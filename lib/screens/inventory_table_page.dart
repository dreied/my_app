import 'package:flutter/material.dart';
import '../controllers/product_controller.dart';
import '../database/category_dao.dart';
import '../models/category.dart';
import '../models/product.dart';
import 'edit_product_page.dart';
import 'add_product_page.dart';
import 'category_management_page.dart';
import '../controllers/export_controller.dart';

class InventoryTablePage extends StatefulWidget {
  const InventoryTablePage({super.key});

  @override
  State<InventoryTablePage> createState() => _InventoryTablePageState();
}

class _InventoryTablePageState extends State<InventoryTablePage> {
  final ProductController _controller = ProductController();
  final CategoryDao _categoryDao = CategoryDao();
  final ExportController _exportController = ExportController();

  List<Product> _products = [];
  List<Product> _filtered = [];
  List<Category> _categories = [];

  bool loading = true;
  bool showDozens = false;

  String searchQuery = "";
  String selectedCategory = "All";

  int? sortColumnIndex;
  bool sortAscending = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  // ---------------- EXPORT COLUMN SELECTION ----------------

  Future<void> _chooseColumnsAndExport(bool isExcel) async {
    final selected = {
      "barcode": true,
      "name": true,
      "category": true,
      "stock": true,
      "purchase": false,
      "sell1": true,
      "sell2": false,
      "sell3": false,
      "total": true,
    };

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Select Columns"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    _checkbox(setState, selected, "barcode", "Barcode"),
                    _checkbox(setState, selected, "name", "Product Name"),
                    _checkbox(setState, selected, "category", "Category"),
                    _checkbox(setState, selected, "stock", "Stock"),
                    _checkbox(setState, selected, "purchase", "Purchase Price"),
                    _checkbox(setState, selected, "sell1", "Sell Price 1"),
                    _checkbox(setState, selected, "sell2", "Sell Price 2"),
                    _checkbox(setState, selected, "sell3", "Sell Price 3"),
                    _checkbox(setState, selected, "total", "Total Value"),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                if (isExcel) {
                  _exportController.exportInventoryToExcel(
                    context,
                    _filtered,
                    selected,
                  );
                } else {
                  _exportController.exportInventoryToPdf(
                    context,
                    _filtered,
                    selected,
                  );
                }
              },
              child: const Text("Export"),
            ),
          ],
        );
      },
    );
  }

  Widget _checkbox(
    void Function(void Function()) setState,
    Map<String, bool> map,
    String key,
    String label,
  ) {
    return CheckboxListTile(
      value: map[key],
      title: Text(label),
      onChanged: (v) => setState(() => map[key] = v!),
    );
  }

  // ---------------- LOAD DATA ----------------

  Future<void> _load() async {
    final items = await _controller.loadProducts();
    final cats = await _categoryDao.getAll();

    setState(() {
      _products = items;
      _filtered = items;
      _categories = cats;
      loading = false;
    });
  }

  // ---------------- UNIT CONVERSION ----------------

  int _toPieces(Product p) {
    switch (p.unit) {
      case "half":
        return p.stock * 6;
      case "dozen":
        return p.stock * 12;
      default:
        return p.stock;
    }
  }

  String _displayPieces(Product p) {
    final pieces = _toPieces(p);
    return "$pieces pieces";
  }

  String _displayDozens(Product p) {
    final pieces = _toPieces(p);

    if (pieces < 12) return "$pieces pieces";

    final dozens = pieces ~/ 12;
    final remainder = pieces % 12;

    if (remainder == 0) return "$dozens dozen";

    return "$dozens dozen + $remainder pieces";
  }

  String _displayStock(Product p) {
    return showDozens ? _displayDozens(p) : _displayPieces(p);
  }

  // ---------------- CATEGORY HELPERS ----------------

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return Colors.grey;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xff')));
    } catch (_) {
      return Colors.grey;
    }
  }

  IconData _parseIcon(String? name) {
    if (name == null || name.isEmpty) return Icons.category;

    const iconMap = {
      "restaurant": Icons.restaurant,
      "local_drink": Icons.local_drink,
      "fastfood": Icons.fastfood,
      "cleaning_services": Icons.cleaning_services,
      "shopping_cart": Icons.shopping_cart,
      "medical_services": Icons.medical_services,
      "checkroom": Icons.checkroom,
      "build": Icons.build,
      "home": Icons.home,
      "star": Icons.star,
      "phone_android": Icons.phone_android,
      "other": Icons.category,
    };

    return iconMap[name] ?? Icons.category;
  }

  Category? _findCategory(String? name) {
    if (name == null) return null;
    try {
      return _categories.firstWhere((c) => c.name == name);
    } catch (_) {
      return null;
    }
  }

  // ---------------- FILTERS ----------------

  void _applyFilters() {
    final q = searchQuery.toLowerCase();

    setState(() {
      _filtered = _products.where((p) {
        final matchesSearch =
            p.name.toLowerCase().contains(q) ||
            (p.barcode).toLowerCase().contains(q);

        final matchesCategory =
            selectedCategory == "All" || p.category == selectedCategory;

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  // ---------------- SORTING ----------------

  void _sort<T>(Comparable<T> Function(Product p) getField, int columnIndex) {
    setState(() {
      sortColumnIndex = columnIndex;
      sortAscending = !sortAscending;

      _filtered.sort((a, b) {
        final aValue = getField(a);
        final bValue = getField(b);
        return sortAscending
            ? Comparable.compare(aValue, bValue)
            : Comparable.compare(bValue, aValue);
      });
    });
  }

  // ---------------- EXPORT MENU ----------------

  void _showExportMenu() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SizedBox(
        height: 160,
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.table_view),
              title: const Text("Export to Excel"),
              onTap: () {
                Navigator.pop(context);
                _chooseColumnsAndExport(true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text("Export to PDF"),
              onTap: () {
                Navigator.pop(context);
                _chooseColumnsAndExport(false);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    final categoryFilterList = [
      "All",
      ..._categories.map((c) => c.name),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Inventory"),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _showExportMenu,
          ),
          Row(
            children: [
              const Text("Pieces"),
              Switch(
                value: showDozens,
                onChanged: (v) {
                  setState(() => showDozens = v);
                },
              ),
              const Text("Dozens"),
              const SizedBox(width: 10),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.category),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CategoryManagementPage(),
                ),
              ).then((value) => _load());
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddProductPage(),
            ),
          ).then((value) {
            if (value == true) _load();
          });
        },
        child: const Icon(Icons.add),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: "Search by name or barcode",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      searchQuery = value;
                      _applyFilters();
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: "Category",
                      border: OutlineInputBorder(),
                    ),
                    items: categoryFilterList
                        .map(
                          (c) => DropdownMenuItem(
                            value: c,
                            child: Text(c),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      selectedCategory = value!;
                      _applyFilters();
                    },
                  ),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      sortColumnIndex: sortColumnIndex,
                      sortAscending: sortAscending,
                      headingRowColor:
                          WidgetStateProperty.all(Colors.grey.shade300),
                      columns: [
                        DataColumn(
                          label: const Text("Barcode"),
                          onSort: (i, _) => _sort((p) => p.barcode, i),
                        ),
                        DataColumn(
                          label: const Text("Product"),
                          onSort: (i, _) => _sort((p) => p.name, i),
                        ),
                        DataColumn(
                          label: const Text("Category"),
                          onSort: (i, _) => _sort((p) => p.category ?? "", i),
                        ),
                        DataColumn(
                          label: const Text("Stock"),
                          numeric: true,
                          onSort: (i, _) => _sort((p) => _toPieces(p), i),
                        ),
                        DataColumn(
                          label: const Text("Purchase"),
                          numeric: true,
                          onSort: (i, _) => _sort((p) => p.purchasePrice, i),
                        ),
                        DataColumn(
                          label: const Text("Sell1(مفرق)"),
                          numeric: true,
                          onSort: (i, _) => _sort((p) => p.sellPrice1, i),
                        ),
                        DataColumn(
                          label: const Text("Sell2(جملة)"),
                          numeric: true,
                          onSort: (i, _) => _sort((p) => p.sellPrice2, i),
                        ),
                        DataColumn(
                          label: const Text("Sell3(خاص)"),
                          numeric: true,
                          onSort: (i, _) => _sort((p) => p.sellPrice3, i),
                        ),
                      ],
                      rows: _filtered.map((p) {
                        final lowStock = _toPieces(p) <= 12;
                        final cat = _findCategory(p.category);

                        return DataRow(
                          color: lowStock
                              ? WidgetStateProperty.all(Colors.red.shade100)
                              : null,
                          cells: [
                            DataCell(Text(p.barcode)),
                            DataCell(Text(p.name)),
                            DataCell(
                              Row(
                                children: [
                                  Icon(
                                    _parseIcon(cat?.icon),
                                    size: 18,
                                    color: _parseColor(cat?.color),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(p.category ?? "—"),
                                ],
                              ),
                            ),
                            DataCell(Text(_displayStock(p))),
                            DataCell(Text(p.purchasePrice.toString())),
                            DataCell(Text(p.sellPrice1.toString())),
                            DataCell(Text(p.sellPrice2.toString())),
                            DataCell(Text(p.sellPrice3.toString())),
                          ],
                          onSelectChanged: (_) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditProductPage(product: p),
                              ),
                            ).then((_) => _load());
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
