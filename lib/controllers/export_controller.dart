import 'dart:io';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle, MethodChannel;

import '../models/product.dart';
import '../services/settings_service.dart';

const _safChannel = MethodChannel('my_app/saf');

Future<bool> saveFileWithSaf({
  required String fileName,
  required String mimeType,
  required Uint8List bytes,
}) async {
  final ok = await _safChannel.invokeMethod<bool>(
    'saveFile',
    {
      'fileName': fileName,
      'mimeType': mimeType,
      'bytes': bytes,
    },
  );
  return ok == true;
}

class ExportController {
  final SettingsService _settings = SettingsService();

  // ---------------------------------------------------------------------------
  // ARABIC DETECTION + SIMPLE TRANSLITERATION (B1)
  // ---------------------------------------------------------------------------

  bool isArabic(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }

  String transliterateArabic(String text) {
    const map = {
      'ا': 'a','أ': 'a','إ': 'i','آ': 'a',
      'ب': 'b','ت': 't','ث': 'th',
      'ج': 'j','ح': 'h','خ': 'kh',
      'د': 'd','ذ': 'dh','ر': 'r',
      'ز': 'z','س': 's','ش': 'sh',
      'ص': 's','ض': 'd','ط': 't',
      'ظ': 'z','ع': 'a','غ': 'gh',
      'ف': 'f','ق': 'q','ك': 'k',
      'ل': 'l','م': 'm','ن': 'n',
      'ه': 'h','و': 'w','ي': 'y',
      'ة': 'a'
    };

    final buffer = StringBuffer();
    for (final ch in text.split('')) {
      buffer.write(map[ch] ?? ch);
    }
    return buffer.toString();
  }

  String safeFileName(String name) {
    if (isArabic(name)) {
      name = transliterateArabic(name);
    }
    return name.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
  }

    // ---------------------------------------------------------------------------
  // PUBLIC EXPORT METHODS
  // ---------------------------------------------------------------------------

  Future<void> exportInventoryToExcel(
    BuildContext context,
    List<Product> products,
    Map<String, bool> selected,
  ) async {
    try {
      final raw = _settings.storeName.trim().isEmpty
          ? 'Store'
          : _settings.storeName.trim();

      final safe = safeFileName(raw);
      final ts = DateFormat('yyyy-MM-dd_HH-mm').format(DateTime.now());
      final fileName = '${safe}_inventory_$ts.xlsx';

      final bytes = _buildExcelBytes(products, selected);

      final ok = await saveFileWithSaf(
        fileName: fileName,
        mimeType:
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        bytes: bytes,
      );

      _showSnack(context, ok ? 'Excel saved: $fileName' : 'Excel not saved');
    } catch (e) {
      _showSnack(context, 'Failed to export Excel: $e');
    }
  }

