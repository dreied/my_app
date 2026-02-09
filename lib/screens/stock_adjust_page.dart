import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../models/product.dart';

class StockAdjustPage extends StatefulWidget {
  final Product product;

  const StockAdjustPage({super.key, required this.product});

  @override
  State<StockAdjustPage> createState() => _StockAdjustPageState();
}

class _StockAdjustPageState extends State<StockAdjustPage> {
  final TextEditingController _qtyController = TextEditingController();
  bool _saving = false;

  Future<void> _applyChange(int change) async {
    if (change == 0) return;

    setState(() => _saving = true);

    final db = await AppDatabase.instance.database;

    final newStock = widget.product.stock + change;

    // Update product stock
    await db.update(
      'products',
      {'stock': newStock},
      where: 'id = ?',
      whereArgs: [widget.product.id],
    );

    // Log inventory change
    await db.insert('inventory_log', {
      'product_id': widget.product.id,
      'change_qty': change,
      'datetime': DateTime.now().toIso8601String(),
    });

    setState(() => _saving = false);

    Navigator.pop(context, true); // return success
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      appBar: AppBar(title: Text("Adjust Stock: ${product.name}")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Current Stock: ${product.stock}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Quantity (+ to add, - to remove)",
                border: OutlineInputBorder(),
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
                    : const Text("Apply Change"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
