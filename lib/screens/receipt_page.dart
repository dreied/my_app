import 'package:flutter/material.dart';
import '../database/app_database.dart';

class ReceiptPage extends StatefulWidget {
  final int saleId;

  const ReceiptPage({super.key, required this.saleId});

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  Map<String, dynamic>? sale;
  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    _loadReceipt();
  }

  Future<void> _loadReceipt() async {
    final db = await AppDatabase.instance.database;

    // Load sale
    final saleResult = await db.query(
      'sales',
      where: 'id = ?',
      whereArgs: [widget.saleId],
    );

    // Load sale items with product names
    final itemResult = await db.rawQuery('''
      SELECT sale_items.*, products.name
      FROM sale_items
      JOIN products ON sale_items.product_id = products.id
      WHERE sale_items.sale_id = ?
    ''', [widget.saleId]);

    setState(() {
      sale = saleResult.first;
      items = itemResult;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (sale == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Receipt")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Receipt")),
      body: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "STORE RECEIPT",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Divider(),

              Text("Date: ${sale!['datetime']}"),
              const SizedBox(height: 10),

              const Divider(),
              const Text(
                "Items",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Divider(),

              Expanded(
                child: ListView(
                  children: items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(item['name'])),
                          Text("x${item['qty']}"),
                          Text("${item['price']}"),
                          Text("${item['qty'] * item['price']}"),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              const Divider(),
              Text(
                "TOTAL: ${sale!['total']}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),

              const Text("Thank you for your purchase!"),
            ],
          ),
        ),
      ),
    );
  }
}
