import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../utils/date_format.dart';
import '../generated/app_localizations.dart';

import '../services/receipt_service.dart';
import '../services/settings_service.dart';
import '../models/cart_item.dart';
import '../models/customer.dart';
import '../models/product.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/escpos_receipt_service.dart';

class ReceiptPage extends StatefulWidget {
  final int saleId;

  const ReceiptPage({super.key, required this.saleId});

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  Map<String, dynamic>? sale;
  List<Map<String, dynamic>> items = [];
  Customer? customer;

  @override
  void initState() {
    super.initState();
    _loadReceipt();
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

  Future<void> _loadReceipt() async {
    final db = await AppDatabase.instance.database;

    final saleResult = await db.query(
      'sales',
      where: 'id = ?',
      whereArgs: [widget.saleId],
    );

    final itemResult = await db.rawQuery('''
      SELECT sale_items.*, products.name, products.purchase_price,
             products.sell_price1, products.sell_price2, products.sell_price3,
             products.unit, products.barcode, products.category
      FROM sale_items
      JOIN products ON sale_items.product_id = products.id
      WHERE sale_items.sale_id = ?
    ''', [widget.saleId]);

    final customerResult = await db.query(
      'customers',
      where: 'id = ?',
      whereArgs: [(saleResult.first['customer_id'] as num).toInt()],
    );

    setState(() {
      sale = saleResult.first;
      items = itemResult;

      customer = Customer(
        id: customerResult.first['id'] as int,
        name: customerResult.first['name'] as String,
        phone: customerResult.first['phone']?.toString() ?? "",
        balance: (customerResult.first['balance'] as num).toDouble(),
        initialBalance:
            (customerResult.first['initial_balance'] as num?)?.toDouble() ?? 0,
        initialBalanceDate:
            customerResult.first['initial_balance_date']?.toString(),
      );
    });
  }

  List<CartItem> _convertToCartItems() {
    return items.map((row) {
      return CartItem(
        product: Product(
          id: row['product_id'],
          name: row['name'],
          purchasePrice: (row['purchase_price'] as num).toDouble(),
          sellPrice1: (row['sell_price1'] as num).toDouble(),
          sellPrice2: (row['sell_price2'] as num).toDouble(),
          sellPrice3: (row['sell_price3'] as num).toDouble(),
          stock: 0,
          unit: row['unit'] ?? "pieces",
          barcode: row['barcode'] ?? "",
          category: row['category'],
        ),
        qty: row['qty'],
        price: (row['price'] as num).toDouble(),
        priceLevel: 0,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    if (sale == null || customer == null) {
      return Scaffold(
        appBar: AppBar(title: Text(t.receipt)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final settings = SettingsService();
    final rawStoreName =
        settings.storeName.isEmpty ? t.storeReceipt : settings.storeName;
    final storeName = "متجر $rawStoreName";

    final cartItems = _convertToCartItems();

    // -----------------------------
    // DISCOUNT VALUES
    // -----------------------------
    final double totalBeforeDiscount =
        (sale!['total_before_discount'] ?? sale!['total'] as num).toDouble();

    final double discountPercent =
        (sale!['discount_percent'] as num?)?.toDouble() ?? 0.0;

    final double discountAmount =
        (sale!['discount_amount'] as num?)?.toDouble() ??
            (totalBeforeDiscount * (discountPercent / 100));

    final double totalAfterDiscount =
        (sale!['total'] as num).toDouble(); // already stored in DB

    final paid = (sale!['paid'] as num?)?.toDouble() ?? 0.0;

// ⭐ NEW — STATIC BALANCES
final balanceBefore = (sale!['balance_before_sale'] as num?)?.toDouble() ?? 0.0;
final balanceAfter = (sale!['balance_after_sale'] as num?)?.toDouble() ?? 0.0;





    return Scaffold(
      appBar: AppBar(
        title: Text(t.receipt),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () async {
              await EscposReceiptService.printSaleReceipt(
  items: cartItems,
  customer: customer!,
  totalBeforeDiscount: totalBeforeDiscount,
  totalAfterDiscount: totalAfterDiscount,
  discountPercent: discountPercent,
  discountAmount: discountAmount,
  paid: paid,
   balance: balanceAfter,
  saleDateTime: sale!['datetime'],
  saleId: widget.saleId,
  t: t,
);


              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(t.printing)),
              );
            },
          )
        ],
      ),
      body: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                storeName,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                "فاتورة رقم: ${sale!['id']}",
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                "${t.customer}: ${customer!.name}",
                style: const TextStyle(fontSize: 16),
              ),
              const Divider(),
              Text(formatDateTimeUI(sale!['datetime'])),
              const SizedBox(height: 10),
              const Divider(),
              Text(
                t.items,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Header row
              Row(
                children: const [
                  Expanded(
                    flex: 4,
                    child: Text(
                      "المادة",
                      textAlign: TextAlign.right,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "الكمية",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "السعر",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "الإجمالي",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const Divider(),

              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    final lineTotal = item.qty * item.price;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Text(
                              item.product.name,
                              textAlign: TextAlign.right,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              item.qty.toString(),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              item.price.toStringAsFixed(2),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              lineTotal.toStringAsFixed(2),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const Divider(),
           Text("${t.total}: ${totalBeforeDiscount.toStringAsFixed(2)}"),
Text("${t.discountAmount}: -${discountAmount.toStringAsFixed(2)}"),
Text("${t.totalAfterDiscount}: ${totalAfterDiscount.toStringAsFixed(2)}"),
Text("${t.paid}: ${paid.toStringAsFixed(2)}"),

// NEW — Past Balance
Text("${t.pastBalance}: ${balanceBefore.toStringAsFixed(2)}"),
Text("${t.currentBalance}: ${formatArabicBalance(balanceAfter)}"),




              const SizedBox(height: 20),
ElevatedButton.icon(
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.green,
    foregroundColor: Colors.white,
    minimumSize: const Size(double.infinity, 50),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(40),
    ),
  ),
 icon: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white, size: 18),

  label: Text(t.shareWhatsApp, style: const TextStyle(fontSize: 16)),
  onPressed: () async {
    await ReceiptService.shareSalePdfWhatsApp(
      items: cartItems,
      customer: customer!,
      totalBeforeDiscount: totalBeforeDiscount,
      totalAfterDiscount: totalAfterDiscount,
      discountPercent: discountPercent,
      discountAmount: discountAmount,
      paid: paid,
        balance: balanceAfter,
      saleDateTime: sale!['datetime'],
      saleId: widget.saleId,
      t: t,
    );
  },
),

              SafeArea(
                minimum: const EdgeInsets.only(bottom: 20),
                
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf),
                  label: Text(t.previewPdf),
                  onPressed: () async {
                    await ReceiptService.previewSalePdfA4(
                      items: cartItems,
                      customer: customer!,
                      totalBeforeDiscount: totalBeforeDiscount,
                      totalAfterDiscount: totalAfterDiscount,
                      discountPercent: discountPercent,
                      discountAmount: discountAmount,
                      paid: paid,
                      balance: balanceAfter,
                      saleDateTime: sale!['datetime'],
                      saleId: widget.saleId,
                      t: t,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
