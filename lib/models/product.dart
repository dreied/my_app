class Product {
  final int? id;
  final String name;
  final double purchasePrice;
  final double sellPrice1;
  final double sellPrice2;
  final double sellPrice3;
  final int stock;

  final String unit; // "pieces", "half", "dozen"
  final String barcode;
  final String? category;

  // 0 = active, 1 = deleted (soft delete)
  final int isDeleted;

  Product({
    this.id,
    required this.name,
    required this.purchasePrice,
    required this.sellPrice1,
    required this.sellPrice2,
    required this.sellPrice3,
    required this.stock,
    required this.unit,
    required this.barcode,
    this.category,
    this.isDeleted = 0,
  });

  Product copyWith({
    int? id,
    String? name,
    double? purchasePrice,
    double? sellPrice1,
    double? sellPrice2,
    double? sellPrice3,
    int? stock,
    String? unit,
    String? barcode,
    String? category,
    int? isDeleted,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      sellPrice1: sellPrice1 ?? this.sellPrice1,
      sellPrice2: sellPrice2 ?? this.sellPrice2,
      sellPrice3: sellPrice3 ?? this.sellPrice3,
      stock: stock ?? this.stock,
      unit: unit ?? this.unit,
      barcode: barcode ?? this.barcode,
      category: category ?? this.category,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'purchase_price': purchasePrice,
      'sell_price1': sellPrice1,
      'sell_price2': sellPrice2,
      'sell_price3': sellPrice3,
      'stock': stock,
      'unit': unit,
      'barcode': barcode,
      'category': category,
      'is_deleted': isDeleted,
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
      // backward compatible
      unit: map['unit']?.toString() ?? "pieces",
      barcode: map['barcode']?.toString() ?? "",
      category: map['category'] as String?,
      isDeleted: (map['is_deleted'] as int?) ?? 0,
    );
  }
}
