class InventoryLog {
  final int id;
  final int productId;
  final int change; // +10 restock, -1 sale
  final DateTime timestamp;

  InventoryLog({
    required this.id,
    required this.productId,
    required this.change,
    required this.timestamp,
  });
}
