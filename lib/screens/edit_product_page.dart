import 'package:flutter/material.dart';
import '../controllers/product_controller.dart';
import '../database/category_dao.dart';
import '../models/category.dart';
import '../models/product.dart';
import 'stock_adjust_page.dart';
import '../widgets/embedded_scanner_box.dart';
import '../generated/app_localizations.dart';
import '../utils/pin_guard.dart'; // <-- Unified PIN guard

class EditProductPage extends StatefulWidget {
  final Product product;

  const EditProductPage({super.key, required this.product});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final ProductController _controller = ProductController();
  final CategoryDao _categoryDao = CategoryDao();

  late TextEditingController _nameController;
  late TextEditingController _purchaseController;
  late TextEditingController _sell1Controller;
  late TextEditingController _sell2Controller;
  late TextEditingController _sell3Controller;
  late TextEditingController _stockController;
  late TextEditingController _barcodeController;
  late TextEditingController _categoryController;
  late TextEditingController _unitController;

  List<Category> _categories = [];
  bool _saving = false;
  bool _loadingCategories = true;

  bool showScanner = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;

    _nameController = TextEditingController(text: p.name);
    _purchaseController = TextEditingController(text: p.purchasePrice.toString());
    _sell1Controller = TextEditingController(text: p.sellPrice1.toString());
    _sell2Controller = TextEditingController(text: p.sellPrice2.toString());
    _sell3Controller = TextEditingController(text: p.sellPrice3.toString());
    _stockController = TextEditingController(text: p.stock.toString());
    _barcodeController = TextEditingController(text: p.barcode);
    _categoryController = TextEditingController(text: p.category ?? "");
    _unitController = TextEditingController(text: p.unit);

    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final list = await _categoryDao.getAll();
    final current = _categoryController.text.trim();

    if (current.isNotEmpty && !list.any((c) => c.name == current)) {
      list.add(Category(name: current));
    }

    setState(() {
      _categories = list;
      _loadingCategories = false;
    });
  }

  Future<String?> _showAddCategoryDialog() async {
    final t = AppLocalizations.of(context)!;
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.addNewCategory),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: t.categoryName,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(t.add),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final t = AppLocalizations.of(context)!;

    final name = _nameController.text.trim();
    final purchase = double.tryParse(_purchaseController.text.trim()) ?? 0;
    final sell1 = double.tryParse(_sell1Controller.text.trim()) ?? 0;
    final sell2 = double.tryParse(_sell2Controller.text.trim()) ?? 0;
    final sell3 = double.tryParse(_sell3Controller.text.trim()) ?? 0;
    final stock = int.tryParse(_stockController.text.trim()) ?? 0;
    final barcode = _barcodeController.text.trim();
    final category = _categoryController.text.trim();
    final unit = _unitController.text.trim();

   // ⭐ Sell Price 1 must not be below purchase
if (sell1 < purchase) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(t.sellPriceBelowPurchase)),
  );
  return;
}

// ⭐ Sell Price 2 must not be below purchase
if (sell2 < purchase) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(t.sellPriceBelowPurchase)),
  );
  return;
}

// ⭐ Sell Price 3 can be empty — only validate if user typed something
if (_sell3Controller.text.trim().isNotEmpty) {
  final sell3 = double.tryParse(_sell3Controller.text.trim()) ?? 0;

  if (sell3 < purchase) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.sellPriceBelowPurchase)),
    );
    return;
  }
}

// ⭐ Required fields (sell3 is NOT required)
if (name.isEmpty ||
    purchase <= 0 ||
    sell1 <= 0 ||
    sell2 <= 0) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(t.invalidProductDetails)),
  );
  return;
}



    // 🔥 Unified PIN guard
    final pinOk = await requireManagerPin(context);
    if (!pinOk) return;

    setState(() => _saving = true);

    final updated = Product(
      id: widget.product.id,
      name: name,
      purchasePrice: purchase,
      sellPrice1: sell1,
      sellPrice2: sell2,
      sellPrice3: sell3,
      stock: stock,
      unit: unit,
      barcode: barcode,
      category: category.isEmpty ? null : category,
    );

    await _controller.updateProduct(updated);

    setState(() => _saving = false);
    Navigator.pop(context, true);
  }

Future<void> _delete() async {
  final t = AppLocalizations.of(context)!;

  // Confirm move to trash
  final confirm = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(t.moveToTrash),
      content: Text(t.confirmMoveToTrash),
      actions: [
        TextButton(
          child: Text(t.cancel),
          onPressed: () => Navigator.pop(context, false),
        ),
        ElevatedButton(
          child: Text(t.moveToTrash),
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

  // PIN guard
  if (!await requireManagerPin(context)) return;

  // Soft delete
  await _controller.softDeleteProduct(widget.product.id!);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(t.movedToTrash)),
  );

  Navigator.pop(context, true);
}


  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    if (_loadingCategories) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(t.editProduct)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            if (showScanner)
              SizedBox(
                height: 160,
                child: const EmbeddedScannerBox(),
              ),

            const SizedBox(height: 12),

            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: t.productName,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: _categoryController.text.isEmpty
                  ? null
                  : _categoryController.text,
              decoration: InputDecoration(
                labelText: t.category,
                border: const OutlineInputBorder(),
              ),
              items: [
                ..._categories.map(
                  (c) => DropdownMenuItem(
                    value: c.name,
                    child: Text(c.name),
                  ),
                ),
                DropdownMenuItem(
                  value: "__add_new__",
                  child: Row(
                    children: [
                      const Icon(Icons.add, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(t.addNewCategory),
                    ],
                  ),
                ),
              ],
              onChanged: (value) async {
                if (value == "__add_new__") {
                  final newCat = await _showAddCategoryDialog();
                  if (newCat != null && newCat.isNotEmpty) {
                    final cat = Category(name: newCat);
                    await _categoryDao.insert(cat);
                    await _loadCategories();
                    setState(() => _categoryController.text = newCat);
                  }
                } else {
                  setState(() => _categoryController.text = value ?? "");
                }
              },
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _purchaseController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: t.purchasePrice,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _sell1Controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: t.sellPrice1,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _sell2Controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: t.sellPrice2,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _sell3Controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: t.sellPrice3,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _stockController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: t.stock,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: _unitController.text,
              decoration: InputDecoration(
                labelText: t.unit,
                border: const OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: "pieces", child: Text(t.unitPieces)),
                DropdownMenuItem(value: "half", child: Text(t.unitHalfDozen)),
                DropdownMenuItem(value: "dozen", child: Text(t.unitDozen)),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _unitController.text = value);
                }
              },
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _barcodeController,
                    decoration: InputDecoration(
                      labelText: t.barcode,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showScanner = !showScanner;
                    });
                  },
                  child: const Icon(Icons.qr_code_scanner),
                ),
              ],
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: Text(t.saveChanges),
            ),
            const SizedBox(height: 10),

            ElevatedButton(
  onPressed: _delete,
  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
  child: Text(t.moveToTrash),
),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StockAdjustPage(product: widget.product),
                  ),
                ).then((result) {
                  if (result == true) {
                    setState(() {});
                  }
                });
              },
              child: Text(t.adjustStock),
            ),
          ],
        ),
      ),
    );
  }
}
