import 'package:sqflite/sqflite.dart';
import '../models/product.dart';
import 'app_database.dart';
import '../services/activation_service.dart';

class ProductDao {
  Future<Database> get _db async => await AppDatabase.instance.database;

  Future<int> insert(Product product) async {
    final db = await _db;
    final activated = await ActivationService.isActivated();

    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM products WHERE is_deleted = 0'),
    ) ?? 0;

    if (!activated && count >= 5) {
      throw Exception("activationRequiredProducts");
    }

    return await db.insert(
      'products',
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all ACTIVE products
  Future<List<Product>> getAll() async {
    final db = await _db;

    final result = await db.query(
      'products',
      where: 'is_deleted = 0',
      orderBy: 'name ASC',
    );

    return result.map((map) => Product.fromMap(map)).toList();
  }

  // Get all DELETED products (Trash Bin)
  Future<List<Product>> getDeleted() async {
    final db = await _db;

    final result = await db.query(
      'products',
      where: 'is_deleted = 1',
      orderBy: 'name ASC',
    );

    return result.map((map) => Product.fromMap(map)).toList();
  }

  // Insert product
  

  // Update product
  Future<int> update(Product product) async {
    final db = await _db;

    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  // SOFT DELETE (move to trash)
  Future<int> softDelete(int id) async {
    final db = await _db;

    return await db.update(
      'products',
      {'is_deleted': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // RESTORE from trash
  Future<int> restore(int id) async {
    final db = await _db;

    return await db.update(
      'products',
      {'is_deleted': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // PERMANENT DELETE (only from Trash Bin)
  Future<int> deleteForever(int id) async {
    final db = await _db;

    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get product by ID (active OR deleted)
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
