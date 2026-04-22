import 'package:sqflite/sqflite.dart';
import '../database/app_database.dart';

class ReturnDao {
  Future<Database> get _db async => AppDatabase.instance.database;

  // ---------------------------------------------------------
  // INSERT RETURN RECORD (stores discounted unit price)
  // ---------------------------------------------------------
  Future<int> insertReturn({
    required int saleId,
    required int productId,
    required int qty,
    required double price, // discounted unit price
    required String reason,
    required bool restock,
    required bool refund,
  }) async {
    final db = await _db;
    final now = DateTime.now().toIso8601String();

    return await db.insert('returns', {
      'sale_id': saleId,
      'product_id': productId,
      'qty': qty,
      'price': price, // discounted price saved
      'reason': reason,
      'restock': restock ? 1 : 0,
      'refund': refund ? 1 : 0,
      'datetime': now,
    });
  }

  // ---------------------------------------------------------
  // GET ALL RETURNS
  // ---------------------------------------------------------
  Future<List<Map<String, dynamic>>> getReturns() async {
    final db = await _db;
    return await db.query(
      'returns',
      orderBy: 'datetime DESC',
    );
  }

  // ---------------------------------------------------------
  // GET RETURNS FOR SPECIFIC SALE
  // ---------------------------------------------------------
  Future<List<Map<String, dynamic>>> getReturnsForSale(int saleId) async {
    final db = await _db;
    return await db.query(
      'returns',
      where: 'sale_id = ?',
      whereArgs: [saleId],
      orderBy: 'datetime DESC',
    );
  }

  // ---------------------------------------------------------
  // INSERT RETURN HISTORY (discounted price)
  // ---------------------------------------------------------
  Future<void> insertReturnHistory({
    required int saleId,
    required int productId,
    required int qty,
    required double price, // discounted price
    required String datetime,
  }) async {
    final db = await _db;

    await db.insert('return_history', {
      'sale_id': saleId,
      'product_id': productId,
      'qty': qty,
      'price': price,
      'datetime': datetime,
    });
  }
}
