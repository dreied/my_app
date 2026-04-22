import 'package:flutter/material.dart';

import '../controllers/return_controller.dart';
import '../database/app_database.dart';
import '../services/receipt_service.dart';
import '../generated/app_localizations.dart';
import '../utils/pin_guard.dart';
import '../models/customer.dart';
import '../db/customer_payments_dao.dart';
import '../services/escpos_receipt_service.dart';

class ReturnSalePage extends StatefulWidget {
  final int saleId;

  const ReturnSalePage({super.key, required this.saleId});

  @override
  State<ReturnSalePage> createState() => _ReturnSalePageState();
}

class _ReturnSalePageState extends State<ReturnSalePage> {
  final ReturnController _returnController = ReturnController();
  final CustomerPaymentsDao _paymentsDao = CustomerPaymentsDao();

  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _items = [];
  Map<int, int> _returnQty = {};

  String _reason = "Expired";
  bool _restock = true;
  bool _refund = false;

  String? _originalSaleDate;
  int? _customerId;
  Customer? customer;

  double _discountPercent = 0.0;
  double _discountAmount = 0.0;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final db = await AppDatabase.instance.database;

    final result = await db.rawQuery('''
      SELECT 
        sale_items.*, 
        sale_items.returned_qty,
        products.name, 
        products.stock, 
        sales.datetime AS sale_date,
        sales.customer_id,
        sales.discount_percent,
        sales.discount_amount
      FROM sale_items
      JOIN products ON sale_items.product_id = products.id
      JOIN sales ON sales.id = sale_items.sale_id
      WHERE sale_items.sale_id = ?
    ''', [widget.saleId]);

    if (result.isNotEmpty) {
      _originalSaleDate = result.first['sale_date'] as String?;
      _customerId = result.first['customer_id'] as int?;
      _discountPercent =
          (result.first['discount_percent'] as num?)?.toDouble() ?? 0.0;
      _discountAmount =
          (result.first['discount_amount'] as num?)?.toDouble() ?? 0.0;
    }

    if (_customerId != null) {
      final customerResult = await db.query(
        'customers',
        where: 'id = ?',
        whereArgs: [_customerId],
      );

      if (customerResult.isNotEmpty) {
        customer = Customer(
          id: customerResult.first['id'] as int,
          name: customerResult.first['name'] as String,
          phone: customerResult.first['phone']?.toString(),
          address: customerResult.first['address']?.toString(),
          notes: customerResult.first['notes']?.toString(),
          balance: (customerResult.first['balance'] as num).toDouble(),
          initialBalance:
              (customerResult.first['initial_balance'] as num?)?.toDouble() ??
                  0,
          initialBalanceDate:
              customerResult.first['initial_balance_date']?.toString(),
        );
      }
    }

