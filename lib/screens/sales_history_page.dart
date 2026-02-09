import 'package:flutter/material.dart';
import '../database/app_database.dart';
import 'sale_details_page.dart';


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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sales History")),
      body: ListView.builder(
        itemCount: _sales.length,
        itemBuilder: (context, i) {
          final sale = _sales[i];
          return ListTile(
            title: Text("Sale #${sale['id']}"),
            subtitle: Text(
              "Date: ${sale['datetime']}\nTotal: ${sale['total']}",
            ),
            onTap: () => _openSaleDetails(sale['id']),
          );
        },
      ),
    );
  }
}
