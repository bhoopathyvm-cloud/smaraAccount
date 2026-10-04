// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Smara Accounting';

  @override
  String get navHome => 'Home';

  @override
  String get navRegister => 'Register';

  @override
  String get navSummary => 'Summary';

  @override
  String get navAccounts => 'Accounts';

  @override
  String get navCategories => 'Categories';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionSave => 'Save';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionDone => 'Done';

  @override
  String get actionContinue => 'Continue';

  @override
  String get actionDismiss => 'Dismiss';

  @override
  String get actionRetry => 'Retry';

  @override
  String get actionSkip => 'Skip';

  @override
  String get actionConfirm => 'Confirm';

  @override
  String get actionAdd => 'Add';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionRename => 'Rename';

  @override
  String get actionHide => 'Hide';

  @override
  String get actionCreate => 'Create';

  @override
  String get actionCloseApp => 'Close app';

  @override
  String get actionUnlock => 'Unlock';

  @override
  String get actionSettle => 'Settle';

  @override
  String get actionFinish => 'Finish';

  @override
  String get actionPreview => 'Preview';

  @override
  String get actionImport => 'Import';

  @override
  String get actionExportCsv => 'Export CSV';

  @override
  String get actionChooseFile => 'Choose file';

  @override
  String get actionRestore => 'Restore';

  @override
  String get actionFix => 'Fix';

  @override
  String get actionBuy => 'Buy';

  @override
  String get actionSell => 'Sell';

  @override
  String get actionDividend => 'Dividend';

  @override
  String get actionRecordBuy => 'Record buy';

  @override
  String get actionRecordSell => 'Record sell';

  @override
  String get actionRecordDividend => 'Record dividend';

  @override
  String get actionPayCard => 'Pay card';

  @override
  String get actionTransfer => 'Transfer';

  @override
  String get actionRecordTransaction => 'Record transaction';

  @override
  String get actionImportStatement => 'Import statement';

  @override
  String get actionClearDates => 'Clear dates';

  @override
  String get actionClearSearch => 'Clear search and filters';

  @override
  String get actionUseBiometrics => 'Use biometrics';

  @override
  String get actionSetPin => 'Set PIN';

  @override
  String get actionChangePin => 'Change PIN';

  @override
  String get actionSaveBackup => 'Save backup';

  @override
  String get actionRestoreBackup => 'Restore backup';

  @override
  String get actionSaveRule => 'Save rule';

  @override
  String get actionConfirmFix => 'Confirm fix';

  @override
  String get captureSpent => 'Spent';

  @override
  String get captureReceived => 'Received';

  @override
  String get captureMovedMoney => 'Moved money';

  @override
  String get captureImportStatement => 'Import statement';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSystem => 'Device language';

  @override
  String get settingsFetchFxRates => 'Fetch reference exchange rates';

  @override
  String get settingsFetchFxRatesSubtitle =>
      'Shows an indicative market rate next to the destination amount on cross-currency transfers, for comparison only - never used to fill in the amount.';

  @override
  String get settingsRateProvider => 'Rate provider';

  @override
  String get settingsFetchMarketPrices => 'Fetch market prices for investments';

  @override
  String get settingsFetchMarketPricesSubtitle =>
      'Looks up last prices for instruments that have a ticker or ISIN, to estimate portfolio value. Never used to record a trade, and never sends how many you hold.';

  @override
  String get settingsMarketPriceProvider => 'Market price provider';

  @override
  String get settingsFavouriteResearchTool => 'Favourite research tool';

  @override
  String get settingsFavouriteResearchToolSubtitle =>
      'Tapping an instrument name on holdings opens this tool in the browser with a research prompt — not an integration, and not advice.';

  @override
  String get settingsBackup => 'Books copy';

  @override
  String get settingsBackupBlurb =>
      'Save an encrypted copy of your books to a place you choose, or restore from one. Restoring replaces the books on this phone — it does not merge. Your language and unlock settings stay on this phone.';

  @override
  String get settingsLock => 'Lock';

  @override
  String get settingsLockBlurb =>
      'Require a PIN, or biometrics where available, to open the app.';

  @override
  String get settingsRequireUnlock => 'Require unlock to open the app';

  @override
  String get settingsLockAfter => 'Lock after';

  @override
  String get settingsLockImmediately => 'Immediately';

  @override
  String get settingsLock1Minute => '1 minute';

  @override
  String get settingsLock5Minutes => '5 minutes';

  @override
  String get settingsLock15Minutes => '15 minutes';

  @override
  String get settingsAllowBiometrics => 'Also allow biometrics';

  @override
  String get settingsHideSnapshot => 'Hide balances in the app switcher';

  @override
  String get settingsHideSnapshotSubtitle =>
      'Obscures this screen when you switch to another app, so it isn\'t visible at a glance in the app switcher.';

  @override
  String get settingsHideSnapshotUnavailable =>
      'Hiding balances in the app switcher isn\'t available on this platform.';

  @override
  String get settingsPayees => 'Payees';

  @override
  String get settingsManagePayees => 'Manage payees';

  @override
  String get settingsPayeesBlurb =>
      'Remembered payee names and their default category and account, suggested by autocomplete when recording a transaction.';

  @override
  String get settingsRecurring => 'Recurring templates';

  @override
  String get settingsManageRecurring => 'Manage recurring templates';

  @override
  String get settingsRecurringBlurb =>
      'Bills or income that repeat monthly, like rent or a paycheck. A due template shows up on Home for you to record with one tap - never posted automatically.';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsPrivacyPolicyOpenFailed =>
      'Could not open the privacy policy in a browser.';

  @override
  String get providerFrankfurter => 'Frankfurter (ECB rates)';

  @override
  String get providerOpenErApi => 'ExchangeRate-API (open.er-api.com)';

  @override
  String get providerStooq => 'Stooq (daily quotes)';

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
  String get systemGroupCashEquivalents => 'Cash & cash equivalents';

  @override
  String get systemGroupPensionRetirement => 'Pension & retirement';

  @override
  String get systemGroupCreditShortTerm => 'Credit & short-term debt';

  @override
  String get systemGroupLoansMortgages => 'Loans & mortgages';

  @override
  String get systemGroupInvestments => 'Investments';

  @override
  String get systemAccountCashBank => 'Cash & Bank';

  @override
  String get systemCategorySalary => 'Salary';

  @override
  String get systemCategoryOtherIncome => 'Other Income';

  @override
  String get systemCategoryGroceries => 'Groceries';

  @override
  String get systemCategoryRentMortgage => 'Rent/Mortgage';

  @override
  String get systemCategoryUtilities => 'Utilities';

  @override
  String get systemCategoryTransport => 'Transport';

  @override
  String get systemCategoryFoodOut => 'Food out';

  @override
  String get systemCategoryPhone => 'Phone';

  @override
  String get systemCategoryHealth => 'Health';

  @override
  String get systemCategoryOtherExpense => 'Other Expense';

  @override
  String get systemDescriptionCsvImport => 'CSV import';

  @override
  String get systemDescriptionOfxImport => 'OFX import';

  @override
  String get homeThisMonth => 'THIS MONTH';

  @override
  String get homeMoneyInTransit => 'MONEY IN TRANSIT';

  @override
  String get homeWhatYouHaveMinusWhatYouOwe =>
      'WHAT YOU HAVE MINUS WHAT YOU OWE';

  @override
  String homeWhatYouHave(String amount, String currency) {
    return 'What you have $amount $currency';
  }

  @override
  String homeNetPosition(String amount, String currency) {
    return '$amount $currency';
  }

  @override
  String homeHaveAndOwe(String haveAmount, String currency, String oweAmount) {
    return 'What you have $haveAmount $currency  •  What you owe $oweAmount $currency';
  }

  @override
  String youSentFrom(String amount, String currency, String name) {
    return 'You sent $amount $currency from $name';
  }

  @override
  String youSentTo(String amount, String currency, String name) {
    return 'You sent $amount $currency to $name';
  }

  @override
  String get hiddenLabel => 'Hidden';

  @override
  String get allAccounts => 'All accounts';

  @override
  String savedToPath(String path) {
    return 'Saved to $path';
  }

  @override
  String get homeTapWhenArrived => 'Tap when you know what arrived';

  @override
  String homeReturnedTo(String name) {
    return 'Returned to $name';
  }

  @override
  String get homeDueToday => 'DUE TODAY';

  @override
  String homeDueLine(String category, String account) {
    return '$category · $account · tap to record';
  }

  @override
  String get homeOverLimit => 'Over limit';

  @override
  String homeSpentOfLimit(String spent, String limit) {
    return '$spent of $limit';
  }

  @override
  String homeRemaining(String amount) {
    return 'Remaining: $amount';
  }

  @override
  String get homeNoAccounts => 'No accounts';

  @override
  String get homeCashRegister => 'Cash register';

  @override
  String get homeMarketEstimate => 'Market estimate';

  @override
  String get registerTitle => 'Register';

  @override
  String get registerSearchHint => 'Description, category, or amount';

  @override
  String get registerNoTransactions => 'No transactions yet';

  @override
  String get registerNoEntries => 'No entries recorded yet.';

  @override
  String get registerSpentOnly => 'Spent only';

  @override
  String get registerReceivedOnly => 'Received only';

  @override
  String get registerAll => 'All';

  @override
  String get registerUnverified => 'Unverified - excluded from totals';

  @override
  String get registerSuperseded =>
      'Superseded by migration - excluded from totals';

  @override
  String get summaryTitle => 'Summary';

  @override
  String get summaryTotalIncome => 'Total income';

  @override
  String get summaryTotalExpense => 'Total expense';

  @override
  String summaryDateRange(String start, String end) {
    return '$start to $end';
  }

  @override
  String get accountsTitle => 'Accounts';

  @override
  String get categoriesTitle => 'Categories';

  @override
  String get accountName => 'Account name';

  @override
  String get createAccount => 'Create account';

  @override
  String get createGroup => 'Create group';

  @override
  String get editGroup => 'Edit group';

  @override
  String get renameAccount => 'Rename account';

  @override
  String get renameCategory => 'Rename category';

  @override
  String get addCategory => 'Add category';

  @override
  String get groupLabel => 'Group';

  @override
  String get kindLabel => 'Kind';

  @override
  String get asset => 'Asset';

  @override
  String get liability => 'Liability';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get thisAccountHoldsInvestments => 'This account holds investments';

  @override
  String get thisAccountHoldsInvestmentsSubtitle =>
      'Cash plus inventory you record with Buy, Sell, and Dividend.';

  @override
  String get thisIsACreditCard => 'This is a credit card';

  @override
  String get openingBalanceOptional => 'Opening balance (optional)';

  @override
  String get currencyIso => 'Currency (ISO 4217)';

  @override
  String get currencyIsoExample => 'Currency (ISO 4217, e.g. USD)';

  @override
  String get hideAccountTitle => 'Hide account from new entries?';

  @override
  String get hideCategoryTitle => 'Hide category from new entries?';

  @override
  String get hideGroupTitle => 'Hide group from new entries?';

  @override
  String get reassignGroup => 'Reassign group';

  @override
  String get transferRemainingBalance => 'Transfer remaining balance';

  @override
  String get monthlyLimit => 'Monthly limit';

  @override
  String get monthlyLimitHint => 'Limit (leave blank to clear)';

  @override
  String get monthlyLimitBlurb =>
      'An optional month-to-date spending guide for this expense category.';

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
  String get manageCategoryRules => 'Manage category rules';

  @override
  String get amount => 'Amount';

  @override
  String get category => 'Category';

  @override
  String get account => 'Account';

  @override
  String get fromAccount => 'From account';

  @override
  String get toAccount => 'To account';

  @override
  String get descriptionOptional => 'Description (optional)';

  @override
  String get alsoRememberPayee => 'Also remember as a payee';

  @override
  String get splitIntoCategories => 'Split into multiple categories';

  @override
  String categoryN(String n) {
    return 'Category $n';
  }

  @override
  String get destinationAmount => 'Destination amount';

  @override
  String get destinationAmountOptional => 'Destination amount (optional)';

  @override
  String get accountCurrencyAmountOptional =>
      'Account-currency amount (optional)';

  @override
  String get transactionCurrencyOptional => 'Transaction currency (optional)';

  @override
  String get feeOptional => 'Fee (optional)';

  @override
  String get feeAmount => 'Fee amount';

  @override
  String get feeCategory => 'Fee category';

  @override
  String get feeDescriptionOptional => 'Fee description (optional)';

  @override
  String get feeDeducted => 'Fee is deducted from the amount above';

  @override
  String get needTwoAccountsToTransfer =>
      'Create at least two active accounts to make a transfer.';

  @override
  String get whatArrivedTitle => 'What arrived?';

  @override
  String get whatArrivedBlurb => 'Tell us what actually arrived.';

  @override
  String get amountThatArrived => 'Amount that arrived';

  @override
  String get feeLossCategory => 'Fee / loss category';

  @override
  String get alreadySettled => 'Already settled.';

  @override
  String get holdingsTitle => 'Holdings';

  @override
  String get holdingsCash => 'Cash';

  @override
  String get holdingsInventory => 'INVENTORY';

  @override
  String holdingsBook(String amount, String currency) {
    return 'Book (cash + cost) $amount $currency';
  }

  @override
  String holdingsMarketEstimate(String amount, String currency) {
    return 'Market estimate $amount $currency';
  }

  @override
  String get holdingsNoHoldings =>
      'No holdings yet. Record a buy to add an instrument.';

  @override
  String get holdingsQuotesBlurb =>
      'Quotes are estimates, not a broker price. This app does not place orders.';

  @override
  String get holdingsTapNameToResearch =>
      'Tap the name to research. Quotes are estimates, not advice.';

  @override
  String get instrument => 'Instrument';

  @override
  String get newInstrument => 'New instrument';

  @override
  String get renameInstrument => 'Rename instrument';

  @override
  String get instrumentActions => 'Instrument actions';

  @override
  String hideInstrumentTitle(String name) {
    return 'Hide $name?';
  }

  @override
  String get tickerOptional => 'Ticker (optional)';

  @override
  String get isinOptional => 'ISIN (optional)';

  @override
  String get quantity => 'Quantity';

  @override
  String get unitPrice => 'Unit price';

  @override
  String get brokerageOptional => 'Brokerage (optional)';

  @override
  String get brokerageExpenseCategory => 'Brokerage expense category';

  @override
  String get incomeCategory => 'Income category';

  @override
  String get gainIncomeCategory => 'Gain income category';

  @override
  String get lossExpenseCategory => 'Loss expense category';

  @override
  String get nonCash => 'Non-cash';

  @override
  String get cash => 'Cash';

  @override
  String get locked => 'Locked';

  @override
  String get lockUntilHint =>
      'Your own note of a restriction, not a broker rule.';

  @override
  String get instrumentKindStock => 'Stock';

  @override
  String get instrumentKindEtf => 'ETF';

  @override
  String get instrumentKindMutualFund => 'Mutual fund';

  @override
  String get instrumentKindBond => 'Bond';

  @override
  String get instrumentKindOther => 'Other';

  @override
  String get quoteUseLive => 'Live price';

  @override
  String get quoteUseCached => 'Cached price';

  @override
  String get quoteUseStale => 'Stale price';

  @override
  String get quoteUseMissing => 'Using cost (no price)';

  @override
  String get quoteUseDisabled => 'Quotes off — using cost/cache';

  @override
  String get quoteUseCurrencyMismatch => 'Using cost (price currency differs)';

  @override
  String unrealizedLabel(String amount, String currency) {
    return 'Unrealized $amount $currency';
  }

  @override
  String holdingsUnitsCost(String qty) {
    return '$qty units · ';
  }

  @override
  String get chooseLanguageTitle => 'Choose your language';

  @override
  String get chooseLanguageBlurb =>
      'Everything in the app will show in this language. You can change it later in Settings.';

  @override
  String get chooseCurrencyTitle => 'Choose your currency';

  @override
  String get chooseCurrencyBlurb =>
      'Every account group (Cash & cash equivalents, Pension & retirement, etc.) uses this one currency for now. You can still add accounts in a different currency later by creating a new group for it.';

  @override
  String get currencyBackfillTitle => 'Choose a currency for existing groups';

  @override
  String get currencyBackfillBlurb =>
      'This app now supports multiple currencies. Your existing accounts and account groups need a currency - since they were all set up before this feature existed, one choice applies to all of them.';

  @override
  String get firstAccountTitle => 'Name your account';

  @override
  String get firstAccountBlurb =>
      'This is the account already set up for you - give it a name you recognize, like your bank. You will record one Spent or Received next.';

  @override
  String get whatsMainAccountCalled => 'What\'s your main account called?';

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
  String settingsBooksSwitcherFallbackName(int number) {
    return 'Books $number';
  }

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
  String get settingsLinkedDevicesJoinCheckCode =>
      'Check code — confirm it matches on the other device';

  @override
  String get settingsLinkedDevicesScanQr => 'Scan join QR';

  @override
  String get settingsLinkedDevicesConfirmCheckCodeTitle => 'Confirm check code';

  @override
  String get settingsLinkedDevicesConfirmCheckCodeBody =>
      'Does this code match the one on the other device?';

  @override
  String get settingsLinkedDevicesCodesMatch => 'Codes match';

  @override
  String get settingsLinkedDevicesCodesDontMatch => 'They don\'t match';

  @override
  String get settingsLinkedDevicesJoinExpired =>
      'This join QR has expired. Ask for a new code.';

  @override
  String get settingsLinkedDevicesJoinReused =>
      'This join QR was already used. Ask for a new code.';

  @override
  String get settingsLinkedDevicesJoinCodeLabel => 'Join code';

  @override
  String settingsLinkedDevicesJoinCodeTimeLeft(int minutes, String seconds) {
    return '$minutes:$seconds left';
  }

  @override
  String get settingsLinkedDevicesEnterCodeInstead => 'Enter code instead';

  @override
  String get settingsLinkedDevicesEnterCodeTitle => 'Enter join code';

  @override
  String get settingsLinkedDevicesEnterCodeHint => 'XXXX-XXXX';

  @override
  String get settingsLinkedDevicesEnterCodeSubmit => 'Find device';

  @override
  String get settingsLinkedDevicesJoinCodeExpired =>
      'This code has expired — ask for a new one';

  @override
  String get settingsLinkedDevicesJoinCodeUsed =>
      'This code was already used. Ask for a new one.';

  @override
  String get settingsLinkedDevicesJoinCodeNotFound =>
      'No device with this code on this Wi-Fi';

  @override
  String get settingsLinkedDevicesJoinCodeTryAgain => 'Try again';

  @override
  String get settingsLinkedDevicesConnectByAddress => 'Connect by address';

  @override
  String get settingsLinkedDevicesConnectByAddressTitle => 'Connect by address';

  @override
  String get settingsLinkedDevicesConnectByAddressBody =>
      'When discovery cannot find a linked device, enter its LAN address and port.';

  @override
  String get settingsLinkedDevicesHost => 'Host';

  @override
  String get settingsLinkedDevicesPort => 'Port';

  @override
  String get settingsLinkedDevicesPeer => 'Device';

  @override
  String get settingsLinkedDevicesSaveAddress => 'Save address';

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
  String get whyWeDontEdit => 'Why we don’t edit old entries';

  @override
  String get whyWeDontEditBody =>
      'When you fix a mistake, we keep the old line and add a correction next to it instead of changing what you already entered. That way your history always shows exactly what happened and when you fixed it — nothing quietly changes behind your back.';

  @override
  String get lockTitle => 'Unlock';

  @override
  String get lockScreenTitle => 'Locked';

  @override
  String get enterPinToContinue => 'Enter your PIN to continue';

  @override
  String get pinLabel => 'PIN';

  @override
  String get setPinTitle => 'Set a PIN';

  @override
  String get currentPin => 'Current PIN';

  @override
  String get newPin => 'New PIN';

  @override
  String get confirmPin => 'Confirm PIN';

  @override
  String get confirmNewPin => 'Confirm new PIN';

  @override
  String get firstWeekTitle => 'Set up your accounts';

  @override
  String get addCashAccount => 'Add a cash account';

  @override
  String get addCreditCard => 'Add a credit card';

  @override
  String get cashAccountName => 'Cash account name';

  @override
  String get cardName => 'Card name';

  @override
  String get paidFromBank => 'Paid from bank';

  @override
  String get paidFromCard => 'Paid from card';

  @override
  String get choosePassphraseTitle =>
      'Choose a passphrase to protect this copy. There is no recovery if you forget it.';

  @override
  String get replaceBooksTitle => 'Replace your local books?';

  @override
  String get replaceBooksBody =>
      'This replaces all entries and the books\' settings on this phone with the copy — it does not merge. Your language and unlock settings stay on this phone. Close and reopen the app afterwards.';

  @override
  String get chooseBackupFileFirst => 'Choose a books copy file first.';

  @override
  String get backupRestored => 'Books restored';

  @override
  String get backupRestoredBody =>
      'Your books have been restored on this phone. Entries you make later on the other device will not appear here. To bring those over later, save a new copy there and restore it here — that replaces this phone\'s books. Close and reopen the app to continue.';

  @override
  String get fixThisEntry => 'Fix this entry';

  @override
  String get fixBlurb =>
      'The old line stays exactly as it was. Confirming adds a reversing line and the corrected one.';

  @override
  String get importStatementTitle => 'Import Statement';

  @override
  String get importOfx => 'Import OFX';

  @override
  String get importOfxQfxFile => 'Import OFX / QFX file';

  @override
  String get importCsvFile => 'Import CSV file';

  @override
  String get whatKindOfStatement => 'What kind of statement file do you have?';

  @override
  String get chooseAccountForFile =>
      'Choose which account this file belongs to.';

  @override
  String get importIntoAccount => 'Import into account';

  @override
  String get useSavedProfile => 'Use a saved profile';

  @override
  String get saveMappingProfile => 'Save this mapping as a profile (optional)';

  @override
  String get renameProfile => 'Rename profile';

  @override
  String get deleteProfileTitle => 'Delete profile?';

  @override
  String get fileHasHeader => 'File has a header row';

  @override
  String get dateColumn => 'Date column';

  @override
  String get dateFormatHint => 'Date format (e.g. dd/MM/yyyy)';

  @override
  String get amountColumn => 'Amount column';

  @override
  String get amountConvention => 'Amount convention';

  @override
  String get signedAmountColumn => 'Signed amount column';

  @override
  String get separateDebitCredit => 'Separate debit / credit columns';

  @override
  String get debitColumn => 'Debit column';

  @override
  String get creditColumn => 'Credit column';

  @override
  String get decimalSeparator => 'Decimal separator (. or ,)';

  @override
  String get descriptionColumns => 'Description column(s)';

  @override
  String get referenceIdColumn => 'Reference id column (optional)';

  @override
  String get skippedRows => 'Skipped rows';

  @override
  String parsedTransactionCount(String count) {
    return '$count transactions parsed';
  }

  @override
  String skippedOrExcludedCount(String count) {
    return '$count skipped or excluded';
  }

  @override
  String postedFailedCount(String posted, String failed) {
    return '$posted posted, $failed failed';
  }

  @override
  String get categoryForAll => 'Category for all';

  @override
  String get saveAsRule => 'Save as a rule?';

  @override
  String get saveAsRuleBlurb =>
      'Future imports whose description contains this keyword will use this category.';

  @override
  String get keyword => 'Keyword';

  @override
  String get noSavedRules =>
      'No saved rules yet. Assign a category to a group of rows to save a rule.';

  @override
  String get deleteRuleTitle => 'Delete rule?';

  @override
  String get editRule => 'Edit rule';

  @override
  String rowsGrouped(String count) {
    return '$count rows';
  }

  @override
  String selectStatementFile(String extensions) {
    return 'Select a $extensions statement file to import';
  }

  @override
  String get payeesTitle => 'Payees';

  @override
  String get addPayee => 'Add payee';

  @override
  String get renamePayee => 'Rename payee';

  @override
  String get deletePayeeTitle => 'Delete payee?';

  @override
  String get noPayeesYet => 'No payees yet';

  @override
  String get recurringTitle => 'Recurring templates';

  @override
  String get noRecurringYet => 'No recurring templates yet';

  @override
  String get deleteTemplateTitle => 'Delete recurring template?';

  @override
  String get dayOfMonth => 'Day of month (1-31)';

  @override
  String get dayOfMonthNote => 'A month with fewer days uses its own last day.';

  @override
  String dayOfMonthLine(String day) {
    return 'Day $day of the month - ';
  }

  @override
  String get name => 'Name';

  @override
  String get none => 'None';

  @override
  String get currency => 'Currency';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorInvalidLedgerBackup =>
      'This file is not a valid Smara backup.';

  @override
  String get errorInvalidLedgerBackupNoIdentity =>
      'This backup has no signing identity - it is not a valid Smara backup.';

  @override
  String get errorInvalidLedgerBackupUnverified =>
      'This backup did not verify as intact books, so it was not restored.';

  @override
  String errorInvalidLedgerBackupUnreadable(String detail) {
    return 'This file could not be opened as a Smara backup: $detail';
  }

  @override
  String get errorAccountNotFinancial => 'That is not a financial account.';

  @override
  String get errorAccountArchived => 'That account is hidden.';

  @override
  String get errorAccountNotArchived => 'That account is not hidden.';

  @override
  String get errorAccountNoPositiveBalanceToCloseOut =>
      'There is no remaining balance to transfer.';

  @override
  String get errorAccountHasNoGroup => 'That account has no group assigned.';

  @override
  String get errorGroupHasNoCurrency => 'That group has no currency set yet.';

  @override
  String get errorGroupNotFound => 'That account group was not found.';

  @override
  String get errorInvestmentAccountsMustBeAssets =>
      'Only asset accounts can be marked as investment accounts.';

  @override
  String get errorCreditCardsMustBeLiabilities =>
      'Only liability accounts can be marked as credit cards.';

  @override
  String get errorOpeningBalanceMustBePositive =>
      'Opening balance must be positive when supplied.';

  @override
  String get errorAccountTypeDoesNotMatchGroup =>
      'That account type does not match the group.';

  @override
  String get errorLastActiveAccount =>
      'Cannot hide the last active financial account.';

  @override
  String get errorCurrencyRequiredToCreateGroup =>
      'Currency is required to create a group.';

  @override
  String get errorSystemGroupCannotBeArchived =>
      'Built-in account groups cannot be hidden.';

  @override
  String get errorGroupAlreadyArchived => 'That group is already hidden.';

  @override
  String get errorCannotArchiveGroupWithAccounts =>
      'Cannot hide a group that still has active accounts.';

  @override
  String get errorSystemGroupNeverArchived =>
      'Built-in account groups are never hidden.';

  @override
  String get errorAccountGroupsCannotBeDeleted =>
      'Account groups cannot be deleted.';

  @override
  String get errorCannotReassignDifferentCurrency =>
      'Cannot move this account to a group with a different currency.';

  @override
  String get errorCannotChangeGroupCurrencyWithAccounts =>
      'Cannot change currency while the group has active accounts.';

  @override
  String get errorAmountMustBePositive => 'Amount must be positive.';

  @override
  String get errorAccountCurrencyAmountMustBePositive =>
      'Account-currency amount must be positive.';

  @override
  String get errorAccountCurrencyAmountNotForSameCurrency =>
      'Account-currency amount is only for a foreign-currency entry.';

  @override
  String get errorSplitNeedsTwoLines =>
      'A split needs at least two category lines.';

  @override
  String get errorSplitLineMustBePositive =>
      'Each split line must be a positive amount.';

  @override
  String get errorSplitLinesMustSumToTotal =>
      'Split lines must add up to the transaction total.';

  @override
  String get errorTransferAmountMustBePositive =>
      'Transfer amount must be positive.';

  @override
  String get errorTransferAccountsMustDiffer =>
      'Source and destination accounts must be different.';

  @override
  String get errorCloseoutRequiresDestinationAmount =>
      'A cross-currency closeout needs a known destination amount.';

  @override
  String get errorDestinationAmountNotForSameCurrency =>
      'Destination amount is only for a cross-currency transfer.';

  @override
  String get errorDestinationAmountMustBePositive =>
      'Destination amount must be positive.';

  @override
  String get errorInvestmentCashExceeded =>
      'Cannot transfer more than this investment account\'s cash.';

  @override
  String get errorCannotReverseUnsettledProvisional =>
      'Settle this pending transfer instead of reversing it.';

  @override
  String get errorAlreadyReversed =>
      'This entry has already been corrected. The original line stays as it is.';

  @override
  String get errorNotActiveExpenseCategory =>
      'Choose an active expense category.';

  @override
  String get errorNotActiveIncomeCategory =>
      'Choose an active income category.';

  @override
  String get errorSettledAmountMustNotBeNegative =>
      'Amount that arrived cannot be negative.';

  @override
  String get errorPendingTransferNotFound =>
      'That pending transfer was not found.';

  @override
  String get errorPendingTransferAlreadySettled =>
      'That pending transfer is already settled.';

  @override
  String get errorSettledToMustBeSourceOrDestination =>
      'Choose the original source or destination account.';

  @override
  String get errorFeeCategoryOnlyWhenReturningToSource =>
      'A fee category is only used when money is returned to the source account.';

  @override
  String get errorSettledAmountMustBePositiveForDelivery =>
      'Enter a positive amount for what arrived.';

  @override
  String get errorSettledAmountExceedsProvisional =>
      'That amount is more than was sent.';

  @override
  String get errorInstrumentNotFound => 'That instrument was not found.';

  @override
  String get errorIncomeRequiredForNonCash =>
      'An active income category is required for a non-cash acquisition.';

  @override
  String get errorInsufficientCash =>
      'Not enough cash in this investment account for that buy.';

  @override
  String get errorSellQuantityAndPriceMustBePositive =>
      'Sell quantity and unit price must be positive.';

  @override
  String errorLockedUntil(String date) {
    return 'Cannot sell: some units are locked until $date.';
  }

  @override
  String get errorInsufficientQuantity =>
      'Cannot sell more than you currently hold unlocked.';

  @override
  String get errorIncomeRequiredForGain =>
      'An active income category is required for a realized gain.';

  @override
  String get errorExpenseRequiredForLoss =>
      'An active expense category is required for a realized loss.';

  @override
  String errorBrokerageFailedAfterBuy(String detail) {
    return 'Buy posted, but brokerage fee failed: $detail';
  }

  @override
  String errorBrokerageFailedAfterSell(String detail) {
    return 'Sell posted, but brokerage fee failed: $detail';
  }

  @override
  String get errorDividendMustBePositive => 'Dividend amount must be positive.';

  @override
  String get errorNotInvestmentAccount => 'That is not an investment account.';

  @override
  String get errorNoInventoryCompanion =>
      'This investment account is missing its inventory companion.';

  @override
  String errorInvestmentReversalBlocked(String sells) {
    return 'Cannot reverse this buy: later sell(s) depend on its units. Reverse dependent sell(s) first: $sells.';
  }

  @override
  String get errorMonthlyLimitMustBePositive =>
      'Monthly limit must be positive.';

  @override
  String get errorTemplateAmountMustBePositive =>
      'Template amount must be positive.';

  @override
  String get errorOfxUnrecognized => 'Could not recognize this file as OFX.';

  @override
  String get errorCsvEmpty => 'The selected file is empty.';

  @override
  String get errorCsvUnreadable => 'Could not read this file as CSV.';

  @override
  String get errorCsvNoRows => 'The selected file has no rows.';

  @override
  String get skipMissingDate => 'Missing date.';

  @override
  String skipUnparseableDate(String raw, String pattern) {
    return 'Could not parse date \"$raw\" with pattern \"$pattern\".';
  }

  @override
  String get skipOfxMissingOrInvalidDate =>
      'Missing or invalid transaction date.';

  @override
  String skipOfxUnparseableDate(String raw) {
    return 'Could not parse transaction date \"$raw\".';
  }

  @override
  String get skipMissingAmount => 'Missing amount.';

  @override
  String skipUnparseableAmount(String raw) {
    return 'Could not parse amount \"$raw\".';
  }

  @override
  String get skipZeroAmount => 'Amount is zero.';

  @override
  String get skipUnparseableDebitCreditAmount =>
      'Could not parse the debit or credit amount.';

  @override
  String get skipBothDebitAndCreditNonZero =>
      'Both debit and credit columns have an amount.';

  @override
  String get skipBothDebitAndCreditZero =>
      'Both debit and credit columns are zero.';

  @override
  String errorBackupCreateFailed(String detail) {
    return 'Could not create the backup: $detail';
  }

  @override
  String get errorBackupRestoreFailed =>
      'Could not restore this backup - wrong passphrase, or not a Smara backup file.';

  @override
  String get validationAmountAccountCategoryRequired =>
      'Amount, account, and category are required.';

  @override
  String get validationAmountAccountRequired =>
      'Amount and account are required.';

  @override
  String get validationSplitLineIncomplete =>
      'Every split line needs a category and an amount.';

  @override
  String get validationSplitSumMismatch =>
      'Split lines must add up to the transaction total.';

  @override
  String get validationFromToAmountRequired =>
      'From account, to account, and amount are required.';

  @override
  String get validationAmountArrivedRequired =>
      'Amount that arrived is required.';

  @override
  String get validationChooseReceivingAccount =>
      'Choose which account received the funds.';

  @override
  String get validationAccountCategoryRequired =>
      'Account and category are required.';

  @override
  String get validationFixFailed => 'Could not save this fix.';

  @override
  String get validationNameRequired => 'Name your main account.';

  @override
  String get validationStillLoading => 'Still loading - try again in a moment.';

  @override
  String get validationSaveAccountNameFailed =>
      'Could not save the account name.';

  @override
  String get validationWrongPin => 'Wrong PIN. Try again.';

  @override
  String get validationCategoryMustBeIncomeOrExpense =>
      'Category must be Income or Expense.';

  @override
  String get validationOnlyExpenseHasMonthlyLimit =>
      'Only an Expense category can have a monthly limit.';

  @override
  String get validationInvalidTemplate => 'Invalid template.';

  @override
  String validationGenerateKeyFailed(String detail) {
    return 'Could not generate a signing key on this device: $detail';
  }

  @override
  String validationSaveCurrencyFailed(String detail) {
    return 'Could not save this currency: $detail';
  }

  @override
  String get validationChooseBackupFile => 'Choose a backup file first.';

  @override
  String get validationPassphraseRequired => 'Enter a passphrase.';

  @override
  String get validationPinsDoNotMatch => 'The two PINs do not match.';

  @override
  String get validationFeePositiveWithCategory =>
      'A transfer fee must be a positive amount with an expense category selected.';

  @override
  String get validationFeeMustBeLessThanAmount =>
      'The fee must be less than the amount for a deducted-fee transfer.';

  @override
  String validationTransferSavedFeeFailed(String detail) {
    return 'Transfer saved, but the fee could not be recorded: $detail';
  }

  @override
  String get validationEnterValidAmount => 'Enter a valid amount.';

  @override
  String get errorBuyQuantityAndPriceMustBePositive =>
      'Buy quantity and unit price must be positive.';

  @override
  String get errorInstrumentArchived => 'Cannot buy an archived instrument.';

  @override
  String get errorNonCashCannotIncludeBrokerage =>
      'Non-cash acquisitions cannot include brokerage.';

  @override
  String get errorBrokerageRequiresExpenseCategory =>
      'An active expense category is required when brokerage is positive.';

  @override
  String get errorSellProceedsMustCoverBrokerage =>
      'Sell proceeds must be at least the brokerage amount.';

  @override
  String homeSpentOfLimitThisMonth(String spent, String limit) {
    return '$spent of $limit this month';
  }

  @override
  String get unlockBiometricReason => 'Unlock Smara Account';

  @override
  String get searchLabel => 'Search';

  @override
  String get openingBalance => 'Opening balance';

  @override
  String transferToName(String name) {
    return 'Transfer: $name';
  }

  @override
  String get feeForTransfer => 'Fee for transfer';

  @override
  String feeForTransferTo(String name) {
    return 'Fee for transfer to $name';
  }

  @override
  String couldNotOpenFilePicker(String detail) {
    return 'Could not open the file picker: $detail';
  }

  @override
  String pleaseSelectFile(String extensions) {
    return 'Please select a .$extensions file';
  }

  @override
  String get currencyCodeIso => 'Currency code (ISO 4217, e.g. USD)';

  @override
  String splitCounterpartMore(String name, String count) {
    return '$name +$count more';
  }

  @override
  String get dateLabel => 'Date';

  @override
  String get noneSelected => 'None';

  @override
  String reviewEntriesBeforeContinuing(String count) {
    return 'Review the entries below ($count total) before continuing.';
  }

  @override
  String youReceived(String amount) {
    return 'You received $amount';
  }

  @override
  String get leaveBlankIfRateUnknown =>
      'Leave blank if the exchange rate isn\'t known yet.';

  @override
  String get recordTradeBlurb =>
      'Record a trade that already happened. This app does not place orders.';

  @override
  String get feeOnTopBlurb =>
      'On: the amount above is the total taken from this account; the fee comes out of it.';

  @override
  String get feeBankBlurb =>
      'An upfront commission charged by your bank or an intermediary.';

  @override
  String get validationPinMinLength => 'PIN must be at least 4 digits.';

  @override
  String get restoreBackupBlurb =>
      'This replaces the books and the books\' settings on this phone with the copy — it does not merge. Your language and unlock settings stay on this phone. Choose a copy file and enter the passphrase you protected it with.';

  @override
  String get actionReplace => 'Replace';

  @override
  String hideAccountBody(String name) {
    return '$name will no longer be available for new transactions.';
  }

  @override
  String hideGroupBody(String name) {
    return '$name will no longer be offered when creating or reassigning accounts.';
  }

  @override
  String hideCategoryBody(String name) {
    return '$name will no longer be offered when recording new transactions.';
  }

  @override
  String get hideInstrumentBody =>
      'Hidden instruments stay on past buys and sells. You can still record a dividend for them.';

  @override
  String nameHidden(String name) {
    return '$name (hidden)';
  }

  @override
  String get noCurrencySet => 'No currency set';

  @override
  String deletePayeeBody(String name) {
    return '$name and its remembered defaults will be removed. Past transactions are unaffected.';
  }

  @override
  String deleteTemplateBody(String name) {
    return '$name will no longer be offered as due. Past transactions it already recorded are unaffected.';
  }

  @override
  String deleteProfileBody(String name) {
    return 'The saved column mapping \"$name\" will be deleted. Statements already imported with it are unaffected.';
  }

  @override
  String deleteRuleBody(String keyword) {
    return 'Imports will no longer be auto-categorized by \"$keyword\". Transactions already categorized using this rule are unaffected.';
  }

  @override
  String get firstWeekBlurb =>
      'Optionally add a credit card or a cash account now - you can always add more accounts later from Settings.';

  @override
  String get deliveredToDestination => 'Delivered to destination';

  @override
  String deliveredToName(String name) {
    return 'Delivered to $name';
  }

  @override
  String youReceivedLessThanExpected(String amount, String currency) {
    return 'You received $amount $currency less than expected - choose a category to cover the difference.';
  }

  @override
  String get dateRangeLabel => 'Date range';

  @override
  String get addTemplate => 'Add template';

  @override
  String get editTemplate => 'Edit template';

  @override
  String get validationFillTemplateFields =>
      'Fill in every field with a valid amount and day.';

  @override
  String get saveCsvExport => 'Save CSV export';

  @override
  String get referenceRate => 'Reference rate';

  @override
  String get yourRate => 'Your rate';

  @override
  String leaveBlankIfThisWasAccountCurrency(String currency) {
    return 'Leave blank if this was in $currency, the account\'s own currency.';
  }

  @override
  String get lockUntilOptional => 'Lock until (optional)';

  @override
  String lockedUntilDate(String date) {
    return 'Locked until $date';
  }

  @override
  String get copiedResearchPrompt =>
      'Copied a research prompt — no browser URL available, or you are offline.';

  @override
  String get openedFavouriteResearchTool =>
      'Opened your favourite research tool.';

  @override
  String get looksLikeGain => 'This looks like a gain';

  @override
  String get looksLikeLoss => 'This looks like a loss';

  @override
  String get looksLikeBreakEven => 'This looks like break-even';

  @override
  String sellableQuantity(String name, String qty) {
    return '$name ($qty sellable)';
  }

  @override
  String columnN(String index) {
    return 'Column $index';
  }

  @override
  String get importingLabel => 'Importing...';

  @override
  String get confirmImport => 'Confirm import';

  @override
  String get manageSavedCategoryRules => 'Manage Saved Category Rules';

  @override
  String statementCurrencyMismatch(String currency) {
    return 'This file\'s currency ($currency) doesn\'t match the selected account\'s currency.';
  }

  @override
  String get categoryRulesTitle => 'Category rules';

  @override
  String get possibleDuplicate => 'possible duplicate';

  @override
  String get unknownCategory => 'Unknown category';

  @override
  String get researchPromptIntro =>
      'Research this publicly listed instrument for a household investor. Identify the issuer, summarize recent news with dates if known, and outline downside risks and upside drivers. Separate facts from speculation. Do not give buy, sell, or hold advice. This is not financial advice.';

  @override
  String researchPromptNameLine(String name) {
    return 'Name: $name';
  }

  @override
  String researchPromptTickerLine(String ticker) {
    return 'Ticker: $ticker';
  }

  @override
  String get researchPromptTickerNoneProvided => 'Ticker: (none provided)';

  @override
  String researchPromptIsinLine(String isin) {
    return 'ISIN: $isin';
  }

  @override
  String get researchPromptIsinNoneProvided => 'ISIN: (none provided)';

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
  String get booksCopyPassphrase => 'Passphrase';

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
  String get claimsPersonalLimitsTitle => 'Claim limits';

  @override
  String claimsPersonalLimitsTitleFor(String name) {
    return 'Claim limits for $name';
  }

  @override
  String get claimsMyLimitsTitle => 'My claim limits';

  @override
  String get claimsMyLimits => 'My limits';

  @override
  String get claimsPersonalLimitsHeading => 'Your personal limits';

  @override
  String get claimsCompanyLimitsHeading => 'Company limits';

  @override
  String get claimsBalancesHeading => 'Balances to settle';

  @override
  String claimsPayBalance(String amount) {
    return 'Pay $amount';
  }

  @override
  String get claimsRecordPayment => 'Record payment';

  @override
  String claimsAboveLimit(String limit) {
    return 'Above the $limit limit';
  }

  @override
  String get claimsNoPersonalLimits => 'No personal limits set.';

  @override
  String get claimsClearPersonalLimit => 'Clear limit';

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

  @override
  String get claimsEditorTitle => 'Edit claim';

  @override
  String get claimsSubmit => 'Submit';

  @override
  String get claimsAddItem => 'Add item';

  @override
  String get claimsEditItem => 'Edit item';

  @override
  String get claimsNoItemsYet => 'Add at least one item before submitting.';

  @override
  String get claimsNoAllowlistedCategories =>
      'No expense categories are allowed for claims yet.';

  @override
  String get claimsCategoryLabel => 'Category';

  @override
  String get claimsExpenseDateLabel => 'Expense date';

  @override
  String get claimsPaidAmountLabel => 'Amount paid';

  @override
  String get claimsPaidCurrencyLabel => 'Currency paid';

  @override
  String get claimsRateOptionalLabel => 'Rate (optional)';

  @override
  String claimsCompanyAmountLabel(String currency) {
    return 'Amount in $currency';
  }

  @override
  String get claimsDescriptionLabel => 'Description';

  @override
  String get claimsAttachCamera => 'Take photo';

  @override
  String get claimsAttachGallery => 'Choose photo';

  @override
  String get claimsAttachPdf => 'Choose PDF';

  @override
  String claimsReceiptAttached(String fileName) {
    return 'Receipt: $fileName';
  }

  @override
  String get claimsReceiptRequiredHint =>
      'A receipt is required for this amount.';

  @override
  String get claimsReceiptPermissionSentence =>
      'To attach a receipt photo, Smara needs access to your camera or photo library. Photos stay in these books on your devices.';

  @override
  String claimsReviewClaimHeading(String status) {
    return 'Claim · $status';
  }

  @override
  String get linkedDevicesMyDevicesHeading => 'My devices';

  @override
  String get linkedDevicesMyDevicesHelp =>
      'Your own phones and computers. They share the full books.';

  @override
  String get linkedDevicesPeopleHeading => 'People';

  @override
  String get linkedDevicesPeopleHelp =>
      'Others who use these books, such as employees who send expense claims.';

  @override
  String get linkedDevicesJoinSyncHeading => 'Join or sync';

  @override
  String get linkedDevicesJoinSyncHelp =>
      'Sync now brings every linked device on this Wi-Fi up to date. To join books from another device, scan the QR code it shows.';

  @override
  String get linkedDevicesMoreWays => 'More ways to connect';

  @override
  String linkedDevicesThisDevice(String name) {
    return '$name (this device)';
  }

  @override
  String get linkedDevicesRoleOwner => 'Owner – full books';

  @override
  String get linkedDevicesRoleBookkeeper => 'Bookkeeper';

  @override
  String get linkedDevicesRoleApprover => 'Approver – reviews and pays claims';

  @override
  String get linkedDevicesRoleEmployee => 'Employee – sends expense claims';

  @override
  String get linkedDevicesRoleEmployeeHelp =>
      'Sees only their own claims. Sends expenses for you to approve and pay back.';

  @override
  String get linkedDevicesRoleApproverHelp =>
      'Reviews, approves and pays everyone\'s claims, and can keep the books.';

  @override
  String get linkedDevicesNameTitle => 'Name this device';

  @override
  String get linkedDevicesNameHelp =>
      'Your other devices and people show this name, so everyone can tell the devices apart.';

  @override
  String get linkedDevicesNameLabel => 'Device name';

  @override
  String get linkedDevicesDefaultNameIphone => 'My iPhone';

  @override
  String get linkedDevicesDefaultNameIpad => 'My iPad';

  @override
  String get linkedDevicesDefaultNameMac => 'My Mac';

  @override
  String get linkedDevicesDefaultNameAndroidPhone => 'My Android phone';

  @override
  String get linkedDevicesDefaultNameAndroidTablet => 'My Android tablet';

  @override
  String get linkedDevicesDefaultNameWindows => 'My Windows PC';

  @override
  String get linkedDevicesDefaultNameLinux => 'My Linux PC';

  @override
  String get settingsBooksSwitcherRenameTitle => 'Rename books';

  @override
  String get settingsBooksSwitcherRenameHelp =>
      'Only this device uses this name. Pick one you will recognise, like “Office” or “Home”.';
}
