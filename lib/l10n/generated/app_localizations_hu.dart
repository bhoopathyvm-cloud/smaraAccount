// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hungarian (`hu`).
class AppLocalizationsHu extends AppLocalizations {
  AppLocalizationsHu([String locale = 'hu']) : super(locale);

  @override
  String get appTitle => 'Smara könyvelés';

  @override
  String get navHome => 'Kezdőlap';

  @override
  String get navRegister => 'Napló';

  @override
  String get navSummary => 'Összesítő';

  @override
  String get navAccounts => 'Számlák';

  @override
  String get navCategories => 'Kategóriák';

  @override
  String get actionCancel => 'Mégse';

  @override
  String get actionSave => 'Mentés';

  @override
  String get actionDelete => 'Törlés';

  @override
  String get actionDone => 'Kész';

  @override
  String get actionContinue => 'Tovább';

  @override
  String get actionDismiss => 'Bezárás';

  @override
  String get actionRetry => 'Újra';

  @override
  String get actionSkip => 'Kihagyás';

  @override
  String get actionConfirm => 'Megerősítés';

  @override
  String get actionAdd => 'Hozzáadás';

  @override
  String get actionEdit => 'Szerkesztés';

  @override
  String get actionRename => 'Átnevezés';

  @override
  String get actionHide => 'Elrejtés';

  @override
  String get actionCreate => 'Létrehozás';

  @override
  String get actionCloseApp => 'Alkalmazás bezárása';

  @override
  String get actionUnlock => 'Feloldás';

  @override
  String get actionSettle => 'Rendezés';

  @override
  String get actionFinish => 'Befejezés';

  @override
  String get actionPreview => 'Előnézet';

  @override
  String get actionImport => 'Importálás';

  @override
  String get actionExportCsv => 'CSV exportálása';

  @override
  String get actionChooseFile => 'Fájl kiválasztása';

  @override
  String get actionRestore => 'Visszaállítás';

  @override
  String get actionFix => 'Javítás';

  @override
  String get actionBuy => 'Vétel';

  @override
  String get actionSell => 'Eladás';

  @override
  String get actionDividend => 'Osztalék';

  @override
  String get actionRecordBuy => 'Vétel rögzítése';

  @override
  String get actionRecordSell => 'Eladás rögzítése';

  @override
  String get actionRecordDividend => 'Osztalék rögzítése';

  @override
  String get actionPayCard => 'Kártya fizetése';

  @override
  String get actionTransfer => 'Átutalás';

  @override
  String get actionRecordTransaction => 'Tranzakció rögzítése';

  @override
  String get actionImportStatement => 'Kivonat importálása';

  @override
  String get actionClearDates => 'Dátumok törlése';

  @override
  String get actionClearSearch => 'Keresés és szűrők törlése';

  @override
  String get actionUseBiometrics => 'Biometrikus azonosítás használata';

  @override
  String get actionSetPin => 'PIN beállítása';

  @override
  String get actionChangePin => 'PIN módosítása';

  @override
  String get actionSaveBackup => 'Biztonsági mentés';

  @override
  String get actionRestoreBackup => 'Biztonsági mentés visszaállítása';

  @override
  String get actionSaveRule => 'Szabály mentése';

  @override
  String get actionConfirmFix => 'Javítás megerősítése';

  @override
  String get captureSpent => 'Kiadás';

  @override
  String get captureReceived => 'Bevétel';

  @override
  String get captureMovedMoney => 'Pénz mozgatva';

  @override
  String get captureImportStatement => 'Kivonat importálása';

  @override
  String get settingsTitle => 'Beállítások';

  @override
  String get settingsLanguage => 'Nyelv';

  @override
  String get settingsLanguageSystem => 'Eszköz nyelve';

  @override
  String get settingsFetchFxRates => 'Referencia árfolyamok lekérése';

  @override
  String get settingsFetchFxRatesSubtitle =>
      'Devizák közötti átutalásoknál a célösszeg mellett tájékoztató jellegű piaci árfolyamot mutat, kizárólag összehasonlításra - soha nem használjuk az összeg kitöltésére.';

  @override
  String get settingsRateProvider => 'Árfolyam-szolgáltató';

  @override
  String get settingsFetchMarketPrices =>
      'Piaci árak lekérése a befektetésekhez';

  @override
  String get settingsFetchMarketPricesSubtitle =>
      'Az utolsó árakat keresi ki azoknál az eszközöknél, amelyeknek van tickerük vagy ISIN-jük, hogy megbecsülje a portfólió értékét. Soha nem használjuk ügylet rögzítésére, és soha nem küldi el, mennyit tart belőle.';

  @override
  String get settingsMarketPriceProvider => 'Piaci ár szolgáltató';

  @override
  String get settingsFavouriteResearchTool => 'Kedvenc kutatóeszköz';

  @override
  String get settingsFavouriteResearchToolSubtitle =>
      'Ha a portfólión rákoppint egy eszköz nevére, ez az eszköz nyílik meg a böngészőben egy kutatási felszólítással — ez nem integráció, és nem tanács.';

  @override
  String get settingsBackup => 'Biztonsági mentés';

  @override
  String get settingsBackupBlurb =>
      'Mentsen egy titkosított másolatot a könyveiről egy Ön által választott helyre, vagy állítsa vissza onnan. Ez különbözik a helyreállítási kifejezéstől vagy a kulcstartó fájltól, amelyek az aláíró kulcsát mentik, nem a könyveit.';

  @override
  String get settingsLock => 'Zárolás';

  @override
  String get settingsLockBlurb =>
      'Az alkalmazás megnyitásához kérjen PIN-t, vagy ahol elérhető, biometrikus azonosítást.';

  @override
  String get settingsRequireUnlock =>
      'Feloldás kötelezővé tétele az alkalmazás megnyitásához';

  @override
  String get settingsLockAfter => 'Zárolás ennyi idő után';

  @override
  String get settingsLockImmediately => 'Azonnal';

  @override
  String get settingsLock1Minute => '1 perc';

  @override
  String get settingsLock5Minutes => '5 perc';

  @override
  String get settingsLock15Minutes => '15 perc';

  @override
  String get settingsAllowBiometrics =>
      'Biometrikus azonosítás engedélyezése is';

  @override
  String get settingsHideSnapshot =>
      'Egyenlegek elrejtése az alkalmazásváltóban';

  @override
  String get settingsHideSnapshotSubtitle =>
      'Elhomályosítja ezt a képernyőt, amikor másik alkalmazásra vált, hogy ne legyen egy pillantásra látható az alkalmazásváltóban.';

  @override
  String get settingsHideSnapshotUnavailable =>
      'Az egyenlegek elrejtése az alkalmazásváltóban ezen a platformon nem érhető el.';

  @override
  String get settingsPayees => 'Kedvezményezettek';

  @override
  String get settingsManagePayees => 'Kedvezményezettek kezelése';

