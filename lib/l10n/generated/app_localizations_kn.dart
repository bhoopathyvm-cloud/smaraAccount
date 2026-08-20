// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kannada (`kn`).
class AppLocalizationsKn extends AppLocalizations {
  AppLocalizationsKn([String locale = 'kn']) : super(locale);

  @override
  String get appTitle => 'ಸ್ಮಾರ ಖಾತೆ';

  @override
  String get navHome => 'ಮುಖಪುಟ';

  @override
  String get navRegister => 'ರಿಜಿಸ್ಟರ್';

  @override
  String get navSummary => 'ಸಾರಾಂಶ';

  @override
  String get navAccounts => 'ಖಾತೆಗಳು';

  @override
  String get navCategories => 'ವರ್ಗಗಳು';

  @override
  String get actionCancel => 'ರದ್ದು';

  @override
  String get actionSave => 'ಉಳಿಸಿ';

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
  String get actionAdd => 'ಸೇರಿಸಿ';

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
  String get actionArchive => 'Hide';

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
  String get captureSpent => 'ವೆಚ್ಚ';

  @override
  String get captureReceived => 'Received';

  @override
  String get captureMovedMoney => 'Moved money';

  @override
  String get captureImportStatement => 'Import statement';

  @override
  String get settingsTitle => 'ಸೆಟ್ಟಿಂಗ್‌ಗಳು';

  @override
  String get settingsLanguage => 'ಭಾಷೆ';

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
  String get settingsBackup => 'Backup';

  @override
  String get settingsBackupBlurb =>
      'Save an encrypted copy of your books to a location you choose, or restore from one. This is separate from your recovery phrase or keystore file, which back up your signing key, not your books.';

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
      'Remembered payee names and their default category and account.';

  @override
  String get settingsRecurring => 'Recurring templates';

  @override
  String get settingsManageRecurring => 'Manage recurring templates';

  @override
  String get settingsRecurringBlurb =>
      'Bills or income that repeat monthly, like rent or a paycheck.';

  @override
  String get settingsAbout => 'About';

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
  String get homeThisMonth => 'ಈ ತಿಂಗಳು';

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
  String get keystoreExportFailed =>
      'Could not export the keystore file. You can skip this step.';

  @override
  String get enterPassphraseToProtect =>
      'Enter a passphrase to protect the file.';

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
  String get recoveryPhraseTitle => 'Your recovery phrase';

  @override
  String get recoveryPhraseConfirmTitle => 'Confirm your phrase';

  @override
  String get recoveryPhraseBlurb =>
      'These 24 words are the only way to recover your transaction history if this device is lost. Write them down in order and store them somewhere safe — we cannot show them again.';

  @override
  String get recoveryPhraseWriteDown =>
      'Write these words down in order and store them somewhere safe — nobody else can recover them for you.';

  @override
  String get iveSavedRecoveryPhrase => 'I\'ve saved my recovery phrase';

  @override
  String get confirmPhraseBlurb =>
      'Enter the requested words from the phrase you just saved.';

  @override
  String wordNumber(String n) {
    return 'Word #$n';
  }

  @override
  String get keystoreExportTitle => 'Export keystore file';

  @override
  String get keystoreExportBlurb =>
      'As well as your recovery phrase, you can save an encrypted keystore file. It is another way to restore your signing key, not a backup of your books.';

  @override
  String get keystorePassphrase => 'Passphrase';

  @override
  String get exportKeystoreFile => 'Export keystore file';

  @override
  String get chooseCurrencyTitle => 'Choose your currency';

  @override
  String get chooseCurrencyBlurb =>
      'Every account group (Cash & cash equivalents, Pension & retirement, and the others) will use this currency until you add more groups.';

  @override
  String get currencyBackfillTitle => 'Choose a currency for existing groups';

  @override
  String get currencyBackfillBlurb =>
      'This app now supports multiple currencies. Your existing groups need one currency assigned.';

  @override
  String get firstAccountTitle => 'Name your account';

  @override
  String get firstAccountBlurb =>
      'This is the account already set up for you - give it a name you\'ll recognize.';

  @override
  String get whatsMainAccountCalled => 'What\'s your main account called?';

  @override
  String get restoreTitle => 'Restore signing key';

  @override
  String get restoreBlurb =>
      'This device has existing books, but no matching signing key. Restore from your recovery phrase or keystore file.';

  @override
  String get recoveryPhrase24 => 'Recovery phrase (all 24 words)';

  @override
  String get keystoreFile => 'Keystore file';

  @override
  String get keystoreFileContents => 'Keystore file contents';

  @override
  String get optionalBackupFile => 'Optional backup file';

  @override
  String get iDontHavePhrase =>
      'I don\'t have my recovery phrase or keystore file';

  @override
  String get migrationTitle => 'Migrate to a new key';

  @override
  String get migrationBlurb =>
      'Without your recovery phrase or keystore file, this device\'s signing key cannot be recovered. You can start a new key. Old entries stay visible but are superseded.';

  @override
  String get iConfirmBooksValid => 'I confirm the current books are valid';

  @override
  String get whyWeDontEdit => 'Why we don’t edit old entries';

  @override
  String get whyWeDontEditBody =>
      'When you fix a mistake, we keep the old line and add a new one. The history cannot quietly rewrite itself.';

  @override
  String get lockTitle => 'Unlock';

  @override
  String get lockScreenTitle => 'ಲಾಕ್';

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
      'Choose a passphrase to protect this backup. There is no recovery if you forget it.';

  @override
  String get replaceBooksTitle => 'Replace your local books?';

  @override
  String get replaceBooksBody =>
      'This replaces everything currently in this app with the backup. Close and reopen the app afterwards.';

  @override
  String get chooseBackupFileFirst => 'Choose a backup file first.';

  @override
  String get backupRestored => 'Backup restored';

  @override
  String get backupRestoredBody =>
      'Your books have been restored. Close and reopen the app to continue.';

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
  String get errorGeneric => 'ಏನೋ ತಪ್ಪಾಗಿದೆ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get errorSigningIdentityMismatch =>
      'This recovery phrase or keystore file does not match any signing identity in this database.';

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
  String get errorForeignBackupIdentity =>
      'This backup belongs to a different signing identity than the one on this device.';

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
  String get errorAmountMustBePositive => 'ಮೊತ್ತ ಧನಾತ್ಮಕವಾಗಿರಬೇಕು.';

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
  String get validationWrongKeystorePassphrase =>
      'Wrong passphrase for this keystore file.';

  @override
  String get validationInvalidKeystoreFile =>
      'That doesn\'t look like a valid keystore file.';

  @override
  String get validationRestorePhraseFailed =>
      'Could not restore from that recovery phrase.';

  @override
  String validationGenerateKeyFailed(String detail) {
    return 'Could not generate a signing key on this device: $detail';
  }

  @override
  String validationSaveCurrencyFailed(String detail) {
    return 'Could not save this currency: $detail';
  }

  @override
  String get validationMigrationFailed => 'Migration failed. Please try again.';

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
  String validationConfirmWordMismatch(String n) {
    return 'Word $n doesn\'t match your saved phrase. Check it and try again.';
  }

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
  String get searchLabel => 'ಹುಡುಕಿ';

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
      'This replaces everything currently in this app with the backup — it does not merge. Choose a backup file and enter the passphrase you protected it with.';

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
      'This is the account already set up for you - give it a name you recognize, like your bank.';

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
}
