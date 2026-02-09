import 'package:flutter/material.dart';
import '../database/category_dao.dart';
import '../models/category.dart';
import '../controllers/product_controller.dart';

class CategoryManagementPage extends StatefulWidget {
  const CategoryManagementPage({super.key});

  @override
  State<CategoryManagementPage> createState() => _CategoryManagementPageState();
}

class _CategoryManagementPageState extends State<CategoryManagementPage> {
  final CategoryDao _dao = CategoryDao();
  final ProductController _productController = ProductController();

  List<Category> _categories = [];
  Map<int, int> _usageMap = {}; // categoryId -> product count

  String _searchQuery = "";
  String _sortMode = "name_asc"; // name_asc, name_desc, usage_desc, usage_asc

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await _dao.getAll();

    // build usage map
    final usage = <int, int>{};
    for (final c in list) {
      if (c.id != null) {
        final count = await _productController.countProductsInCategory(c.name);
        usage[c.id!] = count;
      }
    }

    setState(() {
      _categories = list;
      _usageMap = usage;
    });

    _applySorting();
  }

  // -----------------------------
  // COLOR PICKER
  // -----------------------------
  Future<String?> _pickColor(String? current) async {
    final colors = [
      "#FF0000", "#00AA00", "#0000FF", "#FFA500", "#800080",
      "#008080", "#444444", "#FFC0CB", "#00CED1", "#FFD700"
    ];

    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Pick Color"),
        content: SizedBox(
          width: 300,
          height: 200,
          child: GridView.count(
            crossAxisCount: 5,
            children: colors.map((hex) {
              return GestureDetector(
                onTap: () => Navigator.pop(context, hex),
                child: Container(
                  margin: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Color(int.parse(hex.replaceFirst('#', '0xff'))),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: current == hex ? Colors.black : Colors.white,
                      width: 2,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // -----------------------------
  // ICON PICKER
  // -----------------------------
  Future<String?> _pickIcon(String? current) async {
    final icons = {
      "restaurant": Icons.restaurant,
      "local_drink": Icons.local_drink,
      "fastfood": Icons.fastfood,
      "cleaning_services": Icons.cleaning_services,
      "category": Icons.category,
    };

    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Pick Icon"),
        content: SizedBox(
          width: 300,
          height: 200,
          child: GridView.count(
            crossAxisCount: 4,
            children: icons.entries.map((entry) {
              return GestureDetector(
                onTap: () => Navigator.pop(context, entry.key),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: current == entry.key ? Colors.blue : Colors.grey,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(entry.value, size: 30),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // -----------------------------
  // ADD / EDIT CATEGORY
  // -----------------------------
  Future<void> _editCategory(Category? category) async {
    final nameController = TextEditingController(text: category?.name ?? "");
    String? selectedColor = category?.color;
    String? selectedIcon = category?.icon;

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(category == null ? "Add Category" : "Edit Category"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Category Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Color picker
            Row(
              children: [
                const Text("Color: "),
                GestureDetector(
                  onTap: () async {
                    final picked = await _pickColor(selectedColor);
                    if (picked != null) {
                      setState(() => selectedColor = picked);
                    }
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: selectedColor != null
                          ? Color(int.parse(selectedColor!.replaceFirst('#', '0xff')))
                          : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Icon picker
            Row(
              children: [
                const Text("Icon: "),
                GestureDetector(
                  onTap: () async {
                    final picked = await _pickIcon(selectedIcon);
                    if (picked != null) {
                      setState(() => selectedIcon = picked);
                    }
                  },
                  child: Icon(
                    selectedIcon == null
                        ? Icons.category
                        : _iconFromName(selectedIcon!),
                    size: 28,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Save"),
          ),
        ],
      ),
    );

    if (result == true) {
      final name = nameController.text.trim();
      if (name.isEmpty) return;

      final newCategory = Category(
        id: category?.id,
        name: name,
        color: selectedColor,
        icon: selectedIcon,
      );

      if (category == null) {
        await _dao.insert(newCategory);
      } else {
        await _dao.update(newCategory);
      }

      await _load();
    }
  }

  IconData _iconFromName(String name) {
    switch (name) {
      case "restaurant":
        return Icons.restaurant;
      case "local_drink":
        return Icons.local_drink;
      case "fastfood":
        return Icons.fastfood;
      case "cleaning_services":
        return Icons.cleaning_services;
      default:
        return Icons.category;
    }
  }

  // -----------------------------
  // DELETE CATEGORY (with protection)
  // -----------------------------
  Future<void> _deleteCategory(Category category) async {
    final usage = category.id != null ? _usageMap[category.id!] ?? 0 : 0;

    if (usage > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Cannot delete '${category.name}'. It is used by $usage products.",
          ),
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Category"),
        content: Text("Delete '${category.name}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _dao.delete(category.id!);
      await _load();
    }
  }

  // -----------------------------
  // SORTING + SEARCH
  // -----------------------------
  void _applySorting() {
    setState(() {
      _categories.sort((a, b) {
        final usageA = a.id != null ? _usageMap[a.id!] ?? 0 : 0;
        final usageB = b.id != null ? _usageMap[b.id!] ?? 0 : 0;

        switch (_sortMode) {
          case "name_desc":
            return b.name.toLowerCase().compareTo(a.name.toLowerCase());
          case "usage_desc":
            return usageB.compareTo(usageA);
          case "usage_asc":
            return usageA.compareTo(usageB);
          case "name_asc":
          default:
            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        }
      });
    });
  }

  List<Category> get _filteredCategories {
    if (_searchQuery.isEmpty) return _categories;
    return _categories
        .where((c) => c.name.toLowerCase().contains(_searchQuery))
        .toList();
  }

  // -----------------------------
  // UI
  // -----------------------------
  @override
  Widget build(BuildContext context) {
    final filtered = _filteredCategories;

    return Scaffold(
      appBar: AppBar(title: const Text("Manage Categories")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _editCategory(null),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // SEARCH
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Search categories",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase());
              },
            ),
          ),

          // SORT
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                const Text("Sort by: "),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _sortMode,
                  items: const [
                    DropdownMenuItem(
                      value: "name_asc",
                      child: Text("Name A–Z"),
                    ),
                    DropdownMenuItem(
                      value: "name_desc",
                      child: Text("Name Z–A"),
                    ),
                    DropdownMenuItem(
                      value: "usage_desc",
                      child: Text("Most Used"),
                    ),
                    DropdownMenuItem(
                      value: "usage_asc",
                      child: Text("Least Used"),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _sortMode = value);
                    _applySorting();
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // LIST
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final c = filtered[i];
                final usage =
                    c.id != null ? _usageMap[c.id!] ?? 0 : 0;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: c.color != null
                        ? Color(int.parse(c.color!.replaceFirst('#', '0xff')))
                        : Colors.grey,
                    child: Icon(
                      _iconFromName(c.icon ?? "category"),
                      color: Colors.white,
                    ),
                  ),
                  title: Text(c.name),
                  subtitle: Text("$usage products"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editCategory(c),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteCategory(c),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