  @override
  String get settingsPayeesBlurb =>
      'Megjegyzett kedvezményezett nevek és azok alapértelmezett kategóriája és számlája, amelyeket az automatikus kiegészítés javasol tranzakció rögzítésekor.';

  @override
  String get settingsRecurring => 'Ismétlődő sablonok';

  @override
  String get settingsManageRecurring => 'Ismétlődő sablonok kezelése';

  @override
  String get settingsRecurringBlurb =>
      'Havonta ismétlődő számlák vagy bevételek, például lakbér vagy fizetés. Egy esedékes sablon megjelenik a Kezdőlapon, hogy egy koppintással rögzíthesse - soha nem kerül automatikusan könyvelésre.';

  @override
  String get settingsAbout => 'Névjegy';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get providerFrankfurter => 'Frankfurter (EKB árfolyamok)';

  @override
  String get providerOpenErApi => 'ExchangeRate-API (open.er-api.com)';

  @override
  String get providerStooq => 'Stooq (napi árfolyamok)';

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
  String get systemGroupCashEquivalents =>
      'Készpénz és készpénz-egyenértékesek';

  @override
  String get systemGroupPensionRetirement => 'Nyugdíj és nyugdíj-megtakarítás';

  @override
  String get systemGroupCreditShortTerm => 'Hitel és rövid lejáratú tartozás';

  @override
  String get systemGroupLoansMortgages => 'Kölcsönök és jelzáloghitelek';

  @override
  String get systemGroupInvestments => 'Befektetések';

  @override
  String get systemAccountCashBank => 'Készpénz és bank';

  @override
  String get systemCategorySalary => 'Fizetés';

  @override
  String get systemCategoryOtherIncome => 'Egyéb bevétel';

  @override
  String get systemCategoryGroceries => 'Élelmiszer';

  @override
  String get systemCategoryRentMortgage => 'Lakbér/jelzálog';

  @override
  String get systemCategoryUtilities => 'Rezsi';

  @override
  String get systemCategoryTransport => 'Közlekedés';

  @override
  String get systemCategoryFoodOut => 'Étkezés étteremben';

  @override
  String get systemCategoryPhone => 'Telefon';

  @override
  String get systemCategoryHealth => 'Egészség';

  @override
  String get systemCategoryOtherExpense => 'Egyéb kiadás';

  @override
  String get systemDescriptionCsvImport => 'CSV-importálás';

  @override
  String get systemDescriptionOfxImport => 'OFX-importálás';

  @override
  String get homeThisMonth => 'EZ A HÓNAP';

  @override
  String get homeMoneyInTransit => 'ÚTON LÉVŐ PÉNZ';

  @override
  String get homeWhatYouHaveMinusWhatYouOwe =>
      'AMI ÖNNÉL VAN MÍNUSZ AMIVEL TARTOZIK';

  @override
  String homeWhatYouHave(String amount, String currency) {
    return 'Amije van: $amount $currency';
  }

  @override
  String homeNetPosition(String amount, String currency) {
    return '$amount $currency';
  }

  @override
  String homeHaveAndOwe(String haveAmount, String currency, String oweAmount) {
    return 'Amije van: $haveAmount $currency  •  Amivel tartozik: $oweAmount $currency';
  }

  @override
  String youSentFrom(String amount, String currency, String name) {
    return 'Ön $amount $currency összeget küldött innen: $name';
  }

  @override
  String youSentTo(String amount, String currency, String name) {
    return 'Ön $amount $currency összeget küldött ide: $name';
  }

  @override
  String get hiddenLabel => 'Elrejtve';

  @override
  String get allAccounts => 'Összes számla';

  @override
  String savedToPath(String path) {
    return 'Mentve ide: $path';
  }

  @override
  String get keystoreExportFailed =>
      'Nem sikerült exportálni a kulcstartó fájlt. Ezt a lépést kihagyhatja.';

  @override
  String get enterPassphraseToProtect =>
      'Adjon meg egy jelmondatot a fájl védelméhez.';

  @override
  String get homeTapWhenArrived => 'Koppintson, ha tudja, mi érkezett meg';

  @override
  String homeReturnedTo(String name) {
    return 'Visszaküldve ide: $name';
  }

  @override
  String get homeDueToday => 'MA ESEDÉKES';

  @override
  String homeDueLine(String category, String account) {
    return '$category · $account · koppintson a rögzítéshez';
  }

  @override
  String get homeOverLimit => 'Limit túllépve';

  @override
  String homeSpentOfLimit(String spent, String limit) {
    return '$spent / $limit';
  }

  @override
  String homeRemaining(String amount) {
    return 'Hátralévő: $amount';
  }

  @override
  String get homeNoAccounts => 'Nincs számla';

  @override
  String get homeCashRegister => 'Készpénzállomány';

  @override
  String get homeMarketEstimate => 'Piaci becslés';

  @override
  String get registerTitle => 'Napló';

  @override
  String get registerSearchHint => 'Leírás, kategória vagy összeg';

  @override
  String get registerNoTransactions => 'Még nincs tranzakció';

  @override
  String get registerNoEntries => 'Még nincs rögzített tétel.';

  @override
  String get registerSpentOnly => 'Csak kiadások';

  @override
  String get registerReceivedOnly => 'Csak bevételek';

  @override
  String get registerAll => 'Összes';

  @override
  String get registerUnverified =>
      'Nincs ellenőrizve - kizárva az összesítésből';

  @override
  String get registerSuperseded =>
      'Migráció által felülírva - kizárva az összesítésből';

  @override
  String get summaryTitle => 'Összesítő';

  @override
  String get summaryTotalIncome => 'Összes bevétel';

  @override
  String get summaryTotalExpense => 'Összes kiadás';

  @override
  String summaryDateRange(String start, String end) {
    return '$start - $end';
  }

  @override
  String get accountsTitle => 'Számlák';

  @override
  String get categoriesTitle => 'Kategóriák';

  @override
  String get accountName => 'Számla neve';

  @override
  String get createAccount => 'Számla létrehozása';

  @override
  String get createGroup => 'Csoport létrehozása';

  @override
  String get editGroup => 'Csoport szerkesztése';

  @override
  String get renameAccount => 'Számla átnevezése';

  @override
  String get renameCategory => 'Kategória átnevezése';

  @override
  String get addCategory => 'Kategória hozzáadása';

  @override
  String get groupLabel => 'Csoport';

  @override
  String get kindLabel => 'Típus';

  @override
  String get asset => 'Eszköz';

  @override
  String get liability => 'Kötelezettség';

  @override
  String get income => 'Bevétel';

  @override
  String get expense => 'Kiadás';

  @override
  String get thisAccountHoldsInvestments =>
      'Ez a számla befektetéseket tartalmaz';

