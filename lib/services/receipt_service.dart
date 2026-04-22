// =========================
// PART 1 OF 5
// =========================

// -------------------------------------------------------------
// IMPORTS
// -------------------------------------------------------------
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/cart_item.dart';
import '../models/customer.dart';
import '../utils/date_format.dart';
import '../services/settings_service.dart';
import '../generated/app_localizations.dart';


// Helper to localize return reasons into Arabic
String _mapReasonToArabic(String reason) {
  switch (reason) {
    case "Expired":
      return "منتهي الصلاحية";
    case "Damaged":
      return "تالف";
    case "Wrong item":
      return "صنف خاطئ";
    case "Customer changed mind":
      return "العميل غيّر رأيه";
    case "Other":
      return "أخرى";
    default:
      return reason;
  }
}
class ReceiptService {
  // -------------------------------------------------------------
  // BLUETOOTH PRINTER
  // -------------------------------------------------------------
  static final BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  static BluetoothDevice? selectedDevice;

  static Future<void> savePrinter(BluetoothDevice device) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_printer_mac', device.address ?? "");
    selectedDevice = device;
  }

  static Future<void> loadSavedPrinter() async {
    final prefs = await SharedPreferences.getInstance();
    final mac = prefs.getString('saved_printer_mac');
    if (mac == null) return;

    final devices = await bluetooth.getBondedDevices();
    for (final d in devices) {
      if (d.address == mac) {
        selectedDevice = d;
        return;
      }
    }
  }
static String formatArabicBalance(double value) {
  if (value.abs() < 0.0001) {
    return "0";
  } else if (value < 0) {
    return "عليه ${value.toStringAsFixed(2)}";
  } else {
    return "له ${value.toStringAsFixed(2)}";
  }
}

  static Future<bool> autoConnect() async {
    if (selectedDevice == null) return false;
    try {
      await bluetooth.connect(selectedDevice!);
      return true;
    } catch (_) {
      return false;
    }
  }

  // -------------------------------------------------------------
  // ARABIC DETECTION
  // -------------------------------------------------------------
  static bool containsArabic(String text) {
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    return arabicRegex.hasMatch(text);
  }

  // -------------------------------------------------------------
  // TABLE HELPERS
  // -------------------------------------------------------------
 static pw.Widget _headerCell(String text, pw.Font font) {
  final isArabic = containsArabic(text);

  return pw.Container(
    padding: const pw.EdgeInsets.all(4),
    child: pw.Text(
      text,
      textDirection:
          isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
      textAlign: pw.TextAlign.center,
      style: pw.TextStyle(font: font, fontWeight: pw.FontWeight.bold),
    ),
  );
}



 static pw.Widget _cell(
  String text,
  pw.Font font, {
  bool center = false,
  bool alignRight = false,
}) {
  final isArabic = containsArabic(text);

  return pw.Container(
    padding: const pw.EdgeInsets.all(4),
    child: pw.Text(
      text,
      textDirection:
          isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
      textAlign: center
          ? pw.TextAlign.center
          : alignRight
              ? pw.TextAlign.right
              : pw.TextAlign.left,
      style: pw.TextStyle(font: font),
    ),
  );
}


  static pw.Widget _summaryRow(
      String label, double value, pw.Font font, bool rtl) {
    return pw.Directionality(
      textDirection: rtl ? pw.TextDirection.rtl : pw.TextDirection.ltr,
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(font: font, fontSize: 12)),
          pw.Text(
            value.toStringAsFixed(2),
            style: pw.TextStyle(font: font, fontSize: 12),
          ),
        ],
      ),
    );
  }