    setState(() {
      _items = result;
      _returnQty = {
        for (var item in _items) item['product_id'] as int: 0,
      };
      _isLoading = false;
    });
  }

  void _returnWholeSale() {
    setState(() {
      for (var item in _items) {
        final productId = item['product_id'] as int;
        final sold = item['qty'] as int;
        final returned = (item['returned_qty'] as int?) ?? 0;
        final remaining = sold - returned;
        _returnQty[productId] = remaining;
      }
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  double _calculateRefundTotal() {
    double total = 0;

    for (var item in _items) {
      final productId = item['product_id'] as int;
      final sold = item['qty'] as int;
      final returned = (item['returned_qty'] as int?) ?? 0;
      final remaining = sold - returned;
      final qty = _returnQty[productId] ?? 0;

      if (qty > remaining) return -1;

      final unitPrice = (item['price'] as num).toDouble();
      final discountedUnitPrice =
          unitPrice * (1 - (_discountPercent / 100.0));

      total += qty * discountedUnitPrice;
    }

    return total;
  }

  Future<void> _processReturn(double refundTotal) async {
    final List<Map<String, dynamic>> returnedItems = [];

    for (var item in _items) {
      final productId = item['product_id'] as int;
      final sold = item['qty'] as int;
      final returned = (item['returned_qty'] as int?) ?? 0;
      final remaining = sold - returned;
      final qty = _returnQty[productId] ?? 0;

      if (qty > 0 && qty <= remaining) {
        final unitPrice = (item['price'] as num).toDouble();
        final discountedUnitPrice =
            unitPrice * (1 - (_discountPercent / 100.0));

        await _returnController.processReturn(
          saleId: widget.saleId,
          productId: productId,
          qty: qty,
          price: discountedUnitPrice,
          reason: _reason,
          restock: _restock,
          refund: _refund,
          customerId: _customerId,
        );

        returnedItems.add({
          "name": item['name'],
          "qty": qty,
          "price": discountedUnitPrice,
          "total": qty * discountedUnitPrice,
        });
      }
    }

    await _showPrintDialog(returnedItems, refundTotal);

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _submitReturn() async {
    final t = AppLocalizations.of(context)!;

    final refundTotal = _calculateRefundTotal();

    if (refundTotal < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.invalidReturnQty)),
      );
      return;
    }

    if (refundTotal == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.noItemsSelected)),
      );
      return;
    }

    final confirmed = await _showReturnConfirmDialog(refundTotal);
    if (confirmed != true) return;

    final pinOk = await requireManagerPin(context);
    if (!pinOk) return;

    await _processReturn(refundTotal);
  }

  Future<bool?> _showReturnConfirmDialog(double refundTotal) {
    final t = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.undo,
                  size: 40,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  t.confirmReturnTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          t.totalRefund,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Text(
                        refundTotal.toStringAsFixed(2),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            Navigator.of(context, rootNavigator: true)
                                .pop(false),
                        child: Text(t.cancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () =>
                            Navigator.of(context, rootNavigator: true)
                                .pop(true),
                        child: Text(t.ok),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showPrintDialog(
    List<Map<String, dynamic>> returnedItems,
    double refundTotal,
  ) async {
    final t = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.print,
                  size: 40,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  t.printOptions,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Column(
                  children: [
                  FilledButton.tonal(
                    onPressed: () async {
                      Navigator.of(context, rootNavigator: true).pop();
                      await ReceiptService.previewReturnPdf(
                        items: returnedItems,
                        refundTotal: refundTotal,
                        reason: _reason,
                        restock: _restock,
                        refund: _refund,
                        originalSaleId: widget.saleId,
                        originalSaleDate: _originalSaleDate ?? "",
                        customer: customer!,
                        t: t,
                      );
                    },
                    child: Text("📄 ${t.pdf} (${t.previewPdf})"),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.tonal(
                    onPressed: () async {
                      Navigator.of(context, rootNavigator: true).pop();
                      await ReceiptService.saveReturnPdf(
                        items: returnedItems,
                        refundTotal: refundTotal,
                        reason: _reason,
                        restock: _restock,
                        refund: _refund,
                        originalSaleId: widget.saleId,
                        originalSaleDate: _originalSaleDate ?? "",
                        customer: customer!,
                        t: t,
                      );
                    },
                    child: Text("💾 ${t.save} PDF"),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.tonal(
                    onPressed: () async {
                      Navigator.of(context, rootNavigator: true).pop();
                      await ReceiptService.shareReturnPdf(
                        items: returnedItems,
                        refundTotal: refundTotal,
                        reason: _reason,
                        restock: _restock,
                        refund: _refund,
                        originalSaleId: widget.saleId,
                        originalSaleDate: _originalSaleDate ?? "",
                        customer: customer!,
                        t: t,
                      );
                    },
                    child: Text("📤 ${t.share} PDF"),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.tonal(
                    onPressed: () async {
                      Navigator.of(context, rootNavigator: true).pop();
                      try {
                        await EscposReceiptService.printReturnReceipt(
                          items: returnedItems,
                          refundTotal: refundTotal,
                          reason: _reason,
                          restock: _restock,
                          refund: _refund,
                          originalSaleId: widget.saleId,
                          originalSaleDate: _originalSaleDate ?? "",
                          customer: customer!,
                          t: t,
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(content: Text("Printer not connected")),
                        );
                      }
                    },
                    child: Text("🖨️ ${t.printBluetooth}"),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () =>
                        Navigator.of(context, rootNavigator: true).pop(),
                    child: Text(t.skip),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
 }

  Widget _buildHeader(AppLocalizations t) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.returnItemsHeader,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          if (_originalSaleDate != null)
            Text(
              _originalSaleDate!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
        ],
      ),
    );
  }

  Widget _buildItemCard(
    Map<String, dynamic> item,
    AppLocalizations t,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    final productId = item['product_id'] as int;
    final soldQty = item['qty'] as int;
    final returnedQty = (item['returned_qty'] as int?) ?? 0;
    final remaining = soldQty - returnedQty;
    final selectedQty = _returnQty[productId] ?? 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item['name']?.toString() ?? '',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.shopping_bag_outlined,
                    size: 18, color: colorScheme.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "${t.sold}: $soldQty | ${t.returned}: $returnedQty | ${t.remaining}: $remaining",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
           Row(
  children: [
    Text(
      t.quantity,
      style: Theme.of(context).textTheme.bodyMedium,
    ),
    const Spacer(),
    Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.6),
        borderRadius: BorderRadius.circular(40),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            iconSize: 22,
            icon: Icon(
              Icons.remove_circle_outline,
              color: remaining == 0
                  ? colorScheme.onSurface.withOpacity(0.3)
                  : colorScheme.error,
            ),
            onPressed: remaining == 0
                ? null
                : () {
                    if (selectedQty > 0) {
                      setState(() {
                        _returnQty[productId] = selectedQty - 1;
                      });
                    }
                  },
          ),

          // ⭐ Editable quantity field
          SizedBox(
            width: 45,
            child: TextField(
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              controller: TextEditingController(text: selectedQty.toString())
                ..selection = TextSelection.fromPosition(
                  TextPosition(offset: selectedQty.toString().length),
                ),
              onChanged: (value) {
                final parsed = int.tryParse(value) ?? 0;

                setState(() {
                  if (parsed < 0) {
                    _returnQty[productId] = 0;
                  } else if (parsed > remaining) {
                    _returnQty[productId] = remaining;
                  } else {
                    _returnQty[productId] = parsed;
                  }
                });
              },
            ),
          ),

          IconButton(
            visualDensity: VisualDensity.compact,
            iconSize: 22,
            icon: Icon(
              Icons.add_circle_outline,
              color: remaining == 0
                  ? colorScheme.onSurface.withOpacity(0.3)
                  : Colors.green.shade400,
            ),
            onPressed: remaining == 0
                ? null
                : () {
                    if (selectedQty < remaining) {
                      setState(() {
                        _returnQty[productId] = selectedQty + 1;
                      });
                    }
                  },
          ),

          // ⭐ MAX button
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 32),
            ),
            onPressed: remaining == 0
                ? null
                : () {
                    setState(() {
                      _returnQty[productId] = remaining;
                    });
                  },
            child: Text(
              "MAX",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green.shade600,
              ),
            ),
          ),
        ],
      ),
    ),
  ],
)

          ],
        ),
      ),
    );
  }

  Widget _buildReasonDropdown(AppLocalizations t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: DropdownButtonFormField<String>(
        value: _reason,
        decoration: InputDecoration(
          labelText: t.returnReason,
          border: const OutlineInputBorder(),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        items: [
          DropdownMenuItem(
            value: "Expired",
            child: Text(t.reasonExpired),
          ),
          DropdownMenuItem(
            value: "Damaged",
            child: Text(t.reasonDamaged),
          ),
          DropdownMenuItem(
            value: "Wrong item",
            child: Text(t.reasonWrongItem),
          ),
          DropdownMenuItem(
            value: "Customer changed mind",
            child: Text(t.reasonCustomerChangedMind),
          ),
          DropdownMenuItem(
            value: "Other",
            child: Text(t.reasonOther),
          ),
        ],
        onChanged: (v) => setState(() => _reason = v!),
      ),
    );
  }

  Widget _buildOptionsSection(AppLocalizations t) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.refundOptions,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Card(
            elevation: 0,
            color: colorScheme.surfaceVariant.withOpacity(0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: Row(
                    children: [
                      Icon(Icons.attach_money,
                          color: Colors.green.shade400, size: 22),
                      const SizedBox(width: 8),
                      Text(t.refundInCash),
                    ],
                  ),
                  value: _refund,
                  onChanged: (v) => setState(() => _refund = v),
                ),
                const Divider(height: 0),
                SwitchListTile(
                  title: Text(t.restockReturnedItems),
                  value: _restock,
                  onChanged: (v) => setState(() => _restock = v),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingBottomBar(AppLocalizations t) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      minimum: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface.withOpacity(0.95),
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: FilledButton.tonal(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: _returnWholeSale,
                child: Text(
                  t.fullReturn,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.green.shade400,
                ),
                onPressed: _submitReturn,
                child: Text(
                  t.confirmReturn,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

 @override
Widget build(BuildContext context) {
  final t = AppLocalizations.of(context)!;

  return Scaffold(
    appBar: AppBar(
      title: Text(t.returnItems),
      centerTitle: true,
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    floatingActionButton:
        _items.isEmpty || _isLoading ? null : _buildFloatingBottomBar(t),

    body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _items.isEmpty
            ? Center(
                child: Text(
                  t.noItemsAvailable,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              )
            : ListView(
                controller: _scrollController,
                padding: const EdgeInsets.only(bottom: 140),
                children: [
                  _buildHeader(t),
                  const SizedBox(height: 4),

                  // All item cards
                  for (final item in _items) _buildItemCard(item, t),

                  // Reason dropdown
                  _buildReasonDropdown(t),

                  // Refund + Restock toggles
                  _buildOptionsSection(t),

                  const SizedBox(height: 40),
                ],
              ),
  );
}

}
