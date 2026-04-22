import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

import '../models/cart_item.dart';
import '../db/sales_dao.dart';
import '../db/sale_items_dao.dart';

class SalesController {
  final SalesDao _salesDao = SalesDao();
  final SaleItemsDao _saleItemsDao = SaleItemsDao();

  /// Save sale to DATABASE + export Excel
  ///
  /// Returns the new saleId.
  Future<int> saveSale({
    required int? customerId,
    required double total,        // total AFTER discount
    required double discount,     // discount percent
    required double paid,
    required List<CartItem> items,
  }) async {
    // --------------------------------------------
    // 1) CALCULATE DISCOUNT AMOUNT & BALANCE
    // --------------------------------------------
    final double discountAmount = total * (discount / 100);
    final double totalAfterDiscount = total - discountAmount;
    final double balance = totalAfterDiscount - paid;

    // --------------------------------------------
    // 2) SAVE SALE HEADER
    // --------------------------------------------
    final saleId = await _salesDao.insertSale(
      total: totalAfterDiscount,     // AFTER discount
      discountPercent: discount,
      discountAmount: discountAmount,
      paid: paid,
      balance: balance,
      customerId: customerId,
    );

    // --------------------------------------------
    // 3) SAVE SALE ITEMS
    // --------------------------------------------
    for (final item in items) {
      final product = item.product;
      if (product.id == null) continue;

      await _saleItemsDao.insertSaleItem(
        saleId: saleId,
        productId: product.id!,
        qty: item.qty,
        price: item.price,
      );
    }

    // --------------------------------------------
    // 4) OPTIONAL: EXPORT EXCEL
    // --------------------------------------------
    await _exportSaleToExcel(
      saleId: saleId,
      customerId: customerId,
      total: totalAfterDiscount,
      discount: discountAmount,
      paid: paid,
      items: items,
    );

    return saleId;
  }

  Future<void> _exportSaleToExcel({
    required int saleId,
    required int? customerId,
    required double total,
    required double discount,
    required double paid,
    required List<CartItem> items,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['Sale'];

    sheet.appendRow(['Sale Number', saleId.toString()]);
    sheet.appendRow(['Date', DateTime.now().toString()]);
    sheet.appendRow(['Customer ID', customerId?.toString() ?? 'Walk-in']);
    sheet.appendRow(['Total (After Discount)', total.toStringAsFixed(2)]);
    sheet.appendRow(['Discount Amount', discount.toStringAsFixed(2)]);
    sheet.appendRow(['Paid', paid.toStringAsFixed(2)]);
    sheet.appendRow(['Remaining', (total - paid).toStringAsFixed(2)]);

    sheet.appendRow([]);
    sheet.appendRow(['Product', 'Qty', 'Price', 'Line Total']);

    for (final item in items) {
      sheet.appendRow([
        item.product.name,
        item.qty,
        item.price.toStringAsFixed(2),
        item.lineTotal.toStringAsFixed(2),
      ]);
    }

    final dir = await getApplicationDocumentsDirectory();
    final salesDir = Directory('${dir.path}/sales');

    if (!await salesDir.exists()) {
      await salesDir.create(recursive: true);
    }

    final filePath = '${salesDir.path}/sale_$saleId.xlsx';
    final fileBytes = excel.encode();

    if (fileBytes != null) {
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);
    }
  }
}
