import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'receipt_service.dart';
import '../models/cart_item.dart';
import '../models/customer.dart';
import '../services/settings_service.dart';
import '../utils/date_format.dart';
import '../generated/app_localizations.dart';

class EscposReceiptService {
  EscposReceiptService._();
static String formatArabicBalance(double value) {
  if (value.abs() < 0.0001) {
    return "0"; // zero → no prefix
  } else if (value < 0) {
    return "عليه ${value.toStringAsFixed(2)}"; // negative
  } else {
    return "له ${value.toStringAsFixed(2)}"; // positive
  }
}

  static final BlueThermalPrinter _bluetooth = BlueThermalPrinter.instance;
  static final SettingsService _settings = SettingsService();

  // ------------------------------------------------------------
  // Helpers
  // ------------------------------------------------------------

  static bool _containsArabic(String text) {
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    return arabicRegex.hasMatch(text);
  }

  static Future<Uint8List> _renderLineImage(
    String text, {
    double fontSize = 26,
    bool rtl = false,
    double maxWidth = 550,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final paragraphStyle = ui.ParagraphStyle(
      textDirection: rtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      fontSize: fontSize,
      maxLines: 1,
    );

    final textStyle = ui.TextStyle(color: Colors.black);

    final builder = ui.ParagraphBuilder(paragraphStyle)
      ..pushStyle(textStyle)
      ..addText(text);

    final paragraph = builder.build()
      ..layout(ui.ParagraphConstraints(width: maxWidth));

    final width = paragraph.maxIntrinsicWidth.ceil();
    final height = paragraph.height.ceil();

    canvas.drawColor(Colors.white, BlendMode.src);
    canvas.drawParagraph(paragraph, const Offset(0, 0));

    final picture = recorder.endRecording();
    final img = await picture.toImage(width, height);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }

  // ------------------------------------------------------------
  // Ensure Bluetooth Connection
  // ------------------------------------------------------------
  static Future<bool> _ensureConnected() async {
    final isConnected = await _bluetooth.isConnected ?? false;

    if (!isConnected) {
      await ReceiptService.loadSavedPrinter();
    }

    return await _bluetooth.isConnected ?? false;
  }

  static void _separator() {
    _bluetooth.printCustom("--------------------------------", 1, 1);
  }

  static Future<void> _printLocalizedLine(String text, bool rtl) async {
    if (_containsArabic(text)) {
      final img = await _renderLineImage(text, rtl: rtl);
      await _bluetooth.printImageBytes(img);
    } else {
      _bluetooth.printCustom(text, 1, rtl ? 2 : 0);
    }
  }

  // ------------------------------------------------------------
  // SALE RECEIPT
  // ------------------------------------------------------------
  static Future<void> printSaleReceipt({
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
    if (!await _ensureConnected()) {
      throw Exception("Printer not connected");
    }

    final rtl = _settings.language == "ar";
    final storeName = _settings.storeName.isEmpty ? t.storeName : _settings.storeName;

    await _printLocalizedLine(t.saleReceipt, rtl);
    await _printLocalizedLine("${t.storeName}: $storeName", rtl);
    await _printLocalizedLine("${t.saleId}: $saleId", rtl);
    await _printLocalizedLine("${t.customer}: ${customer.name}", rtl);
    await _printLocalizedLine("${t.date}: ${formatDateTimeReceipt(saleDateTime)}", rtl);

    _separator();
    await _printLocalizedLine("${t.item}   ${t.qty}   ${t.price}   ${t.total}", rtl);

    for (final item in items) {
      await _printLocalizedLine(item.product.name, rtl);
      _bluetooth.printCustom(
        "x${item.qty}   ${item.price.toStringAsFixed(2)}   ${item.lineTotal.toStringAsFixed(2)}",
        1,
        0,
      );
    }

    _separator();
    _bluetooth.printLeftRight(t.totalBeforeDiscount, totalBeforeDiscount.toStringAsFixed(2), 1);
    _bluetooth.printLeftRight(t.discount, "${discountPercent.toStringAsFixed(2)}% (${discountAmount.toStringAsFixed(2)})", 1);
   _bluetooth.printLeftRight(
  t.pastBalance,
  formatArabicBalance(balance + totalAfterDiscount - paid),
  1,
);

    _bluetooth.printLeftRight(t.paid, paid.toStringAsFixed(2), 1);
   _bluetooth.printLeftRight(
  t.balance,
  formatArabicBalance(balance),
  1,
);


    _bluetooth.printNewLine();
    await _printLocalizedLine(t.thankYou, rtl);
    _bluetooth.paperCut();
  }

  // ------------------------------------------------------------
  // RETURN RECEIPT
  // ------------------------------------------------------------
  static Future<void> printReturnReceipt({
    required List<Map<String, dynamic>> items,
    required double refundTotal,
    required String reason,
    required bool restock,
    required bool refund,
    required int originalSaleId,
    required String originalSaleDate,
    required Customer customer,
    required AppLocalizations t,
  }) async {
    if (!await _ensureConnected()) {
      throw Exception("Printer not connected");
    }

    final rtl = _settings.language == "ar";

    await _printLocalizedLine(t.returnReceipt, rtl);
    await _printLocalizedLine("${t.customer}: ${customer.name}", rtl);
    await _printLocalizedLine("${t.originalSaleId}: $originalSaleId", rtl);
    await _printLocalizedLine("${t.saleDate}: ${formatDateTimeReceipt(originalSaleDate)}", rtl);

    _separator();
    await _printLocalizedLine(t.returnedItems, rtl);

    for (final item in items) {
      await _printLocalizedLine(item["name"], rtl);
      _bluetooth.printCustom(
        "x${item["qty"]}   ${(item["price"] as num).toStringAsFixed(2)}   ${(item["total"] as num).toStringAsFixed(2)}",
        1,
        0,
      );
    }

    _separator();
    await _printLocalizedLine("${t.refundTotal}: ${refundTotal.toStringAsFixed(2)}", rtl);
    await _printLocalizedLine("${t.reason}: $reason", rtl);
    await _printLocalizedLine("${t.restock}: ${restock ? t.yes : t.no}", rtl);
    await _printLocalizedLine("${t.refund}: ${refund ? t.yes : t.no}", rtl);

    _bluetooth.printNewLine();
    await _printLocalizedLine(t.thankYou, rtl);
    _bluetooth.paperCut();
  }

  // ------------------------------------------------------------
  // PAYMENT RECEIPT (Customer pays debt)
  // ------------------------------------------------------------
static Future<void> printPaymentReceipt({
  required Customer customer,
  required Map<String, dynamic> payment,
  required AppLocalizations t,
}) async {
  if (!await _ensureConnected()) {
    throw Exception("Printer not connected");
  }

  final rtl = _settings.language == "ar";

  final amount = (payment['amount'] as num).toDouble();
  final note = payment['note'] ?? "";
  final receiptId = payment['id'];
  final date = formatDateTimeReceipt(payment['datetime']);
  final currentBalance = customer.balance;
  final pastBalance = currentBalance - amount;

  final type = (payment['type'] ?? '').toString();

  // ✅ Fix: choose the correct receipt title
  if (type == "give_cash") {
    await _printLocalizedLine(t.cashOutReceipt, rtl);
  } else if (type == "pay_debt") {
    await _printLocalizedLine(t.paymentReceipt, rtl);
  } else if (type == "return") {
    await _printLocalizedLine(t.returnReceipt, rtl);
  } else {
    await _printLocalizedLine(t.paymentReceipt, rtl);
  }

  await _printLocalizedLine("${t.receiptId}: $receiptId", rtl);
  await _printLocalizedLine("${t.customer}: ${customer.name}", rtl);
  await _printLocalizedLine("${t.date}: $date", rtl);

  _separator();

  // ✅ Fix: choose the correct header sentence
  String header;
  if (type == "give_cash") {
    header = t.cashOutSentence(customer.name, amount.abs().toStringAsFixed(2));
  } else if (type == "pay_debt") {
    header = t.paymentSentence(customer.name, amount.toStringAsFixed(2));
  } else if (type == "return") {
    header = t.returnNote;
  } else {
    header = t.paymentAdded;
  }

  await _printLocalizedLine(header, rtl);

  if (note.toString().isNotEmpty) {
    await _printLocalizedLine("${t.note}: $note", rtl);
  }

  _separator();
 await _printLocalizedLine(
  "${t.pastBalance}: ${formatArabicBalance(pastBalance)}",
  rtl,
);

await _printLocalizedLine(
  "${t.currentBalance}: ${formatArabicBalance(currentBalance)}",
  rtl,
);


  _bluetooth.printNewLine();
  _bluetooth.paperCut();
}



  // ------------------------------------------------------------
  // CASH OUT RECEIPT (You give cash to customer)
  // ------------------------------------------------------------
  static Future<void> printCashOutReceipt({
    required Customer customer,
    required double amount,
    required String reason,
    required String datetime,
    required int payoutId,
    required AppLocalizations t,
  }) async {
    if (!await _ensureConnected()) {
      throw Exception("Printer not connected");
    }

    final rtl = _settings.language == "ar";

    await _printLocalizedLine(t.cashOutReceipt, rtl);
    await _printLocalizedLine("${t.operationId}: $payoutId", rtl);
    await _printLocalizedLine("${t.customer}: ${customer.name}", rtl);
    await _printLocalizedLine("${t.date}: ${formatDateTimeReceipt(datetime)}", rtl);

    _separator();
    await _printLocalizedLine(
  t.cashOutSentence(customer.name, amount.abs().toStringAsFixed(2)),
  rtl,
);

    await _printLocalizedLine("${t.reason}: $reason", rtl);

    _bluetooth.printNewLine();
    await _printLocalizedLine(t.signatureLine, rtl);
    _bluetooth.paperCut();
  }
}
