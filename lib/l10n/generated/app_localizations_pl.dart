// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'Smara Księgowość';

  @override
  String get navHome => 'Start';

  @override
  String get navRegister => 'Rejestr';

  @override
  String get navSummary => 'Podsumowanie';

  @override
  String get navAccounts => 'Konta';

  @override
  String get navCategories => 'Kategorie';

  @override
  String get actionCancel => 'Anuluj';

  @override
  String get actionSave => 'Zapisz';

  @override
  String get actionDelete => 'Usuń';

  @override
  String get actionDone => 'Gotowe';

  @override
  String get actionContinue => 'Kontynuuj';

  @override
  String get actionDismiss => 'Zamknij';

  @override
  String get actionRetry => 'Ponów';

  @override
  String get actionSkip => 'Pomiń';

  @override
  String get actionConfirm => 'Potwierdź';

  @override
  String get actionAdd => 'Dodaj';

  @override
  String get actionEdit => 'Edytuj';

  @override
  String get actionRename => 'Zmień nazwę';

  @override
  String get actionHide => 'Ukryj';

  @override
  String get actionCreate => 'Utwórz';

  @override
  String get actionCloseApp => 'Zamknij aplikację';

  @override
  String get actionUnlock => 'Odblokuj';

  @override
  String get actionSettle => 'Rozlicz';

  @override
  String get actionFinish => 'Zakończ';

  @override
  String get actionPreview => 'Podgląd';

  @override
  String get actionImport => 'Importuj';

  @override
  String get actionExportCsv => 'Eksportuj CSV';

  @override
  String get actionChooseFile => 'Wybierz plik';

  @override
  String get actionRestore => 'Przywróć';

  @override
  String get actionFix => 'Napraw';

  @override
  String get actionBuy => 'Kup';

  @override
  String get actionSell => 'Sprzedaj';

  @override
  String get actionDividend => 'Dywidenda';

  @override
  String get actionRecordBuy => 'Zapisz kupno';

  @override
  String get actionRecordSell => 'Zapisz sprzedaż';

  @override
  String get actionRecordDividend => 'Zapisz dywidendę';

  @override
  String get actionPayCard => 'Spłać kartę';

  @override
  String get actionTransfer => 'Przelew';

  @override
  String get actionRecordTransaction => 'Zapisz transakcję';

  @override
  String get actionImportStatement => 'Importuj wyciąg';

  @override
  String get actionClearDates => 'Wyczyść daty';

  @override
  String get actionClearSearch => 'Wyczyść wyszukiwanie i filtry';

  @override
  String get actionUseBiometrics => 'Użyj biometrii';

  @override
  String get actionSetPin => 'Ustaw PIN';

  @override
  String get actionChangePin => 'Zmień PIN';

  @override
  String get actionSaveBackup => 'Zapisz kopię zapasową';

  @override
  String get actionRestoreBackup => 'Przywróć kopię zapasową';

  @override
  String get actionSaveRule => 'Zapisz regułę';

  @override
  String get actionConfirmFix => 'Potwierdź poprawkę';

  @override
  String get captureSpent => 'Wydano';

  @override
  String get captureReceived => 'Otrzymano';

  @override
  String get captureMovedMoney => 'Przeniesiono środki';

  @override
  String get captureImportStatement => 'Importuj wyciąg';

  @override
  String get settingsTitle => 'Ustawienia';

  @override
  String get settingsLanguage => 'Język';

  @override
  String get settingsLanguageSystem => 'Język urządzenia';

  @override
  String get settingsFetchFxRates => 'Pobieraj referencyjne kursy wymiany';

  @override
  String get settingsFetchFxRatesSubtitle =>
      'Pokazuje orientacyjny kurs rynkowy obok kwoty docelowej w przelewach walutowych, wyłącznie do porównania - nigdy nie jest używany do wypełnienia kwoty.';

  @override
  String get settingsRateProvider => 'Dostawca kursów';

  @override
  String get settingsFetchMarketPrices => 'Pobieraj ceny rynkowe inwestycji';

  @override
  String get settingsFetchMarketPricesSubtitle =>
      'Wyszukuje ostatnie ceny instrumentów posiadających ticker lub ISIN, aby oszacować wartość portfela. Nigdy nie służy do zapisania transakcji i nigdy nie wysyła informacji o liczbie posiadanych jednostek.';

  @override
  String get settingsMarketPriceProvider => 'Dostawca cen rynkowych';

  @override
  String get settingsFavouriteResearchTool => 'Ulubione narzędzie do analiz';

  @override
  String get settingsFavouriteResearchToolSubtitle =>
      'Dotknięcie nazwy instrumentu na liście udziałów otworzy to narzędzie w przeglądarce z gotowym zapytaniem — to nie jest integracja ani porada inwestycyjna.';

  @override
  String get settingsBackup => 'Kopia zapasowa';

  @override
  String get settingsBackupBlurb =>
      'Zapisz zaszyfrowaną kopię swoich ksiąg w wybranym miejscu lub przywróć ją stamtąd. To coś innego niż fraza odzyskiwania lub plik magazynu kluczy, które zabezpieczają Twój klucz podpisujący, a nie księgi.';

  @override
  String get settingsLock => 'Blokada';

  @override
  String get settingsLockBlurb =>
      'Wymagaj PIN-u lub, jeśli dostępne, biometrii, aby otworzyć aplikację.';

  @override
  String get settingsRequireUnlock =>
      'Wymagaj odblokowania, aby otworzyć aplikację';

  @override
  String get settingsLockAfter => 'Blokuj po';

  @override
  String get settingsLockImmediately => 'Natychmiast';

  @override
  String get settingsLock1Minute => '1 minuta';

  @override
  String get settingsLock5Minutes => '5 minut';

  @override
  String get settingsLock15Minutes => '15 minut';

  @override
  String get settingsAllowBiometrics => 'Zezwól także na biometrię';

  @override
  String get settingsHideSnapshot => 'Ukryj salda w przełączniku aplikacji';

  @override
  String get settingsHideSnapshotSubtitle =>
      'Ukrywa ten ekran po przełączeniu na inną aplikację, aby nie był widoczny na pierwszy rzut oka w przełączniku aplikacji.';

  @override
  String get settingsHideSnapshotUnavailable =>
      'Ukrywanie sald w przełączniku aplikacji nie jest dostępne na tej platformie.';

  @override
  String get settingsPayees => 'Odbiorcy';

  @override
  String get settingsManagePayees => 'Zarządzaj odbiorcami';

  @override
  String get settingsPayeesBlurb =>
      'Zapamiętane nazwy odbiorców wraz z domyślną kategorią i kontem, podpowiadane przez autouzupełnianie podczas zapisywania transakcji.';

  @override
  String get settingsRecurring => 'Szablony cykliczne';

  @override
  String get settingsManageRecurring => 'Zarządzaj szablonami cyklicznymi';

  @override
  String get settingsRecurringBlurb =>
      'Rachunki lub wpływy, które powtarzają się co miesiąc, jak czynsz czy wypłata. Szablon z terminem pojawia się na ekranie głównym, abyś mógł zapisać go jednym dotknięciem - nigdy nie jest księgowany automatycznie.';

  @override
  String get settingsAbout => 'O aplikacji';

  @override
  String get settingsPrivacyPolicy => 'Polityka prywatności';

  @override
  String get settingsPrivacyPolicyOpenFailed =>
      'Nie udało się otworzyć polityki prywatności w przeglądarce.';

  @override
  String get providerFrankfurter => 'Frankfurter (kursy EBC)';

  @override
  String get providerOpenErApi => 'ExchangeRate-API (open.er-api.com)';

  @override
  String get providerStooq => 'Stooq (notowania dzienne)';

  @override
  String get providerYahooFinance => 'Yahoo Finance (API wykresów)';

  @override
  String get researchChatGpt => 'ChatGPT';

  @override
  String get researchClaude => 'Claude';

  @override
  String get researchGemini => 'Gemini';

  @override
  String get researchMetaAi => 'Meta AI';

  @override
  String get systemGroupCashEquivalents => 'Środki pieniężne i ich ekwiwalenty';

  @override
  String get systemGroupPensionRetirement => 'Emerytura i renta';

  @override
  String get systemGroupCreditShortTerm =>
      'Kredyty i zadłużenie krótkoterminowe';

  @override
  String get systemGroupLoansMortgages => 'Pożyczki i kredyty hipoteczne';

  @override
  String get systemGroupInvestments => 'Inwestycje';

  @override
  String get systemAccountCashBank => 'Gotówka i bank';

  @override
  String get systemCategorySalary => 'Wynagrodzenie';

  @override
  String get systemCategoryOtherIncome => 'Inne przychody';

  @override
  String get systemCategoryGroceries => 'Zakupy spożywcze';

  @override
  String get systemCategoryRentMortgage => 'Czynsz/kredyt hipoteczny';

  @override
  String get systemCategoryUtilities => 'Media';

  @override
  String get systemCategoryTransport => 'Transport';

  @override
  String get systemCategoryFoodOut => 'Jedzenie na mieście';

  @override
  String get systemCategoryPhone => 'Telefon';

  @override
  String get systemCategoryHealth => 'Zdrowie';

  @override
  String get systemCategoryOtherExpense => 'Inne wydatki';

  @override
  String get systemDescriptionCsvImport => 'Import CSV';

  @override
  String get systemDescriptionOfxImport => 'Import OFX';

  @override
  String get homeThisMonth => 'TEN MIESIĄC';

  @override
  String get homeMoneyInTransit => 'ŚRODKI W DRODZE';

  @override
  String get homeWhatYouHaveMinusWhatYouOwe =>
      'TO, CO MASZ MINUS TO, CO JESTEŚ WINIEN';

  @override
  String homeWhatYouHave(String amount, String currency) {
    return 'Masz $amount $currency';
  }

  @override
  String homeNetPosition(String amount, String currency) {
    return '$amount $currency';
  }

  @override
  String homeHaveAndOwe(String haveAmount, String currency, String oweAmount) {
    return 'Masz $haveAmount $currency  •  Jesteś winien $oweAmount $currency';
  }

  @override
  String youSentFrom(String amount, String currency, String name) {
    return 'Wysłano $amount $currency z $name';
  }

  @override
  String youSentTo(String amount, String currency, String name) {
    return 'Wysłano $amount $currency do $name';
  }

  @override
  String get hiddenLabel => 'Ukryte';

  @override
  String get allAccounts => 'Wszystkie konta';

  @override
  String savedToPath(String path) {
    return 'Zapisano w $path';
  }

  @override
  String get homeTapWhenArrived => 'Dotknij, gdy będziesz wiedzieć, co dotarło';

  @override
  String homeReturnedTo(String name) {
    return 'Zwrócono do $name';
  }

  @override
  String get homeDueToday => 'TERMIN DZISIAJ';

  @override
  String homeDueLine(String category, String account) {
    return '$category · $account · dotknij, aby zapisać';
  }

  @override
  String get homeOverLimit => 'Przekroczono limit';

  @override
  String homeSpentOfLimit(String spent, String limit) {
    return '$spent z $limit';
  }

  @override
  String homeRemaining(String amount) {
    return 'Pozostało: $amount';
  }

  @override
  String get homeNoAccounts => 'Brak kont';

  @override
  String get homeCashRegister => 'Kasa gotówkowa';

  @override
  String get homeMarketEstimate => 'Szacunek rynkowy';

  @override
  String get registerTitle => 'Rejestr';

  @override
  String get registerSearchHint => 'Opis, kategoria lub kwota';

  @override
  String get registerNoTransactions => 'Brak transakcji';

  @override
  String get registerNoEntries => 'Brak zapisanych wpisów.';

  @override
  String get registerSpentOnly => 'Tylko wydatki';

  @override
  String get registerReceivedOnly => 'Tylko wpływy';

  @override
  String get registerAll => 'Wszystkie';

  @override
  String get registerUnverified => 'Niezweryfikowane - wykluczone z sum';

  @override
  String get registerSuperseded => 'Zastąpione migracją - wykluczone z sum';

  @override
  String get summaryTitle => 'Podsumowanie';

  @override
  String get summaryTotalIncome => 'Suma przychodów';

  @override
  String get summaryTotalExpense => 'Suma wydatków';

  @override
  String summaryDateRange(String start, String end) {
    return '$start do $end';
  }

  @override
  String get accountsTitle => 'Konta';

  @override
  String get categoriesTitle => 'Kategorie';

  @override
  String get accountName => 'Nazwa konta';

  @override
  String get createAccount => 'Utwórz konto';

  @override
  String get createGroup => 'Utwórz grupę';

  @override
  String get editGroup => 'Edytuj grupę';

  @override
  String get renameAccount => 'Zmień nazwę konta';

  @override
  String get renameCategory => 'Zmień nazwę kategorii';

  @override
  String get addCategory => 'Dodaj kategorię';

  @override
  String get groupLabel => 'Grupa';

  @override
  String get kindLabel => 'Rodzaj';

  @override
  String get asset => 'Aktywa';

  @override
  String get liability => 'Pasywa';

  @override
  String get income => 'Przychód';

  @override
  String get expense => 'Wydatek';

  @override
  String get thisAccountHoldsInvestments => 'To konto zawiera inwestycje';

  @override
  String get thisAccountHoldsInvestmentsSubtitle =>
      'Gotówka wraz z inwentarzem zapisywanym poleceniami Kup, Sprzedaj i Dywidenda.';

  @override
  String get thisIsACreditCard => 'To jest karta kredytowa';

  @override
  String get openingBalanceOptional => 'Saldo początkowe (opcjonalnie)';

  @override
  String get currencyIso => 'Waluta (ISO 4217)';

  @override
  String get currencyIsoExample => 'Waluta (ISO 4217, np. USD)';

  @override
  String get hideAccountTitle => 'Ukryć konto przed nowymi wpisami?';

  @override
  String get hideCategoryTitle => 'Ukryć kategorię przed nowymi wpisami?';

  @override
  String get hideGroupTitle => 'Ukryć grupę przed nowymi wpisami?';

  @override
  String get reassignGroup => 'Przypisz do innej grupy';

  @override
  String get transferRemainingBalance => 'Przenieś pozostałe saldo';

  @override
  String get monthlyLimit => 'Limit miesięczny';

  @override
  String get monthlyLimitHint => 'Limit (pozostaw puste, aby wyczyścić)';

  @override
  String get monthlyLimitBlurb =>
      'Opcjonalny wskaźnik wydatków od początku miesiąca dla tej kategorii wydatków.';

  @override
  String get translateCategoryWithAi => 'Przetłumacz z AI';

  @override
  String get addCategoryTranslation => 'Dodaj tłumaczenie';

  @override
  String get categoryTranslationLocale => 'Język';

  @override
  String get categoryTranslationName => 'Przetłumaczona nazwa';

  @override
  String get mergeCategories => 'Scal kategorie';

  @override
  String get mergeCategoriesSuggested =>
      'Te kategorie wyglądają tak samo. Scalić je?';

  @override
  String get categoryDefaultLanguage => 'Domyślny język nazw kategorii';

  @override
  String get categoryDefaultLanguageSubtitle =>
      'Wspólny dla połączonych urządzeń. Każde urządzenie nadal pokazuje swój język, gdy istnieje tłumaczenie.';

  @override
  String get manageCategoryRules => 'Zarządzaj regułami kategorii';

  @override
  String get amount => 'Kwota';

  @override
  String get category => 'Kategoria';

  @override
  String get account => 'Konto';

  @override
  String get fromAccount => 'Z konta';

  @override
  String get toAccount => 'Na konto';

  @override
  String get descriptionOptional => 'Opis (opcjonalnie)';

  @override
  String get alsoRememberPayee => 'Zapamiętaj też jako odbiorcę';

  @override
  String get splitIntoCategories => 'Podziel na kilka kategorii';

  @override
  String categoryN(String n) {
    return 'Kategoria $n';
  }

  @override
  String get destinationAmount => 'Kwota docelowa';

  @override
  String get destinationAmountOptional => 'Kwota docelowa (opcjonalnie)';

  @override
  String get accountCurrencyAmountOptional =>
      'Kwota w walucie konta (opcjonalnie)';

  @override
  String get transactionCurrencyOptional => 'Waluta transakcji (opcjonalnie)';

  @override
  String get feeOptional => 'Opłata (opcjonalnie)';

  @override
  String get feeAmount => 'Kwota opłaty';

  @override
  String get feeCategory => 'Kategoria opłaty';

  @override
  String get feeDescriptionOptional => 'Opis opłaty (opcjonalnie)';

  @override
  String get feeDeducted => 'Opłata jest potrącana z kwoty powyżej';

  @override
  String get needTwoAccountsToTransfer =>
      'Utwórz co najmniej dwa aktywne konta, aby wykonać przelew.';

  @override
  String get whatArrivedTitle => 'Co dotarło?';

  @override
  String get whatArrivedBlurb => 'Podaj, co faktycznie dotarło.';

  @override
  String get amountThatArrived => 'Kwota, która dotarła';

  @override
  String get feeLossCategory => 'Kategoria opłaty / straty';

  @override
  String get alreadySettled => 'Już rozliczone.';

  @override
  String get holdingsTitle => 'Portfel';

  @override
  String get holdingsCash => 'Gotówka';

  @override
  String get holdingsInventory => 'STAN POSIADANIA';

  @override
  String holdingsBook(String amount, String currency) {
    return 'Wartość księgowa (gotówka + koszt) $amount $currency';
  }

  @override
  String holdingsMarketEstimate(String amount, String currency) {
    return 'Szacunek rynkowy $amount $currency';
  }

  @override
  String get holdingsNoHoldings =>
      'Brak jeszcze żadnych pozycji. Zapisz kupno, aby dodać instrument.';

  @override
  String get holdingsQuotesBlurb =>
      'Notowania są szacunkowe, a nie ceną brokera. Ta aplikacja nie składa zleceń.';

  @override
  String get holdingsTapNameToResearch =>
      'Dotknij nazwy, aby zbadać. Notowania są szacunkowe, a nie poradą.';

  @override
  String get instrument => 'Instrument';

  @override
  String get newInstrument => 'Nowy instrument';

  @override
  String get renameInstrument => 'Zmień nazwę instrumentu';

  @override
  String get instrumentActions => 'Działania na instrumencie';

  @override
  String hideInstrumentTitle(String name) {
    return 'Ukryć $name?';
  }

  @override
  String get tickerOptional => 'Ticker (opcjonalnie)';

  @override
  String get isinOptional => 'ISIN (opcjonalnie)';

  @override
  String get quantity => 'Ilość';

  @override
  String get unitPrice => 'Cena jednostkowa';

  @override
  String get brokerageOptional => 'Prowizja maklerska (opcjonalnie)';

  @override
  String get brokerageExpenseCategory => 'Kategoria wydatku na prowizję';

  @override
  String get incomeCategory => 'Kategoria przychodu';

  @override
  String get gainIncomeCategory => 'Kategoria przychodu z zysku';

  @override
  String get lossExpenseCategory => 'Kategoria wydatku ze straty';

  @override
  String get nonCash => 'Niepieniężne';

  @override
  String get cash => 'Gotówka';

  @override
  String get locked => 'Zablokowane';

  @override
  String get lockUntilHint =>
      'Twoja własna notatka o ograniczeniu, a nie zasada brokera.';

  @override
  String get instrumentKindStock => 'Akcja';

  @override
  String get instrumentKindEtf => 'ETF';

  @override
  String get instrumentKindMutualFund => 'Fundusz inwestycyjny';

  @override
  String get instrumentKindBond => 'Obligacja';

  @override
  String get instrumentKindOther => 'Inne';

  @override
  String get quoteUseLive => 'Cena na żywo';

  @override
  String get quoteUseCached => 'Cena z pamięci podręcznej';

  @override
  String get quoteUseStale => 'Nieaktualna cena';

  @override
  String get quoteUseMissing => 'Używanie kosztu (brak ceny)';

  @override
  String get quoteUseDisabled =>
      'Notowania wyłączone — używany koszt/pamięć podręczna';

  @override
  String get quoteUseCurrencyMismatch => 'Używanie kosztu (inna waluta ceny)';

  @override
  String unrealizedLabel(String amount, String currency) {
    return 'Niezrealizowane $amount $currency';
  }

  @override
  String holdingsUnitsCost(String qty) {
    return '$qty jednostek · ';
  }

  @override
  String get chooseLanguageTitle => 'Wybierz swój język';

  @override
  String get chooseLanguageBlurb =>
      'Wszystko w aplikacji będzie wyświetlane w tym języku. Możesz to zmienić później w Ustawieniach.';

  @override
  String get chooseCurrencyTitle => 'Wybierz swoją walutę';

  @override
  String get chooseCurrencyBlurb =>
      'Każda grupa kont (Środki pieniężne i ich ekwiwalenty, Emerytura i renta itd.) korzysta na razie z jednej wybranej waluty. Konto w innej walucie możesz dodać później, tworząc dla niego nową grupę.';

  @override
  String get currencyBackfillTitle => 'Wybierz walutę dla istniejących grup';

  @override
  String get currencyBackfillBlurb =>
      'Ta aplikacja obsługuje teraz wiele walut. Twoje istniejące konta i grupy kont potrzebują waluty - ponieważ zostały utworzone przed wprowadzeniem tej funkcji, jeden wybór dotyczy ich wszystkich.';

  @override
  String get firstAccountTitle => 'Nazwij swoje konto';

  @override
  String get firstAccountBlurb =>
      'To jest konto już dla Ciebie skonfigurowane - nadaj mu rozpoznawalną nazwę, np. nazwę banku. Zaraz zapiszesz jedną transakcję Wydano lub Otrzymano, a potem zabezpieczysz urządzenie frazą odzyskiwania.';

  @override
  String get whatsMainAccountCalled => 'Jak nazywa się Twoje główne konto?';

  @override
  String get setupChoiceTitle => 'Witamy w Smara Księgowość';

  @override
  String get setupChoiceBlurb =>
      'Zaczynasz od nowa czy przenosisz się z innego urządzenia?';

  @override
  String get actionNewSetup => 'Nowa konfiguracja';

  @override
  String get continueBooksTitle => 'Kontynuuj moje księgi na tym telefonie';

  @override
  String get continueBooksBlurb =>
      'Te księgi trafiły na ten telefon bez swojego klucza podpisu. Możesz je kontynuować z nowym kluczem dla tego telefonu albo zamiast tego przywrócić je z zapisanej kopii.';

  @override
  String get continueBooksAction => 'Kontynuuj moje księgi na tym telefonie';

  @override
  String get restoreFromCopyAction => 'Przywróć z kopii';

  @override
  String get saveBooksCopyAction => 'Zapisz kopię moich ksiąg';

  @override
  String get deviceHistoryTitle => 'Historia urządzeń';

  @override
  String get deviceHistoryEmpty =>
      'Brak kontynuacji. Gdy będziesz kontynuować księgi na nowym telefonie, pojawią się tutaj.';

  @override
  String deviceHistoryContinuedOn(String date) {
    return 'Twoje księgi są kontynuowane na tym telefonie od $date';
  }

  @override
  String deviceHistoryContinuedFromCopy(String continuedDate, String copyDate) {
    return 'Twoje księgi są kontynuowane na tym telefonie od $continuedDate (z kopii zapisanej $copyDate)';
  }

  @override
  String get backupReminderBannerTitle => 'Zapisz kopię swoich ksiąg';

  @override
  String get backupReminderSaveAction => 'Zapisz kopię';

  @override
  String get backupReminderLaterAction => 'Później';

  @override
  String get settingsBackupReminder => 'Przypomnienie o kopii';

  @override
  String get settingsBackupReminderBlurb =>
      'Po pewnym czasie lub po wielu nowych wpisach delikatnie przypomnimy o zapisaniu kopii ksiąg. Zapisana kopia to jedyny sposób odzyskania ksiąg, jeśli zgubisz ten telefon.';

  @override
  String get settingsBackupReminderEnabled => 'Przypominaj o zapisaniu kopii';

  @override
  String get settingsBackupReminderDays => 'Przypomnij po tylu dniach';

  @override
  String get settingsBackupReminderEntries =>
      'Przypomnij po tylu nowych wpisach';

  @override
  String get settingsBackupReminderSnoozeDays =>
      'Ukryj na tyle dni po „Później”';

  @override
  String get settingsBackupReminderSnoozeEntries =>
      'Ukryj na tyle nowych wpisów po „Później”';

  @override
  String get settingsBooksSwitcher => 'Księgi na tym urządzeniu';

  @override
  String get settingsBooksSwitcherBlurb =>
      'Każdy zestaw ksiąg ma własny klucz podpisujący i historię. Przełączenie otwiera ten zestaw — Start i Rejestr pokazują tylko jego wpisy.';

  @override
  String get settingsBooksSwitcherActive => 'Otwarte teraz';

  @override
  String get settingsBooksSwitcherSwitch => 'Przełącz';

  @override
  String get settingsBooksSwitcherCreate => 'Nowe księgi';

  @override
  String get settingsBooksSwitcherCreateTitle => 'Nazwij te księgi';

  @override
  String get settingsBooksSwitcherNameLabel => 'Nazwa';

  @override
  String get settingsBooksSwitcherRemoveTitle => 'Usunąć te księgi?';

  @override
  String settingsBooksSwitcherRemoveBody(String name) {
    return 'To usuwa „$name” z tego urządzenia, w tym klucz podpisujący. Inne księgi na tym urządzeniu nie są dotknięte.';
  }

  @override
  String get settingsBooksSwitcherRemoveConfirm => 'Usuń';

  @override
  String settingsBooksSwitcherFallbackName(int number) {
    return 'Księgi $number';
  }

  @override
  String get settingsLinkedDevices => 'Połączone urządzenia';

  @override
  String get settingsLinkedDevicesCatchUp =>
      'Twoje urządzenia doganiają się, gdy oba mają otwarte Smara w tej samej sieci Wi-Fi.';

  @override
  String get settingsLinkedDevicesPermissionSentence =>
      'Aby udostępnić księgi, Smara musi znaleźć inne urządzenia w tej sieci Wi-Fi. Nic nie trafia do internetu.';

  @override
  String get settingsLinkedDevicesAddDevice => 'Dodaj urządzenie';

  @override
  String get settingsLinkedDevicesContinue => 'Kontynuuj';

  @override
  String get settingsLinkedDevicesRoleOwner => 'Właściciel';

  @override
  String get settingsLinkedDevicesRoleMember => 'Członek';

  @override
  String get settingsLinkedDevicesCanAdd => 'Może dodawać urządzenia';

  @override
  String get settingsLinkedDevicesErasePending => 'Oczekuje na wymazanie';

  @override
  String settingsLinkedDevicesErasedOn(String date) {
    return 'Wymazano $date';
  }

  @override
  String get settingsLinkedDevicesSuggestSecondOwner =>
      'Te księgi mają tylko jednego Właściciela. Rozważ uczynienie innego połączonego urządzenia również Właścicielem.';

  @override
  String get settingsLinkedDevicesJoinSameWifi =>
      'Oba urządzenia muszą być w tej samej sieci Wi-Fi. Smara nie łączy się przez internet.';

  @override
  String get settingsLinkedDevicesApproveJoin => 'Zatwierdź';

  @override
  String get settingsLinkedDevicesRefuseJoin => 'Odrzuć';

  @override
  String settingsLinkedDevicesPendingJoin(String name) {
    return '$name chce dołączyć do tych ksiąg';
  }

  @override
  String get settingsLinkedDevicesEmpty =>
      'Na razie połączone jest tylko to urządzenie.';

  @override
  String get settingsLinkedDevicesSyncNow => 'Synchronizuj teraz';

  @override
  String get settingsLinkedDevicesSyncNowBusy => 'Doganianie…';

  @override
  String membershipNoticeDeviceAdded(String name) {
    return 'Dodano urządzenie: $name';
  }

  @override
  String membershipNoticeDeviceRemoved(String name) {
    return 'Usunięto urządzenie: $name';
  }

  @override
  String membershipNoticeErasePending(String name) {
    return 'Oczekuje na wymazanie dla $name';
  }

  @override
  String membershipNoticeErased(String name, String date) {
    return 'Wymazano $name dnia $date';
  }

  @override
  String membershipNoticeSoleOwnerClaimed(String name) {
    return '$name zgłosił/a wyłączne właścicielstwo';
  }

  @override
  String membershipNoticeSoleOwnerCancelled(String name) {
    return 'Zgłoszenie wyłącznego Właściciela dla $name zostało anulowane';
  }

  @override
  String membershipNoticeSoleOwnerEffective(String name) {
    return '$name jest teraz Właścicielem';
  }

  @override
  String membershipNoticeEntryNotAccepted(String name) {
    return 'Nie przyjęto: nie udało się zweryfikować (od $name)';
  }

  @override
  String membershipNoticeOwnerVerificationAlert(String name) {
    return 'Rekordu od $name nie udało się zweryfikować i nie został przyjęty';
  }

  @override
  String get membershipNoticeCompetingFixCheck =>
      'Rozstrzygnięto dwie poprawki dla tego samego wpisu — sprawdź';

  @override
  String get whyWeDontEdit => 'Dlaczego nie edytujemy starych wpisów';

  @override
  String get whyWeDontEditBody =>
      'Gdy naprawiasz błąd, zachowujemy starą linię i dodajemy obok niej korektę, zamiast zmieniać to, co już wprowadziłeś/-aś. Dzięki temu Twoja historia zawsze pokazuje dokładnie, co się wydarzyło i kiedy to naprawiłeś/-aś — nic nie zmienia się po cichu w tle.';

  @override
  String get lockTitle => 'Odblokuj';

  @override
  String get lockScreenTitle => 'Zablokowane';

  @override
  String get enterPinToContinue => 'Wprowadź PIN, aby kontynuować';

  @override
  String get pinLabel => 'PIN';

  @override
  String get setPinTitle => 'Ustaw PIN';

  @override
  String get currentPin => 'Obecny PIN';

  @override
  String get newPin => 'Nowy PIN';

  @override
  String get confirmPin => 'Potwierdź PIN';

  @override
  String get confirmNewPin => 'Potwierdź nowy PIN';

  @override
  String get firstWeekTitle => 'Skonfiguruj swoje konta';

  @override
  String get addCashAccount => 'Dodaj konto gotówkowe';

  @override
  String get addCreditCard => 'Dodaj kartę kredytową';

  @override
  String get cashAccountName => 'Nazwa konta gotówkowego';

  @override
  String get cardName => 'Nazwa karty';

  @override
  String get paidFromBank => 'Zapłacono z banku';

  @override
  String get paidFromCard => 'Zapłacono kartą';

  @override
  String get choosePassphraseTitle =>
      'Wybierz hasło, aby zabezpieczyć tę kopię zapasową. Nie ma możliwości odzyskania, jeśli je zapomnisz.';

  @override
  String get replaceBooksTitle => 'Zastąpić lokalne księgi?';

  @override
  String get replaceBooksBody =>
      'To zastąpi wszystko, co obecnie znajduje się w tej aplikacji, kopią zapasową. Zamknij i ponownie otwórz aplikację po zakończeniu.';

  @override
  String get chooseBackupFileFirst => 'Najpierw wybierz plik kopii zapasowej.';

  @override
  String get backupRestored => 'Kopia zapasowa przywrócona';

  @override
  String get backupRestoredBody =>
      'Twoje księgi zostały przywrócone. Zamknij i ponownie otwórz aplikację, aby kontynuować.';

  @override
  String get fixThisEntry => 'Napraw ten wpis';

  @override
  String get fixBlurb =>
      'Stara linia pozostaje dokładnie taka, jaka była. Potwierdzenie dodaje linię odwracającą i skorygowaną.';

  @override
  String get importStatementTitle => 'Importuj wyciąg';

  @override
  String get importOfx => 'Importuj OFX';

  @override
  String get importOfxQfxFile => 'Importuj plik OFX / QFX';

  @override
  String get importCsvFile => 'Importuj plik CSV';

  @override
  String get whatKindOfStatement => 'Jaki rodzaj pliku wyciągu posiadasz?';

  @override
  String get chooseAccountForFile =>
      'Wybierz, do którego konta należy ten plik.';

  @override
  String get importIntoAccount => 'Importuj do konta';

  @override
  String get useSavedProfile => 'Użyj zapisanego profilu';

  @override
  String get saveMappingProfile =>
      'Zapisz to mapowanie jako profil (opcjonalnie)';

  @override
  String get renameProfile => 'Zmień nazwę profilu';

  @override
  String get deleteProfileTitle => 'Usunąć profil?';

  @override
  String get fileHasHeader => 'Plik zawiera wiersz nagłówka';

  @override
  String get dateColumn => 'Kolumna daty';

  @override
  String get dateFormatHint => 'Format daty (np. dd/MM/rrrr)';

  @override
  String get amountColumn => 'Kolumna kwoty';

  @override
  String get amountConvention => 'Konwencja kwoty';

  @override
  String get signedAmountColumn => 'Kolumna kwoty ze znakiem';

  @override
  String get separateDebitCredit => 'Osobne kolumny obciążeń / uznań';

  @override
  String get debitColumn => 'Kolumna obciążeń';

  @override
  String get creditColumn => 'Kolumna uznań';

  @override
  String get decimalSeparator => 'Separator dziesiętny (. lub ,)';

  @override
  String get descriptionColumns => 'Kolumna(-y) opisu';

  @override
  String get referenceIdColumn =>
      'Kolumna identyfikatora referencyjnego (opcjonalnie)';

  @override
  String get skippedRows => 'Pominięte wiersze';

  @override
  String parsedTransactionCount(String count) {
    return 'Przeanalizowano $count transakcji';
  }

  @override
  String skippedOrExcludedCount(String count) {
    return '$count pominięto lub wykluczono';
  }

  @override
  String postedFailedCount(String posted, String failed) {
    return '$posted zaksięgowano, $failed nie powiodło się';
  }

  @override
  String get categoryForAll => 'Kategoria dla wszystkich';

  @override
  String get saveAsRule => 'Zapisać jako regułę?';

  @override
  String get saveAsRuleBlurb =>
      'Przyszłe importy, których opis zawiera to słowo kluczowe, będą używać tej kategorii.';

  @override
  String get keyword => 'Słowo kluczowe';

  @override
  String get noSavedRules =>
      'Brak jeszcze zapisanych reguł. Przypisz kategorię do grupy wierszy, aby zapisać regułę.';

  @override
  String get deleteRuleTitle => 'Usunąć regułę?';

  @override
  String get editRule => 'Edytuj regułę';

  @override
  String rowsGrouped(String count) {
    return '$count wierszy';
  }

  @override
  String selectStatementFile(String extensions) {
    return 'Wybierz plik wyciągu $extensions do zaimportowania';
  }

  @override
  String get payeesTitle => 'Odbiorcy';

  @override
  String get addPayee => 'Dodaj odbiorcę';

  @override
  String get renamePayee => 'Zmień nazwę odbiorcy';

  @override
  String get deletePayeeTitle => 'Usunąć odbiorcę?';

  @override
  String get noPayeesYet => 'Brak jeszcze odbiorców';

  @override
  String get recurringTitle => 'Szablony cykliczne';

  @override
  String get noRecurringYet => 'Brak jeszcze szablonów cyklicznych';

  @override
  String get deleteTemplateTitle => 'Usunąć szablon cykliczny?';

  @override
  String get dayOfMonth => 'Dzień miesiąca (1-31)';

  @override
  String get dayOfMonthNote =>
      'Miesiąc z mniejszą liczbą dni używa swojego ostatniego dnia.';

  @override
  String dayOfMonthLine(String day) {
    return 'Dzień $day miesiąca - ';
  }

  @override
  String get name => 'Nazwa';

  @override
  String get none => 'Brak';

  @override
  String get currency => 'Waluta';

  @override
  String get errorGeneric => 'Coś poszło nie tak. Spróbuj ponownie.';

  @override
  String get errorInvalidLedgerBackup =>
      'Ten plik nie jest prawidłową kopią zapasową Smara.';

  @override
  String get errorInvalidLedgerBackupNoIdentity =>
      'Ta kopia zapasowa nie ma tożsamości podpisującej - nie jest prawidłową kopią zapasową Smara.';

  @override
  String get errorInvalidLedgerBackupUnverified =>
      'Ta kopia zapasowa nie zweryfikowała się jako nienaruszone księgi, więc nie została przywrócona.';

  @override
  String errorInvalidLedgerBackupUnreadable(String detail) {
    return 'Nie można było otworzyć tego pliku jako kopii zapasowej Smara: $detail';
  }

  @override
  String get errorAccountNotFinancial => 'To nie jest konto finansowe.';

  @override
  String get errorAccountArchived => 'To konto jest ukryte.';

  @override
  String get errorAccountNotArchived => 'To konto nie jest ukryte.';

  @override
  String get errorAccountNoPositiveBalanceToCloseOut =>
      'Nie ma pozostałego salda do przeniesienia.';

  @override
  String get errorAccountHasNoGroup => 'To konto nie ma przypisanej grupy.';

  @override
  String get errorGroupHasNoCurrency =>
      'Ta grupa nie ma jeszcze ustawionej waluty.';

  @override
  String get errorGroupNotFound => 'Nie znaleziono tej grupy kont.';

  @override
  String get errorInvestmentAccountsMustBeAssets =>
      'Tylko konta aktywów mogą być oznaczone jako konta inwestycyjne.';

  @override
  String get errorCreditCardsMustBeLiabilities =>
      'Tylko konta pasywów mogą być oznaczone jako karty kredytowe.';

  @override
  String get errorOpeningBalanceMustBePositive =>
      'Saldo początkowe musi być dodatnie, jeśli zostało podane.';

  @override
  String get errorAccountTypeDoesNotMatchGroup =>
      'Ten typ konta nie odpowiada grupie.';

  @override
  String get errorLastActiveAccount =>
      'Nie można ukryć ostatniego aktywnego konta finansowego.';

  @override
  String get errorCurrencyRequiredToCreateGroup =>
      'Waluta jest wymagana, aby utworzyć grupę.';

  @override
  String get errorSystemGroupCannotBeArchived =>
      'Wbudowanych grup kont nie można ukryć.';

  @override
  String get errorGroupAlreadyArchived => 'Ta grupa jest już ukryta.';

  @override
  String get errorCannotArchiveGroupWithAccounts =>
      'Nie można ukryć grupy, która nadal ma aktywne konta.';

  @override
  String get errorSystemGroupNeverArchived =>
      'Wbudowane grupy kont nigdy nie są ukrywane.';

  @override
  String get errorAccountGroupsCannotBeDeleted => 'Grup kont nie można usuwać.';

  @override
  String get errorCannotReassignDifferentCurrency =>
      'Nie można przenieść tego konta do grupy o innej walucie.';

  @override
  String get errorCannotChangeGroupCurrencyWithAccounts =>
      'Nie można zmienić waluty, gdy grupa ma aktywne konta.';

  @override
  String get errorAmountMustBePositive => 'Kwota musi być dodatnia.';

  @override
  String get errorAccountCurrencyAmountMustBePositive =>
      'Kwota w walucie konta musi być dodatnia.';

  @override
  String get errorAccountCurrencyAmountNotForSameCurrency =>
      'Kwota w walucie konta jest tylko dla wpisu w obcej walucie.';

  @override
  String get errorSplitNeedsTwoLines =>
      'Podział wymaga co najmniej dwóch linii kategorii.';

  @override
  String get errorSplitLineMustBePositive =>
      'Każda linia podziału musi mieć dodatnią kwotę.';

  @override
  String get errorSplitLinesMustSumToTotal =>
      'Linie podziału muszą sumować się do całkowitej kwoty transakcji.';

  @override
  String get errorTransferAmountMustBePositive =>
      'Kwota przelewu musi być dodatnia.';

  @override
  String get errorTransferAccountsMustDiffer =>
      'Konto źródłowe i docelowe muszą się różnić.';

  @override
  String get errorCloseoutRequiresDestinationAmount =>
      'Rozliczenie w innej walucie wymaga znanej kwoty docelowej.';

  @override
  String get errorDestinationAmountNotForSameCurrency =>
      'Kwota docelowa jest tylko dla przelewu w innej walucie.';

  @override
  String get errorDestinationAmountMustBePositive =>
      'Kwota docelowa musi być dodatnia.';

  @override
  String get errorInvestmentCashExceeded =>
      'Nie można przenieść więcej niż wynosi gotówka tego konta inwestycyjnego.';

  @override
  String get errorCannotReverseUnsettledProvisional =>
      'Rozlicz ten oczekujący przelew zamiast go odwracać.';

  @override
  String get errorAlreadyReversed =>
      'Ten wpis został już skorygowany. Oryginalna linia pozostaje bez zmian.';

  @override
  String get errorNotActiveExpenseCategory =>
      'Wybierz aktywną kategorię wydatków.';

  @override
  String get errorNotActiveIncomeCategory =>
      'Wybierz aktywną kategorię przychodów.';

  @override
  String get errorSettledAmountMustNotBeNegative =>
      'Kwota, która dotarła, nie może być ujemna.';

  @override
  String get errorPendingTransferNotFound =>
      'Nie znaleziono tego oczekującego przelewu.';

  @override
  String get errorPendingTransferAlreadySettled =>
      'Ten oczekujący przelew jest już rozliczony.';

  @override
  String get errorSettledToMustBeSourceOrDestination =>
      'Wybierz oryginalne konto źródłowe lub docelowe.';

  @override
  String get errorFeeCategoryOnlyWhenReturningToSource =>
      'Kategoria opłaty jest używana tylko wtedy, gdy środki wracają na konto źródłowe.';

  @override
  String get errorSettledAmountMustBePositiveForDelivery =>
      'Wprowadź dodatnią kwotę tego, co dotarło.';

  @override
  String get errorSettledAmountExceedsProvisional =>
      'Ta kwota jest większa niż wysłana.';

  @override
  String get errorInstrumentNotFound => 'Nie znaleziono tego instrumentu.';

  @override
  String get errorIncomeRequiredForNonCash =>
      'Aktywna kategoria przychodu jest wymagana dla nabycia niepieniężnego.';

  @override
  String get errorInsufficientCash =>
      'Za mało gotówki na tym koncie inwestycyjnym na to kupno.';

  @override
  String get errorSellQuantityAndPriceMustBePositive =>
      'Ilość i cena jednostkowa sprzedaży muszą być dodatnie.';

  @override
  String errorLockedUntil(String date) {
    return 'Nie można sprzedać: niektóre jednostki są zablokowane do $date.';
  }

  @override
  String get errorInsufficientQuantity =>
      'Nie można sprzedać więcej niż aktualnie posiadasz odblokowane.';

  @override
  String get errorIncomeRequiredForGain =>
      'Aktywna kategoria przychodu jest wymagana dla zrealizowanego zysku.';

  @override
  String get errorExpenseRequiredForLoss =>
      'Aktywna kategoria wydatku jest wymagana dla zrealizowanej straty.';

  @override
  String errorBrokerageFailedAfterBuy(String detail) {
    return 'Kupno zaksięgowane, ale prowizja maklerska nie powiodła się: $detail';
  }

  @override
  String errorBrokerageFailedAfterSell(String detail) {
    return 'Sprzedaż zaksięgowana, ale prowizja maklerska nie powiodła się: $detail';
  }

  @override
  String get errorDividendMustBePositive =>
      'Kwota dywidendy musi być dodatnia.';

  @override
  String get errorNotInvestmentAccount => 'To nie jest konto inwestycyjne.';

  @override
  String get errorNoInventoryCompanion =>
      'To konto inwestycyjne nie ma towarzyszącego rejestru inwentarza.';

  @override
  String errorInvestmentReversalBlocked(String sells) {
    return 'Nie można odwrócić tego kupna: późniejsze sprzedaże zależą od jego jednostek. Najpierw odwróć zależne sprzedaże: $sells.';
  }

  @override
  String get errorMonthlyLimitMustBePositive =>
      'Limit miesięczny musi być dodatni.';

  @override
  String get errorTemplateAmountMustBePositive =>
      'Kwota szablonu musi być dodatnia.';

  @override
  String get errorOfxUnrecognized => 'Nie rozpoznano tego pliku jako OFX.';

  @override
  String get errorCsvEmpty => 'Wybrany plik jest pusty.';

  @override
  String get errorCsvUnreadable => 'Nie można odczytać tego pliku jako CSV.';

  @override
  String get errorCsvNoRows => 'Wybrany plik nie zawiera wierszy.';

  @override
  String get skipMissingDate => 'Brak daty.';

  @override
  String skipUnparseableDate(String raw, String pattern) {
    return 'Nie można odczytać daty \"$raw\" przy użyciu wzorca \"$pattern\".';
  }

  @override
  String get skipOfxMissingOrInvalidDate =>
      'Brak daty transakcji lub jest nieprawidłowa.';

  @override
  String skipOfxUnparseableDate(String raw) {
    return 'Nie można odczytać daty transakcji \"$raw\".';
  }

  @override
  String get skipMissingAmount => 'Brak kwoty.';

  @override
  String skipUnparseableAmount(String raw) {
    return 'Nie można odczytać kwoty \"$raw\".';
  }

  @override
  String get skipZeroAmount => 'Kwota wynosi zero.';

  @override
  String get skipUnparseableDebitCreditAmount =>
      'Nie można odczytać kwoty winien lub ma.';

  @override
  String get skipBothDebitAndCreditNonZero =>
      'Kolumny winien i ma zawierają obie kwotę.';

  @override
  String get skipBothDebitAndCreditZero =>
      'Kolumny winien i ma wynoszą obie zero.';

  @override
  String errorBackupCreateFailed(String detail) {
    return 'Nie udało się utworzyć kopii zapasowej: $detail';
  }

  @override
  String get errorBackupRestoreFailed =>
      'Nie udało się przywrócić tej kopii zapasowej - błędne hasło lub to nie jest plik kopii zapasowej Smara.';

  @override
  String get validationAmountAccountCategoryRequired =>
      'Kwota, konto i kategoria są wymagane.';

  @override
  String get validationAmountAccountRequired => 'Kwota i konto są wymagane.';

  @override
  String get validationSplitLineIncomplete =>
      'Każda linia podziału wymaga kategorii i kwoty.';

  @override
  String get validationSplitSumMismatch =>
      'Linie podziału muszą sumować się do całkowitej kwoty transakcji.';

  @override
  String get validationFromToAmountRequired =>
      'Konto źródłowe, konto docelowe i kwota są wymagane.';

  @override
  String get validationAmountArrivedRequired =>
      'Kwota, która dotarła, jest wymagana.';

  @override
  String get validationChooseReceivingAccount =>
      'Wybierz konto, na które wpłynęły środki.';

  @override
  String get validationAccountCategoryRequired =>
      'Konto i kategoria są wymagane.';

  @override
  String get validationFixFailed => 'Nie udało się zapisać tej poprawki.';

  @override
  String get validationNameRequired => 'Nadaj nazwę swojemu głównemu kontu.';

  @override
  String get validationStillLoading =>
      'Nadal wczytywanie - spróbuj ponownie za chwilę.';

  @override
  String get validationSaveAccountNameFailed =>
      'Nie udało się zapisać nazwy konta.';

  @override
  String get validationWrongPin => 'Błędny PIN. Spróbuj ponownie.';

  @override
  String get validationCategoryMustBeIncomeOrExpense =>
      'Kategoria musi być przychodem lub wydatkiem.';

  @override
  String get validationOnlyExpenseHasMonthlyLimit =>
      'Tylko kategoria wydatku może mieć limit miesięczny.';

  @override
  String get validationInvalidTemplate => 'Nieprawidłowy szablon.';

  @override
  String validationGenerateKeyFailed(String detail) {
    return 'Nie udało się wygenerować klucza podpisującego na tym urządzeniu: $detail';
  }

  @override
  String validationSaveCurrencyFailed(String detail) {
    return 'Nie udało się zapisać tej waluty: $detail';
  }

  @override
  String get validationChooseBackupFile =>
      'Najpierw wybierz plik kopii zapasowej.';

  @override
  String get validationPassphraseRequired => 'Wprowadź hasło.';

  @override
  String get validationPinsDoNotMatch => 'Oba PIN-y nie są zgodne.';

  @override
  String get validationFeePositiveWithCategory =>
      'Opłata za przelew musi być dodatnią kwotą z wybraną kategorią wydatku.';

  @override
  String get validationFeeMustBeLessThanAmount =>
      'Opłata musi być mniejsza niż kwota w przelewie z potrącaną opłatą.';

  @override
  String validationTransferSavedFeeFailed(String detail) {
    return 'Przelew zapisany, ale nie udało się zarejestrować opłaty: $detail';
  }

  @override
  String get validationEnterValidAmount => 'Wprowadź prawidłową kwotę.';

  @override
  String get errorBuyQuantityAndPriceMustBePositive =>
      'Ilość i cena jednostkowa kupna muszą być dodatnie.';

  @override
  String get errorInstrumentArchived =>
      'Nie można kupić zarchiwizowanego instrumentu.';

  @override
  String get errorNonCashCannotIncludeBrokerage =>
      'Nabycia niepieniężne nie mogą zawierać prowizji maklerskiej.';

  @override
  String get errorBrokerageRequiresExpenseCategory =>
      'Aktywna kategoria wydatku jest wymagana, gdy prowizja jest dodatnia.';

  @override
  String get errorSellProceedsMustCoverBrokerage =>
      'Wpływy ze sprzedaży muszą pokrywać co najmniej kwotę prowizji.';

  @override
  String homeSpentOfLimitThisMonth(String spent, String limit) {
    return '$spent z $limit w tym miesiącu';
  }

  @override
  String get unlockBiometricReason => 'Odblokuj Smara Accounting';

  @override
  String get searchLabel => 'Szukaj';

  @override
  String get openingBalance => 'Saldo początkowe';

  @override
  String transferToName(String name) {
    return 'Przelew: $name';
  }

  @override
  String get feeForTransfer => 'Opłata za przelew';

  @override
  String feeForTransferTo(String name) {
    return 'Opłata za przelew do $name';
  }

  @override
  String couldNotOpenFilePicker(String detail) {
    return 'Nie udało się otworzyć selektora plików: $detail';
  }

  @override
  String pleaseSelectFile(String extensions) {
    return 'Wybierz plik .$extensions';
  }

  @override
  String get currencyCodeIso => 'Kod waluty (ISO 4217, np. USD)';

  @override
  String splitCounterpartMore(String name, String count) {
    return '$name +$count więcej';
  }

  @override
  String get dateLabel => 'Data';

  @override
  String get noneSelected => 'Brak';

  @override
  String reviewEntriesBeforeContinuing(String count) {
    return 'Przejrzyj poniższe wpisy ($count łącznie) przed kontynuowaniem.';
  }

  @override
  String youReceived(String amount) {
    return 'Otrzymano $amount';
  }

  @override
  String get leaveBlankIfRateUnknown =>
      'Pozostaw puste, jeśli kurs wymiany nie jest jeszcze znany.';

  @override
  String get recordTradeBlurb =>
      'Zapisz transakcję, która już się odbyła. Ta aplikacja nie składa zleceń.';

  @override
  String get feeOnTopBlurb =>
      'Wliczona: kwota powyżej to całość pobrana z tego konta; opłata jest z niej potrącana.';

  @override
  String get feeBankBlurb =>
      'Prowizja pobierana z góry przez Twój bank lub pośrednika.';

  @override
  String get validationPinMinLength => 'PIN musi mieć co najmniej 4 cyfry.';

  @override
  String get restoreBackupBlurb =>
      'To zastąpi wszystko, co obecnie znajduje się w tej aplikacji, kopią zapasową — nie łączy danych. Wybierz plik kopii zapasowej i wprowadź hasło, którym go zabezpieczono.';

  @override
  String get actionReplace => 'Zastąp';

  @override
  String hideAccountBody(String name) {
    return '$name nie będzie już dostępne dla nowych transakcji.';
  }

  @override
  String hideGroupBody(String name) {
    return '$name nie będzie już oferowane przy tworzeniu lub przypisywaniu kont.';
  }

  @override
  String hideCategoryBody(String name) {
    return '$name nie będzie już oferowane przy zapisywaniu nowych transakcji.';
  }

  @override
  String get hideInstrumentBody =>
      'Ukryte instrumenty pozostają przy dawnych kupnach i sprzedażach. Nadal możesz zapisać dla nich dywidendę.';

  @override
  String nameHidden(String name) {
    return '$name (ukryte)';
  }

  @override
  String get noCurrencySet => 'Nie ustawiono waluty';

  @override
  String deletePayeeBody(String name) {
    return '$name i jego zapamiętane ustawienia domyślne zostaną usunięte. Wcześniejsze transakcje pozostaną bez zmian.';
  }

  @override
  String deleteTemplateBody(String name) {
    return '$name nie będzie już oferowane jako termin. Wcześniejsze transakcje już zapisane przez ten szablon pozostaną bez zmian.';
  }

  @override
  String deleteProfileBody(String name) {
    return 'Zapisane mapowanie kolumn \"$name\" zostanie usunięte. Wyciągi już zaimportowane przy jego użyciu pozostaną bez zmian.';
  }

  @override
  String deleteRuleBody(String keyword) {
    return 'Importy nie będą już automatycznie kategoryzowane przez \"$keyword\". Transakcje już skategoryzowane tą regułą pozostaną bez zmian.';
  }

  @override
  String get firstWeekBlurb =>
      'Możesz teraz opcjonalnie dodać kartę kredytową lub konto gotówkowe - zawsze możesz dodać więcej kont później w Ustawieniach.';

  @override
  String get deliveredToDestination => 'Dostarczono do miejsca docelowego';

  @override
  String deliveredToName(String name) {
    return 'Dostarczono do $name';
  }

  @override
  String youReceivedLessThanExpected(String amount, String currency) {
    return 'Otrzymano $amount $currency mniej niż oczekiwano - wybierz kategorię, aby pokryć różnicę.';
  }

  @override
  String get dateRangeLabel => 'Zakres dat';

  @override
  String get addTemplate => 'Dodaj szablon';

  @override
  String get editTemplate => 'Edytuj szablon';

  @override
  String get validationFillTemplateFields =>
      'Wypełnij każde pole prawidłową kwotą i dniem.';

  @override
  String get saveCsvExport => 'Zapisz eksport CSV';

  @override
  String get referenceRate => 'Kurs referencyjny';

  @override
  String get yourRate => 'Twój kurs';

  @override
  String leaveBlankIfThisWasAccountCurrency(String currency) {
    return 'Pozostaw puste, jeśli było to w $currency, własnej walucie konta.';
  }

  @override
  String get lockUntilOptional => 'Zablokowane do (opcjonalnie)';

  @override
  String lockedUntilDate(String date) {
    return 'Zablokowane do $date';
  }

  @override
  String get copiedResearchPrompt =>
      'Skopiowano zapytanie do analizy — brak dostępnego adresu URL przeglądarki lub jesteś offline.';

  @override
  String get openedFavouriteResearchTool =>
      'Otwarto Twoje ulubione narzędzie do analiz.';

  @override
  String get looksLikeGain => 'To wygląda na zysk';

  @override
  String get looksLikeLoss => 'To wygląda na stratę';

  @override
  String get looksLikeBreakEven => 'To wygląda na wynik zerowy';

  @override
  String sellableQuantity(String name, String qty) {
    return '$name ($qty do sprzedania)';
  }

  @override
  String columnN(String index) {
    return 'Kolumna $index';
  }

  @override
  String get importingLabel => 'Importowanie...';

  @override
  String get confirmImport => 'Potwierdź import';

  @override
  String get manageSavedCategoryRules =>
      'Zarządzaj zapisanymi regułami kategorii';

  @override
  String statementCurrencyMismatch(String currency) {
    return 'Waluta tego pliku ($currency) nie zgadza się z walutą wybranego konta.';
  }

  @override
  String get categoryRulesTitle => 'Reguły kategorii';

  @override
  String get possibleDuplicate => 'możliwy duplikat';

  @override
  String get unknownCategory => 'Nieznana kategoria';

  @override
  String get researchPromptIntro =>
      'Zbadaj ten notowany publicznie instrument dla inwestora indywidualnego. Zidentyfikuj emitenta, podsumuj najnowsze wiadomości z datami, jeśli są znane, i przedstaw ryzyka spadku oraz czynniki wzrostu. Oddziel fakty od spekulacji. Nie udzielaj rekomendacji kupna, sprzedaży ani utrzymania. To nie jest porada finansowa.';

  @override
  String researchPromptNameLine(String name) {
    return 'Nazwa: $name';
  }

  @override
  String researchPromptTickerLine(String ticker) {
    return 'Ticker: $ticker';
  }

  @override
  String get researchPromptTickerNoneProvided => 'Ticker: (nie podano)';

  @override
  String researchPromptIsinLine(String isin) {
    return 'ISIN: $isin';
  }

  @override
  String get researchPromptIsinNoneProvided => 'ISIN: (nie podano)';

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
  String get booksCopyPassphrase => 'Hasło';

  @override
  String replaceBooksWarning(String counts) {
    return 'Spowoduje to zastąpienie wszystkich wpisów i ustawień ksiąg na tym telefonie ($counts). Nic nie jest łączone. Język i ustawienia odblokowania pozostają na tym telefonie.';
  }

  @override
  String get saveCopyFirstAction => 'Najpierw zapisz kopię';

  @override
  String replaceCountEntries(int count) {
    return 'Wpisy: $count';
  }

  @override
  String replaceCountAccounts(int count) {
    return 'Konta: $count';
  }

  @override
  String replaceCountCategories(int count) {
    return 'Kategorie: $count';
  }

  @override
  String replaceCountGroups(int count) {
    return 'Grupy kont: $count';
  }

  @override
  String replaceCountPayees(int count) {
    return 'Odbiorcy: $count';
  }

  @override
  String replaceCountCategoryRules(int count) {
    return 'Reguły kategorii: $count';
  }

  @override
  String replaceCountCsvProfiles(int count) {
    return 'Profile importu: $count';
  }

  @override
  String replaceCountRecurringTemplates(int count) {
    return 'Szablony cykliczne: $count';
  }

  @override
  String replaceCountInstruments(int count) {
    return 'Instrumenty: $count';
  }

  @override
  String get claimsTitle => 'Wnioski';

  @override
  String get claimsReviewTitle => 'Przegląd wniosków';

  @override
  String get claimsStatusDraft => 'Szkic';

  @override
  String get claimsStatusSubmitted => 'Złożony';

  @override
  String get claimsStatusPartlyApproved => 'Częściowo zatwierdzony';

  @override
  String get claimsStatusApproved => 'Zatwierdzony';

  @override
  String get claimsStatusPaid => 'Wypłacony';

  @override
  String get claimsStatusRejected => 'Odrzucony';

  @override
  String get claimsApprove => 'Zatwierdź';

  @override
  String get claimsApproveDifferent => 'Zatwierdź inną kwotę';

  @override
  String get claimsReject => 'Odrzuć';

  @override
  String get claimsReasonRequired => 'Powód jest wymagany';

  @override
  String get claimsAdvances => 'Zaliczki';

  @override
  String get claimsAddPerson => 'Dodaj osobę';

  @override
  String get claimsRoleApprover => 'Zatwierdzający';

  @override
  String get claimsRoleClaimant => 'Wnioskodawca';

  @override
  String claimsBalanceCompanyOwesYou(String company) {
    return '$company jest Ci winna';
  }

  @override
  String claimsBalanceYouOweCompany(String company) {
    return 'Jesteś winien/winna firmie $company';
  }

  @override
  String claimsBalanceSettled(String company) {
    return 'Rozliczono z $company';
  }

  @override
  String get claimsReceiptRequired =>
      'Do tej pozycji wniosku wymagany jest paragon';

  @override
  String get claimsReceiptPdfTooLarge =>
      'Ten PDF jest większy niż 5 MB. Wybierz mniejszy plik.';

  @override
  String claimsSpendingHint(String amount, String unit) {
    return 'Wskazówka: co najwyżej $amount na $unit';
  }

  @override
  String get claimsNoClaimsYet => 'Brak wniosków.';

  @override
  String get claimsNoClaimsToReview => 'Brak wniosków do przeglądu.';

  @override
  String get claimsAdvanceDefault => 'Zaliczka';

  @override
  String claimsItemCount(int count) {
    return 'Pozycje: $count';
  }

  @override
  String get claimsRejectReasonTitle => 'Powód odrzucenia';

  @override
  String get claimsApproveDifferentReasonTitle =>
      'Powód zatwierdzenia innej kwoty';

  @override
  String get claimsPersonNameLabel => 'Imię i nazwisko';

  @override
  String get claimsRemovePerson => 'Usuń';

  @override
  String claimsRemovePersonTitle(String name) {
    return 'Usunąć $name?';
  }

  @override
  String claimsRemovePersonWarning(String name, int openClaims) {
    return '$name ma $openClaims otwartych Wniosków i niezerowe saldo. Historia i paragony pozostają w tych księgach.';
  }

  @override
  String claimsRemovePersonWarningOpenOnly(String name, int openClaims) {
    return '$name ma $openClaims otwartych Wniosków. Historia i paragony pozostają w tych księgach.';
  }

  @override
  String claimsRemovePersonWarningBalanceOnly(String name) {
    return '$name ma niezerowe saldo. Historia i paragony pozostają w tych księgach.';
  }

  @override
  String claimsRemovePersonWarningClean(String name) {
    return 'Usunąć $name? Historia i paragony pozostają w tych księgach.';
  }

  @override
  String get claimsRemovePersonConfirm => 'Usuń';

  @override
  String get claimsEditorTitle => 'Edytuj wniosek';

  @override
  String get claimsSubmit => 'Złóż';

  @override
  String get claimsAddItem => 'Dodaj pozycję';

  @override
  String get claimsEditItem => 'Edytuj pozycję';

  @override
  String get claimsNoItemsYet =>
      'Dodaj co najmniej jedną pozycję przed złożeniem.';

  @override
  String get claimsNoAllowlistedCategories =>
      'Żadne kategorie wydatków nie są jeszcze dozwolone we wnioskach.';

  @override
  String get claimsCategoryLabel => 'Kategoria';

  @override
  String get claimsExpenseDateLabel => 'Data wydatku';

  @override
  String get claimsPaidAmountLabel => 'Zapłacona kwota';

  @override
  String get claimsPaidCurrencyLabel => 'Waluta płatności';

  @override
  String get claimsRateOptionalLabel => 'Kurs (opcjonalnie)';

  @override
  String claimsCompanyAmountLabel(String currency) {
    return 'Kwota w $currency';
  }

  @override
  String get claimsDescriptionLabel => 'Opis';

  @override
  String get claimsAttachCamera => 'Zrób zdjęcie';

  @override
  String get claimsAttachGallery => 'Wybierz zdjęcie';

  @override
  String get claimsAttachPdf => 'Wybierz PDF';

  @override
  String claimsReceiptAttached(String fileName) {
    return 'Paragon: $fileName';
  }

  @override
  String get claimsReceiptRequiredHint => 'Do tej kwoty wymagany jest paragon.';

  @override
  String get claimsReceiptPermissionSentence =>
      'Aby dołączyć zdjęcie paragonu, Smara potrzebuje dostępu do aparatu lub biblioteki zdjęć. Zdjęcia pozostają w tych księgach na Twoich urządzeniach.';

  @override
  String claimsReviewClaimHeading(String status) {
    return 'Wniosek · $status';
  }
}
