import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

class CustomerCreditController {
  Future<void> addCredit({
    required String customer,
    required int saleNumber,
    required double amount,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final creditDir = Directory('${dir.path}/credits');

    if (!await creditDir.exists()) {
      await creditDir.create(recursive: true);
    }

    final safeName = customer.replaceAll(' ', '_');
    final filePath = '${creditDir.path}/$safeName.xlsx';

    Excel excel;

    if (await File(filePath).exists()) {
      final bytes = File(filePath).readAsBytesSync();
      excel = Excel.decodeBytes(bytes);
    } else {
      excel = Excel.createExcel();
    }

    final sheet = excel['Credit'];

    if (sheet.rows.isEmpty) {
      sheet.appendRow(['Date', 'Sale Number', 'Amount Owed']);
    }

    sheet.appendRow([
      DateTime.now().toString(),
      saleNumber.toString(),
      amount.toStringAsFixed(2),
    ]);

    final fileBytes = excel.encode();
    if (fileBytes != null) {
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);
    }
  }
}
