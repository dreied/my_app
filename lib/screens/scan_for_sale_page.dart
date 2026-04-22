import 'package:flutter/material.dart';
import '../controllers/product_controller.dart';
import '../models/product.dart';
import '../widgets/full_screen_scanner.dart';
import '../generated/app_localizations.dart';

class ScanForSalePage extends StatelessWidget {
  final Function(Product) onProductFound;

  ScanForSalePage({super.key, required this.onProductFound});

  final ProductController controller = ProductController();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return FullScreenScanner(
      onScan: (barcode) async {
        Product? p = await controller.getByBarcode(barcode);

        if (p != null) {
          onProductFound(p);
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t.productNotFound)),
          );
        }
      },
    );
  }
}
