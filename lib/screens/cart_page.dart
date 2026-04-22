import 'package:flutter/material.dart';
import '../controllers/cart_controller.dart';
import '../controllers/product_controller.dart';
import '../models/product.dart';
import 'checkout_page.dart';
import 'customer_select_page.dart';
import '../widgets/embedded_scanner_box.dart';
import '../generated/app_localizations.dart';
import '../models/cart_item.dart';

class CartPage extends StatefulWidget {
  final CartController cart;

  const CartPage({super.key, required this.cart});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final ProductController _productController = ProductController();
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";
  bool showScanner = false;

  String _unit(int n, BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return n == 1 ? t.piece : t.pieces;
  }

  String _stockLabel(Product product, BuildContext context) {
    final t = AppLocalizations.of(context)!;

    int dozens = product.stock ~/ 12;
    int remainder = product.stock % 12;

    return "${t.availableStock}: $dozens ${t.dozen} و $remainder ${t.pieces}";
  }

  @override
  void initState() {
    super.initState();
    _ensureCustomerSelected();
  }

  Future<void> _ensureCustomerSelected() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.cart.selectedCustomer == null) {
        final customer = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CustomerSelectPage()),
        );

        if (customer != null) {
          setState(() {
            widget.cart.selectedCustomer = customer;
          });
        }
      }
    });
  }

  // ---------------------------------------------------------------------------
  // PRICE CHANGE INSIDE CART (tap on price)
  // ---------------------------------------------------------------------------
  Future<void> _changeItemPrice(CartItem item) async {
    final t = AppLocalizations.of(context)!;

    PriceMode selected = PriceMode.values[item.priceLevel - 1];
    double customPrice = item.price;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setStateDialog) {
            return AlertDialog(
              title: Text(item.product.name),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: Text(t.retail),
                        selected: selected == PriceMode.retail,
                        onSelected: (_) {
                          setStateDialog(() {
                            selected = PriceMode.retail;
                            customPrice = item.product.sellPrice1;
                          });
                        },
                      ),
                      ChoiceChip(
                        label: Text(t.wholesale),
                        selected: selected == PriceMode.wholesale,
                        onSelected: (_) {
                          setStateDialog(() {
                            selected = PriceMode.wholesale;
                            customPrice = item.product.sellPrice2;
                          });
                        },
                      ),
                      ChoiceChip(
                        label: Text(t.special),
                        selected: selected == PriceMode.special,
                        onSelected: (_) {
                          setStateDialog(() {
                            selected = PriceMode.special;
                          });
                        },
                      ),
                    ],
                  ),

                  if (selected == PriceMode.special)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: t.customPrice,
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (v) {
                          customPrice = double.tryParse(v) ?? 0;
                        },
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text(t.ok),
                  onPressed: () {
                    if (selected == PriceMode.special && customPrice <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(t.customPriceRequired),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    item.priceLevel = selected.index + 1;
                    item.price = customPrice;
                    Navigator.pop(ctx);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
Future<void> _showAddProductDialog(Product p) async {
  final t = AppLocalizations.of(context)!;

  int qty = 1;
  String unit = "pieces";

  // Load last custom price
  double? lastCustomPrice = await widget.cart.getLastCustomPrice(p);

  // If last custom price exists → auto-select custom mode
  PriceMode selectedMode =
      lastCustomPrice != null ? PriceMode.special : await widget.cart.getSuggestedPriceMode(p);

  double customPrice = lastCustomPrice ?? 0;

  await showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              p.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // STOCK BOX
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _stockLabel(p, context),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  Text(t.quantity, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  // QUANTITY + UNIT (RESPONSIVE)
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: t.quantity,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onChanged: (v) => qty = int.tryParse(v) ?? 1,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 3,
                        child: Wrap(
                          spacing: 8,
                          children: [
                            ChoiceChip(
                              label: Text(t.pieces),
                              selected: unit == "pieces",
                              onSelected: (_) => setStateDialog(() => unit = "pieces"),
                            ),
                            ChoiceChip(
                              label: Text(t.dozen),
                              selected: unit == "dozen",
                              onSelected: (p.stock >= 12)
                                  ? (_) => setStateDialog(() => unit = "dozen")
                                  : null,
                              disabledColor: Colors.grey.shade300,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  Text(t.price, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  // PRICE MODE (RESPONSIVE)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: Text(t.retail),
                        selected: selectedMode == PriceMode.retail,
                        onSelected: (_) => setStateDialog(() {
                          selectedMode = PriceMode.retail;
                        }),
                      ),
                      ChoiceChip(
                        label: Text(t.wholesale),
                        selected: selectedMode == PriceMode.wholesale,
                        onSelected: (_) => setStateDialog(() {
                          selectedMode = PriceMode.wholesale;
                        }),
                      ),
                      ChoiceChip(
                        label: Text(t.custom),
                        selected: selectedMode == PriceMode.special,
                        onSelected: (_) => setStateDialog(() {
                          selectedMode = PriceMode.special;
                        }),
                      ),
                    ],
                  ),

                  if (selectedMode == PriceMode.special) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: TextEditingController(
                        text: customPrice > 0 ? customPrice.toString() : "",
                      ),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: t.customPrice,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onChanged: (v) {
                        customPrice = double.tryParse(v) ?? 0;
                        if (customPrice < p.purchasePrice) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(t.cantSellBelowPurchase),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ],
              ),
            ),

            actions: [
              TextButton(
                child: Text(t.add),
                onPressed: () async {
                  int finalQty = unit == "dozen" ? qty * 12 : qty;

                  if (finalQty > p.stock) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("${t.notEnoughStock} ${p.stock} ${_unit(p.stock, context)}"),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  if (selectedMode == PriceMode.special && customPrice <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(t.customPriceRequired),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // SAVE CUSTOM PRICE
                  if (selectedMode == PriceMode.special) {
                    await widget.cart.saveCustomPrice(p, customPrice);
                  }

                  final ok = await widget.cart.addToCartWithCustomPrice(
                    p,
                    finalQty,
                    selectedMode,
                    selectedMode == PriceMode.special
                        ? customPrice
                        : widget.cart.getPriceForMode(p, selectedMode),
                  );

                  if (!ok) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("${t.notEnoughStock} ${p.stock} ${_unit(p.stock, context)}"),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  Navigator.pop(dialogContext);
                  setState(() {});
                },
              ),
            ],
          );
        },
      );
    },
  );
}



  // ---------------------------------------------------------------------------
  // SEARCH PRODUCT
  // ---------------------------------------------------------------------------
  Future<void> _searchProduct() async {
    final t = AppLocalizations.of(context)!;

    if (widget.cart.selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.selectCustomerFirst),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (searchQuery.isEmpty) return;

    Product? p = await _productController.getByBarcode(searchQuery);

    if (p == null) {
      final all = await _productController.loadProducts();

      final matches = all
          .where((prod) =>
              prod.name.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();

      if (matches.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.productNotFound)),
        );
        return;
      }

      if (matches.length == 1) {
        p = matches.first;
      } else {
        p = await showDialog<Product>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: Text(t.selectProduct),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: matches.length,
                  itemBuilder: (_, i) {
                    final prod = matches[i];
                    return ListTile(
                      title: Text("${prod.name} (${_stockLabel(prod, context)})"),
                      subtitle: Text("${t.barcode}: ${prod.barcode}"),
                      onTap: () => Navigator.pop(dialogContext, prod),
                    );
                  },
                ),
              ),
            );
          },
        );

        if (p == null) return;
      }
    }

    _searchController.clear();
    searchQuery = "";

    await _showAddProductDialog(p);
  }

  // ---------------------------------------------------------------------------
  // BUILD UI
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final items = widget.cart.items;

    final title = widget.cart.selectedCustomer == null
        ? t.createSale
        : t.saleFor(widget.cart.selectedCustomer!.name);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: [
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () async {
                final customer = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CustomerSelectPage()),
                );

                if (customer != null) {
                  setState(() {
                    widget.cart.selectedCustomer = customer;
                  });
                }
              },
            ),
          ],
        ),

        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  children: [
                    // SEARCH BAR
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: t.enterBarcodeOrName,
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onChanged: (v) => searchQuery = v,
                              onSubmitted: (_) => _searchProduct(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            icon: const Icon(Icons.qr_code_scanner, size: 30),
                            onPressed: () {
                              setState(() => showScanner = !showScanner);
                            },
                          ),
                        ],
                      ),
                    ),

                    // SCANNER
                    if (showScanner)
                      SizedBox(
                        height: 180,
                        child: EmbeddedScannerBox(
                          onScanned: (barcode) async {
                            final t = AppLocalizations.of(context)!;

                            if (widget.cart.selectedCustomer == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(t.selectCustomerFirst),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            Product? p =
                                await _productController.getByBarcode(barcode);

                            if (p == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(t.productNotFound)),
                              );
                              return;
                            }

                            await _showAddProductDialog(p);

                            setState(() => showScanner = false);
                          },
                        ),
                      ),

                    // AUTO PRICING SWITCH
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          const Icon(Icons.bolt, color: Colors.amber),
                          const SizedBox(width: 8),
                          Text(
                            t.autoPricing,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Switch(
                            value: widget.cart.autoPricing,
                            onChanged: (v) {
                              setState(() {
                                widget.cart.autoPricing = v;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    // MANUAL PRICE MODE
                    if (!widget.cart.autoPricing)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ChoiceChip(
                            label: Text(t.retail),
                            selected: widget.cart.mode == PriceMode.retail,
                            onSelected: (_) {
                              if (!widget.cart.switchMode(PriceMode.retail)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(t.cannotSwitchMode),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              setState(() {});
                            },
                          ),
                          const SizedBox(width: 10),
                          ChoiceChip(
                            label: Text(t.wholesale),
                            selected: widget.cart.mode == PriceMode.wholesale,
                            onSelected: (_) {
                              if (!widget.cart.switchMode(PriceMode.wholesale)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(t.cannotSwitchMode),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              setState(() {});
                            },
                          ),
                          const SizedBox(width: 10),
                          ChoiceChip(
                            label: Text(t.special),
                            selected: widget.cart.mode == PriceMode.special,
                            onSelected: (_) {
                              if (!widget.cart.switchMode(PriceMode.special)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(t.cannotSwitchMode),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              setState(() {});
                            },
                          ),
                        ],
                      ),

                    // CART ITEMS
                    ListView.builder(
                      itemCount: items.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (_, i) {
                        final item = items[i];

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          child: ListTile(
                            title: Text(item.product.name),
                            subtitle: Text(
                              "${t.qty}: ${item.qty}   ${t.price}: ${item.price.toStringAsFixed(2)}",
                            ),

                            // PRICE CLICKABLE
                            trailing: GestureDetector(
                              onTap: () async {
                                await _changeItemPrice(item);
                                setState(() {});
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    item.price.toStringAsFixed(2),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  Text(
                                    item.lineTotal.toStringAsFixed(2),
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),

                            leading: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () async {
                                    if (item.qty > 1) {
                                      if (!await widget.cart.changeQty(
                                        item.product,
                                        item.qty - 1,
                                      )) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "${t.notEnoughStock} ${item.product.stock} ${_unit(item.product.stock, context)}",
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        return;
                                      }
                                    } else {
                                      widget.cart.remove(item.product);
                                    }
                                    setState(() {});
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () async {
                                    if (!await widget.cart.changeQty(
                                      item.product,
                                      item.qty + 1,
                                    )) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "${t.notEnoughStock} ${item.product.stock} ${_unit(item.product.stock, context)}",
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }
                                    setState(() {});
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    widget.cart.remove(item.product);
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
// TOTAL + DISCOUNT
Padding(
  padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        "${t.total}: ${widget.cart.total.toStringAsFixed(2)}",
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 8),

      TextField(
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: t.discountPercent,
          suffixText: "%",
        ),
        onChanged: (value) {
          widget.cart.discountPercent = double.tryParse(value) ?? 0.0;
          setState(() {});
        },
      ),

      const SizedBox(height: 8),

      Text(
        "${t.discountAmount}: ${widget.cart.discountAmount.toStringAsFixed(2)}",
        style: const TextStyle(fontSize: 16),
      ),

      const SizedBox(height: 4),

      Text(
        "${t.totalAfterDiscount}: ${widget.cart.totalAfterDiscount.toStringAsFixed(2)}",
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),

      const SizedBox(height: 12),

      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: widget.cart.items.isEmpty
              ? null
              : () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CheckoutPage(cart: widget.cart),
                    ),
                  );
                  setState(() {});
                },
          child: Text(t.saveSale),
        ),
      ),
    ],
  ),
),
],
),
),
);
},
),
),
);
}
}
