// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get posDashboard => 'لوحة التحكم';

  @override
  String get menu => 'القائمة';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get settings => 'الإعدادات';

  @override
  String get inventory => 'المخزن';

  @override
  String get addProduct => 'إضافة منتج';

  @override
  String get createSale => 'إنشاء فاتورة بيع';

  @override
  String get salesHistory => 'سجل المبيعات';

  @override
  String get customers => 'العملاء';

  @override
  String get returnItems => 'إرجاع مواد';

  @override
  String get scan => 'مسح';

  @override
  String get language => 'اللغة';

  @override
  String get saveLanguage => 'حفظ اللغة';

  @override
  String get printer => 'الطابعة';

  @override
  String get noPrinter => 'لا توجد طابعة محددة';

  @override
  String get savedPrinter => 'الطابعة المحفوظة';

  @override
  String get selectPrinter => 'اختيار الطابعة';

  @override
  String get removePrinter => 'إزالة الطابعة';

  @override
  String get languageUpdated => 'تم تحديث اللغة';

  @override
  String get printerRemoved => 'تمت إزالة الطابعة';

  @override
  String get addCustomer => 'إضافة عميل';

  @override
  String get name => 'الاسم';

  @override
  String get phone => 'الهاتف';

  @override
  String get save => 'حفظ';

  @override
  String get nameRequired => 'الاسم مطلوب';

  @override
  String get productName => 'اسم المنتج';

  @override
  String get category => 'الفئة';

  @override
  String get addNewCategory => 'إضافة فئة جديدة';

  @override
  String get categoryName => 'اسم الفئة';

  @override
  String get cancel => 'إلغاء';

  @override
  String get add => 'إضافة';

  @override
  String get purchasePrice => 'سعر الشراء';

  @override
  String get sellPrice1 => 'سعر البيع 1 (مفرق)';

  @override
  String get sellPrice2 => 'سعر البيع 2 (جملة)';

  @override
  String get sellPrice3 => 'سعر البيع 3 (مخصص)';

  @override
  String get stock => 'الكمية';

  @override
  String get unit => 'الوحدة';

  @override
  String get halfDozen => 'نصف دزينة (6)';

  @override
  String get dozen => 'دزينة';

  @override
  String get barcode => 'الباركود';

  @override
  String get saveProduct => 'حفظ المنتج';

  @override
  String get invalidProductDetails => 'بيانات المنتج غير صالحة';

  @override
  String get sellBelowPurchase => 'لا يمكن أن يكون سعر البيع أقل من سعر الشراء';

  @override
  String get productExists => 'المنتج موجود مسبقاً';

  @override
  String get productExistsDetails => 'هذا المنتج موجود مسبقاً:';

  @override
  String get modifyPrices => 'تعديل الأسعار';

  @override
  String get addToInventory => 'إضافة إلى المخزن ';

  @override
  String get addNewCategoryDialog => 'إضافة فئة جديدة';

  @override
  String saleFor(Object name) {
    return 'فاتورة مبيعات لـ $name';
  }

  @override
  String get selectCustomerFirst => 'يرجى اختيار العميل أولاً';

  @override
  String get enterBarcodeOrName => 'أدخل الباركود أو اسم المنتج';

  @override
  String get productNotFound => 'المنتج غير موجود';

  @override
  String get quantity => 'الكمية';

  @override
  String get cannotSellBelowPurchase => 'لا يمكن البيع بسعر أقل من سعر الشراء';

  @override
  String get autoPricing => 'التسعير التلقائي:';

  @override
  String get retail => 'مفرق';

  @override
  String get wholesale => 'جملة';

  @override
  String get special => 'مخصص';

  @override
  String get cannotSwitchMode =>
      'لا يمكن التبديل — بعض الأسعار أقل من سعر الشراء';

  @override
  String get qty => 'الكمية';

  @override
  String get price => 'السعر';

  @override
  String get total => 'المجموع';

  @override
  String get saveSale => 'حفظ الفاتورة';

  @override
  String get selectProduct => 'اختر المنتج';

  @override
  String get manageCategories => 'إدارة الفئات';

  @override
  String get addCategory => 'إضافة فئة';

  @override
  String get editCategory => 'تعديل الفئة';

  @override
  String get selectIcon => 'اختر الأيقونة';

  @override
  String get selectColor => 'اختر اللون';

  @override
  String get sortByName => 'الفرز حسب الاسم';

  @override
  String get searchCategories => 'ابحث عن الفئات...';

  @override
  String get cannotDeleteCategoryWithProducts =>
      'لا يمكن حذف فئة تحتوي على منتجات.';

  @override
  String get completeSale => 'إتمام البيع';

  @override
  String get currentSale => 'الفاتورة الحالية ';

  @override
  String get previousBalance => 'الرصيد السابق';

  @override
  String get previousDebt => 'الدين السابق';

  @override
  String get totalDue => 'الإجمالي المستحق';

  @override
  String get paid => 'المدفوع';

  @override
  String get ok => 'نعم';

  @override
  String get selectCustomerBeforeSale => 'يرجى اختيار عميل قبل إتمام البيع';

  @override
  String get printReceipt => 'طباعة الفاتورة';

  @override
  String get printReceiptQuestion => 'هل تريد طباعة الإيصال؟';

  @override
  String get skip => 'تخطي';

  @override
  String get yes => 'نعم';

  @override
  String get noPrinterConfigured => 'لم يتم إعداد أي طابعة';

  @override
  String get addPrinter => 'إضافة طابعة';

  @override
  String get pdf => 'PDF';

  @override
  String get thermalBluetooth => 'طابعة بلوتوث حرارية';

  @override
  String get checkout => 'الدفع';

  @override
  String get noCustomer => 'لا يوجد عميل';

  @override
  String get totalBeforeDiscount => 'المجموع قبل الخصم';

  @override
  String get payDebt => 'تسديد دين';

  @override
  String get amount => 'المبلغ';

  @override
  String get next => 'التالي';

  @override
  String get managerPinRequired => 'مطلوب رمز المدير';

  @override
  String get enterPin => 'أدخل الرمز';

  @override
  String get incorrectPin => 'رمز غير صحيح';

  @override
  String get confirm => 'تأكيد';

  @override
  String get debtPayment => 'تسديد دين';

  @override
  String get paymentAdded => 'تم إضافة الدفعة.';

  @override
  String get editPayment => 'تعديل الدفعة';

  @override
  String get deletePayment => 'حذف الدفعة';

  @override
  String get note => 'ملاحظة';

  @override
  String get deletePaymentOf => 'حذف دفعة بقيمة';

  @override
  String get delete => 'حذف';

  @override
  String get paymentDeleted => 'تم حذف الدفعة.';

  @override
  String get cannotDeleteCustomerWithBalance =>
      'لا يمكن حذف زبون لديه رصيد غير صفري.';

  @override
  String get customerDeleted => 'تم حذف الزبون.';

  @override
  String get debt => 'عليه';

  @override
  String get credit => 'له';

  @override
  String get balance => 'الرصيد';

  @override
  String get sales => 'المبيعات';

  @override
  String get payments => 'المدفوعات';

  @override
  String get noSalesYet => 'لا توجد مبيعات بعد';

  @override
  String get sale => 'فاتورة';

  @override
  String get noPaymentsYet => 'لا توجد دفعات بعد';

  @override
  String get returnLabel => 'مرتجع';

  @override
  String get selectCustomer => 'اختيار عميل';

  @override
  String get searchCustomers => 'ابحث عن العملاء...';

  @override
  String get noCustomersFound => 'لا يوجد عملاء';

  @override
  String get dashboard => 'لوحة التحكم';

  @override
  String get todaySalesTotal => 'إجمالي مبيعات اليوم';

  @override
  String get numberOfSalesToday => 'عدد المبيعات اليوم';

  @override
  String get totalItemsSoldToday => 'إجمالي العناصر المباعة اليوم';

  @override
  String get topSellingProductsToday => 'أفضل المنتجات مبيعًا اليوم';

  @override
  String get sold => 'مباع';

  @override
  String get editProduct => 'تعديل المنتج';

  @override
  String get unitPieces => 'قطعة';

  @override
  String get unitHalfDozen => 'نصف دزينة (6)';

  @override
  String get unitDozen => 'دزينة (12)';

  @override
  String get saveChanges => 'حفظ التعديلات';

  @override
  String get deleteProduct => 'حذف المنتج';

  @override
  String get adjustStock => 'تعديل المخزون';

  @override
  String get sellPriceBelowPurchase =>
      'لا يمكن أن يكون سعر البيع أقل من سعر الشراء';

  @override
  String get enterSaleId => 'أدخل رقم الفاتورة';

  @override
  String get saleId => 'رقم الفاتورة';

  @override
  String get search => 'بحث';

  @override
  String get inventoryLog => 'سجل المخزن';

  @override
  String get change => 'التغيير';

  @override
  String get date => 'التاريخ';

  @override
  String get columns => 'الأعمدة';

  @override
  String get product => 'منتج';

  @override
  String get purchase => 'سعر الشراء';

  @override
  String get filterByCategory => 'تصفية حسب الفئة';

  @override
  String get allCategories => 'كل الفئات';

  @override
  String get apply => 'تطبيق';

  @override
  String get dozens => 'دزينة';

  @override
  String get pcs => 'قطعة';

  @override
  String get searchNameBarcode => 'ابحث بالاسم أو الباركود';

  @override
  String get lowStockOnly => 'فقط المواد التى على وشك النفاذ ';

  @override
  String get lowStockAlerts => 'تنبيهات انخفاض المخزون';

  @override
  String get allProductsSufficient => 'جميع المنتجات كميتها في المخزن كافية';

  @override
  String get monthlyReport => 'تقرير شهري';

  @override
  String get totalSalesThisMonth => 'إجمالي المبيعات';

  @override
  String get totalItemsSold => 'إجمالي العناصر المباعة';

  @override
  String get totalProfit => 'إجمالي الأرباح';

  @override
  String get topSellingProducts => 'أفضل المنتجات مبيعاً';

  @override
  String get unknown => 'غير معروف';

  @override
  String get products => 'المنتجات';

  @override
  String get scanBarcode => 'مسح الباركود';

  @override
  String get noProductFound => 'لا يوجد منتج لهذا الباركود:';

  @override
  String get scannerError => 'خطأ في الماسح';

  @override
  String get sell1 => 'سعر بيع 1';

  @override
  String get sell2 => 'سعر بيع 2';

  @override
  String get storeProfile => 'ملف المتجر';

  @override
  String get storeName => 'المتجر';

  @override
  String get chooseLogo => 'اختر الشعار';

  @override
  String get inventorySettings => 'إعدادات المخزن';

  @override
  String get lowStockThreshold => 'حد انخفاض المخزون (قطعة)';

  @override
  String get invalidLowStockThreshold => 'حد المخزون غير صالح';

  @override
  String get profileSaved => 'تم حفظ الملف';

  @override
  String get managerPin => 'رمز المدير';

  @override
  String get currentPin => 'الرمز الحالي';

  @override
  String get changePin => 'تغيير الرمز';

  @override
  String get changeManagerPin => 'تغيير رمز المدير';

  @override
  String get newPin => 'رمز جديد (4 أرقام)';

  @override
  String get confirmNewPin => 'تأكيد الرمز الجديد';

  @override
  String get incorrectCurrentPin => 'الرمز الحالي غير صحيح';

  @override
  String get pinMustBe4Digits => 'يجب أن يتكون الرمز من 4 أرقام';

  @override
  String get pinsDoNotMatch => 'الرمزان غير متطابقين';

  @override
  String get pinUpdated => 'تم تحديث الرمز بنجاح';

  @override
  String get resetPinTo0000 => 'إعادة تعيين الرمز إلى 0000';

  @override
  String get pinReset => 'تمت إعادة تعيين الرمز إلى 0000';

  @override
  String get saveProfile => 'حفظ الملف';

  @override
  String get receipt => 'الإيصال';

  @override
  String get storeReceipt => 'المتجر';

  @override
  String get items => 'العناصر';

  @override
  String get x => '×';

  @override
  String get thankYou => 'شكراً لزيارتكم';

  @override
  String get returnHistory => 'سجل المرتجعات';

  @override
  String get reason => 'السبب';

  @override
  String get invalidReturnQty => 'كمية إرجاع غير صحيحة.';

  @override
  String get noItemsSelected => 'لم يتم اختيار أي مواد للإرجاع.';

  @override
  String get confirmReturn => 'تأكيد الإرجاع';

  @override
  String get refundTotal => 'إجمالي المبلغ المسترجع';

  @override
  String get returnCompletedPrint =>
      'تم إرجاع الفاتورة. اختر طريقة طباعة أو حفظ الإيصال.';

  @override
  String get print => 'طباعة';

  @override
  String get returned => 'المرتجع';

  @override
  String get remaining => 'المتبقي';

  @override
  String get returnReason => 'سبب الإرجاع';

  @override
  String get reasonExpired => 'منتهي الصلاحية';

  @override
  String get reasonDamaged => 'تالف';

  @override
  String get reasonWrongItem => 'صنف خاطئ';

  @override
  String get reasonCustomerChangedMind => 'الزبون غيّر رأيه';

  @override
  String get reasonOther => 'سبب آخر';

  @override
  String get refundInCash => 'استرجاع نقدي';

  @override
  String get restockReturnedItems => 'إرجاع المواد للمخزن';

  @override
  String get returnWholeSale => 'إرجاع الفاتورة كاملة';

  @override
  String get saleDetails => 'تفاصيل الفاتورة';

  @override
  String get refund => 'استرجاع نقدي';

  @override
  String get nothingToReturn => 'لا يوجد ما يمكن إرجاعه';

  @override
  String get viewReceipt => 'عرض الإيصال';

  @override
  String get scanning => 'جاري المسح...';

  @override
  String get processingBarcode => 'جاري معالجة الباركود...';

  @override
  String get english => 'الإنجليزية';

  @override
  String get arabic => 'العربية';

  @override
  String get mac => 'MAC';

  @override
  String get currentStock => 'المخزون الحالي';

  @override
  String get quantityAddRemove => 'الكمية (+ للإضافة، - للحذف)';

  @override
  String get addNewCustomer => 'إضافة عميل';

  @override
  String get applyChange => 'تطبيق التعديل';

  @override
  String get notEnoughStock => 'لا يوجد مخزون كافٍ. المتوفر:';

  @override
  String get invalidPhone => 'رقم هاتف خاطئ';

  @override
  String get availableStock => 'المخزون المتوفر';

  @override
  String get piece => 'قطعة';

  @override
  String get pieces => 'قطع';

  @override
  String stockWithUnit(Object stock, Object unit) {
    return '$stock $unit';
  }

  @override
  String get salesProfitToday => 'أرباح المبيعات اليوم';

  @override
  String get profit => 'الربح';

  @override
  String get saleNumber => 'فاتورة رقم ';

  @override
  String get previewPdf => 'معاينة PDF';

  @override
  String get printing => 'جاري الطباعة...';

  @override
  String get customer => 'الزبون';

  @override
  String get backupTitle => 'النسخ الاحتياطي';

  @override
  String get backupFolder => 'مجلد النسخ الاحتياطي';

  @override
  String get createBackup => 'إنشاء نسخة احتياطية';

  @override
  String get restoreBackup => 'استعادة النسخة الاحتياطية';

  @override
  String get viewBackupFolder => 'عرض مجلد النسخ الاحتياطي';

  @override
  String get backupSuccess => 'تمت استعادة النسخة الاحتياطية بنجاح';

  @override
  String get backupSuccessMessage => 'تم إنشاء النسخة الاحتياطية بنجاح';

  @override
  String get backupFailed => 'فشل النسخ الاحتياطي';

  @override
  String get automaticBackup => 'النسخ الاحتياطي التلقائي';

  @override
  String get backupFrequency => 'تكرار النسخ الاحتياطي';

  @override
  String get daily => 'يومي';

  @override
  String get weekly => 'أسبوعي';

  @override
  String get monthly => 'شهري';

  @override
  String get invalidEmail => 'يرجى إدخال بريد إلكتروني صالح';

  @override
  String get managerEmail => 'بريد المدير';

  @override
  String get emailAddress => 'البريد الإلكتروني';

  @override
  String get noPinSet => 'لا يوجد رقم سري';

  @override
  String get noPinSetPleaseSetInProfile =>
      'لا يوجد رقم سري للمدير. يرجى تعيينه من صفحة الملف الشخصي.';

  @override
  String get enterManagerPin => 'أدخل رمز المدير';

  @override
  String get forgotPin => 'نسيت الرمز؟';

  @override
  String get noEmailSetForReset =>
      'لا يوجد بريد إلكتروني لإعادة التعيين. يرجى تعيينه من صفحة الملف الشخصي.';

  @override
  String get resetCodeSent => 'تم إرسال رمز إعادة التعيين إلى بريدك الإلكتروني';

  @override
  String get failedToSendResetCode => 'فشل إرسال رمز إعادة التعيين';

  @override
  String get resetPin => 'إعادة تعيين الرقم السري';

  @override
  String get enterCodeSentToEmail =>
      'أدخل رمز إعادة التعيين المرسل إلى بريدك الإلكتروني';

  @override
  String get resetCode => 'رمز إعادة التعيين';

  @override
  String get invalidOrExpiredResetCode => 'رمز غير صالح أو منتهي الصلاحية';

  @override
  String get backupSize => 'حجم النسخة الاحتياطية';

  @override
  String get lastBackup => 'آخر نسخة احتياطية';

  @override
  String get noBackupYet => 'لا توجد نسخ احتياطية بعد';

  @override
  String get managerLogin => 'تسجيل دخول المدير';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get setManagerPin => 'إنشاء رمز المدير';

  @override
  String get createPin => 'إنشاء رمز';

  @override
  String get pin => 'الرمز';

  @override
  String get editCustomer => 'تعديل الزبون';

  @override
  String get customerName => 'اسم العميل';

  @override
  String get address => 'العنوان';

  @override
  String get invalidCustomerName => 'لا يمكن ترك اسم العميل فارغًا';

  @override
  String get notes => 'ملاحظات';

  @override
  String get trashBin => 'سلة المهملات';

  @override
  String get noDeletedProducts => 'لا توجد منتجات محذوفة';

  @override
  String get deleteForever => 'حذف نهائي؟';

  @override
  String get deleteSelectedProducts => 'هل تريد حذف المنتجات المحددة؟';

  @override
  String get productsDeleted => 'تم حذف المنتجات';

  @override
  String get deletionCancelled => 'تم إلغاء الحذف';

  @override
  String get deleteAllForever => 'حذف الكل نهائيًا';

  @override
  String get confirmDeleteAllForever => 'هل تريد حذف جميع المنتجات نهائيًا؟';

  @override
  String get deletedForeverSuccessfully => 'تم الحذف نهائيًا';

  @override
  String get restoreAll => 'استعادة الكل';

  @override
  String get confirmRestoreAll => 'هل تريد استعادة جميع المنتجات المحذوفة؟';

  @override
  String get restoredSuccessfully => 'تمت الاستعادة بنجاح';

  @override
  String get bulkRestore => 'استعادة متعددة';

  @override
  String get confirmBulkRestore => 'هل تريد استعادة المنتجات المحددة؟';

  @override
  String get bulkRestoredSuccessfully => 'تمت الاستعادة المتعددة بنجاح';

  @override
  String get nothingSelected => 'لم يتم اختيار أي عنصر';

  @override
  String get moveToTrash => 'نقل إلى سلة المحذوفات';

  @override
  String get confirmMoveToTrash => 'هل تريد نقل هذا المنتج إلى سلة المحذوفات؟';

  @override
  String get movedToTrash => 'تم نقل المنتج إلى سلة المحذوفات';

  @override
  String get restore => 'استعادة';

  @override
  String get activation => 'التفعيل';

  @override
  String get activationStatus => 'الحالة';

  @override
  String get activated => 'مفعل';

  @override
  String get notActivated => 'غير مفعل';

  @override
  String get deviceFingerprint => 'بصمة الجهاز';

  @override
  String get copy => 'نسخ';

  @override
  String get whatsapp => 'واتساب';

  @override
  String get activationCode => 'رمز التفعيل';

  @override
  String get activate => 'تفعيل';

  @override
  String get activationSuccess => 'تم التفعيل بنجاح';

  @override
  String get activationFailed => 'رمز التفعيل غير صحيح';

  @override
  String get requiresActivation => 'هذه الميزة تتطلب التفعيل';

  @override
  String get activationExpiry => 'تاريخ انتهاء التفعيل';

  @override
  String get time => 'الوقت';

  @override
  String get refundLabel => 'استرجاع';

  @override
  String get paidDuringSaleLabel => 'مدفوع أثناء البيع';

  @override
  String paidDuringSale(Object saleId) {
    return 'مدفوع أثناء البيع رقم $saleId#';
  }

  @override
  String refundForReturn(Object saleId) {
    return 'استرجاع عن إرجاع رقم $saleId#';
  }

  @override
  String get activationRequiredProducts =>
      'البرنامج غير مفعل الرجاء التفعيل للاستمرار';

  @override
  String get activationRequiredSales =>
      'البرنامج غير مفعل الرجاء التفعيل للاستمرار';

  @override
  String get activationRequiredCustomers =>
      'البرنامج غير مفعل الرجاء التفعيل للاستمرار';

  @override
  String get customerAdded => 'تمت إضافة الزبون بنجاح';

  @override
  String get aboutApp => 'حول التطبيق';

  @override
  String get contactUs => 'تواصل معنا';

  @override
  String get openContactPage => 'فتح صفحة التواصل';

  @override
  String get noProductsToExport => 'لا توجد منتجات للتصدير';

  @override
  String get returnReceipt => 'إيصال إرجاع';

  @override
  String get originalSaleId => 'رقم الفاتورة الأصلية';

  @override
  String get saleDate => 'تاريخ الفاتورة';

  @override
  String get returnedItems => 'المواد المرجعة';

  @override
  String get restock => 'إرجاع للمخزن';

  @override
  String get cashRefund => 'استرجاع نقدي';

  @override
  String get no => 'لا';

  @override
  String get item => 'الصنف';

  @override
  String get exitConfirmation => 'تأكيد الخروج';

  @override
  String get exitQuestion => 'هل تود فعلاً الخروج من التطبيق؟';

  @override
  String get saleInvoice => 'فاتورة مبيعات';

  @override
  String get purchaseInvoice => 'فاتورة شراء';

  @override
  String get createPurchaseInvoice => 'إنشاء فاتورة شراء';

  @override
  String purchaseFrom(Object name) {
    return 'شراء من $name';
  }

  @override
  String get savePurchase => 'حفظ فاتورة الشراء';

  @override
  String get completePurchase => 'إتمام الشراء';

  @override
  String purchaseInvoiceTitle(Object id) {
    return 'فاتورة شراء رقم $id';
  }

  @override
  String purchaseSentence(Object amount, Object name) {
    return 'قام ($name) ببيع منتجات إليك بمبلغ ($amount) دولار.';
  }

  @override
  String get currentPurchase => 'قيمة الشراء الحالية';

  @override
  String get purchaseTotal => 'إجمالي الشراء';

  @override
  String get supplier => 'المورد';

  @override
  String get newProduct => 'منتج جديد';

  @override
  String get costPrice => 'سعر الشراء';

  @override
  String get initialStock => 'الكمية الابتدائية';

  @override
  String get invalidData => 'يرجى إدخال بيانات صحيحة للمنتج.';

  @override
  String get phoneIsEmpty => 'رقم هاتف الزبون غير موجود';

  @override
  String get shareWhatsApp => 'مشاركة عبر واتساب';

  @override
  String get initialBalance => 'الرصيد الابتدائي';

  @override
  String get startingBalance => 'الرصيد عند الإنشاء';

  @override
  String get editInitialBalance => 'تعديل الرصيد الافتتاحي';

  @override
  String get balanceReset => 'تم تصفير الرصيد.';

  @override
  String get resetBalance => 'تصفير الرصيد';

  @override
  String get balanceHistory => 'سجل الرصيد';

  @override
  String get noHistory => 'لا يوجد سجل للحركة.';

  @override
  String get confirmResetBalance =>
      'هل أنت متأكد أنك تريد إعادة ضبط رصيد هذا الزبون؟';

  @override
  String get reset => 'إعادة ضبط';

  @override
  String get chooseResetType => 'اختر طريقة تصفير الرصيد';

  @override
  String get resetToZero => 'تصفير الرصيد';

  @override
  String get resetToInitial => 'إرجاع إلى الرصيد الافتتاحي';

  @override
  String get customerMaintenance => 'صيانة الزبائن';

  @override
  String get resetAllCustomers => 'إعادة ضبط جميع الزبائن';

  @override
  String get resetAllCustomersSubtitle =>
      'إعادة رصيد كل زبون إلى رصيده الابتدائي';

  @override
  String get confirmResetAllCustomers =>
      'هل أنت متأكد أنك تريد إعادة ضبط أرصدة جميع الزبائن؟';

  @override
  String get allCustomersReset => 'تمت إعادة ضبط أرصدة جميع الزبائن.';

  @override
  String get initialBalanceUpdated => 'تم تحديث الرصيد الافتتاحي.';

  @override
  String get unlockApp => 'افتح التطبيق';

  @override
  String get enterMasterCode => 'أدخل رمز الاستعادة';

  @override
  String get authenticateToUnlock => 'التحقق لفتح التطبيق';

  @override
  String get appearance => 'المظهر';

  @override
  String get light => 'فاتح';

  @override
  String get dark => 'داكن';

  @override
  String get incorrectMasterCode => 'رمز المدير غير صحيح';

  @override
  String get discountPercent => 'نسبة الحسم';

  @override
  String get discountAmount => 'قيمة الحسم';

  @override
  String get totalAfterDiscount => 'المجموع بعد الخصم';

  @override
  String get refundAfterDiscount => 'المبلغ المسترجع بعد الحسم';

  @override
  String get discountedUnitPrice => 'السعر بعد الحسم';

  @override
  String get saleReceipt => 'فاتورة بيع';

  @override
  String get saleTotal => 'Sale Total';

  @override
  String get discount => 'الخصم';

  @override
  String get share => 'مشاركة';

  @override
  String get saleCompletedPrint =>
      'تمت عملية البيع. اختر طريقة طباعة أو حفظ الإيصال.';

  @override
  String get saveToDownloads => 'حفظ في التنزيلات';

  @override
  String get openPdfViewer => 'فتح عارض PDF';

  @override
  String get backupPermissionDenied =>
      'تم رفض إذن التخزين. يرجى السماح بالوصول لإنشاء النسخ الاحتياطية.';

  @override
  String get backupDatabaseNotFound => 'ملف قاعدة البيانات غير موجود';

  @override
  String get backupFileNotFound => 'ملف النسخة الاحتياطية غير موجود';

  @override
  String get noBackupFolder => 'لم يتم اختيار مجلد النسخ الاحتياطي';

  @override
  String get exportPdf => 'تصدير PDF';

  @override
  String get deleteCustomer => 'حذف الزبون';

  @override
  String get salePrice1 => 'Sale Price 1 (Retail)';

  @override
  String get salePrice2 => 'Sale Price 2 (Wholesale)';

  @override
  String get salePrice3 => 'Sale Price 3 (Custom)';

  @override
  String get categories => 'الفئات';

  @override
  String get barcodeExists => 'الباركود موجود بالفعل';

  @override
  String get productFound => 'تم العثور على المنتج';

  @override
  String get modifyQuestion => 'هل تريد تعديل هذا المنتج؟';

  @override
  String get custom => 'مخصص';

  @override
  String get customPrice => 'السعر المخصص';

  @override
  String get customPriceRequired => 'السعر المخصص مطلوب';

  @override
  String get cantSellBelowPurchase => 'لا يمكن البيع بأقل من سعر الشراء';

  @override
  String get giveCash => 'إعطاء مبلغ للزبون';

  @override
  String get giveCashAdded => 'تم إضافة عملية إعطاء المبلغ.';

  @override
  String get giveCashRecord => 'مبلغ مُعطى للزبون';

  @override
  String get giveCashConfirm => 'صرف مبلغ قدره';

  @override
  String get giveCashDeleted => 'تم حذف عملية صرف مبلغ';

  @override
  String get pastBalance => 'الرصيد السابق';

  @override
  String get currentBalance => 'الرصيد الحالي';

  @override
  String get paymentReceipt => 'إيصال دفع';

  @override
  String get cashOutReceipt => 'إيصال صرف نقدي';

  @override
  String get originalSaleDate => 'تاريخ الفاتورة الأصلية';

  @override
  String get operationId => 'رقم العملية';

  @override
  String get receiptId => 'رقم الإيصال';

  @override
  String get signatureLine => 'توقيع المسؤول: __________________________';

  @override
  String cashOutSentence(Object name, Object amount) {
    return 'قام السيد ($name) باستلام مبلغ وقدره ($amount) دولار.';
  }

  @override
  String paymentSentence(Object name, Object amount) {
    return 'قام السيد ($name) بدفع مبلغ وقدره ($amount) دولار.';
  }

  @override
  String get giveCashNote => 'قام السيد باستلام مبلغ';

  @override
  String get pastDebt => 'الدين السابق';

  @override
  String get giveCashAddedShort => 'تم تسجيل إعطاء المبلغ.';

  @override
  String get giveCashRecordShort => 'إعطاء مبلغ';

  @override
  String get giveCashAddedSnack => 'تم حفظ عملية إعطاء المبلغ.';

  @override
  String get giveCashLabel => 'إعطاء مبلغ';

  @override
  String get paymentAddedSnack => 'تم حفظ الدفعة.';

  @override
  String get shareWhatsAppReceipt => 'مشاركة الإيصال عبر واتساب';

  @override
  String get giveCashRecordLabel => 'سجل إعطاء مبلغ';

  @override
  String get resetBalanceTitle => 'تصفير الرصيد';

  @override
  String get returnNote => 'قام السيد باسترجاع مبلغ';

  @override
  String get limitCustomers => 'النسخة غير مفعلة — يسمح بإضافة زبونين فقط.';

  @override
  String get limitProducts => 'النسخة غير مفعلة — يسمح بإضافة 5 مواد فقط.';

  @override
  String get limitSales => 'النسخة غير مفعلة — يسمح بعمل 5 فواتير فقط.';

  @override
  String get returnItemsHeader => 'المواد المراد إرجاعها';

  @override
  String get refundOptions => 'خيارات الاسترجاع';

  @override
  String get returnOptions => 'خيارات الإرجاع';

  @override
  String get processingReturn => 'جاري معالجة الإرجاع...';

  @override
  String get noItemsAvailable => 'لا توجد مواد';

  @override
  String get swipeUpForMore => 'اسحب للأعلى لرؤية المزيد';

  @override
  String get fullReturn => 'إرجاع الفاتورة كاملة';

  @override
  String get selectItemsToReturn => 'اختر المواد المراد إرجاعها';

  @override
  String get confirmReturnTitle => 'تأكيد الإرجاع';

  @override
  String get totalRefund => 'إجمالي المبلغ المسترجع';

  @override
  String get printOptions => 'خيارات الطباعة';

  @override
  String get printBluetooth => 'طباعة (بلوتوث)';

  @override
  String get printA4 => 'PDF A4';

  @override
  String get print80mm => 'PDF 80mm';

  @override
  String get returnSummary => 'ملخص الإرجاع';

  @override
  String get sellPrice3Invalid => 'رقم غير صالح';

  @override
  String get sellPrice3BelowPurchase =>
      'سعر البيع 3 لا يمكن أن يكون أقل من سعر الشراء';

  @override
  String get totalInventoryCost => 'إجمالي تكلفة المخزون';

  @override
  String get totalRetailValue => 'إجمالي قيمة البيع بالمفرق';

  @override
  String get totalWholesaleValue => 'إجمالي قيمة البيع بالجملة';

  @override
  String get january => 'كانون الثاني';

  @override
  String get february => 'شباط';

  @override
  String get march => 'آذار';

  @override
  String get april => 'نيسان';

  @override
  String get may => 'أيار';

  @override
  String get june => 'حزيران';

  @override
  String get july => 'تموز';

  @override
  String get august => 'آب';

  @override
  String get september => 'أيلول';

  @override
  String get october => 'تشرين الأول';

  @override
  String get november => 'تشرين الثاني';

  @override
  String get december => 'كانون الأول';
}
