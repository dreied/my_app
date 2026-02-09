import 'package:flutter/material.dart';
import '../controllers/cart_controller.dart';
import '../controllers/product_controller.dart';
import '../models/product.dart';
import 'scan_for_sale_page.dart';
import '../controllers/sales_controller.dart';
import '../controllers/customer_credit_controller.dart';


class CartPage extends StatefulWidget {
  final CartController cart;

  const CartPage({super.key, required this.cart});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final ProductController _productController = ProductController();
  final SalesController _salesController = SalesController();

  String searchQuery = "";

  // ---------------------------------------------------------
  // SEARCH PRODUCT (manual)
  // ---------------------------------------------------------
  Future<void> _searchProduct() async {
    if (searchQuery.isEmpty) return;

    Product? p;

    // 1. Try barcode
    p = await _productController.getByBarcode(searchQuery);

    // 2. Try name search
    if (p == null) {
      final all = await _productController.loadProducts();

      final matches = all
          .where((prod) =>
              prod.name.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();

      if (matches.isEmpty) {
        p = null;
      } else if (matches.length == 1) {
        p = matches.first;
      } else {
        // Multiple matches → choose
        p = await showDialog<Product>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text("Select Product"),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: matches.length,
                  itemBuilder: (_, i) {
                    final prod = matches[i];
                    return ListTile(
                      title: Text(prod.name),
                      subtitle: Text("Barcode: ${prod.barcode}"),
                      onTap: () => Navigator.pop(dialogContext, prod),
                    );
                  },
                ),
              ),
            );
          },
        );
      }
    }

    if (p == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product not found")),
      );
      return;
    }

    // Quantity dialog
    int qty = 1;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(p!.name),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Quantity"),
            onChanged: (v) => qty = int.tryParse(v) ?? 1,
          ),
          actions: [
            TextButton(
              child: const Text("Add"),
              onPressed: () {
                bool ok = true;

                for (int i = 0; i < qty; i++) {
                  if (!widget.cart.addToCart(p!)) {
                    ok = false;
                    break;
                  }
                }

                if (!ok) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("لا يمكن البيع بسعر أقل من سعر الشراء"),
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
  }

  // ---------------------------------------------------------
  // BUILD UI
  // ---------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final items = widget.cart.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Sale"),
        actions: [
          // SCAN PRODUCT FOR SALE
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ScanForSalePage(
                    onProductFound: (p) async {
                      int qty = 1;

                      await showDialog(
                        context: context,
                        builder: (dialogContext) {
                          return AlertDialog(
                            title: Text(p.name),
                            content: TextField(
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                  labelText: "Quantity"),
                              onChanged: (v) =>
                                  qty = int.tryParse(v) ?? 1,
                            ),
                            actions: [
                              TextButton(
                                child: const Text("Add"),
                                onPressed: () {
                                  bool ok = true;

                                  for (int i = 0; i < qty; i++) {
                                    if (!widget.cart.addToCart(p)) {
                                      ok = false;
                                      break;
                                    }
                                  }

                                  if (!ok) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "لا يمكن البيع بسعر أقل من سعر الشراء"),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }

                                  Navigator.pop(dialogContext);
                                },
                              ),
                            ],
                          );
                        },
                      );

                      setState(() {});
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),

      // ---------------------------------------------------------
      // BODY
      // ---------------------------------------------------------
      body: Column(
        children: [
          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Enter barcode or name",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (v) => searchQuery = v,
              onSubmitted: (_) => _searchProduct(),
            ),
          ),

          // PRICE MODE TOGGLE
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                label: const Text("مفرق"),
                selected: widget.cart.mode == PriceMode.retail,
                onSelected: (_) {
                  if (!widget.cart.switchMode(PriceMode.retail)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            "لا يمكن التبديل — بعض الأسعار أقل من سعر الشراء"),
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
                label: const Text("جملة"),
                selected: widget.cart.mode == PriceMode.wholesale,
                onSelected: (_) {
                  if (!widget.cart.switchMode(PriceMode.wholesale)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            "لا يمكن التبديل — بعض الأسعار أقل من سعر الشراء"),
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

          const SizedBox(height: 10),

          // CART ITEMS LIST
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (_, i) {
                final item = items[i];

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(item.product.name),
                    subtitle: Text(
                      "Qty: ${item.qty}   Price: ${item.price.toStringAsFixed(2)}",
                    ),
                    trailing: Text(item.lineTotal.toStringAsFixed(2)),
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // DECREASE QTY
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            if (item.qty > 1) {
                              if (!widget.cart.changeQty(
                                  item.product, item.qty - 1)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        "لا يمكن البيع بسعر أقل من سعر الشراء"),
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

                        // INCREASE QTY
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            if (!widget.cart.changeQty(
                                item.product, item.qty + 1)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "لا يمكن البيع بسعر أقل من سعر الشراء"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            setState(() {});
                          },
                        ),

                        // DELETE ITEM
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
          ),

          // TOTAL
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            color: Colors.black12,
            child: Text(
              "Total: ${widget.cart.total.toStringAsFixed(2)}",
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),

          // SAVE SALE BUTTON
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ElevatedButton(
              child: const Text("Save Sale"),
              onPressed: () async {
                String customer = "";
                double paid = 0;

                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) {
                    return AlertDialog(
                      title: const Text("Finalize Sale"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            decoration: const InputDecoration(
                                labelText: "Customer Name"),
                            onChanged: (v) => customer = v,
                          ),
                          TextField(
                            decoration: const InputDecoration(
                                labelText: "Amount Paid"),
                            keyboardType: TextInputType.number,
                            onChanged: (v) =>
                                paid = double.tryParse(v) ?? 0,
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          child: const Text("Cancel"),
                          onPressed: () =>
                              Navigator.pop(dialogContext, false),
                        ),
                        TextButton(
                          child: const Text("Save"),
                          onPressed: () =>
                              Navigator.pop(dialogContext, true),
                        ),
                      ],
                    );
                  },
                );

                if (confirmed != true) return;

final total = widget.cart.total;
final remaining = total - paid;
final saleNumber = DateTime.now().millisecondsSinceEpoch;

// Add credit if customer didn't pay full amount
if (remaining > 0) {
  final creditController = CustomerCreditController();
  await creditController.addCredit(
    customer: customer,
    saleNumber: saleNumber,
    amount: remaining,
  );
}

await _salesController.saveSale(
  saleNumber: saleNumber,
  customer: customer,
  total: total,
  discount: widget.cart.discount,
  paid: paid,
  items: widget.cart.items,
);

widget.cart.items.clear();
setState(() {});




                widget.cart.items.clear();
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }
}
