import '../db/return_dao.dart';
import '../db/sale_items_dao.dart';
import '../controllers/product_controller.dart';
import '../db/customer_dao.dart';
import '../db/customer_payments_dao.dart';

class ReturnController {
  final ReturnDao _returnDao = ReturnDao();
  final SaleItemsDao _saleItemsDao = SaleItemsDao();
  final ProductController _productController = ProductController();
  final CustomerDao _customerDao = CustomerDao();
  final CustomerPaymentsDao _paymentsDao = CustomerPaymentsDao();

  Future<void> processReturn({
    required int saleId,
    required int productId,
    required int qty,
    required double price, // discounted unit price
    required String reason,
    required bool restock,
    required bool refund, // true = cash refund, false = credit to balance
    int? customerId,
  }) async {
    // ---------------------------------------------------------
    // 1) Validate remaining quantity
    // ---------------------------------------------------------
    final saleItem = await _saleItemsDao.getSaleItem(saleId, productId);

    final soldQty = saleItem['qty'] as int;
    final returnedQty = saleItem['returned_qty'] as int? ?? 0;
    final remaining = soldQty - returnedQty;

    if (qty > remaining) {
      throw Exception(
        "You already returned $returnedQty of this item. Only $remaining left.",
      );
    }

    // ---------------------------------------------------------
    // 2) Insert return record (discounted price)
    // ---------------------------------------------------------
    await _returnDao.insertReturn(
      saleId: saleId,
      productId: productId,
      qty: qty,
      price: price, // discounted price stored
      reason: reason,
      restock: restock,
      refund: refund,
    );

    // ---------------------------------------------------------
    // 3) Update returned quantity in sale_items
    // ---------------------------------------------------------
    await _saleItemsDao.updateReturnedQty(
      saleId: saleId,
      productId: productId,
      newReturnedQty: returnedQty + qty,
    );

    // ---------------------------------------------------------
    // 4) Restock inventory (if enabled)
    // ---------------------------------------------------------
    if (restock) {
      final product = await _productController.getProduct(productId);
      final newStock = product.stock + qty;
      await _productController.updateStock(productId, newStock);
    }

    // ---------------------------------------------------------
    // 5) Update customer balance or record cash refund
    // ---------------------------------------------------------
    if (customerId != null) {
      final customer = await _customerDao.getCustomerById(customerId);

      if (customer != null) {
        final returnValue = qty * price; // discounted refund

        if (refund) {
          // Cash refund → no balance change, no payment entry
        } else {
          // Add credit to customer balance (blue entry)
          await _paymentsDao.addReturnEntry(
            customerId: customerId,
            amount: returnValue,
            saleId: saleId,
          );
        }
      }
    }

    // ---------------------------------------------------------
    // 6) Insert return history (discounted price)
    // ---------------------------------------------------------
    await _returnDao.insertReturnHistory(
      saleId: saleId,
      productId: productId,
      qty: qty,
      price: price, // discounted price
      datetime: DateTime.now().toIso8601String(),
    );
  }
}
