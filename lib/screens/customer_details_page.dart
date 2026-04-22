import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../utils/beautiful_dialog.dart';

import '../generated/app_localizations.dart';
import '../models/customer.dart';
import '../db/sales_dao.dart';
import '../db/customer_payments_dao.dart';
import '../db/customer_dao.dart';
import '../utils/date_format.dart';
import 'sale_details_page.dart';
import '../utils/customer_statement_pdf.dart';
import '../utils/pin_guard.dart';
import 'edit_customer_page.dart';
import 'package:share_plus/share_plus.dart';
import '../db/balance_history_dao.dart';
import '../services/escpos_receipt_service.dart';

class CustomerDetailsPage extends StatefulWidget {
  final Customer customer;

  const CustomerDetailsPage({super.key, required this.customer});

  @override
  State<CustomerDetailsPage> createState() => _CustomerDetailsPageState();
}

class _CustomerDetailsPageState extends State<CustomerDetailsPage>

    with SingleTickerProviderStateMixin {
  final _salesDao = SalesDao();
  final _paymentsDao = CustomerPaymentsDao();
  final _customerDao = CustomerDao();

  late Customer _customer;

  List<Map<String, dynamic>> _sales = [];
  List<Map<String, dynamic>> _payments = [];
  List<Map<String, dynamic>> _balanceHistory = [];

  late TabController _tabController;
  late double _balance;

  bool _isPrintablePayment(Map<String, dynamic> p) {
  final note = (p['note'] ?? "") as String;
  final type = (p['type'] ?? "").toString();

  if (type == "return") return false;
  if (note.contains("Paid during sale")) return false;

  return true;
}

bool isZero(double v) => v.abs() < 0.0001;

Future<void> _reloadCustomerBalance() async {
  if (_customer.id == null) return;

  // 1. Load customer FIRST
  final updated = await _customerDao.getCustomerById(_customer.id!);
  // 2. Load history SECOND
  final history = await BalanceHistoryDao().getHistory(_customer.id!);

  // 3. Update state
  if (updated != null) {
    setState(() {
      _customer = updated;
      _balanceHistory = history;
      _balance = updated.balance;
    });
  }

  // 4. Load sales AFTER customer is updated
  await _loadSales();

  // 5. Load payments LAST
  await _loadPayments();
}

  @override
void initState() {
  super.initState();
  _customer = widget.customer;
  _tabController = TabController(length: 3, vsync: this);
  _balance = _customer.balance;

  // Only this — it loads everything safely
  Future.delayed(Duration(milliseconds: 150), _reloadCustomerBalance);
}

Widget _buildBalanceHistoryTab() {
  final t = AppLocalizations.of(context)!;

  if (_balanceHistory.isEmpty) {
    return Center(
      child: Text(
        t.noHistory,
        style: const TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }

  return ListView.builder(
    itemCount: _balanceHistory.length,
    itemBuilder: (_, i) {
      final h = _balanceHistory[i];

     
      final newBalance = (h['new_balance'] as num).toDouble();
      final note = h['note'] ?? '';
      final datetime = h['datetime'] ?? '';
      final change = (h['change'] as num).toDouble();
      
      final oldBalance = newBalance - change;
      return Card(
        child: ListTile(
          leading: Icon(
            change >= 0 ? Icons.add : Icons.remove,
            color: change >= 0 ? Colors.green : Colors.red,
          ),
          
title: Text(
  "${oldBalance.toStringAsFixed(2)} "
  "${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)} "
  "= ${newBalance.toStringAsFixed(2)}",
  style: const TextStyle(fontWeight: FontWeight.bold),
),

          subtitle: Text("$note\n${formatDateTimeUI(datetime)}"),
        ),
      );
    },
  );
}

  void _openGiveCashDialog() async {
  final t = AppLocalizations.of(context)!;
  final amountCtrl = TextEditingController();
  final noteCtrl = TextEditingController();

  await showBeautifulDialog(
    context: context,
    title: t.giveCash,
    lottie: "Check Mark",
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: amountCtrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: t.amount),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: noteCtrl,
          maxLines: 3,
          decoration: InputDecoration(labelText: t.note),
        ),
        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 0, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.arrow_upward, color: Colors.white),
                label: Text(t.save, style: const TextStyle(color: Colors.white)),
                onPressed: () async {
                  final amount = double.tryParse(amountCtrl.text) ?? 0;
                  if (amount <= 0) return;

                  Navigator.pop(context);

                  if (!await requireManagerPin(context)) return;

                  await _processGiveCash(amount, noteCtrl.text.trim());
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        SizedBox(
          width: double.infinity,
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: Text(t.cancel, style: const TextStyle(color: Colors.black87)),
          ),
        ),
      ],
    ),
    actions: const [],
  );
}

