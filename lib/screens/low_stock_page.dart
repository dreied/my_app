import 'package:flutter/material.dart';
import '../database/app_database.dart';

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

    // You can change the threshold (default: 5)
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
    return Scaffold(
      appBar: AppBar(title: const Text("Low Stock Alerts")),
      body: _lowStock.isEmpty
          ? const Center(
              child: Text(
                "All products are sufficiently stocked",
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: _lowStock.length,
              itemBuilder: (context, i) {
                final p = _lowStock[i];
                return ListTile(
                  title: Text(p['name']),
                  subtitle: Text("Stock: ${p['stock']}"),
                  trailing: const Icon(Icons.warning, color: Colors.red),
                );
              },
            ),
    );
  }
}