  @override
  String get thisAccountHoldsInvestmentsSubtitle =>
      'Készpénz plusz állomány, amelyet Vétel, Eladás és Osztalék funkciókkal rögzít.';

  @override
  String get thisIsACreditCard => 'Ez egy hitelkártya';

  @override
  String get openingBalanceOptional => 'Nyitóegyenleg (opcionális)';

  @override
  String get currencyIso => 'Pénznem (ISO 4217)';

  @override
  String get currencyIsoExample => 'Pénznem (ISO 4217, pl. USD)';

  @override
  String get hideAccountTitle => 'Elrejti a számlát az új tételek elől?';

  @override
  String get hideCategoryTitle => 'Elrejti a kategóriát az új tételek elől?';

  @override
  String get hideGroupTitle => 'Elrejti a csoportot az új tételek elől?';

  @override
  String get reassignGroup => 'Csoport újbóli hozzárendelése';

  @override
  String get transferRemainingBalance => 'Fennmaradó egyenleg átutalása';

  @override
  String get monthlyLimit => 'Havi keret';

  @override
  String get monthlyLimitHint => 'Keret (üresen hagyva törli)';

  @override
  String get monthlyLimitBlurb =>
      'Egy opcionális, hó eleje óta eltelt kiadási útmutató ehhez a kiadási kategóriához.';

  @override
  String get manageCategoryRules => 'Kategóriaszabályok kezelése';

  @override
  String get amount => 'Összeg';

  @override
  String get category => 'Kategória';

  @override
  String get account => 'Számla';

  @override
  String get fromAccount => 'Forrásszámla';

  @override
  String get toAccount => 'Célszámla';

  @override
  String get descriptionOptional => 'Leírás (opcionális)';

  @override
  String get alsoRememberPayee => 'Kedvezményezettként is megjegyzés';

  @override
  String get splitIntoCategories => 'Felosztás több kategóriára';

  @override
  String categoryN(String n) {
    return '$n. kategória';
  }

  @override
  String get destinationAmount => 'Célösszeg';

  @override
  String get destinationAmountOptional => 'Célösszeg (opcionális)';

  @override
  String get accountCurrencyAmountOptional =>
      'Számla pénznemében megadott összeg (opcionális)';

  @override
  String get transactionCurrencyOptional => 'Tranzakció pénzneme (opcionális)';

  @override
  String get feeOptional => 'Díj (opcionális)';

  @override
  String get feeAmount => 'Díj összege';

  @override
  String get feeCategory => 'Díj kategóriája';

  @override
  String get feeDescriptionOptional => 'Díj leírása (opcionális)';

  @override
  String get feeDeducted => 'A díjat a fenti összegből vonjuk le';

  @override
  String get needTwoAccountsToTransfer =>
      'Az átutaláshoz hozzon létre legalább két aktív számlát.';

  @override
  String get whatArrivedTitle => 'Mi érkezett meg?';

  @override
  String get whatArrivedBlurb => 'Adja meg, mi érkezett meg valójában.';

  @override
  String get amountThatArrived => 'Megérkezett összeg';

  @override
  String get feeLossCategory => 'Díj / veszteség kategória';

  @override
  String get alreadySettled => 'Már rendezve.';

  @override
  String get holdingsTitle => 'Állomány';

  @override
  String get holdingsCash => 'Készpénz';

  @override
  String get holdingsInventory => 'ÁLLOMÁNY';

  @override
  String holdingsBook(String amount, String currency) {
    return 'Könyv szerinti (készpénz + bekerülési érték) $amount $currency';
  }

  @override
  String holdingsMarketEstimate(String amount, String currency) {
    return 'Piaci becslés $amount $currency';
  }

  @override
  String get holdingsNoHoldings =>
      'Még nincs állomány. Egy eszköz hozzáadásához rögzítsen egy vételt.';

  @override
  String get holdingsQuotesBlurb =>
      'Az árfolyamok becslések, nem bróker árak. Ez az alkalmazás nem ad le megbízásokat.';

  @override
  String get holdingsTapNameToResearch =>
      'Koppintson a névre a kutatáshoz. Az árfolyamok becslések, nem tanácsok.';

  @override
  String get instrument => 'Eszköz';

  @override
  String get newInstrument => 'Új eszköz';

  @override
  String get renameInstrument => 'Eszköz átnevezése';

  @override
  String get instrumentActions => 'Eszközműveletek';

  @override
  String hideInstrumentTitle(String name) {
    return 'Elrejti ezt: $name?';
  }

  @override
  String get tickerOptional => 'Ticker (opcionális)';

  @override
  String get isinOptional => 'ISIN (opcionális)';

  @override
  String get quantity => 'Mennyiség';

  @override
  String get unitPrice => 'Egységár';

  @override
  String get brokerageOptional => 'Bróker jutalék (opcionális)';

  @override
  String get brokerageExpenseCategory => 'Bróker jutalék kiadási kategória';

  @override
  String get incomeCategory => 'Bevételi kategória';

  @override
  String get gainIncomeCategory => 'Nyereség bevételi kategória';

  @override
  String get lossExpenseCategory => 'Veszteség kiadási kategória';

  @override
  String get nonCash => 'Nem készpénzes';

  @override
  String get cash => 'Készpénz';

  @override
  String get locked => 'Zárolva';

  @override
  String get lockUntilHint =>
      'Ez az Ön saját feljegyzése egy korlátozásról, nem bróker szabály.';

  @override
  String get instrumentKindStock => 'Részvény';

  @override
  String get instrumentKindEtf => 'ETF';

  @override
  String get instrumentKindMutualFund => 'Befektetési alap';

  @override
  String get instrumentKindBond => 'Kötvény';

  @override
  String get instrumentKindOther => 'Egyéb';

  @override
  String get quoteUseLive => 'Élő árfolyam';

  @override
  String get quoteUseCached => 'Gyorsítótárazott árfolyam';

  @override
  String get quoteUseStale => 'Elavult árfolyam';

  @override
  String get quoteUseMissing => 'Bekerülési érték használata (nincs árfolyam)';

  @override
  String get quoteUseDisabled =>
      'Árfolyamok kikapcsolva — bekerülési érték/gyorsítótár használata';

  @override
  String get quoteUseCurrencyMismatch =>
      'Bekerülési érték használata (az árfolyam pénzneme eltér)';

  @override
  String unrealizedLabel(String amount, String currency) {
    return 'Nem realizált $amount $currency';
  }

  @override
  String holdingsUnitsCost(String qty) {
    return '$qty egység · ';
  }

  @override
  String get recoveryPhraseTitle => 'Az Ön helyreállítási kifejezése';

  @override
  String get recoveryPhraseConfirmTitle => 'Erősítse meg a kifejezését';

