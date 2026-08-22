// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Smara Buchhaltung';

  @override
  String get navHome => 'Start';

  @override
  String get navRegister => 'Register';

  @override
  String get navSummary => 'Übersicht';

  @override
  String get navAccounts => 'Konten';

  @override
  String get navCategories => 'Kategorien';

  @override
  String get actionCancel => 'Abbrechen';

  @override
  String get actionSave => 'Speichern';

  @override
  String get actionDelete => 'Löschen';

  @override
  String get actionDone => 'Fertig';

  @override
  String get actionContinue => 'Weiter';

  @override
  String get actionDismiss => 'Schließen';

  @override
  String get actionRetry => 'Erneut versuchen';

  @override
  String get actionSkip => 'Überspringen';

  @override
  String get actionConfirm => 'Bestätigen';

  @override
  String get actionAdd => 'Hinzufügen';

  @override
  String get actionEdit => 'Bearbeiten';

  @override
  String get actionRename => 'Umbenennen';

  @override
  String get actionHide => 'Ausblenden';

  @override
  String get actionCreate => 'Anlegen';

  @override
  String get actionCloseApp => 'App schließen';

  @override
  String get actionUnlock => 'Entsperren';

  @override
  String get actionSettle => 'Abschließen';

  @override
  String get actionFinish => 'Abschließen';

  @override
  String get actionPreview => 'Vorschau';

  @override
  String get actionImport => 'Importieren';

  @override
  String get actionExportCsv => 'CSV exportieren';

  @override
  String get actionChooseFile => 'Datei auswählen';

  @override
  String get actionRestore => 'Wiederherstellen';

  @override
  String get actionFix => 'Korrigieren';

  @override
  String get actionBuy => 'Kaufen';

  @override
  String get actionSell => 'Verkaufen';

  @override
  String get actionDividend => 'Dividende';

  @override
  String get actionRecordBuy => 'Kauf erfassen';

  @override
  String get actionRecordSell => 'Verkauf erfassen';

  @override
  String get actionRecordDividend => 'Dividende erfassen';

  @override
  String get actionPayCard => 'Karte bezahlen';

  @override
  String get actionTransfer => 'Umbuchen';

  @override
  String get actionRecordTransaction => 'Transaktion erfassen';

  @override
  String get actionImportStatement => 'Kontoauszug importieren';

  @override
  String get actionClearDates => 'Daten löschen';

  @override
  String get actionClearSearch => 'Suche und Filter zurücksetzen';

  @override
  String get actionUseBiometrics => 'Biometrie verwenden';

  @override
  String get actionSetPin => 'PIN festlegen';

  @override
  String get actionChangePin => 'PIN ändern';

  @override
  String get actionSaveBackup => 'Sicherung speichern';

  @override
  String get actionRestoreBackup => 'Sicherung wiederherstellen';

  @override
  String get actionSaveRule => 'Regel speichern';

  @override
  String get actionConfirmFix => 'Korrektur bestätigen';

  @override
  String get captureSpent => 'Ausgegeben';

  @override
  String get captureReceived => 'Erhalten';

  @override
  String get captureMovedMoney => 'Geld verschoben';

  @override
  String get captureImportStatement => 'Kontoauszug importieren';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get settingsLanguageSystem => 'Gerätesprache';

  @override
  String get settingsFetchFxRates => 'Referenz-Wechselkurse abrufen';

  @override
  String get settingsFetchFxRatesSubtitle =>
      'Zeigt neben dem Zielbetrag bei Fremdwährungsüberweisungen einen indikativen Marktkurs nur zum Vergleich an – wird nie zum Ausfüllen des Betrags verwendet.';

  @override
  String get settingsRateProvider => 'Kursanbieter';

  @override
  String get settingsFetchMarketPrices =>
      'Marktpreise für Investitionen abrufen';

  @override
  String get settingsFetchMarketPricesSubtitle =>
      'Ruft die letzten Kurse für Instrumente mit Ticker oder ISIN ab, um den Portfoliowert zu schätzen. Wird nie zur Erfassung eines Trades verwendet und sendet nie, wie viele Sie halten.';

  @override
  String get settingsMarketPriceProvider => 'Marktpreisanbieter';

  @override
  String get settingsFavouriteResearchTool => 'Bevorzugtes Recherchetool';

  @override
  String get settingsFavouriteResearchToolSubtitle =>
      'Ein Tippen auf einen Instrumentennamen bei den Beständen öffnet dieses Tool im Browser mit einem Recherche-Prompt – keine Integration und keine Anlageberatung.';

  @override
  String get settingsBackup => 'Sicherung';

  @override
  String get settingsBackupBlurb =>
      'Speichern Sie eine verschlüsselte Kopie Ihrer Bücher an einem selbst gewählten Ort oder stellen Sie sie von dort wieder her. Dies ist getrennt von Ihrer Wiederherstellungsphrase oder Keystore-Datei, die Ihren Signierschlüssel sichern, nicht Ihre Bücher.';

  @override
  String get settingsLock => 'Sperre';

  @override
  String get settingsLockBlurb =>
      'Für das Öffnen der App eine PIN oder, sofern verfügbar, Biometrie verlangen.';

  @override
  String get settingsRequireUnlock =>
      'Zum Öffnen der App Entsperren erforderlich machen';

  @override
  String get settingsLockAfter => 'Sperren nach';

  @override
  String get settingsLockImmediately => 'Sofort';

  @override
  String get settingsLock1Minute => '1 Minute';

  @override
  String get settingsLock5Minutes => '5 Minuten';

  @override
  String get settingsLock15Minutes => '15 Minuten';

  @override
  String get settingsAllowBiometrics => 'Auch Biometrie zulassen';

  @override
  String get settingsHideSnapshot => 'Kontostände im App-Wechsler ausblenden';

  @override
  String get settingsHideSnapshotSubtitle =>
      'Verdeckt diesen Bildschirm beim Wechseln zu einer anderen App, damit er im App-Wechsler nicht auf einen Blick sichtbar ist.';

  @override
  String get settingsHideSnapshotUnavailable =>
      'Kontostände im App-Wechsler ausblenden ist auf dieser Plattform nicht verfügbar.';

  @override
  String get settingsPayees => 'Zahlungsempfänger';

  @override
  String get settingsManagePayees => 'Zahlungsempfänger verwalten';

  @override
  String get settingsPayeesBlurb =>
      'Gemerkte Zahlungsempfängernamen mit ihrer Standardkategorie und ihrem Standardkonto, die bei der Autovervollständigung beim Erfassen einer Transaktion vorgeschlagen werden.';

  @override
  String get settingsRecurring => 'Wiederkehrende Vorlagen';

  @override
  String get settingsManageRecurring => 'Wiederkehrende Vorlagen verwalten';

  @override
  String get settingsRecurringBlurb =>
      'Rechnungen oder Einnahmen, die sich monatlich wiederholen, wie Miete oder Gehalt. Eine fällige Vorlage erscheint auf der Startseite, um sie mit einem Tipp zu erfassen – wird nie automatisch gebucht.';

  @override
  String get settingsAbout => 'Über';

  @override
  String get providerFrankfurter => 'Frankfurter (EZB-Kurse)';

  @override
  String get providerOpenErApi => 'ExchangeRate-API (open.er-api.com)';

  @override
  String get providerStooq => 'Stooq (tägliche Kurse)';

  @override
  String get providerYahooFinance => 'Yahoo Finance (Chart-API)';

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
      'Bargeld & Zahlungsmitteläquivalente';

  @override
  String get systemGroupPensionRetirement => 'Rente & Altersvorsorge';

  @override
  String get systemGroupCreditShortTerm => 'Kredit & kurzfristige Schulden';

  @override
  String get systemGroupLoansMortgages => 'Darlehen & Hypotheken';

  @override
  String get systemGroupInvestments => 'Investitionen';

  @override
  String get systemAccountCashBank => 'Bargeld & Bank';

  @override
  String get systemCategorySalary => 'Gehalt';

  @override
  String get systemCategoryOtherIncome => 'Sonstige Einnahmen';

  @override
  String get systemCategoryGroceries => 'Lebensmittel';

  @override
  String get systemCategoryRentMortgage => 'Miete/Hypothek';

  @override
  String get systemCategoryUtilities => 'Nebenkosten';

  @override
  String get systemCategoryTransport => 'Transport';

  @override
  String get systemCategoryFoodOut => 'Essen gehen';

  @override
  String get systemCategoryPhone => 'Telefon';

  @override
  String get systemCategoryHealth => 'Gesundheit';

  @override
  String get systemCategoryOtherExpense => 'Sonstige Ausgaben';

  @override
  String get homeThisMonth => 'DIESER MONAT';

  @override
  String get homeMoneyInTransit => 'GELD UNTERWEGS';

  @override
  String get homeWhatYouHaveMinusWhatYouOwe =>
      'WAS SIE HABEN MINUS WAS SIE SCHULDEN';

  @override
  String homeWhatYouHave(String amount, String currency) {
    return 'Ihr Guthaben $amount $currency';
  }

  @override
  String homeNetPosition(String amount, String currency) {
    return '$amount $currency';
  }

  @override
  String homeHaveAndOwe(String haveAmount, String currency, String oweAmount) {
    return 'Ihr Guthaben $haveAmount $currency  •  Ihre Schulden $oweAmount $currency';
  }

  @override
  String youSentFrom(String amount, String currency, String name) {
    return 'Sie haben $amount $currency von $name gesendet';
  }

  @override
  String youSentTo(String amount, String currency, String name) {
    return 'Sie haben $amount $currency an $name gesendet';
  }

  @override
  String get hiddenLabel => 'Ausgeblendet';

  @override
  String get allAccounts => 'Alle Konten';

  @override
  String savedToPath(String path) {
    return 'Gespeichert unter $path';
  }

  @override
  String get keystoreExportFailed =>
      'Die Keystore-Datei konnte nicht exportiert werden. Sie können diesen Schritt überspringen.';

  @override
  String get enterPassphraseToProtect =>
      'Geben Sie eine Passphrase ein, um die Datei zu schützen.';

  @override
  String get homeTapWhenArrived =>
      'Tippen, sobald Sie wissen, was angekommen ist';

  @override
  String homeReturnedTo(String name) {
    return 'Zurück an $name';
  }

  @override
  String get homeDueToday => 'HEUTE FÄLLIG';

  @override
  String homeDueLine(String category, String account) {
    return '$category · $account · zum Erfassen tippen';
  }

  @override
  String get homeOverLimit => 'Limit überschritten';

  @override
  String homeSpentOfLimit(String spent, String limit) {
    return '$spent von $limit';
  }

  @override
  String homeRemaining(String amount) {
    return 'Verbleibend: $amount';
  }

  @override
  String get homeNoAccounts => 'Keine Konten';

  @override
  String get homeCashRegister => 'Bargeldkasse';

  @override
  String get homeMarketEstimate => 'Marktschätzung';

  @override
  String get registerTitle => 'Register';

  @override
  String get registerSearchHint => 'Beschreibung, Kategorie oder Betrag';

  @override
  String get registerNoTransactions => 'Noch keine Transaktionen';

  @override
  String get registerNoEntries => 'Noch keine Einträge erfasst.';

  @override
  String get registerSpentOnly => 'Nur Ausgaben';

  @override
  String get registerReceivedOnly => 'Nur Einnahmen';

  @override
  String get registerAll => 'Alle';

  @override
  String get registerUnverified =>
      'Nicht verifiziert – von Summen ausgeschlossen';

  @override
  String get registerSuperseded =>
      'Durch Migration ersetzt – von Summen ausgeschlossen';

  @override
  String get summaryTitle => 'Übersicht';

  @override
  String get summaryTotalIncome => 'Gesamteinnahmen';

  @override
  String get summaryTotalExpense => 'Gesamtausgaben';

  @override
  String summaryDateRange(String start, String end) {
    return '$start bis $end';
  }

  @override
  String get accountsTitle => 'Konten';

  @override
  String get categoriesTitle => 'Kategorien';

  @override
  String get accountName => 'Kontoname';

  @override
  String get createAccount => 'Konto anlegen';

  @override
  String get createGroup => 'Gruppe anlegen';

  @override
  String get editGroup => 'Gruppe bearbeiten';

  @override
  String get renameAccount => 'Konto umbenennen';

  @override
  String get renameCategory => 'Kategorie umbenennen';

  @override
  String get addCategory => 'Kategorie hinzufügen';

  @override
  String get groupLabel => 'Gruppe';

  @override
  String get kindLabel => 'Art';

  @override
  String get asset => 'Aktiva';

  @override
  String get liability => 'Passiva';

  @override
  String get income => 'Einnahmen';

  @override
  String get expense => 'Ausgaben';

  @override
  String get thisAccountHoldsInvestments =>
      'Dieses Konto enthält Investitionen';

  @override
  String get thisAccountHoldsInvestmentsSubtitle =>
      'Bargeld plus Bestand, den Sie mit Kaufen, Verkaufen und Dividende erfassen.';

  @override
  String get thisIsACreditCard => 'Dies ist eine Kreditkarte';

  @override
  String get openingBalanceOptional => 'Anfangssaldo (optional)';

  @override
  String get currencyIso => 'Währung (ISO 4217)';

  @override
  String get currencyIsoExample => 'Währung (ISO 4217, z. B. USD)';

  @override
  String get hideAccountTitle => 'Konto aus neuen Einträgen ausblenden?';

  @override
  String get hideCategoryTitle => 'Kategorie aus neuen Einträgen ausblenden?';

  @override
  String get hideGroupTitle => 'Gruppe aus neuen Einträgen ausblenden?';

  @override
  String get reassignGroup => 'Gruppe neu zuweisen';

  @override
  String get transferRemainingBalance => 'Restguthaben umbuchen';

  @override
  String get monthlyLimit => 'Monatslimit';

  @override
  String get monthlyLimitHint => 'Limit (leer lassen zum Löschen)';

  @override
  String get monthlyLimitBlurb =>
      'Ein optionaler Richtwert für die bisherigen Ausgaben dieser Kategorie im laufenden Monat.';

  @override
  String get manageCategoryRules => 'Kategorieregeln verwalten';

  @override
  String get amount => 'Betrag';

  @override
  String get category => 'Kategorie';

  @override
  String get account => 'Konto';

  @override
  String get fromAccount => 'Von Konto';

  @override
  String get toAccount => 'An Konto';

  @override
  String get descriptionOptional => 'Beschreibung (optional)';

  @override
  String get alsoRememberPayee => 'Auch als Zahlungsempfänger merken';

  @override
  String get splitIntoCategories => 'In mehrere Kategorien aufteilen';

  @override
  String categoryN(String n) {
    return 'Kategorie $n';
  }

  @override
  String get destinationAmount => 'Zielbetrag';

  @override
  String get destinationAmountOptional => 'Zielbetrag (optional)';

  @override
  String get accountCurrencyAmountOptional =>
      'Betrag in Kontowährung (optional)';

  @override
  String get transactionCurrencyOptional => 'Transaktionswährung (optional)';

  @override
  String get feeOptional => 'Gebühr (optional)';

  @override
  String get feeAmount => 'Gebührenbetrag';

  @override
  String get feeCategory => 'Gebührenkategorie';

  @override
  String get feeDescriptionOptional => 'Gebührenbeschreibung (optional)';

  @override
  String get feeDeducted => 'Die Gebühr wird vom obigen Betrag abgezogen';

  @override
  String get needTwoAccountsToTransfer =>
      'Erstellen Sie mindestens zwei aktive Konten, um eine Umbuchung vorzunehmen.';

  @override
  String get whatArrivedTitle => 'Was ist angekommen?';

  @override
  String get whatArrivedBlurb =>
      'Geben Sie an, was tatsächlich angekommen ist.';

  @override
  String get amountThatArrived => 'Angekommener Betrag';

  @override
  String get feeLossCategory => 'Gebühren-/Verlustkategorie';

  @override
  String get alreadySettled => 'Bereits abgeschlossen.';

  @override
  String get holdingsTitle => 'Bestände';

  @override
  String get holdingsCash => 'Bargeld';

  @override
  String get holdingsInventory => 'BESTAND';

  @override
  String holdingsBook(String amount, String currency) {
    return 'Buchwert (Bargeld + Kosten) $amount $currency';
  }

  @override
  String holdingsMarketEstimate(String amount, String currency) {
    return 'Marktschätzung $amount $currency';
  }

  @override
  String get holdingsNoHoldings =>
      'Noch keine Bestände. Erfassen Sie einen Kauf, um ein Instrument hinzuzufügen.';

  @override
  String get holdingsQuotesBlurb =>
      'Kurse sind Schätzungen, kein Maklerpreis. Diese App platziert keine Orders.';

  @override
  String get holdingsTapNameToResearch =>
      'Tippen Sie auf den Namen, um zu recherchieren. Kurse sind Schätzungen, keine Beratung.';

  @override
  String get instrument => 'Instrument';

  @override
  String get newInstrument => 'Neues Instrument';

  @override
  String get renameInstrument => 'Instrument umbenennen';

  @override
  String get instrumentActions => 'Instrumentaktionen';

  @override
  String hideInstrumentTitle(String name) {
    return '$name ausblenden?';
  }

  @override
  String get tickerOptional => 'Ticker (optional)';

  @override
  String get isinOptional => 'ISIN (optional)';

  @override
  String get quantity => 'Menge';

  @override
  String get unitPrice => 'Stückpreis';

  @override
  String get brokerageOptional => 'Courtage (optional)';

  @override
  String get brokerageExpenseCategory => 'Courtage-Ausgabenkategorie';

  @override
  String get incomeCategory => 'Einnahmenkategorie';

  @override
  String get gainIncomeCategory => 'Gewinn-Einnahmenkategorie';

  @override
  String get lossExpenseCategory => 'Verlust-Ausgabenkategorie';

  @override
  String get nonCash => 'Nicht bar';

  @override
  String get cash => 'Bargeld';

  @override
  String get locked => 'Gesperrt';

  @override
  String get lockUntilHint =>
      'Ihr eigener Vermerk zu einer Beschränkung, keine Maklerregel.';

  @override
  String get instrumentKindStock => 'Aktie';

  @override
  String get instrumentKindEtf => 'ETF';

  @override
  String get instrumentKindMutualFund => 'Investmentfonds';

  @override
  String get instrumentKindBond => 'Anleihe';

  @override
  String get instrumentKindOther => 'Andere';

  @override
  String get quoteUseLive => 'Live-Kurs';

  @override
  String get quoteUseCached => 'Zwischengespeicherter Kurs';

  @override
  String get quoteUseStale => 'Veralteter Kurs';

  @override
  String get quoteUseMissing => 'Kosten werden verwendet (kein Kurs)';

  @override
  String get quoteUseDisabled =>
      'Kurse deaktiviert — Kosten/Cache wird verwendet';

  @override
  String get quoteUseCurrencyMismatch =>
      'Kosten werden verwendet (Kurswährung weicht ab)';

  @override
  String unrealizedLabel(String amount, String currency) {
    return 'Nicht realisiert $amount $currency';
  }

  @override
  String holdingsUnitsCost(String qty) {
    return '$qty Einheiten · ';
  }

  @override
  String get recoveryPhraseTitle => 'Ihre Wiederherstellungsphrase';

  @override
  String get recoveryPhraseConfirmTitle => 'Bestätigen Sie Ihre Phrase';

  @override
  String get recoveryPhraseBlurb =>
      'Diese 24 Wörter sind die einzige Möglichkeit, Ihren Transaktionsverlauf wiederherzustellen, falls dieses Gerät verloren geht, zurückgesetzt oder ersetzt wird. Smara Buchhaltung hat keinen Server und kann sie nicht für Sie wiederherstellen.\n\nWenn Sie dieses Gerät und diese Phrase zusammen verlieren, wird jede von Ihnen erfasste Transaktion dauerhaft nicht mehr verifizierbar.';

  @override
  String get recoveryPhraseWriteDown =>
      'Schreiben Sie diese Wörter in der richtigen Reihenfolge auf und bewahren Sie sie sicher und getrennt von diesem Gerät auf.';

  @override
  String get iveSavedRecoveryPhrase =>
      'Ich habe meine Wiederherstellungsphrase gespeichert';

  @override
  String get confirmPhraseBlurb =>
      'Geben Sie die angeforderten Wörter aus der soeben gespeicherten Phrase ein.';

  @override
  String wordNumber(String n) {
    return 'Wort Nr. $n';
  }

  @override
  String get keystoreExportTitle => 'Keystore-Datei exportieren';

  @override
  String get keystoreExportBlurb =>
      'Zusätzlich zu Ihrer Wiederherstellungsphrase können Sie eine verschlüsselte, durch eine selbst gewählte Passphrase geschützte Keystore-Datei speichern. Dies ist optional – Ihre Wiederherstellungsphrase allein reicht immer aus, um Ihren Signierschlüssel wiederherzustellen.';

  @override
  String get keystorePassphrase => 'Passphrase';

  @override
  String get exportKeystoreFile => 'Keystore-Datei exportieren';

  @override
  String get chooseCurrencyTitle => 'Wählen Sie Ihre Währung';

  @override
  String get chooseCurrencyBlurb =>
      'Jede Kontogruppe (Bargeld & Zahlungsmitteläquivalente, Rente & Altersvorsorge usw.) verwendet vorerst diese eine Währung. Sie können später weiterhin Konten in einer anderen Währung hinzufügen, indem Sie dafür eine neue Gruppe anlegen.';

  @override
  String get currencyBackfillTitle =>
      'Wählen Sie eine Währung für bestehende Gruppen';

  @override
  String get currencyBackfillBlurb =>
      'Diese App unterstützt jetzt mehrere Währungen. Ihre bestehenden Konten und Kontogruppen benötigen eine Währung – da sie alle vor Einführung dieser Funktion eingerichtet wurden, gilt eine Wahl für sie alle.';

  @override
  String get firstAccountTitle => 'Benennen Sie Ihr Konto';

  @override
  String get firstAccountBlurb =>
      'Dies ist das bereits für Sie eingerichtete Konto – geben Sie ihm einen Namen, den Sie erkennen, wie Ihre Bank. Sie erfassen als Nächstes ein Ausgegeben oder Erhalten und schützen dann das Gerät mit Ihrer Wiederherstellungsphrase.';

  @override
  String get whatsMainAccountCalled => 'Wie heißt Ihr Hauptkonto?';

  @override
  String get restoreTitle => 'Signierschlüssel wiederherstellen';

  @override
  String get restoreBlurb =>
      'Dieses Gerät hat vorhandene Bücher, aber keinen passenden Signierschlüssel. Stellen Sie ihn aus Ihrer gespeicherten Wiederherstellungsphrase oder Keystore-Datei wieder her – Ihre Daten werden normal verifiziert, und nichts wird neu signiert oder verändert.';

  @override
  String get recoveryPhrase24 => 'Wiederherstellungsphrase (alle 24 Wörter)';

  @override
  String get keystoreFile => 'Keystore-Datei';

  @override
  String get keystoreFileContents => 'Inhalt der Keystore-Datei';

  @override
  String get optionalBackupFile => 'Optionale Sicherungsdatei';

  @override
  String get iDontHavePhrase =>
      'Ich habe meine Wiederherstellungsphrase oder Keystore-Datei nicht';

  @override
  String get migrationTitle => 'Zu einem neuen Schlüssel migrieren';

  @override
  String get migrationBlurb =>
      'Ohne Ihre Wiederherstellungsphrase oder Keystore-Datei kann der Signierschlüssel dieses Geräts nicht wiederhergestellt werden. Sie können mit einem neuen Schlüssel beginnen. Alte Einträge bleiben sichtbar, gelten aber als ersetzt.';

  @override
  String get iConfirmBooksValid =>
      'Ich bestätige, dass die aktuellen Bücher gültig sind';

  @override
  String get whyWeDontEdit => 'Warum wir alte Einträge nicht bearbeiten';

  @override
  String get whyWeDontEditBody =>
      'Wenn Sie einen Fehler korrigieren, behalten wir die alte Zeile und fügen daneben eine Korrektur hinzu, statt zu ändern, was Sie bereits eingegeben haben. So zeigt Ihr Verlauf immer genau, was passiert ist und wann Sie es korrigiert haben — nichts ändert sich heimlich im Hintergrund.';

  @override
  String get lockTitle => 'Entsperren';

  @override
  String get lockScreenTitle => 'Gesperrt';

  @override
  String get enterPinToContinue => 'PIN eingeben, um fortzufahren';

  @override
  String get pinLabel => 'PIN';

  @override
  String get setPinTitle => 'PIN festlegen';

  @override
  String get currentPin => 'Aktuelle PIN';

  @override
  String get newPin => 'Neue PIN';

  @override
  String get confirmPin => 'PIN bestätigen';

  @override
  String get confirmNewPin => 'Neue PIN bestätigen';

  @override
  String get firstWeekTitle => 'Richten Sie Ihre Konten ein';

  @override
  String get addCashAccount => 'Bargeldkonto hinzufügen';

  @override
  String get addCreditCard => 'Kreditkarte hinzufügen';

  @override
  String get cashAccountName => 'Name des Bargeldkontos';

  @override
  String get cardName => 'Kartenname';

  @override
  String get paidFromBank => 'Von Bank bezahlt';

  @override
  String get paidFromCard => 'Von Karte bezahlt';

  @override
  String get choosePassphraseTitle =>
      'Wählen Sie eine Passphrase zum Schutz dieser Sicherung. Es gibt keine Wiederherstellung, wenn Sie sie vergessen.';

  @override
  String get replaceBooksTitle => 'Ihre lokalen Bücher ersetzen?';

  @override
  String get replaceBooksBody =>
      'Dies ersetzt alles, was sich derzeit in dieser App befindet, durch die Sicherung. Schließen und öffnen Sie die App danach erneut.';

  @override
  String get chooseBackupFileFirst =>
      'Wählen Sie zuerst eine Sicherungsdatei aus.';

  @override
  String get backupRestored => 'Sicherung wiederhergestellt';

  @override
  String get backupRestoredBody =>
      'Ihre Bücher wurden wiederhergestellt. Schließen und öffnen Sie die App erneut, um fortzufahren.';

  @override
  String get fixThisEntry => 'Diesen Eintrag korrigieren';

  @override
  String get fixBlurb =>
      'Die alte Zeile bleibt genau so, wie sie war. Das Bestätigen fügt eine Umkehrzeile und die korrigierte hinzu.';

  @override
  String get importStatementTitle => 'Kontoauszug importieren';

  @override
  String get importOfx => 'OFX importieren';

  @override
  String get importOfxQfxFile => 'OFX-/QFX-Datei importieren';

  @override
  String get importCsvFile => 'CSV-Datei importieren';

  @override
  String get whatKindOfStatement =>
      'Welche Art von Kontoauszugsdatei haben Sie?';

  @override
  String get chooseAccountForFile =>
      'Wählen Sie das Konto, zu dem diese Datei gehört.';

  @override
  String get importIntoAccount => 'In Konto importieren';

  @override
  String get useSavedProfile => 'Gespeichertes Profil verwenden';

  @override
  String get saveMappingProfile =>
      'Diese Zuordnung als Profil speichern (optional)';

  @override
  String get renameProfile => 'Profil umbenennen';

  @override
  String get deleteProfileTitle => 'Profil löschen?';

  @override
  String get fileHasHeader => 'Datei hat eine Kopfzeile';

  @override
  String get dateColumn => 'Datumsspalte';

  @override
  String get dateFormatHint => 'Datumsformat (z. B. dd/MM/yyyy)';

  @override
  String get amountColumn => 'Betragsspalte';

  @override
  String get amountConvention => 'Betragskonvention';

  @override
  String get signedAmountColumn => 'Vorzeichenbehaftete Betragsspalte';

  @override
  String get separateDebitCredit => 'Separate Soll-/Haben-Spalten';

  @override
  String get debitColumn => 'Sollspalte';

  @override
  String get creditColumn => 'Habenspalte';

  @override
  String get decimalSeparator => 'Dezimaltrennzeichen (. oder ,)';

  @override
  String get descriptionColumns => 'Beschreibungsspalte(n)';

  @override
  String get referenceIdColumn => 'Referenz-ID-Spalte (optional)';

  @override
  String get skippedRows => 'Übersprungene Zeilen';

  @override
  String parsedTransactionCount(String count) {
    return '$count Transaktionen analysiert';
  }

  @override
  String skippedOrExcludedCount(String count) {
    return '$count übersprungen oder ausgeschlossen';
  }

  @override
  String postedFailedCount(String posted, String failed) {
    return '$posted gebucht, $failed fehlgeschlagen';
  }

  @override
  String get categoryForAll => 'Kategorie für alle';

  @override
  String get saveAsRule => 'Als Regel speichern?';

  @override
  String get saveAsRuleBlurb =>
      'Künftige Importe, deren Beschreibung dieses Schlüsselwort enthält, verwenden diese Kategorie.';

  @override
  String get keyword => 'Schlüsselwort';

  @override
  String get noSavedRules =>
      'Noch keine gespeicherten Regeln. Weisen Sie einer Gruppe von Zeilen eine Kategorie zu, um eine Regel zu speichern.';

  @override
  String get deleteRuleTitle => 'Regel löschen?';

  @override
  String get editRule => 'Regel bearbeiten';

  @override
  String rowsGrouped(String count) {
    return '$count Zeilen';
  }

  @override
  String selectStatementFile(String extensions) {
    return 'Wählen Sie eine $extensions-Kontoauszugsdatei zum Importieren aus';
  }

  @override
  String get payeesTitle => 'Zahlungsempfänger';

  @override
  String get addPayee => 'Zahlungsempfänger hinzufügen';

  @override
  String get renamePayee => 'Zahlungsempfänger umbenennen';

  @override
  String get deletePayeeTitle => 'Zahlungsempfänger löschen?';

  @override
  String get noPayeesYet => 'Noch keine Zahlungsempfänger';

  @override
  String get recurringTitle => 'Wiederkehrende Vorlagen';

  @override
  String get noRecurringYet => 'Noch keine wiederkehrenden Vorlagen';

  @override
  String get deleteTemplateTitle => 'Wiederkehrende Vorlage löschen?';

  @override
  String get dayOfMonth => 'Tag des Monats (1–31)';

  @override
  String get dayOfMonthNote =>
      'Ein Monat mit weniger Tagen verwendet seinen eigenen letzten Tag.';

  @override
  String dayOfMonthLine(String day) {
    return 'Tag $day des Monats – ';
  }

  @override
  String get name => 'Name';

  @override
  String get none => 'Keine';

  @override
  String get currency => 'Währung';

  @override
  String get errorGeneric =>
      'Etwas ist schiefgelaufen. Bitte erneut versuchen.';

  @override
  String get errorSigningIdentityMismatch =>
      'Diese Wiederherstellungsphrase oder Keystore-Datei stimmt mit keiner Signieridentität in dieser Datenbank überein.';

  @override
  String get errorInvalidLedgerBackup =>
      'Diese Datei ist keine gültige Smara-Sicherung.';

  @override
  String get errorInvalidLedgerBackupNoIdentity =>
      'Diese Sicherung hat keine Signieridentität – sie ist keine gültige Smara-Sicherung.';

  @override
  String get errorInvalidLedgerBackupUnverified =>
      'Diese Sicherung wurde nicht als intakte Bücher verifiziert, daher wurde sie nicht wiederhergestellt.';

  @override
  String errorInvalidLedgerBackupUnreadable(String detail) {
    return 'Diese Datei konnte nicht als Smara-Sicherung geöffnet werden: $detail';
  }

  @override
  String get errorForeignBackupIdentity =>
      'Diese Sicherung gehört zu einer anderen Signieridentität als der auf diesem Gerät.';

  @override
  String get errorAccountNotFinancial => 'Das ist kein Finanzkonto.';

  @override
  String get errorAccountArchived => 'Dieses Konto ist ausgeblendet.';

  @override
  String get errorAccountNotArchived => 'Dieses Konto ist nicht ausgeblendet.';

  @override
  String get errorAccountNoPositiveBalanceToCloseOut =>
      'Es gibt kein verbleibendes Guthaben zum Umbuchen.';

  @override
  String get errorAccountHasNoGroup =>
      'Diesem Konto ist keine Gruppe zugewiesen.';

  @override
  String get errorGroupHasNoCurrency =>
      'Dieser Gruppe ist noch keine Währung zugewiesen.';

  @override
  String get errorGroupNotFound => 'Diese Kontogruppe wurde nicht gefunden.';

  @override
  String get errorInvestmentAccountsMustBeAssets =>
      'Nur Aktivkonten können als Investmentkonten markiert werden.';

  @override
  String get errorCreditCardsMustBeLiabilities =>
      'Nur Passivkonten können als Kreditkarten markiert werden.';

  @override
  String get errorOpeningBalanceMustBePositive =>
      'Der Anfangssaldo muss positiv sein, sofern angegeben.';

  @override
  String get errorAccountTypeDoesNotMatchGroup =>
      'Dieser Kontotyp stimmt nicht mit der Gruppe überein.';

  @override
  String get errorLastActiveAccount =>
      'Das letzte aktive Finanzkonto kann nicht ausgeblendet werden.';

  @override
  String get errorCurrencyRequiredToCreateGroup =>
      'Zum Anlegen einer Gruppe ist eine Währung erforderlich.';

  @override
  String get errorSystemGroupCannotBeArchived =>
      'Integrierte Kontogruppen können nicht ausgeblendet werden.';

  @override
  String get errorGroupAlreadyArchived =>
      'Diese Gruppe ist bereits ausgeblendet.';

  @override
  String get errorCannotArchiveGroupWithAccounts =>
      'Eine Gruppe mit noch aktiven Konten kann nicht ausgeblendet werden.';

  @override
  String get errorSystemGroupNeverArchived =>
      'Integrierte Kontogruppen werden nie ausgeblendet.';

  @override
  String get errorAccountGroupsCannotBeDeleted =>
      'Kontogruppen können nicht gelöscht werden.';

  @override
  String get errorCannotReassignDifferentCurrency =>
      'Dieses Konto kann nicht in eine Gruppe mit einer anderen Währung verschoben werden.';

  @override
  String get errorCannotChangeGroupCurrencyWithAccounts =>
      'Die Währung kann nicht geändert werden, solange die Gruppe aktive Konten hat.';

  @override
  String get errorAmountMustBePositive => 'Der Betrag muss positiv sein.';

  @override
  String get errorAccountCurrencyAmountMustBePositive =>
      'Der Betrag in Kontowährung muss positiv sein.';

  @override
  String get errorAccountCurrencyAmountNotForSameCurrency =>
      'Der Betrag in Kontowährung gilt nur für einen Fremdwährungseintrag.';

  @override
  String get errorSplitNeedsTwoLines =>
      'Eine Aufteilung benötigt mindestens zwei Kategoriezeilen.';

  @override
  String get errorSplitLineMustBePositive =>
      'Jede Aufteilungszeile muss ein positiver Betrag sein.';

  @override
  String get errorSplitLinesMustSumToTotal =>
      'Die Aufteilungszeilen müssen sich zum Transaktionsgesamtbetrag summieren.';

  @override
  String get errorTransferAmountMustBePositive =>
      'Der Umbuchungsbetrag muss positiv sein.';

  @override
  String get errorTransferAccountsMustDiffer =>
      'Quell- und Zielkonto müssen unterschiedlich sein.';

  @override
  String get errorCloseoutRequiresDestinationAmount =>
      'Ein grenzüberschreitender Abschluss benötigt einen bekannten Zielbetrag.';

  @override
  String get errorDestinationAmountNotForSameCurrency =>
      'Der Zielbetrag gilt nur für eine Fremdwährungsüberweisung.';

  @override
  String get errorDestinationAmountMustBePositive =>
      'Der Zielbetrag muss positiv sein.';

  @override
  String get errorInvestmentCashExceeded =>
      'Es kann nicht mehr überwiesen werden, als dieses Investmentkonto an Bargeld hat.';

  @override
  String get errorCannotReverseUnsettledProvisional =>
      'Schließen Sie diese schwebende Überweisung ab, statt sie umzukehren.';

  @override
  String get errorAlreadyReversed =>
      'Dieser Eintrag wurde bereits korrigiert. Die ursprüngliche Zeile bleibt unverändert.';

  @override
  String get errorNotActiveExpenseCategory =>
      'Wählen Sie eine aktive Ausgabenkategorie.';

  @override
  String get errorNotActiveIncomeCategory =>
      'Wählen Sie eine aktive Einnahmenkategorie.';

  @override
  String get errorSettledAmountMustNotBeNegative =>
      'Der angekommene Betrag darf nicht negativ sein.';

  @override
  String get errorPendingTransferNotFound =>
      'Diese schwebende Überweisung wurde nicht gefunden.';

  @override
  String get errorPendingTransferAlreadySettled =>
      'Diese schwebende Überweisung wurde bereits abgeschlossen.';

  @override
  String get errorSettledToMustBeSourceOrDestination =>
      'Wählen Sie das ursprüngliche Quell- oder Zielkonto.';

  @override
  String get errorFeeCategoryOnlyWhenReturningToSource =>
      'Eine Gebührenkategorie wird nur verwendet, wenn Geld an das Quellkonto zurückgegeben wird.';

  @override
  String get errorSettledAmountMustBePositiveForDelivery =>
      'Geben Sie für das Angekommene einen positiven Betrag ein.';

  @override
  String get errorSettledAmountExceedsProvisional =>
      'Dieser Betrag ist höher als der gesendete.';

  @override
  String get errorInstrumentNotFound =>
      'Dieses Instrument wurde nicht gefunden.';

  @override
  String get errorIncomeRequiredForNonCash =>
      'Für einen unbaren Erwerb ist eine aktive Einnahmenkategorie erforderlich.';

  @override
  String get errorInsufficientCash =>
      'In diesem Investmentkonto ist nicht genug Bargeld für diesen Kauf vorhanden.';

  @override
  String get errorSellQuantityAndPriceMustBePositive =>
      'Verkaufsmenge und Stückpreis müssen positiv sein.';

  @override
  String errorLockedUntil(String date) {
    return 'Verkauf nicht möglich: Einige Einheiten sind bis $date gesperrt.';
  }

  @override
  String get errorInsufficientQuantity =>
      'Es kann nicht mehr verkauft werden, als Sie derzeit unverschlossen halten.';

  @override
  String get errorIncomeRequiredForGain =>
      'Für einen realisierten Gewinn ist eine aktive Einnahmenkategorie erforderlich.';

  @override
  String get errorExpenseRequiredForLoss =>
      'Für einen realisierten Verlust ist eine aktive Ausgabenkategorie erforderlich.';

  @override
  String errorBrokerageFailedAfterBuy(String detail) {
    return 'Kauf gebucht, aber Courtage fehlgeschlagen: $detail';
  }

  @override
  String errorBrokerageFailedAfterSell(String detail) {
    return 'Verkauf gebucht, aber Courtage fehlgeschlagen: $detail';
  }

  @override
  String get errorDividendMustBePositive =>
      'Der Dividendenbetrag muss positiv sein.';

  @override
  String get errorNotInvestmentAccount => 'Das ist kein Investmentkonto.';

  @override
  String get errorNoInventoryCompanion =>
      'Diesem Investmentkonto fehlt sein zugehöriges Bestandskonto.';

  @override
  String errorInvestmentReversalBlocked(String sells) {
    return 'Dieser Kauf kann nicht rückgängig gemacht werden: spätere Verkäufe hängen von seinen Einheiten ab. Machen Sie zuerst die abhängigen Verkäufe rückgängig: $sells.';
  }

  @override
  String get errorMonthlyLimitMustBePositive =>
      'Das Monatslimit muss positiv sein.';

  @override
  String get errorTemplateAmountMustBePositive =>
      'Der Vorlagenbetrag muss positiv sein.';

  @override
  String get errorOfxUnrecognized =>
      'Diese Datei konnte nicht als OFX erkannt werden.';

  @override
  String get errorCsvEmpty => 'Die ausgewählte Datei ist leer.';

  @override
  String get errorCsvUnreadable =>
      'Diese Datei konnte nicht als CSV gelesen werden.';

  @override
  String get errorCsvNoRows => 'Die ausgewählte Datei hat keine Zeilen.';

  @override
  String errorBackupCreateFailed(String detail) {
    return 'Die Sicherung konnte nicht erstellt werden: $detail';
  }

  @override
  String get errorBackupRestoreFailed =>
      'Diese Sicherung konnte nicht wiederhergestellt werden – falsche Passphrase oder keine Smara-Sicherungsdatei.';

  @override
  String get validationAmountAccountCategoryRequired =>
      'Betrag, Konto und Kategorie sind erforderlich.';

  @override
  String get validationAmountAccountRequired =>
      'Betrag und Konto sind erforderlich.';

  @override
  String get validationSplitLineIncomplete =>
      'Jede Aufteilungszeile benötigt eine Kategorie und einen Betrag.';

  @override
  String get validationSplitSumMismatch =>
      'Die Aufteilungszeilen müssen sich zum Transaktionsgesamtbetrag summieren.';

  @override
  String get validationFromToAmountRequired =>
      'Von-Konto, An-Konto und Betrag sind erforderlich.';

  @override
  String get validationAmountArrivedRequired =>
      'Der angekommene Betrag ist erforderlich.';

  @override
  String get validationChooseReceivingAccount =>
      'Wählen Sie, welches Konto die Gelder erhalten hat.';

  @override
  String get validationAccountCategoryRequired =>
      'Konto und Kategorie sind erforderlich.';

  @override
  String get validationFixFailed =>
      'Diese Korrektur konnte nicht gespeichert werden.';

  @override
  String get validationNameRequired => 'Benennen Sie Ihr Hauptkonto.';

  @override
  String get validationStillLoading =>
      'Wird noch geladen – versuchen Sie es gleich noch einmal.';

  @override
  String get validationSaveAccountNameFailed =>
      'Der Kontoname konnte nicht gespeichert werden.';

  @override
  String get validationWrongPin => 'Falsche PIN. Erneut versuchen.';

  @override
  String get validationCategoryMustBeIncomeOrExpense =>
      'Die Kategorie muss Einnahmen oder Ausgaben sein.';

  @override
  String get validationOnlyExpenseHasMonthlyLimit =>
      'Nur eine Ausgabenkategorie kann ein Monatslimit haben.';

  @override
  String get validationInvalidTemplate => 'Ungültige Vorlage.';

  @override
  String get validationWrongKeystorePassphrase =>
      'Falsche Passphrase für diese Keystore-Datei.';

  @override
  String get validationInvalidKeystoreFile =>
      'Das sieht nicht wie eine gültige Keystore-Datei aus.';

  @override
  String get validationRestorePhraseFailed =>
      'Von dieser Wiederherstellungsphrase konnte nicht wiederhergestellt werden.';

  @override
  String validationGenerateKeyFailed(String detail) {
    return 'Auf diesem Gerät konnte kein Signierschlüssel erzeugt werden: $detail';
  }

  @override
  String validationSaveCurrencyFailed(String detail) {
    return 'Diese Währung konnte nicht gespeichert werden: $detail';
  }

  @override
  String get validationMigrationFailed =>
      'Migration fehlgeschlagen. Bitte erneut versuchen.';

  @override
  String get validationChooseBackupFile =>
      'Wählen Sie zuerst eine Sicherungsdatei aus.';

  @override
  String get validationPassphraseRequired => 'Geben Sie eine Passphrase ein.';

  @override
  String get validationPinsDoNotMatch =>
      'Die beiden PINs stimmen nicht überein.';

  @override
  String get validationFeePositiveWithCategory =>
      'Eine Überweisungsgebühr muss ein positiver Betrag mit ausgewählter Ausgabenkategorie sein.';

  @override
  String get validationFeeMustBeLessThanAmount =>
      'Die Gebühr muss bei einer Überweisung mit abgezogener Gebühr geringer als der Betrag sein.';

  @override
  String validationTransferSavedFeeFailed(String detail) {
    return 'Überweisung gespeichert, aber die Gebühr konnte nicht erfasst werden: $detail';
  }

  @override
  String get validationEnterValidAmount =>
      'Geben Sie einen gültigen Betrag ein.';

  @override
  String validationConfirmWordMismatch(String n) {
    return 'Wort $n stimmt nicht mit Ihrer gespeicherten Phrase überein. Überprüfen Sie es und versuchen Sie es erneut.';
  }

  @override
  String get errorBuyQuantityAndPriceMustBePositive =>
      'Kaufmenge und Stückpreis müssen positiv sein.';

  @override
  String get errorInstrumentArchived =>
      'Ein ausgeblendetes Instrument kann nicht gekauft werden.';

  @override
  String get errorNonCashCannotIncludeBrokerage =>
      'Unbare Erwerbe können keine Courtage enthalten.';

  @override
  String get errorBrokerageRequiresExpenseCategory =>
      'Bei positiver Courtage ist eine aktive Ausgabenkategorie erforderlich.';

  @override
  String get errorSellProceedsMustCoverBrokerage =>
      'Der Verkaufserlös muss mindestens die Courtage decken.';

  @override
  String homeSpentOfLimitThisMonth(String spent, String limit) {
    return '$spent von $limit in diesem Monat';
  }

  @override
  String get unlockBiometricReason => 'Smara Buchhaltung entsperren';

  @override
  String get searchLabel => 'Suchen';

  @override
  String get openingBalance => 'Anfangssaldo';

  @override
  String transferToName(String name) {
    return 'Umbuchung: $name';
  }

  @override
  String get feeForTransfer => 'Gebühr für Umbuchung';

  @override
  String feeForTransferTo(String name) {
    return 'Gebühr für Umbuchung an $name';
  }

  @override
  String couldNotOpenFilePicker(String detail) {
    return 'Der Dateiauswähler konnte nicht geöffnet werden: $detail';
  }

  @override
  String pleaseSelectFile(String extensions) {
    return 'Bitte wählen Sie eine .$extensions-Datei';
  }

  @override
  String get currencyCodeIso => 'Währungscode (ISO 4217, z. B. USD)';

  @override
  String splitCounterpartMore(String name, String count) {
    return '$name +$count weitere';
  }

  @override
  String get dateLabel => 'Datum';

  @override
  String get noneSelected => 'Keine';

  @override
  String reviewEntriesBeforeContinuing(String count) {
    return 'Überprüfen Sie die untenstehenden Einträge ($count insgesamt), bevor Sie fortfahren.';
  }

  @override
  String youReceived(String amount) {
    return 'Sie haben $amount erhalten';
  }

  @override
  String get leaveBlankIfRateUnknown =>
      'Leer lassen, wenn der Wechselkurs noch nicht bekannt ist.';

  @override
  String get recordTradeBlurb =>
      'Erfassen Sie einen bereits erfolgten Trade. Diese App platziert keine Orders.';

  @override
  String get feeOnTopBlurb =>
      'An: Der obige Betrag ist der Gesamtbetrag, der diesem Konto entnommen wird; die Gebühr wird davon abgezogen.';

  @override
  String get feeBankBlurb =>
      'Eine im Voraus erhobene Provision Ihrer Bank oder eines Vermittlers.';

  @override
  String get validationPinMinLength =>
      'Die PIN muss mindestens 4 Stellen haben.';

  @override
  String get restoreBackupBlurb =>
      'Dies ersetzt alles, was sich derzeit in dieser App befindet, durch die Sicherung — es wird nicht zusammengeführt. Wählen Sie eine Sicherungsdatei und geben Sie die Passphrase ein, mit der Sie sie geschützt haben.';

  @override
  String get actionReplace => 'Ersetzen';

  @override
  String hideAccountBody(String name) {
    return '$name steht für neue Transaktionen nicht mehr zur Verfügung.';
  }

  @override
  String hideGroupBody(String name) {
    return '$name wird beim Erstellen oder Neuzuweisen von Konten nicht mehr angeboten.';
  }

  @override
  String hideCategoryBody(String name) {
    return '$name wird beim Erfassen neuer Transaktionen nicht mehr angeboten.';
  }

  @override
  String get hideInstrumentBody =>
      'Ausgeblendete Instrumente bleiben bei vergangenen Käufen und Verkäufen erhalten. Sie können weiterhin eine Dividende dafür erfassen.';

  @override
  String nameHidden(String name) {
    return '$name (ausgeblendet)';
  }

  @override
  String get noCurrencySet => 'Keine Währung festgelegt';

  @override
  String deletePayeeBody(String name) {
    return '$name und die zugehörigen gemerkten Standardwerte werden entfernt. Vergangene Transaktionen bleiben unberührt.';
  }

  @override
  String deleteTemplateBody(String name) {
    return '$name wird nicht mehr als fällig angeboten. Bereits erfasste vergangene Transaktionen bleiben unberührt.';
  }

  @override
  String deleteProfileBody(String name) {
    return 'Die gespeicherte Spaltenzuordnung \"$name\" wird gelöscht. Bereits damit importierte Kontoauszüge bleiben unberührt.';
  }

  @override
  String deleteRuleBody(String keyword) {
    return 'Importe werden nicht mehr automatisch anhand von \"$keyword\" kategorisiert. Transaktionen, die bereits mit dieser Regel kategorisiert wurden, bleiben unberührt.';
  }

  @override
  String get firstWeekBlurb =>
      'Fügen Sie optional jetzt eine Kreditkarte oder ein Bargeldkonto hinzu – Sie können später jederzeit weitere Konten über die Einstellungen hinzufügen.';

  @override
  String get deliveredToDestination => 'An Ziel geliefert';

  @override
  String deliveredToName(String name) {
    return 'An $name geliefert';
  }

  @override
  String youReceivedLessThanExpected(String amount, String currency) {
    return 'Sie haben $amount $currency weniger als erwartet erhalten - wählen Sie eine Kategorie, um die Differenz zu decken.';
  }

  @override
  String get dateRangeLabel => 'Zeitraum';

  @override
  String get addTemplate => 'Vorlage hinzufügen';

  @override
  String get editTemplate => 'Vorlage bearbeiten';

  @override
  String get validationFillTemplateFields =>
      'Füllen Sie jedes Feld mit einem gültigen Betrag und Tag aus.';

  @override
  String get saveCsvExport => 'CSV-Export speichern';

  @override
  String get referenceRate => 'Referenzkurs';

  @override
  String get yourRate => 'Ihr Kurs';

  @override
  String leaveBlankIfThisWasAccountCurrency(String currency) {
    return 'Leer lassen, wenn dies in $currency, der eigenen Kontowährung, erfolgte.';
  }

  @override
  String get lockUntilOptional => 'Sperren bis (optional)';

  @override
  String lockedUntilDate(String date) {
    return 'Gesperrt bis $date';
  }

  @override
  String get copiedResearchPrompt =>
      'Ein Recherche-Prompt wurde kopiert — keine Browser-URL verfügbar, oder Sie sind offline.';

  @override
  String get openedFavouriteResearchTool =>
      'Ihr bevorzugtes Recherchetool wurde geöffnet.';

  @override
  String get looksLikeGain => 'Das sieht nach einem Gewinn aus';

  @override
  String get looksLikeLoss => 'Das sieht nach einem Verlust aus';

  @override
  String get looksLikeBreakEven => 'Das sieht nach einem Ausgleich aus';

  @override
  String sellableQuantity(String name, String qty) {
    return '$name ($qty verkaufbar)';
  }

  @override
  String columnN(String index) {
    return 'Spalte $index';
  }

  @override
  String get importingLabel => 'Wird importiert …';

  @override
  String get confirmImport => 'Import bestätigen';

  @override
  String get manageSavedCategoryRules =>
      'Gespeicherte Kategorieregeln verwalten';

  @override
  String statementCurrencyMismatch(String currency) {
    return 'Die Währung dieser Datei ($currency) stimmt nicht mit der Währung des ausgewählten Kontos überein.';
  }

  @override
  String get categoryRulesTitle => 'Kategorieregeln';

  @override
  String get possibleDuplicate => 'mögliches Duplikat';

  @override
  String get unknownCategory => 'Unbekannte Kategorie';
}
