import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../utils/date_format.dart';
import 'receipt_page.dart';
import 'return_sale_page.dart';
import '../generated/app_localizations.dart';

class SaleDetailsPage extends StatefulWidget {
  final int saleId;

  const SaleDetailsPage({super.key, required this.saleId});

  @override
  State<SaleDetailsPage> createState() => _SaleDetailsPageState();
}

class _SaleDetailsPageState extends State<SaleDetailsPage> {
  Map<String, dynamic>? _sale;
  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> _returns = [];

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    final db = await AppDatabase.instance.database;

    final saleResult = await db.query(
      'sales',
      where: 'id = ?',
      whereArgs: [widget.saleId],
    );

    final itemResult = await db.rawQuery('''
      SELECT sale_items.*, products.name
      FROM sale_items
      JOIN products ON sale_items.product_id = products.id
      WHERE sale_items.sale_id = ?
    ''', [widget.saleId]);

    final returnResult = await db.rawQuery('''
      SELECT return_history.*, products.name
      FROM return_history
      JOIN products ON return_history.product_id = products.id
      WHERE return_history.sale_id = ?
      ORDER BY datetime DESC
    ''', [widget.saleId]);

    setState(() {
      _sale = saleResult.isNotEmpty ? saleResult.first : null;
      _items = itemResult;
      _returns = returnResult;
    });
  }

  bool get hasRemaining {
    return _items.any((item) {
      final sold = item['qty'];
      final returned = item['returned_qty'] ?? 0;
      return sold - returned > 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    if (_sale == null) {
      return Scaffold(
        appBar: AppBar(title: Text(t.saleDetails)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("${t.sale} #${_sale!['id']}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              formatDateTimeUI(_sale!['datetime']),
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              "${t.total}: ${( _sale!['total'] as num ).toStringAsFixed(2)}",

              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView(
                children: [
                  Text(
                    t.items,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),

                  ..._items.map((item) {
                    final sold = item['qty'];
                    final returned = item['returned_qty'] ?? 0;
                    final remaining = sold - returned;

                    return ListTile(
                      title: Text(item['name']),
                      subtitle: Text(
                        "${t.sold}: $sold | ${t.returned}: $returned | ${t.remaining}: $remaining\n"
                        "${t.price}: ${(item['price'] as num).toStringAsFixed(2)} | "
"${t.total}: ${(sold * item['price']).toStringAsFixed(2)}",

                      ),
                    );
                  }),

                  const SizedBox(height: 20),

                  if (_returns.isNotEmpty) ...[
                    Text(
                      t.returnHistory,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    ..._returns.map((r) {
                      return ListTile(
                        leading: const Icon(Icons.undo, color: Colors.red),
                        title: Text("${r['name']} — ${t.returned} ${r['qty']}"),
                        subtitle: Text(
                          "${formatDateTimeUI(r['datetime'])} | ${t.refund}: ${(r['price'] * r['qty']).toStringAsFixed(2)}",
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            SafeArea(
              minimum: const EdgeInsets.only(bottom: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        disabledBackgroundColor: Colors.grey.shade400,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () async {
                        if (!hasRemaining) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(t.nothingToReturn)),
                          );
                          return;
                        }

                        final changed = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReturnSalePage(saleId: widget.saleId),
                          ),
                        );

                        if (changed == true) {
                          Navigator.pop(context, true);
                        }

                        _loadDetails();
                      },
                      child: Text(
                        t.returnItems,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReceiptPage(saleId: widget.saleId),
                          ),
                        );
                      },
                      child: Text(
                        t.viewReceipt,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