  @override
  String get recoveryPhraseBlurb =>
      'Ez a 24 szó az egyetlen módja annak, hogy visszaállítsa tranzakciós előzményeit, ha ez az eszköz elvész, visszaáll az alapállapotba, vagy kicserélik. A Smara Accountingnak nincs szervere, és nem tudja Ön helyett visszaállítani ezeket.\n\nHa ezt az eszközt és ezt a kifejezést együtt elveszti, minden Ön által rögzített tranzakció véglegesen ellenőrizhetetlenné válik.';

  @override
  String get recoveryPhraseWriteDown =>
      'Írja le ezeket a szavakat sorrendben, és tárolja őket biztonságos helyen, ettől az eszköztől elkülönítve.';

  @override
  String get iveSavedRecoveryPhrase =>
      'Elmentettem a helyreállítási kifejezésemet';

  @override
  String get confirmPhraseBlurb =>
      'Adja meg a kért szavakat az imént elmentett kifejezésből.';

  @override
  String wordNumber(String n) {
    return '$n. szó';
  }

  @override
  String get keystoreExportTitle => 'Kulcstartó fájl exportálása';

  @override
  String get keystoreExportBlurb =>
      'A helyreállítási kifejezés mellett elmenthet egy titkosított kulcstartó fájlt is, amelyet az Ön által választott jelmondat véd. Ez opcionális - a helyreállítási kifejezés önmagában mindig elegendő az aláíró kulcs visszaállításához.';

  @override
  String get keystorePassphrase => 'Jelmondat';

  @override
  String get exportKeystoreFile => 'Kulcstartó fájl exportálása';

  @override
  String get chooseCurrencyTitle => 'Válassza ki a pénznemét';

  @override
  String get chooseCurrencyBlurb =>
      'Minden számlacsoport (Készpénz és készpénz-egyenértékesek, Nyugdíj stb.) egyelőre ezt az egy pénznemet használja. Később egy új csoport létrehozásával továbbra is hozzáadhat más pénznemű számlákat.';

  @override
  String get currencyBackfillTitle =>
      'Válasszon pénznemet a meglévő csoportokhoz';

  @override
  String get currencyBackfillBlurb =>
      'Ez az alkalmazás most már több pénznemet is támogat. A meglévő számláinak és számlacsoportjainak pénznemre van szükségük - mivel mindegyiket a funkció bevezetése előtt hozták létre, egyetlen választás vonatkozik mindegyikükre.';

  @override
  String get firstAccountTitle => 'Nevezze el a számláját';

  @override
  String get firstAccountBlurb =>
      'Ez az a számla, amely már be van állítva Önnek - adjon neki egy Ön számára ismerős nevet, például a bankjáét. Ezután rögzít egy Kiadást vagy Bevételt, majd megvédi az eszközt a helyreállítási kifejezésével.';

  @override
  String get whatsMainAccountCalled => 'Mi a fő számlájának a neve?';

  @override
  String get restoreTitle => 'Aláíró kulcs visszaállítása';

  @override
  String get restoreBlurb =>
      'Ezen az eszközön léteznek könyvek, de nincs hozzájuk illő aláíró kulcs. Állítsa vissza az elmentett helyreállítási kifejezéséből vagy kulcstartó fájljából - az adatai a szokásos módon ellenőrizhetők lesznek, és semmi sem lesz újra aláírva vagy módosítva.';

  @override
  String get recoveryPhrase24 => 'Helyreállítási kifejezés (mind a 24 szó)';

  @override
  String get keystoreFile => 'Kulcstartó fájl';

  @override
  String get keystoreFileContents => 'Kulcstartó fájl tartalma';

  @override
  String get optionalBackupFile => 'Opcionális biztonsági mentés fájl';

  @override
  String get iDontHavePhrase =>
      'Nincs meg a helyreállítási kifejezésem vagy a kulcstartó fájlom';

  @override
  String get migrationTitle => 'Áttérés új kulcsra';

  @override
  String get migrationBlurb =>
      'A helyreállítási kifejezés vagy a kulcstartó fájl nélkül ennek az eszköznek az aláíró kulcsa nem állítható vissza. Elindíthat egy új kulcsot. A régi tételek láthatók maradnak, de felülíródnak.';

  @override
  String get iConfirmBooksValid =>
      'Megerősítem, hogy a jelenlegi könyvek érvényesek';

  @override
  String get whyWeDontEdit => 'Miért nem szerkesztjük a régi tételeket';

  @override
  String get whyWeDontEditBody =>
      'Amikor kijavít egy hibát, megtartjuk a régi sort, és egy korrekciót adunk hozzá mellé, ahelyett hogy megváltoztatnánk, amit már beírt. Így az előzményei mindig pontosan mutatják, mi történt, és mikor javította ki — semmi sem változik csendben a háta mögött.';

  @override
  String get lockTitle => 'Feloldás';

  @override
  String get lockScreenTitle => 'Zárolva';

  @override
  String get enterPinToContinue => 'PIN megadása a folytatáshoz';

  @override
  String get pinLabel => 'PIN';

  @override
  String get setPinTitle => 'PIN beállítása';

  @override
  String get currentPin => 'Jelenlegi PIN';

  @override
  String get newPin => 'Új PIN';

  @override
  String get confirmPin => 'PIN megerősítése';

  @override
  String get confirmNewPin => 'Új PIN megerősítése';

  @override
  String get firstWeekTitle => 'Állítsa be a számláit';

  @override
  String get addCashAccount => 'Készpénzszámla hozzáadása';

  @override
  String get addCreditCard => 'Hitelkártya hozzáadása';

  @override
  String get cashAccountName => 'Készpénzszámla neve';

  @override
  String get cardName => 'Kártya neve';

  @override
  String get paidFromBank => 'Bankból fizetve';

  @override
  String get paidFromCard => 'Kártyából fizetve';

  @override
  String get choosePassphraseTitle =>
      'Válasszon jelmondatot ennek a biztonsági mentésnek a védelméhez. Ha elfelejti, nincs helyreállítás.';

  @override
  String get replaceBooksTitle => 'Lecseréli a helyi könyveit?';

  @override
  String get replaceBooksBody =>
      'Ez lecseréli mindazt, ami jelenleg ebben az alkalmazásban van, a biztonsági mentésre. Ezután zárja be és nyissa meg újra az alkalmazást.';

  @override
  String get chooseBackupFileFirst =>
      'Először válasszon biztonsági mentés fájlt.';

  @override
  String get backupRestored => 'Biztonsági mentés visszaállítva';

  @override
  String get backupRestoredBody =>
      'A könyvei helyreálltak. A folytatáshoz zárja be és nyissa meg újra az alkalmazást.';

  @override
  String get fixThisEntry => 'Ennek a tételnek a javítása';

  @override
  String get fixBlurb =>
      'A régi sor pontosan úgy marad, ahogy volt. A megerősítés hozzáad egy sztornó sort és a javított sort.';

  @override
  String get importStatementTitle => 'Kivonat importálása';

  @override
  String get importOfx => 'OFX importálása';

