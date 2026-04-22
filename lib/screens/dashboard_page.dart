import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../generated/app_localizations.dart';
import 'monthly_report_page.dart';

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
  List<Map<String, dynamic>> salesProfit = [];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    final db = await AppDatabase.instance.database;
    final today = DateTime.now().toIso8601String().substring(0, 10);

    final totalResult = await db.rawQuery('''
      SELECT SUM(total) as total
      FROM sales
      WHERE datetime LIKE '$today%'
    ''');

    final countResult = await db.rawQuery('''
      SELECT COUNT(*) as count
      FROM sales
      WHERE datetime LIKE '$today%'
    ''');

    final itemsResult = await db.rawQuery('''
      SELECT SUM(qty) as qty
      FROM sale_items
      JOIN sales ON sale_items.sale_id = sales.id
      WHERE sales.datetime LIKE '$today%'
    ''');

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

    final profitResult = await db.rawQuery('''
      SELECT 
        sales.id AS sale_id,
        SUM((sale_items.price - products.purchase_price) * sale_items.qty) AS profit
      FROM sale_items
      JOIN products ON sale_items.product_id = products.id
      JOIN sales ON sale_items.sale_id = sales.id
      WHERE sales.datetime LIKE '$today%'
      GROUP BY sales.id
      ORDER BY sales.id DESC
    ''');

    setState(() {
      todayTotal = (totalResult.first['total'] as num?)?.toDouble() ?? 0.0;
      todaySalesCount = (countResult.first['count'] as num?)?.toInt() ?? 0;
      todayItemsSold = (itemsResult.first['qty'] as num?)?.toInt() ?? 0;
      topProducts = topResult;
      salesProfit = profitResult;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(t.dashboard)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Card(
              child: ListTile(
                title: Text(t.todaySalesTotal),
                subtitle: Text("$todayTotal"),
              ),
            ),
            Card(
              child: ListTile(
                title: Text(t.numberOfSalesToday),
                subtitle: Text("$todaySalesCount"),
              ),
            ),
            Card(
              child: ListTile(
                title: Text(t.totalItemsSoldToday),
                subtitle: Text("$todayItemsSold"),
              ),
            ),

            const SizedBox(height: 20),
            Text(
              t.topSellingProductsToday,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            ...topProducts.map((p) {
              return ListTile(
                title: Text(p['name']),
                trailing: Text("${t.sold}: ${p['total_qty']}"),
              );
            }),

            const SizedBox(height: 30),

            Text(
              t.salesProfitToday,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            ...salesProfit.map((row) {
              final saleId = row['sale_id'];
              final profit = (row['profit'] as num?)?.toDouble() ?? 0.0;

              return Card(
                child: ListTile(
                  title: Text("${t.saleNumber}$saleId"),
                  trailing: Text("${t.profit}: ${profit.toStringAsFixed(2)}"),
                ),
              );
            }),

            const SizedBox(height: 30),

            ElevatedButton.icon(
              icon: const Icon(Icons.calendar_month),
              label: Text(t.monthlyReport),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MonthlyReportPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
