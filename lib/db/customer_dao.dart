import 'package:sqflite/sqflite.dart';
import '../database/app_database.dart';
import '../models/customer.dart';
import '../services/activation_service.dart';

class CustomerDao {
  Future<Database> get _db async => AppDatabase.instance.database;

  Future<int> insertCustomer(Customer customer) async {
    final db = await _db;
    final activated = await ActivationService.isActivated();

    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM customers'),
    ) ?? 0;

    if (!activated && count >= 2) {
      throw Exception("activationRequiredCustomers");
    }

    return await db.insert('customers', customer.toMap());
  }

  // other methods unchanged...



  Future<List<Customer>> getAllCustomers() async {
    final db = await _db;
    final result = await db.query(
      'customers',
      orderBy: 'name ASC',
    );
    return result.map((e) => Customer.fromMap(e)).toList();
  }
Future<void> migrateFixBalances() async {
  final db = await _db;

  // 1. Load all customers
  final customers = await db.query('customers');

  for (final c in customers) {
    final id = c['id'] as int;
    final initialBalance = c['balance'] as double;

    // 2. Load all sales for this customer
    final sales = await db.query(
      'sales',
      where: 'customer_id = ?',
      whereArgs: [id],
    );

    // 3. Load all payments for this customer
    final payments = await db.query(
      'customer_payments',
      where: 'customer_id = ?',
      whereArgs: [id],
    );

    double balance = initialBalance;

    // Apply sales (increase debt)
    for (final s in sales) {
      balance -= (s['total'] as num).toDouble();
    }

    // Apply payments (reduce debt)
    for (final p in payments) {
      balance += (p['amount'] as num).toDouble();
    }

    // 4. Save corrected balance
    await db.update(
      'customers',
      {'balance': balance},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
Future<void> resetAllCustomersToInitial() async {
  final db = await _db;

  await db.rawUpdate('''
    UPDATE customers
    SET balance = initial_balance
  ''');
}

Future<void> updateInitialBalance(
  int id,
  double value, {
  Database? txn,
}) async {
  final db = txn ?? await _db;

  await db.update(
    'customers',
    {
      'initial_balance': value,
      'initial_balance_date': DateTime.now().toIso8601String(),
    },
    where: 'id = ?',
    whereArgs: [id],
  );
}



  Future<Customer?> getCustomerById(int id) async {
    final db = await _db;
    final result = await db.query(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return Customer.fromMap(result.first);
  }

  Future<void> updateBalance(
  int customerId,
  double newBalance, {
  Database? txn,
}) async {
  final db = txn ?? await _db;

  await db.update(
    'customers',
    {'balance': newBalance},
    where: 'id = ?',
    whereArgs: [customerId],
  );
}


  // ---------------------------------------------------------
  // DELETE CUSTOMER (only call this if balance == 0)
  // ---------------------------------------------------------
 Future<void> deleteCustomer(
  int id, {
  Database? txn,
}) async {
  final db = txn ?? await _db;

  await db.delete(
    'customers',
    where: 'id = ?',
    whereArgs: [id],
  );
}

  Future<int> updateCustomer(Customer customer) async {
  final db = await _db;

  // Do NOT update balance here
  return await db.update(
    'customers',
    {
      'name': customer.name,
      'phone': customer.phone,
      'address': customer.address,
      'notes': customer.notes,
      // balance intentionally excluded
    },
    where: 'id = ?',
    whereArgs: [customer.id],
    
  );
}


}
