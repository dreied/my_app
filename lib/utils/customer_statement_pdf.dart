import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../models/customer.dart';
import '../services/settings_service.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../utils/date_format.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class CustomerStatementPdf {
  // Detect Arabic characters
  static bool containsArabic(String text) {
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    return arabicRegex.hasMatch(text);
  }

  // Directional text helper
  static pw.Widget dirText(
    String text,
    bool isArabic, {
    double size = 12,
    pw.Font? arabicFont,
    pw.Font? englishFont,
    pw.FontWeight? weight,
  }) {
    return pw.Directionality(
      textDirection: isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: size,
          font: isArabic ? arabicFont : englishFont,
          fontWeight: weight,
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // NEW METHOD: Generate PDF and return FILE PATH (for WhatsApp)
  // ------------------------------------------------------------
 static Future<String> generatePaymentReceiptFile({
  required Customer customer,
  required Map<String, dynamic> payment,
}) async {
  final settings = SettingsService();
  final isArabic = settings.language == "ar";

  final mainFont = pw.Font.ttf(
    await rootBundle.load("assets/fonts/NotoNaskhArabic-Regular.ttf"),
  );

  bool isArabicText(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }

  pw.ImageProvider? logoImage;
  if (settings.storeLogoPath.isNotEmpty) {
    final file = File(settings.storeLogoPath);
    if (await file.exists()) {
      logoImage = pw.MemoryImage(await file.readAsBytes());
    }
  }



  final note = payment['note'] ?? "";
  final rawAmount = (payment['amount'] as num).toDouble(); // negative for give_cash
final amount = rawAmount.abs(); // positive for display
final currentBalance = customer.balance;
final pastBalance = (payment['balance_at_time'] as num?)?.toDouble() ?? currentBalance;



  final receiptId = payment['id'];
  final storeName = settings.storeName.isEmpty
      ? (isArabic ? "المتجر" : "Store")
      : settings.storeName;

  final date = formatDateTimeReceipt(payment['datetime']);
  final type = (payment['type'] ?? "").toString();

  // ------------------------------------------------------------
  // FIXED: Correct title + sentence based on payment type
  // ------------------------------------------------------------
  late String title;
  late String sentence;

  if (type == "give_cash") {
    title = isArabic
        ? "إيصال استلام نقد رقم $receiptId"
        : "Cash Out Receipt No. $receiptId";

    sentence = isArabic
        ? "قام السيد (${customer.name}) باستلام مبلغ قدره (${amount.toStringAsFixed(2)}) دولار."
        : "The customer (${customer.name}) received an amount of ${amount.toStringAsFixed(2)} dollars.";
  }
  else if (type == "pay_debt") {
    title = isArabic
        ? "إيصال دفع رقم $receiptId"
        : "Payment Receipt No. $receiptId";

    sentence = isArabic
        ? "قام السيد (${customer.name}) بدفع مبلغ قدره (${amount.toStringAsFixed(2)}) دولار."
        : "The customer (${customer.name}) paid an amount of ${amount.toStringAsFixed(2)} dollars.";
  }
  else if (type == "return") {
    title = isArabic
        ? "إيصال إرجاع رقم $receiptId"
        : "Return Receipt No. $receiptId";

    sentence = isArabic
        ? "عملية إرجاع مسجلة."
        : "A return transaction was recorded.";
  }
  else {
    title = isArabic
        ? "إيصال دفع رقم $receiptId"
        : "Payment Receipt No. $receiptId";

    sentence = isArabic
        ? "تمت إضافة دفعة."
        : "A payment was added.";
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

  // ------------------------------------------------------------
  // PDF BUILD
  // ------------------------------------------------------------
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat(80 * PdfPageFormat.mm, double.infinity),
      margin: const pw.EdgeInsets.all(8),
      textDirection: isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
      build: (_) {
        return pw.Column(
          crossAxisAlignment: isArabic
              ? pw.CrossAxisAlignment.end
              : pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Text(
                title,
                style: pw.TextStyle(
                  font: mainFont,
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),

            pw.SizedBox(height: 10),

            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Row(
                  children: [
                    pw.Text(
                      isArabic ? "متجر: " : "Store: ",
                      style: pw.TextStyle(font: mainFont, fontSize: 14),
                    ),
                    pw.Directionality(
                      textDirection: isArabicText(storeName)
                          ? pw.TextDirection.rtl
                          : pw.TextDirection.ltr,
                      child: pw.Text(
                        storeName,
                        style: pw.TextStyle(font: mainFont, fontSize: 14),
                      ),
                    ),
                  ],
                ),
                if (logoImage != null) pw.Image(logoImage, height: 40),
              ],
            ),

            pw.SizedBox(height: 10),

            pw.Row(
              children: [
                pw.Text(
                  isArabic ? "الزبون: " : "Customer: ",
                  style: pw.TextStyle(font: mainFont, fontSize: 14),
                ),
                pw.Directionality(
                  textDirection: isArabicText(customer.name)
                      ? pw.TextDirection.rtl
                      : pw.TextDirection.ltr,
                  child: pw.Text(
                    customer.name,
                    style: pw.TextStyle(font: mainFont, fontSize: 14),
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 6),

            pw.Text(
              isArabic ? "التاريخ: $date" : "Date: $date",
              style: pw.TextStyle(font: mainFont, fontSize: 14),
            ),

            pw.SizedBox(height: 12),
            pw.Divider(),

            pw.Directionality(
              textDirection: isArabicText(sentence)
                  ? pw.TextDirection.rtl
                  : pw.TextDirection.ltr,
              child: pw.Text(
                sentence,
                style: pw.TextStyle(font: mainFont, fontSize: 14),
              ),
            ),

            pw.SizedBox(height: 12),

            if (note.toString().isNotEmpty)
              pw.Row(
                children: [
                  pw.Text(
                    isArabic ? "ملاحظة: " : "Note: ",
                    style: pw.TextStyle(font: mainFont, fontSize: 14),
                  ),
                  pw.Directionality(
                    textDirection: isArabicText(note)
                        ? pw.TextDirection.rtl
                        : pw.TextDirection.ltr,
                    child: pw.Text(
                      note,
                      style: pw.TextStyle(font: mainFont, fontSize: 14),
                    ),
                  ),
                ],
              ),

            pw.SizedBox(height: 12),
            pw.Divider(),

            pw.Text(
              isArabic
                  ? "الرصيد السابق: ${formatArabicBalance(pastBalance)}"
      : "Past balance: ${pastBalance.toStringAsFixed(2)}",
              style: pw.TextStyle(font: mainFont, fontSize: 14),
            ),

            pw.Text(
              isArabic
                  ? "الرصيد الحالي: ${formatArabicBalance(currentBalance)}"
      : "Current balance: ${currentBalance.toStringAsFixed(2)}",
              style: pw.TextStyle(font: mainFont, fontSize: 14),
            ),
          ],
        );
      },
    ),
  );

  final bytes = await pdf.save();
  final dir = await getTemporaryDirectory();
  final file = File("${dir.path}/payment_receipt_$receiptId.pdf");

  await file.writeAsBytes(bytes);

  return file.path;
}

  // ------------------------------------------------------------
  // ORIGINAL METHOD (unchanged): Print the receipt normally
  // ------------------------------------------------------------
  static Future<void> generatePaymentReceipt({
    required Customer customer,
    required Map<String, dynamic> payment,
  }) async {
    final settings = SettingsService();
    final isArabic = settings.language == "ar";

    final mainFont = pw.Font.ttf(
      await rootBundle.load("assets/fonts/NotoNaskhArabic-Regular.ttf"),
    );

    bool isArabicText(String text) {
      return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
    }

    pw.ImageProvider? logoImage;
    if (settings.storeLogoPath.isNotEmpty) {
      final file = File(settings.storeLogoPath);
      if (await file.exists()) {
        logoImage = pw.MemoryImage(await file.readAsBytes());
      }
    }

   

    final note = payment['note'] ?? "";
    final rawAmount = (payment['amount'] as num).toDouble(); // negative for give_cash
final amount = rawAmount.abs(); // positive for display
final currentBalance = customer.balance;
final pastBalance =
    (payment['balance_at_time'] as num?)?.toDouble() ?? currentBalance;


    final receiptId = payment['id'];
    final storeName = settings.storeName.isEmpty
        ? (isArabic ? "المتجر" : "Store")
        : settings.storeName;

    final date = formatDateTimeReceipt(payment['datetime']);

    final pdf = pw.Document();

    // SAME TEMPLATE AS BEFORE
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(80 * PdfPageFormat.mm, double.infinity),
        margin: const pw.EdgeInsets.all(8),
        textDirection: isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        build: (_) {
         final type = (payment['type'] ?? '').toString();

late String title;
late String sentence;

if (type == "give_cash") {
  title = isArabic
      ? "إيصال استلام نقد رقم $receiptId"
      : "Cash Out Receipt No. $receiptId";

 sentence = isArabic
    ? "قام السيد (${customer.name}) باستلام مبلغ قدره (${amount.toStringAsFixed(2)}) دولار."
    : "The customer (${customer.name}) received an amount of ${amount.toStringAsFixed(2)} dollars.";

}
else if (type == "pay_debt") {
  title = isArabic
      ? "إيصال دفع رقم $receiptId"
      : "Payment Receipt No. $receiptId";

  sentence = isArabic
      ? "قام السيد (${customer.name}) بدفع مبلغ قدره (${amount.toStringAsFixed(2)}) دولار."
      : "The customer (${customer.name}) paid an amount of ${amount.toStringAsFixed(2)} dollars.";
}
else if (type == "return") {
  title = isArabic
      ? "إيصال إرجاع رقم $receiptId"
      : "Return Receipt No. $receiptId";

  sentence = isArabic
      ? "عملية إرجاع مسجلة."
      : "A return transaction was recorded.";
}
else {
  title = isArabic
      ? "إيصال دفع رقم $receiptId"
      : "Payment Receipt No. $receiptId";

  sentence = isArabic
      ? "تمت إضافة دفعة."
      : "A payment was added.";
}

          return pw.Column(
            crossAxisAlignment: isArabic
                ? pw.CrossAxisAlignment.end
                : pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  title,
                  style: pw.TextStyle(
                    font: mainFont,
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),

              pw.SizedBox(height: 10),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Row(
                    children: [
                      pw.Text(
                        isArabic ? "متجر: " : "Store: ",
                        style: pw.TextStyle(font: mainFont, fontSize: 14),
                      ),
                      pw.Directionality(
                        textDirection: isArabicText(storeName)
                            ? pw.TextDirection.rtl
                            : pw.TextDirection.ltr,
                        child: pw.Text(
                          storeName,
                          style: pw.TextStyle(font: mainFont, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  if (logoImage != null) pw.Image(logoImage, height: 40),
                ],
              ),

              pw.SizedBox(height: 10),

              pw.Row(
                children: [
                  pw.Text(
                    isArabic ? "الزبون: " : "Customer: ",
                    style: pw.TextStyle(font: mainFont, fontSize: 14),
                  ),
                  pw.Directionality(
                    textDirection: isArabicText(customer.name)
                        ? pw.TextDirection.rtl
                        : pw.TextDirection.ltr,
                    child: pw.Text(
                      customer.name,
                      style: pw.TextStyle(font: mainFont, fontSize: 14),
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 6),

              pw.Text(
                isArabic ? "التاريخ: $date" : "Date: $date",
                style: pw.TextStyle(font: mainFont, fontSize: 14),
              ),

              pw.SizedBox(height: 12),
              pw.Divider(),

              pw.Directionality(
                textDirection: isArabicText(sentence)
                    ? pw.TextDirection.rtl
                    : pw.TextDirection.ltr,
                child: pw.Text(
                  sentence,
                  style: pw.TextStyle(font: mainFont, fontSize: 14),
                ),
              ),

              pw.SizedBox(height: 12),

              if (note.toString().isNotEmpty)
                pw.Row(
                  children: [
                    pw.Text(
                      isArabic ? "ملاحظة: " : "Note: ",
                      style: pw.TextStyle(font: mainFont, fontSize: 14),
                    ),
                    pw.Directionality(
                      textDirection: isArabicText(note)
                          ? pw.TextDirection.rtl
                          : pw.TextDirection.ltr,
                      child: pw.Text(
                        note,
                        style: pw.TextStyle(font: mainFont, fontSize: 14),
                      ),
                    ),
                  ],
                ),

              pw.SizedBox(height: 12),
              pw.Divider(),

              pw.Text(
                isArabic
                    ? "الرصيد السابق: ${pastBalance.toStringAsFixed(2)}"
                    : "Past balance: ${pastBalance.toStringAsFixed(2)}",
                style: pw.TextStyle(font: mainFont, fontSize: 14),
              ),

              pw.Text(
                isArabic
                    ? "الرصيد الحالي: ${currentBalance.toStringAsFixed(2)}"
                    : "Current balance: ${currentBalance.toStringAsFixed(2)}",
                style: pw.TextStyle(font: mainFont, fontSize: 14),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }
  // ------------------------------------------------------------
  // ORIGINAL FULL CUSTOMER STATEMENT (unchanged)
  // ------------------------------------------------------------
  static Future<void> generate({
    required Customer customer,
    required List<Map<String, dynamic>> sales,
    required List<Map<String, dynamic>> payments,
  }) async {
    final settings = SettingsService();
    final isArabic = settings.language == "ar";

    final arabicFont = pw.Font.ttf(
      await rootBundle.load("assets/fonts/NotoNaskhArabic-Regular.ttf"),
    );

    final englishFont = pw.Font.ttf(
      await rootBundle.load("assets/fonts/Roboto-Regular.ttf"),
    );

    final pdf = pw.Document();

    pw.ImageProvider? logoImage;
    if (settings.storeLogoPath.isNotEmpty &&
        File(settings.storeLogoPath).existsSync()) {
      final bytes = File(settings.storeLogoPath).readAsBytesSync();
      logoImage = pw.MemoryImage(bytes);
    }

    final totalSales = sales.fold<double>(
      0,
      (sum, s) => sum + (s['total'] as num).toDouble(),
    );

    final totalPayments = payments.fold<double>(
      0,
      (sum, p) => sum + (p['amount'] as num).toDouble(),
    );

    final balance = customer.balance;

    final storeName = settings.storeName.isEmpty
        ? (isArabic ? "المتجر" : "Store")
        : settings.storeName;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        textDirection:
            isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        build: (context) => [
          // HEADER
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment:
                isArabic ? pw.MainAxisAlignment.end : pw.MainAxisAlignment.start,
            children: [
              if (logoImage != null)
                pw.Container(
                  width: 80,
                  height: 80,
                  margin: isArabic
                      ? const pw.EdgeInsets.only(left: 16)
                      : const pw.EdgeInsets.only(right: 16),
                  child: pw.Image(logoImage),
                ),
              pw.Column(
                crossAxisAlignment: isArabic
                    ? pw.CrossAxisAlignment.end
                    : pw.CrossAxisAlignment.start,
                children: [
                  dirText(
                    storeName,
                    isArabic,
                    size: 22,
                    weight: pw.FontWeight.bold,
                    arabicFont: arabicFont,
                    englishFont: englishFont,
                  ),
                  pw.SizedBox(height: 4),
                  dirText(
                    isArabic ? "كشف حساب زبون" : "Customer Statement",
                    isArabic,
                    size: 16,
                    arabicFont: arabicFont,
                    englishFont: englishFont,
                  ),
                  dirText(
                    "${isArabic ? "التاريخ" : "Date"}: ${formatDateTimeUI(DateTime.now().toString())}",
                    isArabic,
                    size: 12,
                    arabicFont: arabicFont,
                    englishFont: englishFont,
                  ),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 20),

          // CUSTOMER INFO
          dirText(
            isArabic ? "معلومات الزبون" : "Customer Information",
            isArabic,
            size: 18,
            weight: pw.FontWeight.bold,
            arabicFont: arabicFont,
            englishFont: englishFont,
          ),
          pw.Divider(),
          dirText("${isArabic ? "الاسم" : "Name"}: ${customer.name}",
              isArabic, arabicFont: arabicFont, englishFont: englishFont),
          dirText("${isArabic ? "الهاتف" : "Phone"}: ${customer.phone ?? '-'}",
              isArabic, arabicFont: arabicFont, englishFont: englishFont),
          dirText(
              "${isArabic ? "الرصيد الحالي" : "Current Balance"}: ${balance.toStringAsFixed(2)}",
              isArabic,
              arabicFont: arabicFont,
              englishFont: englishFont),

          pw.SizedBox(height: 20),

          // SALES TABLE
          dirText(
            isArabic ? "المبيعات" : "Sales",
            isArabic,
            size: 18,
            weight: pw.FontWeight.bold,
            arabicFont: arabicFont,
            englishFont: englishFont,
          ),
          pw.Divider(),

          if (sales.isEmpty)
            dirText(isArabic ? "لا توجد مبيعات." : "No sales recorded.",
                isArabic,
                arabicFont: arabicFont,
                englishFont: englishFont)
          else
            pw.Table(
              columnWidths: isArabic
                  ? {
                      0: pw.FlexColumnWidth(2),
                      1: pw.FlexColumnWidth(3),
                      2: pw.FlexColumnWidth(2),
                    }
                  : {
                      0: pw.FlexColumnWidth(2),
                      1: pw.FlexColumnWidth(3),
                      2: pw.FlexColumnWidth(2),
                    },
              children: [
                pw.TableRow(
                  children: [
                    dirText(isArabic ? "المجموع" : "Total", isArabic,
                        weight: pw.FontWeight.bold,
                        arabicFont: arabicFont,
                        englishFont: englishFont),
                    dirText(isArabic ? "التاريخ" : "Date", isArabic,
                        weight: pw.FontWeight.bold,
                        arabicFont: arabicFont,
                        englishFont: englishFont),
                    dirText(isArabic ? "الرقم" : "ID", isArabic,
                        weight: pw.FontWeight.bold,
                        arabicFont: arabicFont,
                        englishFont: englishFont),
                  ],
                ),
                ...sales.map((s) {
                  return pw.TableRow(
                    children: [
                      dirText(s['total'].toString(), isArabic,
                          arabicFont: arabicFont, englishFont: englishFont),
                      dirText(formatDateTimeUI(s['datetime']), isArabic,
                          arabicFont: arabicFont, englishFont: englishFont),
                      dirText(s['id'].toString(), isArabic,
                          arabicFont: arabicFont, englishFont: englishFont),
                    ],
                  );
                }),
              ],
            ),

          pw.SizedBox(height: 20),

          // PAYMENTS TABLE
          dirText(
            isArabic ? "المدفوعات" : "Payments",
            isArabic,
            size: 18,
            weight: pw.FontWeight.bold,
            arabicFont: arabicFont,
            englishFont: englishFont,
          ),
          pw.Divider(),

          if (payments.isEmpty)
            dirText(isArabic ? "لا توجد دفعات." : "No payments recorded.",
                isArabic,
                arabicFont: arabicFont,
                englishFont: englishFont)
          else
            pw.Table(
              columnWidths: isArabic
                  ? {
                      0: pw.FlexColumnWidth(3),
                      1: pw.FlexColumnWidth(3),
                      2: pw.FlexColumnWidth(2),
                    }
                  : {
                      0: pw.FlexColumnWidth(2),
                      1: pw.FlexColumnWidth(3),
                      2: pw.FlexColumnWidth(3),
                    },
              children: [
                pw.TableRow(
                  children: [
                    dirText(isArabic ? "الملاحظة" : "Note", isArabic,
                        weight: pw.FontWeight.bold,
                        arabicFont: arabicFont,
                        englishFont: englishFont),
                    dirText(isArabic ? "التاريخ" : "Date", isArabic,
                        weight: pw.FontWeight.bold,
                        arabicFont: arabicFont,
                        englishFont: englishFont),
                    dirText(isArabic ? "المبلغ" : "Amount", isArabic,
                        weight: pw.FontWeight.bold,
                        arabicFont: arabicFont,
                        englishFont: englishFont),
                  ],
                ),
                ...payments.map((p) {
                  return pw.TableRow(
                    children: [
                      dirText(p['note'] ?? "", isArabic,
                          arabicFont: arabicFont, englishFont: englishFont),
                      dirText(formatDateTimeUI(p['datetime']), isArabic,
                          arabicFont: arabicFont, englishFont: englishFont),
                      dirText(p['amount'].toString(), isArabic,
                          arabicFont: arabicFont, englishFont: englishFont),
                    ],
                  );
                }),
              ],
            ),

          pw.SizedBox(height: 20),

          // SUMMARY
          dirText(
            isArabic ? "الملخص" : "Summary",
            isArabic,
            size: 18,
            weight: pw.FontWeight.bold,
            arabicFont: arabicFont,
            englishFont: englishFont,
          ),
          pw.Divider(),

          dirText(
              "${isArabic ? "إجمالي المبيعات" : "Total Sales"}: ${totalSales.toStringAsFixed(2)}",
              isArabic,
              arabicFont: arabicFont,
              englishFont: englishFont),
          dirText(
              "${isArabic ? "إجمالي المدفوعات" : "Total Payments"}: ${totalPayments.toStringAsFixed(2)}",
              isArabic,
              arabicFont: arabicFont,
              englishFont: englishFont),
          dirText(
              "${isArabic ? "الرصيد" : "Balance"}: ${balance.toStringAsFixed(2)}",
              isArabic,
              arabicFont: arabicFont,
              englishFont: englishFont),

          pw.SizedBox(height: 40),

          dirText(
            isArabic
                ? "التوقيع: __________________________"
                : "Signature: __________________________",
            isArabic,
            arabicFont: arabicFont,
            englishFont: englishFont,
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }
}
