import 'product.dart';

class CartItem {
  final Product product;
  int qty;
  double price;      // actual price used
  int priceLevel;    // 1 = sellPrice1, 2 = sellPrice2, 3 = sellPrice3
  String get unit => product.unit;


  CartItem({
    required this.product,
    required this.qty,
    required this.price,
    required this.priceLevel,
  });

  double get lineTotal {
  double raw = qty * price;
  return double.parse(raw.toStringAsFixed(3));
}

}