  @override
  String get importOfxQfxFile => 'OFX / QFX fájl importálása';

  @override
  String get importCsvFile => 'CSV fájl importálása';

  @override
  String get whatKindOfStatement => 'Milyen típusú kivonatfájlja van?';

  @override
  String get chooseAccountForFile =>
      'Válassza ki, melyik számlához tartozik ez a fájl.';

  @override
  String get importIntoAccount => 'Importálás ebbe a számlába';

  @override
  String get useSavedProfile => 'Mentett profil használata';

  @override
  String get saveMappingProfile =>
      'Ennek a hozzárendelésnek mentése profilként (opcionális)';

  @override
  String get renameProfile => 'Profil átnevezése';

  @override
  String get deleteProfileTitle => 'Törli a profilt?';

  @override
  String get fileHasHeader => 'A fájl fejlécsort tartalmaz';

  @override
  String get dateColumn => 'Dátum oszlop';

  @override
  String get dateFormatHint => 'Dátumformátum (pl. éééé.HH.nn)';

  @override
  String get amountColumn => 'Összeg oszlop';

  @override
  String get amountConvention => 'Összeg jelölési szabály';

  @override
  String get signedAmountColumn => 'Előjeles összeg oszlop';

  @override
  String get separateDebitCredit => 'Külön terhelés / jóváírás oszlop';

  @override
  String get debitColumn => 'Terhelés oszlop';

  @override
  String get creditColumn => 'Jóváírás oszlop';

  @override
  String get decimalSeparator => 'Tizedesjel (. vagy ,)';

  @override
  String get descriptionColumns => 'Leírás oszlop(ok)';

  @override
  String get referenceIdColumn => 'Referenciaazonosító oszlop (opcionális)';

  @override
  String get skippedRows => 'Kihagyott sorok';

  @override
  String parsedTransactionCount(String count) {
    return '$count tranzakció feldolgozva';
  }

  @override
  String skippedOrExcludedCount(String count) {
    return '$count kihagyva vagy kizárva';
  }

  @override
  String postedFailedCount(String posted, String failed) {
    return '$posted könyvelve, $failed sikertelen';
  }

  @override
  String get categoryForAll => 'Kategória mindenre';

  @override
  String get saveAsRule => 'Menti szabályként?';

  @override
  String get saveAsRuleBlurb =>
      'A jövőbeli importálások, amelyek leírása tartalmazza ezt a kulcsszót, ezt a kategóriát fogják használni.';

  @override
  String get keyword => 'Kulcsszó';

  @override
  String get noSavedRules =>
      'Még nincs mentett szabály. Rendeljen kategóriát egy sorcsoporthoz a szabály mentéséhez.';

  @override
  String get deleteRuleTitle => 'Törli a szabályt?';

  @override
  String get editRule => 'Szabály szerkesztése';

  @override
  String rowsGrouped(String count) {
    return '$count sor';
  }

  @override
  String selectStatementFile(String extensions) {
    return 'Válasszon egy $extensions kivonatfájlt az importáláshoz';
  }

  @override
  String get payeesTitle => 'Kedvezményezettek';

  @override
  String get addPayee => 'Kedvezményezett hozzáadása';

  @override
  String get renamePayee => 'Kedvezményezett átnevezése';

  @override
  String get deletePayeeTitle => 'Törli a kedvezményezettet?';

  @override
  String get noPayeesYet => 'Még nincs kedvezményezett';

  @override
  String get recurringTitle => 'Ismétlődő sablonok';

  @override
  String get noRecurringYet => 'Még nincs ismétlődő sablon';

  @override
  String get deleteTemplateTitle => 'Törli az ismétlődő sablont?';

  @override
  String get dayOfMonth => 'Hónap napja (1-31)';

  @override
  String get dayOfMonthNote =>
      'A kevesebb nappal rendelkező hónap a saját utolsó napját használja.';

  @override
  String dayOfMonthLine(String day) {
    return 'A hónap $day. napja - ';
  }

  @override
  String get name => 'Név';

  @override
  String get none => 'Nincs';

  @override
  String get currency => 'Pénznem';

  @override
  String get errorGeneric => 'Hiba történt. Próbálja újra.';

  @override
  String get errorSigningIdentityMismatch =>
      'Ez a helyreállítási kifejezés vagy kulcstartó fájl nem egyezik egyetlen aláíró identitással sem ebben az adatbázisban.';

  @override
  String get errorInvalidLedgerBackup =>
      'Ez a fájl nem érvényes Smara biztonsági mentés.';

  @override
  String get errorInvalidLedgerBackupNoIdentity =>
      'Ennek a biztonsági mentésnek nincs aláíró identitása - ez nem érvényes Smara biztonsági mentés.';

  @override
  String get errorInvalidLedgerBackupUnverified =>
      'Ez a biztonsági mentés nem igazolódott sértetlen könyvekként, ezért nem lett visszaállítva.';

  @override
  String errorInvalidLedgerBackupUnreadable(String detail) {
    return 'Ez a fájl nem nyitható meg Smara biztonsági mentésként: $detail';
  }

  @override
  String get errorForeignBackupIdentity =>
      'Ez a biztonsági mentés egy másik aláíró identitáshoz tartozik, mint amelyik ezen az eszközön van.';

  @override
  String get errorAccountNotFinancial => 'Ez nem pénzügyi számla.';

  @override
  String get errorAccountArchived => 'Az a számla el van rejtve.';

  @override
  String get errorAccountNotArchived => 'Az a számla nincs elrejtve.';

  @override
  String get errorAccountNoPositiveBalanceToCloseOut =>
      'Nincs fennmaradó egyenleg átutalásra.';

  @override
  String get errorAccountHasNoGroup =>
      'Ahhoz a számlához nincs csoport rendelve.';

  @override
  String get errorGroupHasNoCurrency =>
      'Annak a csoportnak még nincs beállítva pénzneme.';

  @override
  String get errorGroupNotFound => 'Az a számlacsoport nem található.';

  @override
  String get errorInvestmentAccountsMustBeAssets =>
      'Csak eszközszámlák jelölhetők meg befektetési számlaként.';

  @override
  String get errorCreditCardsMustBeLiabilities =>
      'Csak kötelezettségszámlák jelölhetők meg hitelkártyaként.';

  @override
  String get errorOpeningBalanceMustBePositive =>
      'Ha meg van adva, a nyitóegyenlegnek pozitívnak kell lennie.';

  @override
  String get errorAccountTypeDoesNotMatchGroup =>
      'Az a számlatípus nem egyezik a csoporttal.';

  @override
  String get errorLastActiveAccount =>
      'Az utolsó aktív pénzügyi számla nem rejthető el.';

  @override
  String get errorCurrencyRequiredToCreateGroup =>
      'A csoport létrehozásához pénznem szükséges.';

  @override
  String get errorSystemGroupCannotBeArchived =>
      'A beépített számlacsoportok nem rejthetők el.';

