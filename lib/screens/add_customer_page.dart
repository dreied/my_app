import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../generated/app_localizations.dart';
import '../services/activation_service.dart';   // ⭐ REQUIRED

class AddCustomerPage extends StatefulWidget {
  const AddCustomerPage({super.key});

  @override
  State<AddCustomerPage> createState() => _AddCustomerPageState();
}

class _AddCustomerPageState extends State<AddCustomerPage> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _initialBalanceCtrl = TextEditingController(text: "0");

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _initialBalanceCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final t = AppLocalizations.of(context)!;

    // ---------------------------------------------------------
    // ⭐ LIMIT: Only 2 customers allowed if NOT activated
    // ---------------------------------------------------------
    final activated = await ActivationService.isActivated();
    final count = await ActivationService.getCustomerCount();

    if (!activated && count >= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text(t.limitCustomers)),
);

    
      return;
    }

    // NAME REQUIRED
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.nameRequired)),
      );
      return;
    }

    // PHONE VALIDATION (if entered)
    final phone = _phoneCtrl.text.trim();
    if (phone.isNotEmpty) {
      final regex = RegExp(r'^09\d{8}$'); // Syrian format
      if (!regex.hasMatch(phone)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.invalidPhone)),
        );
        return;
      }
    }

    // Parse initial balance
    final initialBalance =
        double.tryParse(_initialBalanceCtrl.text.trim()) ?? 0;

    final customer = Customer(
      name: _nameCtrl.text.trim(),
      phone: phone.isEmpty ? null : phone,
      balance: initialBalance,
      initialBalance: initialBalance,
      initialBalanceDate: DateTime.now().toIso8601String(),
    );

    // ---------------------------------------------------------
    // ⭐ INCREMENT CUSTOMER COUNTER
    // ---------------------------------------------------------
    await ActivationService.incrementCustomer();

    Navigator.pop(context, customer);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(t.addCustomer)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(labelText: t.name),
            ),
            TextField(
              controller: _phoneCtrl,
              decoration: InputDecoration(
                labelText: t.phone,
                hintText: "09XXXXXXXX",
              ),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: _initialBalanceCtrl,
              decoration: InputDecoration(labelText: t.initialBalance),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: Text(t.save),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
