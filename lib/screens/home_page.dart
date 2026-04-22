import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'inventory_table_page.dart';
import 'add_product_page.dart';
import 'cart_page.dart';
import 'sales_history_page.dart';
import 'customers_page.dart';
import 'scan_and_handle_page.dart';
import 'enter_sale_id_for_return_page.dart';
import 'settings_page.dart';
import 'profile_page.dart';
import 'dashboard_page.dart';

import '../controllers/cart_controller.dart';
import '../generated/app_localizations.dart';
import '../services/settings_service.dart';

class HomePage extends StatefulWidget {
  final Function(bool) onThemeChanged;
  final bool isDark;
  final Function(Locale) onLanguageChanged;

  const HomePage({
    super.key,
    required this.onThemeChanged,
    required this.isDark,
    required this.onLanguageChanged,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool showAppearance = false;
  bool showLanguage = false;
  bool showAboutInfo = false;
  bool showContactInfo = false;

  String appVersion = "";
  String buildNumber = "";

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = info.version;      // e.g. "1.0.0"
      buildNumber = info.buildNumber; // e.g. "1"
    });
  }

  // EXIT DIALOG
  Future<bool> _showExitDialog() async {
    final t = AppLocalizations.of(context)!;

    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(t.exitConfirmation),
          content: Text(t.exitQuestion),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(t.no),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(t.yes),
            ),
          ],
        );
      },
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cart = CartController.instance;
    final isDark = widget.isDark;

    // Reset cart
    cart.selectedCustomer = null;
    cart.items.clear();
    cart.autoPricing = false;
    cart.mode = PriceMode.retail;

    return WillPopScope(
      onWillPop: () async => await _showExitDialog(),
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF0D1117) : const Color(0xFFF5F7FA),

        appBar: AppBar(
          backgroundColor: isDark ? const Color(0xFF0D1117) : Colors.white,
          elevation: 1,
          title: Text(
            t.posDashboard,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          iconTheme:
              IconThemeData(color: isDark ? Colors.white : Colors.black87),
        ),

        drawer: Drawer(
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // SIMPLE HEADER
                Container(
                  height: 120,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    t.menu,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                  ),
                ),

                // APPEARANCE SECTION
                ListTile(
                  leading: Icon(Icons.color_lens,
                      color: Theme.of(context).iconTheme.color),
                  title: Text(t.appearance),
                  trailing: Icon(
                    showAppearance ? Icons.expand_less : Icons.expand_more,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  onTap: () => setState(() => showAppearance = !showAppearance),
                ),

                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 250),
                  crossFadeState: showAppearance
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  firstChild: Padding(
                    padding: const EdgeInsetsDirectional.only(
                        start: 40, end: 20, bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.light_mode, color: Colors.orange),
                            SizedBox(width: 8),
                            Text("Light"),
                          ],
                        ),
                        Switch(
                          value: widget.isDark,
                          onChanged: (value) {
                            SettingsService.instance.setTheme(value);
                            widget.onThemeChanged(value);
                          },
                        ),
                        Row(
                          children: const [
                            Icon(Icons.dark_mode, color: Colors.black87),
                            SizedBox(width: 8),
                            Text("Dark"),
                          ],
                        ),
                      ],
                    ),
                  ),
                  secondChild: const SizedBox.shrink(),
                ),

                // LANGUAGE SECTION
                ListTile(
                  leading: Icon(Icons.language,
                      color: Theme.of(context).iconTheme.color),
                  title: Text(t.language),
                  trailing: Icon(
                    showLanguage ? Icons.expand_less : Icons.expand_more,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  onTap: () => setState(() => showLanguage = !showLanguage),
                ),

                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 250),
                  crossFadeState: showLanguage
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  firstChild: Padding(
                    padding: const EdgeInsetsDirectional.only(
                        start: 40, end: 20, bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Text("🇺🇸", style: TextStyle(fontSize: 20)),
                            SizedBox(width: 8),
                            Text("English"),
                          ],
                        ),
                        Switch(
                          value: Localizations.localeOf(context).languageCode ==
                              "ar",
                          onChanged: (value) {
                            if (value) {
                              SettingsService.instance.setLanguage("ar");
                              widget.onLanguageChanged(const Locale('ar'));
                            } else {
                              SettingsService.instance.setLanguage("en");
                              widget.onLanguageChanged(const Locale('en'));
                            }
                          },
                        ),
                        Row(
                          children: const [
                            Text("🇸🇦", style: TextStyle(fontSize: 20)),
                            SizedBox(width: 8),
                            Text("العربية"),
                          ],
                        ),
                      ],
                    ),
                  ),
                  secondChild: const SizedBox.shrink(),
                ),

                // MENU ITEMS
                _drawerItem(Icons.dashboard, t.dashboard, () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const DashboardPage()));
                }),

                _drawerItem(Icons.person, t.profile, () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ProfilePage()));
                }),

                _drawerItem(Icons.settings, t.settings, () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const SettingsPage()));
                }),

                // ABOUT
                ListTile(
                  leading: Icon(Icons.info,
                      color: Theme.of(context).iconTheme.color),
                  title: Text(t.aboutApp),
                  trailing: Icon(
                    showAboutInfo ? Icons.expand_less : Icons.expand_more,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  onTap: () => setState(() => showAboutInfo = !showAboutInfo),
                ),

                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 250),
                  crossFadeState: showAboutInfo
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  firstChild: Padding(
                    padding: const EdgeInsetsDirectional.only(
                        start: 40, end: 20, bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "DPOS v$appVersion (Build $buildNumber)",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Developed by Eng. Dureid Laila",
                          style: TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                  secondChild: const SizedBox.shrink(),
                ),

                // CONTACT
                ListTile(
                  leading: Icon(Icons.contact_mail,
                      color: Theme.of(context).iconTheme.color),
                  title: Text(t.contactUs),
                  trailing: Icon(
                    showContactInfo ? Icons.expand_less : Icons.expand_more,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  onTap: () => setState(() => showContactInfo = !showContactInfo),
                ),

                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 250),
                  crossFadeState: showContactInfo
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  firstChild: Padding(
                    padding: const EdgeInsetsDirectional.only(
                        start: 40, end: 20, bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Email: Dureidlaila@gmail.com"),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: () {
                            final phone = "963937749701";
                            final message =
                                Uri.encodeComponent("Hello Eng. Duried Laila");
                            final url = "https://wa.me/$phone?text=$message";
                            launchUrl(Uri.parse(url));
                          },
                          icon: const Icon(FontAwesomeIcons.whatsapp),
                          label: const Text("WhatsApp"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  secondChild: const SizedBox.shrink(),
                ),

                const SizedBox(height: 20),

                // FOOTER
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      "DPOS v$appVersion (Build $buildNumber) © 2026",
                      style: TextStyle(
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .color
                            ?.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        body: Padding(
          padding: const EdgeInsets.all(20),
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 1.15,
            children: [
              _menuTile(
                label: t.inventory,
                icon: Icons.inventory_2,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => InventoryTablePage())),
              ),
              _menuTile(
                label: t.addProduct,
                icon: Icons.add_box,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AddProductPage())),
              ),
              _menuTile(
                label: t.createSale,
                icon: Icons.point_of_sale,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => CartPage(cart: cart))),
              ),
              _menuTile(
                label: t.salesHistory,
                icon: Icons.receipt_long,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => SalesHistoryPage())),
              ),
              _menuTile(
                label: t.customers,
                icon: Icons.people,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const CustomersPage())),
              ),
              _menuTile(
                label: t.returnItems,
                icon: Icons.undo,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const EnterSaleIdForReturnPage())),
              ),
            ],
          ),
        ),

        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 50),
          child: AnimatedScale(
            scale: 1.0,
            duration: const Duration(milliseconds: 200),
            child: Transform.scale(
              scale: 1.2,
              child: FloatingActionButton(
                backgroundColor: const Color(0xFF00C853),
                child: const Icon(
                  Icons.qr_code_scanner,
                  color: Colors.white,
                  size: 32,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ScanAndHandlePage()),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).iconTheme.color),
      title: Text(label),
      onTap: onTap,
    );
  }

  Widget _menuTile({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFF00C853).withOpacity(0.25),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 42, color: const Color(0xFF00C853)),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
