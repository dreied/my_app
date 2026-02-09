import '../database/product_dao.dart';
import '../models/product.dart';
import '../database/app_database.dart';
import 'package:sqflite/sqflite.dart';

class ProductController {
  final ProductDao _dao = ProductDao();

  Future<List<Product>> loadProducts() {
    return _dao.getAll();
  }

  Future<void> addProduct({
    required String name,
    required double purchasePrice,
    required double sellPrice1,
    required double sellPrice2,
    required double sellPrice3,
    required int stock,
    required String unit, // NEW
    required String barcode,
    String? category,
  }) async {
    if (sellPrice1 < purchasePrice ||
        sellPrice2 < purchasePrice ||
        sellPrice3 < purchasePrice) {
      throw Exception("Sell price cannot be lower than purchase price");
    }

    final product = Product(
      name: name,
      purchasePrice: purchasePrice,
      sellPrice1: sellPrice1,
      sellPrice2: sellPrice2,
      sellPrice3: sellPrice3,
      stock: stock,
      unit: unit, // NEW
      barcode: barcode,
      category: category,
    );

    await _dao.insert(product);
  }

  Future<void> updateProduct(Product product) async {
    if (product.sellPrice1 < product.purchasePrice ||
        product.sellPrice2 < product.purchasePrice ||
        product.sellPrice3 < product.purchasePrice) {
      throw Exception("Sell price cannot be lower than purchase price");
    }

    await _dao.update(product);
  }

  Future<void> deleteProduct(int id) async {
    await _dao.delete(id);
  }

  Future<Product?> getByBarcode(String barcode) async {
    final db = await AppDatabase.instance.database;

    final result = await db.query(
      'products',
      where: 'barcode = ?',
      whereArgs: [barcode],
    );

    if (result.isNotEmpty) {
      return Product.fromMap(result.first);
    }
    return null;
  }

  Future<bool> barcodeExists(String barcode, {int? excludeId}) async {
    final db = await AppDatabase.instance.database;

    final result = await db.query(
      'products',
      where: excludeId == null
          ? 'barcode = ?'
          : 'barcode = ? AND id != ?',
      whereArgs: excludeId == null ? [barcode] : [barcode, excludeId],
    );

    return result.isNotEmpty;
  }

  Future<Product?> findByNameOrBarcode(String name, String barcode) async {
    final db = await AppDatabase.instance.database;

    final result = await db.query(
      'products',
      where: 'name = ? OR barcode = ?',
      whereArgs: [name, barcode],
    );

    if (result.isNotEmpty) {
      return Product.fromMap(result.first);
    }
    return null;
  }

  // ---------------------------------------------------------
  // CATEGORY USAGE COUNT (for protection + display)
  // ---------------------------------------------------------
  Future<int> countProductsInCategory(String category) async {
    final db = await AppDatabase.instance.database;

    final result = await db.rawQuery(
      "SELECT COUNT(*) as count FROM products WHERE category = ?",
      [category],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ---------------------------------------------------------
  // BARCODE GENERATOR
  // ---------------------------------------------------------
  Future<String> generateUniqueBarcode() async {
    final db = await AppDatabase.instance.database;

    while (true) {
      final barcode =
          "1${1000000000000 + DateTime.now().microsecondsSinceEpoch % 999999999999}";

      final result = await db.query(
        'products',
        where: 'barcode = ?',
        whereArgs: [barcode],
      );

      if (result.isEmpty) {
        return barcode;
      }
    }
  }
}
