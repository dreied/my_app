import 'package:sqflite/sqflite.dart';
import '../database/app_database.dart';

class CustomerPaymentsDao {
  Future<Database> get _db async => await AppDatabase.instance.database;

  Future<List<Map<String, dynamic>>> getPayments(int customerId) async {
    final db = await _db;
    return await db.query(
      'customer_payments',
      where: 'customer_id = ?',
      whereArgs: [customerId],
      orderBy: 'datetime DESC',
    );
  }

  // ---------------------------------------------------------
  // ADD PAYMENT (manual payment = Pay Debt)
  // ---------------------------------------------------------
 Future<int> addPayment({
  required int customerId,
  required double amount,
  required String note,
  bool updateBalance = true,
}) async {
  final db = await _db;

  return await db.transaction<int>((txn) async {
    // ⭐ 1) Get current balance BEFORE payment (snapshot)
    final resultBefore = await txn.rawQuery(
      "SELECT balance FROM customers WHERE id = ?",
      [customerId],
    );

    if (resultBefore.isEmpty || resultBefore.first["balance"] == null) {
      throw Exception("Customer balance not found for ID $customerId");
    }

    final double balanceBefore =
        (resultBefore.first["balance"] as num).toDouble();

    // ⭐ 2) Insert payment WITH frozen past balance
    final id = await txn.insert('customer_payments', {
      'customer_id': customerId,
      'amount': amount,
      'datetime': DateTime.now().toIso8601String(),
      'note': note,
      'is_return': 0,
      'type': 'pay_debt',
      'balance_at_time': balanceBefore, // ⭐ NEW — FIXED PAST BALANCE
    });

    // 3) Update balance if needed (your original logic — unchanged)
    if (updateBalance) {
      await txn.rawUpdate(
        "UPDATE customers SET balance = balance + ? WHERE id = ?",
        [amount, customerId],
      );

      final result = await txn.rawQuery(
        "SELECT balance FROM customers WHERE id = ?",
        [customerId],
      );

      if (result.isEmpty || result.first["balance"] == null) {
        throw Exception("Customer balance not found for ID $customerId");
      }

      final newBalance = (result.first["balance"] as num).toDouble();

      // 4) Insert balance history (unchanged)
      await txn.insert('balance_history', {
        'customer_id': customerId,
        'change': amount,
        'new_balance': newBalance,
        'note': note,
        'datetime': DateTime.now().toIso8601String(),
      });
    }

    // 5) Return the inserted payment ID
    return id;
  });
}



  // ---------------------------------------------------------
  // ADD GIVE CASH ENTRY
  // ---------------------------------------------------------
 Future<int> addGiveCash({
  required int customerId,
  required double amount,
  required String note,
}) async {
  final db = await _db;

  return await db.transaction<int>((txn) async {
    // ⭐ Get balance BEFORE payment (snapshot)
    final resultBefore = await txn.rawQuery(
      "SELECT balance FROM customers WHERE id = ?",
      [customerId],
    );

    if (resultBefore.isEmpty || resultBefore.first["balance"] == null) {
      throw Exception("Customer balance not found for ID $customerId");
    }

    final double balanceBefore =
        (resultBefore.first["balance"] as num).toDouble();

    // ⭐ Insert payment with frozen past balance
    final id = await txn.insert('customer_payments', {
      'customer_id': customerId,
      'amount': -amount, // your original logic
      'datetime': DateTime.now().toIso8601String(),
      'note': note,
      'is_return': 0,
      'type': 'give_cash',
      'balance_at_time': balanceBefore, // ⭐ NEW
    });

    // ⭐ Update customer balance (unchanged logic)
    await txn.rawUpdate(
      "UPDATE customers SET balance = balance - ? WHERE id = ?",
      [amount, customerId],
    );

    final result = await txn.rawQuery(
      "SELECT balance FROM customers WHERE id = ?",
      [customerId],
    );

    if (result.isEmpty || result.first["balance"] == null) {
      throw Exception("Customer balance not found for ID $customerId");
    }

    final newBalance = (result.first["balance"] as num).toDouble();

    // ⭐ Insert balance history (unchanged)
    await txn.insert('balance_history', {
      'customer_id': customerId,
      'change': -amount,
      'new_balance': newBalance,
      'note': note,
      'datetime': DateTime.now().toIso8601String(),
    });

    return id;
  });
}



