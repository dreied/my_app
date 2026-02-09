import 'package:flutter/material.dart';
import '../database/app_database.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  double todayTotal = 0;
  int todaySalesCount = 0;
  int todayItemsSold = 0;
  List<Map<String, dynamic>> topProducts = [];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    final db = await AppDatabase.instance.database;

    final today = DateTime.now().toIso8601String().substring(0, 10);

    // Total sales today
    final totalResult = await db.rawQuery('''
      SELECT SUM(total) as total
      FROM sales
      WHERE datetime LIKE '$today%'
    ''');

    // Number of sales today
    final countResult = await db.rawQuery('''
      SELECT COUNT(*) as count
      FROM sales
      WHERE datetime LIKE '$today%'
    ''');

    // Total items sold today
    final itemsResult = await db.rawQuery('''
      SELECT SUM(qty) as qty
      FROM sale_items
      JOIN sales ON sale_items.sale_id = sales.id
      WHERE sales.datetime LIKE '$today%'
    ''');

    // Top 5 products today
    final topResult = await db.rawQuery('''
      SELECT products.name, SUM(sale_items.qty) as total_qty
      FROM sale_items
      JOIN products ON sale_items.product_id = products.id
      JOIN sales ON sale_items.sale_id = sales.id
      WHERE sales.datetime LIKE '$today%'
      GROUP BY sale_items.product_id
      ORDER BY total_qty DESC
      LIMIT 5
    ''');

    setState(() {
      todayTotal = (totalResult.first['total'] as num?)?.toDouble() ?? 0.0;
      todaySalesCount = (countResult.first['count'] as num?)?.toInt() ?? 0;
      todayItemsSold = (itemsResult.first['qty'] as num?)?.toInt() ?? 0;
      topProducts = topResult;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Card(
              child: ListTile(
                title: const Text("Today's Sales Total"),
                subtitle: Text("$todayTotal"),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text("Number of Sales Today"),
                subtitle: Text("$todaySalesCount"),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text("Total Items Sold Today"),
                subtitle: Text("$todayItemsSold"),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Top Selling Products Today",
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