Future<void> _processGiveCash(double amount, String note) async {
  final t = AppLocalizations.of(context)!;

  amount = amount.abs();
  final savedNote = note.isEmpty ? t.giveCashNote : note;

  final id = await _paymentsDao.addGiveCash(
    customerId: _customer.id!,
    amount: amount,
    note: savedNote,
  );

  await _reloadCustomerBalance();

  // ❌ Removed auto-print here

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(t.giveCashAdded)),
  );
}






  Future<void> _loadSales() async {
    if (_customer.id == null) return;
    final list = await _salesDao.getSalesByCustomer(_customer.id!);
    setState(() => _sales = list);
  }

  Future<void> _loadPayments() async {
    if (_customer.id == null) return;
    final list = await _paymentsDao.getPayments(_customer.id!);
    setState(() => _payments = list);
  }

  void _openSale(int saleId) async {
    final changed = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SaleDetailsPage(saleId: saleId),
      ),
    );

    if (changed == true) {
      await _reloadCustomerBalance();
    }
  }

  // ---------------------------
  // PAY DEBT
  // ---------------------------
  void _openPayDebtDialog() async {
  final t = AppLocalizations.of(context)!;
  final amountCtrl = TextEditingController();
  final noteCtrl = TextEditingController();

  await showBeautifulDialog(
    context: context,
    title: t.payDebt,
    lottie: "Check Mark",
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: amountCtrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: t.amount),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: noteCtrl,
          maxLines: 3,
          decoration: InputDecoration(labelText: t.note),
        ),

        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.check_circle, color: Colors.white),
                label: Text(
                  t.save,
                  style: const TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  final amount = double.tryParse(amountCtrl.text) ?? 0;
                  if (amount <= 0) return;

                  Navigator.pop(context);

                  if (!await requireManagerPin(context)) return;

                  await _processPayDebt(amount, noteCtrl.text.trim());
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        SizedBox(
          width: double.infinity,
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: Text(
              t.cancel,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ),
      ],
    ),
    actions: const [],
  );
}

  Future<void> _processPayDebt(double amount, String note) async {
  final t = AppLocalizations.of(context)!;

  final savedNote = note.isEmpty ? t.debtPayment : note;

  // 1) Insert and get the ID of this pay_debt record
  final id = await _paymentsDao.addPayment(
    customerId: _customer.id!,
    amount: amount,
    note: savedNote,
    updateBalance: true,
  );

  // 2) Reload balance
  await _reloadCustomerBalance();

  // 3) (Optional) If you want to auto-print Pay Debt receipts:
  /*
  await EscposReceiptService.printPaymentReceipt(
    customer: _customer,
    payment: {
      'id': id,
      'amount': amount,
      'note': savedNote,
      'datetime': DateTime.now().toIso8601String(),
      'type': 'pay_debt',
    },
    t: t,
  );
  */

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(t.paymentAdded)),
  );
}


 String _buildPaymentReceiptText(Map<String, dynamic> p,Customer customer) {
  print("DEBUG RECEIPT TYPE: ${p['type']}");

  final t = AppLocalizations.of(context)!;

  final rawAmount = p['amount'] as num;
  final type = (p['type'] ?? '').toString();
  final amount = (type == "give_cash" ? rawAmount.abs() : rawAmount).toStringAsFixed(2);

  final date = formatDateOnly(p['datetime']);
  final time = formatTimeOnly(p['datetime']);
  final note = (p['note'] ?? '').toString();

  String header;
  if (type == "give_cash") {
  header = t.cashOutSentence(_customer.name, amount);
} else if (type == "pay_debt") {
  header = t.paymentSentence(_customer.name, amount);
} else if (type == "return") {
  header = t.returnNote;
} else {
  header = t.paymentAdded;
}


  return """
$header
${t.amount}: $amount
${t.date}: $date
${t.time}: $time
${note.isNotEmpty ? "${t.note}: $note" : ""}
""";
}



  // ---------------------------
  // PAYMENT ACTIONS
  // ---------------------------
  void _showPaymentActions(Map<String, dynamic> payment) {
    print("DEBUG TYPE: ${payment['type']}"); // <‑‑ PUT IT HERE
    final t = AppLocalizations.of(context)!;
    final canPrint = _isPrintablePayment(payment);

    final type = (payment['type'] ?? "").toString();
final isGiveCash = type == "give_cash";
final isDebtPayment = type == "pay_debt";
final isReturn = type == "return";
final isPaidDuringSale = type == "paid_sale";


    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              
// WhatsApp share for Debt Payment AND Give Cash
if (isDebtPayment || isGiveCash)
  Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    child: ElevatedButton.icon(
      onPressed: () async {
  // Generate PDF
  final pdfPath = await CustomerStatementPdf.generatePaymentReceiptFile(
    customer: _customer,
    payment: payment,
  );

  // Clean phone number
  String rawPhone = _customer.phone?.trim() ?? "";
  String phone = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');

  // Convert Syrian local format (09XXXXXXXX) → international (9639XXXXXXXX)
  if (phone.startsWith("09")) {
    phone = "963" + phone.substring(1);
  }

  try {
    if (phone.isNotEmpty) {
      final url = "https://wa.me/$phone";
      Share.shareXFiles([XFile(pdfPath)], text: url);
    } else {
      // No phone → open WhatsApp without number
      Share.shareXFiles([XFile(pdfPath)]);
    }
  } catch (e) {
    debugPrint("Share failed: $e");
  }
},

      icon: const Icon(FontAwesomeIcons.whatsapp, color: Colors.white),
      label: Text(
        t.shareWhatsApp,
        style: const TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      ),
    ),
  ),


              if (canPrint)
  ListTile(
    leading: const Icon(Icons.print),
    title: Text(t.printReceipt),
   onTap: () async {
  Navigator.pop(context);

  final type = (payment['type'] ?? "").toString();

  try {
    if (type == "give_cash") {
      await EscposReceiptService.printCashOutReceipt(
        customer: _customer,
        amount: (payment['amount'] as num).abs().toDouble(),
        reason: payment['note'] ?? "",
        datetime: payment['datetime'],
        payoutId: payment['id'],
        t: AppLocalizations.of(context)!,
      );
    } else {
      await EscposReceiptService.printPaymentReceipt(
        customer: _customer,
        payment: payment,
        t: AppLocalizations.of(context)!,
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Printer not connected")),
    );
  }
}

  ),

              ListTile(
                leading: const Icon(Icons.edit),
                title: Text(t.editPayment),
                onTap: () {
                  Navigator.pop(context);
                  _openEditPaymentDialog(payment);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: Text(t.deletePayment),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeletePayment(payment);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _printPayment(Map<String, dynamic> payment) async {
  final type = (payment['type'] ?? "").toString();

  if (type == "give_cash") {
    await EscposReceiptService.printCashOutReceipt(
      customer: _customer,
      amount: (payment['amount'] as num).abs().toDouble(),
      reason: payment['note'] ?? "",
      datetime: payment['datetime'],
      payoutId: payment['id'],
      t: AppLocalizations.of(context)!,
    );
  } else {
    await EscposReceiptService.printPaymentReceipt(
      customer: _customer,
      payment: payment,
      t: AppLocalizations.of(context)!,
    );
  }
}


  // ---------------------------
  // EDIT PAYMENT
  // ---------------------------
 void _openEditPaymentDialog(Map<String, dynamic> payment) async {
  final t = AppLocalizations.of(context)!;

  final amountController =
      TextEditingController(text: payment['amount'].toString());
  final noteController =
      TextEditingController(text: payment['note'] ?? "");

  await showBeautifulDialog(
    context: context,
    title: t.editPayment,
    lottie: "Check Mark",
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: t.amount),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: noteController,
          maxLines: 3,
          decoration: InputDecoration(labelText: t.note),
        ),

        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.check_circle, color: Colors.white),
                label: Text(
                  t.save,
                  style: const TextStyle(color: Colors.white),
                ),
               onPressed: () async {
  final newAmount = double.tryParse(amountController.text) ?? 0;

  // Detect if this is a "Give Cash" record
  final isGiveCash = (payment['note'] ?? "").toString()
      .contains(AppLocalizations.of(context)!.giveCashNote);

  // Validation: positive for normal payments, negative allowed for Give Cash
  if (!isGiveCash && newAmount <= 0) return;
  if (isGiveCash && newAmount >= 0) return; // enforce negative for Give Cash

  if (!await requireManagerPin(context)) return;

  final oldAmount = payment['amount'] as double;

  await _paymentsDao.updatePayment(
    id: payment['id'],
    customerId: _customer.id!,
    oldAmount: oldAmount,
    newAmount: newAmount,
    note: noteController.text.trim(),
  );

  await _reloadCustomerBalance();
  Navigator.pop(context);
},

              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        SizedBox(
          width: double.infinity,
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: Text(
              t.cancel,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ),
      ],
    ),
    actions: const [],
  );
}


  // ---------------------------
  // DELETE PAYMENT
  // ---------------------------
 void _confirmDeletePayment(Map<String, dynamic> payment) async {
  final t = AppLocalizations.of(context)!;
  final amount = payment['amount'] as double;

  await showBeautifulDialog(
    context: context,
    title: t.deletePayment,
    lottie: "Delete Animation", // your Lottie file
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "${t.deletePaymentOf} $amount ?",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),

        const SizedBox(height: 20),

        // DELETE BUTTON
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.delete_forever, color: Colors.white),
                label: Text(
                  t.delete,
                  style: const TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  Navigator.pop(context);

                  if (!await requireManagerPin(context)) return;

                  await _deletePayment(payment);
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // CANCEL BUTTON
        SizedBox(
          width: double.infinity,
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: Text(
              t.cancel,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ),
      ],
    ),
    actions: const [],
  );
}


  // ---------------------------
  // DELETE CUSTOMER
  // ---------------------------
  void _confirmDeleteCustomer() async {
    final t = AppLocalizations.of(context)!;

    if (_balance != 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.cannotDeleteCustomerWithBalance)),
      );
      return;
    }

    if (!await requireManagerPin(context)) return;

    await _deleteCustomer();
  }

  Future<void> _deleteCustomer() async {
    final t = AppLocalizations.of(context)!;

    await _customerDao.deleteCustomer(_customer.id!);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.customerDeleted)),
    );

    Navigator.pop(context, true);
  }

  Future<void> _deletePayment(Map<String, dynamic> payment) async {
    final t = AppLocalizations.of(context)!;

    final id = payment['id'] as int;
    final amount = payment['amount'] as double;

    await _paymentsDao.deletePayment(
      id,
      amount,
      _customer.id!,
    );

    await _reloadCustomerBalance();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.paymentDeleted)),
    );
  }
  // ---------------------------
  // PAYMENT LABEL HELPERS
  // ---------------------------
  int? extractSaleId(String note) {
    final regex = RegExp(r'#(\d+)');
    final match = regex.firstMatch(note);
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }
    return null;
  }

  Color _paymentColor(Map<String, dynamic> p) {
  switch (p['type']) {
    case 'return':
      return Colors.orange;
    case 'paid_sale':
      return Colors.yellow.shade700;
    case 'give_cash':
      return Colors.blue;
    case 'pay_debt':
      return Colors.green;
    default:
      return Colors.grey;
  }
}





