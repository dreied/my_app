import 'package:flutter/material.dart';
import '../database/app_database.dart';

class InventoryLogPage extends StatefulWidget {
  const InventoryLogPage({super.key});

  @override
  State<InventoryLogPage> createState() => _InventoryLogPageState();
}

class _InventoryLogPageState extends State<InventoryLogPage> {
  List<Map<String, dynamic>> _logs = [];

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final db = await AppDatabase.instance.database;

    final result = await db.rawQuery('''
      SELECT inventory_log.*, products.name 
      FROM inventory_log
      JOIN products ON inventory_log.product_id = products.id
      ORDER BY inventory_log.datetime DESC
    ''');

    setState(() => _logs = result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inventory Log")),
      body: ListView.builder(
        itemCount: _logs.length,
        itemBuilder: (context, i) {
          final log = _logs[i];
          final qty = log['change_qty'];

          return ListTile(
            title: Text(log['name']),
            subtitle: Text(
              "Change: $qty | Date: ${log['datetime']}",
            ),
            trailing: qty < 0
                ? const Icon(Icons.remove, color: Colors.red)
                : const Icon(Icons.add, color: Colors.green),
          );
        },
      ),
    );
  }
}
