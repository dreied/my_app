import 'package:flutter/material.dart';
import '../db/return_dao.dart';
import '../utils/date_format.dart';
import '../generated/app_localizations.dart';

class ReturnHistoryPage extends StatefulWidget {
  const ReturnHistoryPage({super.key});

  @override
  State<ReturnHistoryPage> createState() => _ReturnHistoryPageState();
}

class _ReturnHistoryPageState extends State<ReturnHistoryPage> {
  final ReturnDao _dao = ReturnDao();
  List<Map<String, dynamic>> _returns = [];

  @override
  void initState() {
    super.initState();
    _loadReturns();
  }

  Future<void> _loadReturns() async {
    final result = await _dao.getReturns();
    setState(() => _returns = result);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(t.returnHistory)),
      body: ListView.builder(
        itemCount: _returns.length,
        itemBuilder: (context, i) {
          final r = _returns[i];

          final qty = (r['qty'] as num).toInt();
          final price = (r['price'] as num).toDouble(); // discounted price
          final total = qty * price;

          return Card(
            child: ListTile(
              title: Text(
                "${t.sale} #${r['sale_id']} • ${t.product} #${r['product_id']}",
              ),
              subtitle: Text(
                "${t.qty}: $qty • ${t.reason}: ${r['reason']}\n"
                "${formatDateTimeUI(r['datetime'])}",
              ),
              trailing: Text(
                "-${total.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