  @override
  String get errorGroupAlreadyArchived => 'Az a csoport már el van rejtve.';

  @override
  String get errorCannotArchiveGroupWithAccounts =>
      'Nem rejthető el olyan csoport, amelyben még vannak aktív számlák.';

  @override
  String get errorSystemGroupNeverArchived =>
      'A beépített számlacsoportok soha nincsenek elrejtve.';

  @override
  String get errorAccountGroupsCannotBeDeleted =>
      'A számlacsoportok nem törölhetők.';

  @override
  String get errorCannotReassignDifferentCurrency =>
      'Ez a számla nem helyezhető át eltérő pénznemű csoportba.';

  @override
  String get errorCannotChangeGroupCurrencyWithAccounts =>
      'A pénznem nem módosítható, amíg a csoportban aktív számlák vannak.';

  @override
  String get errorAmountMustBePositive =>
      'Az összegnek pozitívnak kell lennie.';

  @override
  String get errorAccountCurrencyAmountMustBePositive =>
      'A számla pénznemében megadott összegnek pozitívnak kell lennie.';

  @override
  String get errorAccountCurrencyAmountNotForSameCurrency =>
      'A számla pénznemében megadott összeg csak devizás tételekhez használható.';

  @override
  String get errorSplitNeedsTwoLines =>
      'Egy felosztáshoz legalább két kategóriasor szükséges.';

  @override
  String get errorSplitLineMustBePositive =>
      'Minden felosztási sornak pozitív összegűnek kell lennie.';

  @override
  String get errorSplitLinesMustSumToTotal =>
      'A felosztási soroknak összesen a tranzakció teljes összegét kell kiadniuk.';

  @override
  String get errorTransferAmountMustBePositive =>
      'Az átutalási összegnek pozitívnak kell lennie.';

  @override
  String get errorTransferAccountsMustDiffer =>
      'A forrás- és célszámlának különbözőnek kell lennie.';

  @override
  String get errorCloseoutRequiresDestinationAmount =>
      'A devizák közötti lezáráshoz ismert célösszeg szükséges.';

  @override
  String get errorDestinationAmountNotForSameCurrency =>
      'A célösszeg csak devizák közötti átutaláshoz használható.';

  @override
  String get errorDestinationAmountMustBePositive =>
      'A célösszegnek pozitívnak kell lennie.';

  @override
  String get errorInvestmentCashExceeded =>
      'Nem utalható át több, mint amennyi készpénz ezen a befektetési számlán van.';

  @override
  String get errorCannotReverseUnsettledProvisional =>
      'Rendezze ezt a függő átutalást ahelyett, hogy sztornózná.';

  @override
  String get errorAlreadyReversed =>
      'Ez a tétel már javítva lett. Az eredeti sor változatlan marad.';

  @override
  String get errorNotActiveExpenseCategory =>
      'Válasszon aktív kiadási kategóriát.';

  @override
  String get errorNotActiveIncomeCategory =>
      'Válasszon aktív bevételi kategóriát.';

  @override
  String get errorSettledAmountMustNotBeNegative =>
      'A megérkezett összeg nem lehet negatív.';

  @override
  String get errorPendingTransferNotFound =>
      'Az a függő átutalás nem található.';

  @override
  String get errorPendingTransferAlreadySettled =>
      'Az a függő átutalás már rendezve van.';

  @override
  String get errorSettledToMustBeSourceOrDestination =>
      'Válassza az eredeti forrás- vagy célszámlát.';

  @override
  String get errorFeeCategoryOnlyWhenReturningToSource =>
      'Díjkategória csak akkor használatos, ha a pénz visszakerül a forrásszámlára.';

  @override
  String get errorSettledAmountMustBePositiveForDelivery =>
      'Adjon meg egy pozitív összeget arra, ami megérkezett.';

  @override
  String get errorSettledAmountExceedsProvisional =>
      'Az az összeg több, mint amennyit elküldtek.';

  @override
  String get errorInstrumentNotFound => 'Az az eszköz nem található.';

  @override
  String get errorIncomeRequiredForNonCash =>
      'Nem készpénzes szerzéshez aktív bevételi kategória szükséges.';

  @override
  String get errorInsufficientCash =>
      'Nincs elég készpénz ezen a befektetési számlán ehhez a vételhez.';

  @override
  String get errorSellQuantityAndPriceMustBePositive =>
      'Az eladási mennyiségnek és az egységárnak pozitívnak kell lennie.';

  @override
  String errorLockedUntil(String date) {
    return 'Nem adható el: néhány egység $date dátumig zárolva van.';
  }

  @override
  String get errorInsufficientQuantity =>
      'Nem adható el több, mint amennyi jelenleg zárolatlanul van birtokában.';

  @override
  String get errorIncomeRequiredForGain =>
      'Realizált nyereséghez aktív bevételi kategória szükséges.';

  @override
  String get errorExpenseRequiredForLoss =>
      'Realizált veszteséghez aktív kiadási kategória szükséges.';

  @override
  String errorBrokerageFailedAfterBuy(String detail) {
    return 'A vétel könyvelve lett, de a bróker jutalék sikertelen volt: $detail';
  }

  @override
  String errorBrokerageFailedAfterSell(String detail) {
    return 'Az eladás könyvelve lett, de a bróker jutalék sikertelen volt: $detail';
  }

  @override
  String get errorDividendMustBePositive =>
      'Az osztalék összegének pozitívnak kell lennie.';

  @override
  String get errorNotInvestmentAccount => 'Ez nem befektetési számla.';

  @override
  String get errorNoInventoryCompanion =>
      'Ebből a befektetési számlából hiányzik a hozzá tartozó állomány.';

  @override
  String errorInvestmentReversalBlocked(String sells) {
    return 'Ez a vétel nem sztornózható: későbbi eladás(ok) függnek az egységeitől. Először sztornózza a függő eladás(oka)t: $sells.';
  }

  @override
  String get errorMonthlyLimitMustBePositive =>
      'A havi keretnek pozitívnak kell lennie.';

  @override
  String get errorTemplateAmountMustBePositive =>
      'A sablon összegének pozitívnak kell lennie.';

  @override
  String get errorOfxUnrecognized => 'Ez a fájl nem ismerhető fel OFX-ként.';

  @override
  String get errorCsvEmpty => 'A kiválasztott fájl üres.';

  @override
  String get errorCsvUnreadable => 'Ez a fájl nem olvasható CSV-ként.';

  @override
  String get errorCsvNoRows => 'A kiválasztott fájlban nincsenek sorok.';

  @override
  String get skipMissingDate => 'Hiányzó dátum.';

  @override
  String skipUnparseableDate(String raw, String pattern) {
    return 'A(z) \"$raw\" dátum nem értelmezhető a(z) \"$pattern\" mintával.';
  }