IconData _paymentIcon(Map<String, dynamic> p) {
  switch (p['type']) {
    case 'return':
      return Icons.undo;
    case 'paid_sale':
      return Icons.receipt_long;
    case 'give_cash':
      return Icons.arrow_upward_rounded;
    case 'pay_debt':
      return FontAwesomeIcons.handHoldingDollar;
    default:
      return Icons.help_outline;
  }
}





void _editInitialBalance() async {
  final t = AppLocalizations.of(context)!;

  // 1. Manager PIN required
  if (!await requireManagerPin(context)) return;

  final ctrl = TextEditingController(
    text: _customer.initialBalance.toString(),
  );

  // 2. Ask user for new value
  final newValue = await showDialog<double>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(t.editInitialBalance),
      content: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(t.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, double.tryParse(ctrl.text));
          },
          child: Text(t.save),
        ),
      ],
    ),
  );

  if (newValue == null) return;

  final oldInitial = _customer.initialBalance;
  final oldBalance = _customer.balance;

  // 3. Calculate difference
  final diff = newValue - oldInitial;

  // 4. Update initial balance
  await _customerDao.updateInitialBalance(_customer.id!, newValue);

  // 5. Update actual balance
  final updatedBalance = oldBalance + diff;
  await _customerDao.updateBalance(_customer.id!, updatedBalance);

  // 6. Log history
  await BalanceHistoryDao().addHistory(
    customerId: _customer.id!,
    change: diff,
    newBalance: updatedBalance,
    note: "Initial balance edited",
  );

  // 7. Refresh UI
  await _reloadCustomerBalance();

  // 8. Notify user
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(t.initialBalanceUpdated)),
  );
}



