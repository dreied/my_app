import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../controllers/product_controller.dart';
import '../database/category_dao.dart';
import '../models/category.dart';
import '../models/product.dart';
import 'edit_product_page.dart';

class AddProductPage extends StatefulWidget {
  final String? initialBarcode;

  const AddProductPage({super.key, this.initialBarcode});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final ProductController _controller = ProductController();
  final CategoryDao _categoryDao = CategoryDao();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _purchaseController = TextEditingController();
  final TextEditingController _sell1Controller = TextEditingController();
  final TextEditingController _sell2Controller = TextEditingController();
  final TextEditingController _sell3Controller = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  // NEW — unit controller
  final TextEditingController _unitController =
      TextEditingController(text: "pieces");

  List<Category> _categories = [];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();

    if (widget.initialBarcode != null && widget.initialBarcode!.isNotEmpty) {
      _barcodeController.text = widget.initialBarcode!;
    }
  }

  // ---------------------------------------------------------
  // LOAD CATEGORIES
  // ---------------------------------------------------------
  Future<void> _loadCategories() async {
    final list = await _categoryDao.getAll();
    setState(() => _categories = list);
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
  // DUPLICATE PRODUCT DIALOG
  // ---------------------------------------------------------
  void _showDuplicateDialog(Product existing, int addedStock) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Product Already Exists"),
          content: Text(
            "This product already exists:\n\n"
            "Name: ${existing.name}\n"
            "Barcode: ${existing.barcode}\n\n"
            "What do you want to do?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditProductPage(product: existing),
                  ),
                );
              },
              child: const Text("Modify Prices"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);

                final updated = Product(
                  id: existing.id,
                  name: existing.name,
                  purchasePrice: existing.purchasePrice,
                  sellPrice1: existing.sellPrice1,
                  sellPrice2: existing.sellPrice2,
                  sellPrice3: existing.sellPrice3,
                  stock: existing.stock + addedStock,
                  unit: existing.unit, // NEW
                  barcode: existing.barcode,
                  category: existing.category,
                );

                await _controller.updateProduct(updated);
                Navigator.pop(context, true);
              },
              child: const Text("Add to Inventory"),
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------
  // SAVE PRODUCT
  // ---------------------------------------------------------
  Future<void> _saveProduct() async {
    final name = _nameController.text.trim();
    final purchase = double.tryParse(_purchaseController.text.trim()) ?? 0;
    final sell1 = double.tryParse(_sell1Controller.text.trim()) ?? 0;
    final sell2 = double.tryParse(_sell2Controller.text.trim()) ?? 0;
    final sell3 = double.tryParse(_sell3Controller.text.trim()) ?? 0;
    final stock = int.tryParse(_stockController.text.trim()) ?? 0;
    String barcode = _barcodeController.text.trim();
    final category = _categoryController.text.trim();
    final unit = _unitController.text.trim(); // NEW

    if (barcode.isEmpty) {
      barcode = await _controller.generateUniqueBarcode();
    }

    if (name.isEmpty ||
        purchase <= 0 ||
        sell1 <= 0 ||
        sell2 <= 0 ||
        sell3 <= 0 ||
        stock < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter valid product details")),
      );
      return;
    }

    if (sell1 < purchase || sell2 < purchase || sell3 < purchase) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("لا يمكن أن يكون سعر البيع أقل من سعر الشراء")),
      );
      return;
    }

    // DUPLICATE CHECK
    final existing = await _controller.findByNameOrBarcode(name, barcode);

    if (existing != null) {
      if (existing.barcode == barcode && barcode.isNotEmpty) {
        _showDuplicateDialog(existing, stock);
        return;
      }

      if (existing.name == name && existing.category == category) {
        _showDuplicateDialog(existing, stock);
        return;
      }
    }

    setState(() => _saving = true);

    await _controller.addProduct(
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

    setState(() => _saving = false);
    Navigator.pop(context, true);
  }

  // ---------------------------------------------------------
  // UI
  // ---------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Product")),
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
                    child: Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 14,
                          color: c.color != null
                              ? Color(int.parse(c.color!.replaceFirst('#', '0xff')))
                              : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(c.name),
                      ],
                    ),
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

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _saveProduct,
                child: _saving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save Product"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
