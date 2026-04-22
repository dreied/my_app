import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';

import '../controllers/product_controller.dart';
import '../database/category_dao.dart';
import '../models/category.dart';
import '../models/product.dart';
import 'edit_product_page.dart';
import 'add_product_page.dart';
import 'category_management_page.dart';
import '../controllers/export_controller.dart';
import '../services/settings_service.dart';
import '../widgets/embedded_scanner_box.dart';
import '../generated/app_localizations.dart';
import '../utils/pin_guard.dart';
import '../utils/units.dart';
import 'trash_bin_page.dart';

class InventoryTablePage extends StatefulWidget {
  const InventoryTablePage({super.key});

  @override
  State<InventoryTablePage> createState() => _InventoryTablePageState();
}

class _InventoryTablePageState extends State<InventoryTablePage> {
  final ProductController _controller = ProductController();
  final CategoryDao _categoryDao = CategoryDao();
  final ExportController _exportController = ExportController();
  final SettingsService _settings = SettingsService();

  bool loading = true;
  bool showScanner = false;
  bool showDozens = false;
  bool showLowStockOnly = false;

  List<Product> _products = [];
  List<Product> _filtered = [];
  List<Category> _categories = [];

  Map<String, Category> _categoryByName = {};

  String searchQuery = "";
  Set<String> selectedCategories = {"All"};

  final Set<int?> _selectedIds = {};

  int get _lowStockThreshold => _settings.lowStockThreshold;

  int _sortColumnIndex = 1;
  bool _sortAscending = true;

  final Map<String, bool> _visible = {
    "product": true,
    "barcode": true,
    "category": true,
    "stock": true,
    "purchase": true,
    "retail": true,
    "wholesale": true,
    "special": true,
  };
double _totalInventoryCost = 0;
double _totalRetailValue = 0;
double _totalWholesaleValue = 0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    loading = true;
    setState(() {});

    final cats = await _categoryDao.getAll();

    for (final c in cats) {
      c.productCount = await _categoryDao.getProductCount(c.name);
    }

    final lookup = <String, Category>{};
    for (final c in cats) {
      String icon = c.icon ?? "bar.png";
      if (!icon.contains(".")) icon = "$icon.png";

      lookup[c.name] = c.copyWith(icon: icon);

      precacheImage(
        AssetImage("assets/icons/$icon"),
        context,
        onError: (_, __) {},
      );
    }

    final items = await _controller.loadProducts();

    _products = items;
    _filtered = items;
    _categories = cats;
    _categoryByName = lookup;

    loading = false;
    _selectedIds.clear();

    setState(() {});
    _applyFilters();
    _calculateTotals();
  }

  // Always stored in pieces now
int _toPieces(Product p) {
  return p.stock;
}

String _displayStock(Product p) {
  final pieces = p.stock;

  if (!showDozens) {
    return "$pieces ${stockUnit(context, pieces)}";
  }

  final dozens = pieces ~/ 12;
  final remainder = pieces % 12;

  if (dozens == 0) {
    return "$pieces ${stockUnit(context, pieces)}";
  }

  if (remainder == 0) {
    return "$dozens ${AppLocalizations.of(context)!.dozens}";
  }

  return "$dozens ${AppLocalizations.of(context)!.dozens} + "
         "$remainder ${stockUnit(context, remainder)}";
}

Widget _buildInventoryItem({required String label, required String value}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        value,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    ],
  );
}

