// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get posDashboard => 'POS Dashboard';

  @override
  String get menu => 'Menu';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get inventory => 'Inventory';

  @override
  String get addProduct => 'Add Product';

  @override
  String get createSale => 'Create Sale';

  @override
  String get salesHistory => 'Sales History';

  @override
  String get customers => 'Customers';

  @override
  String get returnItems => 'Return items';

  @override
  String get scan => 'Scan';

  @override
  String get language => 'Language';

  @override
  String get saveLanguage => 'Save Language';

  @override
  String get printer => 'Printer';

  @override
  String get noPrinter => 'No printer selected';

  @override
  String get savedPrinter => 'Saved Printer';

  @override
  String get selectPrinter => 'Select Printer';

  @override
  String get removePrinter => 'Remove Printer';

  @override
  String get languageUpdated => 'Language updated';

  @override
  String get printerRemoved => 'Printer removed';

  @override
  String get addCustomer => 'Add Customer';

  @override
  String get name => 'Name';

  @override
  String get phone => 'Phone';

  @override
  String get save => 'Save';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get productName => 'Product Name';

  @override
  String get category => 'Category';

  @override
  String get addNewCategory => 'Add New Category';

  @override
  String get categoryName => 'Category Name';

  @override
  String get cancel => 'Cancel';

  @override
  String get add => 'Add';

  @override
  String get purchasePrice => 'Purchase Price';

  @override
  String get sellPrice1 => 'Sell Price 1';

  @override
  String get sellPrice2 => 'Sell Price 2';

  @override
  String get sellPrice3 => 'Sell Price 3';

  @override
  String get stock => 'Stock';

  @override
  String get unit => 'Unit';

  @override
  String get halfDozen => 'Half‑Dozen (6)';

  @override
  String get dozen => 'Dozen';

  @override
  String get barcode => 'Barcode';

  @override
  String get saveProduct => 'Save Product';

  @override
  String get invalidProductDetails => 'Invalid product details';

  @override
  String get sellBelowPurchase =>
      'Selling price cannot be lower than purchase price';

  @override
  String get productExists => 'Product Already Exists';

  @override
  String get productExistsDetails => 'This product already exists:';

  @override
  String get modifyPrices => 'Modify Prices';

  @override
  String get addToInventory => 'Add to Inventory';

  @override
  String get addNewCategoryDialog => 'Add New Category';

  @override
  String saleFor(Object name) {
    return 'Sale for $name';
  }

  @override
  String get selectCustomerFirst => 'Please select a customer first';

  @override
  String get enterBarcodeOrName => 'Enter barcode or product name';

  @override
  String get productNotFound => 'Product not found';

  @override
  String get quantity => 'Quantity';

  @override
  String get cannotSellBelowPurchase => 'Cannot sell below purchase price';

  @override
  String get autoPricing => 'Auto Pricing:';

  @override
  String get retail => 'Retail';

  @override
  String get wholesale => 'Wholesale';

  @override
  String get special => 'custom';

  @override
  String get cannotSwitchMode =>
      'Cannot switch — some prices are below purchase price';

  @override
  String get qty => 'Qty';

  @override
  String get price => 'Price';

  @override
  String get total => 'Total';

  @override
  String get saveSale => 'Save Sale';

  @override
  String get selectProduct => 'Select Product';

  @override
  String get manageCategories => 'Manage Categories';

  @override
  String get addCategory => 'Add Category';

  @override
  String get editCategory => 'Edit Category';

  @override
  String get selectIcon => 'Select Icon';

  @override
  String get selectColor => 'Select Color';

  @override
  String get sortByName => 'Sort by Name';

  @override
  String get searchCategories => 'Search categories...';

  @override
  String get cannotDeleteCategoryWithProducts =>
      'Cannot delete category with products.';

  @override
  String get completeSale => 'Complete Sale';

  @override
  String get currentSale => 'Current Sale';

  @override
  String get previousBalance => 'Previous balance';

  @override
  String get previousDebt => 'Previous debt';

  @override
  String get totalDue => 'Total due';

  @override
  String get paid => 'Paid';

  @override
  String get ok => 'OK';

  @override
  String get selectCustomerBeforeSale =>
      'Please select a customer before completing sale';

  @override
  String get printReceipt => 'Print Receipt';

  @override
  String get printReceiptQuestion => 'Do you want to print the receipt?';

  @override
  String get skip => 'Skip';

  @override
  String get yes => 'Yes';

  @override
  String get noPrinterConfigured => 'No printer configured';

  @override
  String get addPrinter => 'Add Printer';

  @override
  String get pdf => 'PDF';

  @override
  String get thermalBluetooth => 'Thermal Bluetooth Printer';

  @override
  String get checkout => 'Checkout';

  @override
  String get noCustomer => 'No customer';

  @override
  String get totalBeforeDiscount => 'Total Before Discount';

  @override
  String get payDebt => 'Pay debt';

  @override
  String get amount => 'Amount';

  @override
  String get next => 'Next';

  @override
  String get managerPinRequired => 'Manager PIN Required';

  @override
  String get enterPin => 'Enter PIN';

  @override
  String get incorrectPin => 'Incorrect PIN';

  @override
  String get confirm => 'Confirm';

  @override
  String get debtPayment => 'Debt payment';

  @override
  String get paymentAdded => 'Payment added.';

  @override
  String get editPayment => 'Edit payment';

  @override
  String get deletePayment => 'Delete payment';

  @override
  String get note => 'Note';

  @override
  String get deletePaymentOf => 'Delete payment of';

  @override
  String get delete => 'Delete';

  @override
  String get paymentDeleted => 'Payment deleted.';

  @override
  String get cannotDeleteCustomerWithBalance =>
      'Cannot delete a customer with non-zero balance.';

  @override
  String get customerDeleted => 'Customer deleted.';

  @override
  String get debt => 'Debt';

  @override
  String get credit => 'Credit';

  @override
  String get balance => 'Balance';

  @override
  String get sales => 'Sales';

  @override
  String get payments => 'Payments';

  @override
  String get noSalesYet => 'No sales yet';

  @override
  String get sale => 'Sale';

  @override
  String get noPaymentsYet => 'No payments yet';

  @override
  String get returnLabel => 'Return';

  @override
  String get selectCustomer => 'Select Customer';

  @override
  String get searchCustomers => 'Search customers...';

  @override
  String get noCustomersFound => 'No customers found';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get todaySalesTotal => 'Today\'s Sales Total';

  @override
  String get numberOfSalesToday => 'Number of Sales Today';

  @override
  String get totalItemsSoldToday => 'Total Items Sold Today';

  @override
  String get topSellingProductsToday => 'Top Selling Products Today';

  @override
  String get sold => 'Sold';

  @override
  String get editProduct => 'Edit Product';

  @override
  String get unitPieces => 'Pieces';

  @override
  String get unitHalfDozen => 'Half‑Dozen (6)';

  @override
  String get unitDozen => 'Dozen (12)';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get deleteProduct => 'Delete Product';

  @override
  String get adjustStock => 'Adjust Stock';

  @override
  String get sellPriceBelowPurchase =>
      'Sell price cannot be lower than purchase price';

  @override
  String get enterSaleId => 'Enter Sale ID';

  @override
  String get saleId => 'Sale ID';

  @override
  String get search => 'Search';

  @override
  String get inventoryLog => 'Inventory Log';

  @override
  String get change => 'Change';

  @override
  String get date => 'Date';

  @override
  String get columns => 'Columns';

  @override
  String get product => 'Product';

  @override
  String get purchase => 'Purchase';

  @override
  String get filterByCategory => 'Filter by Category';

  @override
  String get allCategories => 'All Categories';

  @override
  String get apply => 'Apply';

  @override
  String get dozens => 'Dozens';

  @override
  String get pcs => 'pcs';

  @override
  String get searchNameBarcode => 'Search by name or barcode';

  @override
  String get lowStockOnly => 'Low stock only';

  @override
  String get lowStockAlerts => 'Low Stock Alerts';

  @override
  String get allProductsSufficient => 'All products are sufficiently stocked';

  @override
  String get monthlyReport => 'Monthly Report';

  @override
  String get totalSalesThisMonth => 'Total Sales';

  @override
  String get totalItemsSold => 'Total Items Sold';

  @override
  String get totalProfit => 'Total Profit';

  @override
  String get topSellingProducts => 'Top Selling Products';

  @override
  String get unknown => 'Unknown';

  @override
  String get products => 'Products';

  @override
  String get scanBarcode => 'Scan Barcode';

  @override
  String get noProductFound => 'No product found for barcode:';

  @override
  String get scannerError => 'Scanner error';

  @override
  String get sell1 => 'Sell1';

  @override
  String get sell2 => 'Sell2';

  @override
  String get storeProfile => 'Store Profile';

  @override
  String get storeName => 'Store';

  @override
  String get chooseLogo => 'Choose logo';

  @override
  String get inventorySettings => 'Inventory Settings';

  @override
  String get lowStockThreshold => 'Low Stock Threshold (pieces)';

  @override
  String get invalidLowStockThreshold => 'Invalid low stock threshold';

  @override
  String get profileSaved => 'Profile saved';

  @override
  String get managerPin => 'Manager PIN';

  @override
  String get currentPin => 'Current PIN';

  @override
  String get changePin => 'Change PIN';

  @override
  String get changeManagerPin => 'Change Manager PIN';

  @override
  String get newPin => 'New PIN (4 digits)';

  @override
  String get confirmNewPin => 'Confirm New PIN';

  @override
  String get incorrectCurrentPin => 'Incorrect current PIN';

  @override
  String get pinMustBe4Digits => 'PIN must be 4 digits';

  @override
  String get pinsDoNotMatch => 'PINs do not match';

  @override
  String get pinUpdated => 'PIN updated successfully';

  @override
  String get resetPinTo0000 => 'Reset PIN to 0000';

  @override
  String get pinReset => 'PIN reset to 0000';

  @override
  String get saveProfile => 'Save Profile';

  @override
  String get receipt => 'Receipt';

  @override
  String get storeReceipt => 'Store';

  @override
  String get items => 'Items';

  @override
  String get x => 'x';

  @override
  String get thankYou => 'Thank you';

  @override
  String get returnHistory => 'Return History';

  @override
  String get reason => 'Reason';

  @override
  String get invalidReturnQty => 'Invalid return quantity.';

  @override
  String get noItemsSelected => 'No items selected for return.';

  @override
  String get confirmReturn => 'Confirm return';

  @override
  String get refundTotal => 'Refund total';

  @override
  String get returnCompletedPrint =>
      'Return completed. Choose how to print or save the receipt.';

  @override
  String get print => 'Print';

  @override
  String get returned => 'Returned';

  @override
  String get remaining => 'Remaining';

  @override
  String get returnReason => 'Return reason';

  @override
  String get reasonExpired => 'Expired';

  @override
  String get reasonDamaged => 'Damaged';

  @override
  String get reasonWrongItem => 'Wrong item';

  @override
  String get reasonCustomerChangedMind => 'Customer changed mind';

  @override
  String get reasonOther => 'Other';

  @override
  String get refundInCash => 'Refund in cash';

  @override
  String get restockReturnedItems => 'Restock returned items';

  @override
  String get returnWholeSale => 'Return whole sale';

  @override
  String get saleDetails => 'Sale Details';

  @override
  String get refund => 'Refund';

  @override
  String get nothingToReturn => 'Nothing to return';

  @override
  String get viewReceipt => 'View Receipt';

  @override
  String get scanning => 'Scanning...';

  @override
  String get processingBarcode => 'Processing barcode...';

  @override
  String get english => 'English';

  @override
  String get arabic => 'Arabic';

  @override
  String get mac => 'MAC';

  @override
  String get currentStock => 'Current Stock';

  @override
  String get quantityAddRemove => 'Quantity (+ to add, - to remove)';

  @override
  String get addNewCustomer => 'Add NewCustomer';

  @override
  String get applyChange => 'Apply Change';

  @override
  String get notEnoughStock => 'Not enough stock. Available:';

  @override
  String get invalidPhone => 'Invalid Phone Number';

  @override
  String get availableStock => 'Available Stock';

  @override
  String get piece => 'Piece';

  @override
  String get pieces => 'Pieces';

  @override
  String stockWithUnit(Object stock, Object unit) {
    return '$stock $unit';
  }

  @override
  String get salesProfitToday => 'Sales Profit Today';

  @override
  String get profit => 'Profit';

  @override
  String get saleNumber => 'Sale #';

  @override
  String get previewPdf => 'Preview PDF';

  @override
  String get printing => 'Printing...';

  @override
  String get customer => 'Customer';

  @override
  String get backupTitle => 'Backup';

  @override
  String get backupFolder => 'Backup Folder';

  @override
  String get createBackup => 'Create Backup';

  @override
  String get restoreBackup => 'Restore Backup';

  @override
  String get viewBackupFolder => 'View Backup Folder';

  @override
  String get backupSuccess => 'Backup restored successfully';

  @override
  String get backupSuccessMessage => 'Backup created successfully';

  @override
  String get backupFailed => 'Backup failed';

  @override
  String get automaticBackup => 'Automatic Backup';

  @override
  String get backupFrequency => 'Backup Frequency';

  @override
  String get daily => 'Daily';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get invalidEmail => 'Please enter a valid email address';

  @override
  String get managerEmail => 'Manager Email';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get noPinSet => 'No PIN set';

  @override
  String get noPinSetPleaseSetInProfile =>
      'No manager PIN set. Please set it in the profile page.';

  @override
  String get enterManagerPin => 'Enter Manager PIN';

  @override
  String get forgotPin => 'Forgot PIN?';

  @override
  String get noEmailSetForReset =>
      'No email set for reset. Please set it in the profile page.';

  @override
  String get resetCodeSent => 'Reset code sent to your email';

  @override
  String get failedToSendResetCode => 'Failed to send reset code';

  @override
  String get resetPin => 'Reset PIN';

  @override
  String get enterCodeSentToEmail => 'Enter the reset code sent to your email';

  @override
  String get resetCode => 'Reset Code';

  @override
  String get invalidOrExpiredResetCode => 'Invalid or expired reset code';

  @override
  String get backupSize => 'Backup Size';

  @override
  String get lastBackup => 'Last Backup';

  @override
  String get noBackupYet => 'No backups yet';

  @override
  String get managerLogin => 'Manager Login';

  @override
  String get login => 'Login';

  @override
  String get setManagerPin => 'Set Manager PIN';

  @override
  String get createPin => 'Create PIN';

  @override
  String get pin => 'PIN';

  @override
  String get editCustomer => 'Edit customer';

  @override
  String get customerName => 'Customer Name';

  @override
  String get address => 'Address';

  @override
  String get invalidCustomerName => 'Customer name cannot be empty';

  @override
  String get notes => 'Notes';

  @override
  String get trashBin => 'Trash Bin';

  @override
  String get noDeletedProducts => 'No deleted products';

  @override
  String get deleteForever => 'Delete permanently?';

  @override
  String get deleteSelectedProducts => 'Delete selected products?';

  @override
  String get productsDeleted => 'Products deleted';

  @override
  String get deletionCancelled => 'Deletion cancelled';

  @override
  String get deleteAllForever => 'Delete all permanently';

  @override
  String get confirmDeleteAllForever =>
      'Are you sure you want to permanently delete all products?';

  @override
  String get deletedForeverSuccessfully => 'Permanently deleted';

  @override
  String get restoreAll => 'Restore all';

  @override
  String get confirmRestoreAll =>
      'Do you want to restore all deleted products?';

  @override
  String get restoredSuccessfully => 'Restored successfully';

  @override
  String get bulkRestore => 'Bulk restore';

  @override
  String get confirmBulkRestore =>
      'Do you want to restore the selected products?';

  @override
  String get bulkRestoredSuccessfully => 'Bulk restore completed';

  @override
  String get nothingSelected => 'No items selected';

  @override
  String get moveToTrash => 'Move to Trash';

  @override
  String get confirmMoveToTrash =>
      'Do you want to move this product to the trash?';

  @override
  String get movedToTrash => 'Product moved to trash';

  @override
  String get restore => 'Restore';

  @override
  String get activation => 'Activation';

  @override
  String get activationStatus => 'Status';

  @override
  String get activated => 'Activated';

  @override
  String get notActivated => 'Not Activated';

  @override
  String get deviceFingerprint => 'Device Fingerprint';

  @override
  String get copy => 'Copy';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get activationCode => 'Activation Code';

  @override
  String get activate => 'Activate';

  @override
  String get activationSuccess => 'Activated successfully';

  @override
  String get activationFailed => 'Invalid activation code';

  @override
  String get requiresActivation => 'This feature requires activation';

  @override
  String get activationExpiry => 'Expires on';

  @override
  String get time => 'Time';

  @override
  String get refundLabel => 'Refund';

  @override
  String get paidDuringSaleLabel => 'Paid during sale';

  @override
  String paidDuringSale(Object saleId) {
    return 'Paid during sale #$saleId';
  }

  @override
  String refundForReturn(Object saleId) {
    return 'Refund for return #$saleId';
  }

  @override
  String get activationRequiredProducts =>
      'Application not activated. Please activate to continue';

  @override
  String get activationRequiredSales =>
      'Application not activated. Please activate to continue';

  @override
  String get activationRequiredCustomers =>
      'Application not activated. Please activate to continue';

  @override
  String get customerAdded => 'Customer added successfully';

  @override
  String get aboutApp => 'About';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get openContactPage => 'Open Contact Page';

  @override
  String get noProductsToExport => 'No products to export';

  @override
  String get returnReceipt => 'Return Receipt';

  @override
  String get originalSaleId => 'Original Sale ID';

  @override
  String get saleDate => 'Sale Date';

  @override
  String get returnedItems => 'Returned Items';

  @override
  String get restock => 'Restock';

  @override
  String get cashRefund => 'Cash Refund';

  @override
  String get no => 'No';

  @override
  String get item => 'Item';

  @override
  String get exitConfirmation => 'Exit Confirmation';

  @override
  String get exitQuestion => 'Are you sure you want to exit the app?';

  @override
  String get saleInvoice => 'Sale Invoice';

  @override
  String get purchaseInvoice => 'Purchase Invoice';

  @override
  String get createPurchaseInvoice => 'Create Purchase Invoice';

  @override
  String purchaseFrom(Object name) {
    return 'Purchase from $name';
  }

  @override
  String get savePurchase => 'Save Purchase';

  @override
  String get completePurchase => 'Complete Purchase';

  @override
  String purchaseInvoiceTitle(Object id) {
    return 'Purchase Invoice No. $id';
  }

  @override
  String purchaseSentence(Object amount, Object name) {
    return 'The customer ($name) sold products to you for $amount dollars.';
  }

  @override
  String get currentPurchase => 'Current Purchase';

  @override
  String get purchaseTotal => 'Purchase Total';

  @override
  String get supplier => 'Supplier';

  @override
  String get newProduct => 'New Product';

  @override
  String get costPrice => 'Cost Price';

  @override
  String get initialStock => 'Initial Stock';

  @override
  String get invalidData => 'Please enter valid product information.';

  @override
  String get phoneIsEmpty => 'Customer phone number is empty';

  @override
  String get shareWhatsApp => 'Share via WhatsApp';

  @override
  String get initialBalance => 'Initial Balance';

  @override
  String get startingBalance => 'Starting balance';

  @override
  String get editInitialBalance => 'Edit initial balance';

  @override
  String get balanceReset => 'Balance has been reset.';

  @override
  String get resetBalance => 'Reset balance';

  @override
  String get balanceHistory => 'Balance History';

  @override
  String get noHistory => 'No balance history.';

  @override
  String get confirmResetBalance =>
      'Are you sure you want to reset this customer\'s balance?';

  @override
  String get reset => 'Reset';

  @override
  String get chooseResetType => 'Choose how to reset the balance';

  @override
  String get resetToZero => 'Reset to zero';

  @override
  String get resetToInitial => 'Reset to initial balance';

  @override
  String get customerMaintenance => 'Customer Maintenance';

  @override
  String get resetAllCustomers => 'Reset All Customers';

  @override
  String get resetAllCustomersSubtitle =>
      'Reset every customer\'s balance to their initial balance';

  @override
  String get confirmResetAllCustomers =>
      'Are you sure you want to reset all customer balances?';

  @override
  String get allCustomersReset => 'All customer balances have been reset.';

  @override
  String get initialBalanceUpdated => 'Initial balance updated.';

  @override
  String get unlockApp => 'Unlock App';

  @override
  String get enterMasterCode => 'Enter Master Code';

  @override
  String get authenticateToUnlock => 'Authenticate to unlock';

  @override
  String get appearance => 'Appearance';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get incorrectMasterCode => 'Incorrect master code';

  @override
  String get discountPercent => 'Discount %';

  @override
  String get discountAmount => 'Discount';

  @override
  String get totalAfterDiscount => 'Total After Discount';

  @override
  String get refundAfterDiscount => 'Refund After Discount';

  @override
  String get discountedUnitPrice => 'Discounted Unit Price';

  @override
  String get saleReceipt => 'Sale Receipt';

  @override
  String get saleTotal => 'Sale Total';

  @override
  String get discount => 'Discount';

  @override
  String get share => 'Share';

  @override
  String get saleCompletedPrint =>
      'Sale completed. Choose how to print or save the receipt.';

  @override
  String get saveToDownloads => 'Save to Downloads';

  @override
  String get openPdfViewer => 'Open PDF Viewer';

  @override
  String get backupPermissionDenied =>
      'Storage permission denied. Please allow access to create backups.';

  @override
  String get backupDatabaseNotFound => 'Database file not found';

  @override
  String get backupFileNotFound => 'Backup file not found';

  @override
  String get noBackupFolder => 'No backup folder selected';

  @override
  String get exportPdf => 'Export PDF';

  @override
  String get deleteCustomer => 'Delete customer';

  @override
  String get salePrice1 => 'Sale Price 1 (Retail)';

  @override
  String get salePrice2 => 'Sale Price 2 (Wholesale)';

  @override
  String get salePrice3 => 'Sale Price 3 (Custom)';

  @override
  String get categories => 'Categories';

  @override
  String get barcodeExists => 'Barcode already exists';

  @override
  String get productFound => 'Product found';

  @override
  String get modifyQuestion => 'Do you want to modify this product?';

  @override
  String get custom => 'Custom';

  @override
  String get customPrice => 'custom';

  @override
  String get customPriceRequired => 'custom Price Required';

  @override
  String get cantSellBelowPurchase => 'Can\'t sell below purchase price';

  @override
  String get giveCash => 'Give cash to customer';

  @override
  String get giveCashAdded => 'Cash transaction added.';

  @override
  String get giveCashRecord => 'Cash given to customer';

  @override
  String get giveCashConfirm => 'Give cash of';

  @override
  String get giveCashDeleted => 'Cash record deleted';

  @override
  String get pastBalance => 'Past balance';

  @override
  String get currentBalance => 'Current balance';

  @override
  String get paymentReceipt => 'Payment Receipt';

  @override
  String get cashOutReceipt => 'Cash Out Receipt';

  @override
  String get originalSaleDate => 'Original Sale Date';

  @override
  String get operationId => 'Operation ID';

  @override
  String get receiptId => 'Receipt ID';

  @override
  String get signatureLine => 'Signature: __________________________';

  @override
  String cashOutSentence(Object name, Object amount) {
    return 'The customer ($name) received an amount of $amount dollars.';
  }

  @override
  String paymentSentence(Object name, Object amount) {
    return 'The customer ($name) paid an amount of $amount dollars.';
  }

  @override
  String get giveCashNote => 'Give cash to customer';

  @override
  String get pastDebt => 'Past debt';

  @override
  String get giveCashAddedShort => 'Cash given recorded.';

  @override
  String get giveCashRecordShort => 'Cash given';

  @override
  String get giveCashAddedSnack => 'Cash transaction saved.';

  @override
  String get giveCashLabel => 'Give cash';

  @override
  String get paymentAddedSnack => 'Payment saved.';

  @override
  String get shareWhatsAppReceipt => 'Share receipt via WhatsApp';

  @override
  String get giveCashRecordLabel => 'Give cash record';

  @override
  String get resetBalanceTitle => 'Reset balance';

  @override
  String get returnNote => 'Customer refund (return)';

  @override
  String get limitCustomers =>
      'The free version allows adding only 2 customers.';

  @override
  String get limitProducts => 'The free version allows adding only 5 products.';

  @override
  String get limitSales => 'The free version allows making only 5 sales.';

  @override
  String get returnItemsHeader => 'Items to return';

  @override
  String get refundOptions => 'Refund options';

  @override
  String get returnOptions => 'Return options';

  @override
  String get processingReturn => 'Processing return...';

  @override
  String get noItemsAvailable => 'No items available';

  @override
  String get swipeUpForMore => 'Swipe up to see more';

  @override
  String get fullReturn => 'Return full sale';

  @override
  String get selectItemsToReturn => 'Select items to return';

  @override
  String get confirmReturnTitle => 'Confirm return';

  @override
  String get totalRefund => 'Total refund';

  @override
  String get printOptions => 'Print options';

  @override
  String get printBluetooth => 'Print (Bluetooth)';

  @override
  String get printA4 => 'A4 PDF';

  @override
  String get print80mm => '80mm PDF';

  @override
  String get returnSummary => 'Return summary';

  @override
  String get sellPrice3Invalid => 'Invalid number';

  @override
  String get sellPrice3BelowPurchase =>
      'Sell Price 3 cannot be below purchase price';

  @override
  String get totalInventoryCost => 'Total Inventory Cost';

  @override
  String get totalRetailValue => 'Total Retail Value';

  @override
  String get totalWholesaleValue => 'Total Wholesale Value';

  @override
  String get january => 'January';

  @override
  String get february => 'February';

  @override
  String get march => 'March';

  @override
  String get april => 'April';

  @override
  String get may => 'May';

  @override
  String get june => 'June';

  @override
  String get july => 'July';

  @override
  String get august => 'August';

  @override
  String get september => 'September';

  @override
  String get october => 'October';

  @override
  String get november => 'November';

  @override
  String get december => 'December';
}
