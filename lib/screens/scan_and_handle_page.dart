import 'package:flutter/material.dart';
import '../controllers/product_controller.dart';
import '../models/product.dart';

import 'add_product_page.dart';
import 'edit_product_page.dart';

// NEW — use the new full-screen scanner
import '../widgets/full_screen_scanner.dart';
import '../generated/app_localizations.dart';

class ScanAndHandlePage extends StatefulWidget {
  const ScanAndHandlePage({super.key});

  @override
  State<ScanAndHandlePage> createState() => _ScanAndHandlePageState();
}

class _ScanAndHandlePageState extends State<ScanAndHandlePage> {
  final ProductController productController = ProductController();

  Future<void> _handleBarcode(String code) async {
    final t = AppLocalizations.of(context)!;

    final Product? product = await productController.getByBarcode(code);

    if (!mounted) return;

    if (product == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AddProductPage(initialBarcode: code),
        ),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => EditProductPage(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FullScreenScanner(
      onScan: (barcode) async {
        await _handleBarcode(barcode);
      },
    );
  }
}
