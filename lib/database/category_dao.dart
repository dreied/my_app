import '../models/category.dart';
import '../services/icon_loader.dart';
import 'app_database.dart';

class CategoryDao {
  static List<String> validIcons = [];

  static Future<void> initializeIcons() async {
    validIcons = await IconLoader.loadIcons();
    if (validIcons.isEmpty) validIcons = ["bar.png"];
  }

  String _sanitizeIcon(String? icon) {
    if (icon == null || icon.isEmpty) return "bar.png";
    if (!icon.contains(".")) icon = "$icon.png";
    if (!validIcons.contains(icon)) return "bar.png";
    return icon;
  }

  Future<void> insert(Category category) async {
    final db = await AppDatabase.instance.database;
    await db.insert("categories", {
      "name": category.name,
      "color": category.color,
      "icon": _sanitizeIcon(category.icon),
    });
  }

  Future<void> update(Category category) async {
    final db = await AppDatabase.instance.database;
    await db.update(
      "categories",
      {
        "name": category.name,
        "color": category.color,
        "icon": _sanitizeIcon(category.icon),
      },
      where: "id = ?",
      whereArgs: [category.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await AppDatabase.instance.database;
    await db.delete("categories", where: "id = ?", whereArgs: [id]);
  }

  // FIXED: use category NAME, not ID
  Future<bool> hasProducts(String categoryName) async {
    final db = await AppDatabase.instance.database;
    final result = await db.rawQuery(
      "SELECT COUNT(*) AS count FROM products WHERE category = ?",
      [categoryName],
    );
    return (result.first["count"] as int) > 0;
  }

  // FIXED: use category NAME, not ID
  Future<int> getProductCount(String categoryName) async {
    final db = await AppDatabase.instance.database;
    final result = await db.rawQuery(
      "SELECT COUNT(*) AS count FROM products WHERE category = ?",
      [categoryName],
    );
    return result.first["count"] as int;
  }

  Future<List<Category>> getAll() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query("categories");

    return rows.map((row) {
      return Category(
        id: row["id"] as int?,
        name: row["name"] as String,
        color: row["color"] as String?,
        icon: _sanitizeIcon(row["icon"] as String?),
        productCount: 0, // will be filled later
      );
    }).toList();
  }
}