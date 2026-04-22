import '../database/app_database.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../models/customer.dart';
import 'package:sqflite/sqflite.dart';

enum PriceMode { retail, wholesale, special }

class CartController {
  CartController._private();
  static final CartController instance = CartController._private();

  Customer? selectedCustomer;

  bool autoPricing = false;

  PriceMode mode = PriceMode.retail;

  final List<CartItem> items = [];

  double discountPercent = 0.0;

  double get total {
    double sum = 0;
    for (var item in items) {
      sum += item.qty * item.price;
    }
    return sum;
  }

  double get discountAmount => total * (discountPercent / 100);
  double get totalAfterDiscount => total - discountAmount;

  // ---------------------------------------------------------------------------
  // PRICE HELPERS
  // ---------------------------------------------------------------------------
  double getPriceForMode(Product p, PriceMode m) {
    switch (m) {
      case PriceMode.retail:
        return p.sellPrice1;
      case PriceMode.wholesale:
        return p.sellPrice2;
      case PriceMode.special:
        return p.sellPrice3;
    }
  }

  int _levelForMode(PriceMode m) {
    switch (m) {
      case PriceMode.retail:
        return 1;
      case PriceMode.wholesale:
        return 2;
      case PriceMode.special:
        return 3;
    }
  }

  PriceMode _modeForLevel(int level) {
    switch (level) {
      case 1:
        return PriceMode.retail;
      case 2:
        return PriceMode.wholesale;
      case 3:
        return PriceMode.special;
      default:
        return PriceMode.retail;
    }
  }

  bool _isBelowPurchase(Product p, double price) {
    return price < p.purchasePrice;
  }

