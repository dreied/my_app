import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../utils/date_format.dart';
import 'sale_details_page.dart';
import 'return_sale_page.dart';
import 'return_history_page.dart';
import '../generated/app_localizations.dart';

class SalesHistoryPage extends StatefulWidget {
  const SalesHistoryPage({super.key});

  @override
  State<SalesHistoryPage> createState() => _SalesHistoryPageState();
}

class _SalesHistoryPageState extends State<SalesHistoryPage> {
  List<Map<String, dynamic>> _sales = [];

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  Future<void> _loadSales() async {
    final db = await AppDatabase.instance.database;
    final result = await db.query(
      'sales',
      orderBy: 'datetime DESC',
    );
    setState(() => _sales = result);
  }

  void _openSaleDetails(int saleId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SaleDetailsPage(saleId: saleId),
      ),
    );
  }

  Future<bool> _saleHasRemaining(int saleId) async {
    final db = await AppDatabase.instance.database;

    final items = await db.rawQuery('''
      SELECT qty, returned_qty
      FROM sale_items
      WHERE sale_id = ?
    ''', [saleId]);

    for (var item in items) {
      final sold = item['qty'] as int;
      final returned = item['returned_qty'] as int? ?? 0;
      if (sold - returned > 0) return true;
    }

    return false;
  }

  Future<void> _openReturnPage(int saleId) async {
    final t = AppLocalizations.of(context)!;

    final hasRemaining = await _saleHasRemaining(saleId);

    if (!hasRemaining) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.nothingToReturn)),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReturnSalePage(saleId: saleId),
      ),
    );
  }

  void _openReturnHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ReturnHistoryPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.salesHistory),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: t.returnHistory,
            onPressed: _openReturnHistory,
          ),
        ],
      ),

      body: ListView.builder(
        itemCount: _sales.length,
        itemBuilder: (context, i) {
          final sale = _sales[i];
          return Card(
            child: ListTile(
              title: Text("${t.sale} #${sale['id']}"),
              subtitle: Text(formatDateTimeUI(sale['datetime'])),
             trailing: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Text(
      (sale['total'] as num).toStringAsFixed(2),
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),

    const SizedBox(width: 12),

    IconButton(
      icon: const Icon(Icons.undo, color: Colors.red),
      tooltip: t.returnItems,
      onPressed: () => _openReturnPage(sale['id']),
    ),
  ],
),

              onTap: () => _openSaleDetails(sale['id']),
            ),
          );
        },
      ),
    );
  }
}
