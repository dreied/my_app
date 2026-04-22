import '../database/product_dao.dart';
import '../models/product.dart';
import '../database/app_database.dart';

class InventoryController {
  final ProductDao _productDao = ProductDao();

  Future<List<Product>> loadProducts() async {
    return await _productDao.getAll();
  }

  // Check for existing product by name or barcode
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

  // Add or merge product
  Future<Product?> addOrMergeProduct({
    required String name,
    required double purchasePrice,
    required double sellPrice1,
    required double sellPrice2,
    required double sellPrice3,
    required int stock,
    required String barcode,
    String unit = "pieces",
    String? category,
  }) async {
    final existing = await findByNameOrBarcode(name, barcode);

    if (existing != null) {
      return existing; // UI will show merge dialog
    }

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

    await _productDao.insert(product);
    return null;
  }

  Future<void> increaseStock(Product existing, int addedStock) async {
    final updated = Product(
      id: existing.id,
      name: existing.name,
      purchasePrice: existing.purchasePrice,
      sellPrice1: existing.sellPrice1,
      sellPrice2: existing.sellPrice2,
      sellPrice3: existing.sellPrice3,
      stock: existing.stock + addedStock,
      unit: existing.unit,
      barcode: existing.barcode,
      category: existing.category,
      isDeleted: existing.isDeleted,
    );

    await _productDao.update(updated);
  }

  Future<void> updateProduct(Product product) async {
    await _productDao.update(product);
  }

  // ⭐ Soft delete (Move to Trash)
  Future<void> softDeleteProduct(int id) async {
    await _productDao.softDelete(id);
  }

  // ⭐ Restore from Trash
  Future<void> restoreProduct(int id) async {
    await _productDao.restore(id);
  }

  // ⭐ Permanent delete (Trash Bin only)
  Future<void> deleteForever(int id) async {
    await _productDao.deleteForever(id);
  }
}
