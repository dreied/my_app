import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanScreen extends StatefulWidget {
  final Function(String barcode) onScan;

  const ScanScreen({super.key, required this.onScan});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool scanned = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan barcode")),
      body: MobileScanner(
        controller: controller,
        fit: BoxFit.cover,
        onDetect: (capture) {
          if (scanned) return; // prevent double scans
          scanned = true;

          final barcode = capture.barcodes.first.rawValue;
          if (barcode != null && barcode.isNotEmpty) {
            controller.stop();
            widget.onScan(barcode);
          } else {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
