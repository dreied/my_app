import 'package:sqflite/sqflite.dart';
import '../models/product.dart';
import 'app_database.dart';

class ProductDao {
  Future<Database> get _db async => await AppDatabase.instance.database;

  // ---------------------------------------------------------
  // GET ALL PRODUCTS
  // ---------------------------------------------------------
  Future<List<Product>> getAll() async {
    final db = await _db;
    final result = await db.query('products');

    return result.map((map) => Product.fromMap(map)).toList();
  }

  // ---------------------------------------------------------
  // INSERT PRODUCT
  // ---------------------------------------------------------
  Future<int> insert(Product product) async {
    final db = await _db;
    return await db.insert(
      'products',
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ---------------------------------------------------------
  // UPDATE PRODUCT
  // ---------------------------------------------------------
  Future<int> update(Product product) async {
    final db = await _db;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  // ---------------------------------------------------------
  // DELETE PRODUCT
  // ---------------------------------------------------------
  Future<int> delete(int id) async {
    final db = await _db;
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ---------------------------------------------------------
  // GET PRODUCT BY ID
  // ---------------------------------------------------------
  Future<Product?> getById(int id) async {
    final db = await _db;
    final result = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return Product.fromMap(result.first);
    }
    return null;
  }
}
