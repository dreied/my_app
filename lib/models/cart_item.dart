import 'product.dart';

class CartItem {
  final Product product;
  int qty;
  double price; // current active price (مفرق or جملة)

  CartItem({
    required this.product,
    required this.qty,
    required this.price,
  });

  double get lineTotal => qty * price;
}
