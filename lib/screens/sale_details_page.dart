import 'package:flutter/material.dart';
import '../database/app_database.dart';
import 'receipt_page.dart';


class SaleDetailsPage extends StatefulWidget {
  final int saleId;

  const SaleDetailsPage({super.key, required this.saleId});

  @override
  State<SaleDetailsPage> createState() => _SaleDetailsPageState();
}

class _SaleDetailsPageState extends State<SaleDetailsPage> {
  Map<String, dynamic>? _sale;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    final db = await AppDatabase.instance.database;

    // Load sale info
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
      _sale = saleResult.isNotEmpty ? saleResult.first : null;
      _items = itemResult;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_sale == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Sale Details")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Sale #${_sale!['id']}")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Date: ${_sale!['datetime']}",
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              "Total: ${_sale!['total']}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, i) {
                  final item = _items[i];
                  return ListTile(
                    title: Text(item['name']),
                    subtitle: Text(
                      "Qty: ${item['qty']} | Price: ${item['price']} | Total: ${item['qty'] * item['price']}",
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReceiptPage(saleId: widget.saleId),
        ),
      );
    },
    child: const Text("View Receipt"),
  ),
),

          ],
        ),
      ),
    );
  }
}
