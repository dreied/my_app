import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanController with ChangeNotifier {
  final MobileScannerController cameraController = MobileScannerController();

  bool _isProcessing = false;
  String? lastBarcode;
  Timer? _debounceTimer;

  // Callback when a barcode is detected
  Function(String code)? onBarcodeScanned;

  ScanController({this.onBarcodeScanned});

  void startScanner() {
    cameraController.start();
  }

  void stopScanner() {
    cameraController.stop();
  }

  void disposeController() {
    cameraController.dispose();
    _debounceTimer?.cancel();
  }

  // Called by MobileScanner when a barcode is detected
  void handleDetection(BarcodeCapture capture) {
  if (_isProcessing) return;

  // Only accept EXACTLY one barcode
  if (capture.barcodes.length != 1) return;

  final barcode = capture.barcodes.first.rawValue;
  if (barcode == null) return;

  if (barcode == lastBarcode) return;

  _isProcessing = true;
  lastBarcode = barcode;

  _debounceTimer?.cancel();
  _debounceTimer = Timer(const Duration(seconds: 1), () {
    _isProcessing = false;
  });

  if (onBarcodeScanned != null) {
    onBarcodeScanned!(barcode);
  }
}

}
