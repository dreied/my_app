import 'package:flutter/material.dart';
import '../db/customer_dao.dart';
import '../models/customer.dart';
import '../generated/app_localizations.dart';
import 'add_customer_page.dart';

class CustomerSelectPage extends StatefulWidget {
  const CustomerSelectPage({super.key});

  @override
  State<CustomerSelectPage> createState() => _CustomerSelectPageState();
}

class _CustomerSelectPageState extends State<CustomerSelectPage> {
  final CustomerDao _dao = CustomerDao();
  List<Customer> _all = [];
  List<Customer> _filtered = [];
  final TextEditingController _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await _dao.getAllCustomers();
    setState(() {
      _all = list;
      _filtered = list;
    });
  }

  String _normalize(String text) {
    return text
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ئ', 'ي')
        .replaceAll('ؤ', 'و')
        .replaceAll('ة', 'ه')
        .toLowerCase();
  }

  void _filter(String q) {
    final n = _normalize(q);
    setState(() {
      _filtered = _all.where((c) => _normalize(c.name).contains(n)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.selectCustomer),
      ),

      body: Column(
        children: [
          // 🔥 SEARCH BAR + ADD CUSTOMER BUTTON IN ONE ROW
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _search,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: t.searchCustomers,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: _filter,
                  ),
                ),

                const SizedBox(width: 10),

                // ADD CUSTOMER BUTTON INSIDE SEARCH BAR AREA
                IconButton(
                  icon: const Icon(Icons.person_add, size: 30),
                  color: Theme.of(context).primaryColor,
                  onPressed: () async {
                    final newCustomer = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddCustomerPage(),
                      ),
                    );

                    if (newCustomer != null) {
                      Navigator.pop(context, newCustomer);
                    }
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: _filtered.isEmpty
                ? Center(child: Text(t.noCustomersFound))
                : ListView.builder(
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final c = _filtered[i];

                      // BALANCE LOGIC
                      String label;
                      Color color;

                      if (c.balance < 0) {
                        label = t.debt;
                        color = Colors.red;
                      } else if (c.balance > 0) {
                        label = t.credit;
                        color = Colors.green;
                      } else {
                        label = t.balance;
                        color = Colors.grey;
                      }

                      return ListTile(
                        title: Text(
                          c.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          "$label: ${c.balance.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        onTap: () => Navigator.pop(context, c),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
