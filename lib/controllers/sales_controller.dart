import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

import '../models/cart_item.dart';      // <-- THIS is the important one
import '../models/product.dart';        // optional, only if needed


class SalesController {
  Future<void> saveSale({
    required int saleNumber,
    required String customer,
    required double total,
    required double discount,
    required double paid,
    required List<CartItem> items,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['Sale'];

    sheet.appendRow(['Sale Number', saleNumber.toString()]);
    sheet.appendRow(['Date', DateTime.now().toString()]);
    sheet.appendRow(['Customer', customer]);
    sheet.appendRow(['Total', total.toStringAsFixed(2)]);
    sheet.appendRow(['Discount', discount.toStringAsFixed(2)]);
    sheet.appendRow(['Paid', paid.toStringAsFixed(2)]);
    sheet.appendRow(['Remaining', (total - discount - paid).toStringAsFixed(2)]);

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

    final filePath = '${salesDir.path}/sale_$saleNumber.xlsx';
    final fileBytes = excel.encode();

    if (fileBytes != null) {
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);
    }
  }
  
}
