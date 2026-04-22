import 'package:flutter/material.dart';
import '../generated/app_localizations.dart';
import '../controllers/cart_controller.dart';
import '../database/app_database.dart';
import '../models/cart_item.dart';
import '../models/customer.dart';
import 'printer_select_page.dart';
import '../services/receipt_service.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../db/customer_payments_dao.dart';
import '../utils/error_handler.dart';
import '../models/sale_item.dart';
import '../db/balance_history_dao.dart';
import '../services/escpos_receipt_service.dart';
import '../services/activation_service.dart';


class CheckoutPage extends StatefulWidget {
  final CartController cart;

  const CheckoutPage({super.key, required this.cart});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool _saving = false;

  Future<double?> _enterPayment(double totalAfterDiscount) async {
    final t = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final balance = widget.cart.selectedCustomer?.balance ?? 0.0;

    double past = balance < 0 ? -balance : balance;
    past = double.parse(past.toStringAsFixed(2));

    double totalDue =
        balance < 0 ? totalAfterDiscount + past : totalAfterDiscount - past;
    totalDue = double.parse(totalDue.toStringAsFixed(2));

    final totalBeforeDiscount = widget.cart.total;
    final discountPercent = widget.cart.discountPercent;
    final discountAmount = widget.cart.discountAmount;

    return showDialog<double>(
      context: context,
      builder: (_) {
        return Dialog(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.85,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          t.completeSale,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // TABLE
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Table(
                          border: TableBorder.all(color: Colors.black, width: 1),
                          columnWidths: const {
                            0: FlexColumnWidth(2),
                            1: FlexColumnWidth(1),
                          },
                          children: [
                            TableRow(children: [
                               Padding(
                                padding: EdgeInsets.all(8),
                                child: Text(t.totalBeforeDiscount),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(totalBeforeDiscount.toStringAsFixed(2)),
                              ),
                            ]),
                            TableRow(children: [
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  "${t.discountAmount} (${discountPercent.toStringAsFixed(2)}%)",
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text("-${discountAmount.toStringAsFixed(2)}"),
                              ),
                            ]),
                            TableRow(children: [
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(t.totalAfterDiscount),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(totalAfterDiscount.toStringAsFixed(2)),
                              ),
                            ]),
                            TableRow(children: [
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  balance > 0 ? t.previousBalance : t.previousDebt,
                                  style: TextStyle(
                                    color: balance > 0 ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(past.toStringAsFixed(2)),
                              ),
                            ]),
                            TableRow(children: [
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(t.totalDue),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(totalDue.toStringAsFixed(2)),
                              ),
                            ]),
                          ],
                        ),
                      ),

