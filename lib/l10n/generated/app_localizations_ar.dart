// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'سمارا للحسابات';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navRegister => 'السجل';

  @override
  String get navSummary => 'الملخص';

  @override
  String get navAccounts => 'الحسابات';

  @override
  String get navCategories => 'التصنيفات';

  @override
  String get actionCancel => 'إلغاء';

  @override
  String get actionSave => 'حفظ';

  @override
  String get actionDelete => 'حذف';

  @override
  String get actionDone => 'تم';

  @override
  String get actionContinue => 'متابعة';

  @override
  String get actionDismiss => 'إغلاق';

  @override
  String get actionRetry => 'إعادة المحاولة';

  @override
  String get actionSkip => 'تخطي';

  @override
  String get actionConfirm => 'تأكيد';

  @override
  String get actionAdd => 'إضافة';

  @override
  String get actionEdit => 'تعديل';

  @override
  String get actionRename => 'إعادة التسمية';

  @override
  String get actionHide => 'إخفاء';

  @override
  String get actionCreate => 'إنشاء';

  @override
  String get actionCloseApp => 'إغلاق التطبيق';

  @override
  String get actionUnlock => 'فتح';

  @override
  String get actionSettle => 'تسوية';

  @override
  String get actionFinish => 'إنهاء';

  @override
  String get actionPreview => 'معاينة';

  @override
  String get actionImport => 'استيراد';

  @override
  String get actionExportCsv => 'تصدير CSV';

  @override
  String get actionChooseFile => 'اختيار ملف';

  @override
  String get actionRestore => 'استعادة';

  @override
  String get actionFix => 'تصحيح';

  @override
  String get actionBuy => 'شراء';

  @override
  String get actionSell => 'بيع';

  @override
  String get actionDividend => 'توزيعات أرباح';

  @override
  String get actionRecordBuy => 'تسجيل شراء';

  @override
  String get actionRecordSell => 'تسجيل بيع';

  @override
  String get actionRecordDividend => 'تسجيل توزيعات أرباح';

  @override
  String get actionPayCard => 'سداد البطاقة';

  @override
  String get actionTransfer => 'تحويل';

  @override
  String get actionRecordTransaction => 'تسجيل معاملة';

  @override
  String get actionImportStatement => 'استيراد كشف حساب';

  @override
  String get actionClearDates => 'مسح التواريخ';

  @override
  String get actionClearSearch => 'مسح البحث والمرشحات';

  @override
  String get actionUseBiometrics => 'استخدام القياسات الحيوية';

  @override
  String get actionSetPin => 'تعيين الرمز';

  @override
  String get actionChangePin => 'تغيير الرمز';

  @override
  String get actionSaveBackup => 'حفظ النسخة الاحتياطية';

  @override
  String get actionRestoreBackup => 'استعادة النسخة الاحتياطية';

  @override
  String get actionSaveRule => 'حفظ القاعدة';

  @override
  String get actionConfirmFix => 'تأكيد التصحيح';

  @override
  String get captureSpent => 'صرف';

  @override
  String get captureReceived => 'وارد';

  @override
  String get captureMovedMoney => 'نقل أموال';

  @override
  String get captureImportStatement => 'استيراد كشف حساب';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsLanguageSystem => 'لغة الجهاز';

  @override
  String get settingsFetchFxRates => 'جلب أسعار الصرف المرجعية';

  @override
  String get settingsFetchFxRatesSubtitle =>
      'يعرض سعر السوق الاسترشادي بجانب المبلغ الوجهة في التحويلات بين العملات، للمقارنة فقط - لا يُستخدم أبداً لملء المبلغ.';

  @override
  String get settingsRateProvider => 'مزود سعر الصرف';

  @override
  String get settingsFetchMarketPrices => 'جلب أسعار السوق للاستثمارات';

  @override
  String get settingsFetchMarketPricesSubtitle =>
      'يبحث عن آخر الأسعار للأدوات المالية التي لها رمز تداول أو رقم ISIN، لتقدير قيمة المحفظة. لا يُستخدم أبداً لتسجيل صفقة، ولا يرسل عدد الوحدات التي تملكها.';

  @override
  String get settingsMarketPriceProvider => 'مزود أسعار السوق';

  @override
  String get settingsFavouriteResearchTool => 'أداة البحث المفضلة';

  @override
  String get settingsFavouriteResearchToolSubtitle =>
      'النقر على اسم أداة مالية في المقتنيات يفتح هذه الأداة في المتصفح مع سؤال بحثي — وهذا ليس تكاملاً، وليس نصيحة استثمارية.';

  @override
  String get settingsBackup => 'النسخ الاحتياطي';

  @override
  String get settingsBackupBlurb =>
      'احفظ نسخة مشفرة من دفاترك في مكان تختاره، أو استعد نسخة من مكان محفوظ. هذا منفصل عن عبارة الاسترداد أو ملف مخزن المفاتيح، اللذين يحفظان مفتاح التوقيع الخاص بك، وليس دفاترك.';

  @override
  String get settingsLock => 'القفل';

  @override
  String get settingsLockBlurb =>
      'يتطلب رمزاً سرياً، أو القياسات الحيوية إن توفرت، لفتح التطبيق.';

  @override
  String get settingsRequireUnlock => 'طلب فتح القفل عند فتح التطبيق';

  @override
  String get settingsLockAfter => 'القفل بعد';

  @override
  String get settingsLockImmediately => 'فوراً';

  @override
  String get settingsLock1Minute => 'دقيقة واحدة';

  @override
  String get settingsLock5Minutes => '5 دقائق';

  @override
  String get settingsLock15Minutes => '15 دقيقة';

  @override
  String get settingsAllowBiometrics => 'السماح بالقياسات الحيوية أيضاً';

  @override
  String get settingsHideSnapshot => 'إخفاء الأرصدة في مبدل التطبيقات';

  @override
  String get settingsHideSnapshotSubtitle =>
      'يُخفي هذه الشاشة عند التبديل إلى تطبيق آخر، بحيث لا تكون مرئية للوهلة الأولى في مبدل التطبيقات.';

  @override
  String get settingsHideSnapshotUnavailable =>
      'إخفاء الأرصدة في مبدل التطبيقات غير متاح على هذه المنصة.';

  @override
  String get settingsPayees => 'المستفيدون';

  @override
  String get settingsManagePayees => 'إدارة المستفيدين';

  @override
  String get settingsPayeesBlurb =>
      'أسماء المستفيدين المحفوظة مع الفئة والحساب الافتراضيين لكل منهم، تُقترح تلقائياً عند تسجيل معاملة.';

  @override
  String get settingsRecurring => 'القوالب المتكررة';

  @override
  String get settingsManageRecurring => 'إدارة القوالب المتكررة';

  @override
  String get settingsRecurringBlurb =>
      'فواتير أو دخل يتكرر شهرياً، مثل الإيجار أو الراتب. يظهر القالب المستحق في الرئيسية لتسجيله بلمسة واحدة - لا يُرحّل تلقائياً أبداً.';

  @override
  String get settingsAbout => 'حول';

  @override
  String get providerFrankfurter =>
      'Frankfurter (أسعار البنك المركزي الأوروبي)';

  @override
  String get providerOpenErApi => 'ExchangeRate-API (open.er-api.com)';

  @override
  String get providerStooq => 'Stooq (أسعار يومية)';

  @override
  String get providerYahooFinance => 'Yahoo Finance (واجهة الرسوم البيانية)';

  @override
  String get researchChatGpt => 'ChatGPT';

  @override
  String get researchClaude => 'Claude';

  @override
  String get researchGemini => 'Gemini';

  @override
  String get researchMetaAi => 'Meta AI';

  @override
  String get systemGroupCashEquivalents => 'النقد وما في حكمه';

  @override
  String get systemGroupPensionRetirement => 'التقاعد والمعاش';

  @override
  String get systemGroupCreditShortTerm => 'الائتمان والديون قصيرة الأجل';

  @override
  String get systemGroupLoansMortgages => 'القروض والرهون العقارية';

  @override
  String get systemGroupInvestments => 'الاستثمارات';

  @override
  String get systemAccountCashBank => 'النقد والبنك';

  @override
  String get systemCategorySalary => 'الراتب';

  @override
  String get systemCategoryOtherIncome => 'دخل آخر';

  @override
  String get systemCategoryGroceries => 'البقالة';

  @override
  String get systemCategoryRentMortgage => 'الإيجار/الرهن العقاري';

  @override
  String get systemCategoryUtilities => 'المرافق';

  @override
  String get systemCategoryTransport => 'النقل';

  @override
  String get systemCategoryFoodOut => 'الطعام بالخارج';

  @override
  String get systemCategoryPhone => 'الهاتف';

  @override
  String get systemCategoryHealth => 'الصحة';

  @override
  String get systemCategoryOtherExpense => 'مصروف آخر';

  @override
  String get homeThisMonth => 'هذا الشهر';

  @override
  String get homeMoneyInTransit => 'أموال قيد التحويل';

  @override
  String get homeWhatYouHaveMinusWhatYouOwe => 'ما تملكه ناقص ما عليك';

  @override
  String homeWhatYouHave(String amount, String currency) {
    return 'ما تملكه $amount $currency';
  }

  @override
  String homeNetPosition(String amount, String currency) {
    return '$amount $currency';
  }

  @override
  String homeHaveAndOwe(String haveAmount, String currency, String oweAmount) {
    return 'ما تملكه $haveAmount $currency  •  ما عليك $oweAmount $currency';
  }

  @override
  String youSentFrom(String amount, String currency, String name) {
    return 'أرسلت $amount $currency من $name';
  }

  @override
  String youSentTo(String amount, String currency, String name) {
    return 'أرسلت $amount $currency إلى $name';
  }

  @override
  String get hiddenLabel => 'مخفي';

  @override
  String get allAccounts => 'جميع الحسابات';

  @override
  String savedToPath(String path) {
    return 'تم الحفظ في $path';
  }

  @override
  String get keystoreExportFailed =>
      'تعذر تصدير ملف مخزن المفاتيح. يمكنك تخطي هذه الخطوة.';

  @override
  String get enterPassphraseToProtect => 'أدخل عبارة مرور لحماية الملف.';

  @override
  String get homeTapWhenArrived => 'اضغط عندما تعرف ما وصل';

  @override
  String homeReturnedTo(String name) {
    return 'أُعيد إلى $name';
  }

  @override
  String get homeDueToday => 'مستحق اليوم';

  @override
  String homeDueLine(String category, String account) {
    return '$category · $account · اضغط للتسجيل';
  }

  @override
  String get homeOverLimit => 'تجاوز الحد';

  @override
  String homeSpentOfLimit(String spent, String limit) {
    return '$spent من $limit';
  }

  @override
  String homeRemaining(String amount) {
    return 'المتبقي: $amount';
  }

  @override
  String get homeNoAccounts => 'لا توجد حسابات';

  @override
  String get homeCashRegister => 'صندوق النقدية';

  @override
  String get homeMarketEstimate => 'تقدير السوق';

  @override
  String get registerTitle => 'السجل';

  @override
  String get registerSearchHint => 'الوصف أو الفئة أو المبلغ';

  @override
  String get registerNoTransactions => 'لا توجد معاملات بعد';

  @override
  String get registerNoEntries => 'لا توجد قيود مسجلة بعد.';

  @override
  String get registerSpentOnly => 'الصادر فقط';

  @override
  String get registerReceivedOnly => 'الوارد فقط';

  @override
  String get registerAll => 'الكل';

  @override
  String get registerUnverified => 'غير موثّق - مستبعد من الإجماليات';

  @override
  String get registerSuperseded => 'استُبدل بالترحيل - مستبعد من الإجماليات';

  @override
  String get summaryTitle => 'الملخص';

  @override
  String get summaryTotalIncome => 'إجمالي الدخل';

  @override
  String get summaryTotalExpense => 'إجمالي المصروفات';

  @override
  String summaryDateRange(String start, String end) {
    return 'من $start إلى $end';
  }

  @override
  String get accountsTitle => 'الحسابات';

  @override
  String get categoriesTitle => 'التصنيفات';

  @override
  String get accountName => 'اسم الحساب';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get createGroup => 'إنشاء مجموعة';

  @override
  String get editGroup => 'تعديل المجموعة';

  @override
  String get renameAccount => 'إعادة تسمية الحساب';

  @override
  String get renameCategory => 'إعادة تسمية الفئة';

  @override
  String get addCategory => 'إضافة فئة';

  @override
  String get groupLabel => 'المجموعة';

  @override
  String get kindLabel => 'النوع';

  @override
  String get asset => 'أصل';

  @override
  String get liability => 'التزام';

  @override
  String get income => 'دخل';

  @override
  String get expense => 'مصروف';

  @override
  String get thisAccountHoldsInvestments => 'هذا الحساب يحتفظ باستثمارات';

  @override
  String get thisAccountHoldsInvestmentsSubtitle =>
      'نقد بالإضافة إلى مخزون تسجله بعمليات الشراء والبيع والتوزيعات.';

  @override
  String get thisIsACreditCard => 'هذه بطاقة ائتمان';

  @override
  String get openingBalanceOptional => 'الرصيد الافتتاحي (اختياري)';

  @override
  String get currencyIso => 'العملة (ISO 4217)';

  @override
  String get currencyIsoExample => 'العملة (ISO 4217، مثل USD)';

  @override
  String get hideAccountTitle => 'إخفاء الحساب من القيود الجديدة؟';

  @override
  String get hideCategoryTitle => 'إخفاء الفئة من القيود الجديدة؟';

  @override
  String get hideGroupTitle => 'إخفاء المجموعة من القيود الجديدة؟';

  @override
  String get reassignGroup => 'إعادة تعيين المجموعة';

  @override
  String get transferRemainingBalance => 'تحويل الرصيد المتبقي';

  @override
  String get monthlyLimit => 'الحد الشهري';

  @override
  String get monthlyLimitHint => 'الحد (اتركه فارغاً لمسحه)';

  @override
  String get monthlyLimitBlurb =>
      'دليل إنفاق اختياري لهذا الشهر حتى تاريخه لهذه الفئة من المصروفات.';

  @override
  String get manageCategoryRules => 'إدارة قواعد الفئات';

  @override
  String get amount => 'المبلغ';

  @override
  String get category => 'الفئة';

  @override
  String get account => 'الحساب';

  @override
  String get fromAccount => 'من حساب';

  @override
  String get toAccount => 'إلى حساب';

  @override
  String get descriptionOptional => 'الوصف (اختياري)';

  @override
  String get alsoRememberPayee => 'تذكّره أيضاً كمستفيد';

  @override
  String get splitIntoCategories => 'تقسيم إلى عدة فئات';

  @override
  String categoryN(String n) {
    return 'الفئة $n';
  }

  @override
  String get destinationAmount => 'مبلغ الوجهة';

  @override
  String get destinationAmountOptional => 'مبلغ الوجهة (اختياري)';

  @override
  String get accountCurrencyAmountOptional => 'المبلغ بعملة الحساب (اختياري)';

  @override
  String get transactionCurrencyOptional => 'عملة المعاملة (اختياري)';

  @override
  String get feeOptional => 'الرسوم (اختياري)';

  @override
  String get feeAmount => 'مبلغ الرسوم';

  @override
  String get feeCategory => 'فئة الرسوم';

  @override
  String get feeDescriptionOptional => 'وصف الرسوم (اختياري)';

  @override
  String get feeDeducted => 'تُخصم الرسوم من المبلغ أعلاه';

  @override
  String get needTwoAccountsToTransfer =>
      'أنشئ حسابين نشطين على الأقل لإجراء تحويل.';

  @override
  String get whatArrivedTitle => 'ماذا وصل؟';

  @override
  String get whatArrivedBlurb => 'أخبرنا بما وصل فعلياً.';

  @override
  String get amountThatArrived => 'المبلغ الذي وصل';

  @override
  String get feeLossCategory => 'فئة الرسوم / الخسارة';

  @override
  String get alreadySettled => 'تمت التسوية بالفعل.';

  @override
  String get holdingsTitle => 'المقتنيات';

  @override
  String get holdingsCash => 'النقد';

  @override
  String get holdingsInventory => 'المخزون';

  @override
  String holdingsBook(String amount, String currency) {
    return 'القيمة الدفترية (نقد + تكلفة) $amount $currency';
  }

  @override
  String holdingsMarketEstimate(String amount, String currency) {
    return 'تقدير السوق $amount $currency';
  }

  @override
  String get holdingsNoHoldings =>
      'لا توجد مقتنيات بعد. سجّل عملية شراء لإضافة أداة مالية.';

  @override
  String get holdingsQuotesBlurb =>
      'الأسعار المعروضة تقديرية، وليست سعر الوسيط. هذا التطبيق لا ينفذ أوامر تداول.';

  @override
  String get holdingsTapNameToResearch =>
      'اضغط على الاسم للبحث. الأسعار تقديرية، وليست نصيحة استثمارية.';

  @override
  String get instrument => 'أداة مالية';

  @override
  String get newInstrument => 'أداة مالية جديدة';

  @override
  String get renameInstrument => 'إعادة تسمية الأداة المالية';

  @override
  String get instrumentActions => 'إجراءات الأداة المالية';

  @override
  String hideInstrumentTitle(String name) {
    return 'إخفاء $name؟';
  }

  @override
  String get tickerOptional => 'رمز التداول (اختياري)';

  @override
  String get isinOptional => 'ISIN (اختياري)';

  @override
  String get quantity => 'الكمية';

  @override
  String get unitPrice => 'سعر الوحدة';

  @override
  String get brokerageOptional => 'عمولة الوساطة (اختياري)';

  @override
  String get brokerageExpenseCategory => 'فئة مصروف الوساطة';

  @override
  String get incomeCategory => 'فئة الدخل';

  @override
  String get gainIncomeCategory => 'فئة دخل الأرباح';

  @override
  String get lossExpenseCategory => 'فئة مصروف الخسائر';

  @override
  String get nonCash => 'غير نقدي';

  @override
  String get cash => 'نقد';

  @override
  String get locked => 'مقفل';

  @override
  String get lockUntilHint =>
      'ملاحظتك الخاصة بشأن قيد ما، وليست قاعدة من الوسيط.';

  @override
  String get instrumentKindStock => 'سهم';

  @override
  String get instrumentKindEtf => 'صندوق مؤشرات متداول (ETF)';

  @override
  String get instrumentKindMutualFund => 'صندوق استثمار مشترك';

  @override
  String get instrumentKindBond => 'سند';

  @override
  String get instrumentKindOther => 'أخرى';

  @override
  String get quoteUseLive => 'سعر مباشر';

  @override
  String get quoteUseCached => 'سعر مخزّن مؤقتاً';

  @override
  String get quoteUseStale => 'سعر قديم';

  @override
  String get quoteUseMissing => 'استخدام التكلفة (لا يوجد سعر)';

  @override
  String get quoteUseDisabled =>
      'الأسعار معطلة — استخدام التكلفة/المخزن المؤقت';

  @override
  String get quoteUseCurrencyMismatch => 'استخدام التكلفة (عملة السعر مختلفة)';

  @override
  String unrealizedLabel(String amount, String currency) {
    return 'غير محقق $amount $currency';
  }

  @override
  String holdingsUnitsCost(String qty) {
    return '$qty وحدة · ';
  }

  @override
  String get recoveryPhraseTitle => 'عبارة الاسترداد الخاصة بك';

  @override
  String get recoveryPhraseConfirmTitle => 'أكّد عبارتك';

  @override
  String get recoveryPhraseBlurb =>
      'هذه الكلمات الـ24 هي الطريقة الوحيدة لاسترداد سجل معاملاتك في حال فقدان هذا الجهاز أو إعادة ضبطه أو استبداله. سمارا للحسابات لا تملك خادماً ولا يمكنها استرداد هذه الكلمات نيابة عنك.\n\nإذا فقدت هذا الجهاز وهذه العبارة معاً، تصبح كل معاملة سجّلتها غير قابلة للتحقق بشكل دائم.';

  @override
  String get recoveryPhraseWriteDown =>
      'دوّن هذه الكلمات بالترتيب واحفظها في مكان آمن ومنفصل عن هذا الجهاز.';

  @override
  String get iveSavedRecoveryPhrase => 'لقد حفظت عبارة الاسترداد الخاصة بي';

  @override
  String get confirmPhraseBlurb =>
      'أدخل الكلمات المطلوبة من العبارة التي حفظتها للتو.';

  @override
  String wordNumber(String n) {
    return 'الكلمة رقم $n';
  }

  @override
  String get keystoreExportTitle => 'تصدير ملف مخزن المفاتيح';

  @override
  String get keystoreExportBlurb =>
      'بالإضافة إلى عبارة الاسترداد، يمكنك حفظ ملف مخزن مفاتيح مشفر محمي بعبارة مرور تختارها. هذا اختياري - عبارة الاسترداد وحدها كافية دائماً لاستعادة مفتاح التوقيع الخاص بك.';

  @override
  String get keystorePassphrase => 'عبارة المرور';

  @override
  String get exportKeystoreFile => 'تصدير ملف مخزن المفاتيح';

  @override
  String get chooseCurrencyTitle => 'اختر عملتك';

  @override
  String get chooseCurrencyBlurb =>
      'كل مجموعة حسابات (النقد وما في حكمه، التقاعد والمعاش، إلخ) تستخدم هذه العملة الواحدة حالياً. يمكنك لاحقاً إضافة حسابات بعملة مختلفة عبر إنشاء مجموعة جديدة لها.';

  @override
  String get currencyBackfillTitle => 'اختر عملة للمجموعات الحالية';

  @override
  String get currencyBackfillBlurb =>
      'يدعم هذا التطبيق الآن عملات متعددة. تحتاج حساباتك ومجموعات حساباتك الحالية إلى عملة - وبما أنها جميعاً أُنشئت قبل وجود هذه الميزة، ينطبق اختيار واحد عليها كلها.';

  @override
  String get firstAccountTitle => 'سمِّ حسابك';

  @override
  String get firstAccountBlurb =>
      'هذا هو الحساب المُعدّ لك مسبقاً - أعطه اسماً تتعرف عليه، مثل اسم بنكك. ستُسجّل عملية صرف أو استلام واحدة تالياً، ثم تحمي الجهاز بعبارة الاسترداد الخاصة بك.';

  @override
  String get whatsMainAccountCalled => 'ما اسم حسابك الرئيسي؟';

  @override
  String get restoreTitle => 'استعادة مفتاح التوقيع';

  @override
  String get restoreBlurb =>
      'يحتوي هذا الجهاز على دفاتر موجودة، لكن بلا مفتاح توقيع مطابق. استعده من عبارة الاسترداد أو ملف مخزن المفاتيح المحفوظين لديك - ستتحقق بياناتك بشكل طبيعي، ولن يُعاد توقيع أو تعديل أي شيء.';

  @override
  String get recoveryPhrase24 => 'عبارة الاسترداد (الكلمات الـ24 كاملة)';

  @override
  String get keystoreFile => 'ملف مخزن المفاتيح';

  @override
  String get keystoreFileContents => 'محتويات ملف مخزن المفاتيح';

  @override
  String get optionalBackupFile => 'ملف نسخة احتياطية اختياري';

  @override
  String get iDontHavePhrase => 'ليس لدي عبارة الاسترداد أو ملف مخزن المفاتيح';

  @override
  String get migrationTitle => 'الترحيل إلى مفتاح جديد';

  @override
  String get migrationBlurb =>
      'بدون عبارة الاسترداد أو ملف مخزن المفاتيح، لا يمكن استعادة مفتاح التوقيع الخاص بهذا الجهاز. يمكنك بدء مفتاح جديد. تبقى القيود القديمة مرئية لكن تصبح مُستبدلة.';

  @override
  String get iConfirmBooksValid => 'أؤكد أن الدفاتر الحالية صحيحة';

  @override
  String get whyWeDontEdit => 'لماذا لا نُعدّل القيود القديمة';

  @override
  String get whyWeDontEditBody =>
      'عندما تصحح خطأً، نُبقي على السطر القديم ونضيف تصحيحاً بجانبه بدلاً من تغيير ما أدخلته بالفعل. بهذه الطريقة يُظهر سجلك دائماً بالضبط ما حدث ومتى صححته — لا شيء يتغير خفية من ورائك.';

  @override
  String get lockTitle => 'فتح القفل';

  @override
  String get lockScreenTitle => 'مقفل';

  @override
  String get enterPinToContinue => 'أدخل الرمز للمتابعة';

  @override
  String get pinLabel => 'الرمز';

  @override
  String get setPinTitle => 'تعيين رمز';

  @override
  String get currentPin => 'الرمز الحالي';

  @override
  String get newPin => 'الرمز الجديد';

  @override
  String get confirmPin => 'تأكيد الرمز';

  @override
  String get confirmNewPin => 'تأكيد الرمز الجديد';

  @override
  String get firstWeekTitle => 'أعدّ حساباتك';

  @override
  String get addCashAccount => 'إضافة حساب نقدي';

  @override
  String get addCreditCard => 'إضافة بطاقة ائتمان';

  @override
  String get cashAccountName => 'اسم الحساب النقدي';

  @override
  String get cardName => 'اسم البطاقة';

  @override
  String get paidFromBank => 'مدفوع من البنك';

  @override
  String get paidFromCard => 'مدفوع من البطاقة';

  @override
  String get choosePassphraseTitle =>
      'اختر عبارة مرور لحماية هذه النسخة الاحتياطية. لا يمكن الاسترداد إن نسيتها.';

  @override
  String get replaceBooksTitle => 'استبدال دفاترك المحلية؟';

  @override
  String get replaceBooksBody =>
      'هذا يستبدل كل ما هو موجود حالياً في هذا التطبيق بالنسخة الاحتياطية. أغلق التطبيق وأعد فتحه بعد ذلك.';

  @override
  String get chooseBackupFileFirst => 'اختر ملف نسخة احتياطية أولاً.';

  @override
  String get backupRestored => 'تم استعادة النسخة الاحتياطية';

  @override
  String get backupRestoredBody =>
      'تم استعادة دفاترك. أغلق التطبيق وأعد فتحه للمتابعة.';

  @override
  String get fixThisEntry => 'تصحيح هذا القيد';

  @override
  String get fixBlurb =>
      'يبقى السطر القديم كما هو تماماً. التأكيد يضيف سطراً عكسياً والسطر المُصحح.';

  @override
  String get importStatementTitle => 'استيراد كشف حساب';

  @override
  String get importOfx => 'استيراد OFX';

  @override
  String get importOfxQfxFile => 'استيراد ملف OFX / QFX';

  @override
  String get importCsvFile => 'استيراد ملف CSV';

  @override
  String get whatKindOfStatement => 'ما نوع ملف كشف الحساب لديك؟';

  @override
  String get chooseAccountForFile => 'اختر الحساب الذي ينتمي إليه هذا الملف.';

  @override
  String get importIntoAccount => 'الاستيراد إلى حساب';

  @override
  String get useSavedProfile => 'استخدام ملف تعريف محفوظ';

  @override
  String get saveMappingProfile => 'حفظ هذا التخطيط كملف تعريف (اختياري)';

  @override
  String get renameProfile => 'إعادة تسمية ملف التعريف';

  @override
  String get deleteProfileTitle => 'حذف ملف التعريف؟';

  @override
  String get fileHasHeader => 'الملف يحتوي على صف عناوين';

  @override
  String get dateColumn => 'عمود التاريخ';

  @override
  String get dateFormatHint => 'تنسيق التاريخ (مثل dd/MM/yyyy)';

  @override
  String get amountColumn => 'عمود المبلغ';

  @override
  String get amountConvention => 'اصطلاح المبلغ';

  @override
  String get signedAmountColumn => 'عمود المبلغ الموقّع';

  @override
  String get separateDebitCredit => 'أعمدة منفصلة للمدين / الدائن';

  @override
  String get debitColumn => 'عمود المدين';

  @override
  String get creditColumn => 'عمود الدائن';

  @override
  String get decimalSeparator => 'الفاصل العشري (. أو ,)';

  @override
  String get descriptionColumns => 'عمود (أعمدة) الوصف';

  @override
  String get referenceIdColumn => 'عمود رقم المرجع (اختياري)';

  @override
  String get skippedRows => 'الصفوف المتخطاة';

  @override
  String parsedTransactionCount(String count) {
    return 'تم تحليل $count معاملة';
  }

  @override
  String skippedOrExcludedCount(String count) {
    return 'تم تخطي أو استبعاد $count';
  }

  @override
  String postedFailedCount(String posted, String failed) {
    return 'تم ترحيل $posted، وفشل $failed';
  }

  @override
  String get categoryForAll => 'الفئة للكل';

  @override
  String get saveAsRule => 'الحفظ كقاعدة؟';

  @override
  String get saveAsRuleBlurb =>
      'عمليات الاستيراد المستقبلية التي يحتوي وصفها على هذه الكلمة المفتاحية ستستخدم هذه الفئة.';

  @override
  String get keyword => 'الكلمة المفتاحية';

  @override
  String get noSavedRules =>
      'لا توجد قواعد محفوظة بعد. عيّن فئة لمجموعة من الصفوف لحفظ قاعدة.';

  @override
  String get deleteRuleTitle => 'حذف القاعدة؟';

  @override
  String get editRule => 'تعديل القاعدة';

  @override
  String rowsGrouped(String count) {
    return '$count صف';
  }

  @override
  String selectStatementFile(String extensions) {
    return 'اختر ملف كشف حساب $extensions للاستيراد';
  }

  @override
  String get payeesTitle => 'المستفيدون';

  @override
  String get addPayee => 'إضافة مستفيد';

  @override
  String get renamePayee => 'إعادة تسمية المستفيد';

  @override
  String get deletePayeeTitle => 'حذف المستفيد؟';

  @override
  String get noPayeesYet => 'لا يوجد مستفيدون بعد';

  @override
  String get recurringTitle => 'القوالب المتكررة';

  @override
  String get noRecurringYet => 'لا توجد قوالب متكررة بعد';

  @override
  String get deleteTemplateTitle => 'حذف القالب المتكرر؟';

  @override
  String get dayOfMonth => 'يوم الشهر (1-31)';

  @override
  String get dayOfMonthNote => 'الشهر ذو الأيام الأقل يستخدم آخر يوم فيه.';

  @override
  String dayOfMonthLine(String day) {
    return 'اليوم $day من الشهر - ';
  }

  @override
  String get name => 'الاسم';

  @override
  String get none => 'لا شيء';

  @override
  String get currency => 'العملة';

  @override
  String get errorGeneric => 'حدث خطأ. حاول مرة أخرى.';

  @override
  String get errorSigningIdentityMismatch =>
      'عبارة الاسترداد أو ملف مخزن المفاتيح هذا لا يطابق أي هوية توقيع في قاعدة البيانات هذه.';

  @override
  String get errorInvalidLedgerBackup =>
      'هذا الملف ليس نسخة احتياطية صالحة من سمارا.';

  @override
  String get errorInvalidLedgerBackupNoIdentity =>
      'هذه النسخة الاحتياطية بلا هوية توقيع - وهي ليست نسخة احتياطية صالحة من سمارا.';

  @override
  String get errorInvalidLedgerBackupUnverified =>
      'لم يتم التحقق من هذه النسخة الاحتياطية كدفاتر سليمة، لذا لم تُستعد.';

  @override
  String errorInvalidLedgerBackupUnreadable(String detail) {
    return 'تعذر فتح هذا الملف كنسخة احتياطية من سمارا: $detail';
  }

  @override
  String get errorForeignBackupIdentity =>
      'تنتمي هذه النسخة الاحتياطية إلى هوية توقيع مختلفة عن الموجودة على هذا الجهاز.';

  @override
  String get errorAccountNotFinancial => 'هذا ليس حساباً مالياً.';

  @override
  String get errorAccountArchived => 'هذا الحساب مخفي.';

  @override
  String get errorAccountNotArchived => 'هذا الحساب غير مخفي.';

  @override
  String get errorAccountNoPositiveBalanceToCloseOut =>
      'لا يوجد رصيد متبقٍ للتحويل.';

  @override
  String get errorAccountHasNoGroup => 'لا توجد مجموعة معيّنة لهذا الحساب.';

  @override
  String get errorGroupHasNoCurrency => 'لم يتم تعيين عملة لهذه المجموعة بعد.';

  @override
  String get errorGroupNotFound => 'لم يتم العثور على مجموعة الحسابات هذه.';

  @override
  String get errorInvestmentAccountsMustBeAssets =>
      'يمكن فقط تعيين حسابات الأصول كحسابات استثمارية.';

  @override
  String get errorCreditCardsMustBeLiabilities =>
      'يمكن فقط تعيين حسابات الالتزامات كبطاقات ائتمان.';

  @override
  String get errorOpeningBalanceMustBePositive =>
      'يجب أن يكون الرصيد الافتتاحي موجباً عند تقديمه.';

  @override
  String get errorAccountTypeDoesNotMatchGroup =>
      'نوع هذا الحساب لا يطابق المجموعة.';

  @override
  String get errorLastActiveAccount => 'لا يمكن إخفاء آخر حساب مالي نشط.';

  @override
  String get errorCurrencyRequiredToCreateGroup =>
      'العملة مطلوبة لإنشاء مجموعة.';

  @override
  String get errorSystemGroupCannotBeArchived =>
      'لا يمكن إخفاء مجموعات الحسابات المدمجة.';

  @override
  String get errorGroupAlreadyArchived => 'هذه المجموعة مخفية بالفعل.';

  @override
  String get errorCannotArchiveGroupWithAccounts =>
      'لا يمكن إخفاء مجموعة لا تزال تحتوي على حسابات نشطة.';

  @override
  String get errorSystemGroupNeverArchived =>
      'مجموعات الحسابات المدمجة لا تُخفى أبداً.';

  @override
  String get errorAccountGroupsCannotBeDeleted =>
      'لا يمكن حذف مجموعات الحسابات.';

  @override
  String get errorCannotReassignDifferentCurrency =>
      'لا يمكن نقل هذا الحساب إلى مجموعة بعملة مختلفة.';

  @override
  String get errorCannotChangeGroupCurrencyWithAccounts =>
      'لا يمكن تغيير عملة المجموعة أثناء وجود حسابات نشطة فيها.';

  @override
  String get errorAmountMustBePositive => 'يجب أن يكون المبلغ موجباً.';

  @override
  String get errorAccountCurrencyAmountMustBePositive =>
      'يجب أن يكون المبلغ بعملة الحساب موجباً.';

  @override
  String get errorAccountCurrencyAmountNotForSameCurrency =>
      'المبلغ بعملة الحساب مخصص فقط لقيد بعملة أجنبية.';

  @override
  String get errorSplitNeedsTwoLines =>
      'يحتاج التقسيم إلى سطرَي فئة على الأقل.';

  @override
  String get errorSplitLineMustBePositive =>
      'يجب أن يكون كل سطر تقسيم مبلغاً موجباً.';

  @override
  String get errorSplitLinesMustSumToTotal =>
      'يجب أن يتساوى مجموع أسطر التقسيم مع إجمالي المعاملة.';

  @override
  String get errorTransferAmountMustBePositive =>
      'يجب أن يكون مبلغ التحويل موجباً.';

  @override
  String get errorTransferAccountsMustDiffer =>
      'يجب أن يختلف حساب المصدر عن حساب الوجهة.';

  @override
  String get errorCloseoutRequiresDestinationAmount =>
      'تحتاج التسوية النهائية بين عملتين إلى مبلغ وجهة معروف.';

  @override
  String get errorDestinationAmountNotForSameCurrency =>
      'مبلغ الوجهة مخصص فقط لتحويل بين عملتين.';

  @override
  String get errorDestinationAmountMustBePositive =>
      'يجب أن يكون مبلغ الوجهة موجباً.';

  @override
  String get errorInvestmentCashExceeded =>
      'لا يمكن تحويل أكثر من نقد هذا الحساب الاستثماري.';

  @override
  String get errorCannotReverseUnsettledProvisional =>
      'سوِّ هذا التحويل المعلق بدلاً من عكسه.';

  @override
  String get errorAlreadyReversed =>
      'تم تصحيح هذا القيد بالفعل. يبقى السطر الأصلي كما هو.';

  @override
  String get errorNotActiveExpenseCategory => 'اختر فئة مصروفات نشطة.';

  @override
  String get errorNotActiveIncomeCategory => 'اختر فئة دخل نشطة.';

  @override
  String get errorSettledAmountMustNotBeNegative =>
      'لا يمكن أن يكون المبلغ الذي وصل سالباً.';

  @override
  String get errorPendingTransferNotFound =>
      'لم يتم العثور على التحويل المعلق هذا.';

  @override
  String get errorPendingTransferAlreadySettled =>
      'تمت تسوية هذا التحويل المعلق بالفعل.';

  @override
  String get errorSettledToMustBeSourceOrDestination =>
      'اختر حساب المصدر أو الوجهة الأصلي.';

  @override
  String get errorFeeCategoryOnlyWhenReturningToSource =>
      'تُستخدم فئة الرسوم فقط عند إعادة الأموال إلى حساب المصدر.';

  @override
  String get errorSettledAmountMustBePositiveForDelivery =>
      'أدخل مبلغاً موجباً لما وصل.';

  @override
  String get errorSettledAmountExceedsProvisional =>
      'هذا المبلغ أكبر مما أُرسل.';

  @override
  String get errorInstrumentNotFound => 'لم يتم العثور على هذه الأداة المالية.';

  @override
  String get errorIncomeRequiredForNonCash =>
      'مطلوب فئة دخل نشطة لعملية اقتناء غير نقدية.';

  @override
  String get errorInsufficientCash =>
      'لا يوجد نقد كافٍ في هذا الحساب الاستثماري لعملية الشراء تلك.';

  @override
  String get errorSellQuantityAndPriceMustBePositive =>
      'يجب أن تكون كمية البيع وسعر الوحدة موجبين.';

  @override
  String errorLockedUntil(String date) {
    return 'لا يمكن البيع: بعض الوحدات مقفلة حتى $date.';
  }

  @override
  String get errorInsufficientQuantity =>
      'لا يمكن بيع أكثر مما تملكه حالياً غير مقفل.';

  @override
  String get errorIncomeRequiredForGain => 'مطلوب فئة دخل نشطة للربح المحقق.';

  @override
  String get errorExpenseRequiredForLoss =>
      'مطلوب فئة مصروفات نشطة للخسارة المحققة.';

  @override
  String errorBrokerageFailedAfterBuy(String detail) {
    return 'تم ترحيل الشراء، لكن فشلت رسوم الوساطة: $detail';
  }

  @override
  String errorBrokerageFailedAfterSell(String detail) {
    return 'تم ترحيل البيع، لكن فشلت رسوم الوساطة: $detail';
  }

  @override
  String get errorDividendMustBePositive =>
      'يجب أن يكون مبلغ التوزيعات موجباً.';

  @override
  String get errorNotInvestmentAccount => 'هذا ليس حساباً استثمارياً.';

  @override
  String get errorNoInventoryCompanion =>
      'يفتقد هذا الحساب الاستثماري إلى حساب المخزون المرافق.';

  @override
  String errorInvestmentReversalBlocked(String sells) {
    return 'لا يمكن عكس عملية الشراء هذه: عمليات بيع لاحقة تعتمد على وحداتها. اعكس عمليات البيع المعتمدة أولاً: $sells.';
  }

  @override
  String get errorMonthlyLimitMustBePositive =>
      'يجب أن يكون الحد الشهري موجباً.';

  @override
  String get errorTemplateAmountMustBePositive =>
      'يجب أن يكون مبلغ القالب موجباً.';

  @override
  String get errorOfxUnrecognized => 'تعذر التعرف على هذا الملف كملف OFX.';

  @override
  String get errorCsvEmpty => 'الملف المحدد فارغ.';

  @override
  String get errorCsvUnreadable => 'تعذر قراءة هذا الملف كملف CSV.';

  @override
  String get errorCsvNoRows => 'الملف المحدد لا يحتوي على صفوف.';

  @override
  String errorBackupCreateFailed(String detail) {
    return 'تعذر إنشاء النسخة الاحتياطية: $detail';
  }

  @override
  String get errorBackupRestoreFailed =>
      'تعذر استعادة هذه النسخة الاحتياطية - عبارة مرور خاطئة، أو ليست ملف نسخة احتياطية من سمارا.';

  @override
  String get validationAmountAccountCategoryRequired =>
      'المبلغ والحساب والفئة مطلوبة.';

  @override
  String get validationAmountAccountRequired => 'المبلغ والحساب مطلوبان.';

  @override
  String get validationSplitLineIncomplete =>
      'كل سطر تقسيم يحتاج إلى فئة ومبلغ.';

  @override
  String get validationSplitSumMismatch =>
      'يجب أن يتساوى مجموع أسطر التقسيم مع إجمالي المعاملة.';

  @override
  String get validationFromToAmountRequired =>
      'حساب المصدر وحساب الوجهة والمبلغ مطلوبة.';

  @override
  String get validationAmountArrivedRequired => 'المبلغ الذي وصل مطلوب.';

  @override
  String get validationChooseReceivingAccount =>
      'اختر الحساب الذي استلم الأموال.';

  @override
  String get validationAccountCategoryRequired => 'الحساب والفئة مطلوبان.';

  @override
  String get validationFixFailed => 'تعذر حفظ هذا التصحيح.';

  @override
  String get validationNameRequired => 'سمِّ حسابك الرئيسي.';

  @override
  String get validationStillLoading =>
      'لا يزال التحميل جارياً - حاول مرة أخرى بعد قليل.';

  @override
  String get validationSaveAccountNameFailed => 'تعذر حفظ اسم الحساب.';

  @override
  String get validationWrongPin => 'رمز خاطئ. حاول مرة أخرى.';

  @override
  String get validationCategoryMustBeIncomeOrExpense =>
      'يجب أن تكون الفئة دخلاً أو مصروفاً.';

  @override
  String get validationOnlyExpenseHasMonthlyLimit =>
      'يمكن فقط لفئة المصروفات أن يكون لها حد شهري.';

  @override
  String get validationInvalidTemplate => 'قالب غير صالح.';

  @override
  String get validationWrongKeystorePassphrase =>
      'عبارة مرور خاطئة لملف مخزن المفاتيح هذا.';

  @override
  String get validationInvalidKeystoreFile =>
      'هذا لا يبدو كملف مخزن مفاتيح صالح.';

  @override
  String get validationRestorePhraseFailed =>
      'تعذر الاستعادة من عبارة الاسترداد تلك.';

  @override
  String validationGenerateKeyFailed(String detail) {
    return 'تعذر توليد مفتاح توقيع على هذا الجهاز: $detail';
  }

  @override
  String validationSaveCurrencyFailed(String detail) {
    return 'تعذر حفظ هذه العملة: $detail';
  }

  @override
  String get validationMigrationFailed => 'فشل الترحيل. حاول مرة أخرى من فضلك.';

  @override
  String get validationChooseBackupFile => 'اختر ملف نسخة احتياطية أولاً.';

  @override
  String get validationPassphraseRequired => 'أدخل عبارة مرور.';

  @override
  String get validationPinsDoNotMatch => 'الرمزان غير متطابقين.';

  @override
  String get validationFeePositiveWithCategory =>
      'يجب أن تكون رسوم التحويل مبلغاً موجباً مع اختيار فئة مصروفات.';

  @override
  String get validationFeeMustBeLessThanAmount =>
      'يجب أن تكون الرسوم أقل من المبلغ لتحويل الرسوم المخصومة.';

  @override
  String validationTransferSavedFeeFailed(String detail) {
    return 'تم حفظ التحويل، لكن تعذر تسجيل الرسوم: $detail';
  }

  @override
  String get validationEnterValidAmount => 'أدخل مبلغاً صالحاً.';

  @override
  String validationConfirmWordMismatch(String n) {
    return 'الكلمة $n لا تطابق عبارتك المحفوظة. تحقق منها وحاول مرة أخرى.';
  }

  @override
  String get errorBuyQuantityAndPriceMustBePositive =>
      'يجب أن تكون كمية الشراء وسعر الوحدة موجبين.';

  @override
  String get errorInstrumentArchived => 'لا يمكن شراء أداة مالية مخفية.';

  @override
  String get errorNonCashCannotIncludeBrokerage =>
      'عمليات الاقتناء غير النقدية لا يمكن أن تتضمن عمولة وساطة.';

  @override
  String get errorBrokerageRequiresExpenseCategory =>
      'مطلوب فئة مصروفات نشطة عندما تكون عمولة الوساطة موجبة.';

  @override
  String get errorSellProceedsMustCoverBrokerage =>
      'يجب أن تغطي عائدات البيع عمولة الوساطة على الأقل.';

  @override
  String homeSpentOfLimitThisMonth(String spent, String limit) {
    return '$spent من $limit هذا الشهر';
  }

  @override
  String get unlockBiometricReason => 'فتح سمارا للحسابات';

  @override
  String get searchLabel => 'بحث';

  @override
  String get openingBalance => 'الرصيد الافتتاحي';

  @override
  String transferToName(String name) {
    return 'تحويل: $name';
  }

  @override
  String get feeForTransfer => 'رسوم التحويل';

  @override
  String feeForTransferTo(String name) {
    return 'رسوم التحويل إلى $name';
  }

  @override
  String couldNotOpenFilePicker(String detail) {
    return 'تعذر فتح منتقي الملفات: $detail';
  }

  @override
  String pleaseSelectFile(String extensions) {
    return 'يرجى اختيار ملف .$extensions';
  }

  @override
  String get currencyCodeIso => 'رمز العملة (ISO 4217، مثل USD)';

  @override
  String splitCounterpartMore(String name, String count) {
    return '$name +$count أخرى';
  }

  @override
  String get dateLabel => 'التاريخ';

  @override
  String get noneSelected => 'لا شيء';

  @override
  String reviewEntriesBeforeContinuing(String count) {
    return 'راجع القيود أدناه ($count إجمالاً) قبل المتابعة.';
  }

  @override
  String youReceived(String amount) {
    return 'استلمت $amount';
  }

  @override
  String get leaveBlankIfRateUnknown =>
      'اتركه فارغاً إذا لم يكن سعر الصرف معروفاً بعد.';

  @override
  String get recordTradeBlurb =>
      'سجّل صفقة حدثت بالفعل. هذا التطبيق لا ينفذ أوامر تداول.';

  @override
  String get feeOnTopBlurb =>
      'مضافة: المبلغ أعلاه هو الإجمالي المأخوذ من هذا الحساب؛ وتُخصم الرسوم منه.';

  @override
  String get feeBankBlurb => 'عمولة مقدّمة يفرضها بنكك أو وسيط.';

  @override
  String get validationPinMinLength =>
      'يجب أن يتكون الرمز من 4 أرقام على الأقل.';

  @override
  String get restoreBackupBlurb =>
      'هذا يستبدل كل ما هو موجود حالياً في هذا التطبيق بالنسخة الاحتياطية — ولا يدمجه. اختر ملف نسخة احتياطية وأدخل عبارة المرور التي حميته بها.';

  @override
  String get actionReplace => 'استبدال';

  @override
  String hideAccountBody(String name) {
    return '$name لن يكون متاحاً بعد الآن للمعاملات الجديدة.';
  }

  @override
  String hideGroupBody(String name) {
    return '$name لن تُعرض بعد الآن عند إنشاء أو إعادة تعيين الحسابات.';
  }

  @override
  String hideCategoryBody(String name) {
    return '$name لن تُعرض بعد الآن عند تسجيل معاملات جديدة.';
  }

  @override
  String get hideInstrumentBody =>
      'الأدوات المالية المخفية تبقى على عمليات الشراء والبيع السابقة. لا يزال بإمكانك تسجيل توزيعات أرباح لها.';

  @override
  String nameHidden(String name) {
    return '$name (مخفي)';
  }

  @override
  String get noCurrencySet => 'لم يتم تعيين عملة';

  @override
  String deletePayeeBody(String name) {
    return 'سيُحذف $name والإعدادات الافتراضية المحفوظة له. المعاملات السابقة لا تتأثر.';
  }

  @override
  String deleteTemplateBody(String name) {
    return '$name لن يُعرض بعد الآن كمستحق. المعاملات السابقة التي سجّلها بالفعل لا تتأثر.';
  }

  @override
  String deleteProfileBody(String name) {
    return 'سيُحذف تخطيط الأعمدة المحفوظ \"$name\". الكشوفات المستوردة به مسبقاً لا تتأثر.';
  }

  @override
  String deleteRuleBody(String keyword) {
    return 'عمليات الاستيراد لن تُصنّف تلقائياً بعد الآن بـ\"$keyword\". المعاملات المصنفة بالفعل باستخدام هذه القاعدة لا تتأثر.';
  }

  @override
  String get firstWeekBlurb =>
      'أضف اختيارياً بطاقة ائتمان أو حساباً نقدياً الآن - يمكنك دائماً إضافة حسابات أخرى لاحقاً من الإعدادات.';

  @override
  String get deliveredToDestination => 'تم التسليم إلى الوجهة';

  @override
  String deliveredToName(String name) {
    return 'تم التسليم إلى $name';
  }

  @override
  String youReceivedLessThanExpected(String amount, String currency) {
    return 'استلمت $amount $currency أقل من المتوقع - اختر فئة لتغطية الفرق.';
  }

  @override
  String get dateRangeLabel => 'نطاق التاريخ';

  @override
  String get addTemplate => 'إضافة قالب';

  @override
  String get editTemplate => 'تعديل القالب';

  @override
  String get validationFillTemplateFields => 'املأ كل حقل بمبلغ ويوم صالحين.';

  @override
  String get saveCsvExport => 'حفظ تصدير CSV';

  @override
  String get referenceRate => 'السعر المرجعي';

  @override
  String get yourRate => 'سعرك';

  @override
  String leaveBlankIfThisWasAccountCurrency(String currency) {
    return 'اتركه فارغاً إذا كان هذا بعملة $currency، عملة الحساب نفسه.';
  }

  @override
  String get lockUntilOptional => 'مقفل حتى (اختياري)';

  @override
  String lockedUntilDate(String date) {
    return 'مقفل حتى $date';
  }

  @override
  String get copiedResearchPrompt =>
      'تم نسخ سؤال بحثي — لا يوجد رابط متصفح متاح، أو أنك غير متصل بالإنترنت.';

  @override
  String get openedFavouriteResearchTool => 'تم فتح أداة البحث المفضلة لديك.';

  @override
  String get looksLikeGain => 'يبدو هذا ربحاً';

  @override
  String get looksLikeLoss => 'يبدو هذا خسارة';

  @override
  String get looksLikeBreakEven => 'يبدو هذا تعادلاً';

  @override
  String sellableQuantity(String name, String qty) {
    return '$name ($qty قابل للبيع)';
  }

  @override
  String columnN(String index) {
    return 'العمود $index';
  }

  @override
  String get importingLabel => 'جارٍ الاستيراد...';

  @override
  String get confirmImport => 'تأكيد الاستيراد';

  @override
  String get manageSavedCategoryRules => 'إدارة قواعد الفئات المحفوظة';

  @override
  String statementCurrencyMismatch(String currency) {
    return 'عملة هذا الملف ($currency) لا تطابق عملة الحساب المحدد.';
  }

  @override
  String get categoryRulesTitle => 'قواعد الفئات';

  @override
  String get possibleDuplicate => 'تكرار محتمل';

  @override
  String get unknownCategory => 'فئة غير معروفة';
}
