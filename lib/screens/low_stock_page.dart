import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../generated/app_localizations.dart';

class LowStockPage extends StatefulWidget {
  const LowStockPage({super.key});

  @override
  State<LowStockPage> createState() => _LowStockPageState();
}

class _LowStockPageState extends State<LowStockPage> {
  List<Map<String, dynamic>> _lowStock = [];

  @override
  void initState() {
    super.initState();
    _loadLowStock();
  }

  Future<void> _loadLowStock() async {
    final db = await AppDatabase.instance.database;

    const threshold = 5;

    final result = await db.query(
      'products',
      where: 'stock <= ?',
      whereArgs: [threshold],
      orderBy: 'stock ASC',
    );

    setState(() => _lowStock = result);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(t.lowStockAlerts)),
      body: _lowStock.isEmpty
          ? Center(
              child: Text(
                t.allProductsSufficient,
                style: const TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: _lowStock.length,
              itemBuilder: (context, i) {
                final p = _lowStock[i];
                return ListTile(
                  title: Text(p['name']),
                  subtitle: Text("${t.stock}: ${p['stock']}"),
                  trailing: const Icon(Icons.warning, color: Colors.red),
                );
              },
            ),
    );
  }
}
