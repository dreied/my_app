import '../database/product_dao.dart';
import '../models/product.dart';
import '../database/app_database.dart';
import 'package:sqflite/sqflite.dart';

class ProductController {
  final ProductDao _dao = ProductDao();

  // Load only active (non-deleted) products
  Future<List<Product>> loadProducts() async {
    final db = await AppDatabase.instance.database;

    final rows = await db.query(
      'products',
      where: 'is_deleted = 0',
    );

    return rows.map((e) => Product.fromMap(e)).toList();
  }

  // Load deleted products (Trash Bin)
  Future<List<Product>> loadDeletedProducts() async {
    final db = await AppDatabase.instance.database;

    final rows = await db.query(
      'products',
      where: 'is_deleted = 1',
    );

    return rows.map((e) => Product.fromMap(e)).toList();
  }

  // Add new product
 Future<void> addProduct({
  required String name,
  required double purchasePrice,
  required double sellPrice1,
  required double sellPrice2,
  required double sellPrice3,
  required int stock,
  required String unit,
  required String barcode,
  String? category,
}) async {

  final product = Product(
    name: name,
    purchasePrice: purchasePrice,
    sellPrice1: sellPrice1,
    sellPrice2: sellPrice2,
    sellPrice3: sellPrice3,
    stock: stock,
    unit: unit,
    barcode: barcode,
    category: category,
    isDeleted: 0,
  );

  await _dao.insert(product);
}


  // Update product
  Future<void> updateProduct(Product product) async {
  

    await _dao.update(product);
  }

  // SOFT DELETE (move to trash)
  Future<void> softDeleteProduct(int id) async {
    final db = await AppDatabase.instance.database;

    await db.update(
      'products',
      {'is_deleted': 1},
      where: 'id = ?',
      whereArgs: [id],
    );

    // Log deletion
    await db.insert('inventory_log', {
      'product_id': id,
      'change_qty': 0,
      'datetime': DateTime.now().toIso8601String(),
    });
  }

  // RESTORE from trash
  Future<void> restoreProduct(int id) async {
    final db = await AppDatabase.instance.database;

    await db.update(
      'products',
      {'is_deleted': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // PERMANENT DELETE (only used inside Trash Bin)
  Future<void> deleteForever(int id) async {
    final db = await AppDatabase.instance.database;
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  // Get product by barcode
  Future<Product?> getByBarcode(String barcode) async {
    final db = await AppDatabase.instance.database;

    final result = await db.query(
      'products',
      where: 'barcode = ? AND is_deleted = 0',
      whereArgs: [barcode],
    );

    if (result.isNotEmpty) {
      return Product.fromMap(result.first);
    }
    return null;
  }

  // Check if barcode exists
  Future<bool> barcodeExists(String barcode, {int? excludeId}) async {
    final db = await AppDatabase.instance.database;

    final result = await db.query(
      'products',
      where: excludeId == null
          ? 'barcode = ? AND is_deleted = 0'
          : 'barcode = ? AND id != ? AND is_deleted = 0',
      whereArgs: excludeId == null ? [barcode] : [barcode, excludeId],
    );

    return result.isNotEmpty;
  }

  // Find by name or barcode
  Future<Product?> findByNameOrBarcode(String name, String barcode) async {
    final db = await AppDatabase.instance.database;

    final result = await db.query(
      'products',
      where: '(name = ? OR barcode = ?) AND is_deleted = 0',
      whereArgs: [name, barcode],
    );

    if (result.isNotEmpty) {
      return Product.fromMap(result.first);
    }
    return null;
  }


  // Count products in category
  Future<int> countProductsInCategory(String category) async {
    final db = await AppDatabase.instance.database;

    final result = await db.rawQuery(
      "SELECT COUNT(*) as count FROM products WHERE category = ? AND is_deleted = 0",
      [category],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Generate unique barcode
  Future<String> generateUniqueBarcode() async {
    final db = await AppDatabase.instance.database;

    while (true) {
      final barcode =
          "1${1000000000000 + DateTime.now().microsecondsSinceEpoch % 999999999999}";

      final result = await db.query(
        'products',
        where: 'barcode = ? AND is_deleted = 0',
        whereArgs: [barcode],
      );

      if (result.isEmpty) {
        return barcode;
      }
    }
  }

  // Get product by ID
  Future<Product> getProduct(int productId) async {
    final db = await AppDatabase.instance.database;

    final result = await db.query(
      'products',
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [productId],
    );

    if (result.isEmpty) {
      throw Exception("Product not found: $productId");
    }

    return Product.fromMap(result.first);
  }

  // Update stock
  Future<void> updateStock(int productId, int newStock) async {
    final db = await AppDatabase.instance.database;

    await db.update(
      'products',
      {'stock': newStock},
      where: 'id = ?',
      whereArgs: [productId],
    );
  }
}
