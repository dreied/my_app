import 'package:sqflite/sqflite.dart';
import '../database/app_database.dart';
import '../services/activation_service.dart';

class SalesDao {
  Future<Database> get _db async => AppDatabase.instance.database;

  // ---------------------------------------------------------
  // INSERT SALE (with discount support)
  // ---------------------------------------------------------
  Future<int> insertSale({
    required double total,              // total AFTER discount
    required double discountPercent,    // ⭐ NEW
    required double discountAmount,     // ⭐ NEW
    required double paid,               // ⭐ NEW
    required double balance,            // ⭐ NEW
    int? customerId,
    Database? txn,
  }) async {
    final db = txn ?? await _db;
    final activated = await ActivationService.isActivated();

    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM sales'),
    ) ?? 0;

    if (!activated && count >= 5) {
      throw Exception("activationRequiredSales");
    }

    final now = DateTime.now().toIso8601String();

    return await db.insert('sales', {
      'datetime': now,
      'total': total,                   // AFTER discount
      'paid': paid,
      'balance': balance,
      'customer_id': customerId,
      'discount_percent': discountPercent,   // ⭐ NEW
      'discount_amount': discountAmount,     // ⭐ NEW
    });
  }

  // ---------------------------------------------------------
  // GET ALL SALES (HEADER ONLY)
  // ---------------------------------------------------------
  Future<List<Map<String, dynamic>>> getAllSales() async {
    final db = await _db;
    return await db.query(
      'sales',
      orderBy: 'datetime DESC',
    );
  }

  // ---------------------------------------------------------
  // GET SALES BY CUSTOMER
  // ---------------------------------------------------------
  Future<List<Map<String, dynamic>>> getSalesByCustomer(int customerId) async {
    final db = await _db;
    return await db.query(
      'sales',
      where: 'customer_id = ?',
      whereArgs: [customerId],
      orderBy: 'datetime DESC',
    );
  }

  // ---------------------------------------------------------
  // GET SINGLE SALE HEADER
  // ---------------------------------------------------------
  Future<Map<String, dynamic>?> getSaleById(int id) async {
    final db = await _db;
    final result = await db.query(
      'sales',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return result.first;
  }
}
