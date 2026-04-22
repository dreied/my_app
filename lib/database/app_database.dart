import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._internal();
  static Database? _database;

  AppDatabase._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    try {
      _database = await _initDb();
    } catch (e) {
      print("DB ERROR: $e");
    }
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'pos.db');

    return await openDatabase(
      path,
      version: 6, // ⭐ NEW VERSION
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // ⭐ ADD THIS
    );
  }

 Future<void> _onCreate(Database db, int version) async {
  await db.execute('''
CREATE TABLE products (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  purchase_price REAL NOT NULL,
  sell_price1 REAL NOT NULL,
  sell_price2 REAL NOT NULL,
  sell_price3 REAL NOT NULL,
  stock INTEGER NOT NULL,
  unit TEXT NOT NULL DEFAULT 'pieces',
  barcode TEXT,
  category TEXT,
  is_deleted INTEGER NOT NULL DEFAULT 0
);
  ''');

  await db.execute('''
CREATE TABLE categories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  color TEXT,
  icon TEXT
);
  ''');

  await db.execute('''
CREATE TABLE customers (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  phone TEXT,
  address TEXT,
  notes TEXT,
  balance REAL NOT NULL DEFAULT 0,
  initial_balance REAL NOT NULL DEFAULT 0,
  initial_balance_date TEXT
);
  ''');

  await db.execute('''
CREATE TABLE sales (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  datetime TEXT NOT NULL,
  total REAL NOT NULL,
  paid REAL NOT NULL DEFAULT 0,
  balance REAL NOT NULL DEFAULT 0,
  customer_id INTEGER,
  discount_percent REAL NOT NULL DEFAULT 0,   -- ⭐ add
  discount_amount REAL NOT NULL DEFAULT 0,    -- ⭐ add
   balance_before_sale REAL,
  balance_after_sale REAL,
  FOREIGN KEY(customer_id) REFERENCES customers(id)
);
  ''');

  await db.execute('''
CREATE TABLE sale_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  sale_id INTEGER NOT NULL,
  product_id INTEGER NOT NULL,
  qty INTEGER NOT NULL,
  price REAL NOT NULL,
  returned_qty INTEGER NOT NULL DEFAULT 0
);
  ''');

  await db.execute('''
CREATE TABLE inventory_log (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  product_id INTEGER NOT NULL,
  change_qty INTEGER NOT NULL,
  datetime TEXT NOT NULL
);
  ''');

  await db.execute('''
CREATE TABLE customer_product_prices (
  customer_id INTEGER NOT NULL,
  product_id INTEGER NOT NULL,
  price_level INTEGER NOT NULL,
  custom_price REAL,
  PRIMARY KEY (customer_id, product_id)
);

  ''');

  await db.execute('''
CREATE TABLE customer_payments (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  customer_id INTEGER NOT NULL,
  amount REAL NOT NULL,
  datetime TEXT NOT NULL,
  note TEXT,
  is_return INTEGER NOT NULL DEFAULT 0,
 type TEXT NOT NULL,
balance_at_time REAL,

  FOREIGN KEY(customer_id) REFERENCES customers(id)
);
  ''');

  await db.execute('''
CREATE TABLE returns (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  sale_id INTEGER NOT NULL,
  product_id INTEGER NOT NULL,
  qty INTEGER NOT NULL,
  price REAL NOT NULL,
  reason TEXT NOT NULL,
  restock INTEGER NOT NULL,
  refund INTEGER NOT NULL,
  datetime TEXT NOT NULL
);
  ''');

  await db.execute('''
CREATE TABLE return_history (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  sale_id INTEGER NOT NULL,
  product_id INTEGER NOT NULL,
  qty INTEGER NOT NULL,
  price REAL NOT NULL,
  datetime TEXT NOT NULL
);
  ''');

  await db.execute('''
CREATE TABLE balance_history (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  customer_id INTEGER NOT NULL,
  change REAL NOT NULL,
  new_balance REAL NOT NULL,
  note TEXT,
  datetime TEXT NOT NULL,
  FOREIGN KEY(customer_id) REFERENCES customers(id)
);
  ''');

  await db.execute('''
CREATE TABLE manager (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  pin TEXT NOT NULL
);
  ''');
}

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 2) {
    // ⭐ 1) Add new columns
    await db.execute('ALTER TABLE customers ADD COLUMN initial_balance REAL NOT NULL DEFAULT 0;');
    await db.execute('ALTER TABLE customers ADD COLUMN initial_balance_date TEXT;');

    // ⭐ 2) Copy existing balance into initial_balance
    await db.update(
      'customers',
      {
        'initial_balance': 0, // temporary, will fix below
      },
    );

    // ⭐ 3) For existing customers, treat current balance as "initial"
    final now = DateTime.now().toIso8601String();
    await db.rawUpdate('UPDATE customers SET initial_balance = balance, initial_balance_date = ?', [now]);
  }
  if (oldVersion < 3) {
  await db.execute(
      'ALTER TABLE sales ADD COLUMN discount_percent REAL NOT NULL DEFAULT 0;');
  await db.execute(
      'ALTER TABLE sales ADD COLUMN discount_amount REAL NOT NULL DEFAULT 0;');
}
if (oldVersion < 4) {
  await db.execute(
    'ALTER TABLE customer_product_prices ADD COLUMN custom_price REAL;'
  );
}
if (oldVersion < 5) {
  await db.execute('ALTER TABLE customer_payments ADD COLUMN type TEXT;');

  // Optional: backfill existing rows
  await db.rawUpdate("UPDATE customer_payments SET type = 'pay_debt' WHERE type IS NULL AND is_return = 0 AND amount > 0");
  await db.rawUpdate("UPDATE customer_payments SET type = 'give_cash' WHERE type IS NULL AND is_return = 0 AND amount < 0");
  await db.rawUpdate("UPDATE customer_payments SET type = 'return' WHERE type IS NULL AND is_return = 1");
}

if (oldVersion < 6) {
  await db.execute('ALTER TABLE customer_payments ADD COLUMN balance_at_time REAL;');

  await db.execute('ALTER TABLE sales ADD COLUMN balance_before_sale REAL;');
  await db.execute('ALTER TABLE sales ADD COLUMN balance_after_sale REAL;');
}



}

}
