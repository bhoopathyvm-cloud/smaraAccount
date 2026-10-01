// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get appTitle => 'สมุดบัญชี Smara';

  @override
  String get navHome => 'หน้าหลัก';

  @override
  String get navRegister => 'รายการ';

  @override
  String get navSummary => 'สรุป';

  @override
  String get navAccounts => 'บัญชี';

  @override
  String get navCategories => 'หมวดหมู่';

  @override
  String get actionCancel => 'ยกเลิก';

  @override
  String get actionSave => 'บันทึก';

  @override
  String get actionDelete => 'ลบ';

  @override
  String get actionDone => 'เสร็จสิ้น';

  @override
  String get actionContinue => 'ดำเนินการต่อ';

  @override
  String get actionDismiss => 'ปิด';

  @override
  String get actionRetry => 'ลองอีกครั้ง';

  @override
  String get actionSkip => 'ข้าม';

  @override
  String get actionConfirm => 'ยืนยัน';

  @override
  String get actionAdd => 'เพิ่ม';

  @override
  String get actionEdit => 'แก้ไข';

  @override
  String get actionRename => 'เปลี่ยนชื่อ';

  @override
  String get actionHide => 'ซ่อน';

  @override
  String get actionCreate => 'สร้าง';

  @override
  String get actionCloseApp => 'ปิดแอป';

  @override
  String get actionUnlock => 'ปลดล็อก';

  @override
  String get actionSettle => 'ชำระ';

  @override
  String get actionFinish => 'สิ้นสุด';

  @override
  String get actionPreview => 'ดูตัวอย่าง';

  @override
  String get actionImport => 'นำเข้า';

  @override
  String get actionExportCsv => 'ส่งออก CSV';

  @override
  String get actionChooseFile => 'เลือกไฟล์';

  @override
  String get actionRestore => 'กู้คืน';

  @override
  String get actionFix => 'ปรับแก้';

  @override
  String get actionBuy => 'ซื้อ';

  @override
  String get actionSell => 'ขาย';

  @override
  String get actionDividend => 'เงินปันผล';

  @override
  String get actionRecordBuy => 'บันทึกการซื้อ';

  @override
  String get actionRecordSell => 'บันทึกการขาย';

  @override
  String get actionRecordDividend => 'บันทึกเงินปันผล';

  @override
  String get actionPayCard => 'ชำระบัตร';

  @override
  String get actionTransfer => 'โอนเงิน';

  @override
  String get actionRecordTransaction => 'บันทึกรายการ';

  @override
  String get actionImportStatement => 'นำเข้ารายการเดินบัญชี';

  @override
  String get actionClearDates => 'ล้างวันที่';

  @override
  String get actionClearSearch => 'ล้างการค้นหาและตัวกรอง';

  @override
  String get actionUseBiometrics => 'ใช้ไบโอเมตริก';

  @override
  String get actionSetPin => 'ตั้งรหัส PIN';

  @override
  String get actionChangePin => 'เปลี่ยนรหัส PIN';

  @override
  String get actionSaveBackup => 'บันทึกข้อมูลสำรอง';

  @override
  String get actionRestoreBackup => 'กู้คืนข้อมูลสำรอง';

  @override
  String get actionSaveRule => 'บันทึกกฎ';

  @override
  String get actionConfirmFix => 'ยืนยันการแก้ไข';

  @override
  String get captureSpent => 'จ่ายไป';

  @override
  String get captureReceived => 'ได้รับ';

  @override
  String get captureMovedMoney => 'โอนเงิน';

  @override
  String get captureImportStatement => 'นำเข้ารายการเดินบัญชี';

  @override
  String get settingsTitle => 'การตั้งค่า';

  @override
  String get settingsLanguage => 'ภาษา';

  @override
  String get settingsLanguageSystem => 'ภาษาของอุปกรณ์';

  @override
  String get settingsFetchFxRates => 'ดึงอัตราแลกเปลี่ยนอ้างอิง';

  @override
  String get settingsFetchFxRatesSubtitle =>
      'แสดงอัตราตลาดโดยประมาณข้างจำนวนเงินปลายทาง สำหรับการโอนเงินข้ามสกุลเงิน เพื่อเปรียบเทียบเท่านั้น - จะไม่ถูกนำไปใช้กรอกจำนวนเงินให้โดยอัตโนมัติ';

  @override
  String get settingsRateProvider => 'ผู้ให้บริการอัตราแลกเปลี่ยน';

  @override
  String get settingsFetchMarketPrices => 'ดึงราคาตลาดสำหรับการลงทุน';

  @override
  String get settingsFetchMarketPricesSubtitle =>
      'ค้นหาราคาล่าสุดของตราสารที่มีสัญลักษณ์ (ticker) หรือ ISIN เพื่อประเมินมูลค่าพอร์ตการลงทุน จะไม่ถูกใช้บันทึกการซื้อขาย และจะไม่ส่งข้อมูลจำนวนที่คุณถืออยู่';

  @override
  String get settingsMarketPriceProvider => 'ผู้ให้บริการราคาตลาด';

  @override
  String get settingsFavouriteResearchTool => 'เครื่องมือค้นคว้าที่ชื่นชอบ';

  @override
  String get settingsFavouriteResearchToolSubtitle =>
      'การแตะชื่อตราสารในหน้าการถือครองจะเปิดเครื่องมือนี้ในเบราว์เซอร์พร้อมคำค้นหา — ไม่ใช่การเชื่อมต่อระบบ และไม่ใช่คำแนะนำการลงทุน';

  @override
  String get settingsBackup => 'สำรองข้อมูล';

  @override
  String get settingsBackupBlurb =>
      'บันทึกสำเนาบัญชีของคุณแบบเข้ารหัสไว้ในตำแหน่งที่คุณเลือก หรือกู้คืนจากสำเนานั้น ซึ่งแยกต่างหากจากวลีกู้คืนหรือไฟล์ keystore ที่ใช้สำรองกุญแจลงลายเซ็นของคุณ ไม่ใช่บัญชีของคุณ';

  @override
  String get settingsLock => 'ล็อก';

  @override
  String get settingsLockBlurb =>
      'กำหนดให้ใส่รหัส PIN หรือไบโอเมตริก (หากมี) เพื่อเปิดแอป';

  @override
  String get settingsRequireUnlock => 'ต้องปลดล็อกเพื่อเปิดแอป';

  @override
  String get settingsLockAfter => 'ล็อกหลังจาก';

  @override
  String get settingsLockImmediately => 'ทันที';

  @override
  String get settingsLock1Minute => '1 นาที';

  @override
  String get settingsLock5Minutes => '5 นาที';

  @override
  String get settingsLock15Minutes => '15 นาที';

  @override
  String get settingsAllowBiometrics => 'อนุญาตให้ใช้ไบโอเมตริกด้วย';

  @override
  String get settingsHideSnapshot => 'ซ่อนยอดคงเหลือในหน้าสลับแอป';

  @override
  String get settingsHideSnapshotSubtitle =>
      'ปิดบังหน้าจอนี้เมื่อคุณสลับไปยังแอปอื่น เพื่อไม่ให้มองเห็นได้ทันทีในหน้าสลับแอป';

  @override
  String get settingsHideSnapshotUnavailable =>
      'การซ่อนยอดคงเหลือในหน้าสลับแอปไม่รองรับบนแพลตฟอร์มนี้';

  @override
  String get settingsPayees => 'ผู้รับเงิน';

  @override
  String get settingsManagePayees => 'จัดการผู้รับเงิน';

  @override
  String get settingsPayeesBlurb =>
      'ชื่อผู้รับเงินที่จดจำไว้พร้อมหมวดหมู่และบัญชีเริ่มต้น จะถูกแนะนำโดยอัตโนมัติเมื่อบันทึกรายการ';

  @override
  String get settingsRecurring => 'แม่แบบรายการประจำ';

  @override
  String get settingsManageRecurring => 'จัดการแม่แบบรายการประจำ';

  @override
  String get settingsRecurringBlurb =>
      'ค่าใช้จ่ายหรือรายได้ที่เกิดซ้ำทุกเดือน เช่น ค่าเช่าหรือเงินเดือน แม่แบบที่ถึงกำหนดจะปรากฏในหน้าหลักให้คุณบันทึกด้วยการแตะเพียงครั้งเดียว - จะไม่ถูกบันทึกให้โดยอัตโนมัติ';

  @override
  String get settingsAbout => 'เกี่ยวกับ';

  @override
  String get settingsPrivacyPolicy => 'นโยบายความเป็นส่วนตัว';

  @override
  String get settingsPrivacyPolicyOpenFailed =>
      'ไม่สามารถเปิดนโยบายความเป็นส่วนตัวในเบราว์เซอร์ได้';

  @override
  String get providerFrankfurter => 'Frankfurter (อัตราจาก ECB)';

  @override
  String get providerOpenErApi => 'ExchangeRate-API (open.er-api.com)';

  @override
  String get providerStooq => 'Stooq (ราคารายวัน)';

  @override
  String get providerYahooFinance => 'Yahoo Finance (chart API)';

  @override
  String get researchChatGpt => 'ChatGPT';

  @override
  String get researchClaude => 'Claude';

  @override
  String get researchGemini => 'Gemini';

  @override
  String get researchMetaAi => 'Meta AI';

  @override
  String get systemGroupCashEquivalents => 'เงินสดและรายการเทียบเท่าเงินสด';

  @override
  String get systemGroupPensionRetirement => 'บำนาญและเกษียณอายุ';

  @override
  String get systemGroupCreditShortTerm => 'เครดิตและหนี้ระยะสั้น';

  @override
  String get systemGroupLoansMortgages => 'เงินกู้และสินเชื่อบ้าน';

  @override
  String get systemGroupInvestments => 'การลงทุน';

  @override
  String get systemAccountCashBank => 'เงินสดและธนาคาร';

  @override
  String get systemCategorySalary => 'เงินเดือน';

  @override
  String get systemCategoryOtherIncome => 'รายได้อื่น';

  @override
  String get systemCategoryGroceries => 'ของชำ';

  @override
  String get systemCategoryRentMortgage => 'ค่าเช่า/สินเชื่อบ้าน';

  @override
  String get systemCategoryUtilities => 'ค่าสาธารณูปโภค';

  @override
  String get systemCategoryTransport => 'การเดินทาง';

  @override
  String get systemCategoryFoodOut => 'อาหารนอกบ้าน';

  @override
  String get systemCategoryPhone => 'โทรศัพท์';

  @override
  String get systemCategoryHealth => 'สุขภาพ';

  @override
  String get systemCategoryOtherExpense => 'ค่าใช้จ่ายอื่น';

  @override
  String get systemDescriptionCsvImport => 'นำเข้า CSV';

  @override
  String get systemDescriptionOfxImport => 'นำเข้า OFX';

  @override
  String get homeThisMonth => 'เดือนนี้';

  @override
  String get homeMoneyInTransit => 'เงินระหว่างโอน';

  @override
  String get homeWhatYouHaveMinusWhatYouOwe =>
      'สิ่งที่คุณมี ลบ สิ่งที่คุณเป็นหนี้';

  @override
  String homeWhatYouHave(String amount, String currency) {
    return 'สิ่งที่คุณมี $amount $currency';
  }

  @override
  String homeNetPosition(String amount, String currency) {
    return '$amount $currency';
  }

  @override
  String homeHaveAndOwe(String haveAmount, String currency, String oweAmount) {
    return 'สิ่งที่คุณมี $haveAmount $currency  •  สิ่งที่คุณเป็นหนี้ $oweAmount $currency';
  }

  @override
  String youSentFrom(String amount, String currency, String name) {
    return 'คุณส่ง $amount $currency จาก $name';
  }

  @override
  String youSentTo(String amount, String currency, String name) {
    return 'คุณส่ง $amount $currency ไปยัง $name';
  }

  @override
  String get hiddenLabel => 'ซ่อนอยู่';

  @override
  String get allAccounts => 'ทุกบัญชี';

  @override
  String savedToPath(String path) {
    return 'บันทึกไปยัง $path';
  }

  @override
  String get homeTapWhenArrived => 'แตะเมื่อคุณทราบว่าได้รับอะไร';

  @override
  String homeReturnedTo(String name) {
    return 'คืนกลับไปยัง $name';
  }

  @override
  String get homeDueToday => 'ครบกำหนดวันนี้';

  @override
  String homeDueLine(String category, String account) {
    return '$category · $account · แตะเพื่อบันทึก';
  }

  @override
  String get homeOverLimit => 'เกินวงเงิน';

  @override
  String homeSpentOfLimit(String spent, String limit) {
    return '$spent จาก $limit';
  }

  @override
  String homeRemaining(String amount) {
    return 'คงเหลือ: $amount';
  }

  @override
  String get homeNoAccounts => 'ไม่มีบัญชี';

  @override
  String get homeCashRegister => 'รายการเงินสด';

  @override
  String get homeMarketEstimate => 'มูลค่าตามราคาตลาด';

  @override
  String get registerTitle => 'รายการ';

  @override
  String get registerSearchHint => 'คำอธิบาย หมวดหมู่ หรือจำนวนเงิน';

  @override
  String get registerNoTransactions => 'ยังไม่มีรายการ';

  @override
  String get registerNoEntries => 'ยังไม่มีการบันทึกรายการ';

  @override
  String get registerSpentOnly => 'แสดงเฉพาะรายจ่าย';

  @override
  String get registerReceivedOnly => 'แสดงเฉพาะรายรับ';

  @override
  String get registerAll => 'ทั้งหมด';

  @override
  String get registerUnverified => 'ยังไม่ยืนยัน - ไม่รวมในยอดรวม';

  @override
  String get registerSuperseded => 'ถูกแทนที่ด้วยการย้ายกุญแจ - ไม่รวมในยอดรวม';

  @override
  String get summaryTitle => 'สรุป';

  @override
  String get summaryTotalIncome => 'รายรับรวม';

  @override
  String get summaryTotalExpense => 'รายจ่ายรวม';

  @override
  String summaryDateRange(String start, String end) {
    return '$start ถึง $end';
  }

  @override
  String get accountsTitle => 'บัญชี';

  @override
  String get categoriesTitle => 'หมวดหมู่';

  @override
  String get accountName => 'ชื่อบัญชี';

  @override
  String get createAccount => 'สร้างบัญชี';

  @override
  String get createGroup => 'สร้างกลุ่ม';

  @override
  String get editGroup => 'แก้ไขกลุ่ม';

  @override
  String get renameAccount => 'เปลี่ยนชื่อบัญชี';

  @override
  String get renameCategory => 'เปลี่ยนชื่อหมวดหมู่';

  @override
  String get addCategory => 'เพิ่มหมวดหมู่';

  @override
  String get groupLabel => 'กลุ่ม';

  @override
  String get kindLabel => 'ประเภท';

  @override
  String get asset => 'สินทรัพย์';

  @override
  String get liability => 'หนี้สิน';

  @override
  String get income => 'รายได้';

  @override
  String get expense => 'ค่าใช้จ่าย';

  @override
  String get thisAccountHoldsInvestments => 'บัญชีนี้ใช้ถือครองการลงทุน';

  @override
  String get thisAccountHoldsInvestmentsSubtitle =>
      'เงินสดบวกกับสินค้าคงคลังที่คุณบันทึกด้วยการซื้อ ขาย และเงินปันผล';

  @override
  String get thisIsACreditCard => 'นี่คือบัตรเครดิต';

  @override
  String get openingBalanceOptional => 'ยอดยกมา (ไม่บังคับ)';

  @override
  String get currencyIso => 'สกุลเงิน (ISO 4217)';

  @override
  String get currencyIsoExample => 'สกุลเงิน (ISO 4217 เช่น USD)';

  @override
  String get hideAccountTitle => 'ซ่อนบัญชีจากรายการใหม่หรือไม่?';

  @override
  String get hideCategoryTitle => 'ซ่อนหมวดหมู่จากรายการใหม่หรือไม่?';

  @override
  String get hideGroupTitle => 'ซ่อนกลุ่มจากรายการใหม่หรือไม่?';

  @override
  String get reassignGroup => 'ย้ายกลุ่ม';

  @override
  String get transferRemainingBalance => 'โอนยอดคงเหลือ';

  @override
  String get monthlyLimit => 'วงเงินรายเดือน';

  @override
  String get monthlyLimitHint => 'วงเงิน (เว้นว่างเพื่อล้างค่า)';

  @override
  String get monthlyLimitBlurb =>
      'แนวทางการใช้จ่ายสะสมตั้งแต่ต้นเดือนสำหรับหมวดหมู่รายจ่ายนี้ (ไม่บังคับ)';

  @override
  String get translateCategoryWithAi => 'Translate with AI';

  @override
  String get addCategoryTranslation => 'Add translation';

  @override
  String get categoryTranslationLocale => 'Language';

  @override
  String get categoryTranslationName => 'Translated name';

  @override
  String get mergeCategories => 'Merge categories';

  @override
  String get mergeCategoriesSuggested =>
      'These categories look the same. Merge them?';

  @override
  String get categoryDefaultLanguage => 'Default language for category names';

  @override
  String get categoryDefaultLanguageSubtitle =>
      'Shared across linked devices. Each device still shows its own language when a translation exists.';

  @override
  String get manageCategoryRules => 'จัดการกฎหมวดหมู่';

  @override
  String get amount => 'จำนวนเงิน';

  @override
  String get category => 'หมวดหมู่';

  @override
  String get account => 'บัญชี';

  @override
  String get fromAccount => 'จากบัญชี';

  @override
  String get toAccount => 'ไปยังบัญชี';

  @override
  String get descriptionOptional => 'คำอธิบาย (ไม่บังคับ)';

  @override
  String get alsoRememberPayee => 'จดจำเป็นผู้รับเงินด้วย';

  @override
  String get splitIntoCategories => 'แบ่งเป็นหลายหมวดหมู่';

  @override
  String categoryN(String n) {
    return 'หมวดหมู่ $n';
  }

  @override
  String get destinationAmount => 'จำนวนเงินปลายทาง';

  @override
  String get destinationAmountOptional => 'จำนวนเงินปลายทาง (ไม่บังคับ)';

  @override
  String get accountCurrencyAmountOptional =>
      'จำนวนเงินตามสกุลเงินบัญชี (ไม่บังคับ)';

  @override
  String get transactionCurrencyOptional => 'สกุลเงินของรายการ (ไม่บังคับ)';

  @override
  String get feeOptional => 'ค่าธรรมเนียม (ไม่บังคับ)';

  @override
  String get feeAmount => 'จำนวนค่าธรรมเนียม';

  @override
  String get feeCategory => 'หมวดหมู่ค่าธรรมเนียม';

  @override
  String get feeDescriptionOptional => 'คำอธิบายค่าธรรมเนียม (ไม่บังคับ)';

  @override
  String get feeDeducted => 'ค่าธรรมเนียมถูกหักจากจำนวนเงินด้านบน';

  @override
  String get needTwoAccountsToTransfer =>
      'สร้างบัญชีที่ใช้งานอยู่อย่างน้อยสองบัญชีเพื่อทำการโอนเงิน';

  @override
  String get whatArrivedTitle => 'ได้รับอะไร?';

  @override
  String get whatArrivedBlurb => 'บอกเราว่าได้รับอะไรจริง ๆ';

  @override
  String get amountThatArrived => 'จำนวนเงินที่ได้รับ';

  @override
  String get feeLossCategory => 'หมวดหมู่ค่าธรรมเนียม / ขาดทุน';

  @override
  String get alreadySettled => 'ชำระเรียบร้อยแล้ว';

  @override
  String get holdingsTitle => 'การถือครอง';

  @override
  String get holdingsCash => 'เงินสด';

  @override
  String get holdingsInventory => 'สินค้าคงคลัง';

  @override
  String holdingsBook(String amount, String currency) {
    return 'ตามบัญชี (เงินสด + ต้นทุน) $amount $currency';
  }

  @override
  String holdingsMarketEstimate(String amount, String currency) {
    return 'มูลค่าตามราคาตลาด $amount $currency';
  }

  @override
  String get holdingsNoHoldings =>
      'ยังไม่มีการถือครอง บันทึกการซื้อเพื่อเพิ่มตราสาร';

  @override
  String get holdingsQuotesBlurb =>
      'ราคาที่แสดงเป็นเพียงการประมาณ ไม่ใช่ราคาจากโบรกเกอร์ แอปนี้ไม่ได้ส่งคำสั่งซื้อขาย';

  @override
  String get holdingsTapNameToResearch =>
      'แตะชื่อเพื่อค้นคว้าข้อมูล ราคาที่แสดงเป็นเพียงการประมาณ ไม่ใช่คำแนะนำการลงทุน';

  @override
  String get instrument => 'ตราสาร';

  @override
  String get newInstrument => 'ตราสารใหม่';

  @override
  String get renameInstrument => 'เปลี่ยนชื่อตราสาร';

  @override
  String get instrumentActions => 'การดำเนินการกับตราสาร';

  @override
  String hideInstrumentTitle(String name) {
    return 'ซ่อน $name หรือไม่?';
  }

  @override
  String get tickerOptional => 'สัญลักษณ์ตราสาร (ไม่บังคับ)';

  @override
  String get isinOptional => 'ISIN (ไม่บังคับ)';

  @override
  String get quantity => 'จำนวนหน่วย';

  @override
  String get unitPrice => 'ราคาต่อหน่วย';

  @override
  String get brokerageOptional => 'ค่านายหน้า (ไม่บังคับ)';

  @override
  String get brokerageExpenseCategory => 'หมวดหมู่ค่าใช้จ่ายค่านายหน้า';

  @override
  String get incomeCategory => 'หมวดหมู่รายได้';

  @override
  String get gainIncomeCategory => 'หมวดหมู่รายได้จากกำไร';

  @override
  String get lossExpenseCategory => 'หมวดหมู่ค่าใช้จ่ายจากขาดทุน';

  @override
  String get nonCash => 'ไม่ใช่เงินสด';

  @override
  String get cash => 'เงินสด';

  @override
  String get locked => 'ถูกล็อก';

  @override
  String get lockUntilHint => 'บันทึกข้อจำกัดของคุณเอง ไม่ใช่กฎของโบรกเกอร์';

  @override
  String get instrumentKindStock => 'หุ้น';

  @override
  String get instrumentKindEtf => 'ETF';

  @override
  String get instrumentKindMutualFund => 'กองทุนรวม';

  @override
  String get instrumentKindBond => 'พันธบัตร';

  @override
  String get instrumentKindOther => 'อื่น ๆ';

  @override
  String get quoteUseLive => 'ราคาสด';

  @override
  String get quoteUseCached => 'ราคาที่แคชไว้';

  @override
  String get quoteUseStale => 'ราคาที่ล้าสมัย';

  @override
  String get quoteUseMissing => 'ใช้ต้นทุน (ไม่มีราคา)';

  @override
  String get quoteUseDisabled => 'ปิดการดึงราคา — ใช้ต้นทุน/แคช';

  @override
  String get quoteUseCurrencyMismatch => 'ใช้ต้นทุน (สกุลเงินราคาต่างกัน)';

  @override
  String unrealizedLabel(String amount, String currency) {
    return 'กำไร/ขาดทุนที่ยังไม่เกิดขึ้นจริง $amount $currency';
  }

  @override
  String holdingsUnitsCost(String qty) {
    return '$qty หน่วย · ';
  }

  @override
  String get chooseLanguageTitle => 'เลือกภาษาของคุณ';

  @override
  String get chooseLanguageBlurb =>
      'ทุกอย่างในแอปจะแสดงเป็นภาษานี้ คุณสามารถเปลี่ยนได้ภายหลังในการตั้งค่า';

  @override
  String get chooseCurrencyTitle => 'เลือกสกุลเงินของคุณ';

  @override
  String get chooseCurrencyBlurb =>
      'กลุ่มบัญชีทุกกลุ่ม (เงินสดและรายการเทียบเท่าเงินสด บำนาญและเกษียณอายุ ฯลฯ) จะใช้สกุลเงินเดียวนี้ไปก่อน คุณยังสามารถเพิ่มบัญชีในสกุลเงินอื่นได้ภายหลังโดยการสร้างกลุ่มใหม่สำหรับสกุลเงินนั้น';

  @override
  String get currencyBackfillTitle => 'เลือกสกุลเงินสำหรับกลุ่มที่มีอยู่';

  @override
  String get currencyBackfillBlurb =>
      'ตอนนี้แอปนี้รองรับหลายสกุลเงินแล้ว บัญชีและกลุ่มบัญชีที่มีอยู่ของคุณต้องมีสกุลเงิน - เนื่องจากทั้งหมดถูกตั้งค่าไว้ก่อนที่ฟีเจอร์นี้จะมีขึ้น การเลือกครั้งนี้จะมีผลกับทั้งหมด';

  @override
  String get firstAccountTitle => 'ตั้งชื่อบัญชีของคุณ';

  @override
  String get firstAccountBlurb =>
      'นี่คือบัญชีที่ถูกตั้งค่าไว้ให้คุณแล้ว - ตั้งชื่อที่คุณจำได้ เช่น ชื่อธนาคารของคุณ จากนั้นคุณจะบันทึกรายการจ่ายหรือรับหนึ่งรายการ แล้วปกป้องอุปกรณ์ด้วยวลีกู้คืนของคุณ';

  @override
  String get whatsMainAccountCalled => 'บัญชีหลักของคุณชื่ออะไร?';

  @override
  String get setupChoiceTitle => 'Welcome to Smara Accounting';

  @override
  String get setupChoiceBlurb =>
      'Starting fresh, or moving from another device?';

  @override
  String get actionNewSetup => 'New setup';

  @override
  String get continueBooksTitle => 'Continue my books on this phone';

  @override
  String get continueBooksBlurb =>
      'These books arrived on this phone without their signing key. You can continue them under a new key for this phone, or restore from a saved copy instead.';

  @override
  String get continueBooksAction => 'Continue my books on this phone';

  @override
  String get restoreFromCopyAction => 'Restore from a copy';

  @override
  String get saveBooksCopyAction => 'Save a copy of my books';

  @override
  String get deviceHistoryTitle => 'Device history';

  @override
  String get deviceHistoryEmpty =>
      'No Continuations yet. When you continue books on a new phone, they will show up here.';

  @override
  String deviceHistoryContinuedOn(String date) {
    return 'Your books continued on this phone on $date';
  }

  @override
  String deviceHistoryContinuedFromCopy(String continuedDate, String copyDate) {
    return 'Your books continued on this phone on $continuedDate (from a copy saved on $copyDate)';
  }

  @override
  String get backupReminderBannerTitle => 'Save a copy of your books';

  @override
  String get backupReminderSaveAction => 'Save a copy';

  @override
  String get backupReminderLaterAction => 'Later';

  @override
  String get settingsBackupReminder => 'Copy reminder';

  @override
  String get settingsBackupReminderBlurb =>
      'We\'ll gently remind you to save a copy of your books after a while, or after many new entries. A saved copy is the only way to recover books if this phone is lost.';

  @override
  String get settingsBackupReminderEnabled => 'Remind me to save a copy';

  @override
  String get settingsBackupReminderDays => 'Remind after this many days';

  @override
  String get settingsBackupReminderEntries =>
      'Remind after this many new entries';

  @override
  String get settingsBackupReminderSnoozeDays =>
      'Hide for this many days after Later';

  @override
  String get settingsBackupReminderSnoozeEntries =>
      'Hide for this many new entries after Later';

  @override
  String get settingsBooksSwitcher => 'Books on this device';

  @override
  String get settingsBooksSwitcherBlurb =>
      'Each set of books has its own signing key and history. Switching opens that set — Home and Register show only its entries.';

  @override
  String get settingsBooksSwitcherActive => 'Open now';

  @override
  String get settingsBooksSwitcherSwitch => 'Switch';

  @override
  String get settingsBooksSwitcherCreate => 'New books';

  @override
  String get settingsBooksSwitcherCreateTitle => 'Name these books';

  @override
  String get settingsBooksSwitcherNameLabel => 'Name';

  @override
  String get settingsBooksSwitcherRemoveTitle => 'Remove these books?';

  @override
  String settingsBooksSwitcherRemoveBody(String name) {
    return 'This deletes \"$name\" from this device, including its signing key. Other books on this device are not affected.';
  }

  @override
  String get settingsBooksSwitcherRemoveConfirm => 'Remove';

  @override
  String get settingsLinkedDevices => 'Linked devices';

  @override
  String get settingsLinkedDevicesCatchUp =>
      'Your devices catch up when both have Smara open on the same Wi-Fi.';

  @override
  String get settingsLinkedDevicesPermissionSentence =>
      'To share your books, Smara needs to find your other devices on this Wi-Fi. Nothing goes to the internet.';

  @override
  String get settingsLinkedDevicesAddDevice => 'Add a device';

  @override
  String get settingsLinkedDevicesContinue => 'Continue';

  @override
  String get settingsLinkedDevicesRoleOwner => 'Owner';

  @override
  String get settingsLinkedDevicesRoleMember => 'Member';

  @override
  String get settingsLinkedDevicesCanAdd => 'May add devices';

  @override
  String get settingsLinkedDevicesErasePending => 'Erase pending';

  @override
  String settingsLinkedDevicesErasedOn(String date) {
    return 'Erased on $date';
  }

  @override
  String get settingsLinkedDevicesSuggestSecondOwner =>
      'These books have only one Owner. Consider making another linked device an Owner too.';

  @override
  String get settingsLinkedDevicesJoinSameWifi =>
      'Both devices must be on the same Wi-Fi. Smara does not join over the internet.';

  @override
  String get settingsLinkedDevicesApproveJoin => 'Approve';

  @override
  String get settingsLinkedDevicesRefuseJoin => 'Refuse';

  @override
  String settingsLinkedDevicesPendingJoin(String name) {
    return '$name wants to join these books';
  }

  @override
  String get settingsLinkedDevicesEmpty => 'Only this device is linked so far.';

  @override
  String get settingsLinkedDevicesSyncNow => 'Sync now';

  @override
  String get settingsLinkedDevicesSyncNowBusy => 'Catching up…';

  @override
  String membershipNoticeDeviceAdded(String name) {
    return 'A device was added: $name';
  }

  @override
  String membershipNoticeDeviceRemoved(String name) {
    return 'A device was removed: $name';
  }

  @override
  String membershipNoticeErasePending(String name) {
    return 'Erase pending for $name';
  }

  @override
  String membershipNoticeErased(String name, String date) {
    return 'Erased $name on $date';
  }

  @override
  String membershipNoticeSoleOwnerClaimed(String name) {
    return '$name claimed sole ownership';
  }

  @override
  String membershipNoticeSoleOwnerCancelled(String name) {
    return 'Sole-Owner claim for $name was cancelled';
  }

  @override
  String membershipNoticeSoleOwnerEffective(String name) {
    return '$name is now an Owner';
  }

  @override
  String membershipNoticeEntryNotAccepted(String name) {
    return 'Not accepted: couldn\'t be verified (from $name)';
  }

  @override
  String membershipNoticeOwnerVerificationAlert(String name) {
    return 'A record from $name could not be verified and was not accepted';
  }

  @override
  String get membershipNoticeCompetingFixCheck =>
      'Two Fixes for the same entry were resolved — please check';

  @override
  String get whyWeDontEdit => 'ทำไมเราจึงไม่แก้ไขรายการเก่า';

  @override
  String get whyWeDontEditBody =>
      'เมื่อคุณแก้ไขข้อผิดพลาด เราจะเก็บรายการเดิมไว้และเพิ่มรายการแก้ไขต่อท้าย แทนที่จะเปลี่ยนสิ่งที่คุณบันทึกไปแล้ว วิธีนี้ทำให้ประวัติของคุณแสดงสิ่งที่เกิดขึ้นจริงเสมอ รวมถึงเวลาที่คุณแก้ไข — ไม่มีอะไรถูกเปลี่ยนแปลงอย่างเงียบ ๆ โดยที่คุณไม่รู้';

  @override
  String get lockTitle => 'ปลดล็อก';

  @override
  String get lockScreenTitle => 'ล็อก';

  @override
  String get enterPinToContinue => 'ป้อนรหัส PIN เพื่อดำเนินการต่อ';

  @override
  String get pinLabel => 'PIN';

  @override
  String get setPinTitle => 'ตั้งรหัส PIN';

  @override
  String get currentPin => 'PIN ปัจจุบัน';

  @override
  String get newPin => 'PIN ใหม่';

  @override
  String get confirmPin => 'ยืนยัน PIN';

  @override
  String get confirmNewPin => 'ยืนยัน PIN ใหม่';

  @override
  String get firstWeekTitle => 'ตั้งค่าบัญชีของคุณ';

  @override
  String get addCashAccount => 'เพิ่มบัญชีเงินสด';

  @override
  String get addCreditCard => 'เพิ่มบัตรเครดิต';

  @override
  String get cashAccountName => 'ชื่อบัญชีเงินสด';

  @override
  String get cardName => 'ชื่อบัตร';

  @override
  String get paidFromBank => 'จ่ายจากธนาคาร';

  @override
  String get paidFromCard => 'จ่ายจากบัตร';

  @override
  String get choosePassphraseTitle =>
      'เลือกวลีรหัสผ่านเพื่อป้องกันข้อมูลสำรองนี้ หากคุณลืมจะไม่สามารถกู้คืนได้';

  @override
  String get replaceBooksTitle => 'แทนที่บัญชีในเครื่องของคุณหรือไม่?';

  @override
  String get replaceBooksBody =>
      'การดำเนินการนี้จะแทนที่ข้อมูลทั้งหมดในแอปนี้ด้วยข้อมูลสำรอง หลังจากนั้นให้ปิดและเปิดแอปใหม่';

  @override
  String get chooseBackupFileFirst => 'เลือกไฟล์สำรองก่อน';

  @override
  String get backupRestored => 'กู้คืนข้อมูลสำรองเรียบร้อยแล้ว';

  @override
  String get backupRestoredBody =>
      'บัญชีของคุณได้รับการกู้คืนแล้ว ปิดและเปิดแอปใหม่เพื่อดำเนินการต่อ';

  @override
  String get fixThisEntry => 'แก้ไขรายการนี้';

  @override
  String get fixBlurb =>
      'รายการเดิมจะคงอยู่เหมือนเดิมทุกประการ การยืนยันจะเพิ่มรายการกลับรายการและรายการที่แก้ไขแล้ว';

  @override
  String get importStatementTitle => 'นำเข้ารายการเดินบัญชี';

  @override
  String get importOfx => 'นำเข้า OFX';

  @override
  String get importOfxQfxFile => 'นำเข้าไฟล์ OFX / QFX';

  @override
  String get importCsvFile => 'นำเข้าไฟล์ CSV';

  @override
  String get whatKindOfStatement => 'คุณมีไฟล์รายการเดินบัญชีประเภทใด?';

  @override
  String get chooseAccountForFile => 'เลือกว่าไฟล์นี้เป็นของบัญชีใด';

  @override
  String get importIntoAccount => 'นำเข้าไปยังบัญชี';

  @override
  String get useSavedProfile => 'ใช้โปรไฟล์ที่บันทึกไว้';

  @override
  String get saveMappingProfile => 'บันทึกการจับคู่นี้เป็นโปรไฟล์ (ไม่บังคับ)';

  @override
  String get renameProfile => 'เปลี่ยนชื่อโปรไฟล์';

  @override
  String get deleteProfileTitle => 'ลบโปรไฟล์หรือไม่?';

  @override
  String get fileHasHeader => 'ไฟล์มีแถวหัวตาราง';

  @override
  String get dateColumn => 'คอลัมน์วันที่';

  @override
  String get dateFormatHint => 'รูปแบบวันที่ (เช่น dd/MM/yyyy)';

  @override
  String get amountColumn => 'คอลัมน์จำนวนเงิน';

  @override
  String get amountConvention => 'รูปแบบเครื่องหมายจำนวนเงิน';

  @override
  String get signedAmountColumn => 'คอลัมน์จำนวนเงินที่มีเครื่องหมาย';

  @override
  String get separateDebitCredit => 'แยกคอลัมน์เดบิต / เครดิต';

  @override
  String get debitColumn => 'คอลัมน์เดบิต';

  @override
  String get creditColumn => 'คอลัมน์เครดิต';

  @override
  String get decimalSeparator => 'ตัวคั่นทศนิยม (. หรือ ,)';

  @override
  String get descriptionColumns => 'คอลัมน์คำอธิบาย';

  @override
  String get referenceIdColumn => 'คอลัมน์รหัสอ้างอิง (ไม่บังคับ)';

  @override
  String get skippedRows => 'แถวที่ข้าม';

  @override
  String parsedTransactionCount(String count) {
    return 'แยกรายการได้ $count รายการ';
  }

  @override
  String skippedOrExcludedCount(String count) {
    return 'ข้ามหรือแยกออก $count รายการ';
  }

  @override
  String postedFailedCount(String posted, String failed) {
    return 'บันทึกสำเร็จ $posted รายการ, ล้มเหลว $failed รายการ';
  }

  @override
  String get categoryForAll => 'หมวดหมู่สำหรับทั้งหมด';

  @override
  String get saveAsRule => 'บันทึกเป็นกฎหรือไม่?';

  @override
  String get saveAsRuleBlurb =>
      'การนำเข้าครั้งต่อไปที่คำอธิบายมีคำสำคัญนี้จะใช้หมวดหมู่นี้';

  @override
  String get keyword => 'คำสำคัญ';

  @override
  String get noSavedRules =>
      'ยังไม่มีกฎที่บันทึกไว้ กำหนดหมวดหมู่ให้กลุ่มแถวเพื่อบันทึกเป็นกฎ';

  @override
  String get deleteRuleTitle => 'ลบกฎหรือไม่?';

  @override
  String get editRule => 'แก้ไขกฎ';

  @override
  String rowsGrouped(String count) {
    return '$count แถว';
  }

  @override
  String selectStatementFile(String extensions) {
    return 'เลือกไฟล์รายการเดินบัญชี $extensions เพื่อนำเข้า';
  }

  @override
  String get payeesTitle => 'ผู้รับเงิน';

  @override
  String get addPayee => 'เพิ่มผู้รับเงิน';

  @override
  String get renamePayee => 'เปลี่ยนชื่อผู้รับเงิน';

  @override
  String get deletePayeeTitle => 'ลบผู้รับเงินหรือไม่?';

  @override
  String get noPayeesYet => 'ยังไม่มีผู้รับเงิน';

  @override
  String get recurringTitle => 'แม่แบบรายการประจำ';

  @override
  String get noRecurringYet => 'ยังไม่มีแม่แบบรายการประจำ';

  @override
  String get deleteTemplateTitle => 'ลบแม่แบบรายการประจำหรือไม่?';

  @override
  String get dayOfMonth => 'วันที่ของเดือน (1-31)';

  @override
  String get dayOfMonthNote =>
      'เดือนที่มีจำนวนวันน้อยกว่าจะใช้วันสุดท้ายของเดือนนั้นแทน';

  @override
  String dayOfMonthLine(String day) {
    return 'วันที่ $day ของเดือน - ';
  }

  @override
  String get name => 'ชื่อ';

  @override
  String get none => 'ไม่มี';

  @override
  String get currency => 'สกุลเงิน';

  @override
  String get errorGeneric => 'เกิดข้อผิดพลาด โปรดลองอีกครั้ง';

  @override
  String get errorInvalidLedgerBackup =>
      'ไฟล์นี้ไม่ใช่ข้อมูลสำรองของ Smara ที่ถูกต้อง';

  @override
  String get errorInvalidLedgerBackupNoIdentity =>
      'ข้อมูลสำรองนี้ไม่มีตัวตนลงลายเซ็น - จึงไม่ใช่ข้อมูลสำรองของ Smara ที่ถูกต้อง';

  @override
  String get errorInvalidLedgerBackupUnverified =>
      'ข้อมูลสำรองนี้ไม่ผ่านการยืนยันว่าเป็นบัญชีที่สมบูรณ์ จึงไม่ได้ถูกกู้คืน';

  @override
  String errorInvalidLedgerBackupUnreadable(String detail) {
    return 'ไม่สามารถเปิดไฟล์นี้เป็นข้อมูลสำรองของ Smara ได้: $detail';
  }

  @override
  String get errorAccountNotFinancial => 'นั่นไม่ใช่บัญชีการเงิน';

  @override
  String get errorAccountArchived => 'บัญชีนั้นถูกซ่อนอยู่';

  @override
  String get errorAccountNotArchived => 'บัญชีนั้นไม่ได้ถูกซ่อน';

  @override
  String get errorAccountNoPositiveBalanceToCloseOut => 'ไม่มียอดคงเหลือให้โอน';

  @override
  String get errorAccountHasNoGroup => 'บัญชีนั้นยังไม่ได้กำหนดกลุ่ม';

  @override
  String get errorGroupHasNoCurrency => 'กลุ่มนั้นยังไม่ได้กำหนดสกุลเงิน';

  @override
  String get errorGroupNotFound => 'ไม่พบกลุ่มบัญชีนั้น';

  @override
  String get errorInvestmentAccountsMustBeAssets =>
      'เฉพาะบัญชีสินทรัพย์เท่านั้นที่สามารถกำหนดให้เป็นบัญชีการลงทุนได้';

  @override
  String get errorCreditCardsMustBeLiabilities =>
      'เฉพาะบัญชีหนี้สินเท่านั้นที่สามารถกำหนดให้เป็นบัตรเครดิตได้';

  @override
  String get errorOpeningBalanceMustBePositive =>
      'ยอดยกมาต้องเป็นค่าบวกเมื่อระบุ';

  @override
  String get errorAccountTypeDoesNotMatchGroup =>
      'ประเภทบัญชีนั้นไม่ตรงกับกลุ่ม';

  @override
  String get errorLastActiveAccount =>
      'ไม่สามารถซ่อนบัญชีการเงินที่ใช้งานอยู่บัญชีสุดท้ายได้';

  @override
  String get errorCurrencyRequiredToCreateGroup =>
      'ต้องระบุสกุลเงินเพื่อสร้างกลุ่ม';

  @override
  String get errorSystemGroupCannotBeArchived =>
      'กลุ่มบัญชีในตัวไม่สามารถซ่อนได้';

  @override
  String get errorGroupAlreadyArchived => 'กลุ่มนั้นถูกซ่อนอยู่แล้ว';

  @override
  String get errorCannotArchiveGroupWithAccounts =>
      'ไม่สามารถซ่อนกลุ่มที่ยังมีบัญชีที่ใช้งานอยู่ได้';

  @override
  String get errorSystemGroupNeverArchived =>
      'กลุ่มบัญชีในตัวจะไม่ถูกซ่อนไม่ว่ากรณีใด';

  @override
  String get errorAccountGroupsCannotBeDeleted => 'ไม่สามารถลบกลุ่มบัญชีได้';

  @override
  String get errorCannotReassignDifferentCurrency =>
      'ไม่สามารถย้ายบัญชีนี้ไปยังกลุ่มที่มีสกุลเงินต่างกันได้';

  @override
  String get errorCannotChangeGroupCurrencyWithAccounts =>
      'ไม่สามารถเปลี่ยนสกุลเงินขณะที่กลุ่มมีบัญชีที่ใช้งานอยู่ได้';

  @override
  String get errorAmountMustBePositive => 'จำนวนเงินต้องเป็นบวก';

  @override
  String get errorAccountCurrencyAmountMustBePositive =>
      'จำนวนเงินตามสกุลเงินบัญชีต้องเป็นบวก';

  @override
  String get errorAccountCurrencyAmountNotForSameCurrency =>
      'จำนวนเงินตามสกุลเงินบัญชีใช้ได้เฉพาะรายการที่เป็นสกุลเงินต่างประเทศเท่านั้น';

  @override
  String get errorSplitNeedsTwoLines =>
      'การแบ่งรายการต้องมีอย่างน้อยสองหมวดหมู่';

  @override
  String get errorSplitLineMustBePositive =>
      'แต่ละรายการที่แบ่งต้องมีจำนวนเงินเป็นบวก';

  @override
  String get errorSplitLinesMustSumToTotal =>
      'ผลรวมของรายการที่แบ่งต้องเท่ากับยอดรวมของรายการ';

  @override
  String get errorTransferAmountMustBePositive => 'จำนวนเงินโอนต้องเป็นบวก';

  @override
  String get errorTransferAccountsMustDiffer =>
      'บัญชีต้นทางและปลายทางต้องแตกต่างกัน';

  @override
  String get errorCloseoutRequiresDestinationAmount =>
      'การปิดบัญชีข้ามสกุลเงินต้องระบุจำนวนเงินปลายทางที่ทราบแล้ว';

  @override
  String get errorDestinationAmountNotForSameCurrency =>
      'จำนวนเงินปลายทางใช้ได้เฉพาะการโอนข้ามสกุลเงินเท่านั้น';

  @override
  String get errorDestinationAmountMustBePositive =>
      'จำนวนเงินปลายทางต้องเป็นบวก';

  @override
  String get errorInvestmentCashExceeded =>
      'ไม่สามารถโอนเกินยอดเงินสดของบัญชีการลงทุนนี้ได้';

  @override
  String get errorCannotReverseUnsettledProvisional =>
      'ให้ชำระรายการโอนที่รอดำเนินการนี้แทนการกลับรายการ';

  @override
  String get errorAlreadyReversed =>
      'รายการนี้ได้รับการแก้ไขแล้ว รายการต้นฉบับจะยังคงอยู่ตามเดิม';

  @override
  String get errorNotActiveExpenseCategory =>
      'เลือกหมวดหมู่รายจ่ายที่ใช้งานอยู่';

  @override
  String get errorNotActiveIncomeCategory => 'เลือกหมวดหมู่รายรับที่ใช้งานอยู่';

  @override
  String get errorSettledAmountMustNotBeNegative =>
      'จำนวนเงินที่ได้รับต้องไม่ติดลบ';

  @override
  String get errorPendingTransferNotFound => 'ไม่พบรายการโอนที่รอดำเนินการนั้น';

  @override
  String get errorPendingTransferAlreadySettled =>
      'รายการโอนที่รอดำเนินการนั้นชำระเรียบร้อยแล้ว';

  @override
  String get errorSettledToMustBeSourceOrDestination =>
      'เลือกบัญชีต้นทางหรือปลายทางเดิม';

  @override
  String get errorFeeCategoryOnlyWhenReturningToSource =>
      'หมวดหมู่ค่าธรรมเนียมจะใช้ก็ต่อเมื่อเงินถูกคืนกลับไปยังบัญชีต้นทางเท่านั้น';

  @override
  String get errorSettledAmountMustBePositiveForDelivery =>
      'ป้อนจำนวนเงินที่ได้รับเป็นค่าบวก';

  @override
  String get errorSettledAmountExceedsProvisional =>
      'จำนวนเงินนั้นมากกว่าที่ถูกส่งไป';

  @override
  String get errorInstrumentNotFound => 'ไม่พบตราสารนั้น';

  @override
  String get errorIncomeRequiredForNonCash =>
      'ต้องมีหมวดหมู่รายรับที่ใช้งานอยู่สำหรับการได้มาแบบไม่ใช่เงินสด';

  @override
  String get errorInsufficientCash =>
      'เงินสดในบัญชีการลงทุนนี้ไม่เพียงพอสำหรับการซื้อนั้น';

  @override
  String get errorSellQuantityAndPriceMustBePositive =>
      'จำนวนหน่วยที่ขายและราคาต่อหน่วยต้องเป็นบวก';

  @override
  String errorLockedUntil(String date) {
    return 'ไม่สามารถขายได้: บางหน่วยถูกล็อกจนถึง $date';
  }

  @override
  String get errorInsufficientQuantity =>
      'ไม่สามารถขายเกินจำนวนที่คุณถืออยู่ที่ไม่ถูกล็อกได้';

  @override
  String get errorIncomeRequiredForGain =>
      'ต้องมีหมวดหมู่รายรับที่ใช้งานอยู่สำหรับกำไรที่เกิดขึ้นจริง';

  @override
  String get errorExpenseRequiredForLoss =>
      'ต้องมีหมวดหมู่รายจ่ายที่ใช้งานอยู่สำหรับขาดทุนที่เกิดขึ้นจริง';

  @override
  String errorBrokerageFailedAfterBuy(String detail) {
    return 'บันทึกการซื้อแล้ว แต่ค่านายหน้าไม่สำเร็จ: $detail';
  }

  @override
  String errorBrokerageFailedAfterSell(String detail) {
    return 'บันทึกการขายแล้ว แต่ค่านายหน้าไม่สำเร็จ: $detail';
  }

  @override
  String get errorDividendMustBePositive => 'จำนวนเงินปันผลต้องเป็นบวก';

  @override
  String get errorNotInvestmentAccount => 'นั่นไม่ใช่บัญชีการลงทุน';

  @override
  String get errorNoInventoryCompanion =>
      'บัญชีการลงทุนนี้ขาดบัญชีสินค้าคงคลังคู่กัน';

  @override
  String errorInvestmentReversalBlocked(String sells) {
    return 'ไม่สามารถกลับรายการซื้อนี้ได้: การขายในภายหลังขึ้นอยู่กับหน่วยของรายการนี้ กรุณากลับรายการขายที่เกี่ยวข้องก่อน: $sells';
  }

  @override
  String get errorMonthlyLimitMustBePositive => 'วงเงินรายเดือนต้องเป็นบวก';

  @override
  String get errorTemplateAmountMustBePositive =>
      'จำนวนเงินของแม่แบบต้องเป็นบวก';

  @override
  String get errorOfxUnrecognized => 'ไม่สามารถระบุไฟล์นี้เป็น OFX ได้';

  @override
  String get errorCsvEmpty => 'ไฟล์ที่เลือกว่างเปล่า';

  @override
  String get errorCsvUnreadable => 'ไม่สามารถอ่านไฟล์นี้เป็น CSV ได้';

  @override
  String get errorCsvNoRows => 'ไฟล์ที่เลือกไม่มีข้อมูล';

  @override
  String get skipMissingDate => 'ไม่มีวันที่';

  @override
  String skipUnparseableDate(String raw, String pattern) {
    return 'ไม่สามารถแยกวิเคราะห์วันที่ \"$raw\" ด้วยรูปแบบ \"$pattern\" ได้';
  }

  @override
  String get skipOfxMissingOrInvalidDate => 'ไม่มีวันที่ทำรายการหรือไม่ถูกต้อง';

  @override
  String skipOfxUnparseableDate(String raw) {
    return 'ไม่สามารถแยกวิเคราะห์วันที่ทำรายการ \"$raw\" ได้';
  }

  @override
  String get skipMissingAmount => 'ไม่มีจำนวนเงิน';

  @override
  String skipUnparseableAmount(String raw) {
    return 'ไม่สามารถแยกวิเคราะห์จำนวนเงิน \"$raw\" ได้';
  }

  @override
  String get skipZeroAmount => 'จำนวนเงินเป็นศูนย์';

  @override
  String get skipUnparseableDebitCreditAmount =>
      'ไม่สามารถแยกวิเคราะห์จำนวนเงินฝั่งเดบิตหรือเครดิตได้';

  @override
  String get skipBothDebitAndCreditNonZero =>
      'คอลัมน์เดบิตและเครดิตมีจำนวนเงินทั้งคู่';

  @override
  String get skipBothDebitAndCreditZero =>
      'คอลัมน์เดบิตและเครดิตเป็นศูนย์ทั้งคู่';

  @override
  String errorBackupCreateFailed(String detail) {
    return 'ไม่สามารถสร้างข้อมูลสำรองได้: $detail';
  }

  @override
  String get errorBackupRestoreFailed =>
      'ไม่สามารถกู้คืนข้อมูลสำรองนี้ได้ - วลีรหัสผ่านไม่ถูกต้อง หรือไม่ใช่ไฟล์สำรองของ Smara';

  @override
  String get validationAmountAccountCategoryRequired =>
      'ต้องระบุจำนวนเงิน บัญชี และหมวดหมู่';

  @override
  String get validationAmountAccountRequired => 'ต้องระบุจำนวนเงินและบัญชี';

  @override
  String get validationSplitLineIncomplete =>
      'ทุกรายการที่แบ่งต้องมีหมวดหมู่และจำนวนเงิน';

  @override
  String get validationSplitSumMismatch =>
      'ผลรวมของรายการที่แบ่งต้องเท่ากับยอดรวมของรายการ';

  @override
  String get validationFromToAmountRequired =>
      'ต้องระบุบัญชีต้นทาง บัญชีปลายทาง และจำนวนเงิน';

  @override
  String get validationAmountArrivedRequired => 'ต้องระบุจำนวนเงินที่ได้รับ';

  @override
  String get validationChooseReceivingAccount => 'เลือกบัญชีที่ได้รับเงิน';

  @override
  String get validationAccountCategoryRequired => 'ต้องระบุบัญชีและหมวดหมู่';

  @override
  String get validationFixFailed => 'ไม่สามารถบันทึกการแก้ไขนี้ได้';

  @override
  String get validationNameRequired => 'ตั้งชื่อบัญชีหลักของคุณ';

  @override
  String get validationStillLoading =>
      'กำลังโหลดอยู่ - โปรดลองอีกครั้งในอีกสักครู่';

  @override
  String get validationSaveAccountNameFailed => 'ไม่สามารถบันทึกชื่อบัญชีได้';

  @override
  String get validationWrongPin => 'รหัส PIN ไม่ถูกต้อง ลองอีกครั้ง';

  @override
  String get validationCategoryMustBeIncomeOrExpense =>
      'หมวดหมู่ต้องเป็นรายรับหรือรายจ่าย';

  @override
  String get validationOnlyExpenseHasMonthlyLimit =>
      'เฉพาะหมวดหมู่รายจ่ายเท่านั้นที่สามารถมีวงเงินรายเดือนได้';

  @override
  String get validationInvalidTemplate => 'แม่แบบไม่ถูกต้อง';

  @override
  String validationGenerateKeyFailed(String detail) {
    return 'ไม่สามารถสร้างกุญแจลงลายเซ็นบนอุปกรณ์นี้ได้: $detail';
  }

  @override
  String validationSaveCurrencyFailed(String detail) {
    return 'ไม่สามารถบันทึกสกุลเงินนี้ได้: $detail';
  }

  @override
  String get validationChooseBackupFile => 'เลือกไฟล์สำรองก่อน';

  @override
  String get validationPassphraseRequired => 'ป้อนวลีรหัสผ่าน';

  @override
  String get validationPinsDoNotMatch => 'รหัส PIN ทั้งสองไม่ตรงกัน';

  @override
  String get validationFeePositiveWithCategory =>
      'ค่าธรรมเนียมการโอนต้องเป็นจำนวนบวกและเลือกหมวดหมู่รายจ่ายไว้';

  @override
  String get validationFeeMustBeLessThanAmount =>
      'ค่าธรรมเนียมต้องน้อยกว่าจำนวนเงินสำหรับการโอนแบบหักค่าธรรมเนียม';

  @override
  String validationTransferSavedFeeFailed(String detail) {
    return 'บันทึกการโอนแล้ว แต่ไม่สามารถบันทึกค่าธรรมเนียมได้: $detail';
  }

  @override
  String get validationEnterValidAmount => 'ป้อนจำนวนเงินที่ถูกต้อง';

  @override
  String get errorBuyQuantityAndPriceMustBePositive =>
      'จำนวนหน่วยที่ซื้อและราคาต่อหน่วยต้องเป็นบวก';

  @override
  String get errorInstrumentArchived => 'ไม่สามารถซื้อตราสารที่ถูกซ่อนไว้ได้';

  @override
  String get errorNonCashCannotIncludeBrokerage =>
      'การได้มาแบบไม่ใช่เงินสดไม่สามารถมีค่านายหน้าได้';

  @override
  String get errorBrokerageRequiresExpenseCategory =>
      'ต้องมีหมวดหมู่รายจ่ายที่ใช้งานอยู่เมื่อมีค่านายหน้า';

  @override
  String get errorSellProceedsMustCoverBrokerage =>
      'เงินที่ได้จากการขายต้องมากกว่าหรือเท่ากับค่านายหน้า';

  @override
  String homeSpentOfLimitThisMonth(String spent, String limit) {
    return '$spent จาก $limit ในเดือนนี้';
  }

  @override
  String get unlockBiometricReason => 'ปลดล็อกบัญชี Smara';

  @override
  String get searchLabel => 'ค้นหา';

  @override
  String get openingBalance => 'ยอดยกมา';

  @override
  String transferToName(String name) {
    return 'โอนเงิน: $name';
  }

  @override
  String get feeForTransfer => 'ค่าธรรมเนียมการโอน';

  @override
  String feeForTransferTo(String name) {
    return 'ค่าธรรมเนียมการโอนไปยัง $name';
  }

  @override
  String couldNotOpenFilePicker(String detail) {
    return 'ไม่สามารถเปิดตัวเลือกไฟล์ได้: $detail';
  }

  @override
  String pleaseSelectFile(String extensions) {
    return 'โปรดเลือกไฟล์ .$extensions';
  }

  @override
  String get currencyCodeIso => 'รหัสสกุลเงิน (ISO 4217 เช่น USD)';

  @override
  String splitCounterpartMore(String name, String count) {
    return '$name และอีก $count รายการ';
  }

  @override
  String get dateLabel => 'วันที่';

  @override
  String get noneSelected => 'ไม่มี';

  @override
  String reviewEntriesBeforeContinuing(String count) {
    return 'ตรวจสอบรายการด้านล่าง (ทั้งหมด $count รายการ) ก่อนดำเนินการต่อ';
  }

  @override
  String youReceived(String amount) {
    return 'คุณได้รับ $amount';
  }

  @override
  String get leaveBlankIfRateUnknown =>
      'เว้นว่างไว้หากยังไม่ทราบอัตราแลกเปลี่ยน';

  @override
  String get recordTradeBlurb =>
      'บันทึกการซื้อขายที่เกิดขึ้นแล้ว แอปนี้ไม่ได้ส่งคำสั่งซื้อขาย';

  @override
  String get feeOnTopBlurb =>
      'เปิด: จำนวนเงินด้านบนคือยอดรวมที่หักจากบัญชีนี้ โดยค่าธรรมเนียมจะถูกหักออกจากยอดนั้น';

  @override
  String get feeBankBlurb =>
      'ค่าคอมมิชชันที่เรียกเก็บล่วงหน้าโดยธนาคารหรือตัวกลางของคุณ';

  @override
  String get validationPinMinLength => 'รหัส PIN ต้องมีอย่างน้อย 4 หลัก';

  @override
  String get restoreBackupBlurb =>
      'การดำเนินการนี้จะแทนที่ข้อมูลทั้งหมดในแอปนี้ด้วยข้อมูลสำรอง — จะไม่มีการรวมข้อมูล เลือกไฟล์สำรองและป้อนวลีรหัสผ่านที่คุณใช้ป้องกันไฟล์นั้น';

  @override
  String get actionReplace => 'แทนที่';

  @override
  String hideAccountBody(String name) {
    return '$name จะไม่สามารถใช้สำหรับรายการใหม่ได้อีกต่อไป';
  }

  @override
  String hideGroupBody(String name) {
    return '$name จะไม่ปรากฏเป็นตัวเลือกเมื่อสร้างหรือย้ายบัญชีอีกต่อไป';
  }

  @override
  String hideCategoryBody(String name) {
    return '$name จะไม่ปรากฏเป็นตัวเลือกเมื่อบันทึกรายการใหม่อีกต่อไป';
  }

  @override
  String get hideInstrumentBody =>
      'ตราสารที่ถูกซ่อนจะยังคงอยู่ในรายการซื้อขายในอดีต คุณยังสามารถบันทึกเงินปันผลให้กับตราสารเหล่านี้ได้';

  @override
  String nameHidden(String name) {
    return '$name (ซ่อนอยู่)';
  }

  @override
  String get noCurrencySet => 'ยังไม่ได้กำหนดสกุลเงิน';

  @override
  String deletePayeeBody(String name) {
    return '$name และค่าเริ่มต้นที่จดจำไว้จะถูกลบ รายการในอดีตจะไม่ได้รับผลกระทบ';
  }

  @override
  String deleteTemplateBody(String name) {
    return '$name จะไม่ปรากฏเป็นรายการครบกำหนดอีกต่อไป รายการในอดีตที่บันทึกไว้แล้วจะไม่ได้รับผลกระทบ';
  }

  @override
  String deleteProfileBody(String name) {
    return 'การจับคู่คอลัมน์ที่บันทึกไว้ \"$name\" จะถูกลบ รายการเดินบัญชีที่นำเข้าไปแล้วด้วยการจับคู่นี้จะไม่ได้รับผลกระทบ';
  }

  @override
  String deleteRuleBody(String keyword) {
    return 'การนำเข้าจะไม่ถูกจัดหมวดหมู่อัตโนมัติด้วย \"$keyword\" อีกต่อไป รายการที่ถูกจัดหมวดหมู่ด้วยกฎนี้ไปแล้วจะไม่ได้รับผลกระทบ';
  }

  @override
  String get firstWeekBlurb =>
      'เพิ่มบัตรเครดิตหรือบัญชีเงินสดตอนนี้ได้หากต้องการ - คุณสามารถเพิ่มบัญชีเพิ่มเติมได้ภายหลังจากเมนูการตั้งค่า';

  @override
  String get deliveredToDestination => 'ส่งถึงปลายทางแล้ว';

  @override
  String deliveredToName(String name) {
    return 'ส่งถึง $name แล้ว';
  }

  @override
  String youReceivedLessThanExpected(String amount, String currency) {
    return 'คุณได้รับ $amount $currency น้อยกว่าที่คาดไว้ - เลือกหมวดหมู่เพื่อครอบคลุมส่วนต่าง';
  }

  @override
  String get dateRangeLabel => 'ช่วงวันที่';

  @override
  String get addTemplate => 'เพิ่มแม่แบบ';

  @override
  String get editTemplate => 'แก้ไขแม่แบบ';

  @override
  String get validationFillTemplateFields =>
      'กรอกทุกช่องด้วยจำนวนเงินและวันที่ที่ถูกต้อง';

  @override
  String get saveCsvExport => 'บันทึกไฟล์ CSV ที่ส่งออก';

  @override
  String get referenceRate => 'อัตราอ้างอิง';

  @override
  String get yourRate => 'อัตราของคุณ';

  @override
  String leaveBlankIfThisWasAccountCurrency(String currency) {
    return 'เว้นว่างไว้หากรายการนี้เป็นสกุลเงิน $currency ซึ่งเป็นสกุลเงินของบัญชีนี้เอง';
  }

  @override
  String get lockUntilOptional => 'ล็อกจนถึง (ไม่บังคับ)';

  @override
  String lockedUntilDate(String date) {
    return 'ล็อกจนถึง $date';
  }

  @override
  String get copiedResearchPrompt =>
      'คัดลอกคำค้นหาแล้ว — ไม่มี URL เบราว์เซอร์ให้ใช้ หรือคุณออฟไลน์อยู่';

  @override
  String get openedFavouriteResearchTool =>
      'เปิดเครื่องมือค้นคว้าที่คุณชื่นชอบแล้ว';

  @override
  String get looksLikeGain => 'ดูเหมือนจะเป็นกำไร';

  @override
  String get looksLikeLoss => 'ดูเหมือนจะเป็นขาดทุน';

  @override
  String get looksLikeBreakEven => 'ดูเหมือนจะเท่าทุน';

  @override
  String sellableQuantity(String name, String qty) {
    return '$name (ขายได้ $qty)';
  }

  @override
  String columnN(String index) {
    return 'คอลัมน์ $index';
  }

  @override
  String get importingLabel => 'กำลังนำเข้า...';

  @override
  String get confirmImport => 'ยืนยันการนำเข้า';

  @override
  String get manageSavedCategoryRules => 'จัดการกฎหมวดหมู่ที่บันทึกไว้';

  @override
  String statementCurrencyMismatch(String currency) {
    return 'สกุลเงินของไฟล์นี้ ($currency) ไม่ตรงกับสกุลเงินของบัญชีที่เลือก';
  }

  @override
  String get categoryRulesTitle => 'กฎหมวดหมู่';

  @override
  String get possibleDuplicate => 'อาจซ้ำกับรายการอื่น';

  @override
  String get unknownCategory => 'หมวดหมู่ที่ไม่ทราบ';

  @override
  String get researchPromptIntro =>
      'ค้นคว้าตราสารที่จดทะเบียนในตลาดหลักทรัพย์นี้สำหรับนักลงทุนรายย่อยในครัวเรือน ระบุผู้ออกตราสาร สรุปข่าวล่าสุดพร้อมวันที่หากทราบ และสรุปความเสี่ยงด้านลบและปัจจัยขับเคลื่อนด้านบวก แยกข้อเท็จจริงออกจากการคาดเดา อย่าให้คำแนะนำซื้อ ขาย หรือถือครอง นี่ไม่ใช่คำแนะนำทางการเงิน';

  @override
  String researchPromptNameLine(String name) {
    return 'ชื่อ: $name';
  }

  @override
  String researchPromptTickerLine(String ticker) {
    return 'สัญลักษณ์หลักทรัพย์: $ticker';
  }

  @override
  String get researchPromptTickerNoneProvided =>
      'สัญลักษณ์หลักทรัพย์: (ไม่ได้ระบุ)';

  @override
  String researchPromptIsinLine(String isin) {
    return 'ISIN: $isin';
  }

  @override
  String get researchPromptIsinNoneProvided => 'ISIN: (ไม่ได้ระบุ)';

  @override
  String get identifyPromptIntro =>
      'I want to add this security to my portfolio tracker. Give me its ISIN, its primary listing exchange and ticker, the trading currency, the exact market-data symbol (for example the Yahoo Finance symbol), and — if it is cross-listed — each venue with its own currency. Facts only, with the source if you can. Do not give buy, sell, or hold advice. This is not financial advice.';

  @override
  String get instrumentLookUp => 'Look up identifiers';

  @override
  String get instrumentLookUpCopied =>
      'Copied an identifier look-up prompt — no browser URL available, or you are offline.';

  @override
  String get instrumentLookUpOpened =>
      'Opened your favourite tool to look up the identifiers.';

  @override
  String get isinInvalid =>
      'This does not look like an ISIN (12 letters/digits starting with a country code).';

  @override
  String get isinCheckDigitWarning =>
      'This ISIN looks mistyped — its check digit does not add up.';

  @override
  String instrumentCurrencyMismatchWithHint(
    String inferred,
    String account,
    String suffix,
  ) {
    return 'Automatic quotes may not match: this looks like a $inferred listing but the account is in $account. For $account quotes, use the $suffix listing.';
  }

  @override
  String instrumentCurrencyMismatch(String inferred, String account) {
    return 'Automatic quotes may not match: this looks like a $inferred listing but the account is in $account.';
  }

  @override
  String get settingsDefaultExchange => 'Default exchange';

  @override
  String get settingsDefaultExchangeSubtitle =>
      'Biases which listing a new instrument resolves to, and supplies its currency. A fixed list — pick the venue you trade on most.';

  @override
  String get confirmListingTitle => 'Confirm the listing';

  @override
  String get confirmListingBlurb =>
      'Pick the listing that matches your holding. Its currency is what automatic quotes will use.';

  @override
  String confirmListingCurrencyLine(String exchange, String currency) {
    return '$exchange · $currency';
  }

  @override
  String get confirmListingSkip => 'Skip — save as typed';

  @override
  String get resolveDeferredSaved =>
      'Saved. The exact market symbol will be resolved on the next price refresh.';

  @override
  String get booksCopyPassphrase => 'วลีรหัสผ่าน';

  @override
  String replaceBooksWarning(String counts) {
    return 'This will replace all entries and the books\' settings on this phone ($counts). It does not merge. Your language and unlock settings stay on this phone.';
  }

  @override
  String get saveCopyFirstAction => 'Save a copy first';

  @override
  String replaceCountEntries(int count) {
    return '$count entries';
  }

  @override
  String replaceCountAccounts(int count) {
    return '$count accounts';
  }

  @override
  String replaceCountCategories(int count) {
    return '$count categories';
  }

  @override
  String replaceCountGroups(int count) {
    return '$count account groups';
  }

  @override
  String replaceCountPayees(int count) {
    return '$count payees';
  }

  @override
  String replaceCountCategoryRules(int count) {
    return '$count category rules';
  }

  @override
  String replaceCountCsvProfiles(int count) {
    return '$count import profiles';
  }

  @override
  String replaceCountRecurringTemplates(int count) {
    return '$count recurring templates';
  }

  @override
  String replaceCountInstruments(int count) {
    return '$count instruments';
  }

  @override
  String get claimsTitle => 'Claims';

  @override
  String get claimsReviewTitle => 'Review claims';

  @override
  String get claimsStatusDraft => 'Draft';

  @override
  String get claimsStatusSubmitted => 'Submitted';

  @override
  String get claimsStatusPartlyApproved => 'Partly approved';

  @override
  String get claimsStatusApproved => 'Approved';

  @override
  String get claimsStatusPaid => 'Paid';

  @override
  String get claimsStatusRejected => 'Rejected';

  @override
  String get claimsApprove => 'Approve';

  @override
  String get claimsApproveDifferent => 'Approve different amount';

  @override
  String get claimsReject => 'Reject';

  @override
  String get claimsReasonRequired => 'A reason is required';

  @override
  String get claimsAdvances => 'Advances';

  @override
  String get claimsAddPerson => 'Add a person';

  @override
  String get claimsRoleApprover => 'Approver';

  @override
  String get claimsRoleClaimant => 'Claimant';

  @override
  String claimsBalanceCompanyOwesYou(String company) {
    return '$company owes you';
  }

  @override
  String claimsBalanceYouOweCompany(String company) {
    return 'You owe $company';
  }

  @override
  String claimsBalanceSettled(String company) {
    return 'Settled with $company';
  }

  @override
  String get claimsReceiptRequired =>
      'A receipt is required for this claim item';

  @override
  String get claimsReceiptPdfTooLarge =>
      'This PDF is larger than 5 MB. Choose a smaller file.';

  @override
  String claimsSpendingHint(String amount, String unit) {
    return 'Hint: at most $amount per $unit';
  }

  @override
  String get claimsNoClaimsYet => 'No claims yet.';

  @override
  String get claimsNoClaimsToReview => 'No claims to review.';

  @override
  String get claimsAdvanceDefault => 'Advance';

  @override
  String claimsItemCount(int count) {
    return '$count item(s)';
  }

  @override
  String get claimsRejectReasonTitle => 'Reject reason';

  @override
  String get claimsApproveDifferentReasonTitle =>
      'Approve different amount reason';

  @override
  String get claimsPersonNameLabel => 'Person name';

  @override
  String get claimsRemovePerson => 'Remove';

  @override
  String claimsRemovePersonTitle(String name) {
    return 'Remove $name?';
  }

  @override
  String claimsRemovePersonWarning(String name, int openClaims) {
    return '$name has $openClaims open Claims and a non-zero owed balance. History and receipts stay in these books.';
  }

  @override
  String claimsRemovePersonWarningOpenOnly(String name, int openClaims) {
    return '$name has $openClaims open Claims. History and receipts stay in these books.';
  }

  @override
  String claimsRemovePersonWarningBalanceOnly(String name) {
    return '$name has a non-zero owed balance. History and receipts stay in these books.';
  }

  @override
  String claimsRemovePersonWarningClean(String name) {
    return 'Remove $name? History and receipts stay in these books.';
  }

  @override
  String get claimsRemovePersonConfirm => 'Remove';
}
