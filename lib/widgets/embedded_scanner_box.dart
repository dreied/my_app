import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:audioplayers/audioplayers.dart';
import '../controllers/scan_controller.dart';
import '../controllers/product_controller.dart';
import '../models/product.dart';
import '../screens/add_product_page.dart';
import '../screens/edit_product_page.dart';
import '../utils/camera_permission.dart';

class EmbeddedScannerBox extends StatefulWidget {
  final Function(String barcode)? onScanned;

  const EmbeddedScannerBox({super.key, this.onScanned});

  @override
  State<EmbeddedScannerBox> createState() => _EmbeddedScannerBoxState();
}

class _EmbeddedScannerBoxState extends State<EmbeddedScannerBox>
    with SingleTickerProviderStateMixin {
  late ScanController scanController;
  final ProductController productController = ProductController();

  bool cameraReady = false;
  bool _showFlash = false;     // Green flash overlay
  bool _cooldown = false;      // Cooldown flag

  late AnimationController _lineController;
  late Animation<double> _lineAnimation;

  late AnimationController _frameController;
  late Animation<double> _frameGlow;

  final AudioPlayer _player = AudioPlayer(); // 🔊 Beep player

  @override
  void initState() {
    super.initState();

    // Red scanning line animation
    _lineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _lineAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _lineController, curve: Curves.easeInOut),
    );

    // Glowing frame animation
    _frameController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _frameGlow = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _frameController, curve: Curves.easeInOut),
    );

    scanController = ScanController(
      onBarcodeScanned: (code) async {
        if (_cooldown) return; // Prevent double scans
        _cooldown = true;
        Future.delayed(const Duration(seconds: 1), () => _cooldown = false);

        // Green flash overlay
        setState(() => _showFlash = true);
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) setState(() => _showFlash = false);
        });

       

        // 🔊 Beep
        await _player.play(AssetSource('sounds/beep.mp3'));

        await _handleBarcode(code);
      },
    );

    CameraPermission.request().then((granted) {
      if (!mounted) return;
      if (granted) {
        setState(() => cameraReady = true);
        scanController.startScanner();
      }
    });
  }

  @override
  void dispose() {
    scanController.disposeController();
    _lineController.dispose();
    _frameController.dispose();
    super.dispose();
  }

  Future<void> _handleBarcode(String code) async {
    if (widget.onScanned != null) {
      widget.onScanned!(code);
      scanController.stopScanner();
      return;
    }

    final Product? product = await productController.getByBarcode(code);

    if (!mounted) return;

    scanController.stopScanner();

    if (product == null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AddProductPage(initialBarcode: code),
        ),
      ).then((_) {
        if (mounted) scanController.startScanner();
      });
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProductPage(product: product),
      ),
    ).then((_) {
      if (mounted) scanController.startScanner();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!cameraReady) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        MobileScanner(
          controller: scanController.cameraController,
          onDetect: scanController.handleDetection,
        ),

        // 🔦 Flash toggle with dynamic icon
        Positioned(
          top: 10,
          right: 10,
          child: ValueListenableBuilder(
            valueListenable: scanController.cameraController.torchState,
            builder: (context, state, child) {
              final isOn = state == TorchState.on;

              return IconButton(
                icon: Icon(
                  isOn ? Icons.flash_on : Icons.flash_off,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: () {
                  scanController.cameraController.toggleTorch();
                },
              );
            },
          ),
        ),

        // Glowing frame
        Center(
          child: AnimatedBuilder(
            animation: _frameGlow,
            builder: (_, __) {
              return Container(
                width: 260,
                height: 160,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.greenAccent.withOpacity(_frameGlow.value),
                    width: 3,
                  ),
                ),
              );
            },
          ),
        ),

        // Red scanning line
        Center(
          child: SizedBox(
            width: 260,
            height: 160,
            child: Stack(
              children: [
                AnimatedBuilder(
                  animation: _lineAnimation,
                  builder: (_, __) {
                    return Positioned(
                      top: 160 * _lineAnimation.value,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 3,
                        color: Colors.redAccent,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        // Green flash overlay
        if (_showFlash)
          Positioned.fill(
            child: Container(
              color: Colors.green.withOpacity(0.3),
            ),
          ),
      ],
    );
  }
}
