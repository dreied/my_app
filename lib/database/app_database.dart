import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._internal();
  static Database? _database;

  AppDatabase._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'pos.db');

    return await openDatabase(
      path,
      version: 3, // UPDATED VERSION
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // ---------------------------------------------------------
  // CREATE TABLES (fresh install)
  // ---------------------------------------------------------
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
  unit TEXT NOT NULL DEFAULT 'pieces',   -- NEW COLUMN
  barcode TEXT,
  category TEXT
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
CREATE TABLE sales (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  datetime TEXT NOT NULL,
  total REAL NOT NULL
);
    ''');

    await db.execute('''
CREATE TABLE sale_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  sale_id INTEGER NOT NULL,
  product_id INTEGER NOT NULL,
  qty INTEGER NOT NULL,
  price REAL NOT NULL
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
  }

  // ---------------------------------------------------------
  // MIGRATION (existing installs)
  // ---------------------------------------------------------
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Upgrade to version 2 (categories table safety)
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS categories (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL UNIQUE,
          color TEXT,
          icon TEXT
        );
      ''');
    }

    // Upgrade to version 3 (add unit column)
    if (oldVersion < 3) {
      await db.execute(
        "ALTER TABLE products ADD COLUMN unit TEXT NOT NULL DEFAULT 'pieces';"
      );
    }
  }
}
