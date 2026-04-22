import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../models/product.dart';
import '../generated/app_localizations.dart';
import '../utils/pin_guard.dart';

class StockAdjustPage extends StatefulWidget {
  final Product product;

  const StockAdjustPage({super.key, required this.product});

  @override
  State<StockAdjustPage> createState() => _StockAdjustPageState();
}

class _StockAdjustPageState extends State<StockAdjustPage> {
  final TextEditingController _qtyController = TextEditingController();
  bool _saving = false;

  /// 🔥 Convert entered quantity based on product.unit
  int _convertToPieces(int qty) {
    if (widget.product.unit == "dozen") {
      return qty * 12;
    } else if (widget.product.unit == "half") {
      return qty * 6;
    }
    return qty; // pieces
  }

  Future<void> _applyChange(int change) async {
    if (change == 0) return;

    // Require manager PIN
    final pinOk = await requireManagerPin(context);
    if (!pinOk) return;

    setState(() => _saving = true);

    final db = await AppDatabase.instance.database;

    // 🔥 Convert change to pieces before applying
    final convertedChange = _convertToPieces(change);

    final newStock = widget.product.stock + convertedChange;

    await db.update(
      'products',
      {'stock': newStock},
      where: 'id = ?',
      whereArgs: [widget.product.id],
    );

    // Log inventory change
    await db.insert('inventory_log', {
      'product_id': widget.product.id,
      'change_qty': convertedChange, // 🔥 store actual piece change
      'datetime': DateTime.now().toIso8601String(),
    });

    setState(() => _saving = false);

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final product = widget.product;

    return Scaffold(
      appBar: AppBar(title: Text("${t.adjustStock}: ${product.name}")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "${t.currentStock}: ${product.stock}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _qtyController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: t.quantityAddRemove,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving
                    ? null
                    : () {
                        final qty = int.tryParse(_qtyController.text.trim()) ?? 0;
                        _applyChange(qty);
                      },
                child: _saving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(t.applyChange),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
