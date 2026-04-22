import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../db/customer_dao.dart';
import '../generated/app_localizations.dart';
import '../utils/pin_guard.dart';

class EditCustomerPage extends StatefulWidget {
  final Customer customer;

  const EditCustomerPage({super.key, required this.customer});

  @override
  State<EditCustomerPage> createState() => _EditCustomerPageState();
}

class _EditCustomerPageState extends State<EditCustomerPage> {
  final CustomerDao _customerDao = CustomerDao();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _notesController;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final c = widget.customer;

    _nameController = TextEditingController(text: c.name);
    _phoneController = TextEditingController(text: c.phone ?? "");
    _addressController = TextEditingController(text: c.address ?? "");
    _notesController = TextEditingController(text: c.notes ?? "");
  }

  Future<void> _save() async {
    final t = AppLocalizations.of(context)!;

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();
    final notes = _notesController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.invalidCustomerName)),
      );
      return;
    }

    // PIN REQUIRED
    if (!await requireManagerPin(context)) return;

    setState(() => _saving = true);

    final updated = Customer(
  id: widget.customer.id,
  name: name,
  phone: phone.isEmpty ? null : phone,
  address: address.isEmpty ? null : address,
  notes: notes.isEmpty ? null : notes,
  balance: widget.customer.balance,
  initialBalance: widget.customer.initialBalance,
  initialBalanceDate: widget.customer.initialBalanceDate,
);


    await _customerDao.updateCustomer(updated);

    setState(() => _saving = false);

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(t.editCustomer)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: t.customerName,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: t.phone,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: t.address,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: t.notes,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(t.saveChanges),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