  Future<void> exportInventoryToPdf(
    BuildContext context,
    List<Product> products,
    Map<String, bool> selected,
  ) async {
    try {
      final raw = _settings.storeName.trim().isEmpty
          ? 'Store'
          : _settings.storeName.trim();

      final safe = safeFileName(raw);
      final ts = DateFormat('yyyy-MM-dd_HH-mm').format(DateTime.now());
      final fileName = '${safe}_inventory_$ts.pdf';

      final bytes = await _buildPdfBytes(products, selected);

      final ok = await saveFileWithSaf(
        fileName: fileName,
        mimeType: 'application/pdf',
        bytes: bytes,
      );

      _showSnack(context, ok ? 'PDF saved: $fileName' : 'PDF not saved');
    } catch (e) {
      _showSnack(context, 'Failed to export PDF: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // LOCALIZATION
  // ---------------------------------------------------------------------------

  String _t(String key) {
    final lang = _settings.language;

    if (lang == 'ar') {
      switch (key) {
        case 'inventory_report': return 'تقرير الجرد';
        case 'barcode': return 'الباركود';
        case 'product': return 'المنتج';
        case 'category': return 'الفئة';
        case 'stock': return 'الكمية في المخزن';
        case 'purchase_price': return 'سعر الشراء';
        case 'sell_price1': return 'سعر المفرق';
        case 'sell_price2': return 'سعر الجملة';
        case 'sell_price3': return 'سعر البيع 3';
        case 'total_value': return 'القيمة الإجمالية';
        case 'total': return 'الإجمالي';
      }
    }

    switch (key) {
      case 'inventory_report': return 'Inventory Report';
      case 'barcode': return 'Barcode';
      case 'product': return 'Product';
      case 'category': return 'Category';
      case 'stock': return 'Stock';
      case 'purchase_price': return 'Purchase Price';
      case 'sell_price1': return 'Sell Price 1';
      case 'sell_price2': return 'Sell Price 2';
      case 'sell_price3': return 'Sell Price 3';
      case 'total_value': return 'Total Value';
      case 'total': return 'Total';
    }

    return key;
  }

  String _formatDateTime() {
    return DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
  }

  // ---------------------------------------------------------------------------
  // STOCK / TOTAL HELPERS
  // ---------------------------------------------------------------------------

  int _toPieces(Product p) {
    switch (p.unit) {
      case 'half': return p.stock * 6;
      case 'dozen': return p.stock * 12;
      default: return p.stock;
    }
  }

  String _stockDisplay(Product p) {
    final pieces = _toPieces(p);
    if (pieces < 12) return '$pieces';

    final dozens = pieces ~/ 12;
    final remainder = pieces % 12;

    if (remainder == 0) return '$dozens dozen';
    return '$dozens dozen + $remainder pieces';
  }

  double _totalValue(Product p) {
    return p.purchasePrice * _toPieces(p);
  }

  // ---------------------------------------------------------------------------
  // EXCEL EXPORT
  // ---------------------------------------------------------------------------

  Uint8List _buildExcelBytes(
    List<Product> products,
    Map<String, bool> selected,
  ) {
    final excel = Excel.createExcel();
    final sheet = excel['Inventory'];

    final storeName = _settings.storeName.trim().isEmpty
        ? _t('inventory_report')
        : _settings.storeName.trim();

    sheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('H1'));
    sheet.cell(CellIndex.indexByString('A1')).value = storeName;

    sheet.merge(CellIndex.indexByString('A2'), CellIndex.indexByString('H2'));
    sheet.cell(CellIndex.indexByString('A2')).value =
        "${_t('inventory_report')} - ${_formatDateTime()}";

    const headerRowIndex = 3;
    final headers = _buildHeaderList(selected);

    for (var col = 0; col < headers.length; col++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: col, rowIndex: headerRowIndex),
      );
      cell.value = headers[col];
      cell.cellStyle = CellStyle(bold: true);
    }

    var rowIndex = headerRowIndex + 1;
    double grandTotal = 0;

    for (final p in products) {
      final rowValues = _buildRowValues(p, selected);

      for (var col = 0; col < rowValues.length; col++) {
        final v = rowValues[col];
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: col, rowIndex: rowIndex),
        );
        cell.value = v is num ? v.toDouble() : v.toString();
      }

      if (selected['total'] == true) {
        grandTotal += _totalValue(p);
      }

