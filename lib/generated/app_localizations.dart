import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @posDashboard.
  ///
  /// In en, this message translates to:
  /// **'POS Dashboard'**
  String get posDashboard;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @inventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get inventory;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get addProduct;

  /// No description provided for @createSale.
  ///
  /// In en, this message translates to:
  /// **'Create Sale'**
  String get createSale;

  /// No description provided for @salesHistory.
  ///
  /// In en, this message translates to:
  /// **'Sales History'**
  String get salesHistory;

  /// No description provided for @customers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customers;

  /// No description provided for @returnItems.
  ///
  /// In en, this message translates to:
  /// **'Return items'**
  String get returnItems;

  /// No description provided for @scan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @saveLanguage.
  ///
  /// In en, this message translates to:
  /// **'Save Language'**
  String get saveLanguage;

  /// No description provided for @printer.
  ///
  /// In en, this message translates to:
  /// **'Printer'**
  String get printer;

  /// No description provided for @noPrinter.
  ///
  /// In en, this message translates to:
  /// **'No printer selected'**
  String get noPrinter;

  /// No description provided for @savedPrinter.
  ///
  /// In en, this message translates to:
  /// **'Saved Printer'**
  String get savedPrinter;

  /// No description provided for @selectPrinter.
  ///
  /// In en, this message translates to:
  /// **'Select Printer'**
  String get selectPrinter;

  /// No description provided for @removePrinter.
  ///
  /// In en, this message translates to:
  /// **'Remove Printer'**
  String get removePrinter;

  /// No description provided for @languageUpdated.
  ///
  /// In en, this message translates to:
  /// **'Language updated'**
  String get languageUpdated;

  /// No description provided for @printerRemoved.
  ///
  /// In en, this message translates to:
  /// **'Printer removed'**
  String get printerRemoved;

  /// No description provided for @addCustomer.
  ///
  /// In en, this message translates to:
  /// **'Add Customer'**
  String get addCustomer;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @productName.
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get productName;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @addNewCategory.
  ///
  /// In en, this message translates to:
  /// **'Add New Category'**
  String get addNewCategory;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get categoryName;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @purchasePrice.
  ///
  /// In en, this message translates to:
  /// **'Purchase Price'**
  String get purchasePrice;

  /// No description provided for @sellPrice1.
  ///
  /// In en, this message translates to:
  /// **'Sell Price 1'**
  String get sellPrice1;

  /// No description provided for @sellPrice2.
  ///
  /// In en, this message translates to:
  /// **'Sell Price 2'**
  String get sellPrice2;

  /// No description provided for @sellPrice3.
  ///
  /// In en, this message translates to:
  /// **'Sell Price 3'**
  String get sellPrice3;

  /// No description provided for @stock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get stock;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @halfDozen.
  ///
  /// In en, this message translates to:
  /// **'Half‑Dozen (6)'**
  String get halfDozen;

  /// No description provided for @dozen.
  ///
  /// In en, this message translates to:
  /// **'Dozen'**
  String get dozen;

  /// No description provided for @barcode.
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get barcode;

  /// No description provided for @saveProduct.
  ///
  /// In en, this message translates to:
  /// **'Save Product'**
  String get saveProduct;

  /// No description provided for @invalidProductDetails.
  ///
  /// In en, this message translates to:
  /// **'Invalid product details'**
  String get invalidProductDetails;

  /// No description provided for @sellBelowPurchase.
  ///
  /// In en, this message translates to:
  /// **'Selling price cannot be lower than purchase price'**
  String get sellBelowPurchase;

  /// No description provided for @productExists.
  ///
  /// In en, this message translates to:
  /// **'Product Already Exists'**
  String get productExists;

  /// No description provided for @productExistsDetails.
  ///
  /// In en, this message translates to:
  /// **'This product already exists:'**
  String get productExistsDetails;

  /// No description provided for @modifyPrices.
  ///
  /// In en, this message translates to:
  /// **'Modify Prices'**
  String get modifyPrices;

  /// No description provided for @addToInventory.
  ///
  /// In en, this message translates to:
  /// **'Add to Inventory'**
  String get addToInventory;

  /// No description provided for @addNewCategoryDialog.
  ///
  /// In en, this message translates to:
  /// **'Add New Category'**
  String get addNewCategoryDialog;

  /// No description provided for @saleFor.
  ///
  /// In en, this message translates to:
  /// **'Sale for {name}'**
  String saleFor(Object name);

  /// No description provided for @selectCustomerFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select a customer first'**
  String get selectCustomerFirst;

  /// No description provided for @enterBarcodeOrName.
  ///
  /// In en, this message translates to:
  /// **'Enter barcode or product name'**
  String get enterBarcodeOrName;

  /// No description provided for @productNotFound.
  ///
  /// In en, this message translates to:
  /// **'Product not found'**
  String get productNotFound;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @cannotSellBelowPurchase.
  ///
  /// In en, this message translates to:
  /// **'Cannot sell below purchase price'**
  String get cannotSellBelowPurchase;

  /// No description provided for @autoPricing.
  ///
  /// In en, this message translates to:
  /// **'Auto Pricing:'**
  String get autoPricing;

  /// No description provided for @retail.
  ///
  /// In en, this message translates to:
  /// **'Retail'**
  String get retail;

  /// No description provided for @wholesale.
  ///
  /// In en, this message translates to:
  /// **'Wholesale'**
  String get wholesale;

  /// No description provided for @special.
  ///
  /// In en, this message translates to:
  /// **'custom'**
  String get special;

  /// No description provided for @cannotSwitchMode.
  ///
  /// In en, this message translates to:
  /// **'Cannot switch — some prices are below purchase price'**
  String get cannotSwitchMode;

  /// No description provided for @qty.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get qty;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @saveSale.
  ///
  /// In en, this message translates to:
  /// **'Save Sale'**
  String get saveSale;

  /// No description provided for @selectProduct.
  ///
  /// In en, this message translates to:
  /// **'Select Product'**
  String get selectProduct;

  /// No description provided for @manageCategories.
  ///
  /// In en, this message translates to:
  /// **'Manage Categories'**
  String get manageCategories;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get addCategory;

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get editCategory;

  /// No description provided for @selectIcon.
  ///
  /// In en, this message translates to:
  /// **'Select Icon'**
  String get selectIcon;

  /// No description provided for @selectColor.
  ///
  /// In en, this message translates to:
  /// **'Select Color'**
  String get selectColor;

  /// No description provided for @sortByName.
  ///
  /// In en, this message translates to:
  /// **'Sort by Name'**
  String get sortByName;

  /// No description provided for @searchCategories.
  ///
  /// In en, this message translates to:
  /// **'Search categories...'**
  String get searchCategories;

  /// No description provided for @cannotDeleteCategoryWithProducts.
  ///
  /// In en, this message translates to:
  /// **'Cannot delete category with products.'**
  String get cannotDeleteCategoryWithProducts;

  /// No description provided for @completeSale.
  ///
  /// In en, this message translates to:
  /// **'Complete Sale'**
  String get completeSale;

  /// No description provided for @currentSale.
  ///
  /// In en, this message translates to:
  /// **'Current Sale'**
  String get currentSale;

  /// No description provided for @previousBalance.
  ///
  /// In en, this message translates to:
  /// **'Previous balance'**
  String get previousBalance;

  /// No description provided for @previousDebt.
  ///
  /// In en, this message translates to:
  /// **'Previous debt'**
  String get previousDebt;

  /// No description provided for @totalDue.
  ///
  /// In en, this message translates to:
  /// **'Total due'**
  String get totalDue;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @selectCustomerBeforeSale.
  ///
  /// In en, this message translates to:
  /// **'Please select a customer before completing sale'**
  String get selectCustomerBeforeSale;

  /// No description provided for @printReceipt.
  ///
  /// In en, this message translates to:
  /// **'Print Receipt'**
  String get printReceipt;

  /// No description provided for @printReceiptQuestion.
  ///
  /// In en, this message translates to:
  /// **'Do you want to print the receipt?'**
  String get printReceiptQuestion;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @noPrinterConfigured.
  ///
  /// In en, this message translates to:
  /// **'No printer configured'**
  String get noPrinterConfigured;

  /// No description provided for @addPrinter.
  ///
  /// In en, this message translates to:
  /// **'Add Printer'**
  String get addPrinter;

  /// No description provided for @pdf.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get pdf;

  /// No description provided for @thermalBluetooth.
  ///
  /// In en, this message translates to:
  /// **'Thermal Bluetooth Printer'**
  String get thermalBluetooth;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @noCustomer.
  ///
  /// In en, this message translates to:
  /// **'No customer'**
  String get noCustomer;

  /// No description provided for @totalBeforeDiscount.
  ///
  /// In en, this message translates to:
  /// **'Total Before Discount'**
  String get totalBeforeDiscount;

  /// No description provided for @payDebt.
  ///
  /// In en, this message translates to:
  /// **'Pay debt'**
  String get payDebt;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @managerPinRequired.
  ///
  /// In en, this message translates to:
  /// **'Manager PIN Required'**
  String get managerPinRequired;

  /// No description provided for @enterPin.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN'**
  String get enterPin;

  /// No description provided for @incorrectPin.
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN'**
  String get incorrectPin;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @debtPayment.
  ///
  /// In en, this message translates to:
  /// **'Debt payment'**
  String get debtPayment;

  /// No description provided for @paymentAdded.
  ///
  /// In en, this message translates to:
  /// **'Payment added.'**
  String get paymentAdded;

  /// No description provided for @editPayment.
  ///
  /// In en, this message translates to:
  /// **'Edit payment'**
  String get editPayment;

  /// No description provided for @deletePayment.
  ///
  /// In en, this message translates to:
  /// **'Delete payment'**
  String get deletePayment;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @deletePaymentOf.
  ///
  /// In en, this message translates to:
  /// **'Delete payment of'**
  String get deletePaymentOf;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @paymentDeleted.
  ///
  /// In en, this message translates to:
  /// **'Payment deleted.'**
  String get paymentDeleted;

  /// No description provided for @cannotDeleteCustomerWithBalance.
  ///
  /// In en, this message translates to:
  /// **'Cannot delete a customer with non-zero balance.'**
  String get cannotDeleteCustomerWithBalance;

  /// No description provided for @customerDeleted.
  ///
  /// In en, this message translates to:
  /// **'Customer deleted.'**
  String get customerDeleted;

  /// No description provided for @debt.
  ///
  /// In en, this message translates to:
  /// **'Debt'**
  String get debt;

  /// No description provided for @credit.
  ///
  /// In en, this message translates to:
  /// **'Credit'**
  String get credit;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @sales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get sales;

  /// No description provided for @payments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get payments;

  /// No description provided for @noSalesYet.
  ///
  /// In en, this message translates to:
  /// **'No sales yet'**
  String get noSalesYet;

  /// No description provided for @sale.
  ///
  /// In en, this message translates to:
  /// **'Sale'**
  String get sale;

  /// No description provided for @noPaymentsYet.
  ///
  /// In en, this message translates to:
  /// **'No payments yet'**
  String get noPaymentsYet;

  /// No description provided for @returnLabel.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get returnLabel;

  /// No description provided for @selectCustomer.
  ///
  /// In en, this message translates to:
  /// **'Select Customer'**
  String get selectCustomer;

  /// No description provided for @searchCustomers.
  ///
  /// In en, this message translates to:
  /// **'Search customers...'**
  String get searchCustomers;

  /// No description provided for @noCustomersFound.
  ///
  /// In en, this message translates to:
  /// **'No customers found'**
  String get noCustomersFound;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @todaySalesTotal.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Sales Total'**
  String get todaySalesTotal;

  /// No description provided for @numberOfSalesToday.
  ///
  /// In en, this message translates to:
  /// **'Number of Sales Today'**
  String get numberOfSalesToday;

  /// No description provided for @totalItemsSoldToday.
  ///
  /// In en, this message translates to:
  /// **'Total Items Sold Today'**
  String get totalItemsSoldToday;

  /// No description provided for @topSellingProductsToday.
  ///
  /// In en, this message translates to:
  /// **'Top Selling Products Today'**
  String get topSellingProductsToday;

  /// No description provided for @sold.
  ///
  /// In en, this message translates to:
  /// **'Sold'**
  String get sold;

  /// No description provided for @editProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get editProduct;

  /// No description provided for @unitPieces.
  ///
  /// In en, this message translates to:
  /// **'Pieces'**
  String get unitPieces;

  /// No description provided for @unitHalfDozen.
  ///
  /// In en, this message translates to:
  /// **'Half‑Dozen (6)'**
  String get unitHalfDozen;

  /// No description provided for @unitDozen.
  ///
  /// In en, this message translates to:
  /// **'Dozen (12)'**
  String get unitDozen;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @deleteProduct.
  ///
  /// In en, this message translates to:
  /// **'Delete Product'**
  String get deleteProduct;

  /// No description provided for @adjustStock.
  ///
  /// In en, this message translates to:
  /// **'Adjust Stock'**
  String get adjustStock;

  /// No description provided for @sellPriceBelowPurchase.
  ///
  /// In en, this message translates to:
  /// **'Sell price cannot be lower than purchase price'**
  String get sellPriceBelowPurchase;

  /// No description provided for @enterSaleId.
  ///
  /// In en, this message translates to:
  /// **'Enter Sale ID'**
  String get enterSaleId;

  /// No description provided for @saleId.
  ///
  /// In en, this message translates to:
  /// **'Sale ID'**
  String get saleId;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @inventoryLog.
  ///
  /// In en, this message translates to:
  /// **'Inventory Log'**
  String get inventoryLog;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @columns.
  ///
  /// In en, this message translates to:
  /// **'Columns'**
  String get columns;

  /// No description provided for @product.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get product;

  /// No description provided for @purchase.
  ///
  /// In en, this message translates to:
  /// **'Purchase'**
  String get purchase;

  /// No description provided for @filterByCategory.
  ///
  /// In en, this message translates to:
  /// **'Filter by Category'**
  String get filterByCategory;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All Categories'**
  String get allCategories;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @dozens.
  ///
  /// In en, this message translates to:
  /// **'Dozens'**
  String get dozens;

  /// No description provided for @pcs.
  ///
  /// In en, this message translates to:
  /// **'pcs'**
  String get pcs;

  /// No description provided for @searchNameBarcode.
  ///
  /// In en, this message translates to:
  /// **'Search by name or barcode'**
  String get searchNameBarcode;

  /// No description provided for @lowStockOnly.
  ///
  /// In en, this message translates to:
  /// **'Low stock only'**
  String get lowStockOnly;

  /// No description provided for @lowStockAlerts.
  ///
  /// In en, this message translates to:
  /// **'Low Stock Alerts'**
  String get lowStockAlerts;

  /// No description provided for @allProductsSufficient.
  ///
  /// In en, this message translates to:
  /// **'All products are sufficiently stocked'**
  String get allProductsSufficient;

  /// No description provided for @monthlyReport.
  ///
  /// In en, this message translates to:
  /// **'Monthly Report'**
  String get monthlyReport;

  /// No description provided for @totalSalesThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Total Sales'**
  String get totalSalesThisMonth;

  /// No description provided for @totalItemsSold.
  ///
  /// In en, this message translates to:
  /// **'Total Items Sold'**
  String get totalItemsSold;

  /// No description provided for @totalProfit.
  ///
  /// In en, this message translates to:
  /// **'Total Profit'**
  String get totalProfit;

  /// No description provided for @topSellingProducts.
  ///
  /// In en, this message translates to:
  /// **'Top Selling Products'**
  String get topSellingProducts;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @scanBarcode.
  ///
  /// In en, this message translates to:
  /// **'Scan Barcode'**
  String get scanBarcode;

  /// No description provided for @noProductFound.
  ///
  /// In en, this message translates to:
  /// **'No product found for barcode:'**
  String get noProductFound;

  /// No description provided for @scannerError.
  ///
  /// In en, this message translates to:
  /// **'Scanner error'**
  String get scannerError;

  /// No description provided for @sell1.
  ///
  /// In en, this message translates to:
  /// **'Sell1'**
  String get sell1;

  /// No description provided for @sell2.
  ///
  /// In en, this message translates to:
  /// **'Sell2'**
  String get sell2;

  /// No description provided for @storeProfile.
  ///
  /// In en, this message translates to:
  /// **'Store Profile'**
  String get storeProfile;

  /// No description provided for @storeName.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get storeName;

  /// No description provided for @chooseLogo.
  ///
  /// In en, this message translates to:
  /// **'Choose logo'**
  String get chooseLogo;

  /// No description provided for @inventorySettings.
  ///
  /// In en, this message translates to:
  /// **'Inventory Settings'**
  String get inventorySettings;

  /// No description provided for @lowStockThreshold.
  ///
  /// In en, this message translates to:
  /// **'Low Stock Threshold (pieces)'**
  String get lowStockThreshold;

  /// No description provided for @invalidLowStockThreshold.
  ///
  /// In en, this message translates to:
  /// **'Invalid low stock threshold'**
  String get invalidLowStockThreshold;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved'**
  String get profileSaved;

  /// No description provided for @managerPin.
  ///
  /// In en, this message translates to:
  /// **'Manager PIN'**
  String get managerPin;

  /// No description provided for @currentPin.
  ///
  /// In en, this message translates to:
  /// **'Current PIN'**
  String get currentPin;

  /// No description provided for @changePin.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get changePin;

  /// No description provided for @changeManagerPin.
  ///
  /// In en, this message translates to:
  /// **'Change Manager PIN'**
  String get changeManagerPin;

  /// No description provided for @newPin.
  ///
  /// In en, this message translates to:
  /// **'New PIN (4 digits)'**
  String get newPin;

  /// No description provided for @confirmNewPin.
  ///
  /// In en, this message translates to:
  /// **'Confirm New PIN'**
  String get confirmNewPin;

  /// No description provided for @incorrectCurrentPin.
  ///
  /// In en, this message translates to:
  /// **'Incorrect current PIN'**
  String get incorrectCurrentPin;

  /// No description provided for @pinMustBe4Digits.
  ///
  /// In en, this message translates to:
  /// **'PIN must be 4 digits'**
  String get pinMustBe4Digits;

  /// No description provided for @pinsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'PINs do not match'**
  String get pinsDoNotMatch;

  /// No description provided for @pinUpdated.
  ///
  /// In en, this message translates to:
  /// **'PIN updated successfully'**
  String get pinUpdated;

  /// No description provided for @resetPinTo0000.
  ///
  /// In en, this message translates to:
  /// **'Reset PIN to 0000'**
  String get resetPinTo0000;

  /// No description provided for @pinReset.
  ///
  /// In en, this message translates to:
  /// **'PIN reset to 0000'**
  String get pinReset;

  /// No description provided for @saveProfile.
  ///
  /// In en, this message translates to:
  /// **'Save Profile'**
  String get saveProfile;

  /// No description provided for @receipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get receipt;

  /// No description provided for @storeReceipt.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get storeReceipt;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @x.
  ///
  /// In en, this message translates to:
  /// **'x'**
  String get x;

  /// No description provided for @thankYou.
  ///
  /// In en, this message translates to:
  /// **'Thank you'**
  String get thankYou;

  /// No description provided for @returnHistory.
  ///
  /// In en, this message translates to:
  /// **'Return History'**
  String get returnHistory;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// No description provided for @invalidReturnQty.
  ///
  /// In en, this message translates to:
  /// **'Invalid return quantity.'**
  String get invalidReturnQty;

  /// No description provided for @noItemsSelected.
  ///
  /// In en, this message translates to:
  /// **'No items selected for return.'**
  String get noItemsSelected;

  /// No description provided for @confirmReturn.
  ///
  /// In en, this message translates to:
  /// **'Confirm return'**
  String get confirmReturn;

  /// No description provided for @refundTotal.
  ///
  /// In en, this message translates to:
  /// **'Refund total'**
  String get refundTotal;

  /// No description provided for @returnCompletedPrint.
  ///
  /// In en, this message translates to:
  /// **'Return completed. Choose how to print or save the receipt.'**
  String get returnCompletedPrint;

  /// No description provided for @print.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get print;

  /// No description provided for @returned.
  ///
  /// In en, this message translates to:
  /// **'Returned'**
  String get returned;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @returnReason.
  ///
  /// In en, this message translates to:
  /// **'Return reason'**
  String get returnReason;

  /// No description provided for @reasonExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get reasonExpired;

  /// No description provided for @reasonDamaged.
  ///
  /// In en, this message translates to:
  /// **'Damaged'**
  String get reasonDamaged;

  /// No description provided for @reasonWrongItem.
  ///
  /// In en, this message translates to:
  /// **'Wrong item'**
  String get reasonWrongItem;

  /// No description provided for @reasonCustomerChangedMind.
  ///
  /// In en, this message translates to:
  /// **'Customer changed mind'**
  String get reasonCustomerChangedMind;

  /// No description provided for @reasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get reasonOther;

  /// No description provided for @refundInCash.
  ///
  /// In en, this message translates to:
  /// **'Refund in cash'**
  String get refundInCash;

  /// No description provided for @restockReturnedItems.
  ///
  /// In en, this message translates to:
  /// **'Restock returned items'**
  String get restockReturnedItems;

  /// No description provided for @returnWholeSale.
  ///
  /// In en, this message translates to:
  /// **'Return whole sale'**
  String get returnWholeSale;

  /// No description provided for @saleDetails.
  ///
  /// In en, this message translates to:
  /// **'Sale Details'**
  String get saleDetails;

  /// No description provided for @refund.
  ///
  /// In en, this message translates to:
  /// **'Refund'**
  String get refund;

  /// No description provided for @nothingToReturn.
  ///
  /// In en, this message translates to:
  /// **'Nothing to return'**
  String get nothingToReturn;

  /// No description provided for @viewReceipt.
  ///
  /// In en, this message translates to:
  /// **'View Receipt'**
  String get viewReceipt;

  /// No description provided for @scanning.
  ///
  /// In en, this message translates to:
  /// **'Scanning...'**
  String get scanning;

  /// No description provided for @processingBarcode.
  ///
  /// In en, this message translates to:
  /// **'Processing barcode...'**
  String get processingBarcode;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @mac.
  ///
  /// In en, this message translates to:
  /// **'MAC'**
  String get mac;

  /// No description provided for @currentStock.
  ///
  /// In en, this message translates to:
  /// **'Current Stock'**
  String get currentStock;

  /// No description provided for @quantityAddRemove.
  ///
  /// In en, this message translates to:
  /// **'Quantity (+ to add, - to remove)'**
  String get quantityAddRemove;

  /// No description provided for @addNewCustomer.
  ///
  /// In en, this message translates to:
  /// **'Add NewCustomer'**
  String get addNewCustomer;

  /// No description provided for @applyChange.
  ///
  /// In en, this message translates to:
  /// **'Apply Change'**
  String get applyChange;

  /// No description provided for @notEnoughStock.
  ///
  /// In en, this message translates to:
  /// **'Not enough stock. Available:'**
  String get notEnoughStock;

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Invalid Phone Number'**
  String get invalidPhone;

  /// No description provided for @availableStock.
  ///
  /// In en, this message translates to:
  /// **'Available Stock'**
  String get availableStock;

  /// No description provided for @piece.
  ///
  /// In en, this message translates to:
  /// **'Piece'**
  String get piece;

  /// No description provided for @pieces.
  ///
  /// In en, this message translates to:
  /// **'Pieces'**
  String get pieces;

  /// No description provided for @stockWithUnit.
  ///
  /// In en, this message translates to:
  /// **'{stock} {unit}'**
  String stockWithUnit(Object stock, Object unit);

  /// No description provided for @salesProfitToday.
  ///
  /// In en, this message translates to:
  /// **'Sales Profit Today'**
  String get salesProfitToday;

  /// No description provided for @profit.
  ///
  /// In en, this message translates to:
  /// **'Profit'**
  String get profit;

  /// No description provided for @saleNumber.
  ///
  /// In en, this message translates to:
  /// **'Sale #'**
  String get saleNumber;

  /// No description provided for @previewPdf.
  ///
  /// In en, this message translates to:
  /// **'Preview PDF'**
  String get previewPdf;

  /// No description provided for @printing.
  ///
  /// In en, this message translates to:
  /// **'Printing...'**
  String get printing;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @backupTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backupTitle;

  /// No description provided for @backupFolder.
  ///
  /// In en, this message translates to:
  /// **'Backup Folder'**
  String get backupFolder;

  /// No description provided for @createBackup.
  ///
  /// In en, this message translates to:
  /// **'Create Backup'**
  String get createBackup;

  /// No description provided for @restoreBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore Backup'**
  String get restoreBackup;

  /// No description provided for @viewBackupFolder.
  ///
  /// In en, this message translates to:
  /// **'View Backup Folder'**
  String get viewBackupFolder;

  /// No description provided for @backupSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup restored successfully'**
  String get backupSuccess;

  /// No description provided for @backupSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Backup created successfully'**
  String get backupSuccessMessage;

  /// No description provided for @backupFailed.
  ///
  /// In en, this message translates to:
  /// **'Backup failed'**
  String get backupFailed;

  /// No description provided for @automaticBackup.
  ///
  /// In en, this message translates to:
  /// **'Automatic Backup'**
  String get automaticBackup;

  /// No description provided for @backupFrequency.
  ///
  /// In en, this message translates to:
  /// **'Backup Frequency'**
  String get backupFrequency;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get invalidEmail;

  /// No description provided for @managerEmail.
  ///
  /// In en, this message translates to:
  /// **'Manager Email'**
  String get managerEmail;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @noPinSet.
  ///
  /// In en, this message translates to:
  /// **'No PIN set'**
  String get noPinSet;

  /// No description provided for @noPinSetPleaseSetInProfile.
  ///
  /// In en, this message translates to:
  /// **'No manager PIN set. Please set it in the profile page.'**
  String get noPinSetPleaseSetInProfile;

  /// No description provided for @enterManagerPin.
  ///
  /// In en, this message translates to:
  /// **'Enter Manager PIN'**
  String get enterManagerPin;

  /// No description provided for @forgotPin.
  ///
  /// In en, this message translates to:
  /// **'Forgot PIN?'**
  String get forgotPin;

  /// No description provided for @noEmailSetForReset.
  ///
  /// In en, this message translates to:
  /// **'No email set for reset. Please set it in the profile page.'**
  String get noEmailSetForReset;

  /// No description provided for @resetCodeSent.
  ///
  /// In en, this message translates to:
  /// **'Reset code sent to your email'**
  String get resetCodeSent;

  /// No description provided for @failedToSendResetCode.
  ///
  /// In en, this message translates to:
  /// **'Failed to send reset code'**
  String get failedToSendResetCode;

  /// No description provided for @resetPin.
  ///
  /// In en, this message translates to:
  /// **'Reset PIN'**
  String get resetPin;

  /// No description provided for @enterCodeSentToEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter the reset code sent to your email'**
  String get enterCodeSentToEmail;

  /// No description provided for @resetCode.
  ///
  /// In en, this message translates to:
  /// **'Reset Code'**
  String get resetCode;

  /// No description provided for @invalidOrExpiredResetCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired reset code'**
  String get invalidOrExpiredResetCode;

  /// No description provided for @backupSize.
  ///
  /// In en, this message translates to:
  /// **'Backup Size'**
  String get backupSize;

  /// No description provided for @lastBackup.
  ///
  /// In en, this message translates to:
  /// **'Last Backup'**
  String get lastBackup;

  /// No description provided for @noBackupYet.
  ///
  /// In en, this message translates to:
  /// **'No backups yet'**
  String get noBackupYet;

  /// No description provided for @managerLogin.
  ///
  /// In en, this message translates to:
  /// **'Manager Login'**
  String get managerLogin;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @setManagerPin.
  ///
  /// In en, this message translates to:
  /// **'Set Manager PIN'**
  String get setManagerPin;

  /// No description provided for @createPin.
  ///
  /// In en, this message translates to:
  /// **'Create PIN'**
  String get createPin;

  /// No description provided for @pin.
  ///
  /// In en, this message translates to:
  /// **'PIN'**
  String get pin;

  /// No description provided for @editCustomer.
  ///
  /// In en, this message translates to:
  /// **'Edit customer'**
  String get editCustomer;

  /// No description provided for @customerName.
  ///
  /// In en, this message translates to:
  /// **'Customer Name'**
  String get customerName;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @invalidCustomerName.
  ///
  /// In en, this message translates to:
  /// **'Customer name cannot be empty'**
  String get invalidCustomerName;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @trashBin.
  ///
  /// In en, this message translates to:
  /// **'Trash Bin'**
  String get trashBin;

  /// No description provided for @noDeletedProducts.
  ///
  /// In en, this message translates to:
  /// **'No deleted products'**
  String get noDeletedProducts;

  /// No description provided for @deleteForever.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently?'**
  String get deleteForever;

  /// No description provided for @deleteSelectedProducts.
  ///
  /// In en, this message translates to:
  /// **'Delete selected products?'**
  String get deleteSelectedProducts;

  /// No description provided for @productsDeleted.
  ///
  /// In en, this message translates to:
  /// **'Products deleted'**
  String get productsDeleted;

  /// No description provided for @deletionCancelled.
  ///
  /// In en, this message translates to:
  /// **'Deletion cancelled'**
  String get deletionCancelled;

  /// No description provided for @deleteAllForever.
  ///
  /// In en, this message translates to:
  /// **'Delete all permanently'**
  String get deleteAllForever;

  /// No description provided for @confirmDeleteAllForever.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete all products?'**
  String get confirmDeleteAllForever;

  /// No description provided for @deletedForeverSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Permanently deleted'**
  String get deletedForeverSuccessfully;

  /// No description provided for @restoreAll.
  ///
  /// In en, this message translates to:
  /// **'Restore all'**
  String get restoreAll;

  /// No description provided for @confirmRestoreAll.
  ///
  /// In en, this message translates to:
  /// **'Do you want to restore all deleted products?'**
  String get confirmRestoreAll;

  /// No description provided for @restoredSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Restored successfully'**
  String get restoredSuccessfully;

  /// No description provided for @bulkRestore.
  ///
  /// In en, this message translates to:
  /// **'Bulk restore'**
  String get bulkRestore;

  /// No description provided for @confirmBulkRestore.
  ///
  /// In en, this message translates to:
  /// **'Do you want to restore the selected products?'**
  String get confirmBulkRestore;

  /// No description provided for @bulkRestoredSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Bulk restore completed'**
  String get bulkRestoredSuccessfully;

  /// No description provided for @nothingSelected.
  ///
  /// In en, this message translates to:
  /// **'No items selected'**
  String get nothingSelected;

  /// No description provided for @moveToTrash.
  ///
  /// In en, this message translates to:
  /// **'Move to Trash'**
  String get moveToTrash;

  /// No description provided for @confirmMoveToTrash.
  ///
  /// In en, this message translates to:
  /// **'Do you want to move this product to the trash?'**
  String get confirmMoveToTrash;

  /// No description provided for @movedToTrash.
  ///
  /// In en, this message translates to:
  /// **'Product moved to trash'**
  String get movedToTrash;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @activation.
  ///
  /// In en, this message translates to:
  /// **'Activation'**
  String get activation;

  /// No description provided for @activationStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get activationStatus;

  /// No description provided for @activated.
  ///
  /// In en, this message translates to:
  /// **'Activated'**
  String get activated;

  /// No description provided for @notActivated.
  ///
  /// In en, this message translates to:
  /// **'Not Activated'**
  String get notActivated;

  /// No description provided for @deviceFingerprint.
  ///
  /// In en, this message translates to:
  /// **'Device Fingerprint'**
  String get deviceFingerprint;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @whatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsapp;

  /// No description provided for @activationCode.
  ///
  /// In en, this message translates to:
  /// **'Activation Code'**
  String get activationCode;

  /// No description provided for @activate.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get activate;

  /// No description provided for @activationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Activated successfully'**
  String get activationSuccess;

  /// No description provided for @activationFailed.
  ///
  /// In en, this message translates to:
  /// **'Invalid activation code'**
  String get activationFailed;

  /// No description provided for @requiresActivation.
  ///
  /// In en, this message translates to:
  /// **'This feature requires activation'**
  String get requiresActivation;

  /// No description provided for @activationExpiry.
  ///
  /// In en, this message translates to:
  /// **'Expires on'**
  String get activationExpiry;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @refundLabel.
  ///
  /// In en, this message translates to:
  /// **'Refund'**
  String get refundLabel;

  /// No description provided for @paidDuringSaleLabel.
  ///
  /// In en, this message translates to:
  /// **'Paid during sale'**
  String get paidDuringSaleLabel;

  /// No description provided for @paidDuringSale.
  ///
  /// In en, this message translates to:
  /// **'Paid during sale #{saleId}'**
  String paidDuringSale(Object saleId);

  /// No description provided for @refundForReturn.
  ///
  /// In en, this message translates to:
  /// **'Refund for return #{saleId}'**
  String refundForReturn(Object saleId);

  /// No description provided for @activationRequiredProducts.
  ///
  /// In en, this message translates to:
  /// **'Application not activated. Please activate to continue'**
  String get activationRequiredProducts;

  /// No description provided for @activationRequiredSales.
  ///
  /// In en, this message translates to:
  /// **'Application not activated. Please activate to continue'**
  String get activationRequiredSales;

  /// No description provided for @activationRequiredCustomers.
  ///
  /// In en, this message translates to:
  /// **'Application not activated. Please activate to continue'**
  String get activationRequiredCustomers;

  /// No description provided for @customerAdded.
  ///
  /// In en, this message translates to:
  /// **'Customer added successfully'**
  String get customerAdded;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutApp;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @openContactPage.
  ///
  /// In en, this message translates to:
  /// **'Open Contact Page'**
  String get openContactPage;

  /// No description provided for @noProductsToExport.
  ///
  /// In en, this message translates to:
  /// **'No products to export'**
  String get noProductsToExport;

  /// No description provided for @returnReceipt.
  ///
  /// In en, this message translates to:
  /// **'Return Receipt'**
  String get returnReceipt;

  /// No description provided for @originalSaleId.
  ///
  /// In en, this message translates to:
  /// **'Original Sale ID'**
  String get originalSaleId;

  /// No description provided for @saleDate.
  ///
  /// In en, this message translates to:
  /// **'Sale Date'**
  String get saleDate;

  /// No description provided for @returnedItems.
  ///
  /// In en, this message translates to:
  /// **'Returned Items'**
  String get returnedItems;

  /// No description provided for @restock.
  ///
  /// In en, this message translates to:
  /// **'Restock'**
  String get restock;

  /// No description provided for @cashRefund.
  ///
  /// In en, this message translates to:
  /// **'Cash Refund'**
  String get cashRefund;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @item.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get item;

  /// No description provided for @exitConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Exit Confirmation'**
  String get exitConfirmation;

  /// No description provided for @exitQuestion.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to exit the app?'**
  String get exitQuestion;

  /// No description provided for @saleInvoice.
  ///
  /// In en, this message translates to:
  /// **'Sale Invoice'**
  String get saleInvoice;

  /// No description provided for @purchaseInvoice.
  ///
  /// In en, this message translates to:
  /// **'Purchase Invoice'**
  String get purchaseInvoice;

  /// No description provided for @createPurchaseInvoice.
  ///
  /// In en, this message translates to:
  /// **'Create Purchase Invoice'**
  String get createPurchaseInvoice;

  /// No description provided for @purchaseFrom.
  ///
  /// In en, this message translates to:
  /// **'Purchase from {name}'**
  String purchaseFrom(Object name);

  /// No description provided for @savePurchase.
  ///
  /// In en, this message translates to:
  /// **'Save Purchase'**
  String get savePurchase;

  /// No description provided for @completePurchase.
  ///
  /// In en, this message translates to:
  /// **'Complete Purchase'**
  String get completePurchase;

  /// No description provided for @purchaseInvoiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Purchase Invoice No. {id}'**
  String purchaseInvoiceTitle(Object id);

  /// No description provided for @purchaseSentence.
  ///
  /// In en, this message translates to:
  /// **'The customer ({name}) sold products to you for {amount} dollars.'**
  String purchaseSentence(Object amount, Object name);

  /// No description provided for @currentPurchase.
  ///
  /// In en, this message translates to:
  /// **'Current Purchase'**
  String get currentPurchase;

  /// No description provided for @purchaseTotal.
  ///
  /// In en, this message translates to:
  /// **'Purchase Total'**
  String get purchaseTotal;

  /// No description provided for @supplier.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get supplier;

  /// No description provided for @newProduct.
  ///
  /// In en, this message translates to:
  /// **'New Product'**
  String get newProduct;

  /// No description provided for @costPrice.
  ///
  /// In en, this message translates to:
  /// **'Cost Price'**
  String get costPrice;

  /// No description provided for @initialStock.
  ///
  /// In en, this message translates to:
  /// **'Initial Stock'**
  String get initialStock;

  /// No description provided for @invalidData.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid product information.'**
  String get invalidData;

  /// No description provided for @phoneIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Customer phone number is empty'**
  String get phoneIsEmpty;

  /// No description provided for @shareWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Share via WhatsApp'**
  String get shareWhatsApp;

  /// No description provided for @initialBalance.
  ///
  /// In en, this message translates to:
  /// **'Initial Balance'**
  String get initialBalance;

  /// No description provided for @startingBalance.
  ///
  /// In en, this message translates to:
  /// **'Starting balance'**
  String get startingBalance;

  /// No description provided for @editInitialBalance.
  ///
  /// In en, this message translates to:
  /// **'Edit initial balance'**
  String get editInitialBalance;

  /// No description provided for @balanceReset.
  ///
  /// In en, this message translates to:
  /// **'Balance has been reset.'**
  String get balanceReset;

  /// No description provided for @resetBalance.
  ///
  /// In en, this message translates to:
  /// **'Reset balance'**
  String get resetBalance;

  /// No description provided for @balanceHistory.
  ///
  /// In en, this message translates to:
  /// **'Balance History'**
  String get balanceHistory;

  /// No description provided for @noHistory.
  ///
  /// In en, this message translates to:
  /// **'No balance history.'**
  String get noHistory;

  /// No description provided for @confirmResetBalance.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset this customer\'s balance?'**
  String get confirmResetBalance;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @chooseResetType.
  ///
  /// In en, this message translates to:
  /// **'Choose how to reset the balance'**
  String get chooseResetType;

  /// No description provided for @resetToZero.
  ///
  /// In en, this message translates to:
  /// **'Reset to zero'**
  String get resetToZero;

  /// No description provided for @resetToInitial.
  ///
  /// In en, this message translates to:
  /// **'Reset to initial balance'**
  String get resetToInitial;

  /// No description provided for @customerMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Customer Maintenance'**
  String get customerMaintenance;

  /// No description provided for @resetAllCustomers.
  ///
  /// In en, this message translates to:
  /// **'Reset All Customers'**
  String get resetAllCustomers;

  /// No description provided for @resetAllCustomersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reset every customer\'s balance to their initial balance'**
  String get resetAllCustomersSubtitle;

  /// No description provided for @confirmResetAllCustomers.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset all customer balances?'**
  String get confirmResetAllCustomers;

  /// No description provided for @allCustomersReset.
  ///
  /// In en, this message translates to:
  /// **'All customer balances have been reset.'**
  String get allCustomersReset;

  /// No description provided for @initialBalanceUpdated.
  ///
  /// In en, this message translates to:
  /// **'Initial balance updated.'**
  String get initialBalanceUpdated;

  /// No description provided for @unlockApp.
  ///
  /// In en, this message translates to:
  /// **'Unlock App'**
  String get unlockApp;

  /// No description provided for @enterMasterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Master Code'**
  String get enterMasterCode;

  /// No description provided for @authenticateToUnlock.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to unlock'**
  String get authenticateToUnlock;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @incorrectMasterCode.
  ///
  /// In en, this message translates to:
  /// **'Incorrect master code'**
  String get incorrectMasterCode;

  /// No description provided for @discountPercent.
  ///
  /// In en, this message translates to:
  /// **'Discount %'**
  String get discountPercent;

  /// No description provided for @discountAmount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discountAmount;

  /// No description provided for @totalAfterDiscount.
  ///
  /// In en, this message translates to:
  /// **'Total After Discount'**
  String get totalAfterDiscount;

  /// No description provided for @refundAfterDiscount.
  ///
  /// In en, this message translates to:
  /// **'Refund After Discount'**
  String get refundAfterDiscount;

  /// No description provided for @discountedUnitPrice.
  ///
  /// In en, this message translates to:
  /// **'Discounted Unit Price'**
  String get discountedUnitPrice;

  /// No description provided for @saleReceipt.
  ///
  /// In en, this message translates to:
  /// **'Sale Receipt'**
  String get saleReceipt;

  /// No description provided for @saleTotal.
  ///
  /// In en, this message translates to:
  /// **'Sale Total'**
  String get saleTotal;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @saleCompletedPrint.
  ///
  /// In en, this message translates to:
  /// **'Sale completed. Choose how to print or save the receipt.'**
  String get saleCompletedPrint;

  /// No description provided for @saveToDownloads.
  ///
  /// In en, this message translates to:
  /// **'Save to Downloads'**
  String get saveToDownloads;

  /// No description provided for @openPdfViewer.
  ///
  /// In en, this message translates to:
  /// **'Open PDF Viewer'**
  String get openPdfViewer;

  /// No description provided for @backupPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Storage permission denied. Please allow access to create backups.'**
  String get backupPermissionDenied;

  /// No description provided for @backupDatabaseNotFound.
  ///
  /// In en, this message translates to:
  /// **'Database file not found'**
  String get backupDatabaseNotFound;

  /// No description provided for @backupFileNotFound.
  ///
  /// In en, this message translates to:
  /// **'Backup file not found'**
  String get backupFileNotFound;

  /// No description provided for @noBackupFolder.
  ///
  /// In en, this message translates to:
  /// **'No backup folder selected'**
  String get noBackupFolder;

  /// No description provided for @exportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get exportPdf;

  /// No description provided for @deleteCustomer.
  ///
  /// In en, this message translates to:
  /// **'Delete customer'**
  String get deleteCustomer;

  /// No description provided for @salePrice1.
  ///
  /// In en, this message translates to:
  /// **'Sale Price 1 (Retail)'**
  String get salePrice1;

  /// No description provided for @salePrice2.
  ///
  /// In en, this message translates to:
  /// **'Sale Price 2 (Wholesale)'**
  String get salePrice2;

  /// No description provided for @salePrice3.
  ///
  /// In en, this message translates to:
  /// **'Sale Price 3 (Custom)'**
  String get salePrice3;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @barcodeExists.
  ///
  /// In en, this message translates to:
  /// **'Barcode already exists'**
  String get barcodeExists;

  /// No description provided for @productFound.
  ///
  /// In en, this message translates to:
  /// **'Product found'**
  String get productFound;

  /// No description provided for @modifyQuestion.
  ///
  /// In en, this message translates to:
  /// **'Do you want to modify this product?'**
  String get modifyQuestion;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @customPrice.
  ///
  /// In en, this message translates to:
  /// **'custom'**
  String get customPrice;

  /// No description provided for @customPriceRequired.
  ///
  /// In en, this message translates to:
  /// **'custom Price Required'**
  String get customPriceRequired;

  /// No description provided for @cantSellBelowPurchase.
  ///
  /// In en, this message translates to:
  /// **'Can\'t sell below purchase price'**
  String get cantSellBelowPurchase;

  /// No description provided for @giveCash.
  ///
  /// In en, this message translates to:
  /// **'Give cash to customer'**
  String get giveCash;

  /// No description provided for @giveCashAdded.
  ///
  /// In en, this message translates to:
  /// **'Cash transaction added.'**
  String get giveCashAdded;

  /// No description provided for @giveCashRecord.
  ///
  /// In en, this message translates to:
  /// **'Cash given to customer'**
  String get giveCashRecord;

  /// No description provided for @giveCashConfirm.
  ///
  /// In en, this message translates to:
  /// **'Give cash of'**
  String get giveCashConfirm;

  /// No description provided for @giveCashDeleted.
  ///
  /// In en, this message translates to:
  /// **'Cash record deleted'**
  String get giveCashDeleted;

  /// No description provided for @pastBalance.
  ///
  /// In en, this message translates to:
  /// **'Past balance'**
  String get pastBalance;

  /// No description provided for @currentBalance.
  ///
  /// In en, this message translates to:
  /// **'Current balance'**
  String get currentBalance;

  /// No description provided for @paymentReceipt.
  ///
  /// In en, this message translates to:
  /// **'Payment Receipt'**
  String get paymentReceipt;

  /// No description provided for @cashOutReceipt.
  ///
  /// In en, this message translates to:
  /// **'Cash Out Receipt'**
  String get cashOutReceipt;

  /// No description provided for @originalSaleDate.
  ///
  /// In en, this message translates to:
  /// **'Original Sale Date'**
  String get originalSaleDate;

  /// No description provided for @operationId.
  ///
  /// In en, this message translates to:
  /// **'Operation ID'**
  String get operationId;

  /// No description provided for @receiptId.
  ///
  /// In en, this message translates to:
  /// **'Receipt ID'**
  String get receiptId;

  /// No description provided for @signatureLine.
  ///
  /// In en, this message translates to:
  /// **'Signature: __________________________'**
  String get signatureLine;

  /// No description provided for @cashOutSentence.
  ///
  /// In en, this message translates to:
  /// **'The customer ({name}) received an amount of {amount} dollars.'**
  String cashOutSentence(Object name, Object amount);

  /// No description provided for @paymentSentence.
  ///
  /// In en, this message translates to:
  /// **'The customer ({name}) paid an amount of {amount} dollars.'**
  String paymentSentence(Object name, Object amount);

  /// No description provided for @giveCashNote.
  ///
  /// In en, this message translates to:
  /// **'Give cash to customer'**
  String get giveCashNote;

  /// No description provided for @pastDebt.
  ///
  /// In en, this message translates to:
  /// **'Past debt'**
  String get pastDebt;

  /// No description provided for @giveCashAddedShort.
  ///
  /// In en, this message translates to:
  /// **'Cash given recorded.'**
  String get giveCashAddedShort;

  /// No description provided for @giveCashRecordShort.
  ///
  /// In en, this message translates to:
  /// **'Cash given'**
  String get giveCashRecordShort;

  /// No description provided for @giveCashAddedSnack.
  ///
  /// In en, this message translates to:
  /// **'Cash transaction saved.'**
  String get giveCashAddedSnack;

  /// No description provided for @giveCashLabel.
  ///
  /// In en, this message translates to:
  /// **'Give cash'**
  String get giveCashLabel;

  /// No description provided for @paymentAddedSnack.
  ///
  /// In en, this message translates to:
  /// **'Payment saved.'**
  String get paymentAddedSnack;

  /// No description provided for @shareWhatsAppReceipt.
  ///
  /// In en, this message translates to:
  /// **'Share receipt via WhatsApp'**
  String get shareWhatsAppReceipt;

  /// No description provided for @giveCashRecordLabel.
  ///
  /// In en, this message translates to:
  /// **'Give cash record'**
  String get giveCashRecordLabel;

  /// No description provided for @resetBalanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset balance'**
  String get resetBalanceTitle;

  /// No description provided for @returnNote.
  ///
  /// In en, this message translates to:
  /// **'Customer refund (return)'**
  String get returnNote;

  /// No description provided for @limitCustomers.
  ///
  /// In en, this message translates to:
  /// **'The free version allows adding only 2 customers.'**
  String get limitCustomers;

  /// No description provided for @limitProducts.
  ///
  /// In en, this message translates to:
  /// **'The free version allows adding only 5 products.'**
  String get limitProducts;

  /// No description provided for @limitSales.
  ///
  /// In en, this message translates to:
  /// **'The free version allows making only 5 sales.'**
  String get limitSales;

  /// No description provided for @returnItemsHeader.
  ///
  /// In en, this message translates to:
  /// **'Items to return'**
  String get returnItemsHeader;

  /// No description provided for @refundOptions.
  ///
  /// In en, this message translates to:
  /// **'Refund options'**
  String get refundOptions;

  /// No description provided for @returnOptions.
  ///
  /// In en, this message translates to:
  /// **'Return options'**
  String get returnOptions;

  /// No description provided for @processingReturn.
  ///
  /// In en, this message translates to:
  /// **'Processing return...'**
  String get processingReturn;

  /// No description provided for @noItemsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No items available'**
  String get noItemsAvailable;

  /// No description provided for @swipeUpForMore.
  ///
  /// In en, this message translates to:
  /// **'Swipe up to see more'**
  String get swipeUpForMore;

  /// No description provided for @fullReturn.
  ///
  /// In en, this message translates to:
  /// **'Return full sale'**
  String get fullReturn;

  /// No description provided for @selectItemsToReturn.
  ///
  /// In en, this message translates to:
  /// **'Select items to return'**
  String get selectItemsToReturn;

  /// No description provided for @confirmReturnTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm return'**
  String get confirmReturnTitle;

  /// No description provided for @totalRefund.
  ///
  /// In en, this message translates to:
  /// **'Total refund'**
  String get totalRefund;

  /// No description provided for @printOptions.
  ///
  /// In en, this message translates to:
  /// **'Print options'**
  String get printOptions;

  /// No description provided for @printBluetooth.
  ///
  /// In en, this message translates to:
  /// **'Print (Bluetooth)'**
  String get printBluetooth;

  /// No description provided for @printA4.
  ///
  /// In en, this message translates to:
  /// **'A4 PDF'**
  String get printA4;

  /// No description provided for @print80mm.
  ///
  /// In en, this message translates to:
  /// **'80mm PDF'**
  String get print80mm;

  /// No description provided for @returnSummary.
  ///
  /// In en, this message translates to:
  /// **'Return summary'**
  String get returnSummary;

  /// No description provided for @sellPrice3Invalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid number'**
  String get sellPrice3Invalid;

  /// No description provided for @sellPrice3BelowPurchase.
  ///
  /// In en, this message translates to:
  /// **'Sell Price 3 cannot be below purchase price'**
  String get sellPrice3BelowPurchase;

  /// No description provided for @totalInventoryCost.
  ///
  /// In en, this message translates to:
  /// **'Total Inventory Cost'**
  String get totalInventoryCost;

  /// No description provided for @totalRetailValue.
  ///
  /// In en, this message translates to:
  /// **'Total Retail Value'**
  String get totalRetailValue;

  /// No description provided for @totalWholesaleValue.
  ///
  /// In en, this message translates to:
  /// **'Total Wholesale Value'**
  String get totalWholesaleValue;

  /// No description provided for @january.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get january;

  /// No description provided for @february.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get february;

  /// No description provided for @march.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get march;

  /// No description provided for @april.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get april;

  /// No description provided for @may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// No description provided for @june.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get june;

  /// No description provided for @july.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get july;

  /// No description provided for @august.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get august;

  /// No description provided for @september.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get september;

  /// No description provided for @october.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get october;

  /// No description provided for @november.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get november;

  /// No description provided for @december.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get december;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
