import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../generated/app_localizations.dart';

class MonthlyReportPage extends StatefulWidget {
  const MonthlyReportPage({super.key});

  @override
  State<MonthlyReportPage> createState() => _MonthlyReportPageState();
}

class _MonthlyReportPageState extends State<MonthlyReportPage> {
  List<Map<String, dynamic>> monthlyReports = [];

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<List<String>> _getAllMonths() async {
    final db = await AppDatabase.instance.database;

    final result = await db.rawQuery('''
      SELECT DISTINCT SUBSTR(datetime, 1, 7) AS month
      FROM sales
      ORDER BY month DESC
    ''');

    return result.map((row) => row['month'] as String).toList();
  }

  String localizeMonth(BuildContext context, String ym) {
    final t = AppLocalizations.of(context)!;
    final parts = ym.split("-");
    final year = parts[0];
    final month = int.parse(parts[1]);

    final monthNames = [
      t.january,
      t.february,
      t.march,
      t.april,
      t.may,
      t.june,
      t.july,
      t.august,
      t.september,
      t.october,
      t.november,
      t.december,
    ];

    return "${monthNames[month - 1]} $year";
  }

  Future<void> _loadReport() async {
    final db = await AppDatabase.instance.database;
    final months = await _getAllMonths();

    List<Map<String, dynamic>> reports = [];

    for (final month in months) {
      final salesResult = await db.rawQuery('''
        SELECT SUM(total) as total
        FROM sales
        WHERE datetime LIKE '$month%'
      ''');

      final itemsResult = await db.rawQuery('''
        SELECT SUM(qty) as qty
        FROM sale_items
        JOIN sales ON sale_items.sale_id = sales.id
        WHERE sales.datetime LIKE '$month%'
      ''');

      final profitResult = await db.rawQuery('''
        SELECT SUM((sale_items.price - products.purchase_price) * sale_items.qty) AS profit
        FROM sale_items
        JOIN products ON sale_items.product_id = products.id
        JOIN sales ON sale_items.sale_id = sales.id
        WHERE sales.datetime LIKE '$month%'
      ''');

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

      reports.add({
        "month": month,
        "totalSales": (salesResult.first['total'] as num?)?.toDouble() ?? 0.0,
        "totalItems": (itemsResult.first['qty'] as num?)?.toInt() ?? 0,
        "totalProfit": (profitResult.first['profit'] as num?)?.toDouble() ?? 0.0,
        "topProducts": topResult,
      });
    }

    setState(() {
      monthlyReports = reports;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(t.monthlyReport)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...monthlyReports.map((m) {
            return ExpansionTile(
              title: Text(
                localizeMonth(context, m["month"]),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              children: [
                ListTile(
                  title: Text(t.totalSalesThisMonth),
                  subtitle: Text("${m['totalSales']}"),
                ),
                ListTile(
                  title: Text(t.totalItemsSold),
                  subtitle: Text("${m['totalItems']}"),
                ),
                ListTile(
                  title: Text(t.totalProfit),
                  subtitle: Text("${m['totalProfit']}"),
                ),

                const SizedBox(height: 10),
                Text(
                  t.topSellingProducts,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),

                ...m["topProducts"].map<Widget>((p) {
                  return ListTile(
                    title: Text(p['name']),
                    trailing: Text("${t.sold}: ${p['total_qty']}"),
                  );
                }).toList(),

                const SizedBox(height: 20),
              ],
            );
          }),
        ],
      ),
    );
  }
}