void _resetBalance() async {
  final t = AppLocalizations.of(context)!;

  // 1. Manager PIN required
  if (!await requireManagerPin(context)) return;

  // 2. Ask user which reset type they want
final choice = await showBeautifulDialog(
  context: context,
  title: t.resetBalance,
  lottie: "Warning",
  content: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        t.chooseResetType,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16),
      ),

      const SizedBox(height: 20),

      Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              style: dialogButton(Colors.redAccent),
              icon: const Icon(Icons.restart_alt, color: Colors.white),
              label: Text(
                t.resetToZero,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context, "zero"),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton.icon(
              style: dialogButton(Colors.orange),
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: Text(
                t.resetToInitial,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context, "initial"),
            ),
          ),
        ],
      ),

      const SizedBox(height: 10),

      SizedBox(
        width: double.infinity,
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.grey.shade300,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => Navigator.pop(context),
          child: Text(
            t.cancel,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
      ),
    ],
  ),
  actions: const [],
);





  if (choice == null) return;

  final oldBalance = _customer.balance;
  double newBalance;

  if (choice == "zero") {
    newBalance = 0;
  } else {
    newBalance = _customer.initialBalance;
  }

  // 3. Update DB
  await _customerDao.updateBalance(_customer.id!, newBalance);

  // 4. Log history
  await BalanceHistoryDao().addHistory(
    customerId: _customer.id!,
    change: newBalance - oldBalance,
    newBalance: newBalance,
    note: choice == "zero"
        ? "Balance reset to zero"
        : "Balance reset to initial",
  );

  // 5. Refresh UI
  await _reloadCustomerBalance();

  // 6. Notify user
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(t.balanceReset)),
  );
}

