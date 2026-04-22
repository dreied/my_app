import 'package:flutter/material.dart';
import '../models/category.dart';
import '../database/category_dao.dart';
import '../services/icon_loader.dart';
import '../generated/app_localizations.dart';

class CategoryManagementPage extends StatefulWidget {
  const CategoryManagementPage({super.key});

  @override
  State<CategoryManagementPage> createState() => _CategoryManagementPageState();
}

class _CategoryManagementPageState extends State<CategoryManagementPage> {
  final CategoryDao _dao = CategoryDao();

  List<Category> _categories = [];
  List<Category> _filtered = [];
  List<String> _availableIcons = [];

  String _search = "";
  String _sortMode = "name";

  final List<String> _colors = [
    "#FF5722", "#4CAF50", "#2196F3", "#9C27B0",
    "#FFC107", "#009688", "#000000", "#FF0000",
  ];

  @override
  void initState() {
    super.initState();
    _loadIcons();
    _loadCategories();
  }

  Future<void> _loadIcons() async {
    final icons = await IconLoader.loadIcons();
    setState(() => _availableIcons = icons.isEmpty ? ["bar.png"] : icons);
  }

  Future<void> _loadCategories() async {
    final cats = await _dao.getAll();
    setState(() {
      _categories = cats;
      _applyFilters();
    });
  }

  void _applyFilters() {
    _filtered = _categories.where((c) {
      return c.name.toLowerCase().contains(_search.toLowerCase());
    }).toList();

    if (_sortMode == "name") {
      _filtered.sort((a, b) => a.name.compareTo(b.name));
    }

    setState(() {});
  }

  void _openCategoryDialog({Category? category}) {
    final t = AppLocalizations.of(context)!;
    final isEditing = category != null;

    final nameController = TextEditingController(text: category?.name ?? "");
    String selectedIcon = category?.icon ?? "bar.png";
    String? selectedColor = category?.color;

    void unfocus() => FocusScope.of(context).unfocus();

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? t.editCategory : t.addCategory),
              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: t.categoryName,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text(t.selectIcon),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 200,
                        child: GridView.count(
                          crossAxisCount: 4,
                          children: _availableIcons.map((icon) {
                            return GestureDetector(
                              onTap: () {
                                unfocus();
                                setDialogState(() => selectedIcon = icon);
                              },
                              child: Container(
                                margin: const EdgeInsets.all(6),
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: selectedIcon == icon
                                        ? Colors.blue
                                        : Colors.grey,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Image.asset(
                                  "assets/icons/$icon",
                                  width: 40,
                                  height: 40,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Text(t.selectColor),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 120,
                        child: GridView.count(
                          crossAxisCount: 6,
                          children: _colors.map((hex) {
                            return GestureDetector(
                              onTap: () {
                                unfocus();
                                setDialogState(() => selectedColor = hex);
                              },
                              child: Container(
                                margin: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Color(
                                      int.parse(hex.replaceFirst('#', '0xff'))),
                                  border: Border.all(
                                    color: selectedColor == hex
                                        ? Colors.black
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  child: Text(t.cancel),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  child: Text(isEditing ? t.save : t.add),
                  onPressed: () async {
                    final name = nameController.text.trim();
                    if (name.isEmpty) return;

                    final newCategory = Category(
                      id: category?.id,
                      name: name,
                      color: selectedColor,
                      icon: selectedIcon,
                    );

                    if (isEditing) {
                      await _dao.update(newCategory);
                    } else {
                      await _dao.insert(newCategory);
                    }

                    Navigator.pop(context);
                    _loadCategories();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteCategory(Category c) async {
    final t = AppLocalizations.of(context)!;

    if (await _dao.hasProducts(c.name)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.cannotDeleteCategoryWithProducts),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await _dao.delete(c.id!);
    _loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.manageCategories),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _sortMode = value;
                _applyFilters();
              });
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: "name",
                child: Text(t.sortByName),
              ),
            ],
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCategoryDialog(),
        child: const Icon(Icons.add),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: t.searchCategories,
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                _search = value;
                _applyFilters();
              },
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: _filtered.length,
              itemBuilder: (_, i) {
                final c = _filtered[i];

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: c.color != null
                        ? Color(int.parse(
                            c.color!.replaceFirst('#', '0xff')))
                        : Colors.grey,
                    child: Image.asset(
                      "assets/icons/${c.icon}",
                      width: 24,
                    ),
                  ),
                  title: Text("${c.name} (${c.productCount})"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _openCategoryDialog(category: c),
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
