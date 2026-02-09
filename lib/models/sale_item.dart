class SaleItem {
  final int productId;
  final int quantity;
  final double price;

  SaleItem({
    required this.productId,
    required this.quantity,
    required this.price,
  });
}

class Sale {
  final int id;
  final List<SaleItem> items;
  final double total;
  final DateTime timestamp;

  Sale({
    required this.id,
    required this.items,
    required this.total,
    required this.timestamp,
  });
}