  // ---------------------------------------------------------
  // ADD RETURN ENTRY (refund)
  // ---------------------------------------------------------
 Future<void> addReturnEntry({
  required int customerId,
  required double amount,
  required int saleId,
}) async {
  final db = await _db;

  await db.transaction((txn) async {
    // ⭐ Get balance BEFORE refund
    final resultBefore = await txn.rawQuery(
      "SELECT balance FROM customers WHERE id = ?",
      [customerId],
    );

    if (resultBefore.isEmpty || resultBefore.first["balance"] == null) {
      throw Exception("Customer balance not found for ID $customerId");
    }

    final double balanceBefore =
        (resultBefore.first["balance"] as num).toDouble();

    // ⭐ Insert refund with frozen past balance
    await txn.insert('customer_payments', {
      'customer_id': customerId,
      'amount': amount,
      'datetime': DateTime.now().toIso8601String(),
      'note': 'Refund for return (Sale #$saleId)',
      'is_return': 1,
      'type': 'return',
      'balance_at_time': balanceBefore, // ⭐ NEW
    });

    // ⭐ Update balance (unchanged logic)
    await txn.rawUpdate(
      "UPDATE customers SET balance = balance + ? WHERE id = ?",
      [amount, customerId],
    );

    final result = await txn.rawQuery(
      "SELECT balance FROM customers WHERE id = ?",
      [customerId],
    );

    if (result.isEmpty || result.first["balance"] == null) {
      throw Exception("Customer balance not found for ID $customerId");
    }

    final newBalance = (result.first["balance"] as num).toDouble();

    // ⭐ Insert history (unchanged)
    await txn.insert('balance_history', {
      'customer_id': customerId,
      'change': amount,
      'new_balance': newBalance,
      'note': "Refund for return (Sale #$saleId)",
      'datetime': DateTime.now().toIso8601String(),
    });
  });
}


  // ---------------------------------------------------------
  // ADD PAID DURING SALE ENTRY
  // ---------------------------------------------------------
  // ---------------------------------------------------------
// ADD PAID DURING SALE ENTRY (record only, no balance change)
// ---------------------------------------------------------
Future<void> addPaidDuringSale({
  required int customerId,
  required double amount,
  required int saleId,
}) async {
  final db = await _db;

  // ⭐ Get balance BEFORE payment
  final resultBefore = await db.rawQuery(
    "SELECT balance FROM customers WHERE id = ?",
    [customerId],
  );

  if (resultBefore.isEmpty || resultBefore.first["balance"] == null) {
    throw Exception("Customer balance not found for ID $customerId");
  }

  final double balanceBefore =
      (resultBefore.first["balance"] as num).toDouble();

  // ⭐ Insert payment with frozen past balance
  await db.insert('customer_payments', {
    'customer_id': customerId,
    'amount': amount,
    'datetime': DateTime.now().toIso8601String(),
    'note': "Paid during sale (Invoice #$saleId)",
    'is_return': 0,
    'type': 'paid_sale',
    'balance_at_time': balanceBefore, // ⭐ NEW
  });

  // ❌ No balance update
  // ❌ No balance history
}



  // ---------------------------------------------------------
  // UPDATE PAYMENT
  // ---------------------------------------------------------
  Future<void> updatePayment({
    required int id,
    required int customerId,
    required double oldAmount,
    required double newAmount,
    required String note,
  }) async {
    final db = await _db;

    await db.transaction((txn) async {
      await txn.update(
        'customer_payments',
        {
          'amount': newAmount,
          'note': note,
        },
        where: 'id = ?',
        whereArgs: [id],
      );

      final diff = newAmount - oldAmount;

      await txn.rawUpdate(
        "UPDATE customers SET balance = balance + ? WHERE id = ?",
        [diff, customerId],
      );

      final result = await txn.rawQuery(
        "SELECT balance FROM customers WHERE id = ?",
        [customerId],
      );

      if (result.isEmpty || result.first["balance"] == null) {
        throw Exception("Customer balance not found for ID $customerId");
      }

      final newBalance = (result.first["balance"] as num).toDouble();

      await txn.insert('balance_history', {
        'customer_id': customerId,
        'change': diff,
        'new_balance': newBalance,
        'note': "Edited payment #$id",
        'datetime': DateTime.now().toIso8601String(),
      });
    });
  }

  // ---------------------------------------------------------
  // DELETE PAYMENT
  // ---------------------------------------------------------
  Future<void> deletePayment(int id, double amount, int customerId) async {
    final db = await _db;

    await db.transaction((txn) async {
      await txn.delete(
        'customer_payments',
        where: 'id = ?',
        whereArgs: [id],
      );

      await txn.rawUpdate(
        "UPDATE customers SET balance = balance - ? WHERE id = ?",
        [amount, customerId],
      );

      final result = await txn.rawQuery(
        "SELECT balance FROM customers WHERE id = ?",
        [customerId],
      );

      if (result.isEmpty || result.first["balance"] == null) {
        throw Exception("Customer balance not found for ID $customerId");
      }

      final newBalance = (result.first["balance"] as num).toDouble();

      await txn.insert('balance_history', {
        'customer_id': customerId,
        'change': -amount,
        'new_balance': newBalance,
        'note': "Deleted payment #$id",
        'datetime': DateTime.now().toIso8601String(),
      });
    });
  }
}
