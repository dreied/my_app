import 'package:flutter/material.dart';
import '../db/customer_dao.dart';
import '../models/customer.dart';
import 'add_customer_page.dart';
import 'customer_details_page.dart';
import '../generated/app_localizations.dart';
import '../utils/error_handler.dart';
class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  final _dao = CustomerDao();
  List<Customer> _customers = [];

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    final list = await _dao.getAllCustomers();
    setState(() => _customers = list);
  }

  Future<void> _addCustomer() async {
  final t = AppLocalizations.of(context)!;

  final newCustomer = await Navigator.push<Customer?>(
    context,
    MaterialPageRoute(builder: (_) => const AddCustomerPage()),
  );

  if (newCustomer != null) {
    try {
      await _dao.insertCustomer(newCustomer);
      await _loadCustomers();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.customerAdded)),
      );

    } catch (e) {
      // ✅ Use your unified activation error handler
      showActivationError(context, e);
    }
  }
}



  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(t.customers)),
      body: ListView.builder(
        itemCount: _customers.length,
        itemBuilder: (context, index) {
          final c = _customers[index];

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
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (c.phone != null && c.phone!.isNotEmpty)
                  Text(c.phone!),

                Text(
                  "$label: ${c.balance.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            onTap: () async {
              final deleted = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => CustomerDetailsPage(customer: c),
                ),
              );

              await _loadCustomers();
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCustomer,
        child: const Icon(Icons.add),
      ),
    );
  }
}
