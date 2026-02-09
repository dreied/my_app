import '../models/product.dart';
import '../models/cart_item.dart';

enum PriceMode { retail, wholesale } // retail = مفرق, wholesale = جملة
enum DiscountType { money, percent }

class CartController {
  PriceMode mode = PriceMode.retail; // default مفرق
  final List<CartItem> items = [];

  DiscountType discountType = DiscountType.money;
  double discount = 0;

  // Helper: get active price for a product
  double _activePrice(Product p) {
    return mode == PriceMode.retail ? p.sellPrice1 : p.sellPrice2;
  }

  // Helper: check if price is valid
  bool _isBelowPurchase(Product p, double price) {
    return price < p.purchasePrice;
  }

  // Add product to cart
  bool addToCart(Product product) {
    final price = _activePrice(product);

    // Block selling below purchase price
    if (_isBelowPurchase(product, price)) {
      return false;
    }

    final existing = items.where((e) => e.product.id == product.id).toList();

    if (existing.isNotEmpty) {
      existing.first.qty++;
    } else {
      items.add(
        CartItem(
          product: product,
          qty: 1,
          price: price,
        ),
      );
    }

    return true;
  }

  // Change quantity
  bool changeQty(Product product, int newQty) {
    final item = items.firstWhere((e) => e.product.id == product.id);

    final price = _activePrice(product);

    // Block selling below purchase price
    if (_isBelowPurchase(product, price)) {
      return false;
    }

    item.qty = newQty;
    item.price = price;

    return true;
  }

  // Remove item
  void remove(Product product) {
    items.removeWhere((e) => e.product.id == product.id);
  }

  // Switch between مفرق and جملة
  bool switchMode(PriceMode newMode) {
    // Validate BEFORE switching
    for (var item in items) {
      final newPrice = newMode == PriceMode.retail
          ? item.product.sellPrice1
          : item.product.sellPrice2;

      if (_isBelowPurchase(item.product, newPrice)) {
        return false; // Block switching
      }
    }

    // Safe to switch
    mode = newMode;

    // Update all prices
    for (var item in items) {
      item.price = _activePrice(item.product);
    }

    return true;
  }

  // Calculate total
  double get total {
    double sum = 0;
    for (var item in items) {
      sum += item.qty * item.price;
    }
    return sum;
  }

  double get finalTotal {
    if (discountType == DiscountType.money) {
      return total - discount;
    } else {
      return total - (total * (discount / 100));
    }
  }
}
