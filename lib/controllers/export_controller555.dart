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
  // PUBLIC EXPORT METHODS
  // ---------------------------------------------------------------------------

  Future<void> exportInventoryToExcel(
    BuildContext context,
    List<Product> products,
    Map<String, bool> selected,
  ) async {
    try {
      final fileName = _buildFileName(extension: 'xlsx');
      final bytes = _buildExcelBytes(products, selected);

      final ok = await saveFileWithSaf(
        fileName: fileName,
        mimeType:
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        bytes: bytes,
      );

      if (ok) {
        _showSnack(context, 'Excel saved: $fileName');
      } else {
        _showSnack(context, 'Excel not saved');
      }
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
      final fileName = _buildFileName(extension: 'pdf');
      final bytes = await _buildPdfBytes(products, selected);

      final ok = await saveFileWithSaf(
        fileName: fileName,
        mimeType: 'application/pdf',
        bytes: bytes,
      );

      if (ok) {
        _showSnack(context, 'PDF saved: $fileName');
      } else {
        _showSnack(context, 'PDF not saved');
      }
    } catch (e) {
      _showSnack(context, 'Failed to export PDF: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // FILE NAME / LOCALIZATION
  // ---------------------------------------------------------------------------

  String _buildFileName({required String extension}) {
    final raw = _settings.storeName.trim().isEmpty
        ? 'Store'
        : _settings.storeName.trim();

    final safe = raw.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final ts = DateFormat('yyyy-MM-dd_HH-mm').format(DateTime.now());

    return '${safe}_inventory_$ts.$extension';
  }

  String _t(String key) {
    final lang = _settings.language;

    if (lang == 'ar') {
      switch (key) {
        case 'inventory_report':
          return 'تقرير الجرد';
        case 'barcode':
          return 'الباركود';
        case 'product':
          return 'المنتج';
        case 'category':
          return 'الفئة';
        case 'stock':
          return 'الكمية في المخزن';
        case 'purchase_price':
          return 'سعر الشراء';
        case 'sell_price1':
          return 'سعر المفرق';
        case 'sell_price2':
          return 'سعر الجملة';
        case 'sell_price3':
          return 'سعر البيع 3';
        case 'total_value':
          return 'القيمة الإجمالية';
        case 'total':
          return 'الإجمالي';
      }
    }

    switch (key) {
      case 'inventory_report':
        return 'Inventory Report';
      case 'barcode':
        return 'Barcode';
      case 'product':
        return 'Product';
      case 'category':
        return 'Category';
      case 'stock':
        return 'Stock';
      case 'purchase_price':
        return 'Purchase Price';
      case 'sell_price1':
        return 'Sell Price 1';
      case 'sell_price2':
        return 'Sell Price 2';
      case 'sell_price3':
        return 'Sell Price 3';
      case 'total_value':
        return 'Total Value';
      case 'total':
        return 'Total';
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
      case 'half':
        return p.stock * 6;
      case 'dozen':
        return p.stock * 12;
      default:
        return p.stock;
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

    // Title row
    sheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('H1'));
    sheet.cell(CellIndex.indexByString('A1')).value = storeName;

    // Subtitle row
    sheet.merge(CellIndex.indexByString('A2'), CellIndex.indexByString('H2'));
    sheet.cell(CellIndex.indexByString('A2')).value =
        "${_t('inventory_report')} - ${_formatDateTime()}";

    const headerRowIndex = 3;
    final headers = _buildHeaderList(selected);

    // Write headers
    for (var col = 0; col < headers.length; col++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(
          columnIndex: col,
          rowIndex: headerRowIndex,
        ),
      );
      cell.value = headers[col];
      cell.cellStyle = CellStyle(bold: true);
    }

    // Write rows
    var rowIndex = headerRowIndex + 1;
    double grandTotal = 0;

    for (final p in products) {
      final rowValues = _buildRowValues(p, selected);

      for (var col = 0; col < rowValues.length; col++) {
        final v = rowValues[col];
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(
            columnIndex: col,
            rowIndex: rowIndex,
          ),
        );

        if (v is num) {
          cell.value = v.toDouble();
        } else {
          cell.value = v.toString();
        }
      }

      if (selected['total'] == true) {
        grandTotal += _totalValue(p);
      }

      rowIndex++;
    }

    // Total row (Excel)
    if (selected['total'] == true) {
      final totalColIndex = _columnIndexOf(selected, 'total');
      if (totalColIndex != null) {
        sheet
            .cell(
              CellIndex.indexByColumnRow(
                columnIndex: totalColIndex - 1,
                rowIndex: rowIndex,
              ),
            )
            .value = _t('total');

        sheet
            .cell(
              CellIndex.indexByColumnRow(
                columnIndex: totalColIndex,
                rowIndex: rowIndex,
              ),
            )
            .value = grandTotal;
      }
    }

    // Auto column width
    for (var col = 0; col < headers.length; col++) {
      int maxLen = headers[col].toString().length;

      for (var r = headerRowIndex + 1; r <= rowIndex; r++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(
            columnIndex: col,
            rowIndex: r,
          ),
        );
        final v = cell.value;
        if (v != null) {
          final len = v.toString().length;
          if (len > maxLen) maxLen = len;
        }
      }

      sheet.setColWidth(col, (maxLen + 2).toDouble());
    }

    return Uint8List.fromList(excel.encode()!);
  }

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
  // PDF EXPORT (REWRITTEN)
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
      final hasArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(text);
      return hasArabic ? arabicFont : englishFont;
    }

    String fixArabic(String text) => text;

    final pdf = pw.Document();

    final storeName = _settings.storeName.trim().isEmpty
        ? _t('inventory_report')
        : _settings.storeName.trim();

    final isArabicApp = _settings.language == 'ar';

    // Build headers
    final headers = _buildHeaderList(selected)
        .map((h) => fixArabic(h))
        .toList();

    // Build data rows
    final data = products.map((p) {
      final row = <String>[];

      if (selected['barcode'] == true) row.add(fixArabic(p.barcode));
      if (selected['name'] == true) row.add(fixArabic(p.name));
      if (selected['category'] == true) row.add(fixArabic(p.category ?? ''));
      if (selected['stock'] == true) row.add(_stockDisplay(p));
      if (selected['purchase'] == true) {
        row.add(p.purchasePrice.toStringAsFixed(2));
      }
      if (selected['sell1'] == true) {
        row.add(p.sellPrice1.toStringAsFixed(2));
      }
      if (selected['sell2'] == true) {
        row.add(p.sellPrice2.toStringAsFixed(2));
      }
      if (selected['sell3'] == true) {
        row.add(p.sellPrice3.toStringAsFixed(2));
      }
      if (selected['total'] == true) {
        row.add(_totalValue(p).toStringAsFixed(2));
      }

      return row;
    }).toList();

    // -----------------------------------------------------------------------
    // PROPORTIONAL COLUMN WIDTHS (Option B)
    // -----------------------------------------------------------------------
    //
    // These ratios stay the same even if fewer columns are selected.
    //
    final fullRatios = <String, double>{
      'barcode': 1.8,
      'name': 2.4,
      'category': 1.6,
      'stock': 2.2,
      'purchase': 1.2,
      'sell1': 1.2,
      'sell2': 1.2,
      'sell3': 1.2,
      'total': 1.4,
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
      columnWidths[i] = pw.FlexColumnWidth(fullRatios[selectedKeys[i]]!);
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
          // Logo
          if (logoImage != null)
            pw.Center(
              child: pw.Image(
                logoImage!,
                width: 80,
                height: 80,
                fit: pw.BoxFit.contain,
              ),
            ),

          if (logoImage != null) pw.SizedBox(height: 8),

          // Store name
          pw.Center(
            child: pw.Text(
              fixArabic(storeName),
              style: pw.TextStyle(
                font: pickFont(storeName),
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),

          pw.SizedBox(height: 4),

          // Report title
          pw.Center(
            child: pw.Text(
              fixArabic(_t('inventory_report') + " - " + _formatDateTime()),
              style: pw.TextStyle(
                font: pickFont(_t('inventory_report')),
                fontSize: 10,
              ),
            ),
          ),

          pw.SizedBox(height: 16),

          // -------------------------------------------------------------------
          // TABLE
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
                      child: pw.Text(
                        h,
                        style: pw.TextStyle(
                          font: pickFont(h),
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                          fontSize: 10,
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
                          textDirection: RegExp(r'[\u0600-\u06FF]').hasMatch(cell)
                              ? pw.TextDirection.rtl
                              : pw.TextDirection.ltr,
                          child: pw.Text(
                            cell,
                            style: pw.TextStyle(
                              font: pickFont(cell),
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),

          // -------------------------------------------------------------------
          // TOTAL ROW BELOW TABLE (Option 2)
          // -------------------------------------------------------------------
          if (selected['total'] == true) ...[
            pw.SizedBox(height: 12),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text(
                  fixArabic(_t('total')),
                  style: pw.TextStyle(
                    font: pickFont(_t('total')),
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                pw.SizedBox(width: 6),
                pw.Text(
                  grandTotal.toStringAsFixed(2),
                  style: pw.TextStyle(
                    font: pickFont(grandTotal.toString()),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
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