      rowIndex++;
    }

    if (selected['total'] == true) {
      final totalColIndex = _columnIndexOf(selected, 'total');
      if (totalColIndex != null) {
        sheet
            .cell(CellIndex.indexByColumnRow(
              columnIndex: totalColIndex - 1,
              rowIndex: rowIndex,
            ))
            .value = _t('total');

        sheet
            .cell(CellIndex.indexByColumnRow(
              columnIndex: totalColIndex,
              rowIndex: rowIndex,
            ))
            .value = grandTotal;
      }
    }

    for (var col = 0; col < headers.length; col++) {
      int maxLen = headers[col].length;

      for (var r = headerRowIndex + 1; r <= rowIndex; r++) {
        final v = sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: r))
            .value;
        if (v != null) {
          maxLen = maxLen < v.toString().length ? v.toString().length : maxLen;
        }
      }

      sheet.setColWidth(col, (maxLen + 2).toDouble());
    }

    return Uint8List.fromList(excel.encode()!);
  }

  // ---------------------------------------------------------------------------
  // HEADER + ROW BUILDERS
  // ---------------------------------------------------------------------------

  List<String> _buildHeaderList(Map<String, bool> selected) {
    final headers = <String>[];

    if (selected['barcode'] == true) headers.add(_t('barcode'));
    if (selected['name'] == true) headers.add(_t('product'));
    if (selected['category'] == true) headers.add(_t('category'));
    if (selected['stock'] == true) headers.add(_t('stock'));
    if (selected['purchase'] == true) headers.add(_t('purchase_price'));
    if (selected['sell1'] == true) headers.add(_t('sell_price1'));
    if (selected['sell2'] == true) headers.add(_t('sell_price2'));
    if (selected['sell3'] == true) headers.add(_t('sell_price3'));
    if (selected['total'] == true) headers.add(_t('total_value'));

    return headers;
  }

  List<dynamic> _buildRowValues(Product p, Map<String, bool> selected) {
    final row = <dynamic>[];

    if (selected['barcode'] == true) row.add(p.barcode);
    if (selected['name'] == true) row.add(p.name);
    if (selected['category'] == true) row.add(p.category ?? '');
    if (selected['stock'] == true) row.add(_stockDisplay(p));
    if (selected['purchase'] == true) row.add(p.purchasePrice);
    if (selected['sell1'] == true) row.add(p.sellPrice1);
    if (selected['sell2'] == true) row.add(p.sellPrice2);
    if (selected['sell3'] == true) row.add(p.sellPrice3);
    if (selected['total'] == true) row.add(_totalValue(p));

    return row;
  }

  int? _columnIndexOf(Map<String, bool> selected, String key) {
    var index = 0;

    void check(String k) {
      if (selected[k] == true) {
        if (k == key) throw index;
        index++;
      }
    }

    try {
      check('barcode');
      check('name');
      check('category');
      check('stock');
      check('purchase');
      check('sell1');
      check('sell2');
      check('sell3');
      check('total');
    } catch (i) {
      return i as int;
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // PDF EXPORT — FINAL VERSION (C1 Hybrid + B1 Transliteration)
  // ---------------------------------------------------------------------------

  Future<Uint8List> _buildPdfBytes(
    List<Product> products,
    Map<String, bool> selected,
  ) async {
    // Load fonts
    final arabicFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoNaskhArabic-Regular.ttf'),
    );
    final englishFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
    );

    pw.Font pickFont(String text) {
      return isArabic(text) ? arabicFont : englishFont;
    }

    final pdf = pw.Document();

    final rawName = _settings.storeName.trim();
    final isArabicName = isArabic(rawName);

    final storeName = rawName.isEmpty ? _t('inventory_report') : rawName;

    final isArabicApp = _settings.language == 'ar';

    // Build headers
    final headers = _buildHeaderList(selected);

    // Build data rows
    final data = products.map((p) {
      final row = <String>[];

      if (selected['barcode'] == true) row.add(p.barcode);
      if (selected['name'] == true) row.add(p.name);
      if (selected['category'] == true) row.add(p.category ?? '');
      if (selected['stock'] == true) row.add(_stockDisplay(p));
      if (selected['purchase'] == true) row.add(p.purchasePrice.toStringAsFixed(2));
      if (selected['sell1'] == true) row.add(p.sellPrice1.toStringAsFixed(2));
      if (selected['sell2'] == true) row.add(p.sellPrice2.toStringAsFixed(2));
      if (selected['sell3'] == true) row.add(p.sellPrice3.toStringAsFixed(2));
      if (selected['total'] == true) row.add(_totalValue(p).toStringAsFixed(2));

      return row;
    }).toList();

    // -----------------------------------------------------------------------
    // HYBRID COLUMN WIDTHS (C1)
    // -----------------------------------------------------------------------
    final fixedWidths = <String, double>{
  'barcode': 130,   // was 120
  'category': 110,  // was 100
  'stock': 130,     // was 120
  'purchase': 75,   // was 70
  'sell1': 75,
  'sell2': 75,
  'sell3': 75,
  'total': 120,     // was 110
};


    final selectedKeys = <String>[];
    if (selected['barcode'] == true) selectedKeys.add('barcode');
    if (selected['name'] == true) selectedKeys.add('name');
    if (selected['category'] == true) selectedKeys.add('category');
    if (selected['stock'] == true) selectedKeys.add('stock');
    if (selected['purchase'] == true) selectedKeys.add('purchase');
    if (selected['sell1'] == true) selectedKeys.add('sell1');
    if (selected['sell2'] == true) selectedKeys.add('sell2');
    if (selected['sell3'] == true) selectedKeys.add('sell3');
    if (selected['total'] == true) selectedKeys.add('total');

    final columnWidths = <int, pw.TableColumnWidth>{};

    for (var i = 0; i < selectedKeys.length; i++) {
      final key = selectedKeys[i];

      if (key == 'name') {
        columnWidths[i] = const pw.FlexColumnWidth();
      } else {
        columnWidths[i] = pw.FixedColumnWidth(fixedWidths[key]!);
      }
    }

    // -----------------------------------------------------------------------
    // TOTAL CALCULATION
    // -----------------------------------------------------------------------
    double grandTotal = 0;
    if (selected['total'] == true) {
      for (final p in products) {
        grandTotal += _totalValue(p);
      }
    }

    // -----------------------------------------------------------------------
    // LOAD LOGO IF EXISTS
    // -----------------------------------------------------------------------
    pw.ImageProvider? logoImage;
    try {
      if (_settings.storeLogoPath.isNotEmpty) {
        final logoFile = File(_settings.storeLogoPath);
        if (await logoFile.exists()) {
          final bytes = await logoFile.readAsBytes();
          logoImage = pw.MemoryImage(bytes);
        }
      }
    } catch (_) {
      logoImage = null;
    }

    // -----------------------------------------------------------------------
    // BUILD PDF PAGE
    // -----------------------------------------------------------------------
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        textDirection:
            isArabicApp ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        build: (context) => [
          if (logoImage != null)
            pw.Center(
              child: pw.Image(logoImage!, width: 80, height: 80),
            ),

          pw.SizedBox(height: 8),

          pw.Center(
            child: pw.Text(
              storeName,
              textDirection:
                  isArabicName ? pw.TextDirection.rtl : pw.TextDirection.ltr,
              style: pw.TextStyle(
                font: pickFont(storeName),
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),

          pw.SizedBox(height: 4),

          pw.Center(
            child: pw.Text(
              "${_t('inventory_report')} - ${_formatDateTime()}",
              style: pw.TextStyle(
                font: pickFont(_t('inventory_report')),
                fontSize: 10,
              ),
            ),
          ),

          pw.SizedBox(height: 16),

          // -------------------------------------------------------------------
          // TABLE — WITH TOTAL ROW INSIDE
          // -------------------------------------------------------------------
          pw.Table(
            columnWidths: columnWidths,
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              // Header row
              pw.TableRow(
  decoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
  children: [
    for (var h in headers)
      pw.Container(
        padding: const pw.EdgeInsets.all(4),
        alignment: pw.Alignment.center,
        child: pw.Directionality(
          textDirection: isArabic(h)
              ? pw.TextDirection.rtl
              : pw.TextDirection.ltr,
          child: pw.Text(
            h,
            style: pw.TextStyle(
              font: pickFont(h),
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
              fontSize: 9, // was 10
            ),
            maxLines: 1,
            softWrap: false,
            overflow: pw.TextOverflow.clip,
          ),
        ),
      ),
  ],
),


              // Data rows
              for (var row in data)
  pw.TableRow(
    children: [
      for (var cell in row)
        pw.Container(
          padding: const pw.EdgeInsets.all(4),
          alignment: pw.Alignment.center,
          child: pw.Directionality(
            textDirection: isArabic(cell)
                ? pw.TextDirection.rtl
                : pw.TextDirection.ltr,
            child: pw.Text(
              cell,
              style: pw.TextStyle(
                font: pickFont(cell),
                fontSize: 8, // was 9
              ),
              maxLines: 1,
              softWrap: false,
              overflow: pw.TextOverflow.clip,
            ),
          ),
        ),
    ],
  ),


              // TOTAL ROW (INSIDE TABLE)
              if (selected['total'] == true)
                pw.TableRow(
                  children: [
                    for (var i = 0; i < selectedKeys.length; i++)
                      pw.Container(
                        padding: const pw.EdgeInsets.all(4),
                        alignment: pw.Alignment.center,
                        child: (selectedKeys[i] == 'total')
                            ? pw.Text(
                                grandTotal.toStringAsFixed(2),
                                style: pw.TextStyle(
                                  font: pickFont(grandTotal.toString()),
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 10,
                                ),
                              )
                            : (selectedKeys[i] ==
                                    selectedKeys[selectedKeys.length - 2]
                                ? pw.Text(
                                    _t('total'),
                                    style: pw.TextStyle(
                                      font: pickFont(_t('total')),
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  )
                                : pw.Text("")),
                      ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );

    return pdf.save();
  }

  // ---------------------------------------------------------------------------
  // UI HELPER
  // ---------------------------------------------------------------------------

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
}
