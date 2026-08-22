// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appTitle => 'Smara Boekhouding';

  @override
  String get navHome => 'Home';

  @override
  String get navRegister => 'Register';

  @override
  String get navSummary => 'Overzicht';

  @override
  String get navAccounts => 'Rekeningen';

  @override
  String get navCategories => 'Categorieën';

  @override
  String get actionCancel => 'Annuleren';

  @override
  String get actionSave => 'Opslaan';

  @override
  String get actionDelete => 'Verwijderen';

  @override
  String get actionDone => 'Klaar';

  @override
  String get actionContinue => 'Doorgaan';

  @override
  String get actionDismiss => 'Sluiten';

  @override
  String get actionRetry => 'Opnieuw proberen';

  @override
  String get actionSkip => 'Overslaan';

  @override
  String get actionConfirm => 'Bevestigen';

  @override
  String get actionAdd => 'Toevoegen';

  @override
  String get actionEdit => 'Bewerken';

  @override
  String get actionRename => 'Naam wijzigen';

  @override
  String get actionHide => 'Verbergen';

  @override
  String get actionCreate => 'Aanmaken';

  @override
  String get actionCloseApp => 'App sluiten';

  @override
  String get actionUnlock => 'Ontgrendelen';

  @override
  String get actionSettle => 'Afwikkelen';

  @override
  String get actionFinish => 'Voltooien';

  @override
  String get actionPreview => 'Voorbeeld';

  @override
  String get actionImport => 'Importeren';

  @override
  String get actionExportCsv => 'CSV exporteren';

  @override
  String get actionChooseFile => 'Bestand kiezen';

  @override
  String get actionRestore => 'Herstellen';

  @override
  String get actionFix => 'Corrigeren';

  @override
  String get actionBuy => 'Kopen';

  @override
  String get actionSell => 'Verkopen';

  @override
  String get actionDividend => 'Dividend';

  @override
  String get actionRecordBuy => 'Aankoop registreren';

  @override
  String get actionRecordSell => 'Verkoop registreren';

  @override
  String get actionRecordDividend => 'Dividend registreren';

  @override
  String get actionPayCard => 'Kaart betalen';

  @override
  String get actionTransfer => 'Overboeken';

  @override
  String get actionRecordTransaction => 'Transactie registreren';

  @override
  String get actionImportStatement => 'Afschrift importeren';

  @override
  String get actionClearDates => 'Datums wissen';

  @override
  String get actionClearSearch => 'Zoekopdracht en filters wissen';

  @override
  String get actionUseBiometrics => 'Biometrie gebruiken';

  @override
  String get actionSetPin => 'Pincode instellen';

  @override
  String get actionChangePin => 'Pincode wijzigen';

  @override
  String get actionSaveBackup => 'Back-up opslaan';

  @override
  String get actionRestoreBackup => 'Back-up herstellen';

  @override
  String get actionSaveRule => 'Regel opslaan';

  @override
  String get actionConfirmFix => 'Correctie bevestigen';

  @override
  String get captureSpent => 'Uitgegeven';

  @override
  String get captureReceived => 'Ontvangen';

  @override
  String get captureMovedMoney => 'Geld verplaatst';

  @override
  String get captureImportStatement => 'Afschrift importeren';

  @override
  String get settingsTitle => 'Instellingen';

  @override
  String get settingsLanguage => 'Taal';

  @override
  String get settingsLanguageSystem => 'Apparaattaal';

  @override
  String get settingsFetchFxRates => 'Referentiewisselkoersen ophalen';

  @override
  String get settingsFetchFxRatesSubtitle =>
      'Toont een indicatieve marktkoers naast het bestemmingsbedrag bij overboekingen tussen valuta, uitsluitend ter vergelijking - wordt nooit gebruikt om het bedrag automatisch in te vullen.';

  @override
  String get settingsRateProvider => 'Koersaanbieder';

  @override
  String get settingsFetchMarketPrices =>
      'Marktprijzen voor beleggingen ophalen';

  @override
  String get settingsFetchMarketPricesSubtitle =>
      'Zoekt de laatste prijzen op voor instrumenten met een ticker of ISIN, om de portefeuillewaarde te schatten. Wordt nooit gebruikt om een transactie vast te leggen en verstuurt nooit hoeveel je in bezit hebt.';

  @override
  String get settingsMarketPriceProvider => 'Marktprijsaanbieder';

  @override
  String get settingsFavouriteResearchTool => 'Favoriete onderzoekstool';

  @override
  String get settingsFavouriteResearchToolSubtitle =>
      'Als je op een instrumentnaam bij je posities tikt, opent deze tool in de browser met een onderzoeksvraag — geen integratie en geen advies.';

  @override
  String get settingsBackup => 'Back-up';

  @override
  String get settingsBackupBlurb =>
      'Sla een versleutelde kopie van je boekhouding op een locatie naar keuze op, of herstel er een. Dit is iets anders dan je herstelzin of keystore-bestand, die je ondertekeningssleutel back-uppen, niet je boekhouding.';

  @override
  String get settingsLock => 'Vergrendeling';

  @override
  String get settingsLockBlurb =>
      'Vereis een pincode, of biometrie waar beschikbaar, om de app te openen.';

  @override
  String get settingsRequireUnlock =>
      'Ontgrendeling vereisen om de app te openen';

  @override
  String get settingsLockAfter => 'Vergrendelen na';

  @override
  String get settingsLockImmediately => 'Direct';

  @override
  String get settingsLock1Minute => '1 minuut';

  @override
  String get settingsLock5Minutes => '5 minuten';

  @override
  String get settingsLock15Minutes => '15 minuten';

  @override
  String get settingsAllowBiometrics => 'Ook biometrie toestaan';

  @override
  String get settingsHideSnapshot => 'Saldi verbergen in de app-switcher';

  @override
  String get settingsHideSnapshotSubtitle =>
      'Verbergt dit scherm wanneer je naar een andere app schakelt, zodat het niet in één oogopslag zichtbaar is in de app-switcher.';

  @override
  String get settingsHideSnapshotUnavailable =>
      'Saldi verbergen in de app-switcher is niet beschikbaar op dit platform.';

  @override
  String get settingsPayees => 'Begunstigden';

  @override
  String get settingsManagePayees => 'Begunstigden beheren';

  @override
  String get settingsPayeesBlurb =>
      'Onthouden begunstigdennamen met hun standaardcategorie en -rekening, voorgesteld door automatisch aanvullen bij het registreren van een transactie.';

  @override
  String get settingsRecurring => 'Terugkerende sjablonen';

  @override
  String get settingsManageRecurring => 'Terugkerende sjablonen beheren';

  @override
  String get settingsRecurringBlurb =>
      'Rekeningen of inkomsten die maandelijks terugkeren, zoals huur of salaris. Een vervallen sjabloon verschijnt op Home zodat je het met één tik kunt registreren - nooit automatisch geboekt.';

  @override
  String get settingsAbout => 'Over';

  @override
  String get providerFrankfurter => 'Frankfurter (ECB-koersen)';

  @override
  String get providerOpenErApi => 'ExchangeRate-API (open.er-api.com)';

  @override
  String get providerStooq => 'Stooq (dagelijkse koersen)';

  @override
  String get providerYahooFinance => 'Yahoo Finance (chart-API)';

  @override
  String get researchChatGpt => 'ChatGPT';

  @override
  String get researchClaude => 'Claude';

  @override
  String get researchGemini => 'Gemini';

  @override
  String get researchMetaAi => 'Meta AI';

  @override
  String get systemGroupCashEquivalents => 'Liquide middelen';

  @override
  String get systemGroupPensionRetirement => 'Pensioen';

  @override
  String get systemGroupCreditShortTerm => 'Krediet & kortlopende schulden';

  @override
  String get systemGroupLoansMortgages => 'Leningen & hypotheken';

  @override
  String get systemGroupInvestments => 'Beleggingen';

  @override
  String get systemAccountCashBank => 'Kas & Bank';

  @override
  String get systemCategorySalary => 'Salaris';

  @override
  String get systemCategoryOtherIncome => 'Overige inkomsten';

  @override
  String get systemCategoryGroceries => 'Boodschappen';

  @override
  String get systemCategoryRentMortgage => 'Huur/Hypotheek';

  @override
  String get systemCategoryUtilities => 'Nutsvoorzieningen';

  @override
  String get systemCategoryTransport => 'Vervoer';

  @override
  String get systemCategoryFoodOut => 'Uit eten';

  @override
  String get systemCategoryPhone => 'Telefoon';

  @override
  String get systemCategoryHealth => 'Gezondheid';

  @override
  String get systemCategoryOtherExpense => 'Overige uitgaven';

  @override
  String get homeThisMonth => 'DEZE MAAND';

  @override
  String get homeMoneyInTransit => 'GELD ONDERWEG';

  @override
  String get homeWhatYouHaveMinusWhatYouOwe =>
      'WAT JE HEBT MIN WAT JE SCHULDIG BENT';

  @override
  String homeWhatYouHave(String amount, String currency) {
    return 'Wat je hebt $amount $currency';
  }

  @override
  String homeNetPosition(String amount, String currency) {
    return '$amount $currency';
  }

  @override
  String homeHaveAndOwe(String haveAmount, String currency, String oweAmount) {
    return 'Wat je hebt $haveAmount $currency  •  Wat je schuldig bent $oweAmount $currency';
  }

  @override
  String youSentFrom(String amount, String currency, String name) {
    return 'Je stuurde $amount $currency vanaf $name';
  }

  @override
  String youSentTo(String amount, String currency, String name) {
    return 'Je stuurde $amount $currency naar $name';
  }

  @override
  String get hiddenLabel => 'Verborgen';

  @override
  String get allAccounts => 'Alle rekeningen';

  @override
  String savedToPath(String path) {
    return 'Opgeslagen op $path';
  }

  @override
  String get keystoreExportFailed =>
      'Het keystore-bestand kon niet worden geëxporteerd. Je kunt deze stap overslaan.';

  @override
  String get enterPassphraseToProtect =>
      'Voer een wachtwoordzin in om het bestand te beveiligen.';

  @override
  String get homeTapWhenArrived => 'Tik zodra je weet wat er is aangekomen';

  @override
  String homeReturnedTo(String name) {
    return 'Teruggestort naar $name';
  }

  @override
  String get homeDueToday => 'VANDAAG VERSCHULDIGD';

  @override
  String homeDueLine(String category, String account) {
    return '$category · $account · tik om te registreren';
  }

  @override
  String get homeOverLimit => 'Over de limiet';

  @override
  String homeSpentOfLimit(String spent, String limit) {
    return '$spent van $limit';
  }

  @override
  String homeRemaining(String amount) {
    return 'Resterend: $amount';
  }

  @override
  String get homeNoAccounts => 'Geen rekeningen';

  @override
  String get homeCashRegister => 'Kasregister';

  @override
  String get homeMarketEstimate => 'Marktschatting';

  @override
  String get registerTitle => 'Register';

  @override
  String get registerSearchHint => 'Omschrijving, categorie of bedrag';

  @override
  String get registerNoTransactions => 'Nog geen transacties';

  @override
  String get registerNoEntries => 'Nog geen boekingen geregistreerd.';

  @override
  String get registerSpentOnly => 'Alleen uitgaven';

  @override
  String get registerReceivedOnly => 'Alleen ontvangsten';

  @override
  String get registerAll => 'Alles';

  @override
  String get registerUnverified =>
      'Niet geverifieerd - buiten totalen gehouden';

  @override
  String get registerSuperseded =>
      'Vervangen door migratie - buiten totalen gehouden';

  @override
  String get summaryTitle => 'Overzicht';

  @override
  String get summaryTotalIncome => 'Totale inkomsten';

  @override
  String get summaryTotalExpense => 'Totale uitgaven';

  @override
  String summaryDateRange(String start, String end) {
    return '$start tot $end';
  }

  @override
  String get accountsTitle => 'Rekeningen';

  @override
  String get categoriesTitle => 'Categorieën';

  @override
  String get accountName => 'Rekeningnaam';

  @override
  String get createAccount => 'Rekening aanmaken';

  @override
  String get createGroup => 'Groep aanmaken';

  @override
  String get editGroup => 'Groep bewerken';

  @override
  String get renameAccount => 'Rekening hernoemen';

  @override
  String get renameCategory => 'Categorie hernoemen';

  @override
  String get addCategory => 'Categorie toevoegen';

  @override
  String get groupLabel => 'Groep';

  @override
  String get kindLabel => 'Type';

  @override
  String get asset => 'Bezitting';

  @override
  String get liability => 'Verplichting';

  @override
  String get income => 'Inkomsten';

  @override
  String get expense => 'Uitgaven';

  @override
  String get thisAccountHoldsInvestments => 'Deze rekening bevat beleggingen';

  @override
  String get thisAccountHoldsInvestmentsSubtitle =>
      'Kas plus voorraad die je vastlegt met Kopen, Verkopen en Dividend.';

  @override
  String get thisIsACreditCard => 'Dit is een creditcard';

  @override
  String get openingBalanceOptional => 'Beginsaldo (optioneel)';

  @override
  String get currencyIso => 'Valuta (ISO 4217)';

  @override
  String get currencyIsoExample => 'Valuta (ISO 4217, bijv. USD)';

  @override
  String get hideAccountTitle => 'Rekening verbergen voor nieuwe boekingen?';

  @override
  String get hideCategoryTitle => 'Categorie verbergen voor nieuwe boekingen?';

  @override
  String get hideGroupTitle => 'Groep verbergen voor nieuwe boekingen?';

  @override
  String get reassignGroup => 'Groep opnieuw toewijzen';

  @override
  String get transferRemainingBalance => 'Resterend saldo overboeken';

  @override
  String get monthlyLimit => 'Maandlimiet';

  @override
  String get monthlyLimitHint => 'Limiet (leeg laten om te wissen)';

  @override
  String get monthlyLimitBlurb =>
      'Een optionele richtlijn voor uitgaven tot nu toe deze maand, voor deze uitgavencategorie.';

  @override
  String get manageCategoryRules => 'Categorieregels beheren';

  @override
  String get amount => 'Bedrag';

  @override
  String get category => 'Categorie';

  @override
  String get account => 'Rekening';

  @override
  String get fromAccount => 'Van rekening';

  @override
  String get toAccount => 'Naar rekening';

  @override
  String get descriptionOptional => 'Omschrijving (optioneel)';

  @override
  String get alsoRememberPayee => 'Ook onthouden als begunstigde';

  @override
  String get splitIntoCategories => 'Splitsen over meerdere categorieën';

  @override
  String categoryN(String n) {
    return 'Categorie $n';
  }

  @override
  String get destinationAmount => 'Bestemmingsbedrag';

  @override
  String get destinationAmountOptional => 'Bestemmingsbedrag (optioneel)';

  @override
  String get accountCurrencyAmountOptional =>
      'Bedrag in rekeningvaluta (optioneel)';

  @override
  String get transactionCurrencyOptional => 'Transactievaluta (optioneel)';

  @override
  String get feeOptional => 'Kosten (optioneel)';

  @override
  String get feeAmount => 'Kostenbedrag';

  @override
  String get feeCategory => 'Kostencategorie';

  @override
  String get feeDescriptionOptional => 'Omschrijving kosten (optioneel)';

  @override
  String get feeDeducted => 'Kosten worden ingehouden op bovenstaand bedrag';

  @override
  String get needTwoAccountsToTransfer =>
      'Maak minstens twee actieve rekeningen aan om een overboeking te doen.';

  @override
  String get whatArrivedTitle => 'Wat is er aangekomen?';

  @override
  String get whatArrivedBlurb => 'Vertel ons wat er werkelijk is aangekomen.';

  @override
  String get amountThatArrived => 'Aangekomen bedrag';

  @override
  String get feeLossCategory => 'Kosten-/verliescategorie';

  @override
  String get alreadySettled => 'Al afgewikkeld.';

  @override
  String get holdingsTitle => 'Posities';

  @override
  String get holdingsCash => 'Kas';

  @override
  String get holdingsInventory => 'VOORRAAD';

  @override
  String holdingsBook(String amount, String currency) {
    return 'Boekwaarde (kas + kostprijs) $amount $currency';
  }

  @override
  String holdingsMarketEstimate(String amount, String currency) {
    return 'Marktschatting $amount $currency';
  }

  @override
  String get holdingsNoHoldings =>
      'Nog geen posities. Registreer een aankoop om een instrument toe te voegen.';

  @override
  String get holdingsQuotesBlurb =>
      'Koersen zijn schattingen, geen brokerprijs. Deze app plaatst geen orders.';

  @override
  String get holdingsTapNameToResearch =>
      'Tik op de naam om te onderzoeken. Koersen zijn schattingen, geen advies.';

  @override
  String get instrument => 'Instrument';

  @override
  String get newInstrument => 'Nieuw instrument';

  @override
  String get renameInstrument => 'Instrument hernoemen';

  @override
  String get instrumentActions => 'Instrumentacties';

  @override
  String hideInstrumentTitle(String name) {
    return '$name verbergen?';
  }

  @override
  String get tickerOptional => 'Ticker (optioneel)';

  @override
  String get isinOptional => 'ISIN (optioneel)';

  @override
  String get quantity => 'Aantal';

  @override
  String get unitPrice => 'Eenheidsprijs';

  @override
  String get brokerageOptional => 'Brokerkosten (optioneel)';

  @override
  String get brokerageExpenseCategory => 'Uitgavencategorie brokerkosten';

  @override
  String get incomeCategory => 'Inkomstencategorie';

  @override
  String get gainIncomeCategory => 'Inkomstencategorie voor winst';

  @override
  String get lossExpenseCategory => 'Uitgavencategorie voor verlies';

  @override
  String get nonCash => 'Niet-cash';

  @override
  String get cash => 'Cash';

  @override
  String get locked => 'Vergrendeld';

  @override
  String get lockUntilHint =>
      'Je eigen notitie over een beperking, geen brokerregel.';

  @override
  String get instrumentKindStock => 'Aandeel';

  @override
  String get instrumentKindEtf => 'ETF';

  @override
  String get instrumentKindMutualFund => 'Beleggingsfonds';

  @override
  String get instrumentKindBond => 'Obligatie';

  @override
  String get instrumentKindOther => 'Overig';

  @override
  String get quoteUseLive => 'Actuele koers';

  @override
  String get quoteUseCached => 'Gecachete koers';

  @override
  String get quoteUseStale => 'Verouderde koers';

  @override
  String get quoteUseMissing => 'Kostprijs gebruikt (geen koers)';

  @override
  String get quoteUseDisabled => 'Koersen uit — kostprijs/cache gebruikt';

  @override
  String get quoteUseCurrencyMismatch =>
      'Kostprijs gebruikt (koersvaluta wijkt af)';

  @override
  String unrealizedLabel(String amount, String currency) {
    return 'Ongerealiseerd $amount $currency';
  }

  @override
  String holdingsUnitsCost(String qty) {
    return '$qty eenheden · ';
  }

  @override
  String get recoveryPhraseTitle => 'Je herstelzin';

  @override
  String get recoveryPhraseConfirmTitle => 'Bevestig je zin';

  @override
  String get recoveryPhraseBlurb =>
      'Deze 24 woorden zijn de enige manier om je transactiegeschiedenis te herstellen als dit toestel verloren, gereset of vervangen wordt. Smara Boekhouding heeft geen server en kan ze niet voor je herstellen.\n\nAls je dit toestel en deze zin samen kwijtraakt, wordt elke transactie die je hebt geregistreerd permanent onverifieerbaar.';

  @override
  String get recoveryPhraseWriteDown =>
      'Schrijf deze woorden in volgorde op en bewaar ze op een veilige plek, gescheiden van dit toestel.';

  @override
  String get iveSavedRecoveryPhrase => 'Ik heb mijn herstelzin opgeslagen';

  @override
  String get confirmPhraseBlurb =>
      'Voer de gevraagde woorden in uit de zin die je zojuist hebt opgeslagen.';

  @override
  String wordNumber(String n) {
    return 'Woord #$n';
  }

  @override
  String get keystoreExportTitle => 'Keystore-bestand exporteren';

  @override
  String get keystoreExportBlurb =>
      'Naast je herstelzin kun je een versleuteld keystore-bestand opslaan, beveiligd met een wachtwoordzin naar keuze. Dit is optioneel - je herstelzin alleen is altijd genoeg om je ondertekeningssleutel te herstellen.';

  @override
  String get keystorePassphrase => 'Wachtwoordzin';

  @override
  String get exportKeystoreFile => 'Keystore-bestand exporteren';

  @override
  String get chooseCurrencyTitle => 'Kies je valuta';

  @override
  String get chooseCurrencyBlurb =>
      'Elke rekeninggroep (Liquide middelen, Pensioen, enz.) gebruikt voorlopig deze ene valuta. Je kunt later nog rekeningen in een andere valuta toevoegen door er een nieuwe groep voor aan te maken.';

  @override
  String get currencyBackfillTitle => 'Kies een valuta voor bestaande groepen';

  @override
  String get currencyBackfillBlurb =>
      'Deze app ondersteunt nu meerdere valuta. Je bestaande rekeningen en rekeninggroepen hebben een valuta nodig - omdat ze allemaal zijn aangemaakt voordat deze functie bestond, geldt één keuze voor ze allemaal.';

  @override
  String get firstAccountTitle => 'Geef je rekening een naam';

  @override
  String get firstAccountBlurb =>
      'Dit is de rekening die al voor je is aangemaakt - geef hem een naam die je herkent, zoals je bank. Hierna registreer je één Uitgave of Ontvangst, en beveilig je daarna het toestel met je herstelzin.';

  @override
  String get whatsMainAccountCalled => 'Hoe heet je hoofdrekening?';

  @override
  String get restoreTitle => 'Ondertekeningssleutel herstellen';

  @override
  String get restoreBlurb =>
      'Dit toestel heeft al een boekhouding, maar geen bijpassende ondertekeningssleutel. Herstel deze vanuit je opgeslagen herstelzin of keystore-bestand - je gegevens worden gewoon geverifieerd en er wordt niets opnieuw ondertekend of gewijzigd.';

  @override
  String get recoveryPhrase24 => 'Herstelzin (alle 24 woorden)';

  @override
  String get keystoreFile => 'Keystore-bestand';

  @override
  String get keystoreFileContents => 'Inhoud keystore-bestand';

  @override
  String get optionalBackupFile => 'Optioneel back-upbestand';

  @override
  String get iDontHavePhrase =>
      'Ik heb mijn herstelzin of keystore-bestand niet';

  @override
  String get migrationTitle => 'Migreren naar een nieuwe sleutel';

  @override
  String get migrationBlurb =>
      'Zonder je herstelzin of keystore-bestand kan de ondertekeningssleutel van dit toestel niet worden hersteld. Je kunt een nieuwe sleutel starten. Oude boekingen blijven zichtbaar maar worden vervangen.';

  @override
  String get iConfirmBooksValid =>
      'Ik bevestig dat de huidige boekhouding klopt';

  @override
  String get whyWeDontEdit => 'Waarom we oude boekingen niet bewerken';

  @override
  String get whyWeDontEditBody =>
      'Als je een fout corrigeert, laten we de oude regel staan en voegen we er een correctie naast toe, in plaats van te wijzigen wat je al had ingevoerd. Zo toont je geschiedenis altijd precies wat er is gebeurd en wanneer je het hebt gecorrigeerd — er verandert nooit iets stiekem achter je rug.';

  @override
  String get lockTitle => 'Ontgrendelen';

  @override
  String get lockScreenTitle => 'Vergrendeld';

  @override
  String get enterPinToContinue => 'Voer je pincode in om door te gaan';

  @override
  String get pinLabel => 'Pincode';

  @override
  String get setPinTitle => 'Stel een pincode in';

  @override
  String get currentPin => 'Huidige pincode';

  @override
  String get newPin => 'Nieuwe pincode';

  @override
  String get confirmPin => 'Bevestig pincode';

  @override
  String get confirmNewPin => 'Bevestig nieuwe pincode';

  @override
  String get firstWeekTitle => 'Stel je rekeningen in';

  @override
  String get addCashAccount => 'Voeg een contante rekening toe';

  @override
  String get addCreditCard => 'Voeg een creditcard toe';

  @override
  String get cashAccountName => 'Naam contante rekening';

  @override
  String get cardName => 'Naam kaart';

  @override
  String get paidFromBank => 'Betaald vanaf bank';

  @override
  String get paidFromCard => 'Betaald met kaart';

  @override
  String get choosePassphraseTitle =>
      'Kies een wachtwoordzin om deze back-up te beveiligen. Er is geen herstel mogelijk als je deze vergeet.';

  @override
  String get replaceBooksTitle => 'Je lokale boekhouding vervangen?';

  @override
  String get replaceBooksBody =>
      'Dit vervangt alles wat nu in deze app staat door de back-up. Sluit en heropen de app daarna.';

  @override
  String get chooseBackupFileFirst => 'Kies eerst een back-upbestand.';

  @override
  String get backupRestored => 'Back-up hersteld';

  @override
  String get backupRestoredBody =>
      'Je boekhouding is hersteld. Sluit en heropen de app om door te gaan.';

  @override
  String get fixThisEntry => 'Deze boeking corrigeren';

  @override
  String get fixBlurb =>
      'De oude regel blijft precies zoals hij was. Bevestigen voegt een tegenboeking en de gecorrigeerde regel toe.';

  @override
  String get importStatementTitle => 'Afschrift importeren';

  @override
  String get importOfx => 'OFX importeren';

  @override
  String get importOfxQfxFile => 'OFX-/QFX-bestand importeren';

  @override
  String get importCsvFile => 'CSV-bestand importeren';

  @override
  String get whatKindOfStatement => 'Wat voor soort afschriftbestand heb je?';

  @override
  String get chooseAccountForFile =>
      'Kies bij welke rekening dit bestand hoort.';

  @override
  String get importIntoAccount => 'Importeren in rekening';

  @override
  String get useSavedProfile => 'Gebruik een opgeslagen profiel';

  @override
  String get saveMappingProfile =>
      'Deze koppeling opslaan als profiel (optioneel)';

  @override
  String get renameProfile => 'Profiel hernoemen';

  @override
  String get deleteProfileTitle => 'Profiel verwijderen?';

  @override
  String get fileHasHeader => 'Bestand heeft een koprij';

  @override
  String get dateColumn => 'Datumkolom';

  @override
  String get dateFormatHint => 'Datumnotatie (bijv. dd/MM/jjjj)';

  @override
  String get amountColumn => 'Bedragkolom';

  @override
  String get amountConvention => 'Bedragconventie';

  @override
  String get signedAmountColumn => 'Kolom met getekend bedrag';

  @override
  String get separateDebitCredit => 'Aparte debet-/creditkolommen';

  @override
  String get debitColumn => 'Debetkolom';

  @override
  String get creditColumn => 'Creditkolom';

  @override
  String get decimalSeparator => 'Decimaalteken (. of ,)';

  @override
  String get descriptionColumns => 'Omschrijvingskolom(men)';

  @override
  String get referenceIdColumn => 'Referentiekolom (optioneel)';

  @override
  String get skippedRows => 'Overgeslagen rijen';

  @override
  String parsedTransactionCount(String count) {
    return '$count transacties verwerkt';
  }

  @override
  String skippedOrExcludedCount(String count) {
    return '$count overgeslagen of uitgesloten';
  }

  @override
  String postedFailedCount(String posted, String failed) {
    return '$posted geboekt, $failed mislukt';
  }

  @override
  String get categoryForAll => 'Categorie voor alles';

  @override
  String get saveAsRule => 'Opslaan als regel?';

  @override
  String get saveAsRuleBlurb =>
      'Toekomstige imports waarvan de omschrijving dit trefwoord bevat, gebruiken deze categorie.';

  @override
  String get keyword => 'Trefwoord';

  @override
  String get noSavedRules =>
      'Nog geen opgeslagen regels. Wijs een categorie toe aan een groep rijen om een regel op te slaan.';

  @override
  String get deleteRuleTitle => 'Regel verwijderen?';

  @override
  String get editRule => 'Regel bewerken';

  @override
  String rowsGrouped(String count) {
    return '$count rijen';
  }

  @override
  String selectStatementFile(String extensions) {
    return 'Selecteer een $extensions-afschriftbestand om te importeren';
  }

  @override
  String get payeesTitle => 'Begunstigden';

  @override
  String get addPayee => 'Begunstigde toevoegen';

  @override
  String get renamePayee => 'Begunstigde hernoemen';

  @override
  String get deletePayeeTitle => 'Begunstigde verwijderen?';

  @override
  String get noPayeesYet => 'Nog geen begunstigden';

  @override
  String get recurringTitle => 'Terugkerende sjablonen';

  @override
  String get noRecurringYet => 'Nog geen terugkerende sjablonen';

  @override
  String get deleteTemplateTitle => 'Terugkerend sjabloon verwijderen?';

  @override
  String get dayOfMonth => 'Dag van de maand (1-31)';

  @override
  String get dayOfMonthNote =>
      'Een maand met minder dagen gebruikt zijn eigen laatste dag.';

  @override
  String dayOfMonthLine(String day) {
    return 'Dag $day van de maand - ';
  }

  @override
  String get name => 'Naam';

  @override
  String get none => 'Geen';

  @override
  String get currency => 'Valuta';

  @override
  String get errorGeneric => 'Er is iets misgegaan. Probeer het opnieuw.';

  @override
  String get errorSigningIdentityMismatch =>
      'Deze herstelzin of dit keystore-bestand komt niet overeen met een ondertekeningsidentiteit in deze database.';

  @override
  String get errorInvalidLedgerBackup =>
      'Dit bestand is geen geldige Smara-back-up.';

  @override
  String get errorInvalidLedgerBackupNoIdentity =>
      'Deze back-up heeft geen ondertekeningsidentiteit - het is geen geldige Smara-back-up.';

  @override
  String get errorInvalidLedgerBackupUnverified =>
      'Deze back-up kon niet worden geverifieerd als intacte boekhouding en is daarom niet hersteld.';

  @override
  String errorInvalidLedgerBackupUnreadable(String detail) {
    return 'Dit bestand kon niet worden geopend als Smara-back-up: $detail';
  }

  @override
  String get errorForeignBackupIdentity =>
      'Deze back-up hoort bij een andere ondertekeningsidentiteit dan die op dit toestel.';

  @override
  String get errorAccountNotFinancial => 'Dat is geen financiële rekening.';

  @override
  String get errorAccountArchived => 'Die rekening is verborgen.';

  @override
  String get errorAccountNotArchived => 'Die rekening is niet verborgen.';

  @override
  String get errorAccountNoPositiveBalanceToCloseOut =>
      'Er is geen resterend saldo om over te boeken.';

  @override
  String get errorAccountHasNoGroup =>
      'Aan die rekening is geen groep toegewezen.';

  @override
  String get errorGroupHasNoCurrency =>
      'Voor die groep is nog geen valuta ingesteld.';

  @override
  String get errorGroupNotFound => 'Die rekeninggroep is niet gevonden.';

  @override
  String get errorInvestmentAccountsMustBeAssets =>
      'Alleen bezittingsrekeningen kunnen als beleggingsrekening worden gemarkeerd.';

  @override
  String get errorCreditCardsMustBeLiabilities =>
      'Alleen verplichtingenrekeningen kunnen als creditcard worden gemarkeerd.';

  @override
  String get errorOpeningBalanceMustBePositive =>
      'Het beginsaldo moet positief zijn indien opgegeven.';

  @override
  String get errorAccountTypeDoesNotMatchGroup =>
      'Dat rekeningtype komt niet overeen met de groep.';

  @override
  String get errorLastActiveAccount =>
      'De laatste actieve financiële rekening kan niet worden verborgen.';

  @override
  String get errorCurrencyRequiredToCreateGroup =>
      'Er is een valuta nodig om een groep aan te maken.';

  @override
  String get errorSystemGroupCannotBeArchived =>
      'Ingebouwde rekeninggroepen kunnen niet worden verborgen.';

  @override
  String get errorGroupAlreadyArchived => 'Die groep is al verborgen.';

  @override
  String get errorCannotArchiveGroupWithAccounts =>
      'Een groep met nog actieve rekeningen kan niet worden verborgen.';

  @override
  String get errorSystemGroupNeverArchived =>
      'Ingebouwde rekeninggroepen worden nooit verborgen.';

  @override
  String get errorAccountGroupsCannotBeDeleted =>
      'Rekeninggroepen kunnen niet worden verwijderd.';

  @override
  String get errorCannotReassignDifferentCurrency =>
      'Deze rekening kan niet worden verplaatst naar een groep met een andere valuta.';

  @override
  String get errorCannotChangeGroupCurrencyWithAccounts =>
      'De valuta kan niet worden gewijzigd zolang de groep actieve rekeningen heeft.';

  @override
  String get errorAmountMustBePositive => 'Bedrag moet positief zijn.';

  @override
  String get errorAccountCurrencyAmountMustBePositive =>
      'Bedrag in rekeningvaluta moet positief zijn.';

  @override
  String get errorAccountCurrencyAmountNotForSameCurrency =>
      'Bedrag in rekeningvaluta is alleen voor een boeking in vreemde valuta.';

  @override
  String get errorSplitNeedsTwoLines =>
      'Een splitsing heeft minstens twee categorieregels nodig.';

  @override
  String get errorSplitLineMustBePositive =>
      'Elke splitsingsregel moet een positief bedrag zijn.';

  @override
  String get errorSplitLinesMustSumToTotal =>
      'Splitsingsregels moeten optellen tot het totale transactiebedrag.';

  @override
  String get errorTransferAmountMustBePositive =>
      'Overboekingsbedrag moet positief zijn.';

  @override
  String get errorTransferAccountsMustDiffer =>
      'Bron- en bestemmingsrekening moeten verschillend zijn.';

  @override
  String get errorCloseoutRequiresDestinationAmount =>
      'Een afsluiting tussen valuta vereist een bekend bestemmingsbedrag.';

  @override
  String get errorDestinationAmountNotForSameCurrency =>
      'Bestemmingsbedrag is alleen voor een overboeking tussen valuta.';

  @override
  String get errorDestinationAmountMustBePositive =>
      'Bestemmingsbedrag moet positief zijn.';

  @override
  String get errorInvestmentCashExceeded =>
      'Er kan niet meer worden overgeboekt dan de kas van deze beleggingsrekening.';

  @override
  String get errorCannotReverseUnsettledProvisional =>
      'Wikkel deze lopende overboeking af in plaats van deze te herroepen.';

  @override
  String get errorAlreadyReversed =>
      'Deze boeking is al gecorrigeerd. De oorspronkelijke regel blijft ongewijzigd.';

  @override
  String get errorNotActiveExpenseCategory =>
      'Kies een actieve uitgavencategorie.';

  @override
  String get errorNotActiveIncomeCategory =>
      'Kies een actieve inkomstencategorie.';

  @override
  String get errorSettledAmountMustNotBeNegative =>
      'Aangekomen bedrag kan niet negatief zijn.';

  @override
  String get errorPendingTransferNotFound =>
      'Die lopende overboeking is niet gevonden.';

  @override
  String get errorPendingTransferAlreadySettled =>
      'Die lopende overboeking is al afgewikkeld.';

  @override
  String get errorSettledToMustBeSourceOrDestination =>
      'Kies de oorspronkelijke bron- of bestemmingsrekening.';

  @override
  String get errorFeeCategoryOnlyWhenReturningToSource =>
      'Een kostencategorie wordt alleen gebruikt wanneer geld wordt teruggestort naar de bronrekening.';

  @override
  String get errorSettledAmountMustBePositiveForDelivery =>
      'Voer een positief bedrag in voor wat er is aangekomen.';

  @override
  String get errorSettledAmountExceedsProvisional =>
      'Dat bedrag is meer dan er is verstuurd.';

  @override
  String get errorInstrumentNotFound => 'Dat instrument is niet gevonden.';

  @override
  String get errorIncomeRequiredForNonCash =>
      'Voor een niet-cash verwerving is een actieve inkomstencategorie vereist.';

  @override
  String get errorInsufficientCash =>
      'Onvoldoende kas op deze beleggingsrekening voor die aankoop.';

  @override
  String get errorSellQuantityAndPriceMustBePositive =>
      'Verkoophoeveelheid en eenheidsprijs moeten positief zijn.';

  @override
  String errorLockedUntil(String date) {
    return 'Verkopen niet mogelijk: sommige eenheden zijn vergrendeld tot $date.';
  }

  @override
  String get errorInsufficientQuantity =>
      'Je kunt niet meer verkopen dan je momenteel onvergrendeld in bezit hebt.';

  @override
  String get errorIncomeRequiredForGain =>
      'Voor een gerealiseerde winst is een actieve inkomstencategorie vereist.';

  @override
  String get errorExpenseRequiredForLoss =>
      'Voor een gerealiseerd verlies is een actieve uitgavencategorie vereist.';

  @override
  String errorBrokerageFailedAfterBuy(String detail) {
    return 'Aankoop geboekt, maar brokerkosten zijn mislukt: $detail';
  }

  @override
  String errorBrokerageFailedAfterSell(String detail) {
    return 'Verkoop geboekt, maar brokerkosten zijn mislukt: $detail';
  }

  @override
  String get errorDividendMustBePositive =>
      'Dividendbedrag moet positief zijn.';

  @override
  String get errorNotInvestmentAccount => 'Dat is geen beleggingsrekening.';

  @override
  String get errorNoInventoryCompanion =>
      'Bij deze beleggingsrekening ontbreekt de bijbehorende voorraadrekening.';

  @override
  String errorInvestmentReversalBlocked(String sells) {
    return 'Deze aankoop kan niet worden herroepen: latere verkoop/verkopen zijn afhankelijk van deze eenheden. Herroep eerst de afhankelijke verkoop/verkopen: $sells.';
  }

  @override
  String get errorMonthlyLimitMustBePositive =>
      'Maandlimiet moet positief zijn.';

  @override
  String get errorTemplateAmountMustBePositive =>
      'Sjabloonbedrag moet positief zijn.';

  @override
  String get errorOfxUnrecognized =>
      'Dit bestand kon niet worden herkend als OFX.';

  @override
  String get errorCsvEmpty => 'Het geselecteerde bestand is leeg.';

  @override
  String get errorCsvUnreadable =>
      'Dit bestand kon niet worden gelezen als CSV.';

  @override
  String get errorCsvNoRows => 'Het geselecteerde bestand heeft geen rijen.';

  @override
  String errorBackupCreateFailed(String detail) {
    return 'De back-up kon niet worden gemaakt: $detail';
  }

  @override
  String get errorBackupRestoreFailed =>
      'Deze back-up kon niet worden hersteld - onjuiste wachtwoordzin, of geen Smara-back-upbestand.';

  @override
  String get validationAmountAccountCategoryRequired =>
      'Bedrag, rekening en categorie zijn verplicht.';

  @override
  String get validationAmountAccountRequired =>
      'Bedrag en rekening zijn verplicht.';

  @override
  String get validationSplitLineIncomplete =>
      'Elke splitsingsregel heeft een categorie en een bedrag nodig.';

  @override
  String get validationSplitSumMismatch =>
      'Splitsingsregels moeten optellen tot het totale transactiebedrag.';

  @override
  String get validationFromToAmountRequired =>
      'Van-rekening, naar-rekening en bedrag zijn verplicht.';

  @override
  String get validationAmountArrivedRequired =>
      'Aangekomen bedrag is verplicht.';

  @override
  String get validationChooseReceivingAccount =>
      'Kies welke rekening het geld heeft ontvangen.';

  @override
  String get validationAccountCategoryRequired =>
      'Rekening en categorie zijn verplicht.';

  @override
  String get validationFixFailed =>
      'Deze correctie kon niet worden opgeslagen.';

  @override
  String get validationNameRequired => 'Geef je hoofdrekening een naam.';

  @override
  String get validationStillLoading =>
      'Nog aan het laden - probeer het straks opnieuw.';

  @override
  String get validationSaveAccountNameFailed =>
      'De rekeningnaam kon niet worden opgeslagen.';

  @override
  String get validationWrongPin => 'Onjuiste pincode. Probeer het opnieuw.';

  @override
  String get validationCategoryMustBeIncomeOrExpense =>
      'Categorie moet Inkomsten of Uitgaven zijn.';

  @override
  String get validationOnlyExpenseHasMonthlyLimit =>
      'Alleen een uitgavencategorie kan een maandlimiet hebben.';

  @override
  String get validationInvalidTemplate => 'Ongeldig sjabloon.';

  @override
  String get validationWrongKeystorePassphrase =>
      'Onjuiste wachtwoordzin voor dit keystore-bestand.';

  @override
  String get validationInvalidKeystoreFile =>
      'Dat lijkt geen geldig keystore-bestand te zijn.';

  @override
  String get validationRestorePhraseFailed =>
      'Herstellen vanuit die herstelzin is mislukt.';

  @override
  String validationGenerateKeyFailed(String detail) {
    return 'Er kon geen ondertekeningssleutel worden gegenereerd op dit toestel: $detail';
  }

  @override
  String validationSaveCurrencyFailed(String detail) {
    return 'Deze valuta kon niet worden opgeslagen: $detail';
  }

  @override
  String get validationMigrationFailed =>
      'Migratie mislukt. Probeer het opnieuw.';

  @override
  String get validationChooseBackupFile => 'Kies eerst een back-upbestand.';

  @override
  String get validationPassphraseRequired => 'Voer een wachtwoordzin in.';

  @override
  String get validationPinsDoNotMatch => 'De twee pincodes komen niet overeen.';

  @override
  String get validationFeePositiveWithCategory =>
      'Overboekingskosten moeten een positief bedrag zijn met een geselecteerde uitgavencategorie.';

  @override
  String get validationFeeMustBeLessThanAmount =>
      'Bij een overboeking met ingehouden kosten moeten de kosten lager zijn dan het bedrag.';

  @override
  String validationTransferSavedFeeFailed(String detail) {
    return 'Overboeking opgeslagen, maar de kosten konden niet worden geregistreerd: $detail';
  }

  @override
  String get validationEnterValidAmount => 'Voer een geldig bedrag in.';

  @override
  String validationConfirmWordMismatch(String n) {
    return 'Woord $n komt niet overeen met je opgeslagen zin. Controleer het en probeer het opnieuw.';
  }

  @override
  String get errorBuyQuantityAndPriceMustBePositive =>
      'Aankoophoeveelheid en eenheidsprijs moeten positief zijn.';

  @override
  String get errorInstrumentArchived =>
      'Een gearchiveerd instrument kan niet worden gekocht.';

  @override
  String get errorNonCashCannotIncludeBrokerage =>
      'Niet-cash verwervingen kunnen geen brokerkosten bevatten.';

  @override
  String get errorBrokerageRequiresExpenseCategory =>
      'Als de brokerkosten positief zijn, is een actieve uitgavencategorie vereist.';

  @override
  String get errorSellProceedsMustCoverBrokerage =>
      'De verkoopopbrengst moet minstens gelijk zijn aan de brokerkosten.';

  @override
  String homeSpentOfLimitThisMonth(String spent, String limit) {
    return '$spent van $limit deze maand';
  }

  @override
  String get unlockBiometricReason => 'Smara Boekhouding ontgrendelen';

  @override
  String get searchLabel => 'Zoeken';

  @override
  String get openingBalance => 'Beginsaldo';

  @override
  String transferToName(String name) {
    return 'Overboeking: $name';
  }

  @override
  String get feeForTransfer => 'Kosten voor overboeking';

  @override
  String feeForTransferTo(String name) {
    return 'Kosten voor overboeking naar $name';
  }

  @override
  String couldNotOpenFilePicker(String detail) {
    return 'De bestandskiezer kon niet worden geopend: $detail';
  }

  @override
  String pleaseSelectFile(String extensions) {
    return 'Selecteer een .$extensions-bestand';
  }

  @override
  String get currencyCodeIso => 'Valutacode (ISO 4217, bijv. USD)';

  @override
  String splitCounterpartMore(String name, String count) {
    return '$name +$count meer';
  }

  @override
  String get dateLabel => 'Datum';

  @override
  String get noneSelected => 'Geen';

  @override
  String reviewEntriesBeforeContinuing(String count) {
    return 'Controleer onderstaande boekingen ($count in totaal) voordat je doorgaat.';
  }

  @override
  String youReceived(String amount) {
    return 'Je ontving $amount';
  }

  @override
  String get leaveBlankIfRateUnknown =>
      'Laat leeg als de wisselkoers nog niet bekend is.';

  @override
  String get recordTradeBlurb =>
      'Registreer een transactie die al heeft plaatsgevonden. Deze app plaatst geen orders.';

  @override
  String get feeOnTopBlurb =>
      'Aan: het bovenstaande bedrag is het totaal dat van deze rekening wordt afgeschreven; de kosten worden hieruit betaald.';

  @override
  String get feeBankBlurb =>
      'Een vooraf in rekening gebrachte commissie door je bank of een tussenpersoon.';

  @override
  String get validationPinMinLength =>
      'Pincode moet minstens 4 cijfers hebben.';

  @override
  String get restoreBackupBlurb =>
      'Dit vervangt alles wat nu in deze app staat door de back-up — het wordt niet samengevoegd. Kies een back-upbestand en voer de wachtwoordzin in waarmee je het hebt beveiligd.';

  @override
  String get actionReplace => 'Vervangen';

  @override
  String hideAccountBody(String name) {
    return '$name is niet meer beschikbaar voor nieuwe transacties.';
  }

  @override
  String hideGroupBody(String name) {
    return '$name wordt niet meer aangeboden bij het aanmaken of opnieuw toewijzen van rekeningen.';
  }

  @override
  String hideCategoryBody(String name) {
    return '$name wordt niet meer aangeboden bij het registreren van nieuwe transacties.';
  }

  @override
  String get hideInstrumentBody =>
      'Verborgen instrumenten blijven staan op eerdere aan- en verkopen. Je kunt er nog steeds een dividend voor registreren.';

  @override
  String nameHidden(String name) {
    return '$name (verborgen)';
  }

  @override
  String get noCurrencySet => 'Geen valuta ingesteld';

  @override
  String deletePayeeBody(String name) {
    return '$name en de bijbehorende onthouden standaardwaarden worden verwijderd. Eerdere transacties blijven ongewijzigd.';
  }

  @override
  String deleteTemplateBody(String name) {
    return '$name wordt niet meer als vervallen aangeboden. Eerdere transacties die het al heeft geregistreerd, blijven ongewijzigd.';
  }

  @override
  String deleteProfileBody(String name) {
    return 'De opgeslagen kolomkoppeling \"$name\" wordt verwijderd. Al geïmporteerde afschriften blijven ongewijzigd.';
  }

  @override
  String deleteRuleBody(String keyword) {
    return 'Imports worden niet meer automatisch gecategoriseerd op basis van \"$keyword\". Transacties die met deze regel al zijn gecategoriseerd, blijven ongewijzigd.';
  }

  @override
  String get firstWeekBlurb =>
      'Voeg nu optioneel een creditcard of contante rekening toe - je kunt later altijd meer rekeningen toevoegen via Instellingen.';

  @override
  String get deliveredToDestination => 'Afgeleverd bij bestemming';

  @override
  String deliveredToName(String name) {
    return 'Afgeleverd bij $name';
  }

  @override
  String youReceivedLessThanExpected(String amount, String currency) {
    return 'Je ontving $amount $currency minder dan verwacht - kies een categorie om het verschil te dekken.';
  }

  @override
  String get dateRangeLabel => 'Datumbereik';

  @override
  String get addTemplate => 'Sjabloon toevoegen';

  @override
  String get editTemplate => 'Sjabloon bewerken';

  @override
  String get validationFillTemplateFields =>
      'Vul elk veld in met een geldig bedrag en een geldige dag.';

  @override
  String get saveCsvExport => 'CSV-export opslaan';

  @override
  String get referenceRate => 'Referentiekoers';

  @override
  String get yourRate => 'Jouw koers';

  @override
  String leaveBlankIfThisWasAccountCurrency(String currency) {
    return 'Laat leeg als dit in $currency was, de eigen valuta van de rekening.';
  }

  @override
  String get lockUntilOptional => 'Vergrendelen tot (optioneel)';

  @override
  String lockedUntilDate(String date) {
    return 'Vergrendeld tot $date';
  }

  @override
  String get copiedResearchPrompt =>
      'Een onderzoeksvraag gekopieerd — geen browser-URL beschikbaar, of je bent offline.';

  @override
  String get openedFavouriteResearchTool =>
      'Je favoriete onderzoekstool geopend.';

  @override
  String get looksLikeGain => 'Dit lijkt een winst';

  @override
  String get looksLikeLoss => 'Dit lijkt een verlies';

  @override
  String get looksLikeBreakEven => 'Dit lijkt quitte';

  @override
  String sellableQuantity(String name, String qty) {
    return '$name ($qty verkoopbaar)';
  }

  @override
  String columnN(String index) {
    return 'Kolom $index';
  }

  @override
  String get importingLabel => 'Bezig met importeren...';

  @override
  String get confirmImport => 'Import bevestigen';

  @override
  String get manageSavedCategoryRules => 'Opgeslagen categorieregels beheren';

  @override
  String statementCurrencyMismatch(String currency) {
    return 'De valuta van dit bestand ($currency) komt niet overeen met de valuta van de geselecteerde rekening.';
  }

  @override
  String get categoryRulesTitle => 'Categorieregels';

  @override
  String get possibleDuplicate => 'mogelijk duplicaat';

  @override
  String get unknownCategory => 'Onbekende categorie';
}
