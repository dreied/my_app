import 'package:sqflite/sqflite.dart';
import 'app_database.dart';
import '../models/category.dart';


class CategoryDao {
  Future<int> insert(Category category) async {
    final db = await AppDatabase.instance.database;
    return db.insert('categories', category.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Category>> getAll() async {
    final db = await AppDatabase.instance.database;
    final result = await db.query('categories', orderBy: 'name ASC');
    return result.map((e) => Category.fromMap(e)).toList();
  }

  Future<int> update(Category category) async {
    final db = await AppDatabase.instance.database;
    return db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await AppDatabase.instance.database;
    return db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Category?> findByName(String name) async {
    final db = await AppDatabase.instance.database;
    final result = await db.query(
      'categories',
      where: 'name = ?',
      whereArgs: [name],
    );
    if (result.isNotEmpty) {
      return Category.fromMap(result.first);
    }
    return null;
  }
}