void _calculateTotals() {
  double cost = 0;
  double retail = 0;
  double wholesale = 0;

  for (final p in _filtered) {
    final qty = _toPieces(p);

    cost += qty * p.purchasePrice;
    retail += qty * p.sellPrice1;
    wholesale += qty * p.sellPrice2;
  }

  setState(() {
    _totalInventoryCost = cost;
    _totalRetailValue = retail;
    _totalWholesaleValue = wholesale;
  });
}

  void _applyFilters() {
    final q = searchQuery.toLowerCase();

    _filtered = _products.where((p) {
      final matchesSearch =
          p.name.toLowerCase().contains(q) ||
          p.barcode.toLowerCase().contains(q);

      final matchesCategory =
          selectedCategories.contains("All") ||
          selectedCategories.contains(p.category);

      final isLowStock = _toPieces(p) <= _lowStockThreshold;
      final matchesLowStock = !showLowStockOnly || isLowStock;

      return matchesSearch && matchesCategory && matchesLowStock;
    }).toList();
 _calculateTotals();
    setState(() {});
  }


  void _sort<T>(
    Comparable<T> Function(Product p) getField,
    int columnIndex,
    bool ascending,
  ) {
    _filtered.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });

    _sortColumnIndex = columnIndex;
    _sortAscending = ascending;
    setState(() {});
  }

  // -------------------------------------------------------------
  // EXPORT HELPERS
  // -------------------------------------------------------------

  /// If user selected products → export only selected
  /// If none selected → export all filtered
  List<Product> _exportList() {
    if (_selectedIds.isEmpty) return _filtered;
    return _filtered.where((p) => _selectedIds.contains(p.id)).toList();
  }

  /// Map visible columns → export controller keys
  Map<String, bool> _exportSelection() {
    return {
      "barcode": _visible["barcode"] ?? true,
      "name": _visible["product"] ?? true,
      "category": _visible["category"] ?? true,
      "stock": _visible["stock"] ?? true,
      "purchase": _visible["purchase"] ?? true,
      "sell1": _visible["retail"] ?? true,
      "sell2": _visible["wholesale"] ?? true,
      "sell3": _visible["special"] ?? true,
      "total": true,
    };
  }

  // -------------------------------------------------------------
  // COLUMN DRAWER
  // -------------------------------------------------------------

  Widget _buildColumnDrawer() {
    final t = AppLocalizations.of(context)!;

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(8),
          children: [
            ListTile(
              title: Text(
                t.columns,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            _buildDrawerToggle(t.product, "product"),
            _buildDrawerToggle(t.barcode, "barcode"),
            _buildDrawerToggle(t.category, "category"),
            _buildDrawerToggle(t.stock, "stock"),
            _buildDrawerToggle(t.purchase, "purchase"),
            _buildDrawerToggle(t.retail, "retail"),
            _buildDrawerToggle(t.wholesale, "wholesale"),
            _buildDrawerToggle(t.special, "special"),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerToggle(String label, String key) {
    return SwitchListTile(
      title: Text(label),
      value: _visible[key] ?? true,
      onChanged: (v) {
        _visible[key] = v;
        setState(() {});
      },
    );
  }

  // -------------------------------------------------------------
  // CATEGORY FILTER DIALOG
  // -------------------------------------------------------------

  void _openCategoryFilterDialog() {
    final t = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(t.filterByCategory),
              content: SizedBox(
                width: 400,
                height: 500,
                child: ListView(
                  children: [
                    CheckboxListTile(
                      value: selectedCategories.contains("All"),
                      title: Text(t.allCategories),
                      onChanged: (v) {
                        setDialogState(() {
                          selectedCategories.clear();
                          selectedCategories.add("All");
                        });
                      },
                    ),
                    const Divider(),
                    ..._categories.map((c) {
                      final isSelected = selectedCategories.contains(c.name);

                      return CheckboxListTile(
                        value: isSelected,
                        onChanged: (v) {
                          setDialogState(() {
                            if (v == true) {
                              selectedCategories.remove("All");
                              selectedCategories.add(c.name);
                            } else {
                              selectedCategories.remove(c.name);
                            }

                            if (selectedCategories.isEmpty) {
                              selectedCategories.add("All");
                            }
                          });
                        },
                        title: Row(
                          children: [
                            Image.asset(
                              "assets/icons/${c.icon}",
                              width: 24,
                              height: 24,
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: c.color != null
                                    ? Color(int.parse(
                                        c.color!.replaceFirst('#', '0xff')))
                                    : Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "${c.name} (${c.productCount})",
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text(t.cancel),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  child: Text(t.apply),
                  onPressed: () {
                    Navigator.pop(context);
                    _applyFilters();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // -------------------------------------------------------------
  // BUILD UI
  // -------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
  key: _scaffoldKey,
  endDrawer: _buildColumnDrawer(),

  appBar: AppBar(
    title: Text(t.inventory),
    actions: [
      // ---------------------------------------------------------
      // EXPORT BUTTON
      // ---------------------------------------------------------
      PopupMenuButton<String>(
        icon: const Icon(Icons.download),
        onSelected: (value) async {
          final selectedColumns = _exportSelection();
          final exportProducts = _exportList();

          if (exportProducts.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(t.noProductsToExport)),
            );
            return;
          }

          if (value == "excel") {
            await _exportController.exportInventoryToExcel(
              context,
              exportProducts,
              selectedColumns,
            );
          }

          if (value == "pdf") {
            await _exportController.exportInventoryToPdf(
              context,
              exportProducts,
              selectedColumns,
            );
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: "excel",
            child: Row(
              children: const [
                Icon(Icons.table_chart, color: Colors.green),
                SizedBox(width: 10),
                Text("Export to Excel"),
              ],
            ),
          ),
          PopupMenuItem(
            value: "pdf",
            child: Row(
              children: const [
                Icon(Icons.picture_as_pdf, color: Colors.red),
                SizedBox(width: 10),
                Text("Export to PDF"),
              ],
            ),
          ),
        ],
      ),

      // ---------------------------------------------------------
      // DOZENS SWITCH
      // ---------------------------------------------------------
      Row(
        children: [
          Text(t.pieces),
          Switch(
            value: showDozens,
            onChanged: (v) {
              showDozens = v;
              _applyFilters();
            },
          ),
          Text(t.dozens),
          const SizedBox(width: 10),
        ],
      ),

      // ---------------------------------------------------------
      // POPUP MENU (Trash + Categories)
      // ---------------------------------------------------------
      PopupMenuButton<String>(
        onSelected: (value) async {
          if (value == 'trash') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TrashBinPage()),
            ).then((_) => _load());
          }

          if (value == 'category') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CategoryManagementPage()),
            ).then((_) => _load());
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'trash',
            child: Row(
              children: [
                const Icon(Icons.delete_sweep, color: Colors.red),
                const SizedBox(width: 10),
                Text(t.trashBin),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'category',
            child: Row(
              children: [
                const Icon(Icons.category),
                const SizedBox(width: 10),
                Text(t.categories),
              ],
            ),
          ),
        ],
      ),

      // ---------------------------------------------------------
      // DELETE SELECTED
      // ---------------------------------------------------------
      if (_selectedIds.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: Text(t.delete),
                content: Text(t.deleteSelectedProducts),
                actions: [
                  TextButton(
                    child: Text(t.cancel),
                    onPressed: () => Navigator.pop(context, false),
                  ),
                  ElevatedButton(
                    child: Text(t.delete),
                    onPressed: () => Navigator.pop(context, true),
                  ),
                ],
              ),
            );

            if (confirm != true) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(t.deletionCancelled)),
              );
              return;
            }

            if (!await requireManagerPin(context)) return;

            final ids = List<int?>.from(_selectedIds);
            for (final id in ids) {
              if (id != null) {
                await _controller.softDeleteProduct(id);
              }
            }

            _selectedIds.clear();
            _load();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(t.productsDeleted)),
            );
          },
        ),

      IconButton(
        icon: const Icon(Icons.tune),
        onPressed: () {
          _scaffoldKey.currentState?.openEndDrawer();
        },
      ),
    ],
  ),

  floatingActionButton: FloatingActionButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AddProductPage()),
      ).then((value) {
        if (value == true) _load();
      });
    },
    child: const Icon(Icons.add),
  ),

  body: loading
      ? const Center(child: CircularProgressIndicator())
      : Stack(
          children: [
            Column(
              children: [
                // ---------------------------------------------------------
                // SEARCH BAR
                // ---------------------------------------------------------
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: TextField(
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search),
                              hintText: t.searchNameBarcode,
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
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(Icons.qr_code_scanner,
                            size: 28, color: Colors.blue),
                        onPressed: () {
                          showScanner = !showScanner;
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),

                // ---------------------------------------------------------
                // CATEGORY FILTER + LOW STOCK
                // ---------------------------------------------------------
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _openCategoryFilterDialog(),
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.category),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    selectedCategories.contains("All")
                                        ? t.allCategories
                                        : selectedCategories.join(", "),
                                    softWrap: true,
                                    overflow: TextOverflow.visible,
                                    maxLines: 2,
                                  ),
                                ),
                                const Icon(Icons.arrow_drop_down),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      FilterChip(
                        label: Text(t.lowStockOnly),
                        selected: showLowStockOnly,
                        onSelected: (v) {
                          showLowStockOnly = v;
                          _applyFilters();
                        },
                      ),
                    ],
                  ),
                ),

                if (showScanner)
                  SizedBox(height: 160, child: const EmbeddedScannerBox()),

                const SizedBox(height: 10),

                // ---------------------------------------------------------
                // DATA TABLE
                // ---------------------------------------------------------
                Expanded(
                  child: DataTable2(
                    columnSpacing: 12,
                    horizontalMargin: 12,
                    headingRowHeight: 45,
                    dataRowHeight: 60,
                    sortColumnIndex: _sortColumnIndex,
                    sortAscending: _sortAscending,
                    minWidth: 1200,

                    columns: [
                      DataColumn2(label: const Text(""), size: ColumnSize.S),

                      if (_visible["product"] == true)
                        DataColumn2(
                          label: Text(t.product),
                          size: ColumnSize.L,
                          onSort: (i, asc) =>
                              _sort((p) => p.name.toLowerCase(), i, asc),
                        ),

                      if (_visible["barcode"] == true)
                        DataColumn2(
                          label: Text(t.barcode),
                          size: ColumnSize.L,
                          onSort: (i, asc) =>
                              _sort((p) => p.barcode.toLowerCase(), i, asc),
                        ),

                      if (_visible["category"] == true)
                        DataColumn2(
                          label: Text(t.category),
                          size: ColumnSize.M,
                          onSort: (i, asc) =>
                              _sort((p) => (p.category ?? "").toLowerCase(), i, asc),
                        ),

                      if (_visible["stock"] == true)
                        DataColumn2(
                          label: Text(t.stock),
                          size: ColumnSize.S,
                          onSort: (i, asc) => _sort((p) => _toPieces(p), i, asc),
                        ),

                      if (_visible["purchase"] == true)
                        DataColumn2(
                          label: Text(t.purchase),
                          size: ColumnSize.M,
                          onSort: (i, asc) =>
                              _sort((p) => p.purchasePrice, i, asc),
                        ),

                      if (_visible["retail"] == true)
                        DataColumn2(
                          label: Text(t.retail),
                          size: ColumnSize.S,
                          onSort: (i, asc) =>
                              _sort((p) => p.sellPrice1, i, asc),
                        ),

                      if (_visible["wholesale"] == true)
                        DataColumn2(
                          label: Text(t.wholesale),
                          size: ColumnSize.M,
                          onSort: (i, asc) =>
                              _sort((p) => p.sellPrice2, i, asc),
                        ),

                      if (_visible["special"] == true)
                        DataColumn2(
                          label: Text(t.special),
                          size: ColumnSize.S,
                          onSort: (i, asc) =>
                              _sort((p) => p.sellPrice3, i, asc),
                        ),
                    ],

                    rows: _filtered.map((p) {
                      final isSelected = _selectedIds.contains(p.id);
                      final isLowStock = _toPieces(p) <= _lowStockThreshold;

                      final category = p.category != null
                          ? _categoryByName[p.category!]
                          : null;

                      String icon = category?.icon ?? "bar.png";
                      if (!icon.contains(".")) icon = "$icon.png";

                      return DataRow(
                        selected: isSelected,
                        color: MaterialStateProperty.resolveWith((states) {
                          if (isSelected) return Colors.blue.withOpacity(0.15);
                          if (isLowStock) return Colors.red.withOpacity(0.18);
                          return null;
                        }),
                        cells: [
                          DataCell(
                            Checkbox(
                              value: isSelected,
                              onChanged: (v) {
                                if (v == true) {
                                  _selectedIds.add(p.id);
                                } else {
                                  _selectedIds.remove(p.id);
                                }
                                setState(() {});
                              },
                            ),
                          ),

                          if (_visible["product"] == true)
                            DataCell(
                              InkWell(
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          EditProductPage(product: p),
                                    ),
                                  );
                                  if (result == true) _load();
                                },
                                child: Text(
                                  p.name,
                                  maxLines: 2,
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ),

                          if (_visible["barcode"] == true)
                            DataCell(
                              Text(
                                p.barcode,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                          if (_visible["category"] == true)
                            DataCell(
                              Row(
                                children: [
                                  Image.asset(
                                    "assets/icons/$icon",
                                    width: 24,
                                    height: 24,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(p.category ?? "—"),
                                ],
                              ),
                            ),

                          if (_visible["stock"] == true)
                            DataCell(
                              Text(
                                _displayStock(p),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                          if (_visible["purchase"] == true)
                            DataCell(
                              Text(p.purchasePrice.toStringAsFixed(2)),
                            ),

                          if (_visible["retail"] == true)
                            DataCell(
                              Text(p.sellPrice1.toStringAsFixed(2)),
                            ),

                          if (_visible["wholesale"] == true)
                            DataCell(
                              Text(p.sellPrice2.toStringAsFixed(2)),
                            ),

                          if (_visible["special"] == true)
                            DataCell(
                              Text(p.sellPrice3.toStringAsFixed(2)),
                            ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),

            // ---------------------------------------------------------
            // FIXED BOTTOM INVENTORY CARD
            // ---------------------------------------------------------
            Positioned(
              left: 0,
              right: 0,
              bottom: 10,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildInventoryItem(
                        label: t.totalInventoryCost,
                        value: _totalInventoryCost.toStringAsFixed(2),
                      ),
                      const SizedBox(width: 25),
                      _buildInventoryItem(
                        label: t.totalRetailValue,
                        value: _totalRetailValue.toStringAsFixed(2),
                      ),
                      const SizedBox(width: 25),
                      _buildInventoryItem(
                        label: t.totalWholesaleValue,
                        value: _totalWholesaleValue.toStringAsFixed(2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
);

  }
}
