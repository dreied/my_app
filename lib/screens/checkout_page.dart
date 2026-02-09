import 'package:flutter/material.dart';
import '../controllers/cart_controller.dart';
import '../database/app_database.dart';
import '../models/cart_item.dart';

class CheckoutPage extends StatefulWidget {
  final CartController cart;

  const CheckoutPage({super.key, required this.cart});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool _saving = false;

  Future<void> _completeSale() async {
    final cart = widget.cart;
    if (cart.items.isEmpty) return;

    setState(() => _saving = true);

    final db = await AppDatabase.instance.database;

    // Start transaction
    await db.transaction((txn) async {
      // Insert sale
      final saleId = await txn.insert('sales', {
        'datetime': DateTime.now().toIso8601String(),
        'total': cart.total,
      });

      // Insert sale items + reduce stock
      for (CartItem item in cart.items) {
        await txn.insert('sale_items', {
          'sale_id': saleId,
          'product_id': item.product.id,
          'qty': item.qty,
          'price': item.price,
        });

        // Reduce stock
        final newStock = item.product.stock - item.qty;
        await txn.update(
          'products',
          {'stock': newStock},
          where: 'id = ?',
          whereArgs: [item.product.id],
        );

        // Add inventory log
        await txn.insert('inventory_log', {
          'product_id': item.product.id,
          'change_qty': -item.qty,
          'datetime': DateTime.now().toIso8601String(),
        });
      }
    });

    // Clear cart
    cart.items.clear();

    setState(() => _saving = false);

    Navigator.pop(context, true); // return success
  }

  @override
  Widget build(BuildContext context) {
    final cart = widget.cart;

    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: cart.items.map((item) {
                  return ListTile(
                    title: Text(item.product.name),
                    subtitle: Text(
                      "Qty: ${item.qty} | Price: ${item.price} | Total: ${item.lineTotal}",
                    ),
                  );
                }).toList(),
              ),
            ),

            Text(
              "Total: ${cart.total}",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _completeSale,
                child: _saving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Complete Sale"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