  // ---------------------------------------------------------------------------
  // LOAD SAVED PRICE LEVEL FOR CUSTOMER
  // ---------------------------------------------------------------------------
  Future<int?> _loadSavedPriceLevel(int productId) async {
    if (selectedCustomer == null) return null;

    final db = await AppDatabase.instance.database;
    final result = await db.query(
      'customer_product_prices',
      where: 'customer_id = ? AND product_id = ?',
      whereArgs: [selectedCustomer!.id, productId],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return result.first['price_level'] as int;
  }
// ---------------------------------------------------------------------------
// SAVE CUSTOM PRICE FOR CUSTOMER
// ---------------------------------------------------------------------------
Future<void> saveCustomPrice(Product p, double price) async {
  if (selectedCustomer == null || p.id == null) return;

  final db = await AppDatabase.instance.database;

  await db.insert(
    'customer_product_prices',
    {
      'customer_id': selectedCustomer!.id,
      'product_id': p.id,
      'price_level': 3, // special
      'custom_price': price,
    },
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

// ---------------------------------------------------------------------------
// LOAD LAST CUSTOM PRICE FOR CUSTOMER
// ---------------------------------------------------------------------------
Future<double?> getLastCustomPrice(Product p) async {
  if (selectedCustomer == null || p.id == null) return null;

  final db = await AppDatabase.instance.database;

  final result = await db.query(
    'customer_product_prices',
    where: 'customer_id = ? AND product_id = ? AND price_level = 3',
    whereArgs: [selectedCustomer!.id, p.id],
    limit: 1,
  );

  if (result.isEmpty) return null;

  return result.first['custom_price'] as double?;
}

  // ---------------------------------------------------------------------------
  // SUGGESTED PRICE MODE
  // ---------------------------------------------------------------------------
  Future<PriceMode> getSuggestedPriceMode(Product product) async {
    if (autoPricing && selectedCustomer != null && product.id != null) {
      final saved = await _loadSavedPriceLevel(product.id!);
      if (saved != null) {
        return _modeForLevel(saved);
      }
    }
    return mode;
  }

  // ---------------------------------------------------------------------------
  // ADD TO CART WITH CUSTOM PRICE (used by popup)
  // ---------------------------------------------------------------------------
  Future<bool> addToCartWithCustomPrice(
    Product product,
    int qty,
    PriceMode priceMode,
    double customPrice,
  ) async {
    if (selectedCustomer == null) return false;

    final existing = items.where((e) => e.product.id == product.id).toList();
    int currentQty = existing.isNotEmpty ? existing.first.qty : 0;

    if (currentQty + qty > product.stock) return false;

    double price = (priceMode == PriceMode.special)
        ? customPrice
        : getPriceForMode(product, priceMode);

    int level = (priceMode == PriceMode.special)
        ? 3
        : _levelForMode(priceMode);

    if (_isBelowPurchase(product, price)) return false;

    if (existing.isNotEmpty) {
      existing.first.qty += qty;
      existing.first.price = price;
      existing.first.priceLevel = level;
    } else {
      items.add(
        CartItem(
          product: product,
          qty: qty,
          price: price,
          priceLevel: level,
        ),
      );
    }

    return true;
  }

  // ---------------------------------------------------------------------------
  // ADD TO CART (used by scanner and + button)
  // ---------------------------------------------------------------------------
  Future<bool> addToCart(Product product) async {
    if (selectedCustomer == null) return false;

    final existing = items.where((e) => e.product.id == product.id).toList();
    int currentQty = existing.isNotEmpty ? existing.first.qty : 0;

    if (currentQty + 1 > product.stock) return false;

    double price;
    int priceLevel;

    if (autoPricing && selectedCustomer != null) {
      final saved = await _loadSavedPriceLevel(product.id!);

      if (saved != null) {
        priceLevel = saved;
        price = getPriceForMode(product, _modeForLevel(saved));
      } else {
        priceLevel = 1;
        price = product.sellPrice1;
      }
    } else {
      priceLevel = _levelForMode(mode);
      price = getPriceForMode(product, mode);
    }

    if (_isBelowPurchase(product, price)) return false;

    if (existing.isNotEmpty) {
      existing.first.qty++;
      existing.first.price = price;
      existing.first.priceLevel = priceLevel;
    } else {
      items.add(
        CartItem(
          product: product,
          qty: 1,
          price: price,
          priceLevel: priceLevel,
        ),
      );
    }

    return true;
  }

  // ---------------------------------------------------------------------------
  // CHANGE QTY
  // ---------------------------------------------------------------------------
  Future<bool> changeQty(Product product, int newQty) async {
    if (selectedCustomer == null) return false;

    if (newQty > product.stock) return false;

    final item = items.firstWhere((e) => e.product.id == product.id);

    double price;
    int priceLevel;

    if (autoPricing && selectedCustomer != null) {
      final saved = await _loadSavedPriceLevel(product.id!);

      if (saved != null) {
        priceLevel = saved;
        price = getPriceForMode(product, _modeForLevel(saved));
      } else {
        priceLevel = 1;
        price = product.sellPrice1;
      }
    } else {
      priceLevel = _levelForMode(mode);
      price = getPriceForMode(product, mode);
    }

    if (_isBelowPurchase(product, price)) return false;

    item.qty = newQty;
    item.price = price;
    item.priceLevel = priceLevel;

    return true;
  }

  // ---------------------------------------------------------------------------
  // REMOVE ITEM
  // ---------------------------------------------------------------------------
  void remove(Product product) {
    items.removeWhere((e) => e.product.id == product.id);
  }

  // ---------------------------------------------------------------------------
  // SWITCH MODE (Retail / Wholesale / Special)
  // ---------------------------------------------------------------------------
  bool switchMode(PriceMode newMode) {
    if (autoPricing) return false;

    for (var item in items) {
      final newPrice = getPriceForMode(item.product, newMode);
      if (_isBelowPurchase(item.product, newPrice)) {
        return false;
      }
    }

    mode = newMode;

    for (var item in items) {
      item.price = getPriceForMode(item.product, newMode);
      item.priceLevel = _levelForMode(newMode);
    }

    return true;
  }
}
