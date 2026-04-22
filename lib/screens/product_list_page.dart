import 'package:flutter/material.dart';
import '../controllers/product_controller.dart';
import '../controllers/cart_controller.dart';
import '../models/product.dart';
import 'add_product_page.dart';
import 'edit_product_page.dart';
import 'cart_page.dart';
import 'sales_history_page.dart';
import 'inventory_log_page.dart';
import 'dashboard_page.dart';
import 'low_stock_page.dart';
import 'monthly_report_page.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'stock_adjust_page.dart';
import '../generated/app_localizations.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final ProductController _controller = ProductController();
  final CartController _cart = CartController.instance;

  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await _controller.loadProducts();
    setState(() => _products = items);
  }

  Future<void> _openAdd() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddProductPage()),
    );
    if (result == true) _load();
  }

  Future<void> _openEdit(Product product) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditProductPage(product: product)),
    );
    if (result == true) _load();
  }

  void _openCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CartPage(cart: CartController.instance),
      ),
    ).then((_) => setState(() {}));
  }

  void _openSalesHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SalesHistoryPage()),
    );
  }

  Future<String?> _scanBarcode() async {
    final t = AppLocalizations.of(context)!;
    final tempScanner = MobileScannerController();
    String? scannedCode;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(t.scanBarcode)),
          body: MobileScanner(
            controller: tempScanner,
            fit: BoxFit.cover,
            onDetect: (capture) {
              final barcode = capture.barcodes.first;
              scannedCode = barcode.rawValue;
              tempScanner.stop();
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );

    tempScanner.dispose();
    return scannedCode;
  }

  Future<void> _scanAndAdjustStock() async {
    final t = AppLocalizations.of(context)!;

    try {
      final code = await _scanBarcode();
      if (code == null) return;

      final product = await _controller.getByBarcode(code);

      if (product == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${t.noProductFound} $code")),
        );
        return;
      }

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StockAdjustPage(product: product),
        ),
      );

      if (result == true) _load();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${t.scannerError}: $e")),
      );
    }
  }

  Future<void> _scanAndAddNewProduct() async {
    final t = AppLocalizations.of(context)!;

    try {
      final code = await _scanBarcode();
      if (code == null) return;

      final product = await _controller.getByBarcode(code);

      if (product != null) {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditProductPage(product: product),
          ),
        );
        if (result == true) _load();
        return;
      }

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AddProductPage(initialBarcode: code),
        ),
      );

      if (result == true) _load();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${t.scannerError}: $e")),
      );
    }
  }

  Future<void> _scanAndEditProduct() async {
    final t = AppLocalizations.of(context)!;

    try {
      final code = await _scanBarcode();
      if (code == null) return;

      final product = await _controller.getByBarcode(code);

      if (product == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${t.noProductFound} $code")),
        );
        return;
      }

      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => EditProductPage(product: product)),
      );

      if (result == true) _load();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${t.scannerError}: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.products),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_2),
            onPressed: _scanAndAdjustStock,
          ),
          IconButton(
            icon: const Icon(Icons.qr_code),
            onPressed: _scanAndAddNewProduct,
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _scanAndEditProduct,
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: _openCart,
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _openSalesHistory,
          ),
          IconButton(
            icon: const Icon(Icons.list_alt),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InventoryLogPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.dashboard),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DashboardPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.warning_amber),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LowStockPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MonthlyReportPage()),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _products.length,
        itemBuilder: (context, i) {
          final p = _products[i];

          return ListTile(
            title: Text(p.name),
            subtitle: Text(
              "${t.purchase}: ${p.purchasePrice} | "
              "${t.sell1}: ${p.sellPrice1} | "
              "${t.sell2}: ${p.sellPrice2} | "
              "${t.stock}: ${p.stock}",
            ),
            onTap: () => _openEdit(p),
            trailing: IconButton(
              icon: const Icon(Icons.add_shopping_cart),
              onPressed: () async {
                final ok = await _cart.addToCart(p);

                if (!ok) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(t.cannotSellBelowPurchase),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                setState(() {});
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAdd,
        child: const Icon(Icons.add),
      ),
    );
  }
}
