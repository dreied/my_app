import 'package:flutter/material.dart';
import '../controllers/product_controller.dart';
import '../models/product.dart';
import '../scan_screen.dart';

class ScanForSalePage extends StatelessWidget {
  final Function(Product) onProductFound;

  ScanForSalePage({super.key, required this.onProductFound});

  final ProductController controller = ProductController();

  @override
  Widget build(BuildContext context) {
    return ScanScreen(
      onScan: (barcode) async {
        Product? p = await controller.getByBarcode(barcode);

        if (p != null) {
          onProductFound(p);
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Product not found")),
          );
        }
      },
    );
  }
}