                      // PAYMENT FIELD
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: TextField(
                          controller: controller,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: t.paid),
                        ),
                      ),

                      // OK BUTTON (INSIDE SCROLL)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(
                              context,
                              double.tryParse(controller.text) ?? 0.0,
                            );
                          },
                          child: Text(t.ok),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _completeSale() async {
    final t = AppLocalizations.of(context)!;
    final cart = widget.cart;
// ⭐ LIMIT: Only 5 sales allowed if NOT activated
final activated = await ActivationService.isActivated();
final saleCount = await ActivationService.getSalesCount();

if (!activated && saleCount >= 5) {
  if (!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(t.limitSales)),
  );
  return;
}

    if (cart.selectedCustomer == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.selectCustomerBeforeSale)),
      );
      return;
    }

    Customer customer = cart.selectedCustomer!;
    final totalBeforeDiscount = cart.total;
    final totalAfterDiscount = cart.totalAfterDiscount;

    final paid = await _enterPayment(totalAfterDiscount);
    if (paid == null) return;

    final previousBalance = customer.balance;
    final newBalance = customer.balance - totalAfterDiscount + paid;

    final itemsSnapshot = List<CartItem>.from(cart.items);
    final saleDateTime = DateTime.now().toIso8601String();

    setState(() => _saving = true);

    final db = await AppDatabase.instance.database;
    final paymentsDao = CustomerPaymentsDao();

    int saleId = 0;

    try {
      await db.transaction((txn) async {
        if (customer.id == null) {
          final newId = await txn.insert('customers', customer.toMap());

          customer = Customer(
            id: newId,
            name: customer.name,
            phone: customer.phone,
            address: customer.address,
            notes: customer.notes,
            balance: customer.balance,
            initialBalance: customer.initialBalance,
            initialBalanceDate: customer.initialBalanceDate,
          );

          cart.selectedCustomer = customer;
        }

        saleId = await txn.insert('sales', {
          'datetime': saleDateTime,
          'total': totalAfterDiscount,
          'paid': paid,
          'balance': newBalance,
          'customer_id': customer.id,
          'discount_percent': cart.discountPercent,
          'discount_amount': cart.discountAmount,
          // ⭐ NEW STATIC FIELDS
  'balance_before_sale': previousBalance,
  'balance_after_sale': newBalance,
        });
        // ⭐ INCREMENT SALE COUNTER
           await ActivationService.incrementSale();

        for (final item in cart.items) {
          await txn.insert('sale_items', {
            'sale_id': saleId,
            'product_id': item.product.id,
            'qty': item.qty,
            'price': item.price,
          });

          final newStock = item.product.stock - item.qty;

          await txn.update(
            'products',
            {'stock': newStock},
            where: 'id = ?',
            whereArgs: [item.product.id],
          );

          // 🔹 SAVE LAST PRICE LEVEL FOR THIS CUSTOMER & PRODUCT
          if (customer.id != null && item.product.id != null) {
            int priceLevel;
            if (item.price == item.product.sellPrice1) {
              priceLevel = 1;
            } else if (item.price == item.product.sellPrice2) {
              priceLevel = 2;
            } else {
              priceLevel = 3;
            }

            final existing = await txn.query(
              'customer_product_prices',
              where: 'customer_id = ? AND product_id = ?',
              whereArgs: [customer.id, item.product.id],
              limit: 1,
            );

            if (existing.isEmpty) {
              await txn.insert('customer_product_prices', {
                'customer_id': customer.id,
                'product_id': item.product.id,
                'price_level': priceLevel,
              });
            } else {
              await txn.update(
                'customer_product_prices',
                {'price_level': priceLevel},
                where: 'customer_id = ? AND product_id = ?',
                whereArgs: [customer.id, item.product.id],
              );
            }
          }
        }

        await txn.update(
          'customers',
          {'balance': newBalance},
          where: 'id = ?',
          whereArgs: [customer.id],
        );

        await txn.insert('balance_history', {
          'customer_id': customer.id!,
          'change': -totalAfterDiscount + paid,
          'new_balance': newBalance,
          'note': "Sale #$saleId",
          'datetime': DateTime.now().toIso8601String(),
        });
      });
    } catch (e) {
      setState(() => _saving = false);
      showActivationError(context, e);
      return;
    }

    final shouldPrint = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(t.printReceipt),
          content: Text(t.printReceiptQuestion),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(t.skip),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(t.yes),
            ),
          ],
        );
      },
    );

    if (shouldPrint == true) {
      await _printOptions(
        items: itemsSnapshot,
        customer: customer,
        totalBeforeDiscount: totalBeforeDiscount,
        totalAfterDiscount: totalAfterDiscount,
        discountPercent: cart.discountPercent,
        discountAmount: cart.discountAmount,
        paid: paid,
        balance: newBalance,
        saleDateTime: saleDateTime,
        saleId: saleId,
        t: t,
      );
    }

    await paymentsDao.addPaidDuringSale(
  customerId: customer.id!,
  amount: paid,
  saleId: saleId,
);

    cart.items.clear();
    cart.selectedCustomer = null;
    cart.discountPercent = 0.0;

    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.pop(context, true);
  }

  Future<void> _printOptions({
    required List<CartItem> items,
    required Customer customer,
    required double totalBeforeDiscount,
    required double totalAfterDiscount,
    required double discountPercent,
    required double discountAmount,
    required double paid,
    required double balance,
    required String saleDateTime,
    required int saleId,
    required AppLocalizations t,
  }) async {
    await ReceiptService.loadSavedPrinter();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: DefaultTabController(
            length: 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Text(
                  t.saleCompletedPrint,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                TabBar(
                  labelColor: Theme.of(context).primaryColor,
                  tabs: const [
                    Tab(text: "A4"),
                    Tab(text: "80mm"),
                  ],
                ),
                SizedBox(
                  height: 300, // enough space for buttons
                  child: TabBarView(
                    children: [
                      // --- A4 Buttons ---
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                Navigator.of(context, rootNavigator: true).pop();
                                await ReceiptService.previewSalePdfA4(
                                  items: items,
                                  customer: customer,
                                  totalBeforeDiscount: totalBeforeDiscount,
                                  totalAfterDiscount: totalAfterDiscount,
                                  discountPercent: discountPercent,
                                  discountAmount: discountAmount,
                                  paid: paid,
                                  balance: balance,
                                  saleDateTime: saleDateTime,
                                  saleId: saleId,
                                  t: t,
                                );
                              },
                              child: Text("📄 ${t.pdf} (${t.previewPdf})"),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                Navigator.of(context, rootNavigator: true).pop();
                                await ReceiptService.shareSalePdfA4(
                                  items: items,
                                  customer: customer,
                                  totalBeforeDiscount: totalBeforeDiscount,
                                  totalAfterDiscount: totalAfterDiscount,
                                  discountPercent: discountPercent,
                                  discountAmount: discountAmount,
                                  paid: paid,
                                  balance: balance,
                                  saleDateTime: saleDateTime,
                                  saleId: saleId,
                                  t: t,
                                );
                              },
                              child: Text("📤 ${t.share} PDF"),
                            ),
                          ],
                        ),
                      ),

                      // --- 80mm Buttons ---
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                Navigator.of(context, rootNavigator: true).pop();
                                await ReceiptService.previewSalePdf(
                                  items: items,
                                  customer: customer,
                                  totalBeforeDiscount: totalBeforeDiscount,
                                  totalAfterDiscount: totalAfterDiscount,
                                  discountPercent: discountPercent,
                                  discountAmount: discountAmount,
                                  paid: paid,
                                  balance: balance,
                                  saleDateTime: saleDateTime,
                                  saleId: saleId,
                                  t: t,
                                );
                              },
                              child: Text("📄 ${t.pdf} (${t.previewPdf})"),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                Navigator.of(context, rootNavigator: true).pop();
                                await ReceiptService.saveSalePdf(
                                  items: items,
                                  customer: customer,
                                  totalBeforeDiscount: totalBeforeDiscount,
                                  totalAfterDiscount: totalAfterDiscount,
                                  discountPercent: discountPercent,
                                  discountAmount: discountAmount,
                                  paid: paid,
                                  balance: balance,
                                  saleDateTime: saleDateTime,
                                  saleId: saleId,
                                  t: t,
                                );
                              },
                              child: Text("💾 ${t.save} PDF"),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                Navigator.of(context, rootNavigator: true).pop();
                                await ReceiptService.shareSalePdf(
                                  items: items,
                                  customer: customer,
                                  totalBeforeDiscount: totalBeforeDiscount,
                                  totalAfterDiscount: totalAfterDiscount,
                                  discountPercent: discountPercent,
                                  discountAmount: discountAmount,
                                  paid: paid,
                                  balance: balance,
                                  saleDateTime: saleDateTime,
                                  saleId: saleId,
                                  t: t,
                                );
                              },
                              child: Text("📤 ${t.share} PDF"),
                            ),
                            ElevatedButton(
  onPressed: () async {
    Navigator.of(context, rootNavigator: true).pop();
    try {
      await EscposReceiptService.printSaleReceipt(
        items: items,
        customer: customer,
        totalBeforeDiscount: totalBeforeDiscount,
        totalAfterDiscount: totalAfterDiscount,
        discountPercent: discountPercent,
        discountAmount: discountAmount,
        paid: paid,
        balance: balance,
        saleDateTime: saleDateTime,
        saleId: saleId,
        t: t,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Printer not connected")),
      );
    }
  },
  child: Text("🖨️ ${t.print} (Bluetooth)"),
),

                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () =>
                      Navigator.of(context, rootNavigator: true).pop(),
                  child: Text(t.skip),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cart = widget.cart;

    final title =
        "${t.checkout} — ${cart.selectedCustomer?.name ?? t.noCustomer}";

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                children: cart.items.map((i) {
                  return ListTile(
                    title: Text(i.product.name),
                    subtitle:
                        Text("${t.qty}: ${i.qty}  ${t.price}: ${i.price}"),
                    trailing: Text(i.lineTotal.toStringAsFixed(2)),
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    "${t.total}: ${cart.total.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${t.discountAmount} (${cart.discountPercent.toStringAsFixed(2)}%): -${cart.discountAmount.toStringAsFixed(2)}",
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${t.totalAfterDiscount}: ${cart.totalAfterDiscount.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _saving ? null : _completeSale,
                    child: _saving
                        ? const CircularProgressIndicator()
                        : Text(t.completeSale),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
