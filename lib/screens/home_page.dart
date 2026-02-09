import 'package:flutter/material.dart';
import 'package:my_app/screens/scan_and_handle_page.dart';
import 'cart_page.dart';
import 'add_product_page.dart';
import '../controllers/cart_controller.dart';
import 'inventory_table_page.dart';
import 'settings_page.dart'; // <-- ADD THIS IMPORT

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = CartController();

    return Scaffold(
      appBar: AppBar(title: const Text("POS Dashboard")),

      // -------------------------------
      // ADD DRAWER (Side Menu)
      // -------------------------------
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                "Menu",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),

            // SETTINGS BUTTON
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () {
                Navigator.pop(context); // close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                );
              },
            ),
          ],
        ),
      ),
      // -------------------------------

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _menuButton(
              context,
              label: "Inventory",
              icon: Icons.inventory_2,
              page: InventoryTablePage(),
            ),
            const SizedBox(height: 20),
            _menuButton(
              context,
              label: "Create Sale",
              icon: Icons.point_of_sale,
              page: CartPage(cart: cart),
            ),
            const SizedBox(height: 20),
            _menuButton(
              context,
              label: "Add Product",
              icon: Icons.add_box,
              page: const AddProductPage(),
            ),
            const SizedBox(height: 20),
            _menuButton(
              context,
              label: "Scan Product",
              icon: Icons.qr_code_scanner,
              page: ScanAndHandlePage(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Widget page,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 20),
          textStyle: const TextStyle(fontSize: 20),
        ),
        icon: Icon(icon, size: 30),
        label: Text(label),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => page),
          );
        },
      ),
    );
  }
}