static Future<void> shareSalePdfWhatsApp({
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
  // Generate PDF bytes
  final pdfBytes = await generateSalePdfA4(
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

  // Save PDF to temp file
  final dir = await getTemporaryDirectory();
  final file = File("${dir.path}/sale_$saleId.pdf");
  await file.writeAsBytes(pdfBytes);

  // -------------------------------
  // SYRIAN WHATSAPP NUMBER LOGIC
  // -------------------------------
  String rawPhone = customer.phone?.trim() ?? "";
  String phone = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');

  // Convert 09XXXXXXXX → 9639XXXXXXXX
  if (phone.startsWith("09")) {
    phone = "963" + phone.substring(1);
  }

  try {
    if (phone.isNotEmpty) {
      final url = "https://wa.me/$phone";
      await Share.shareXFiles(
        [XFile(file.path)],
        text: url,
      );
    } else {
      // No phone → open WhatsApp share sheet without number
      await Share.shareXFiles(
        [XFile(file.path)],
        text: "${t.saleReceipt} #$saleId",
      );
    }
  } catch (e) {
    debugPrint("WhatsApp share failed: $e");
  }
}


  // =============================================================
 static Future<Uint8List> generateSalePdf80mm({
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
  final settings = SettingsService();
  final isArabic = settings.language == "ar";
final pastBalance = balance + totalAfterDiscount - paid;

  final arabicFont = pw.Font.ttf(
    await rootBundle.load("assets/fonts/NotoNaskhArabic-Regular.ttf"),
  );
  final englishFont = pw.Font.ttf(
    await rootBundle.load("assets/fonts/Roboto-Regular.ttf"),
  );

  pw.ImageProvider? logoImage;
  if (settings.storeLogoPath.isNotEmpty) {
    final file = File(settings.storeLogoPath);
    if (await file.exists()) {
      logoImage = pw.MemoryImage(await file.readAsBytes());
    }
  }

  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat(80 * PdfPageFormat.mm, double.infinity),
      margin: const pw.EdgeInsets.all(8),
      textDirection: isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
      build: (_) {
        return pw.Directionality(
          textDirection: isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
          child: pw.Column(
            crossAxisAlignment:
                isArabic ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
            children: [
              if (logoImage != null)
                pw.Center(child: pw.Image(logoImage!, height: 50)),
              pw.SizedBox(height: 6),

              // Store name
              pw.Container(
                width: double.infinity,
                alignment: isArabic ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
                child: pw.Text(
                  isArabic ? "متجر: ${settings.storeName}" : "Store: ${settings.storeName}",
                  style: pw.TextStyle(
                    font: isArabic ? arabicFont : englishFont,
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),

              // Customer
              pw.Container(
                width: double.infinity,
                alignment: isArabic ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
                child: pw.Text(
                  isArabic ? "العميل: ${customer.name}" : "Customer: ${customer.name}",
                  style: pw.TextStyle(
                    font: containsArabic(customer.name) ? arabicFont : englishFont,
                  ),
                ),
              ),

              // Invoice number
              pw.Container(
                width: double.infinity,
                alignment: isArabic ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
                child: pw.Text(
                  isArabic
                      ? "فاتورة مبيعات رقم $saleId"
                      : "Sale Invoice #$saleId",
                  style: pw.TextStyle(
                    font: isArabic ? arabicFont : englishFont,
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),

              // Date + Time using utils/date_format.dart
              pw.Container(
                width: double.infinity,
                alignment: isArabic ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
                child: pw.Text(
                  "${t.saleDate}: ${formatDateTimeReceipt(saleDateTime)}",
                  style: pw.TextStyle(font: isArabic ? arabicFont : englishFont),
                ),
              ),

              pw.SizedBox(height: 10),
              pw.Divider(),

              // Items table
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: isArabic
                    ? {
                        0: pw.FlexColumnWidth(2.5), // Total
                        1: pw.FlexColumnWidth(2),   // Price
                        2: pw.FlexColumnWidth(2),   // Qty
                        3: pw.FlexColumnWidth(4),   // Item
                      }
                    : {
                        0: pw.FlexColumnWidth(4),   // Item
                        1: pw.FlexColumnWidth(2),   // Qty
                        2: pw.FlexColumnWidth(2),   // Price
                        3: pw.FlexColumnWidth(2.5), // Total
                      },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                    children: isArabic
                        ? [
                            _headerCell("الإجمالي", arabicFont),
                            _headerCell("السعر", arabicFont),
                            _headerCell("الكمية", arabicFont),
                            _headerCell("المادة", arabicFont),
                          ]
                        : [
                            _headerCell("Item", englishFont),
                            _headerCell("Qty", englishFont),
                            _headerCell("Price", englishFont),
                            _headerCell("Total", englishFont),
                          ],
                  ),
                  ...items.map((i) {
                    final lineTotal = i.qty * i.price;
                    final isArabicName = containsArabic(i.product.name);

                    return pw.TableRow(
                      children: isArabic
                          ? [
                              _cell(lineTotal.toStringAsFixed(2), arabicFont, center: true),
                              _cell(i.price.toStringAsFixed(2), arabicFont, center: true),
                              _cell(i.qty.toString(), arabicFont, center: true),
                              _cell(i.product.name,
                                  isArabicName ? arabicFont : englishFont,
                                  alignRight: true),
                            ]
                          : [
                              _cell(i.product.name, englishFont),
                              _cell(i.qty.toString(), englishFont, center: true),
                              _cell(i.price.toStringAsFixed(2), englishFont, center: true),
                              _cell(lineTotal.toStringAsFixed(2), englishFont, alignRight: true),
                            ],
                    );
                  }),
                ],
              ),

              pw.SizedBox(height: 10),
              pw.Divider(),

              // Totals
              _summaryRow(
                  isArabic ? "أجمالي الفاتورة:" : "Sale Total:",
                  totalBeforeDiscount,
                  isArabic ? arabicFont : englishFont,
                  true),
              _summaryRow(
                  isArabic
                      ? "الحسم ${discountPercent.toStringAsFixed(2)}%:"
                      : "Discount ${discountPercent.toStringAsFixed(2)}%:",
                  discountAmount,
                  isArabic ? arabicFont : englishFont,
                  true),
              _summaryRow(
                  isArabic ? "الإجمالي بعد الحسم:" : "Total After Discount:",
                  totalAfterDiscount,
                  isArabic ? arabicFont : englishFont,
                  true),
              _summaryRow(
                  isArabic ? "المبلغ المدفوع:" : "Paid:",
                  paid,
                  isArabic ? arabicFont : englishFont,
                  true),
             pw.Row(
  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  children: [
    pw.Text(
      isArabic ? "الرصيد السابق:" : "Past Balance:",
      style: pw.TextStyle(font: arabicFont, fontSize: 12),
    ),
    pw.Text(
      isArabic
          ? ReceiptService.formatArabicBalance(pastBalance)
          : pastBalance.toStringAsFixed(2),
      style: pw.TextStyle(font: arabicFont, fontSize: 12),
    ),
  ],
),


             pw.Row(
  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  children: [
    pw.Text(
      isArabic ? "الرصيد الحالي:" : "Remaining:",
      style: pw.TextStyle(font: arabicFont, fontSize: 12),
    ),
    pw.Text(
      isArabic
          ? ReceiptService.formatArabicBalance(balance)
          : balance.toStringAsFixed(2),
      style: pw.TextStyle(font: arabicFont, fontSize: 12),
    ),
  ],
),


              pw.SizedBox(height: 16),

              // Thank you stays centered
              pw.Center(
                child: pw.Text(
                  isArabic ? "شكراً لتسوقكم" : "Thank you!",
                  style: pw.TextStyle(font: isArabic ? arabicFont : englishFont),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );

  return pdf.save();
}


// =============================================================
// FIXED WRAPPER — 80mm
// =============================================================
static Future<Uint8List> generateSalePdf80mmWrapper({
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
  return generateSalePdf80mm(
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
    t: t, // <-- forward it
  );
}
// =========================
// PART 3 OF 5
// =========================

// =============================================================
// A4 SALE INVOICE — FULL PROFESSIONAL LAYOUT
// =============================================================
static Future<Uint8List> generateSalePdfA4({
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
  final settings = SettingsService();
  final isArabic = settings.language == "ar";
final pastBalance = balance + totalAfterDiscount - paid;

  final arabicFont = pw.Font.ttf(
    await rootBundle.load("assets/fonts/NotoNaskhArabic-Regular.ttf"),
  );
  final englishFont = pw.Font.ttf(
    await rootBundle.load("assets/fonts/Roboto-Regular.ttf"),
  );

  pw.ImageProvider? logoImage;
  if (settings.storeLogoPath.isNotEmpty) {
    final file = File(settings.storeLogoPath);
    if (await file.exists()) {
      logoImage = pw.MemoryImage(await file.readAsBytes());
    }
  }

  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(20),
      textDirection: isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
      build: (_) {
        return pw.Directionality(
          textDirection: isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
          child: pw.Column(
            crossAxisAlignment:
                isArabic ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
            children: [
              if (logoImage != null)
                pw.Center(child: pw.Image(logoImage!, height: 80)),
              pw.SizedBox(height: 10),

              // Store name
              pw.Container(
                width: double.infinity,
                alignment: isArabic ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
                child: pw.Text(
                  "${t.storeName}: ${settings.storeName}",
                  style: pw.TextStyle(
                    font: isArabic ? arabicFont : englishFont,
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),

              // Customer
              pw.Container(
                width: double.infinity,
                alignment: isArabic ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
                child: pw.Text(
                  "${t.customer}: ${customer.name}",
                  style: pw.TextStyle(
                    font: containsArabic(customer.name) ? arabicFont : englishFont,
                  ),
                ),
              ),

              // Invoice number
              pw.Container(
                width: double.infinity,
                alignment: isArabic ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
                child: pw.Text(
                  isArabic
                      ? "فاتورة مبيعات رقم $saleId"
                      : "Sale Invoice #$saleId",
                  style: pw.TextStyle(
                    font: isArabic ? arabicFont : englishFont,
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),

              // Date + Time using utils/date_format.dart
              pw.Container(
                width: double.infinity,
                alignment: isArabic ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
                child: pw.Text(
                  "${t.saleDate}: ${formatDateTimeReceipt(saleDateTime)}",
                  style: pw.TextStyle(font: isArabic ? arabicFont : englishFont),
                ),
              ),

              pw.SizedBox(height: 20),
              pw.Divider(),

              // Items table
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: isArabic
                    ? {
                        0: pw.FlexColumnWidth(2), // Total
                        1: pw.FlexColumnWidth(2), // Price
                        2: pw.FlexColumnWidth(2), // Qty
                        3: pw.FlexColumnWidth(4), // Item
                      }
                    : {
                        0: pw.FlexColumnWidth(4), // Item
                        1: pw.FlexColumnWidth(2), // Qty
                        2: pw.FlexColumnWidth(2), // Price
                        3: pw.FlexColumnWidth(2), // Total
                      },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                    children: isArabic
                        ? [
                            _headerCell("الإجمالي", arabicFont),
                            _headerCell("السعر", arabicFont),
                            _headerCell("الكمية", arabicFont),
                            _headerCell("المادة", arabicFont),
                          ]
                        : [
                            _headerCell("Item", englishFont),
                            _headerCell("Qty", englishFont),
                            _headerCell("Price", englishFont),
                            _headerCell("Total", englishFont),
                          ],
                  ),
                  ...items.map((i) {
                    final isArabicName = containsArabic(i.product.name);
                    final lineTotal = i.qty * i.price;

                    return pw.TableRow(
                      children: isArabic
                          ? [
                              _cell(lineTotal.toStringAsFixed(2), arabicFont, center: true),
                              _cell(i.price.toStringAsFixed(2), arabicFont, center: true),
                              _cell(i.qty.toString(), arabicFont, center: true),
                              _cell(i.product.name,
                                  isArabicName ? arabicFont : englishFont,
                                  alignRight: true),
                            ]
                          : [
                              _cell(i.product.name, englishFont),
                              _cell(i.qty.toString(), englishFont, center: true),
                              _cell(i.price.toStringAsFixed(2), englishFont, center: true),
                              _cell(lineTotal.toStringAsFixed(2), englishFont, alignRight: true),
                            ],
                    );
                  }),
                ],
              ),

              pw.SizedBox(height: 20),
              pw.Divider(),

              // Totals
              _summaryRow(
                  isArabic ? "أجمالي الفاتورة:" : "Total Before Discount:",
                  totalBeforeDiscount,
                  isArabic ? arabicFont : englishFont,
                  true),
              _summaryRow(
                  isArabic
                      ? "الحسم ${discountPercent.toStringAsFixed(2)}%:"
                      : "Discount ${discountPercent.toStringAsFixed(2)}%:",
                  discountAmount,
                  isArabic ? arabicFont : englishFont,
                  true),
              _summaryRow(
                  isArabic ? "الإجمالي بعد الحسم:" : "Total After Discount:",
                  totalAfterDiscount,
                  isArabic ? arabicFont : englishFont,
                  true),
              _summaryRow(
                  isArabic ? "المبلغ المدفوع:" : "Paid:",
                  paid,
                  isArabic ? arabicFont : englishFont,
                  true),
             pw.Row(
  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  children: [
    pw.Text(
      isArabic ? "الرصيد السابق:" : "Previous Balance:",
      style: pw.TextStyle(font: arabicFont, fontSize: 12),
    ),
    pw.Text(
      isArabic
          ? formatArabicBalance(pastBalance)
          : pastBalance.toStringAsFixed(2),
      style: pw.TextStyle(font: arabicFont, fontSize: 12),
    ),
  ],
),
pw.Row(
  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  children: [
    pw.Text(
      isArabic ? "الرصيد الحالي:" : "Current Balance:",
      style: pw.TextStyle(font: arabicFont, fontSize: 12),
    ),
    pw.Text(
      isArabic
          ? formatArabicBalance(balance)
          : balance.toStringAsFixed(2),
      style: pw.TextStyle(font: arabicFont, fontSize: 12),
    ),
  ],
),


              pw.SizedBox(height: 30),

              // Thank you stays centered
              pw.Center(
                child: pw.Text(
                  isArabic ? "شكراً لتسوقكم" : "Thank you for shopping",
                  style: pw.TextStyle(font: isArabic ? arabicFont : englishFont),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );

  return pdf.save();
}

// =============================================================
// FIXED WRAPPER — A4
// =============================================================
static Future<Uint8List> generateSalePdfA4Wrapper({
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
  return generateSalePdfA4(
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
}


  // Preview Sale PDF
  static Future<void> previewSalePdf({
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
    final pdfBytes = await generateSalePdfA4(
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

    await Printing.layoutPdf(onLayout: (format) async => pdfBytes);
  }

  // Save Sale PDF
  static Future<void> saveSalePdf({
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
    final pdfBytes = await generateSalePdfA4(
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

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/receipt_$saleId.pdf");
    await file.writeAsBytes(pdfBytes);
  }

  // Share Sale PDF
  static Future<void> shareSalePdf({
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
    final pdfBytes = await generateSalePdfA4(
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

    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: "receipt_$saleId.pdf",
    );
  }



// -------------------------------------------------------------
// SALE — PREVIEW A4
// -------------------------------------------------------------
static Future<void> previewSalePdfA4({
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
  final pdfBytes = await generateSalePdfA4Wrapper(
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

  await Printing.layoutPdf(
    onLayout: (format) async => pdfBytes,
  );
}

// -------------------------------------------------------------
// SALE — SHARE A4
// -------------------------------------------------------------
static Future<void> shareSalePdfA4({
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
  final pdfBytes = await generateSalePdfA4Wrapper(
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

  final dir = await getTemporaryDirectory();
  final file = File("${dir.path}/sale_$saleId.pdf");
  await file.writeAsBytes(pdfBytes);

  await Share.shareXFiles([XFile(file.path)], text: t.saleReceipt);
}
// =========================
// PART 4 OF 5
// =========================

// -------------------------------------------------------------
// SALE — BLUETOOTH PRINT (80mm)
// -------------------------------------------------------------
static Future<void> printSalePdfBluetooth({
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
  final isConnected = await bluetooth.isConnected ?? false;

  if (!isConnected) {
    if (selectedDevice == null) return;
    try {
      await bluetooth.connect(selectedDevice!);
    } catch (_) {
      return;
    }
  }

  final pdfBytes = await generateSalePdf80mmWrapper(
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
    t: t, // <-- forward it
  );

  await for (final page in Printing.raster(pdfBytes, dpi: 200)) {
    final png = await page.toPng();
    bluetooth.printImageBytes(png);
  }

  bluetooth.printNewLine();
  bluetooth.paperCut();
}

// -------------------------------------------------------------
// PART 3 — RETURN RECEIPTS (80mm + A4)
// -------------------------------------------------------------


// =============================================================
// A4 RETURN INVOICE
// =============================================================
static Future<Uint8List> generateReturnPdfA4({
  required List<Map<String, dynamic>> items,
  required double refundTotal,
  required String reason,
  required bool restock,
  required bool refund,
  required int originalSaleId,
  required String originalSaleDate,
  required AppLocalizations t,
  required Customer customer,
}) async {
  final settings = SettingsService();
  final isArabic = settings.language == "ar";

  final arabicFont = pw.Font.ttf(
    await rootBundle.load("assets/fonts/NotoNaskhArabic-Regular.ttf"),
  );
  final englishFont = pw.Font.ttf(
    await rootBundle.load("assets/fonts/Roboto-Regular.ttf"),
  );

  pw.ImageProvider? logoImage;
  if (settings.storeLogoPath.isNotEmpty) {
    final file = File(settings.storeLogoPath);
    if (await file.exists()) {
      logoImage = pw.MemoryImage(await file.readAsBytes());
    }
  }

  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(20),
      textDirection: isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
     build: (_) {
  return pw.Directionality(
    textDirection: pw.TextDirection.rtl,
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        if (logoImage != null)
          pw.Center(child: pw.Image(logoImage!, height: 80)),
        pw.SizedBox(height: 10),

        // Title stays centered
        pw.Center(
          child: pw.Text(
            t.returnReceipt,
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
              font: arabicFont,
            ),
          ),
        ),

        pw.SizedBox(height: 20),

        pw.Container(
  width: double.infinity,
  alignment: pw.Alignment.centerRight,
  child: pw.Text(
    "${t.customer}: ${customer.name}",
    style: pw.TextStyle(
      font: containsArabic(customer.name) ? arabicFont : englishFont,
    ),
  ),
),

pw.Container(
  width: double.infinity,
  alignment: pw.Alignment.centerRight,
  child: pw.Text(
    "${t.storeName}: ${settings.storeName}",
    style: pw.TextStyle(font: arabicFont),
  ),
),

pw.Container(
  width: double.infinity,
  alignment: pw.Alignment.centerRight,
  child: pw.Text(
    "${t.originalSaleId}: $originalSaleId",
    style: pw.TextStyle(font: arabicFont),
  ),
),

pw.Container(
  width: double.infinity,
  alignment: pw.Alignment.centerRight,
  child: pw.Text(
    "${t.saleDate}: ${formatDateTimeReceipt(originalSaleDate)}",
    style: pw.TextStyle(font: arabicFont),
  ),
),


        pw.SizedBox(height: 20),
        pw.Divider(),

        // Section title stays centered
pw.Center(
  child: pw.Text(
    t.returnedItems, // المواد المرجعة
    style: pw.TextStyle(
      fontSize: 16,
      fontWeight: pw.FontWeight.bold,
      font: arabicFont,
    ),
  ),
),

pw.SizedBox(height: 10),

pw.Table(
  border: pw.TableBorder.all(),
  columnWidths: {
    0: pw.FlexColumnWidth(2), // الإجمالي
    1: pw.FlexColumnWidth(2), // السعر
    2: pw.FlexColumnWidth(2), // الكمية
    3: pw.FlexColumnWidth(4), // المادة
  },
  children: [
    pw.TableRow(
      decoration: const pw.BoxDecoration(color: PdfColors.grey300),
      children: [
        _headerCell(t.total, arabicFont),
        _headerCell(t.price, arabicFont),
        _headerCell(t.qty, arabicFont),
        _headerCell(t.item, arabicFont),
      ],
    ),
    ...items.map((item) {
      return pw.TableRow(
        children: [
          // الإجمالي column → center
          _cell(item["total"].toStringAsFixed(2), arabicFont, center: true),

          // السعر column → center
          _cell(item["price"].toStringAsFixed(2), arabicFont, center: true),

          // الكمية column → center
          _cell(item["qty"].toString(), arabicFont, center: true),

          // المادة column → align right
          _cell(item["name"],
              containsArabic(item["name"]) ? arabicFont : englishFont,
              alignRight: true),
        ],
      );
    }),
  ],
),



        pw.SizedBox(height: 20),
        pw.Divider(),

      
// Below table
pw.Container(
  width: double.infinity,
  alignment: pw.Alignment.centerRight,
  child: pw.Text(
    "إجمالي المبلغ المسترد: ${refundTotal.toStringAsFixed(2)}",
    style: pw.TextStyle(
      font: arabicFont,
      fontSize: 18,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.red,
    ),
  ),
),

pw.Container(
  width: double.infinity,
  alignment: pw.Alignment.centerRight,
  child: pw.Text("السبب: ${_mapReasonToArabic(reason)}",
      style: pw.TextStyle(font: arabicFont)),
),

pw.Container(
  width: double.infinity,
  alignment: pw.Alignment.centerRight,
  child: pw.Text("إرجاع للمخزن: ${restock ? t.yes : t.no}",
      style: pw.TextStyle(font: arabicFont)),
),

pw.Container(
  width: double.infinity,
  alignment: pw.Alignment.centerRight,
  child: pw.Text("استرجاع نقدي: ${refund ? t.yes : t.no}",
      style: pw.TextStyle(font: arabicFont)),
),


        pw.SizedBox(height: 30),

        // Thank you stays centered
        pw.Center(
          child: pw.Text(
            t.thankYou,
            style: pw.TextStyle(font: arabicFont),
          ),
        ),
      ],
    ),
  );
},



    ),
  );

  return pdf.save();
}
// =========================
// PART 5 OF 5
// =========================

// =============================================================
// 80mm RETURN RECEIPT
// =============================================================
static Future<Uint8List> generateReturnPdf80mm({
  required List<Map<String, dynamic>> items,
  required double refundTotal,
  required String reason,
  required bool restock,
  required bool refund,
  required int originalSaleId,
  required String originalSaleDate,
  required AppLocalizations t,
  required Customer customer,
}) async {
  final settings = SettingsService();
  final isArabic = settings.language == "ar";

  final arabicFont = pw.Font.ttf(
    await rootBundle.load("assets/fonts/NotoNaskhArabic-Regular.ttf"),
  );
  final englishFont = pw.Font.ttf(
    await rootBundle.load("assets/fonts/Roboto-Regular.ttf"),
  );

  pw.ImageProvider? logoImage;
  if (settings.storeLogoPath.isNotEmpty) {
    final file = File(settings.storeLogoPath);
    if (await file.exists()) {
      logoImage = pw.MemoryImage(await file.readAsBytes());
    }
  }

  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat(80 * PdfPageFormat.mm, double.infinity),
      margin: const pw.EdgeInsets.all(8),
      textDirection: isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
      build: (_) {
        return pw.Directionality(
          textDirection: isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
          child: pw.Column(
            crossAxisAlignment:
                isArabic ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
            children: [
              // Title stays centered
              pw.Center(
                child: pw.Text(
                  t.returnReceipt,
                  style: pw.TextStyle(
                    font: isArabic ? arabicFont : englishFont,
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),

              if (logoImage != null)
                pw.Center(child: pw.Image(logoImage!, height: 50)),

              pw.SizedBox(height: 10),

              // Above table info
              pw.Container(
                width: double.infinity,
                alignment: isArabic ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
                child: pw.Text("${t.customer}: ${customer.name}",
                    style: pw.TextStyle(
                        font: containsArabic(customer.name)
                            ? arabicFont
                            : englishFont)),
              ),
              pw.Container(
                width: double.infinity,
                alignment: isArabic ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
                child: pw.Text("${t.storeName}: ${settings.storeName}",
                    style: pw.TextStyle(font: isArabic ? arabicFont : englishFont)),
              ),
              pw.Container(
                width: double.infinity,
                alignment: isArabic ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
                child: pw.Text("${t.originalSaleId}: $originalSaleId",
                    style: pw.TextStyle(font: isArabic ? arabicFont : englishFont)),
              ),
              pw.Container(
                width: double.infinity,
                alignment: isArabic ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
                child: pw.Text("${t.saleDate}: ${formatDateTimeReceipt(originalSaleDate)}",
                    style: pw.TextStyle(font: isArabic ? arabicFont : englishFont)),
              ),

              pw.SizedBox(height: 12),
              pw.Divider(),

              // المواد المرجعة centered
              pw.Center(
                child: pw.Text(
                  t.returnedItems,
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    font: isArabic ? arabicFont : englishFont,
                  ),
                ),
              ),
              pw.SizedBox(height: 8),

              // Table with conditional column order
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: isArabic
                    ? {
                        0: pw.FlexColumnWidth(2), // Total
                        1: pw.FlexColumnWidth(2), // Price
                        2: pw.FlexColumnWidth(2), // Qty
                        3: pw.FlexColumnWidth(4), // Item
                      }
                    : {
                        0: pw.FlexColumnWidth(4), // Item
                        1: pw.FlexColumnWidth(2), // Qty
                        2: pw.FlexColumnWidth(2), // Price
                        3: pw.FlexColumnWidth(2), // Total
                      },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                    children: isArabic
                        ? [
                            _headerCell(t.total, arabicFont),
                            _headerCell(t.price, arabicFont),
                            _headerCell(t.qty, arabicFont),
                            _headerCell(t.item, arabicFont),
                          ]
                        : [
                            _headerCell(t.item, englishFont),
                            _headerCell(t.qty, englishFont),
                            _headerCell(t.price, englishFont),
                            _headerCell(t.total, englishFont),
                          ],
                  ),
                  ...items.map((item) {
                    return pw.TableRow(
                      children: isArabic
                          ? [
                              _cell(item["total"].toStringAsFixed(2), arabicFont, center: true),
                              _cell(item["price"].toStringAsFixed(2), arabicFont, center: true),
                              _cell(item["qty"].toString(), arabicFont, center: true),
                              _cell(item["name"],
                                  containsArabic(item["name"]) ? arabicFont : englishFont,
                                  alignRight: true),
                            ]
                          : [
                              _cell(item["name"], englishFont),
                              _cell(item["qty"].toString(), englishFont, center: true),
                              _cell(item["price"].toStringAsFixed(2), englishFont, center: true),
                              _cell(item["total"].toStringAsFixed(2), englishFont, alignRight: true),
                            ],
                    );
                  }),
                ],
              ),

              pw.SizedBox(height: 10),
              pw.Divider(),

              // Refund total and reason aligned right for Arabic
              pw.Container(
                width: double.infinity,
                alignment: isArabic ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
                child: pw.Text(
                  "${t.refundTotal}: ${refundTotal.toStringAsFixed(2)}",
                  style: pw.TextStyle(
                    font: isArabic ? arabicFont : englishFont,
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.red,
                  ),
                ),
              ),

              pw.SizedBox(height: 10),

              pw.Container(
                width: double.infinity,
                alignment: isArabic ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
                child: pw.Text("السبب: ${_mapReasonToArabic(reason)}",
                    style: pw.TextStyle(font: isArabic ? arabicFont : englishFont)),
              ),
              pw.Container(
                width: double.infinity,
                alignment: isArabic ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
                child: pw.Text("إرجاع للمخزن: ${restock ? t.yes : t.no}",
                    style: pw.TextStyle(font: isArabic ? arabicFont : englishFont)),
              ),
              pw.Container(
                width: double.infinity,
                alignment: isArabic ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
                child: pw.Text("استرجاع نقدي: ${refund ? t.yes : t.no}",
                    style: pw.TextStyle(font: isArabic ? arabicFont : englishFont)),
              ),

              pw.SizedBox(height: 20),

              // Thank you stays centered
              pw.Center(
                child: pw.Text(
                  t.thankYou,
                  style: pw.TextStyle(font: isArabic ? arabicFont : englishFont),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );

  return pdf.save();
}


// -------------------------------------------------------------
// RETURN — SAVE A4 (NEW METHOD)
// -------------------------------------------------------------
static Future<void> saveReturnPdf({
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
  final pdfBytes = await generateReturnPdfA4(
    items: items,
    refundTotal: refundTotal,
    reason: reason,
    restock: restock,
    refund: refund,
    originalSaleId: originalSaleId,
    originalSaleDate: originalSaleDate,
    customer: customer,
    t: t,
  );

  final dir = await getTemporaryDirectory();
  final file = File("${dir.path}/return_$originalSaleId.pdf");
  await file.writeAsBytes(pdfBytes);
}

// -------------------------------------------------------------
// RETURN — PREVIEW A4
// -------------------------------------------------------------
static Future<void> previewReturnPdf({
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
  final pdfBytes = await generateReturnPdfA4(
    items: items,
    refundTotal: refundTotal,
    reason: reason,
    restock: restock,
    refund: refund,
    originalSaleId: originalSaleId,
    originalSaleDate: originalSaleDate,
    customer: customer,
    t: t,
  );

  await Printing.layoutPdf(
    onLayout: (format) async => pdfBytes,
  );
}

// -------------------------------------------------------------
// RETURN — SHARE A4
// -------------------------------------------------------------
static Future<void> shareReturnPdf({
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
  final pdfBytes = await generateReturnPdfA4(
    items: items,
    refundTotal: refundTotal,
    reason: reason,
    restock: restock,
    refund: refund,
    originalSaleId: originalSaleId,
    originalSaleDate: originalSaleDate,
    customer: customer,
    t: t,
  );

  final dir = await getTemporaryDirectory();
  final file = File("${dir.path}/return_$originalSaleId.pdf");
  await file.writeAsBytes(pdfBytes);

  await Share.shareXFiles([XFile(file.path)], text: t.returnReceipt);
}

// -------------------------------------------------------------
// RETURN — BLUETOOTH PRINT (80mm)
// -------------------------------------------------------------
static Future<void> printReturnPdfBluetooth({
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
  final isConnected = await bluetooth.isConnected ?? false;

  if (!isConnected) {
    if (selectedDevice == null) return;
    try {
      await bluetooth.connect(selectedDevice!);
    } catch (_) {
      return;
    }
  }

  final pdfBytes = await generateReturnPdf80mm(
    items: items,
    refundTotal: refundTotal,
    reason: reason,
    restock: restock,
    refund: refund,
    originalSaleId: originalSaleId,
    originalSaleDate: originalSaleDate,
    customer: customer,
    t: t,
  );

  await for (final page in Printing.raster(pdfBytes, dpi: 200)) {
    final png = await page.toPng();
    bluetooth.printImageBytes(png);
  }

  bluetooth.printNewLine();
  bluetooth.paperCut();
}

} // END OF CLASS