  @override
  String get skipOfxMissingOrInvalidDate =>
      'Hiányzó vagy érvénytelen tranzakciódátum.';

  @override
  String skipOfxUnparseableDate(String raw) {
    return 'A(z) \"$raw\" tranzakciódátum nem értelmezhető.';
  }

  @override
  String get skipMissingAmount => 'Hiányzó összeg.';

  @override
  String skipUnparseableAmount(String raw) {
    return 'A(z) \"$raw\" összeg nem értelmezhető.';
  }

  @override
  String get skipZeroAmount => 'Az összeg nulla.';

  @override
  String get skipUnparseableDebitCreditAmount =>
      'A terhelési vagy jóváírási összeg nem értelmezhető.';

  @override
  String get skipBothDebitAndCreditNonZero =>
      'A terhelés és a jóváírás oszlopa is tartalmaz összeget.';

  @override
  String get skipBothDebitAndCreditZero =>
      'A terhelés és a jóváírás oszlopa is nulla.';

  @override
  String errorBackupCreateFailed(String detail) {
    return 'Nem sikerült létrehozni a biztonsági mentést: $detail';
  }

  @override
  String get errorBackupRestoreFailed =>
      'Ez a biztonsági mentés nem állítható vissza - rossz jelmondat, vagy nem Smara biztonsági mentés fájl.';

  @override
  String get validationAmountAccountCategoryRequired =>
      'Az összeg, a számla és a kategória kötelező.';

  @override
  String get validationAmountAccountRequired =>
      'Az összeg és a számla kötelező.';

  @override
  String get validationSplitLineIncomplete =>
      'Minden felosztási sorhoz kategória és összeg szükséges.';

  @override
  String get validationSplitSumMismatch =>
      'A felosztási soroknak összesen a tranzakció teljes összegét kell kiadniuk.';

  @override
  String get validationFromToAmountRequired =>
      'A forrásszámla, a célszámla és az összeg kötelező.';

  @override
  String get validationAmountArrivedRequired =>
      'A megérkezett összeg megadása kötelező.';

  @override
  String get validationChooseReceivingAccount =>
      'Válassza ki, melyik számla kapta a pénzt.';

  @override
  String get validationAccountCategoryRequired =>
      'A számla és a kategória kötelező.';

  @override
  String get validationFixFailed => 'Nem sikerült elmenteni ezt a javítást.';

  @override
  String get validationNameRequired => 'Nevezze el a fő számláját.';

  @override
  String get validationStillLoading =>
      'Még betöltés alatt - próbálja meg egy pillanat múlva.';

  @override
  String get validationSaveAccountNameFailed =>
      'Nem sikerült elmenteni a számla nevét.';

  @override
  String get validationWrongPin => 'Hibás PIN. Próbálja újra.';

  @override
  String get validationCategoryMustBeIncomeOrExpense =>
      'A kategóriának bevételnek vagy kiadásnak kell lennie.';

  @override
  String get validationOnlyExpenseHasMonthlyLimit =>
      'Csak kiadási kategóriának lehet havi kerete.';

  @override
  String get validationInvalidTemplate => 'Érvénytelen sablon.';

  @override
  String get validationWrongKeystorePassphrase =>
      'Hibás jelmondat ehhez a kulcstartó fájlhoz.';

  @override
  String get validationInvalidKeystoreFile =>
      'Ez nem tűnik érvényes kulcstartó fájlnak.';

  @override
  String get validationRestorePhraseFailed =>
      'Nem sikerült visszaállítani abból a helyreállítási kifejezésből.';

  @override
  String validationGenerateKeyFailed(String detail) {
    return 'Nem sikerült aláíró kulcsot generálni ezen az eszközön: $detail';
  }

  @override
  String validationSaveCurrencyFailed(String detail) {
    return 'Nem sikerült elmenteni ezt a pénznemet: $detail';
  }

  @override
  String get validationMigrationFailed =>
      'A migráció sikertelen volt. Kérjük, próbálja újra.';

  @override
  String get validationChooseBackupFile =>
      'Először válasszon biztonsági mentés fájlt.';

  @override
  String get validationPassphraseRequired => 'Adjon meg egy jelmondatot.';

  @override
  String get validationPinsDoNotMatch => 'A két PIN nem egyezik.';

  @override
  String get validationFeePositiveWithCategory =>
      'Az átutalási díjnak pozitív összegűnek kell lennie, kiválasztott kiadási kategóriával.';

  @override
  String get validationFeeMustBeLessThanAmount =>
      'A díjnak kevesebbnek kell lennie az összegnél a levont díjas átutalásnál.';

  @override
  String validationTransferSavedFeeFailed(String detail) {
    return 'Az átutalás mentve lett, de a díjat nem sikerült rögzíteni: $detail';
  }

  @override
  String get validationEnterValidAmount => 'Adjon meg egy érvényes összeget.';

  @override
  String validationConfirmWordMismatch(String n) {
    return 'A(z) $n. szó nem egyezik az elmentett kifejezésével. Ellenőrizze, és próbálja újra.';
  }

  @override
  String get errorBuyQuantityAndPriceMustBePositive =>
      'A vételi mennyiségnek és az egységárnak pozitívnak kell lennie.';

  @override
  String get errorInstrumentArchived => 'Nem vásárolható archivált eszköz.';

  @override
  String get errorNonCashCannotIncludeBrokerage =>
      'Nem készpénzes szerzések nem tartalmazhatnak bróker jutalékot.';

  @override
  String get errorBrokerageRequiresExpenseCategory =>
      'Ha a bróker jutalék pozitív, aktív kiadási kategória szükséges.';

  @override
  String get errorSellProceedsMustCoverBrokerage =>
      'Az eladási bevételnek legalább a bróker jutalék összegét fedeznie kell.';

  @override
  String homeSpentOfLimitThisMonth(String spent, String limit) {
    return '$spent / $limit ebben a hónapban';
  }

  @override
  String get unlockBiometricReason => 'Smara Account feloldása';

  @override
  String get searchLabel => 'Keresés';

  @override
  String get openingBalance => 'Nyitóegyenleg';

  @override
  String transferToName(String name) {
    return 'Átutalás: $name';
  }

  @override
  String get feeForTransfer => 'Átutalási díj';

  @override
  String feeForTransferTo(String name) {
    return 'Átutalási díj ide: $name';
  }

  @override
  String couldNotOpenFilePicker(String detail) {
    return 'Nem sikerült megnyitni a fájlválasztót: $detail';
  }

  @override
  String pleaseSelectFile(String extensions) {
    return 'Válasszon egy .$extensions fájlt';
  }

  @override
  String get currencyCodeIso => 'Pénznemkód (ISO 4217, pl. USD)';

  @override
  String splitCounterpartMore(String name, String count) {
    return '$name +$count további';
  }

  @override
  String get dateLabel => 'Dátum';

