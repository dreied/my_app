class Product {
  final int? id;
  final String name;
  final double purchasePrice;
  final double sellPrice1;
  final double sellPrice2;
  final double sellPrice3;
  final int stock;

  // NEW FIELD (placed under stock exactly as you requested)
  final String unit; // "pieces", "half", "dozen"

  final String barcode;
  final String? category;

  Product({
    this.id,
    required this.name,
    required this.purchasePrice,
    required this.sellPrice1,
    required this.sellPrice2,
    required this.sellPrice3,
    required this.stock,
    required this.unit, // NEW
    required this.barcode,
    this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'purchase_price': purchasePrice,
      'sell_price1': sellPrice1,
      'sell_price2': sellPrice2,
      'sell_price3': sellPrice3,
      'stock': stock,
      'unit': unit, // NEW
      'barcode': barcode,
      'category': category,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      name: map['name'] as String,
      purchasePrice: (map['purchase_price'] as num).toDouble(),
      sellPrice1: (map['sell_price1'] as num).toDouble(),
      sellPrice2: (map['sell_price2'] as num).toDouble(),
      sellPrice3: (map['sell_price3'] as num).toDouble(),
      stock: map['stock'] as int,

      // NEW — backward compatible: if missing, default to "pieces"
      unit: map['unit']?.toString() ?? "pieces",

      barcode: map['barcode'] ?? '',
      category: map['category'],
    );
  }
}
