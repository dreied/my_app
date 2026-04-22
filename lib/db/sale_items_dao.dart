import 'package:sqflite/sqflite.dart';
import '../database/app_database.dart';

class SaleItemsDao {
  Future<Database> get _db async => AppDatabase.instance.database;

  // ---------------------------------------------------------
  // INSERT ONE SALE ITEM
  // ---------------------------------------------------------
  Future<int> insertSaleItem({
    required int saleId,
    required int productId,
    required int qty,
    required double price,
  }) async {
    final db = await _db;
    return await db.insert('sale_items', {
      'sale_id': saleId,
      'product_id': productId,
      'qty': qty,
      'price': price,
      // ensure returned_qty exists for new rows
      'returned_qty': 0,
    });
  }

  // ---------------------------------------------------------
  // LOAD ITEMS FOR A SALE
  // ---------------------------------------------------------
  Future<List<Map<String, dynamic>>> getItemsForSale(int saleId) async {
    final db = await _db;
    return await db.query(
      'sale_items',
      where: 'sale_id = ?',
      whereArgs: [saleId],
    );
  }

  // ---------------------------------------------------------
  // GET ONE SALE ITEM (needed for return validation)
  // ---------------------------------------------------------
  Future<Map<String, dynamic>> getSaleItem(int saleId, int productId) async {
    final db = await _db;

    final result = await db.query(
      'sale_items',
      where: 'sale_id = ? AND product_id = ?',
      whereArgs: [saleId, productId],
      limit: 1,
    );

    if (result.isEmpty) {
      throw Exception(
        "Sale item not found for saleId=$saleId productId=$productId",
      );
    }

    return result.first;
  }

  // ---------------------------------------------------------
  // UPDATE returned_qty
  // ---------------------------------------------------------
  Future<void> updateReturnedQty({
    required int saleId,
    required int productId,
    required int newReturnedQty,
  }) async {
    final db = await _db;

    await db.update(
      'sale_items',
      {'returned_qty': newReturnedQty},
      where: 'sale_id = ? AND product_id = ?',
      whereArgs: [saleId, productId],
    );
  }
}