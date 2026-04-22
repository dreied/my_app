import 'package:flutter/material.dart';
import '../controllers/product_controller.dart';
import '../database/category_dao.dart';
import '../models/category.dart';
import '../models/product.dart';
import 'edit_product_page.dart';
import '../widgets/embedded_scanner_box.dart';
import '../generated/app_localizations.dart';
import '../utils/error_handler.dart';
import '../services/activation_service.dart';


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
  final TextEditingController _unitController =
      TextEditingController(text: "pieces");

  List<Category> _categories = [];
  bool _saving = false;
  bool showScanner = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();

    if (widget.initialBarcode != null && widget.initialBarcode!.isNotEmpty) {
      _barcodeController.text = widget.initialBarcode!;
    }
  }

  Future<void> _loadCategories() async {
    final list = await _categoryDao.getAll();
    setState(() => _categories = list);
  }

  Future<String?> _showAddCategoryDialog() async {
    final t = AppLocalizations.of(context)!;
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.addNewCategoryDialog),
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

  void _showDuplicateDialog(Product existing, int addedStock) {
    final t = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(t.productExists),
          content: Text(
            "${t.productExistsDetails}\n\n"
            "${t.productName}: ${existing.name}\n"
            "${t.barcode}: ${existing.barcode}\n\n"
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
              child: Text(t.modifyPrices),
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
                  unit: existing.unit,
                  barcode: existing.barcode,
                  category: existing.category,
                );

                await _controller.updateProduct(updated);
                Navigator.pop(context, true);
              },
              child: Text(t.addToInventory),
            ),
          ],
        );
      },
    );
  }

Future<void> _saveProduct() async {
  final t = AppLocalizations.of(context)!;

  // ⭐ LIMIT: Only 5 products allowed if NOT activated
  final activated = await ActivationService.isActivated();
  final count = await ActivationService.getProductCount();

  if (!activated && count >= 5) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.limitProducts))

    );
    return;
  }

  final name = _nameController.text.trim();
  final purchase = double.tryParse(_purchaseController.text.trim()) ?? 0;
  final sell1 = double.tryParse(_sell1Controller.text.trim()) ?? 0;
  final sell2 = double.tryParse(_sell2Controller.text.trim()) ?? 0;
  final sell3 = double.tryParse(_sell3Controller.text.trim()) ?? 0;
  final stock = int.tryParse(_stockController.text.trim()) ?? 0;
  String barcode = _barcodeController.text.trim();
  final category = _categoryController.text.trim();
  final unit = _unitController.text.trim();

  if (barcode.isEmpty) {
    barcode = await _controller.generateUniqueBarcode();
  }

  if (name.isEmpty ||
      purchase <= 0 ||
      sell1 <= 0 ||
      sell2 <= 0 ||
      stock < 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.invalidProductDetails)),
    );
    return;
  }

  if (sell1 < purchase || sell2 < purchase) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(t.sellBelowPurchase)),
  );
  return;
}
// ⭐ Sell Price 3 can be empty. Only validate if user typed something.
if (_sell3Controller.text.trim().isNotEmpty) {
  final sell3 = double.tryParse(_sell3Controller.text.trim()) ?? 0;

  if (sell3 < purchase) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.sellBelowPurchase)),
    );
    return;
  }
}



  final existing = await _controller.findByNameOrBarcode(name, barcode);
  if (existing != null) {
    _showDuplicateDialog(existing, stock);
    return;
  }

  int finalStock = stock;
  if (unit == "dozen") finalStock = stock * 12;
  if (unit == "half") finalStock = stock * 6;

  setState(() => _saving = true);

  try {
    await _controller.addProduct(
      name: name,
      purchasePrice: purchase,
      sellPrice1: sell1,
      sellPrice2: sell2,
      sellPrice3: sell3,
      stock: finalStock,
      unit: unit,
      barcode: barcode,
      category: category.isEmpty ? null : category,
    );

    // ⭐ INCREMENT PRODUCT COUNTER
    await ActivationService.incrementProduct();

    setState(() => _saving = false);
    Navigator.pop(context, true);
  } catch (e) {
    setState(() => _saving = false);
    showActivationError(context, e);
  }
}




  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(t.addProduct)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            if (showScanner)
  SizedBox(
    height: 160,
    child: EmbeddedScannerBox(
      onScanned: (code) async {
        setState(() {
          showScanner = false;
          _barcodeController.text = code; // ⭐ fill current form
        });

        final existing = await _controller.getByBarcode(code);

        if (existing != null) {
          final t = AppLocalizations.of(context)!;
          final confirm = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: Text(t.barcodeExists),
              content: Text("${t.productFound}: ${existing.name}\n${t.modifyQuestion}"),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: Text(t.no)),
                ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text(t.yes)),
              ],
            ),
          );

          if (confirm == true) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => EditProductPage(product: existing)),
            );
          }
        }
      },
    ),
  ),

const SizedBox(height: 12),


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
                DropdownMenuItem(
                  value: "pieces",
                  child: Text(t.pieces),
                ),
                DropdownMenuItem(
                  value: "half",
                  child: Text(t.halfDozen),
                ),
                DropdownMenuItem(
                  value: "dozen",
                  child: Text(t.dozen),
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

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _saveProduct,
                child: _saving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(t.saveProduct),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
