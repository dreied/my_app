import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../controllers/product_controller.dart';
import '../database/category_dao.dart';
import '../models/category.dart';
import '../models/product.dart';
import 'stock_adjust_page.dart';

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

  // NEW — unit controller
  late TextEditingController _unitController;

  List<Category> _categories = [];
  bool _saving = false;
  bool _loadingCategories = true;

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

    // NEW — load existing unit
    _unitController = TextEditingController(text: p.unit);

    _loadCategories();
  }

  // ---------------------------------------------------------
  // LOAD CATEGORIES (freeze-proof)
  // ---------------------------------------------------------
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

  // ---------------------------------------------------------
  // ADD NEW CATEGORY
  // ---------------------------------------------------------
  Future<String?> _showAddCategoryDialog() async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add New Category"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: "Category Name",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // BARCODE SCAN
  // ---------------------------------------------------------
  Future<void> _scanBarcode() async {
    final controller = MobileScannerController();
    String? scannedCode;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text("Scan Barcode")),
          body: MobileScanner(
            controller: controller,
            onDetect: (capture) {
              final barcode = capture.barcodes.first;
              scannedCode = barcode.rawValue;
              controller.stop();
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );

    if (scannedCode != null && scannedCode!.isNotEmpty) {
      setState(() => _barcodeController.text = scannedCode!);
    }
  }

  // ---------------------------------------------------------
  // SAVE PRODUCT
  // ---------------------------------------------------------
  Future<void> _save() async {
    final name = _nameController.text.trim();
    final purchase = double.tryParse(_purchaseController.text.trim()) ?? 0;
    final sell1 = double.tryParse(_sell1Controller.text.trim()) ?? 0;
    final sell2 = double.tryParse(_sell2Controller.text.trim()) ?? 0;
    final sell3 = double.tryParse(_sell3Controller.text.trim()) ?? 0;
    final stock = int.tryParse(_stockController.text.trim()) ?? 0;
    final barcode = _barcodeController.text.trim();
    final category = _categoryController.text.trim();
    final unit = _unitController.text.trim(); // NEW

    if (sell1 < purchase || sell2 < purchase || sell3 < purchase) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("لا يمكن أن يكون سعر البيع أقل من سعر الشراء")),
      );
      return;
    }

    if (name.isEmpty ||
        purchase <= 0 ||
        sell1 <= 0 ||
        sell2 <= 0 ||
        sell3 <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid product details")),
      );
      return;
    }

    setState(() => _saving = true);

    final updated = Product(
      id: widget.product.id,
      name: name,
      purchasePrice: purchase,
      sellPrice1: sell1,
      sellPrice2: sell2,
      sellPrice3: sell3,
      stock: stock,
      unit: unit, // NEW
      barcode: barcode,
      category: category.isEmpty ? null : category,
    );

    await _controller.updateProduct(updated);

    setState(() => _saving = false);
    Navigator.pop(context, true);
  }

  // ---------------------------------------------------------
  // DELETE PRODUCT
  // ---------------------------------------------------------
  Future<void> _delete() async {
    await _controller.deleteProduct(widget.product.id!);
    Navigator.pop(context, true);
  }

  // ---------------------------------------------------------
  // UI
  // ---------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    if (_loadingCategories) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Product")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Product Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: _categoryController.text.isEmpty
                  ? null
                  : _categoryController.text,
              decoration: const InputDecoration(
                labelText: "Category",
                border: OutlineInputBorder(),
              ),
              items: [
                ..._categories.map(
                  (c) => DropdownMenuItem(
                    value: c.name,
                    child: Text(c.name),
                  ),
                ),
                const DropdownMenuItem(
                  value: "__add_new__",
                  child: Row(
                    children: [
                      Icon(Icons.add, color: Colors.blue),
                      SizedBox(width: 8),
                      Text("Add New Category"),
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
              decoration: const InputDecoration(
                labelText: "Purchase Price",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _sell1Controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Sell Price 1 (مفرق)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _sell2Controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Sell Price 2 (جملة)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _sell3Controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Sell Price 3 (مخصص)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _stockController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Stock",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // NEW — UNIT DROPDOWN
            DropdownButtonFormField<String>(
              value: _unitController.text,
              decoration: const InputDecoration(
                labelText: "Unit",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: "pieces",
                  child: Text("Pieces"),
                ),
                DropdownMenuItem(
                  value: "half",
                  child: Text("Half‑Dozen (6)"),
                ),
                DropdownMenuItem(
                  value: "dozen",
                  child: Text("Dozen (12)"),
                ),
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
                    decoration: const InputDecoration(
                      labelText: "Barcode",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _scanBarcode,
                  child: const Icon(Icons.qr_code_scanner),
                ),
              ],
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: const Text("Save Changes"),
            ),
            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: _delete,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Delete Product"),
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
              child: const Text("Adjust Stock"),
            ),
          ],
        ),
      ),
    );
  }
}