String formatArabicBalance(double value) {
  if (value.abs() < 0.0001) {
    return "0"; // zero → no prefix
  } else if (value < 0) {
    return "عليه ${value.toStringAsFixed(2)}"; // negative
  } else {
    return "له ${value.toStringAsFixed(2)}"; // positive
  }
}


  String _paymentLabel(Map<String, dynamic> p, AppLocalizations t) {
  final saleId = extractSaleId((p['note'] ?? "") as String);

  switch (p['type']) {
    case 'return':
      return saleId != null ? t.refundForReturn(saleId) : t.refundLabel;
    case 'give_cash':
      return t.giveCashRecord;
    case 'paid_sale':
      return saleId != null ? t.paidDuringSale(saleId) : t.paidDuringSaleLabel;
    case 'pay_debt':
      return t.debtPayment;
    default:
      return t.debtPayment;
  }
}


  // ---------------------------
  // UI
  // ---------------------------
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final c = _customer;

    String label;
    Color labelColor;

    if (isZero(_balance)) {
  label = t.balance;
  labelColor = Colors.grey;
} else if (_balance < 0) {
  label = t.debt;
  labelColor = Colors.red;
} else {
  label = t.credit;
  labelColor = Colors.green;
}


    return Scaffold(
      appBar: AppBar(
  title: Text(c.name),
  actions: [
   PopupMenuButton<String>(
  onSelected: (value) async {
    switch (value) {
      case 'edit':
        final updated = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditCustomerPage(customer: _customer),
          ),
        );
        if (updated == true) {
          await _reloadCustomerBalance();
          setState(() {});
        }
        break;

      case 'pdf':
        await CustomerStatementPdf.generate(
          customer: _customer,
          sales: _sales,
          payments: _payments,
        );
        break;

      case 'initial':
        _editInitialBalance();
        break;

      case 'reset':
        _resetBalance();
        break;

      case 'delete':
        _confirmDeleteCustomer();
        break;
    }
  },
  itemBuilder: (context) => [
    PopupMenuItem(
      value: 'edit',
      child: Row(
        children: [
          const Icon(Icons.edit, color: Colors.blue),
          const SizedBox(width: 8),
          Text(t.editCustomer),
        ],
      ),
    ),
    PopupMenuItem(
      value: 'pdf',
      child: Row(
        children: [
          const Icon(Icons.picture_as_pdf, color: Colors.red),
          const SizedBox(width: 8),
          Text(t.exportPdf),
        ],
      ),
    ),
    PopupMenuItem(
      value: 'initial',
      child: Row(
        children: [
          const Icon(Icons.edit_note, color: Colors.orange),
          const SizedBox(width: 8),
          Text(t.editInitialBalance),
        ],
      ),
    ),
    PopupMenuItem(
      value: 'reset',
      child: Row(
        children: [
          const Icon(Icons.refresh, color: Colors.green),
          const SizedBox(width: 8),
          Text(t.resetBalance),
        ],
      ),
    ),
    PopupMenuItem(
      value: 'delete',
      child: Row(
        children: [
          const Icon(Icons.delete, color: Colors.redAccent),
          const SizedBox(width: 8),
          Text(t.deleteCustomer),
        ],
      ),
    ),
  ],
)

  ],
  bottom: TabBar(
    controller: _tabController,
    tabs: [
      Tab(text: t.sales),
      Tab(text: t.payments),
      Tab(text: t.balanceHistory),
    ],
  ),
),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${t.phone}: ${c.phone ?? '-'}",
                    style: const TextStyle(fontSize: 16)),
                if (c.address != null && c.address!.isNotEmpty)
                  Text("${t.address}: ${c.address}",
                      style: const TextStyle(fontSize: 16)),
                if (c.notes != null && c.notes!.isNotEmpty)
                  Text("${t.notes}: ${c.notes}",
                      style: const TextStyle(fontSize: 16)),
                Text(
                  "$label: ${_balance.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 16,
                    color: labelColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
           child: TabBarView(
  controller: _tabController,
  children: [

    // -------------------------------------------------
    // ⭐ SALES TAB
    // -------------------------------------------------
    _sales.isEmpty
        ? Center(child: Text(t.noSalesYet))
        : ListView.builder(
            itemCount: _sales.length,
            itemBuilder: (context, i) {
              final sale = _sales[i];
              return Card(
                child: ListTile(
                  title: Text("${t.sale} #${sale['id']}"),
                  subtitle: Text(formatDateTimeUI(sale['datetime'])),
                  trailing: Text(
                    (sale['total'] as num).toStringAsFixed(2),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () => _openSale(sale['id']),
                ),
              );
            },
          ),

    // -------------------------------------------------
    // ⭐ PAYMENTS TAB
    // -------------------------------------------------
    Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            width: double.infinity,
           child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color.fromARGB(255, 0, 255, 38),
    ),
              onPressed: _openPayDebtDialog,
              child: Text(t.payDebt),
            ),
          ),
        ),
      Padding(  padding: const EdgeInsets.all(12),
child:SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color.fromARGB(255, 255, 85, 0),
    ),
    onPressed: _openGiveCashDialog,
    child: Text(t.giveCash),
  ),
),
      ),
        Expanded(
          child: ListView.builder(
            itemCount: _payments.length + 1, // last row = initial balance
            itemBuilder: (context, i) {
              // ⭐ INITIAL BALANCE ROW
              if (i == _payments.length) {
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.flag, color: Colors.red),
                    title: Text(
                      t.initialBalance,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                   subtitle: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      "${t.date}: ${formatDateOnly(_customer.initialBalanceDate!)}",
      style: const TextStyle(color: Colors.grey, fontSize: 14),
    ),
    const SizedBox(height: 4),
    Text(
      "${t.time}: ${formatTimeOnly(_customer.initialBalanceDate!)}",
      style: const TextStyle(color: Colors.grey, fontSize: 14),
    ),
  ],
),

                    trailing: Text(
                      _customer.initialBalance.toStringAsFixed(2),
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              }

              // ⭐ NORMAL PAYMENT ROW
              final p = _payments[i];
              final color = _paymentColor(p);
              final icon = _paymentIcon(p);
              final labelText = _paymentLabel(p, t);
              final note = (p['note'] ?? "").toString();
              final isReturn = (p['is_return'] ?? 0) == 1;
              final isPaidDuringSale = note.contains("Paid during sale");
              final isGiveCash = note.contains(t.giveCashNote);
final isDebtPayment = !isReturn && !isPaidDuringSale && !isGiveCash;
final canPrint = _isPrintablePayment(p) || isGiveCash;
final pastBalance = (p['balance_at_time'] as num?)?.toDouble();
final amount = (p['amount'] as num).toDouble();
final newBalance = pastBalance != null ? pastBalance + amount : null;


             return Card(
  child: ListTile(
    leading: Icon(
      _paymentIcon(p),
      color: _paymentColor(p),
    ),

    title: Text(
      "${_paymentLabel(p, t)}\n"
      "${t.amount}: ${amount.toStringAsFixed(2)}",
      style: const TextStyle(fontWeight: FontWeight.bold),
    ),

    subtitle: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (pastBalance != null)
          Text(
            "${t.pastBalance}: ${formatArabicBalance(pastBalance)}",

            style: const TextStyle(color: Colors.grey),
          ),

        if (newBalance != null)
          Text(
            "${t.currentBalance}: ${formatArabicBalance(newBalance)}",
            style: const TextStyle(color: Colors.grey),
          ),

        Text(formatDateTimeUI(p['datetime'])),
        if ((p['note'] ?? '').toString().isNotEmpty)
          Text("${t.note}: ${p['note']}"),
      ],
    ),

    onTap: () => _showPaymentActions(p),
  ),
);

            },
          ),
        ),
      ],
    ),

    // -------------------------------------------------
    // ⭐ BALANCE HISTORY TAB
    // -------------------------------------------------
    _buildBalanceHistoryTab(),
  ],
),

          ),
        ],
      ),
    );
  }
}

// ---------------------------
// DATE + TIME HELPERS
// ---------------------------
String formatDateOnly(String iso) {
  final dt = DateTime.parse(iso);
  return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
}

String formatTimeOnly(String iso) {
  final dt = DateTime.parse(iso);
  final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final minute = dt.minute.toString().padLeft(2, '0');
  final period = dt.hour >= 12 ? "PM" : "AM";
  return "$hour12:$minute $period";
}
