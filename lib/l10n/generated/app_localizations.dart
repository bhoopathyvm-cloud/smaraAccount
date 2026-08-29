import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_as.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_brx.dart';
import 'app_localizations_de.dart';
import 'app_localizations_doi.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_hu.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_kn.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_kok.dart';
import 'app_localizations_ks.dart';
import 'app_localizations_mai.dart';
import 'app_localizations_ml.dart';
import 'app_localizations_mni.dart';
import 'app_localizations_mr.dart';
import 'app_localizations_ms.dart';
import 'app_localizations_ne.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_or.dart';
import 'app_localizations_pa.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ro.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_sa.dart';
import 'app_localizations_sat.dart';
import 'app_localizations_sd.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';
import 'app_localizations_th.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_uk.dart';
import 'app_localizations_ur.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

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
    Locale('as'),
    Locale('bn'),
    Locale('brx'),
    Locale('de'),
    Locale('doi'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('gu'),
    Locale('hi'),
    Locale('hu'),
    Locale('id'),
    Locale('it'),
    Locale('ja'),
    Locale('kn'),
    Locale('ko'),
    Locale('kok'),
    Locale('ks'),
    Locale('mai'),
    Locale('ml'),
    Locale('mni'),
    Locale('mr'),
    Locale('ms'),
    Locale('ne'),
    Locale('nl'),
    Locale('or'),
    Locale('pa'),
    Locale('pl'),
    Locale('pt'),
    Locale('ro'),
    Locale('ru'),
    Locale('sa'),
    Locale('sat'),
    Locale('sd'),
    Locale('ta'),
    Locale('te'),
    Locale('th'),
    Locale('tr'),
    Locale('uk'),
    Locale('ur'),
    Locale('vi'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Smara Accounting'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navRegister.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get navRegister;

  /// No description provided for @navSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get navSummary;

  /// No description provided for @navAccounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get navAccounts;

  /// No description provided for @navCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get navCategories;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get actionDone;

  /// No description provided for @actionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get actionContinue;

  /// No description provided for @actionDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get actionDismiss;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get actionRetry;

  /// No description provided for @actionSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get actionSkip;

  /// No description provided for @actionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get actionConfirm;

  /// No description provided for @actionAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get actionAdd;

  /// No description provided for @actionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// No description provided for @actionRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get actionRename;

  /// No description provided for @actionHide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get actionHide;

  /// No description provided for @actionCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get actionCreate;

  /// No description provided for @actionCloseApp.
  ///
  /// In en, this message translates to:
  /// **'Close app'**
  String get actionCloseApp;

  /// No description provided for @actionUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get actionUnlock;

  /// No description provided for @actionSettle.
  ///
  /// In en, this message translates to:
  /// **'Settle'**
  String get actionSettle;

  /// No description provided for @actionFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get actionFinish;

  /// No description provided for @actionPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get actionPreview;

  /// No description provided for @actionImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get actionImport;

  /// No description provided for @actionExportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get actionExportCsv;

  /// No description provided for @actionChooseFile.
  ///
  /// In en, this message translates to:
  /// **'Choose file'**
  String get actionChooseFile;

  /// No description provided for @actionRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get actionRestore;

  /// No description provided for @actionFix.
  ///
  /// In en, this message translates to:
  /// **'Fix'**
  String get actionFix;

  /// No description provided for @actionBuy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get actionBuy;

  /// No description provided for @actionSell.
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get actionSell;

  /// No description provided for @actionDividend.
  ///
  /// In en, this message translates to:
  /// **'Dividend'**
  String get actionDividend;

  /// No description provided for @actionRecordBuy.
  ///
  /// In en, this message translates to:
  /// **'Record buy'**
  String get actionRecordBuy;

  /// No description provided for @actionRecordSell.
  ///
  /// In en, this message translates to:
  /// **'Record sell'**
  String get actionRecordSell;

  /// No description provided for @actionRecordDividend.
  ///
  /// In en, this message translates to:
  /// **'Record dividend'**
  String get actionRecordDividend;

  /// No description provided for @actionPayCard.
  ///
  /// In en, this message translates to:
  /// **'Pay card'**
  String get actionPayCard;

  /// No description provided for @actionTransfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get actionTransfer;

  /// No description provided for @actionRecordTransaction.
  ///
  /// In en, this message translates to:
  /// **'Record transaction'**
  String get actionRecordTransaction;

  /// No description provided for @actionImportStatement.
  ///
  /// In en, this message translates to:
  /// **'Import statement'**
  String get actionImportStatement;

  /// No description provided for @actionClearDates.
  ///
  /// In en, this message translates to:
  /// **'Clear dates'**
  String get actionClearDates;

  /// No description provided for @actionClearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search and filters'**
  String get actionClearSearch;

  /// No description provided for @actionUseBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Use biometrics'**
  String get actionUseBiometrics;

  /// No description provided for @actionSetPin.
  ///
  /// In en, this message translates to:
  /// **'Set PIN'**
  String get actionSetPin;

  /// No description provided for @actionChangePin.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get actionChangePin;

  /// No description provided for @actionSaveBackup.
  ///
  /// In en, this message translates to:
  /// **'Save backup'**
  String get actionSaveBackup;

  /// No description provided for @actionRestoreBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore backup'**
  String get actionRestoreBackup;

  /// No description provided for @actionSaveRule.
  ///
  /// In en, this message translates to:
  /// **'Save rule'**
  String get actionSaveRule;

  /// No description provided for @actionConfirmFix.
  ///
  /// In en, this message translates to:
  /// **'Confirm fix'**
  String get actionConfirmFix;

  /// No description provided for @captureSpent.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get captureSpent;

  /// No description provided for @captureReceived.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get captureReceived;

  /// No description provided for @captureMovedMoney.
  ///
  /// In en, this message translates to:
  /// **'Moved money'**
  String get captureMovedMoney;

  /// No description provided for @captureImportStatement.
  ///
  /// In en, this message translates to:
  /// **'Import statement'**
  String get captureImportStatement;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'Device language'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsFetchFxRates.
  ///
  /// In en, this message translates to:
  /// **'Fetch reference exchange rates'**
  String get settingsFetchFxRates;

  /// No description provided for @settingsFetchFxRatesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Shows an indicative market rate next to the destination amount on cross-currency transfers, for comparison only - never used to fill in the amount.'**
  String get settingsFetchFxRatesSubtitle;

  /// No description provided for @settingsRateProvider.
  ///
  /// In en, this message translates to:
  /// **'Rate provider'**
  String get settingsRateProvider;

  /// No description provided for @settingsFetchMarketPrices.
  ///
  /// In en, this message translates to:
  /// **'Fetch market prices for investments'**
  String get settingsFetchMarketPrices;

  /// No description provided for @settingsFetchMarketPricesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Looks up last prices for instruments that have a ticker or ISIN, to estimate portfolio value. Never used to record a trade, and never sends how many you hold.'**
  String get settingsFetchMarketPricesSubtitle;

  /// No description provided for @settingsMarketPriceProvider.
  ///
  /// In en, this message translates to:
  /// **'Market price provider'**
  String get settingsMarketPriceProvider;

  /// No description provided for @settingsFavouriteResearchTool.
  ///
  /// In en, this message translates to:
  /// **'Favourite research tool'**
  String get settingsFavouriteResearchTool;

  /// No description provided for @settingsFavouriteResearchToolSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tapping an instrument name on holdings opens this tool in the browser with a research prompt — not an integration, and not advice.'**
  String get settingsFavouriteResearchToolSubtitle;

  /// No description provided for @settingsBackup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get settingsBackup;

  /// No description provided for @settingsBackupBlurb.
  ///
  /// In en, this message translates to:
  /// **'Save an encrypted copy of your books to a location you choose, or restore from one. This is separate from your recovery phrase or keystore file, which back up your signing key, not your books.'**
  String get settingsBackupBlurb;

  /// No description provided for @settingsLock.
  ///
  /// In en, this message translates to:
  /// **'Lock'**
  String get settingsLock;

  /// No description provided for @settingsLockBlurb.
  ///
  /// In en, this message translates to:
  /// **'Require a PIN, or biometrics where available, to open the app.'**
  String get settingsLockBlurb;

  /// No description provided for @settingsRequireUnlock.
  ///
  /// In en, this message translates to:
  /// **'Require unlock to open the app'**
  String get settingsRequireUnlock;

  /// No description provided for @settingsLockAfter.
  ///
  /// In en, this message translates to:
  /// **'Lock after'**
  String get settingsLockAfter;

  /// No description provided for @settingsLockImmediately.
  ///
  /// In en, this message translates to:
  /// **'Immediately'**
  String get settingsLockImmediately;

  /// No description provided for @settingsLock1Minute.
  ///
  /// In en, this message translates to:
  /// **'1 minute'**
  String get settingsLock1Minute;

  /// No description provided for @settingsLock5Minutes.
  ///
  /// In en, this message translates to:
  /// **'5 minutes'**
  String get settingsLock5Minutes;

  /// No description provided for @settingsLock15Minutes.
  ///
  /// In en, this message translates to:
  /// **'15 minutes'**
  String get settingsLock15Minutes;

  /// No description provided for @settingsAllowBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Also allow biometrics'**
  String get settingsAllowBiometrics;

  /// No description provided for @settingsHideSnapshot.
  ///
  /// In en, this message translates to:
  /// **'Hide balances in the app switcher'**
  String get settingsHideSnapshot;

  /// No description provided for @settingsHideSnapshotSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Obscures this screen when you switch to another app, so it isn\'\'t visible at a glance in the app switcher.'**
  String get settingsHideSnapshotSubtitle;

  /// No description provided for @settingsHideSnapshotUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Hiding balances in the app switcher isn\'\'t available on this platform.'**
  String get settingsHideSnapshotUnavailable;

  /// No description provided for @settingsPayees.
  ///
  /// In en, this message translates to:
  /// **'Payees'**
  String get settingsPayees;

  /// No description provided for @settingsManagePayees.
  ///
  /// In en, this message translates to:
  /// **'Manage payees'**
  String get settingsManagePayees;

  /// No description provided for @settingsPayeesBlurb.
  ///
  /// In en, this message translates to:
  /// **'Remembered payee names and their default category and account, suggested by autocomplete when recording a transaction.'**
  String get settingsPayeesBlurb;

  /// No description provided for @settingsRecurring.
  ///
  /// In en, this message translates to:
  /// **'Recurring templates'**
  String get settingsRecurring;

  /// No description provided for @settingsManageRecurring.
  ///
  /// In en, this message translates to:
  /// **'Manage recurring templates'**
  String get settingsManageRecurring;

  /// No description provided for @settingsRecurringBlurb.
  ///
  /// In en, this message translates to:
  /// **'Bills or income that repeat monthly, like rent or a paycheck. A due template shows up on Home for you to record with one tap - never posted automatically.'**
  String get settingsRecurringBlurb;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @providerFrankfurter.
  ///
  /// In en, this message translates to:
  /// **'Frankfurter (ECB rates)'**
  String get providerFrankfurter;

  /// No description provided for @providerOpenErApi.
  ///
  /// In en, this message translates to:
  /// **'ExchangeRate-API (open.er-api.com)'**
  String get providerOpenErApi;

  /// No description provided for @providerStooq.
  ///
  /// In en, this message translates to:
  /// **'Stooq (daily quotes)'**
  String get providerStooq;

  /// No description provided for @providerYahooFinance.
  ///
  /// In en, this message translates to:
  /// **'Yahoo Finance (chart API)'**
  String get providerYahooFinance;

  /// No description provided for @researchChatGpt.
  ///
  /// In en, this message translates to:
  /// **'ChatGPT'**
  String get researchChatGpt;

  /// No description provided for @researchClaude.
  ///
  /// In en, this message translates to:
  /// **'Claude'**
  String get researchClaude;

  /// No description provided for @researchGemini.
  ///
  /// In en, this message translates to:
  /// **'Gemini'**
  String get researchGemini;

  /// No description provided for @researchMetaAi.
  ///
  /// In en, this message translates to:
  /// **'Meta AI'**
  String get researchMetaAi;

  /// No description provided for @systemGroupCashEquivalents.
  ///
  /// In en, this message translates to:
  /// **'Cash & cash equivalents'**
  String get systemGroupCashEquivalents;

  /// No description provided for @systemGroupPensionRetirement.
  ///
  /// In en, this message translates to:
  /// **'Pension & retirement'**
  String get systemGroupPensionRetirement;

  /// No description provided for @systemGroupCreditShortTerm.
  ///
  /// In en, this message translates to:
  /// **'Credit & short-term debt'**
  String get systemGroupCreditShortTerm;

  /// No description provided for @systemGroupLoansMortgages.
  ///
  /// In en, this message translates to:
  /// **'Loans & mortgages'**
  String get systemGroupLoansMortgages;

  /// No description provided for @systemGroupInvestments.
  ///
  /// In en, this message translates to:
  /// **'Investments'**
  String get systemGroupInvestments;

  /// No description provided for @systemAccountCashBank.
  ///
  /// In en, this message translates to:
  /// **'Cash & Bank'**
  String get systemAccountCashBank;

  /// No description provided for @systemCategorySalary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get systemCategorySalary;

  /// No description provided for @systemCategoryOtherIncome.
  ///
  /// In en, this message translates to:
  /// **'Other Income'**
  String get systemCategoryOtherIncome;

  /// No description provided for @systemCategoryGroceries.
  ///
  /// In en, this message translates to:
  /// **'Groceries'**
  String get systemCategoryGroceries;

  /// No description provided for @systemCategoryRentMortgage.
  ///
  /// In en, this message translates to:
  /// **'Rent/Mortgage'**
  String get systemCategoryRentMortgage;

  /// No description provided for @systemCategoryUtilities.
  ///
  /// In en, this message translates to:
  /// **'Utilities'**
  String get systemCategoryUtilities;

  /// No description provided for @systemCategoryTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get systemCategoryTransport;

  /// No description provided for @systemCategoryFoodOut.
  ///
  /// In en, this message translates to:
  /// **'Food out'**
  String get systemCategoryFoodOut;

  /// No description provided for @systemCategoryPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get systemCategoryPhone;

  /// No description provided for @systemCategoryHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get systemCategoryHealth;

  /// No description provided for @systemCategoryOtherExpense.
  ///
  /// In en, this message translates to:
  /// **'Other Expense'**
  String get systemCategoryOtherExpense;

  /// No description provided for @systemDescriptionCsvImport.
  ///
  /// In en, this message translates to:
  /// **'CSV import'**
  String get systemDescriptionCsvImport;

  /// No description provided for @systemDescriptionOfxImport.
  ///
  /// In en, this message translates to:
  /// **'OFX import'**
  String get systemDescriptionOfxImport;

  /// No description provided for @homeThisMonth.
  ///
  /// In en, this message translates to:
  /// **'THIS MONTH'**
  String get homeThisMonth;

  /// No description provided for @homeMoneyInTransit.
  ///
  /// In en, this message translates to:
  /// **'MONEY IN TRANSIT'**
  String get homeMoneyInTransit;

  /// No description provided for @homeWhatYouHaveMinusWhatYouOwe.
  ///
  /// In en, this message translates to:
  /// **'WHAT YOU HAVE MINUS WHAT YOU OWE'**
  String get homeWhatYouHaveMinusWhatYouOwe;

  /// No description provided for @homeWhatYouHave.
  ///
  /// In en, this message translates to:
  /// **'What you have {amount} {currency}'**
  String homeWhatYouHave(String amount, String currency);

  /// No description provided for @homeNetPosition.
  ///
  /// In en, this message translates to:
  /// **'{amount} {currency}'**
  String homeNetPosition(String amount, String currency);

  /// No description provided for @homeHaveAndOwe.
  ///
  /// In en, this message translates to:
  /// **'What you have {haveAmount} {currency}  •  What you owe {oweAmount} {currency}'**
  String homeHaveAndOwe(String haveAmount, String currency, String oweAmount);

  /// No description provided for @youSentFrom.
  ///
  /// In en, this message translates to:
  /// **'You sent {amount} {currency} from {name}'**
  String youSentFrom(String amount, String currency, String name);

  /// No description provided for @youSentTo.
  ///
  /// In en, this message translates to:
  /// **'You sent {amount} {currency} to {name}'**
  String youSentTo(String amount, String currency, String name);

  /// No description provided for @hiddenLabel.
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get hiddenLabel;

  /// No description provided for @allAccounts.
  ///
  /// In en, this message translates to:
  /// **'All accounts'**
  String get allAccounts;

  /// No description provided for @savedToPath.
  ///
  /// In en, this message translates to:
  /// **'Saved to {path}'**
  String savedToPath(String path);

  /// No description provided for @keystoreExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not export the keystore file. You can skip this step.'**
  String get keystoreExportFailed;

  /// No description provided for @enterPassphraseToProtect.
  ///
  /// In en, this message translates to:
  /// **'Enter a passphrase to protect the file.'**
  String get enterPassphraseToProtect;

  /// No description provided for @homeTapWhenArrived.
  ///
  /// In en, this message translates to:
  /// **'Tap when you know what arrived'**
  String get homeTapWhenArrived;

  /// No description provided for @homeReturnedTo.
  ///
  /// In en, this message translates to:
  /// **'Returned to {name}'**
  String homeReturnedTo(String name);

  /// No description provided for @homeDueToday.
  ///
  /// In en, this message translates to:
  /// **'DUE TODAY'**
  String get homeDueToday;

  /// No description provided for @homeDueLine.
  ///
  /// In en, this message translates to:
  /// **'{category} · {account} · tap to record'**
  String homeDueLine(String category, String account);

  /// No description provided for @homeOverLimit.
  ///
  /// In en, this message translates to:
  /// **'Over limit'**
  String get homeOverLimit;

  /// No description provided for @homeSpentOfLimit.
  ///
  /// In en, this message translates to:
  /// **'{spent} of {limit}'**
  String homeSpentOfLimit(String spent, String limit);

  /// No description provided for @homeRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining: {amount}'**
  String homeRemaining(String amount);

  /// No description provided for @homeNoAccounts.
  ///
  /// In en, this message translates to:
  /// **'No accounts'**
  String get homeNoAccounts;

  /// No description provided for @homeCashRegister.
  ///
  /// In en, this message translates to:
  /// **'Cash register'**
  String get homeCashRegister;

  /// No description provided for @homeMarketEstimate.
  ///
  /// In en, this message translates to:
  /// **'Market estimate'**
  String get homeMarketEstimate;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerTitle;

  /// No description provided for @registerSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Description, category, or amount'**
  String get registerSearchHint;

  /// No description provided for @registerNoTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get registerNoTransactions;

  /// No description provided for @registerNoEntries.
  ///
  /// In en, this message translates to:
  /// **'No entries recorded yet.'**
  String get registerNoEntries;

  /// No description provided for @registerSpentOnly.
  ///
  /// In en, this message translates to:
  /// **'Spent only'**
  String get registerSpentOnly;

  /// No description provided for @registerReceivedOnly.
  ///
  /// In en, this message translates to:
  /// **'Received only'**
  String get registerReceivedOnly;

  /// No description provided for @registerAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get registerAll;

  /// No description provided for @registerUnverified.
  ///
  /// In en, this message translates to:
  /// **'Unverified - excluded from totals'**
  String get registerUnverified;

  /// No description provided for @registerSuperseded.
  ///
  /// In en, this message translates to:
  /// **'Superseded by migration - excluded from totals'**
  String get registerSuperseded;

  /// No description provided for @summaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summaryTitle;

  /// No description provided for @summaryTotalIncome.
  ///
  /// In en, this message translates to:
  /// **'Total income'**
  String get summaryTotalIncome;

  /// No description provided for @summaryTotalExpense.
  ///
  /// In en, this message translates to:
  /// **'Total expense'**
  String get summaryTotalExpense;

  /// No description provided for @summaryDateRange.
  ///
  /// In en, this message translates to:
  /// **'{start} to {end}'**
  String summaryDateRange(String start, String end);

  /// No description provided for @accountsTitle.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get accountsTitle;

  /// No description provided for @categoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoriesTitle;

  /// No description provided for @accountName.
  ///
  /// In en, this message translates to:
  /// **'Account name'**
  String get accountName;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @createGroup.
  ///
  /// In en, this message translates to:
  /// **'Create group'**
  String get createGroup;

  /// No description provided for @editGroup.
  ///
  /// In en, this message translates to:
  /// **'Edit group'**
  String get editGroup;

  /// No description provided for @renameAccount.
  ///
  /// In en, this message translates to:
  /// **'Rename account'**
  String get renameAccount;

  /// No description provided for @renameCategory.
  ///
  /// In en, this message translates to:
  /// **'Rename category'**
  String get renameCategory;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get addCategory;

  /// No description provided for @groupLabel.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get groupLabel;

  /// No description provided for @kindLabel.
  ///
  /// In en, this message translates to:
  /// **'Kind'**
  String get kindLabel;

  /// No description provided for @asset.
  ///
  /// In en, this message translates to:
  /// **'Asset'**
  String get asset;

  /// No description provided for @liability.
  ///
  /// In en, this message translates to:
  /// **'Liability'**
  String get liability;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @thisAccountHoldsInvestments.
  ///
  /// In en, this message translates to:
  /// **'This account holds investments'**
  String get thisAccountHoldsInvestments;

  /// No description provided for @thisAccountHoldsInvestmentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Cash plus inventory you record with Buy, Sell, and Dividend.'**
  String get thisAccountHoldsInvestmentsSubtitle;

  /// No description provided for @thisIsACreditCard.
  ///
  /// In en, this message translates to:
  /// **'This is a credit card'**
  String get thisIsACreditCard;

  /// No description provided for @openingBalanceOptional.
  ///
  /// In en, this message translates to:
  /// **'Opening balance (optional)'**
  String get openingBalanceOptional;

  /// No description provided for @currencyIso.
  ///
  /// In en, this message translates to:
  /// **'Currency (ISO 4217)'**
  String get currencyIso;

  /// No description provided for @currencyIsoExample.
  ///
  /// In en, this message translates to:
  /// **'Currency (ISO 4217, e.g. USD)'**
  String get currencyIsoExample;

  /// No description provided for @hideAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Hide account from new entries?'**
  String get hideAccountTitle;

  /// No description provided for @hideCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Hide category from new entries?'**
  String get hideCategoryTitle;

  /// No description provided for @hideGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Hide group from new entries?'**
  String get hideGroupTitle;

  /// No description provided for @reassignGroup.
  ///
  /// In en, this message translates to:
  /// **'Reassign group'**
  String get reassignGroup;

  /// No description provided for @transferRemainingBalance.
  ///
  /// In en, this message translates to:
  /// **'Transfer remaining balance'**
  String get transferRemainingBalance;

  /// No description provided for @monthlyLimit.
  ///
  /// In en, this message translates to:
  /// **'Monthly limit'**
  String get monthlyLimit;

  /// No description provided for @monthlyLimitHint.
  ///
  /// In en, this message translates to:
  /// **'Limit (leave blank to clear)'**
  String get monthlyLimitHint;

  /// No description provided for @monthlyLimitBlurb.
  ///
  /// In en, this message translates to:
  /// **'An optional month-to-date spending guide for this expense category.'**
  String get monthlyLimitBlurb;

  /// No description provided for @manageCategoryRules.
  ///
  /// In en, this message translates to:
  /// **'Manage category rules'**
  String get manageCategoryRules;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @fromAccount.
  ///
  /// In en, this message translates to:
  /// **'From account'**
  String get fromAccount;

  /// No description provided for @toAccount.
  ///
  /// In en, this message translates to:
  /// **'To account'**
  String get toAccount;

  /// No description provided for @descriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get descriptionOptional;

  /// No description provided for @alsoRememberPayee.
  ///
  /// In en, this message translates to:
  /// **'Also remember as a payee'**
  String get alsoRememberPayee;

  /// No description provided for @splitIntoCategories.
  ///
  /// In en, this message translates to:
  /// **'Split into multiple categories'**
  String get splitIntoCategories;

  /// No description provided for @categoryN.
  ///
  /// In en, this message translates to:
  /// **'Category {n}'**
  String categoryN(String n);

  /// No description provided for @destinationAmount.
  ///
  /// In en, this message translates to:
  /// **'Destination amount'**
  String get destinationAmount;

  /// No description provided for @destinationAmountOptional.
  ///
  /// In en, this message translates to:
  /// **'Destination amount (optional)'**
  String get destinationAmountOptional;

  /// No description provided for @accountCurrencyAmountOptional.
  ///
  /// In en, this message translates to:
  /// **'Account-currency amount (optional)'**
  String get accountCurrencyAmountOptional;

  /// No description provided for @transactionCurrencyOptional.
  ///
  /// In en, this message translates to:
  /// **'Transaction currency (optional)'**
  String get transactionCurrencyOptional;

  /// No description provided for @feeOptional.
  ///
  /// In en, this message translates to:
  /// **'Fee (optional)'**
  String get feeOptional;

  /// No description provided for @feeAmount.
  ///
  /// In en, this message translates to:
  /// **'Fee amount'**
  String get feeAmount;

  /// No description provided for @feeCategory.
  ///
  /// In en, this message translates to:
  /// **'Fee category'**
  String get feeCategory;

  /// No description provided for @feeDescriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Fee description (optional)'**
  String get feeDescriptionOptional;

  /// No description provided for @feeDeducted.
  ///
  /// In en, this message translates to:
  /// **'Fee is deducted from the amount above'**
  String get feeDeducted;

  /// No description provided for @needTwoAccountsToTransfer.
  ///
  /// In en, this message translates to:
  /// **'Create at least two active accounts to make a transfer.'**
  String get needTwoAccountsToTransfer;

  /// No description provided for @whatArrivedTitle.
  ///
  /// In en, this message translates to:
  /// **'What arrived?'**
  String get whatArrivedTitle;

  /// No description provided for @whatArrivedBlurb.
  ///
  /// In en, this message translates to:
  /// **'Tell us what actually arrived.'**
  String get whatArrivedBlurb;

  /// No description provided for @amountThatArrived.
  ///
  /// In en, this message translates to:
  /// **'Amount that arrived'**
  String get amountThatArrived;

  /// No description provided for @feeLossCategory.
  ///
  /// In en, this message translates to:
  /// **'Fee / loss category'**
  String get feeLossCategory;

  /// No description provided for @alreadySettled.
  ///
  /// In en, this message translates to:
  /// **'Already settled.'**
  String get alreadySettled;

  /// No description provided for @holdingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Holdings'**
  String get holdingsTitle;

  /// No description provided for @holdingsCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get holdingsCash;

  /// No description provided for @holdingsInventory.
  ///
  /// In en, this message translates to:
  /// **'INVENTORY'**
  String get holdingsInventory;

  /// No description provided for @holdingsBook.
  ///
  /// In en, this message translates to:
  /// **'Book (cash + cost) {amount} {currency}'**
  String holdingsBook(String amount, String currency);

  /// No description provided for @holdingsMarketEstimate.
  ///
  /// In en, this message translates to:
  /// **'Market estimate {amount} {currency}'**
  String holdingsMarketEstimate(String amount, String currency);

  /// No description provided for @holdingsNoHoldings.
  ///
  /// In en, this message translates to:
  /// **'No holdings yet. Record a buy to add an instrument.'**
  String get holdingsNoHoldings;

  /// No description provided for @holdingsQuotesBlurb.
  ///
  /// In en, this message translates to:
  /// **'Quotes are estimates, not a broker price. This app does not place orders.'**
  String get holdingsQuotesBlurb;

  /// No description provided for @holdingsTapNameToResearch.
  ///
  /// In en, this message translates to:
  /// **'Tap the name to research. Quotes are estimates, not advice.'**
  String get holdingsTapNameToResearch;

  /// No description provided for @instrument.
  ///
  /// In en, this message translates to:
  /// **'Instrument'**
  String get instrument;

  /// No description provided for @newInstrument.
  ///
  /// In en, this message translates to:
  /// **'New instrument'**
  String get newInstrument;

  /// No description provided for @renameInstrument.
  ///
  /// In en, this message translates to:
  /// **'Rename instrument'**
  String get renameInstrument;

  /// No description provided for @instrumentActions.
  ///
  /// In en, this message translates to:
  /// **'Instrument actions'**
  String get instrumentActions;

  /// No description provided for @hideInstrumentTitle.
  ///
  /// In en, this message translates to:
  /// **'Hide {name}?'**
  String hideInstrumentTitle(String name);

  /// No description provided for @tickerOptional.
  ///
  /// In en, this message translates to:
  /// **'Ticker (optional)'**
  String get tickerOptional;

  /// No description provided for @isinOptional.
  ///
  /// In en, this message translates to:
  /// **'ISIN (optional)'**
  String get isinOptional;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @unitPrice.
  ///
  /// In en, this message translates to:
  /// **'Unit price'**
  String get unitPrice;

  /// No description provided for @brokerageOptional.
  ///
  /// In en, this message translates to:
  /// **'Brokerage (optional)'**
  String get brokerageOptional;

  /// No description provided for @brokerageExpenseCategory.
  ///
  /// In en, this message translates to:
  /// **'Brokerage expense category'**
  String get brokerageExpenseCategory;

  /// No description provided for @incomeCategory.
  ///
  /// In en, this message translates to:
  /// **'Income category'**
  String get incomeCategory;

  /// No description provided for @gainIncomeCategory.
  ///
  /// In en, this message translates to:
  /// **'Gain income category'**
  String get gainIncomeCategory;

  /// No description provided for @lossExpenseCategory.
  ///
  /// In en, this message translates to:
  /// **'Loss expense category'**
  String get lossExpenseCategory;

  /// No description provided for @nonCash.
  ///
  /// In en, this message translates to:
  /// **'Non-cash'**
  String get nonCash;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @locked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get locked;

  /// No description provided for @lockUntilHint.
  ///
  /// In en, this message translates to:
  /// **'Your own note of a restriction, not a broker rule.'**
  String get lockUntilHint;

  /// No description provided for @instrumentKindStock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get instrumentKindStock;

  /// No description provided for @instrumentKindEtf.
  ///
  /// In en, this message translates to:
  /// **'ETF'**
  String get instrumentKindEtf;

  /// No description provided for @instrumentKindMutualFund.
  ///
  /// In en, this message translates to:
  /// **'Mutual fund'**
  String get instrumentKindMutualFund;

  /// No description provided for @instrumentKindBond.
  ///
  /// In en, this message translates to:
  /// **'Bond'**
  String get instrumentKindBond;

  /// No description provided for @instrumentKindOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get instrumentKindOther;

  /// No description provided for @quoteUseLive.
  ///
  /// In en, this message translates to:
  /// **'Live price'**
  String get quoteUseLive;

  /// No description provided for @quoteUseCached.
  ///
  /// In en, this message translates to:
  /// **'Cached price'**
  String get quoteUseCached;

  /// No description provided for @quoteUseStale.
  ///
  /// In en, this message translates to:
  /// **'Stale price'**
  String get quoteUseStale;

  /// No description provided for @quoteUseMissing.
  ///
  /// In en, this message translates to:
  /// **'Using cost (no price)'**
  String get quoteUseMissing;

  /// No description provided for @quoteUseDisabled.
  ///
  /// In en, this message translates to:
  /// **'Quotes off — using cost/cache'**
  String get quoteUseDisabled;

  /// No description provided for @quoteUseCurrencyMismatch.
  ///
  /// In en, this message translates to:
  /// **'Using cost (price currency differs)'**
  String get quoteUseCurrencyMismatch;

  /// No description provided for @unrealizedLabel.
  ///
  /// In en, this message translates to:
  /// **'Unrealized {amount} {currency}'**
  String unrealizedLabel(String amount, String currency);

  /// No description provided for @holdingsUnitsCost.
  ///
  /// In en, this message translates to:
  /// **'{qty} units · '**
  String holdingsUnitsCost(String qty);

  /// No description provided for @recoveryPhraseTitle.
  ///
  /// In en, this message translates to:
  /// **'Your recovery phrase'**
  String get recoveryPhraseTitle;

  /// No description provided for @recoveryPhraseConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm your phrase'**
  String get recoveryPhraseConfirmTitle;

  /// No description provided for @recoveryPhraseBlurb.
  ///
  /// In en, this message translates to:
  /// **'These 24 words are the only way to recover your transaction history if this device is lost, reset, or replaced. Smara Accounting has no server and cannot recover them for you.\n\nIf you lose this device and this phrase together, every transaction you\'\'ve recorded becomes permanently unverifiable.'**
  String get recoveryPhraseBlurb;

  /// No description provided for @recoveryPhraseWriteDown.
  ///
  /// In en, this message translates to:
  /// **'Write these words down in order and store them somewhere safe and separate from this device.'**
  String get recoveryPhraseWriteDown;

  /// No description provided for @iveSavedRecoveryPhrase.
  ///
  /// In en, this message translates to:
  /// **'I\'\'ve saved my recovery phrase'**
  String get iveSavedRecoveryPhrase;

  /// No description provided for @confirmPhraseBlurb.
  ///
  /// In en, this message translates to:
  /// **'Enter the requested words from the phrase you just saved.'**
  String get confirmPhraseBlurb;

  /// No description provided for @wordNumber.
  ///
  /// In en, this message translates to:
  /// **'Word #{n}'**
  String wordNumber(String n);

  /// No description provided for @keystoreExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export keystore file'**
  String get keystoreExportTitle;

  /// No description provided for @keystoreExportBlurb.
  ///
  /// In en, this message translates to:
  /// **'As well as your recovery phrase, you can save an encrypted keystore file protected by a passphrase you choose. This is optional - your recovery phrase alone is always enough to restore your signing key.'**
  String get keystoreExportBlurb;

  /// No description provided for @keystorePassphrase.
  ///
  /// In en, this message translates to:
  /// **'Passphrase'**
  String get keystorePassphrase;

  /// No description provided for @exportKeystoreFile.
  ///
  /// In en, this message translates to:
  /// **'Export keystore file'**
  String get exportKeystoreFile;

  /// No description provided for @chooseCurrencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your currency'**
  String get chooseCurrencyTitle;

  /// No description provided for @chooseCurrencyBlurb.
  ///
  /// In en, this message translates to:
  /// **'Every account group (Cash & cash equivalents, Pension & retirement, etc.) uses this one currency for now. You can still add accounts in a different currency later by creating a new group for it.'**
  String get chooseCurrencyBlurb;

  /// No description provided for @currencyBackfillTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a currency for existing groups'**
  String get currencyBackfillTitle;

  /// No description provided for @currencyBackfillBlurb.
  ///
  /// In en, this message translates to:
  /// **'This app now supports multiple currencies. Your existing accounts and account groups need a currency - since they were all set up before this feature existed, one choice applies to all of them.'**
  String get currencyBackfillBlurb;

  /// No description provided for @firstAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Name your account'**
  String get firstAccountTitle;

  /// No description provided for @firstAccountBlurb.
  ///
  /// In en, this message translates to:
  /// **'This is the account already set up for you - give it a name you recognize, like your bank. You will record one Spent or Received next, then protect the device with your recovery phrase.'**
  String get firstAccountBlurb;

  /// No description provided for @whatsMainAccountCalled.
  ///
  /// In en, this message translates to:
  /// **'What\'\'s your main account called?'**
  String get whatsMainAccountCalled;

  /// No description provided for @restoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore signing key'**
  String get restoreTitle;

  /// No description provided for @restoreBlurb.
  ///
  /// In en, this message translates to:
  /// **'This device has existing books, but no matching signing key. Restore it from your saved recovery phrase or keystore file - your data will verify normally, and nothing will be re-signed or altered.'**
  String get restoreBlurb;

  /// No description provided for @recoveryPhrase24.
  ///
  /// In en, this message translates to:
  /// **'Recovery phrase (all 24 words)'**
  String get recoveryPhrase24;

  /// No description provided for @keystoreFile.
  ///
  /// In en, this message translates to:
  /// **'Keystore file'**
  String get keystoreFile;

  /// No description provided for @keystoreFileContents.
  ///
  /// In en, this message translates to:
  /// **'Keystore file contents'**
  String get keystoreFileContents;

  /// No description provided for @optionalBackupFile.
  ///
  /// In en, this message translates to:
  /// **'Optional backup file'**
  String get optionalBackupFile;

  /// No description provided for @iDontHavePhrase.
  ///
  /// In en, this message translates to:
  /// **'I don\'\'t have my recovery phrase or keystore file'**
  String get iDontHavePhrase;

  /// No description provided for @migrationTitle.
  ///
  /// In en, this message translates to:
  /// **'Migrate to a new key'**
  String get migrationTitle;

  /// No description provided for @migrationBlurb.
  ///
  /// In en, this message translates to:
  /// **'Without your recovery phrase or keystore file, this device\'\'s signing key cannot be recovered. You can start a new key. Old entries stay visible but are superseded.'**
  String get migrationBlurb;

  /// No description provided for @iConfirmBooksValid.
  ///
  /// In en, this message translates to:
  /// **'I confirm the current books are valid'**
  String get iConfirmBooksValid;

  /// No description provided for @whyWeDontEdit.
  ///
  /// In en, this message translates to:
  /// **'Why we don’t edit old entries'**
  String get whyWeDontEdit;

  /// No description provided for @whyWeDontEditBody.
  ///
  /// In en, this message translates to:
  /// **'When you fix a mistake, we keep the old line and add a correction next to it instead of changing what you already entered. That way your history always shows exactly what happened and when you fixed it — nothing quietly changes behind your back.'**
  String get whyWeDontEditBody;

  /// No description provided for @lockTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get lockTitle;

  /// No description provided for @lockScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get lockScreenTitle;

  /// No description provided for @enterPinToContinue.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN to continue'**
  String get enterPinToContinue;

  /// No description provided for @pinLabel.
  ///
  /// In en, this message translates to:
  /// **'PIN'**
  String get pinLabel;

  /// No description provided for @setPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Set a PIN'**
  String get setPinTitle;

  /// No description provided for @currentPin.
  ///
  /// In en, this message translates to:
  /// **'Current PIN'**
  String get currentPin;

  /// No description provided for @newPin.
  ///
  /// In en, this message translates to:
  /// **'New PIN'**
  String get newPin;

  /// No description provided for @confirmPin.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get confirmPin;

  /// No description provided for @confirmNewPin.
  ///
  /// In en, this message translates to:
  /// **'Confirm new PIN'**
  String get confirmNewPin;

  /// No description provided for @firstWeekTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your accounts'**
  String get firstWeekTitle;

  /// No description provided for @addCashAccount.
  ///
  /// In en, this message translates to:
  /// **'Add a cash account'**
  String get addCashAccount;

  /// No description provided for @addCreditCard.
  ///
  /// In en, this message translates to:
  /// **'Add a credit card'**
  String get addCreditCard;

  /// No description provided for @cashAccountName.
  ///
  /// In en, this message translates to:
  /// **'Cash account name'**
  String get cashAccountName;

  /// No description provided for @cardName.
  ///
  /// In en, this message translates to:
  /// **'Card name'**
  String get cardName;

  /// No description provided for @paidFromBank.
  ///
  /// In en, this message translates to:
  /// **'Paid from bank'**
  String get paidFromBank;

  /// No description provided for @paidFromCard.
  ///
  /// In en, this message translates to:
  /// **'Paid from card'**
  String get paidFromCard;

  /// No description provided for @choosePassphraseTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a passphrase to protect this backup. There is no recovery if you forget it.'**
  String get choosePassphraseTitle;

  /// No description provided for @replaceBooksTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace your local books?'**
  String get replaceBooksTitle;

  /// No description provided for @replaceBooksBody.
  ///
  /// In en, this message translates to:
  /// **'This replaces everything currently in this app with the backup. Close and reopen the app afterwards.'**
  String get replaceBooksBody;

  /// No description provided for @chooseBackupFileFirst.
  ///
  /// In en, this message translates to:
  /// **'Choose a backup file first.'**
  String get chooseBackupFileFirst;

  /// No description provided for @backupRestored.
  ///
  /// In en, this message translates to:
  /// **'Backup restored'**
  String get backupRestored;

  /// No description provided for @backupRestoredBody.
  ///
  /// In en, this message translates to:
  /// **'Your books have been restored. Close and reopen the app to continue.'**
  String get backupRestoredBody;

  /// No description provided for @fixThisEntry.
  ///
  /// In en, this message translates to:
  /// **'Fix this entry'**
  String get fixThisEntry;

  /// No description provided for @fixBlurb.
  ///
  /// In en, this message translates to:
  /// **'The old line stays exactly as it was. Confirming adds a reversing line and the corrected one.'**
  String get fixBlurb;

  /// No description provided for @importStatementTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Statement'**
  String get importStatementTitle;

  /// No description provided for @importOfx.
  ///
  /// In en, this message translates to:
  /// **'Import OFX'**
  String get importOfx;

  /// No description provided for @importOfxQfxFile.
  ///
  /// In en, this message translates to:
  /// **'Import OFX / QFX file'**
  String get importOfxQfxFile;

  /// No description provided for @importCsvFile.
  ///
  /// In en, this message translates to:
  /// **'Import CSV file'**
  String get importCsvFile;

  /// No description provided for @whatKindOfStatement.
  ///
  /// In en, this message translates to:
  /// **'What kind of statement file do you have?'**
  String get whatKindOfStatement;

  /// No description provided for @chooseAccountForFile.
  ///
  /// In en, this message translates to:
  /// **'Choose which account this file belongs to.'**
  String get chooseAccountForFile;

  /// No description provided for @importIntoAccount.
  ///
  /// In en, this message translates to:
  /// **'Import into account'**
  String get importIntoAccount;

  /// No description provided for @useSavedProfile.
  ///
  /// In en, this message translates to:
  /// **'Use a saved profile'**
  String get useSavedProfile;

  /// No description provided for @saveMappingProfile.
  ///
  /// In en, this message translates to:
  /// **'Save this mapping as a profile (optional)'**
  String get saveMappingProfile;

  /// No description provided for @renameProfile.
  ///
  /// In en, this message translates to:
  /// **'Rename profile'**
  String get renameProfile;

  /// No description provided for @deleteProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete profile?'**
  String get deleteProfileTitle;

  /// No description provided for @fileHasHeader.
  ///
  /// In en, this message translates to:
  /// **'File has a header row'**
  String get fileHasHeader;

  /// No description provided for @dateColumn.
  ///
  /// In en, this message translates to:
  /// **'Date column'**
  String get dateColumn;

  /// No description provided for @dateFormatHint.
  ///
  /// In en, this message translates to:
  /// **'Date format (e.g. dd/MM/yyyy)'**
  String get dateFormatHint;

  /// No description provided for @amountColumn.
  ///
  /// In en, this message translates to:
  /// **'Amount column'**
  String get amountColumn;

  /// No description provided for @amountConvention.
  ///
  /// In en, this message translates to:
  /// **'Amount convention'**
  String get amountConvention;

  /// No description provided for @signedAmountColumn.
  ///
  /// In en, this message translates to:
  /// **'Signed amount column'**
  String get signedAmountColumn;

  /// No description provided for @separateDebitCredit.
  ///
  /// In en, this message translates to:
  /// **'Separate debit / credit columns'**
  String get separateDebitCredit;

  /// No description provided for @debitColumn.
  ///
  /// In en, this message translates to:
  /// **'Debit column'**
  String get debitColumn;

  /// No description provided for @creditColumn.
  ///
  /// In en, this message translates to:
  /// **'Credit column'**
  String get creditColumn;

  /// No description provided for @decimalSeparator.
  ///
  /// In en, this message translates to:
  /// **'Decimal separator (. or ,)'**
  String get decimalSeparator;

  /// No description provided for @descriptionColumns.
  ///
  /// In en, this message translates to:
  /// **'Description column(s)'**
  String get descriptionColumns;

  /// No description provided for @referenceIdColumn.
  ///
  /// In en, this message translates to:
  /// **'Reference id column (optional)'**
  String get referenceIdColumn;

  /// No description provided for @skippedRows.
  ///
  /// In en, this message translates to:
  /// **'Skipped rows'**
  String get skippedRows;

  /// No description provided for @parsedTransactionCount.
  ///
  /// In en, this message translates to:
  /// **'{count} transactions parsed'**
  String parsedTransactionCount(String count);

  /// No description provided for @skippedOrExcludedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} skipped or excluded'**
  String skippedOrExcludedCount(String count);

  /// No description provided for @postedFailedCount.
  ///
  /// In en, this message translates to:
  /// **'{posted} posted, {failed} failed'**
  String postedFailedCount(String posted, String failed);

  /// No description provided for @categoryForAll.
  ///
  /// In en, this message translates to:
  /// **'Category for all'**
  String get categoryForAll;

  /// No description provided for @saveAsRule.
  ///
  /// In en, this message translates to:
  /// **'Save as a rule?'**
  String get saveAsRule;

  /// No description provided for @saveAsRuleBlurb.
  ///
  /// In en, this message translates to:
  /// **'Future imports whose description contains this keyword will use this category.'**
  String get saveAsRuleBlurb;

  /// No description provided for @keyword.
  ///
  /// In en, this message translates to:
  /// **'Keyword'**
  String get keyword;

  /// No description provided for @noSavedRules.
  ///
  /// In en, this message translates to:
  /// **'No saved rules yet. Assign a category to a group of rows to save a rule.'**
  String get noSavedRules;

  /// No description provided for @deleteRuleTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete rule?'**
  String get deleteRuleTitle;

  /// No description provided for @editRule.
  ///
  /// In en, this message translates to:
  /// **'Edit rule'**
  String get editRule;

  /// No description provided for @rowsGrouped.
  ///
  /// In en, this message translates to:
  /// **'{count} rows'**
  String rowsGrouped(String count);

  /// No description provided for @selectStatementFile.
  ///
  /// In en, this message translates to:
  /// **'Select a {extensions} statement file to import'**
  String selectStatementFile(String extensions);

  /// No description provided for @payeesTitle.
  ///
  /// In en, this message translates to:
  /// **'Payees'**
  String get payeesTitle;

  /// No description provided for @addPayee.
  ///
  /// In en, this message translates to:
  /// **'Add payee'**
  String get addPayee;

  /// No description provided for @renamePayee.
  ///
  /// In en, this message translates to:
  /// **'Rename payee'**
  String get renamePayee;

  /// No description provided for @deletePayeeTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete payee?'**
  String get deletePayeeTitle;

  /// No description provided for @noPayeesYet.
  ///
  /// In en, this message translates to:
  /// **'No payees yet'**
  String get noPayeesYet;

  /// No description provided for @recurringTitle.
  ///
  /// In en, this message translates to:
  /// **'Recurring templates'**
  String get recurringTitle;

  /// No description provided for @noRecurringYet.
  ///
  /// In en, this message translates to:
  /// **'No recurring templates yet'**
  String get noRecurringYet;

  /// No description provided for @deleteTemplateTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete recurring template?'**
  String get deleteTemplateTitle;

  /// No description provided for @dayOfMonth.
  ///
  /// In en, this message translates to:
  /// **'Day of month (1-31)'**
  String get dayOfMonth;

  /// No description provided for @dayOfMonthNote.
  ///
  /// In en, this message translates to:
  /// **'A month with fewer days uses its own last day.'**
  String get dayOfMonthNote;

  /// No description provided for @dayOfMonthLine.
  ///
  /// In en, this message translates to:
  /// **'Day {day} of the month - '**
  String dayOfMonthLine(String day);

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @errorSigningIdentityMismatch.
  ///
  /// In en, this message translates to:
  /// **'This recovery phrase or keystore file does not match any signing identity in this database.'**
  String get errorSigningIdentityMismatch;

  /// No description provided for @errorInvalidLedgerBackup.
  ///
  /// In en, this message translates to:
  /// **'This file is not a valid Smara backup.'**
  String get errorInvalidLedgerBackup;

  /// No description provided for @errorInvalidLedgerBackupNoIdentity.
  ///
  /// In en, this message translates to:
  /// **'This backup has no signing identity - it is not a valid Smara backup.'**
  String get errorInvalidLedgerBackupNoIdentity;

  /// No description provided for @errorInvalidLedgerBackupUnverified.
  ///
  /// In en, this message translates to:
  /// **'This backup did not verify as intact books, so it was not restored.'**
  String get errorInvalidLedgerBackupUnverified;

  /// No description provided for @errorInvalidLedgerBackupUnreadable.
  ///
  /// In en, this message translates to:
  /// **'This file could not be opened as a Smara backup: {detail}'**
  String errorInvalidLedgerBackupUnreadable(String detail);

  /// No description provided for @errorForeignBackupIdentity.
  ///
  /// In en, this message translates to:
  /// **'This backup belongs to a different signing identity than the one on this device.'**
  String get errorForeignBackupIdentity;

  /// No description provided for @errorAccountNotFinancial.
  ///
  /// In en, this message translates to:
  /// **'That is not a financial account.'**
  String get errorAccountNotFinancial;

  /// No description provided for @errorAccountArchived.
  ///
  /// In en, this message translates to:
  /// **'That account is hidden.'**
  String get errorAccountArchived;

  /// No description provided for @errorAccountNotArchived.
  ///
  /// In en, this message translates to:
  /// **'That account is not hidden.'**
  String get errorAccountNotArchived;

  /// No description provided for @errorAccountNoPositiveBalanceToCloseOut.
  ///
  /// In en, this message translates to:
  /// **'There is no remaining balance to transfer.'**
  String get errorAccountNoPositiveBalanceToCloseOut;

  /// No description provided for @errorAccountHasNoGroup.
  ///
  /// In en, this message translates to:
  /// **'That account has no group assigned.'**
  String get errorAccountHasNoGroup;

  /// No description provided for @errorGroupHasNoCurrency.
  ///
  /// In en, this message translates to:
  /// **'That group has no currency set yet.'**
  String get errorGroupHasNoCurrency;

  /// No description provided for @errorGroupNotFound.
  ///
  /// In en, this message translates to:
  /// **'That account group was not found.'**
  String get errorGroupNotFound;

  /// No description provided for @errorInvestmentAccountsMustBeAssets.
  ///
  /// In en, this message translates to:
  /// **'Only asset accounts can be marked as investment accounts.'**
  String get errorInvestmentAccountsMustBeAssets;

  /// No description provided for @errorCreditCardsMustBeLiabilities.
  ///
  /// In en, this message translates to:
  /// **'Only liability accounts can be marked as credit cards.'**
  String get errorCreditCardsMustBeLiabilities;

  /// No description provided for @errorOpeningBalanceMustBePositive.
  ///
  /// In en, this message translates to:
  /// **'Opening balance must be positive when supplied.'**
  String get errorOpeningBalanceMustBePositive;

  /// No description provided for @errorAccountTypeDoesNotMatchGroup.
  ///
  /// In en, this message translates to:
  /// **'That account type does not match the group.'**
  String get errorAccountTypeDoesNotMatchGroup;

  /// No description provided for @errorLastActiveAccount.
  ///
  /// In en, this message translates to:
  /// **'Cannot hide the last active financial account.'**
  String get errorLastActiveAccount;

  /// No description provided for @errorCurrencyRequiredToCreateGroup.
  ///
  /// In en, this message translates to:
  /// **'Currency is required to create a group.'**
  String get errorCurrencyRequiredToCreateGroup;

  /// No description provided for @errorSystemGroupCannotBeArchived.
  ///
  /// In en, this message translates to:
  /// **'Built-in account groups cannot be hidden.'**
  String get errorSystemGroupCannotBeArchived;

  /// No description provided for @errorGroupAlreadyArchived.
  ///
  /// In en, this message translates to:
  /// **'That group is already hidden.'**
  String get errorGroupAlreadyArchived;

  /// No description provided for @errorCannotArchiveGroupWithAccounts.
  ///
  /// In en, this message translates to:
  /// **'Cannot hide a group that still has active accounts.'**
  String get errorCannotArchiveGroupWithAccounts;

  /// No description provided for @errorSystemGroupNeverArchived.
  ///
  /// In en, this message translates to:
  /// **'Built-in account groups are never hidden.'**
  String get errorSystemGroupNeverArchived;

  /// No description provided for @errorAccountGroupsCannotBeDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account groups cannot be deleted.'**
  String get errorAccountGroupsCannotBeDeleted;

  /// No description provided for @errorCannotReassignDifferentCurrency.
  ///
  /// In en, this message translates to:
  /// **'Cannot move this account to a group with a different currency.'**
  String get errorCannotReassignDifferentCurrency;

  /// No description provided for @errorCannotChangeGroupCurrencyWithAccounts.
  ///
  /// In en, this message translates to:
  /// **'Cannot change currency while the group has active accounts.'**
  String get errorCannotChangeGroupCurrencyWithAccounts;

  /// No description provided for @errorAmountMustBePositive.
  ///
  /// In en, this message translates to:
  /// **'Amount must be positive.'**
  String get errorAmountMustBePositive;

  /// No description provided for @errorAccountCurrencyAmountMustBePositive.
  ///
  /// In en, this message translates to:
  /// **'Account-currency amount must be positive.'**
  String get errorAccountCurrencyAmountMustBePositive;

  /// No description provided for @errorAccountCurrencyAmountNotForSameCurrency.
  ///
  /// In en, this message translates to:
  /// **'Account-currency amount is only for a foreign-currency entry.'**
  String get errorAccountCurrencyAmountNotForSameCurrency;

  /// No description provided for @errorSplitNeedsTwoLines.
  ///
  /// In en, this message translates to:
  /// **'A split needs at least two category lines.'**
  String get errorSplitNeedsTwoLines;

  /// No description provided for @errorSplitLineMustBePositive.
  ///
  /// In en, this message translates to:
  /// **'Each split line must be a positive amount.'**
  String get errorSplitLineMustBePositive;

  /// No description provided for @errorSplitLinesMustSumToTotal.
  ///
  /// In en, this message translates to:
  /// **'Split lines must add up to the transaction total.'**
  String get errorSplitLinesMustSumToTotal;

  /// No description provided for @errorTransferAmountMustBePositive.
  ///
  /// In en, this message translates to:
  /// **'Transfer amount must be positive.'**
  String get errorTransferAmountMustBePositive;

  /// No description provided for @errorTransferAccountsMustDiffer.
  ///
  /// In en, this message translates to:
  /// **'Source and destination accounts must be different.'**
  String get errorTransferAccountsMustDiffer;

  /// No description provided for @errorCloseoutRequiresDestinationAmount.
  ///
  /// In en, this message translates to:
  /// **'A cross-currency closeout needs a known destination amount.'**
  String get errorCloseoutRequiresDestinationAmount;

  /// No description provided for @errorDestinationAmountNotForSameCurrency.
  ///
  /// In en, this message translates to:
  /// **'Destination amount is only for a cross-currency transfer.'**
  String get errorDestinationAmountNotForSameCurrency;

  /// No description provided for @errorDestinationAmountMustBePositive.
  ///
  /// In en, this message translates to:
  /// **'Destination amount must be positive.'**
  String get errorDestinationAmountMustBePositive;

  /// No description provided for @errorInvestmentCashExceeded.
  ///
  /// In en, this message translates to:
  /// **'Cannot transfer more than this investment account\'\'s cash.'**
  String get errorInvestmentCashExceeded;

  /// No description provided for @errorCannotReverseUnsettledProvisional.
  ///
  /// In en, this message translates to:
  /// **'Settle this pending transfer instead of reversing it.'**
  String get errorCannotReverseUnsettledProvisional;

  /// No description provided for @errorAlreadyReversed.
  ///
  /// In en, this message translates to:
  /// **'This entry has already been corrected. The original line stays as it is.'**
  String get errorAlreadyReversed;

  /// No description provided for @errorNotActiveExpenseCategory.
  ///
  /// In en, this message translates to:
  /// **'Choose an active expense category.'**
  String get errorNotActiveExpenseCategory;

  /// No description provided for @errorNotActiveIncomeCategory.
  ///
  /// In en, this message translates to:
  /// **'Choose an active income category.'**
  String get errorNotActiveIncomeCategory;

  /// No description provided for @errorSettledAmountMustNotBeNegative.
  ///
  /// In en, this message translates to:
  /// **'Amount that arrived cannot be negative.'**
  String get errorSettledAmountMustNotBeNegative;

  /// No description provided for @errorPendingTransferNotFound.
  ///
  /// In en, this message translates to:
  /// **'That pending transfer was not found.'**
  String get errorPendingTransferNotFound;

  /// No description provided for @errorPendingTransferAlreadySettled.
  ///
  /// In en, this message translates to:
  /// **'That pending transfer is already settled.'**
  String get errorPendingTransferAlreadySettled;

  /// No description provided for @errorSettledToMustBeSourceOrDestination.
  ///
  /// In en, this message translates to:
  /// **'Choose the original source or destination account.'**
  String get errorSettledToMustBeSourceOrDestination;

  /// No description provided for @errorFeeCategoryOnlyWhenReturningToSource.
  ///
  /// In en, this message translates to:
  /// **'A fee category is only used when money is returned to the source account.'**
  String get errorFeeCategoryOnlyWhenReturningToSource;

  /// No description provided for @errorSettledAmountMustBePositiveForDelivery.
  ///
  /// In en, this message translates to:
  /// **'Enter a positive amount for what arrived.'**
  String get errorSettledAmountMustBePositiveForDelivery;

  /// No description provided for @errorSettledAmountExceedsProvisional.
  ///
  /// In en, this message translates to:
  /// **'That amount is more than was sent.'**
  String get errorSettledAmountExceedsProvisional;

  /// No description provided for @errorInstrumentNotFound.
  ///
  /// In en, this message translates to:
  /// **'That instrument was not found.'**
  String get errorInstrumentNotFound;

  /// No description provided for @errorIncomeRequiredForNonCash.
  ///
  /// In en, this message translates to:
  /// **'An active income category is required for a non-cash acquisition.'**
  String get errorIncomeRequiredForNonCash;

  /// No description provided for @errorInsufficientCash.
  ///
  /// In en, this message translates to:
  /// **'Not enough cash in this investment account for that buy.'**
  String get errorInsufficientCash;

  /// No description provided for @errorSellQuantityAndPriceMustBePositive.
  ///
  /// In en, this message translates to:
  /// **'Sell quantity and unit price must be positive.'**
  String get errorSellQuantityAndPriceMustBePositive;

  /// No description provided for @errorLockedUntil.
  ///
  /// In en, this message translates to:
  /// **'Cannot sell: some units are locked until {date}.'**
  String errorLockedUntil(String date);

  /// No description provided for @errorInsufficientQuantity.
  ///
  /// In en, this message translates to:
  /// **'Cannot sell more than you currently hold unlocked.'**
  String get errorInsufficientQuantity;

  /// No description provided for @errorIncomeRequiredForGain.
  ///
  /// In en, this message translates to:
  /// **'An active income category is required for a realized gain.'**
  String get errorIncomeRequiredForGain;

  /// No description provided for @errorExpenseRequiredForLoss.
  ///
  /// In en, this message translates to:
  /// **'An active expense category is required for a realized loss.'**
  String get errorExpenseRequiredForLoss;

  /// No description provided for @errorBrokerageFailedAfterBuy.
  ///
  /// In en, this message translates to:
  /// **'Buy posted, but brokerage fee failed: {detail}'**
  String errorBrokerageFailedAfterBuy(String detail);

  /// No description provided for @errorBrokerageFailedAfterSell.
  ///
  /// In en, this message translates to:
  /// **'Sell posted, but brokerage fee failed: {detail}'**
  String errorBrokerageFailedAfterSell(String detail);

  /// No description provided for @errorDividendMustBePositive.
  ///
  /// In en, this message translates to:
  /// **'Dividend amount must be positive.'**
  String get errorDividendMustBePositive;

  /// No description provided for @errorNotInvestmentAccount.
  ///
  /// In en, this message translates to:
  /// **'That is not an investment account.'**
  String get errorNotInvestmentAccount;

  /// No description provided for @errorNoInventoryCompanion.
  ///
  /// In en, this message translates to:
  /// **'This investment account is missing its inventory companion.'**
  String get errorNoInventoryCompanion;

  /// No description provided for @errorInvestmentReversalBlocked.
  ///
  /// In en, this message translates to:
  /// **'Cannot reverse this buy: later sell(s) depend on its units. Reverse dependent sell(s) first: {sells}.'**
  String errorInvestmentReversalBlocked(String sells);

  /// No description provided for @errorMonthlyLimitMustBePositive.
  ///
  /// In en, this message translates to:
  /// **'Monthly limit must be positive.'**
  String get errorMonthlyLimitMustBePositive;

  /// No description provided for @errorTemplateAmountMustBePositive.
  ///
  /// In en, this message translates to:
  /// **'Template amount must be positive.'**
  String get errorTemplateAmountMustBePositive;

  /// No description provided for @errorOfxUnrecognized.
  ///
  /// In en, this message translates to:
  /// **'Could not recognize this file as OFX.'**
  String get errorOfxUnrecognized;

  /// No description provided for @errorCsvEmpty.
  ///
  /// In en, this message translates to:
  /// **'The selected file is empty.'**
  String get errorCsvEmpty;

  /// No description provided for @errorCsvUnreadable.
  ///
  /// In en, this message translates to:
  /// **'Could not read this file as CSV.'**
  String get errorCsvUnreadable;

  /// No description provided for @errorCsvNoRows.
  ///
  /// In en, this message translates to:
  /// **'The selected file has no rows.'**
  String get errorCsvNoRows;

  /// No description provided for @skipMissingDate.
  ///
  /// In en, this message translates to:
  /// **'Missing date.'**
  String get skipMissingDate;

  /// No description provided for @skipUnparseableDate.
  ///
  /// In en, this message translates to:
  /// **'Could not parse date \"{raw}\" with pattern \"{pattern}\".'**
  String skipUnparseableDate(String raw, String pattern);

  /// No description provided for @skipOfxMissingOrInvalidDate.
  ///
  /// In en, this message translates to:
  /// **'Missing or invalid transaction date.'**
  String get skipOfxMissingOrInvalidDate;

  /// No description provided for @skipOfxUnparseableDate.
  ///
  /// In en, this message translates to:
  /// **'Could not parse transaction date \"{raw}\".'**
  String skipOfxUnparseableDate(String raw);

  /// No description provided for @skipMissingAmount.
  ///
  /// In en, this message translates to:
  /// **'Missing amount.'**
  String get skipMissingAmount;

  /// No description provided for @skipUnparseableAmount.
  ///
  /// In en, this message translates to:
  /// **'Could not parse amount \"{raw}\".'**
  String skipUnparseableAmount(String raw);

  /// No description provided for @skipZeroAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount is zero.'**
  String get skipZeroAmount;

  /// No description provided for @skipUnparseableDebitCreditAmount.
  ///
  /// In en, this message translates to:
  /// **'Could not parse the debit or credit amount.'**
  String get skipUnparseableDebitCreditAmount;

  /// No description provided for @skipBothDebitAndCreditNonZero.
  ///
  /// In en, this message translates to:
  /// **'Both debit and credit columns have an amount.'**
  String get skipBothDebitAndCreditNonZero;

  /// No description provided for @skipBothDebitAndCreditZero.
  ///
  /// In en, this message translates to:
  /// **'Both debit and credit columns are zero.'**
  String get skipBothDebitAndCreditZero;

  /// No description provided for @errorBackupCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not create the backup: {detail}'**
  String errorBackupCreateFailed(String detail);

  /// No description provided for @errorBackupRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not restore this backup - wrong passphrase, or not a Smara backup file.'**
  String get errorBackupRestoreFailed;

  /// No description provided for @validationAmountAccountCategoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Amount, account, and category are required.'**
  String get validationAmountAccountCategoryRequired;

  /// No description provided for @validationAmountAccountRequired.
  ///
  /// In en, this message translates to:
  /// **'Amount and account are required.'**
  String get validationAmountAccountRequired;

  /// No description provided for @validationSplitLineIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Every split line needs a category and an amount.'**
  String get validationSplitLineIncomplete;

  /// No description provided for @validationSplitSumMismatch.
  ///
  /// In en, this message translates to:
  /// **'Split lines must add up to the transaction total.'**
  String get validationSplitSumMismatch;

  /// No description provided for @validationFromToAmountRequired.
  ///
  /// In en, this message translates to:
  /// **'From account, to account, and amount are required.'**
  String get validationFromToAmountRequired;

  /// No description provided for @validationAmountArrivedRequired.
  ///
  /// In en, this message translates to:
  /// **'Amount that arrived is required.'**
  String get validationAmountArrivedRequired;

  /// No description provided for @validationChooseReceivingAccount.
  ///
  /// In en, this message translates to:
  /// **'Choose which account received the funds.'**
  String get validationChooseReceivingAccount;

  /// No description provided for @validationAccountCategoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Account and category are required.'**
  String get validationAccountCategoryRequired;

  /// No description provided for @validationFixFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save this fix.'**
  String get validationFixFailed;

  /// No description provided for @validationNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name your main account.'**
  String get validationNameRequired;

  /// No description provided for @validationStillLoading.
  ///
  /// In en, this message translates to:
  /// **'Still loading - try again in a moment.'**
  String get validationStillLoading;

  /// No description provided for @validationSaveAccountNameFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save the account name.'**
  String get validationSaveAccountNameFailed;

  /// No description provided for @validationWrongPin.
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN. Try again.'**
  String get validationWrongPin;

  /// No description provided for @validationCategoryMustBeIncomeOrExpense.
  ///
  /// In en, this message translates to:
  /// **'Category must be Income or Expense.'**
  String get validationCategoryMustBeIncomeOrExpense;

  /// No description provided for @validationOnlyExpenseHasMonthlyLimit.
  ///
  /// In en, this message translates to:
  /// **'Only an Expense category can have a monthly limit.'**
  String get validationOnlyExpenseHasMonthlyLimit;

  /// No description provided for @validationInvalidTemplate.
  ///
  /// In en, this message translates to:
  /// **'Invalid template.'**
  String get validationInvalidTemplate;

  /// No description provided for @validationWrongKeystorePassphrase.
  ///
  /// In en, this message translates to:
  /// **'Wrong passphrase for this keystore file.'**
  String get validationWrongKeystorePassphrase;

  /// No description provided for @validationInvalidKeystoreFile.
  ///
  /// In en, this message translates to:
  /// **'That doesn\'\'t look like a valid keystore file.'**
  String get validationInvalidKeystoreFile;

  /// No description provided for @validationRestorePhraseFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not restore from that recovery phrase.'**
  String get validationRestorePhraseFailed;

  /// No description provided for @validationGenerateKeyFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not generate a signing key on this device: {detail}'**
  String validationGenerateKeyFailed(String detail);

  /// No description provided for @validationSaveCurrencyFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save this currency: {detail}'**
  String validationSaveCurrencyFailed(String detail);

  /// No description provided for @validationMigrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Migration failed. Please try again.'**
  String get validationMigrationFailed;

  /// No description provided for @validationChooseBackupFile.
  ///
  /// In en, this message translates to:
  /// **'Choose a backup file first.'**
  String get validationChooseBackupFile;

  /// No description provided for @validationPassphraseRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a passphrase.'**
  String get validationPassphraseRequired;

  /// No description provided for @validationPinsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'The two PINs do not match.'**
  String get validationPinsDoNotMatch;

  /// No description provided for @validationFeePositiveWithCategory.
  ///
  /// In en, this message translates to:
  /// **'A transfer fee must be a positive amount with an expense category selected.'**
  String get validationFeePositiveWithCategory;

  /// No description provided for @validationFeeMustBeLessThanAmount.
  ///
  /// In en, this message translates to:
  /// **'The fee must be less than the amount for a deducted-fee transfer.'**
  String get validationFeeMustBeLessThanAmount;

  /// No description provided for @validationTransferSavedFeeFailed.
  ///
  /// In en, this message translates to:
  /// **'Transfer saved, but the fee could not be recorded: {detail}'**
  String validationTransferSavedFeeFailed(String detail);

  /// No description provided for @validationEnterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount.'**
  String get validationEnterValidAmount;

  /// No description provided for @validationConfirmWordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Word {n} doesn\'\'t match your saved phrase. Check it and try again.'**
  String validationConfirmWordMismatch(String n);

  /// No description provided for @errorBuyQuantityAndPriceMustBePositive.
  ///
  /// In en, this message translates to:
  /// **'Buy quantity and unit price must be positive.'**
  String get errorBuyQuantityAndPriceMustBePositive;

  /// No description provided for @errorInstrumentArchived.
  ///
  /// In en, this message translates to:
  /// **'Cannot buy an archived instrument.'**
  String get errorInstrumentArchived;

  /// No description provided for @errorNonCashCannotIncludeBrokerage.
  ///
  /// In en, this message translates to:
  /// **'Non-cash acquisitions cannot include brokerage.'**
  String get errorNonCashCannotIncludeBrokerage;

  /// No description provided for @errorBrokerageRequiresExpenseCategory.
  ///
  /// In en, this message translates to:
  /// **'An active expense category is required when brokerage is positive.'**
  String get errorBrokerageRequiresExpenseCategory;

  /// No description provided for @errorSellProceedsMustCoverBrokerage.
  ///
  /// In en, this message translates to:
  /// **'Sell proceeds must be at least the brokerage amount.'**
  String get errorSellProceedsMustCoverBrokerage;

  /// No description provided for @homeSpentOfLimitThisMonth.
  ///
  /// In en, this message translates to:
  /// **'{spent} of {limit} this month'**
  String homeSpentOfLimitThisMonth(String spent, String limit);

  /// No description provided for @unlockBiometricReason.
  ///
  /// In en, this message translates to:
  /// **'Unlock Smara Account'**
  String get unlockBiometricReason;

  /// No description provided for @searchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchLabel;

  /// No description provided for @openingBalance.
  ///
  /// In en, this message translates to:
  /// **'Opening balance'**
  String get openingBalance;

  /// No description provided for @transferToName.
  ///
  /// In en, this message translates to:
  /// **'Transfer: {name}'**
  String transferToName(String name);

  /// No description provided for @feeForTransfer.
  ///
  /// In en, this message translates to:
  /// **'Fee for transfer'**
  String get feeForTransfer;

  /// No description provided for @feeForTransferTo.
  ///
  /// In en, this message translates to:
  /// **'Fee for transfer to {name}'**
  String feeForTransferTo(String name);

  /// No description provided for @couldNotOpenFilePicker.
  ///
  /// In en, this message translates to:
  /// **'Could not open the file picker: {detail}'**
  String couldNotOpenFilePicker(String detail);

  /// No description provided for @pleaseSelectFile.
  ///
  /// In en, this message translates to:
  /// **'Please select a .{extensions} file'**
  String pleaseSelectFile(String extensions);

  /// No description provided for @currencyCodeIso.
  ///
  /// In en, this message translates to:
  /// **'Currency code (ISO 4217, e.g. USD)'**
  String get currencyCodeIso;

  /// No description provided for @splitCounterpartMore.
  ///
  /// In en, this message translates to:
  /// **'{name} +{count} more'**
  String splitCounterpartMore(String name, String count);

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @noneSelected.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get noneSelected;

  /// No description provided for @reviewEntriesBeforeContinuing.
  ///
  /// In en, this message translates to:
  /// **'Review the entries below ({count} total) before continuing.'**
  String reviewEntriesBeforeContinuing(String count);

  /// No description provided for @youReceived.
  ///
  /// In en, this message translates to:
  /// **'You received {amount}'**
  String youReceived(String amount);

  /// No description provided for @leaveBlankIfRateUnknown.
  ///
  /// In en, this message translates to:
  /// **'Leave blank if the exchange rate isn\'\'t known yet.'**
  String get leaveBlankIfRateUnknown;

  /// No description provided for @recordTradeBlurb.
  ///
  /// In en, this message translates to:
  /// **'Record a trade that already happened. This app does not place orders.'**
  String get recordTradeBlurb;

  /// No description provided for @feeOnTopBlurb.
  ///
  /// In en, this message translates to:
  /// **'On: the amount above is the total taken from this account; the fee comes out of it.'**
  String get feeOnTopBlurb;

  /// No description provided for @feeBankBlurb.
  ///
  /// In en, this message translates to:
  /// **'An upfront commission charged by your bank or an intermediary.'**
  String get feeBankBlurb;

  /// No description provided for @validationPinMinLength.
  ///
  /// In en, this message translates to:
  /// **'PIN must be at least 4 digits.'**
  String get validationPinMinLength;

  /// No description provided for @restoreBackupBlurb.
  ///
  /// In en, this message translates to:
  /// **'This replaces everything currently in this app with the backup — it does not merge. Choose a backup file and enter the passphrase you protected it with.'**
  String get restoreBackupBlurb;

  /// No description provided for @actionReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get actionReplace;

  /// No description provided for @hideAccountBody.
  ///
  /// In en, this message translates to:
  /// **'{name} will no longer be available for new transactions.'**
  String hideAccountBody(String name);

  /// No description provided for @hideGroupBody.
  ///
  /// In en, this message translates to:
  /// **'{name} will no longer be offered when creating or reassigning accounts.'**
  String hideGroupBody(String name);

  /// No description provided for @hideCategoryBody.
  ///
  /// In en, this message translates to:
  /// **'{name} will no longer be offered when recording new transactions.'**
  String hideCategoryBody(String name);

  /// No description provided for @hideInstrumentBody.
  ///
  /// In en, this message translates to:
  /// **'Hidden instruments stay on past buys and sells. You can still record a dividend for them.'**
  String get hideInstrumentBody;

  /// No description provided for @nameHidden.
  ///
  /// In en, this message translates to:
  /// **'{name} (hidden)'**
  String nameHidden(String name);

  /// No description provided for @noCurrencySet.
  ///
  /// In en, this message translates to:
  /// **'No currency set'**
  String get noCurrencySet;

  /// No description provided for @deletePayeeBody.
  ///
  /// In en, this message translates to:
  /// **'{name} and its remembered defaults will be removed. Past transactions are unaffected.'**
  String deletePayeeBody(String name);

  /// No description provided for @deleteTemplateBody.
  ///
  /// In en, this message translates to:
  /// **'{name} will no longer be offered as due. Past transactions it already recorded are unaffected.'**
  String deleteTemplateBody(String name);

  /// No description provided for @deleteProfileBody.
  ///
  /// In en, this message translates to:
  /// **'The saved column mapping \"{name}\" will be deleted. Statements already imported with it are unaffected.'**
  String deleteProfileBody(String name);

  /// No description provided for @deleteRuleBody.
  ///
  /// In en, this message translates to:
  /// **'Imports will no longer be auto-categorized by \"{keyword}\". Transactions already categorized using this rule are unaffected.'**
  String deleteRuleBody(String keyword);

  /// No description provided for @firstWeekBlurb.
  ///
  /// In en, this message translates to:
  /// **'Optionally add a credit card or a cash account now - you can always add more accounts later from Settings.'**
  String get firstWeekBlurb;

  /// No description provided for @deliveredToDestination.
  ///
  /// In en, this message translates to:
  /// **'Delivered to destination'**
  String get deliveredToDestination;

  /// No description provided for @deliveredToName.
  ///
  /// In en, this message translates to:
  /// **'Delivered to {name}'**
  String deliveredToName(String name);

  /// No description provided for @youReceivedLessThanExpected.
  ///
  /// In en, this message translates to:
  /// **'You received {amount} {currency} less than expected - choose a category to cover the difference.'**
  String youReceivedLessThanExpected(String amount, String currency);

  /// No description provided for @dateRangeLabel.
  ///
  /// In en, this message translates to:
  /// **'Date range'**
  String get dateRangeLabel;

  /// No description provided for @addTemplate.
  ///
  /// In en, this message translates to:
  /// **'Add template'**
  String get addTemplate;

  /// No description provided for @editTemplate.
  ///
  /// In en, this message translates to:
  /// **'Edit template'**
  String get editTemplate;

  /// No description provided for @validationFillTemplateFields.
  ///
  /// In en, this message translates to:
  /// **'Fill in every field with a valid amount and day.'**
  String get validationFillTemplateFields;

  /// No description provided for @saveCsvExport.
  ///
  /// In en, this message translates to:
  /// **'Save CSV export'**
  String get saveCsvExport;

  /// No description provided for @referenceRate.
  ///
  /// In en, this message translates to:
  /// **'Reference rate'**
  String get referenceRate;

  /// No description provided for @yourRate.
  ///
  /// In en, this message translates to:
  /// **'Your rate'**
  String get yourRate;

  /// No description provided for @leaveBlankIfThisWasAccountCurrency.
  ///
  /// In en, this message translates to:
  /// **'Leave blank if this was in {currency}, the account\'\'s own currency.'**
  String leaveBlankIfThisWasAccountCurrency(String currency);

  /// No description provided for @lockUntilOptional.
  ///
  /// In en, this message translates to:
  /// **'Lock until (optional)'**
  String get lockUntilOptional;

  /// No description provided for @lockedUntilDate.
  ///
  /// In en, this message translates to:
  /// **'Locked until {date}'**
  String lockedUntilDate(String date);

  /// No description provided for @copiedResearchPrompt.
  ///
  /// In en, this message translates to:
  /// **'Copied a research prompt — no browser URL available, or you are offline.'**
  String get copiedResearchPrompt;

  /// No description provided for @openedFavouriteResearchTool.
  ///
  /// In en, this message translates to:
  /// **'Opened your favourite research tool.'**
  String get openedFavouriteResearchTool;

  /// No description provided for @looksLikeGain.
  ///
  /// In en, this message translates to:
  /// **'This looks like a gain'**
  String get looksLikeGain;

  /// No description provided for @looksLikeLoss.
  ///
  /// In en, this message translates to:
  /// **'This looks like a loss'**
  String get looksLikeLoss;

  /// No description provided for @looksLikeBreakEven.
  ///
  /// In en, this message translates to:
  /// **'This looks like break-even'**
  String get looksLikeBreakEven;

  /// No description provided for @sellableQuantity.
  ///
  /// In en, this message translates to:
  /// **'{name} ({qty} sellable)'**
  String sellableQuantity(String name, String qty);

  /// No description provided for @columnN.
  ///
  /// In en, this message translates to:
  /// **'Column {index}'**
  String columnN(String index);

  /// No description provided for @importingLabel.
  ///
  /// In en, this message translates to:
  /// **'Importing...'**
  String get importingLabel;

  /// No description provided for @confirmImport.
  ///
  /// In en, this message translates to:
  /// **'Confirm import'**
  String get confirmImport;

  /// No description provided for @manageSavedCategoryRules.
  ///
  /// In en, this message translates to:
  /// **'Manage Saved Category Rules'**
  String get manageSavedCategoryRules;

  /// No description provided for @statementCurrencyMismatch.
  ///
  /// In en, this message translates to:
  /// **'This file\'\'s currency ({currency}) doesn\'\'t match the selected account\'\'s currency.'**
  String statementCurrencyMismatch(String currency);

  /// No description provided for @categoryRulesTitle.
  ///
  /// In en, this message translates to:
  /// **'Category rules'**
  String get categoryRulesTitle;

  /// No description provided for @possibleDuplicate.
  ///
  /// In en, this message translates to:
  /// **'possible duplicate'**
  String get possibleDuplicate;

  /// No description provided for @unknownCategory.
  ///
  /// In en, this message translates to:
  /// **'Unknown category'**
  String get unknownCategory;

  /// No description provided for @researchPromptIntro.
  ///
  /// In en, this message translates to:
  /// **'Research this publicly listed instrument for a household investor. Identify the issuer, summarize recent news with dates if known, and outline downside risks and upside drivers. Separate facts from speculation. Do not give buy, sell, or hold advice. This is not financial advice.'**
  String get researchPromptIntro;

  /// No description provided for @researchPromptNameLine.
  ///
  /// In en, this message translates to:
  /// **'Name: {name}'**
  String researchPromptNameLine(String name);

  /// No description provided for @researchPromptTickerLine.
  ///
  /// In en, this message translates to:
  /// **'Ticker: {ticker}'**
  String researchPromptTickerLine(String ticker);

  /// No description provided for @researchPromptTickerNoneProvided.
  ///
  /// In en, this message translates to:
  /// **'Ticker: (none provided)'**
  String get researchPromptTickerNoneProvided;

  /// No description provided for @researchPromptIsinLine.
  ///
  /// In en, this message translates to:
  /// **'ISIN: {isin}'**
  String researchPromptIsinLine(String isin);

  /// No description provided for @researchPromptIsinNoneProvided.
  ///
  /// In en, this message translates to:
  /// **'ISIN: (none provided)'**
  String get researchPromptIsinNoneProvided;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'as',
    'bn',
    'brx',
    'de',
    'doi',
    'en',
    'es',
    'fr',
    'gu',
    'hi',
    'hu',
    'id',
    'it',
    'ja',
    'kn',
    'ko',
    'kok',
    'ks',
    'mai',
    'ml',
    'mni',
    'mr',
    'ms',
    'ne',
    'nl',
    'or',
    'pa',
    'pl',
    'pt',
    'ro',
    'ru',
    'sa',
    'sat',
    'sd',
    'ta',
    'te',
    'th',
    'tr',
    'uk',
    'ur',
    'vi',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'as':
      return AppLocalizationsAs();
    case 'bn':
      return AppLocalizationsBn();
    case 'brx':
      return AppLocalizationsBrx();
    case 'de':
      return AppLocalizationsDe();
    case 'doi':
      return AppLocalizationsDoi();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'gu':
      return AppLocalizationsGu();
    case 'hi':
      return AppLocalizationsHi();
    case 'hu':
      return AppLocalizationsHu();
    case 'id':
      return AppLocalizationsId();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'kn':
      return AppLocalizationsKn();
    case 'ko':
      return AppLocalizationsKo();
    case 'kok':
      return AppLocalizationsKok();
    case 'ks':
      return AppLocalizationsKs();
    case 'mai':
      return AppLocalizationsMai();
    case 'ml':
      return AppLocalizationsMl();
    case 'mni':
      return AppLocalizationsMni();
    case 'mr':
      return AppLocalizationsMr();
    case 'ms':
      return AppLocalizationsMs();
    case 'ne':
      return AppLocalizationsNe();
    case 'nl':
      return AppLocalizationsNl();
    case 'or':
      return AppLocalizationsOr();
    case 'pa':
      return AppLocalizationsPa();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ro':
      return AppLocalizationsRo();
    case 'ru':
      return AppLocalizationsRu();
    case 'sa':
      return AppLocalizationsSa();
    case 'sat':
      return AppLocalizationsSat();
    case 'sd':
      return AppLocalizationsSd();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
    case 'th':
      return AppLocalizationsTh();
    case 'tr':
      return AppLocalizationsTr();
    case 'uk':
      return AppLocalizationsUk();
    case 'ur':
      return AppLocalizationsUr();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