  @override
  String get noneSelected => 'Nincs';

  @override
  String reviewEntriesBeforeContinuing(String count) {
    return 'Folytatás előtt tekintse át az alábbi tételeket (összesen $count).';
  }

  @override
  String youReceived(String amount) {
    return 'Ön kapott $amount összeget';
  }

  @override
  String get leaveBlankIfRateUnknown =>
      'Hagyja üresen, ha az árfolyam még nem ismert.';

  @override
  String get recordTradeBlurb =>
      'Rögzítsen egy már megtörtént ügyletet. Ez az alkalmazás nem ad le megbízásokat.';

  @override
  String get feeOnTopBlurb =>
      'Bekapcsolva: a fenti összeg a számláról levont teljes összeg; a díj ebből kerül levonásra.';

  @override
  String get feeBankBlurb =>
      'A bankja vagy egy közvetítő által felszámított előzetes jutalék.';

  @override
  String get validationPinMinLength =>
      'A PIN-nek legalább 4 számjegyűnek kell lennie.';

  @override
  String get restoreBackupBlurb =>
      'Ez lecseréli mindazt, ami jelenleg ebben az alkalmazásban van, a biztonsági mentésre — nem egyesíti. Válasszon egy biztonsági mentés fájlt, és adja meg a jelmondatot, amellyel védte.';

  @override
  String get actionReplace => 'Csere';

  @override
  String hideAccountBody(String name) {
    return '$name a továbbiakban nem lesz elérhető új tételekhez.';
  }

  @override
  String hideGroupBody(String name) {
    return 'Számla létrehozásakor vagy áthelyezésekor a(z) $name a továbbiakban nem lesz felkínálva.';
  }

  @override
  String hideCategoryBody(String name) {
    return 'Új tranzakció rögzítésekor a(z) $name a továbbiakban nem lesz felkínálva.';
  }

  @override
  String get hideInstrumentBody =>
      'Az elrejtett eszközök megmaradnak a korábbi vételeken és eladásokon. Osztalékot továbbra is rögzíthet hozzájuk.';

  @override
  String nameHidden(String name) {
    return '$name (elrejtve)';
  }

  @override
  String get noCurrencySet => 'Nincs pénznem beállítva';

  @override
  String deletePayeeBody(String name) {
    return 'A(z) $name és a hozzá tartozó megjegyzett alapértelmezések törlődnek. A korábbi tranzakciókat ez nem érinti.';
  }

  @override
  String deleteTemplateBody(String name) {
    return 'A(z) $name a továbbiakban nem lesz felkínálva esedékesként. Az általa már rögzített tranzakciókat ez nem érinti.';
  }

  @override
  String deleteProfileBody(String name) {
    return 'A mentett oszlop-hozzárendelés (\"$name\") törlődik. Az azzal már importált kivonatokat ez nem érinti.';
  }

  @override
  String deleteRuleBody(String keyword) {
    return 'Az importálások a továbbiakban nem lesznek automatikusan kategorizálva a(z) \"$keyword\" alapján. Az e szabállyal már kategorizált tranzakciókat ez nem érinti.';
  }

  @override
  String get firstWeekBlurb =>
      'Opcionálisan adjon hozzá most egy hitelkártyát vagy készpénzszámlát - később a Beállításokból mindig hozzáadhat további számlákat.';

  @override
  String get deliveredToDestination => 'Kézbesítve a célszámlára';

  @override
  String deliveredToName(String name) {
    return 'Kézbesítve ide: $name';
  }

  @override
  String youReceivedLessThanExpected(String amount, String currency) {
    return 'Ön $amount $currency összeggel kevesebbet kapott a vártnál - válasszon kategóriát a különbözet fedezésére.';
  }

  @override
  String get dateRangeLabel => 'Dátumtartomány';

  @override
  String get addTemplate => 'Sablon hozzáadása';

  @override
  String get editTemplate => 'Sablon szerkesztése';

  @override
  String get validationFillTemplateFields =>
      'Töltsön ki minden mezőt érvényes összeggel és nappal.';

  @override
  String get saveCsvExport => 'CSV export mentése';

  @override
  String get referenceRate => 'Referencia árfolyam';

  @override
  String get yourRate => 'Az Ön árfolyama';

  @override
  String leaveBlankIfThisWasAccountCurrency(String currency) {
    return 'Hagyja üresen, ha ez $currency pénznemben volt, a számla saját pénznemében.';
  }

  @override
  String get lockUntilOptional => 'Zárolva eddig (opcionális)';

  @override
  String lockedUntilDate(String date) {
    return 'Zárolva eddig: $date';
  }

  @override
  String get copiedResearchPrompt =>
      'Egy kutatási felszólítás átmásolva — nincs elérhető böngésző URL, vagy Ön offline van.';

  @override
  String get openedFavouriteResearchTool => 'Megnyílt a kedvenc kutatóeszköze.';

  @override
  String get looksLikeGain => 'Ez nyereségnek tűnik';

  @override
  String get looksLikeLoss => 'Ez veszteségnek tűnik';

  @override
  String get looksLikeBreakEven => 'Ez nullszaldósnak tűnik';

  @override
  String sellableQuantity(String name, String qty) {
    return '$name ($qty eladható)';
  }

  @override
  String columnN(String index) {
    return '$index. oszlop';
  }

  @override
  String get importingLabel => 'Importálás...';

  @override
  String get confirmImport => 'Importálás megerősítése';

  @override
  String get manageSavedCategoryRules => 'Mentett kategóriaszabályok kezelése';

  @override
  String statementCurrencyMismatch(String currency) {
    return 'Ennek a fájlnak a pénzneme ($currency) nem egyezik a kiválasztott számla pénznemével.';
  }

  @override
  String get categoryRulesTitle => 'Kategóriaszabályok';

  @override
  String get possibleDuplicate => 'lehetséges duplikátum';

  @override
  String get unknownCategory => 'Ismeretlen kategória';

  @override
  String get researchPromptIntro =>
      'Kutasd fel ezt a tőzsdén jegyzett eszközt egy magánbefektető számára. Azonosítsd a kibocsátót, foglald össze a friss híreket dátummal, ha ismert, és vázold fel a lefelé mutató kockázatokat és a felfelé mutató tényezőket. Válaszd külön a tényeket a feltételezésektől. Ne adj vételi, eladási vagy tartási ajánlást. Ez nem befektetési tanácsadás.';

  @override
  String researchPromptNameLine(String name) {
    return 'Név: $name';
  }

  @override
  String researchPromptTickerLine(String ticker) {
    return 'Ticker: $ticker';
  }

  @override
  String get researchPromptTickerNoneProvided => 'Ticker: (nincs megadva)';

  @override
  String researchPromptIsinLine(String isin) {
    return 'ISIN: $isin';
  }

  @override
  String get researchPromptIsinNoneProvided => 'ISIN: (nincs megadva)';
}
