import 'package:flutter/material.dart';
import 'package:my_app/controllers/product_controller.dart';
import 'package:my_app/models/product.dart';
import 'package:my_app/screens/add_product_page.dart';
import 'package:my_app/screens/edit_product_page.dart';
import '../scan_screen.dart';




class ScanAndHandlePage extends StatefulWidget {
  @override
  State<ScanAndHandlePage> createState() => _ScanAndHandlePageState();
}

class _ScanAndHandlePageState extends State<ScanAndHandlePage> {
  final ProductController _controller = ProductController();

  @override
  Widget build(BuildContext context) {
    return ScanScreen(
      onScan: (barcode) async {
        if (barcode == null || barcode.isEmpty) return;

        Product? existing = await _controller.getByBarcode(barcode);

        if (existing != null) {
          // Product exists → open edit page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => EditProductPage(product: existing),
            ),
          );
        } else {
          // Product does NOT exist → open add page with barcode pre-filled
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => AddProductPage(
                initialBarcode: barcode,
              ),
            ),
          );
        }
      },
    );
  }
}
