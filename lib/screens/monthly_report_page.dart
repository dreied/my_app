import 'package:flutter/material.dart';
import '../database/app_database.dart';

class MonthlyReportPage extends StatefulWidget {
  const MonthlyReportPage({super.key});

  @override
  State<MonthlyReportPage> createState() => _MonthlyReportPageState();
}

class _MonthlyReportPageState extends State<MonthlyReportPage> {
  double totalSales = 0;
  int totalItems = 0;
  double totalProfit = 0;
  List<Map<String, dynamic>> topProducts = [];

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    final db = await AppDatabase.instance.database;

    final now = DateTime.now();
    final month = now.toIso8601String().substring(0, 7); // YYYY-MM

    // Total sales
    final salesResult = await db.rawQuery('''
      SELECT SUM(total) as total
      FROM sales
      WHERE datetime LIKE '$month%'
    ''');

    // Total items sold
    final itemsResult = await db.rawQuery('''
      SELECT SUM(qty) as qty
      FROM sale_items
      JOIN sales ON sale_items.sale_id = sales.id
      WHERE sales.datetime LIKE '$month%'
    ''');

    // Profit = (sell price - purchase price) * qty
    final profitResult = await db.rawQuery('''
      SELECT SUM((sale_items.price - products.purchase_price) * sale_items.qty) AS profit
      FROM sale_items
      JOIN products ON sale_items.product_id = products.id
      JOIN sales ON sale_items.sale_id = sales.id
      WHERE sales.datetime LIKE '$month%'
    ''');

    // Top 5 products
    final topResult = await db.rawQuery('''
      SELECT products.name, SUM(sale_items.qty) as total_qty
      FROM sale_items
      JOIN products ON sale_items.product_id = products.id
      JOIN sales ON sale_items.sale_id = sales.id
      WHERE sales.datetime LIKE '$month%'
      GROUP BY sale_items.product_id
      ORDER BY total_qty DESC
      LIMIT 5
    ''');

    setState(() {
      totalSales = (salesResult.first['total'] as num?)?.toDouble() ?? 0.0;
      totalItems = (itemsResult.first['qty'] as num?)?.toInt() ?? 0;
      totalProfit = (profitResult.first['profit'] as num?)?.toDouble() ?? 0.0;
      topProducts = topResult;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Monthly Report")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Card(
              child: ListTile(
                title: const Text("Total Sales This Month"),
                subtitle: Text("$totalSales"),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text("Total Items Sold"),
                subtitle: Text("$totalItems"),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text("Total Profit"),
                subtitle: Text("$totalProfit"),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Top Selling Products",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...topProducts.map((p) {
              return ListTile(
                title: Text(p['name']),
                trailing: Text("Sold: ${p['total_qty']}"),
              );
            }),
          ],
        ),
      ),
    );
  }
}
