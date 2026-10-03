// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Smara Contabilità';

  @override
  String get navHome => 'Home';

  @override
  String get navRegister => 'Registro';

  @override
  String get navSummary => 'Riepilogo';

  @override
  String get navAccounts => 'Conti';

  @override
  String get navCategories => 'Categorie';

  @override
  String get actionCancel => 'Annulla';

  @override
  String get actionSave => 'Salva';

  @override
  String get actionDelete => 'Elimina';

  @override
  String get actionDone => 'Fatto';

  @override
  String get actionContinue => 'Continua';

  @override
  String get actionDismiss => 'Ignora';

  @override
  String get actionRetry => 'Riprova';

  @override
  String get actionSkip => 'Salta';

  @override
  String get actionConfirm => 'Conferma';

  @override
  String get actionAdd => 'Aggiungi';

  @override
  String get actionEdit => 'Modifica';

  @override
  String get actionRename => 'Rinomina';

  @override
  String get actionHide => 'Nascondi';

  @override
  String get actionCreate => 'Crea';

  @override
  String get actionCloseApp => 'Chiudi app';

  @override
  String get actionUnlock => 'Sblocca';

  @override
  String get actionSettle => 'Salda';

  @override
  String get actionFinish => 'Fine';

  @override
  String get actionPreview => 'Anteprima';

  @override
  String get actionImport => 'Importa';

  @override
  String get actionExportCsv => 'Esporta CSV';

  @override
  String get actionChooseFile => 'Scegli file';

  @override
  String get actionRestore => 'Ripristina';

  @override
  String get actionFix => 'Correggi';

  @override
  String get actionBuy => 'Compra';

  @override
  String get actionSell => 'Vendi';

  @override
  String get actionDividend => 'Dividendo';

  @override
  String get actionRecordBuy => 'Registra acquisto';

  @override
  String get actionRecordSell => 'Registra vendita';

  @override
  String get actionRecordDividend => 'Registra dividendo';

  @override
  String get actionPayCard => 'Paga carta';

  @override
  String get actionTransfer => 'Trasferisci';

  @override
  String get actionRecordTransaction => 'Registra transazione';

  @override
  String get actionImportStatement => 'Importa estratto conto';

  @override
  String get actionClearDates => 'Cancella date';

  @override
  String get actionClearSearch => 'Cancella ricerca e filtri';

  @override
  String get actionUseBiometrics => 'Usa dati biometrici';

  @override
  String get actionSetPin => 'Imposta PIN';

  @override
  String get actionChangePin => 'Cambia PIN';

  @override
  String get actionSaveBackup => 'Salva backup';

  @override
  String get actionRestoreBackup => 'Ripristina backup';

  @override
  String get actionSaveRule => 'Salva regola';

  @override
  String get actionConfirmFix => 'Conferma correzione';

  @override
  String get captureSpent => 'Speso';

  @override
  String get captureReceived => 'Ricevuto';

  @override
  String get captureMovedMoney => 'Denaro spostato';

  @override
  String get captureImportStatement => 'Importa estratto conto';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get settingsLanguage => 'Lingua';

  @override
  String get settingsLanguageSystem => 'Lingua del dispositivo';

  @override
  String get settingsFetchFxRates => 'Recupera tassi di cambio di riferimento';

  @override
  String get settingsFetchFxRatesSubtitle =>
      'Mostra un tasso di mercato indicativo accanto all\'importo di destinazione nei trasferimenti tra valute diverse, solo a scopo di confronto - non viene mai usato per compilare l\'importo.';

  @override
  String get settingsRateProvider => 'Fornitore del tasso';

  @override
  String get settingsFetchMarketPrices =>
      'Recupera i prezzi di mercato per gli investimenti';

  @override
  String get settingsFetchMarketPricesSubtitle =>
      'Cerca gli ultimi prezzi degli strumenti che hanno un ticker o un ISIN, per stimare il valore del portafoglio. Non viene mai usato per registrare un\'operazione e non invia mai la quantità posseduta.';

  @override
  String get settingsMarketPriceProvider => 'Fornitore dei prezzi di mercato';

  @override
  String get settingsFavouriteResearchTool => 'Strumento di ricerca preferito';

  @override
  String get settingsFavouriteResearchToolSubtitle =>
      'Toccando il nome di uno strumento nelle posizioni si apre questo strumento nel browser con un prompt di ricerca — non è un\'integrazione, né una consulenza.';

  @override
  String get settingsBackup => 'Backup';

  @override
  String get settingsBackupBlurb =>
      'Salva una copia cifrata dei tuoi libri contabili in un percorso a tua scelta, oppure ripristinala da lì. Questo è separato dalla tua frase di recupero o dal file keystore, che eseguono il backup della tua chiave di firma, non dei tuoi libri contabili.';

  @override
  String get settingsLock => 'Blocco';

  @override
  String get settingsLockBlurb =>
      'Richiedi un PIN, o i dati biometrici dove disponibili, per aprire l\'app.';

  @override
  String get settingsRequireUnlock => 'Richiedi sblocco per aprire l\'app';

  @override
  String get settingsLockAfter => 'Blocca dopo';

  @override
  String get settingsLockImmediately => 'Immediatamente';

  @override
  String get settingsLock1Minute => '1 minuto';

  @override
  String get settingsLock5Minutes => '5 minuti';

  @override
  String get settingsLock15Minutes => '15 minuti';

  @override
  String get settingsAllowBiometrics => 'Consenti anche i dati biometrici';

  @override
  String get settingsHideSnapshot => 'Nascondi i saldi nel selettore app';

  @override
  String get settingsHideSnapshotSubtitle =>
      'Oscura questa schermata quando passi a un\'altra app, così non è visibile a colpo d\'occhio nel selettore app.';

  @override
  String get settingsHideSnapshotUnavailable =>
      'Nascondere i saldi nel selettore app non è disponibile su questa piattaforma.';

  @override
  String get settingsPayees => 'Beneficiari';

  @override
  String get settingsManagePayees => 'Gestisci beneficiari';

  @override
  String get settingsPayeesBlurb =>
      'Nomi dei beneficiari memorizzati con la loro categoria e conto predefiniti, suggeriti dal completamento automatico quando registri una transazione.';

  @override
  String get settingsRecurring => 'Modelli ricorrenti';

  @override
  String get settingsManageRecurring => 'Gestisci modelli ricorrenti';

  @override
  String get settingsRecurringBlurb =>
      'Bollette o entrate che si ripetono mensilmente, come l\'affitto o uno stipendio. Un modello in scadenza compare nella schermata Home per essere registrato con un tocco - non viene mai pubblicato automaticamente.';

  @override
  String get settingsAbout => 'Informazioni';

  @override
  String get settingsPrivacyPolicy => 'Informativa sulla privacy';

  @override
  String get settingsPrivacyPolicyOpenFailed =>
      'Impossibile aprire l\'informativa sulla privacy nel browser.';

  @override
  String get providerFrankfurter => 'Frankfurter (tassi BCE)';

  @override
  String get providerOpenErApi => 'ExchangeRate-API (open.er-api.com)';

  @override
  String get providerStooq => 'Stooq (quotazioni giornaliere)';

  @override
  String get providerYahooFinance => 'Yahoo Finance (API grafici)';

  @override
  String get researchChatGpt => 'ChatGPT';

  @override
  String get researchClaude => 'Claude';

  @override
  String get researchGemini => 'Gemini';

  @override
  String get researchMetaAi => 'Meta AI';

  @override
  String get systemGroupCashEquivalents => 'Liquidità e mezzi equivalenti';

  @override
  String get systemGroupPensionRetirement => 'Pensione e previdenza';

  @override
  String get systemGroupCreditShortTerm => 'Credito e debiti a breve termine';

  @override
  String get systemGroupLoansMortgages => 'Prestiti e mutui';

  @override
  String get systemGroupInvestments => 'Investimenti';

  @override
  String get systemAccountCashBank => 'Contanti e banca';

  @override
  String get systemCategorySalary => 'Stipendio';

  @override
  String get systemCategoryOtherIncome => 'Altre entrate';

  @override
  String get systemCategoryGroceries => 'Spesa alimentare';

  @override
  String get systemCategoryRentMortgage => 'Affitto/Mutuo';

  @override
  String get systemCategoryUtilities => 'Utenze';

  @override
  String get systemCategoryTransport => 'Trasporti';

  @override
  String get systemCategoryFoodOut => 'Ristoranti';

  @override
  String get systemCategoryPhone => 'Telefono';

  @override
  String get systemCategoryHealth => 'Salute';

  @override
  String get systemCategoryOtherExpense => 'Altre spese';

  @override
  String get systemDescriptionCsvImport => 'Importazione CSV';

  @override
  String get systemDescriptionOfxImport => 'Importazione OFX';

  @override
  String get homeThisMonth => 'QUESTO MESE';

  @override
  String get homeMoneyInTransit => 'DENARO IN TRANSITO';

  @override
  String get homeWhatYouHaveMinusWhatYouOwe =>
      'QUELLO CHE HAI MENO QUELLO CHE DEVI';

  @override
  String homeWhatYouHave(String amount, String currency) {
    return 'Quello che hai $amount $currency';
  }

  @override
  String homeNetPosition(String amount, String currency) {
    return '$amount $currency';
  }

  @override
  String homeHaveAndOwe(String haveAmount, String currency, String oweAmount) {
    return 'Quello che hai $haveAmount $currency  •  Quello che devi $oweAmount $currency';
  }

  @override
  String youSentFrom(String amount, String currency, String name) {
    return 'Hai inviato $amount $currency da $name';
  }

  @override
  String youSentTo(String amount, String currency, String name) {
    return 'Hai inviato $amount $currency a $name';
  }

  @override
  String get hiddenLabel => 'Nascosto';

  @override
  String get allAccounts => 'Tutti i conti';

  @override
  String savedToPath(String path) {
    return 'Salvato in $path';
  }

  @override
  String get homeTapWhenArrived => 'Tocca quando sai cosa è arrivato';

  @override
  String homeReturnedTo(String name) {
    return 'Restituito a $name';
  }

  @override
  String get homeDueToday => 'IN SCADENZA OGGI';

  @override
  String homeDueLine(String category, String account) {
    return '$category · $account · tocca per registrare';
  }

  @override
  String get homeOverLimit => 'Oltre il limite';

  @override
  String homeSpentOfLimit(String spent, String limit) {
    return '$spent di $limit';
  }

  @override
  String homeRemaining(String amount) {
    return 'Rimanente: $amount';
  }

  @override
  String get homeNoAccounts => 'Nessun conto';

  @override
  String get homeCashRegister => 'Registratore di cassa';

  @override
  String get homeMarketEstimate => 'Stima di mercato';

  @override
  String get registerTitle => 'Registro';

  @override
  String get registerSearchHint => 'Descrizione, categoria o importo';

  @override
  String get registerNoTransactions => 'Ancora nessuna transazione';

  @override
  String get registerNoEntries => 'Ancora nessuna voce registrata.';

  @override
  String get registerSpentOnly => 'Solo speso';

  @override
  String get registerReceivedOnly => 'Solo ricevuto';

  @override
  String get registerAll => 'Tutti';

  @override
  String get registerUnverified => 'Non verificato - escluso dai totali';

  @override
  String get registerSuperseded =>
      'Sostituito dalla migrazione - escluso dai totali';

  @override
  String get summaryTitle => 'Riepilogo';

  @override
  String get summaryTotalIncome => 'Entrate totali';

  @override
  String get summaryTotalExpense => 'Spese totali';

  @override
  String summaryDateRange(String start, String end) {
    return '$start - $end';
  }

  @override
  String get accountsTitle => 'Conti';

  @override
  String get categoriesTitle => 'Categorie';

  @override
  String get accountName => 'Nome del conto';

  @override
  String get createAccount => 'Crea conto';

  @override
  String get createGroup => 'Crea gruppo';

  @override
  String get editGroup => 'Modifica gruppo';

  @override
  String get renameAccount => 'Rinomina conto';

  @override
  String get renameCategory => 'Rinomina categoria';

  @override
  String get addCategory => 'Aggiungi categoria';

  @override
  String get groupLabel => 'Gruppo';

  @override
  String get kindLabel => 'Tipo';

  @override
  String get asset => 'Attività';

  @override
  String get liability => 'Passività';

  @override
  String get income => 'Entrata';

  @override
  String get expense => 'Spesa';

  @override
  String get thisAccountHoldsInvestments =>
      'Questo conto contiene investimenti';

  @override
  String get thisAccountHoldsInvestmentsSubtitle =>
      'Liquidità più l\'inventario che registri con Compra, Vendi e Dividendo.';

  @override
  String get thisIsACreditCard => 'Questa è una carta di credito';

  @override
  String get openingBalanceOptional => 'Saldo iniziale (opzionale)';

  @override
  String get currencyIso => 'Valuta (ISO 4217)';

  @override
  String get currencyIsoExample => 'Valuta (ISO 4217, es. USD)';

  @override
  String get hideAccountTitle => 'Nascondere il conto dalle nuove voci?';

  @override
  String get hideCategoryTitle => 'Nascondere la categoria dalle nuove voci?';

  @override
  String get hideGroupTitle => 'Nascondere il gruppo dalle nuove voci?';

  @override
  String get reassignGroup => 'Riassegna gruppo';

  @override
  String get transferRemainingBalance => 'Trasferisci il saldo rimanente';

  @override
  String get monthlyLimit => 'Limite mensile';

  @override
  String get monthlyLimitHint => 'Limite (lascia vuoto per rimuovere)';

  @override
  String get monthlyLimitBlurb =>
      'Una guida di spesa opzionale, calcolata da inizio mese, per questa categoria di spesa.';

  @override
  String get translateCategoryWithAi => 'Traduci con l\'IA';

  @override
  String get addCategoryTranslation => 'Aggiungi traduzione';

  @override
  String get categoryTranslationLocale => 'Lingua';

  @override
  String get categoryTranslationName => 'Nome tradotto';

  @override
  String get mergeCategories => 'Unisci categorie';

  @override
  String get mergeCategoriesSuggested =>
      'Queste categorie sembrano uguali. Unirle?';

  @override
  String get categoryDefaultLanguage =>
      'Lingua predefinita per i nomi delle categorie';

  @override
  String get categoryDefaultLanguageSubtitle =>
      'Condivisa tra i dispositivi collegati. Ogni dispositivo mostra comunque la propria lingua quando esiste una traduzione.';

  @override
  String get manageCategoryRules => 'Gestisci regole di categoria';

  @override
  String get amount => 'Importo';

  @override
  String get category => 'Categoria';

  @override
  String get account => 'Conto';

  @override
  String get fromAccount => 'Conto di origine';

  @override
  String get toAccount => 'Conto di destinazione';

  @override
  String get descriptionOptional => 'Descrizione (opzionale)';

  @override
  String get alsoRememberPayee => 'Ricorda anche come beneficiario';

  @override
  String get splitIntoCategories => 'Dividi in più categorie';

  @override
  String categoryN(String n) {
    return 'Categoria $n';
  }

  @override
  String get destinationAmount => 'Importo di destinazione';

  @override
  String get destinationAmountOptional => 'Importo di destinazione (opzionale)';

  @override
  String get accountCurrencyAmountOptional =>
      'Importo nella valuta del conto (opzionale)';

  @override
  String get transactionCurrencyOptional =>
      'Valuta della transazione (opzionale)';

  @override
  String get feeOptional => 'Commissione (opzionale)';

  @override
  String get feeAmount => 'Importo della commissione';

  @override
  String get feeCategory => 'Categoria della commissione';

  @override
  String get feeDescriptionOptional =>
      'Descrizione della commissione (opzionale)';

  @override
  String get feeDeducted => 'La commissione viene dedotta dall\'importo sopra';

  @override
  String get needTwoAccountsToTransfer =>
      'Crea almeno due conti attivi per effettuare un trasferimento.';

  @override
  String get whatArrivedTitle => 'Cosa è arrivato?';

  @override
  String get whatArrivedBlurb => 'Dicci cosa è arrivato effettivamente.';

  @override
  String get amountThatArrived => 'Importo arrivato';

  @override
  String get feeLossCategory => 'Categoria di commissione / perdita';

  @override
  String get alreadySettled => 'Già saldato.';

  @override
  String get holdingsTitle => 'Posizioni';

  @override
  String get holdingsCash => 'Liquidità';

  @override
  String get holdingsInventory => 'INVENTARIO';

  @override
  String holdingsBook(String amount, String currency) {
    return 'Contabile (liquidità + costo) $amount $currency';
  }

  @override
  String holdingsMarketEstimate(String amount, String currency) {
    return 'Stima di mercato $amount $currency';
  }

  @override
  String get holdingsNoHoldings =>
      'Ancora nessuna posizione. Registra un acquisto per aggiungere uno strumento.';

  @override
  String get holdingsQuotesBlurb =>
      'Le quotazioni sono stime, non un prezzo del broker. Questa app non inoltra ordini.';

  @override
  String get holdingsTapNameToResearch =>
      'Tocca il nome per la ricerca. Le quotazioni sono stime, non consulenza.';

  @override
  String get instrument => 'Strumento';

  @override
  String get newInstrument => 'Nuovo strumento';

  @override
  String get renameInstrument => 'Rinomina strumento';

  @override
  String get instrumentActions => 'Azioni sullo strumento';

  @override
  String hideInstrumentTitle(String name) {
    return 'Nascondere $name?';
  }

  @override
  String get tickerOptional => 'Ticker (opzionale)';

  @override
  String get isinOptional => 'ISIN (opzionale)';

  @override
  String get quantity => 'Quantità';

  @override
  String get unitPrice => 'Prezzo unitario';

  @override
  String get brokerageOptional => 'Commissione di intermediazione (opzionale)';

  @override
  String get brokerageExpenseCategory =>
      'Categoria di spesa per l\'intermediazione';

  @override
  String get incomeCategory => 'Categoria di entrata';

  @override
  String get gainIncomeCategory => 'Categoria di entrata per plusvalenza';

  @override
  String get lossExpenseCategory => 'Categoria di spesa per minusvalenza';

  @override
  String get nonCash => 'Non monetario';

  @override
  String get cash => 'Liquidità';

  @override
  String get locked => 'Bloccato';

  @override
  String get lockUntilHint =>
      'Una tua nota personale su una restrizione, non una regola del broker.';

  @override
  String get instrumentKindStock => 'Azione';

  @override
  String get instrumentKindEtf => 'ETF';

  @override
  String get instrumentKindMutualFund => 'Fondo comune';

  @override
  String get instrumentKindBond => 'Obbligazione';

  @override
  String get instrumentKindOther => 'Altro';

  @override
  String get quoteUseLive => 'Prezzo in tempo reale';

  @override
  String get quoteUseCached => 'Prezzo in cache';

  @override
  String get quoteUseStale => 'Prezzo non aggiornato';

  @override
  String get quoteUseMissing => 'Uso il costo (nessun prezzo)';

  @override
  String get quoteUseDisabled => 'Quotazioni disattivate — uso costo/cache';

  @override
  String get quoteUseCurrencyMismatch =>
      'Uso il costo (valuta del prezzo diversa)';

  @override
  String unrealizedLabel(String amount, String currency) {
    return 'Non realizzato $amount $currency';
  }

  @override
  String holdingsUnitsCost(String qty) {
    return '$qty unità · ';
  }

  @override
  String get chooseLanguageTitle => 'Scegli la tua lingua';

  @override
  String get chooseLanguageBlurb =>
      'Tutto nell\'app verrà mostrato in questa lingua. Potrai cambiarla più tardi nelle Impostazioni.';

  @override
  String get chooseCurrencyTitle => 'Scegli la tua valuta';

  @override
  String get chooseCurrencyBlurb =>
      'Per ora ogni gruppo di conti (Liquidità e mezzi equivalenti, Pensione e previdenza, ecc.) usa questa unica valuta. Potrai comunque aggiungere conti in una valuta diversa in seguito, creando un nuovo gruppo per essa.';

  @override
  String get currencyBackfillTitle =>
      'Scegli una valuta per i gruppi esistenti';

  @override
  String get currencyBackfillBlurb =>
      'Questa app ora supporta più valute. I tuoi conti e gruppi di conti esistenti hanno bisogno di una valuta - poiché sono stati tutti creati prima che questa funzione esistesse, si applica un\'unica scelta a tutti.';

  @override
  String get firstAccountTitle => 'Dai un nome al tuo conto';

  @override
  String get firstAccountBlurb =>
      'Questo è il conto già impostato per te - dagli un nome che riconosci, come la tua banca. Registrerai una voce di Speso o Ricevuto, poi proteggerai il dispositivo con la tua frase di recupero.';

  @override
  String get whatsMainAccountCalled =>
      'Come si chiama il tuo conto principale?';

  @override
  String get setupChoiceTitle => 'Benvenuto in Smara Contabilità';

  @override
  String get setupChoiceBlurb =>
      'Inizi da zero o arrivi da un altro dispositivo?';

  @override
  String get actionNewSetup => 'Nuova configurazione';

  @override
  String get continueBooksTitle => 'Continua i miei libri su questo telefono';

  @override
  String get continueBooksBlurb =>
      'Questi libri sono arrivati su questo telefono senza la loro chiave di firma. Puoi continuarli con una nuova chiave per questo telefono oppure ripristinare da una copia salvata.';

  @override
  String get continueBooksAction => 'Continua i miei libri su questo telefono';

  @override
  String get restoreFromCopyAction => 'Ripristina da una copia';

  @override
  String get saveBooksCopyAction => 'Salva una copia dei miei libri';

  @override
  String get deviceHistoryTitle => 'Cronologia dispositivo';

  @override
  String get deviceHistoryEmpty =>
      'Nessuna continuazione per ora. Quando continuerai i libri su un nuovo telefono, appariranno qui.';

  @override
  String deviceHistoryContinuedOn(String date) {
    return 'I tuoi libri sono continuati su questo telefono il $date';
  }

  @override
  String deviceHistoryContinuedFromCopy(String continuedDate, String copyDate) {
    return 'I tuoi libri sono continuati su questo telefono il $continuedDate (da una copia salvata il $copyDate)';
  }

  @override
  String get backupReminderBannerTitle => 'Salva una copia dei tuoi libri';

  @override
  String get backupReminderSaveAction => 'Salva una copia';

  @override
  String get backupReminderLaterAction => 'Più tardi';

  @override
  String get settingsBackupReminder => 'Promemoria copia';

  @override
  String get settingsBackupReminderBlurb =>
      'Ti ricorderemo con discrezione di salvare una copia dei tuoi libri dopo un po\' di tempo o dopo molte nuove registrazioni. Una copia salvata è l\'unico modo per recuperare i libri se perdi questo telefono.';

  @override
  String get settingsBackupReminderEnabled => 'Ricordami di salvare una copia';

  @override
  String get settingsBackupReminderDays => 'Ricorda dopo questi giorni';

  @override
  String get settingsBackupReminderEntries =>
      'Ricorda dopo queste nuove registrazioni';

  @override
  String get settingsBackupReminderSnoozeDays =>
      'Nascondi per questi giorni dopo «Più tardi»';

  @override
  String get settingsBackupReminderSnoozeEntries =>
      'Nascondi per queste nuove registrazioni dopo «Più tardi»';

  @override
  String get settingsBooksSwitcher => 'Libri su questo dispositivo';

  @override
  String get settingsBooksSwitcherBlurb =>
      'Ogni set di libri ha la propria chiave di firma e cronologia. Cambiando si apre quel set — Home e Registro mostrano solo le sue voci.';

  @override
  String get settingsBooksSwitcherActive => 'Aperto ora';

  @override
  String get settingsBooksSwitcherSwitch => 'Cambia';

  @override
  String get settingsBooksSwitcherCreate => 'Nuovi libri';

  @override
  String get settingsBooksSwitcherCreateTitle => 'Dai un nome a questi libri';

  @override
  String get settingsBooksSwitcherNameLabel => 'Nome';

  @override
  String get settingsBooksSwitcherRemoveTitle => 'Rimuovere questi libri?';

  @override
  String settingsBooksSwitcherRemoveBody(String name) {
    return 'Questo elimina \"$name\" da questo dispositivo, inclusa la chiave di firma. Gli altri libri su questo dispositivo non vengono interessati.';
  }

  @override
  String get settingsBooksSwitcherRemoveConfirm => 'Rimuovi';

  @override
  String settingsBooksSwitcherFallbackName(int number) {
    return 'Libri $number';
  }

  @override
  String get settingsLinkedDevices => 'Dispositivi collegati';

  @override
  String get settingsLinkedDevicesCatchUp =>
      'I tuoi dispositivi si aggiornano quando entrambi hanno Smara aperto sulla stessa Wi-Fi.';

  @override
  String get settingsLinkedDevicesPermissionSentence =>
      'Per condividere i tuoi libri, Smara deve trovare i tuoi altri dispositivi su questa Wi-Fi. Nulla va su Internet.';

  @override
  String get settingsLinkedDevicesAddDevice => 'Aggiungi un dispositivo';

  @override
  String get settingsLinkedDevicesContinue => 'Continua';

  @override
  String get settingsLinkedDevicesRoleOwner => 'Proprietario';

  @override
  String get settingsLinkedDevicesRoleMember => 'Membro';

  @override
  String get settingsLinkedDevicesCanAdd => 'Può aggiungere dispositivi';

  @override
  String get settingsLinkedDevicesErasePending => 'Cancellazione in sospeso';

  @override
  String settingsLinkedDevicesErasedOn(String date) {
    return 'Cancellato il $date';
  }

  @override
  String get settingsLinkedDevicesSuggestSecondOwner =>
      'Questi libri hanno un solo Proprietario. Considera di rendere Proprietario anche un altro dispositivo collegato.';

  @override
  String get settingsLinkedDevicesJoinSameWifi =>
      'Entrambi i dispositivi devono essere sulla stessa Wi-Fi. Smara non si unisce via Internet.';

  @override
  String get settingsLinkedDevicesApproveJoin => 'Approva';

  @override
  String get settingsLinkedDevicesRefuseJoin => 'Rifiuta';

  @override
  String settingsLinkedDevicesPendingJoin(String name) {
    return '$name vuole unirsi a questi libri';
  }

  @override
  String get settingsLinkedDevicesEmpty =>
      'Finora è collegato solo questo dispositivo.';

  @override
  String get settingsLinkedDevicesSyncNow => 'Sincronizza ora';

  @override
  String get settingsLinkedDevicesSyncNowBusy => 'Aggiornamento…';

  @override
  String get settingsLinkedDevicesJoinCheckCode =>
      'Codice di controllo — conferma che corrisponde sullaltro dispositivo';

  @override
  String get settingsLinkedDevicesScanQr => 'Scansiona QR di unione';

  @override
  String get settingsLinkedDevicesConfirmCheckCodeTitle =>
      'Conferma codice di controllo';

  @override
  String get settingsLinkedDevicesConfirmCheckCodeBody =>
      'Questo codice corrisponde a quello sullaltro dispositivo?';

  @override
  String get settingsLinkedDevicesCodesMatch => 'I codici corrispondono';

  @override
  String get settingsLinkedDevicesCodesDontMatch => 'Non corrispondono';

  @override
  String get settingsLinkedDevicesJoinExpired =>
      'Questo QR di unione è scaduto. Chiedi un nuovo codice.';

  @override
  String get settingsLinkedDevicesJoinReused =>
      'Questo QR di unione è già stato usato. Chiedi un nuovo codice.';

  @override
  String get settingsLinkedDevicesJoinCodeLabel => 'Codice di unione';

  @override
  String settingsLinkedDevicesJoinCodeTimeLeft(int minutes, String seconds) {
    return '$minutes:$seconds rimasti';
  }

  @override
  String get settingsLinkedDevicesEnterCodeInstead =>
      'Inserisci invece il codice';

  @override
  String get settingsLinkedDevicesEnterCodeTitle =>
      'Inserisci codice di unione';

  @override
  String get settingsLinkedDevicesEnterCodeHint => 'XXXX-XXXX';

  @override
  String get settingsLinkedDevicesEnterCodeSubmit => 'Trova dispositivo';

  @override
  String get settingsLinkedDevicesJoinCodeExpired =>
      'Questo codice è scaduto — chiedine uno nuovo';

  @override
  String get settingsLinkedDevicesJoinCodeUsed =>
      'Questo codice è già stato usato. Chiedine uno nuovo.';

  @override
  String get settingsLinkedDevicesJoinCodeNotFound =>
      'Nessun dispositivo con questo codice su questo Wi-Fi';

  @override
  String get settingsLinkedDevicesJoinCodeTryAgain => 'Riprova';

  @override
  String get settingsLinkedDevicesConnectByAddress =>
      'Connetti tramite indirizzo';

  @override
  String get settingsLinkedDevicesConnectByAddressTitle =>
      'Connetti tramite indirizzo';

  @override
  String get settingsLinkedDevicesConnectByAddressBody =>
      'Quando lindividuazione non trova un dispositivo collegato, inserisci indirizzo LAN e porta.';

  @override
  String get settingsLinkedDevicesHost => 'Host';

  @override
  String get settingsLinkedDevicesPort => 'Porta';

  @override
  String get settingsLinkedDevicesPeer => 'Dispositivo';

  @override
  String get settingsLinkedDevicesSaveAddress => 'Salva indirizzo';

  @override
  String membershipNoticeDeviceAdded(String name) {
    return 'È stato aggiunto un dispositivo: $name';
  }

  @override
  String membershipNoticeDeviceRemoved(String name) {
    return 'È stato rimosso un dispositivo: $name';
  }

  @override
  String membershipNoticeErasePending(String name) {
    return 'Cancellazione in sospeso per $name';
  }

  @override
  String membershipNoticeErased(String name, String date) {
    return 'Cancellato $name il $date';
  }

  @override
  String membershipNoticeSoleOwnerClaimed(String name) {
    return '$name ha rivendicato la proprietà esclusiva';
  }

  @override
  String membershipNoticeSoleOwnerCancelled(String name) {
    return 'La rivendicazione di Proprietario unico per $name è stata annullata';
  }

  @override
  String membershipNoticeSoleOwnerEffective(String name) {
    return '$name è ora Proprietario';
  }

  @override
  String membershipNoticeEntryNotAccepted(String name) {
    return 'Non accettata: non è stato possibile verificarla (da $name)';
  }

  @override
  String membershipNoticeOwnerVerificationAlert(String name) {
    return 'Un record di $name non è stato verificato e non è stato accettato';
  }

  @override
  String get membershipNoticeCompetingFixCheck =>
      'Due Correzioni per la stessa voce sono state risolte — controlla';

  @override
  String get whyWeDontEdit => 'Perché non modifichiamo le voci precedenti';

  @override
  String get whyWeDontEditBody =>
      'Quando correggi un errore, manteniamo la vecchia riga e aggiungiamo una correzione accanto ad essa, invece di modificare quello che hai già inserito. In questo modo la tua cronologia mostra sempre esattamente cosa è successo e quando lo hai corretto — nulla cambia silenziosamente alle tue spalle.';

  @override
  String get lockTitle => 'Sblocca';

  @override
  String get lockScreenTitle => 'Bloccato';

  @override
  String get enterPinToContinue => 'Inserisci il tuo PIN per continuare';

  @override
  String get pinLabel => 'PIN';

  @override
  String get setPinTitle => 'Imposta un PIN';

  @override
  String get currentPin => 'PIN attuale';

  @override
  String get newPin => 'Nuovo PIN';

  @override
  String get confirmPin => 'Conferma PIN';

  @override
  String get confirmNewPin => 'Conferma nuovo PIN';

  @override
  String get firstWeekTitle => 'Configura i tuoi conti';

  @override
  String get addCashAccount => 'Aggiungi un conto in contanti';

  @override
  String get addCreditCard => 'Aggiungi una carta di credito';

  @override
  String get cashAccountName => 'Nome del conto in contanti';

  @override
  String get cardName => 'Nome della carta';

  @override
  String get paidFromBank => 'Pagato dalla banca';

  @override
  String get paidFromCard => 'Pagato dalla carta';

  @override
  String get choosePassphraseTitle =>
      'Scegli una passphrase per proteggere questo backup. Non c\'è modo di recuperarla se la dimentichi.';

  @override
  String get replaceBooksTitle => 'Sostituire i tuoi libri contabili locali?';

  @override
  String get replaceBooksBody =>
      'Questo sostituisce tutto ciò che è attualmente in questa app con il backup. Chiudi e riapri l\'app in seguito.';

  @override
  String get chooseBackupFileFirst => 'Scegli prima un file di backup.';

  @override
  String get backupRestored => 'Backup ripristinato';

  @override
  String get backupRestoredBody =>
      'I tuoi libri contabili sono stati ripristinati. Chiudi e riapri l\'app per continuare.';

  @override
  String get fixThisEntry => 'Correggi questa voce';

  @override
  String get fixBlurb =>
      'La vecchia riga resta esattamente com\'era. Confermando si aggiunge una riga di storno e quella corretta.';

  @override
  String get importStatementTitle => 'Importa estratto conto';

  @override
  String get importOfx => 'Importa OFX';

  @override
  String get importOfxQfxFile => 'Importa file OFX / QFX';

  @override
  String get importCsvFile => 'Importa file CSV';

  @override
  String get whatKindOfStatement => 'Che tipo di file di estratto conto hai?';

  @override
  String get chooseAccountForFile =>
      'Scegli a quale conto appartiene questo file.';

  @override
  String get importIntoAccount => 'Importa nel conto';

  @override
  String get useSavedProfile => 'Usa un profilo salvato';

  @override
  String get saveMappingProfile =>
      'Salva questa mappatura come profilo (opzionale)';

  @override
  String get renameProfile => 'Rinomina profilo';

  @override
  String get deleteProfileTitle => 'Eliminare il profilo?';

  @override
  String get fileHasHeader => 'Il file ha una riga di intestazione';

  @override
  String get dateColumn => 'Colonna della data';

  @override
  String get dateFormatHint => 'Formato della data (es. gg/MM/aaaa)';

  @override
  String get amountColumn => 'Colonna dell\'importo';

  @override
  String get amountConvention => 'Convenzione dell\'importo';

  @override
  String get signedAmountColumn => 'Colonna dell\'importo con segno';

  @override
  String get separateDebitCredit => 'Colonne separate per dare / avere';

  @override
  String get debitColumn => 'Colonna dare';

  @override
  String get creditColumn => 'Colonna avere';

  @override
  String get decimalSeparator => 'Separatore decimale (. o ,)';

  @override
  String get descriptionColumns => 'Colonna/e della descrizione';

  @override
  String get referenceIdColumn => 'Colonna dell\'ID di riferimento (opzionale)';

  @override
  String get skippedRows => 'Righe saltate';

  @override
  String parsedTransactionCount(String count) {
    return '$count transazioni analizzate';
  }

  @override
  String skippedOrExcludedCount(String count) {
    return '$count saltate o escluse';
  }

  @override
  String postedFailedCount(String posted, String failed) {
    return '$posted registrate, $failed non riuscite';
  }

  @override
  String get categoryForAll => 'Categoria per tutti';

  @override
  String get saveAsRule => 'Salvare come regola?';

  @override
  String get saveAsRuleBlurb =>
      'Le future importazioni la cui descrizione contiene questa parola chiave useranno questa categoria.';

  @override
  String get keyword => 'Parola chiave';

  @override
  String get noSavedRules =>
      'Nessuna regola salvata. Assegna una categoria a un gruppo di righe per salvare una regola.';

  @override
  String get deleteRuleTitle => 'Eliminare la regola?';

  @override
  String get editRule => 'Modifica regola';

  @override
  String rowsGrouped(String count) {
    return '$count righe';
  }

  @override
  String selectStatementFile(String extensions) {
    return 'Seleziona un file di estratto conto $extensions da importare';
  }

  @override
  String get payeesTitle => 'Beneficiari';

  @override
  String get addPayee => 'Aggiungi beneficiario';

  @override
  String get renamePayee => 'Rinomina beneficiario';

  @override
  String get deletePayeeTitle => 'Eliminare il beneficiario?';

  @override
  String get noPayeesYet => 'Ancora nessun beneficiario';

  @override
  String get recurringTitle => 'Modelli ricorrenti';

  @override
  String get noRecurringYet => 'Ancora nessun modello ricorrente';

  @override
  String get deleteTemplateTitle => 'Eliminare il modello ricorrente?';

  @override
  String get dayOfMonth => 'Giorno del mese (1-31)';

  @override
  String get dayOfMonthNote =>
      'Un mese con meno giorni usa il proprio ultimo giorno.';

  @override
  String dayOfMonthLine(String day) {
    return 'Giorno $day del mese - ';
  }

  @override
  String get name => 'Nome';

  @override
  String get none => 'Nessuno';

  @override
  String get currency => 'Valuta';

  @override
  String get errorGeneric => 'Qualcosa è andato storto. Riprova.';

  @override
  String get errorInvalidLedgerBackup =>
      'Questo file non è un backup Smara valido.';

  @override
  String get errorInvalidLedgerBackupNoIdentity =>
      'Questo backup non ha un\'identità di firma - non è un backup Smara valido.';

  @override
  String get errorInvalidLedgerBackupUnverified =>
      'Questo backup non è stato verificato come libri contabili integri, quindi non è stato ripristinato.';

  @override
  String errorInvalidLedgerBackupUnreadable(String detail) {
    return 'Non è stato possibile aprire questo file come backup Smara: $detail';
  }

  @override
  String get errorAccountNotFinancial => 'Quello non è un conto finanziario.';

  @override
  String get errorAccountArchived => 'Quel conto è nascosto.';

  @override
  String get errorAccountNotArchived => 'Quel conto non è nascosto.';

  @override
  String get errorAccountNoPositiveBalanceToCloseOut =>
      'Non c\'è un saldo residuo da trasferire.';

  @override
  String get errorAccountHasNoGroup => 'Quel conto non ha un gruppo assegnato.';

  @override
  String get errorGroupHasNoCurrency =>
      'Quel gruppo non ha ancora una valuta impostata.';

  @override
  String get errorGroupNotFound => 'Quel gruppo di conti non è stato trovato.';

  @override
  String get errorInvestmentAccountsMustBeAssets =>
      'Solo i conti di tipo attività possono essere contrassegnati come conti di investimento.';

  @override
  String get errorCreditCardsMustBeLiabilities =>
      'Solo i conti di tipo passività possono essere contrassegnati come carte di credito.';

  @override
  String get errorOpeningBalanceMustBePositive =>
      'Il saldo iniziale deve essere positivo, se fornito.';

  @override
  String get errorAccountTypeDoesNotMatchGroup =>
      'Il tipo di conto non corrisponde al gruppo.';

  @override
  String get errorLastActiveAccount =>
      'Non è possibile nascondere l\'ultimo conto finanziario attivo.';

  @override
  String get errorCurrencyRequiredToCreateGroup =>
      'La valuta è obbligatoria per creare un gruppo.';

  @override
  String get errorSystemGroupCannotBeArchived =>
      'I gruppi di conti predefiniti non possono essere nascosti.';

  @override
  String get errorGroupAlreadyArchived => 'Quel gruppo è già nascosto.';

  @override
  String get errorCannotArchiveGroupWithAccounts =>
      'Non è possibile nascondere un gruppo che ha ancora conti attivi.';

  @override
  String get errorSystemGroupNeverArchived =>
      'I gruppi di conti predefiniti non vengono mai nascosti.';

  @override
  String get errorAccountGroupsCannotBeDeleted =>
      'I gruppi di conti non possono essere eliminati.';

  @override
  String get errorCannotReassignDifferentCurrency =>
      'Non è possibile spostare questo conto in un gruppo con una valuta diversa.';

  @override
  String get errorCannotChangeGroupCurrencyWithAccounts =>
      'Non è possibile cambiare la valuta mentre il gruppo ha conti attivi.';

  @override
  String get errorAmountMustBePositive => 'L\'importo deve essere positivo.';

  @override
  String get errorAccountCurrencyAmountMustBePositive =>
      'L\'importo nella valuta del conto deve essere positivo.';

  @override
  String get errorAccountCurrencyAmountNotForSameCurrency =>
      'L\'importo nella valuta del conto vale solo per una voce in valuta estera.';

  @override
  String get errorSplitNeedsTwoLines =>
      'Una suddivisione richiede almeno due righe di categoria.';

  @override
  String get errorSplitLineMustBePositive =>
      'Ogni riga della suddivisione deve avere un importo positivo.';

  @override
  String get errorSplitLinesMustSumToTotal =>
      'Le righe della suddivisione devono sommarsi al totale della transazione.';

  @override
  String get errorTransferAmountMustBePositive =>
      'L\'importo del trasferimento deve essere positivo.';

  @override
  String get errorTransferAccountsMustDiffer =>
      'Il conto di origine e quello di destinazione devono essere diversi.';

  @override
  String get errorCloseoutRequiresDestinationAmount =>
      'Una chiusura tra valute diverse richiede un importo di destinazione noto.';

  @override
  String get errorDestinationAmountNotForSameCurrency =>
      'L\'importo di destinazione vale solo per un trasferimento tra valute diverse.';

  @override
  String get errorDestinationAmountMustBePositive =>
      'L\'importo di destinazione deve essere positivo.';

  @override
  String get errorInvestmentCashExceeded =>
      'Non è possibile trasferire più della liquidità di questo conto di investimento.';

  @override
  String get errorCannotReverseUnsettledProvisional =>
      'Salda questo trasferimento in sospeso invece di stornarlo.';

  @override
  String get errorAlreadyReversed =>
      'Questa voce è già stata corretta. La riga originale resta com\'è.';

  @override
  String get errorNotActiveExpenseCategory =>
      'Scegli una categoria di spesa attiva.';

  @override
  String get errorNotActiveIncomeCategory =>
      'Scegli una categoria di entrata attiva.';

  @override
  String get errorSettledAmountMustNotBeNegative =>
      'L\'importo arrivato non può essere negativo.';

  @override
  String get errorPendingTransferNotFound =>
      'Quel trasferimento in sospeso non è stato trovato.';

  @override
  String get errorPendingTransferAlreadySettled =>
      'Quel trasferimento in sospeso è già saldato.';

  @override
  String get errorSettledToMustBeSourceOrDestination =>
      'Scegli il conto di origine o di destinazione originale.';

  @override
  String get errorFeeCategoryOnlyWhenReturningToSource =>
      'Una categoria di commissione si usa solo quando il denaro torna al conto di origine.';

  @override
  String get errorSettledAmountMustBePositiveForDelivery =>
      'Inserisci un importo positivo per ciò che è arrivato.';

  @override
  String get errorSettledAmountExceedsProvisional =>
      'Quell\'importo è superiore a quanto è stato inviato.';

  @override
  String get errorInstrumentNotFound => 'Quello strumento non è stato trovato.';

  @override
  String get errorIncomeRequiredForNonCash =>
      'È richiesta una categoria di entrata attiva per un\'acquisizione non monetaria.';

  @override
  String get errorInsufficientCash =>
      'Liquidità insufficiente in questo conto di investimento per quell\'acquisto.';

  @override
  String get errorSellQuantityAndPriceMustBePositive =>
      'La quantità e il prezzo unitario di vendita devono essere positivi.';

  @override
  String errorLockedUntil(String date) {
    return 'Impossibile vendere: alcune unità sono bloccate fino al $date.';
  }

  @override
  String get errorInsufficientQuantity =>
      'Non è possibile vendere più di quanto attualmente detieni sbloccato.';

  @override
  String get errorIncomeRequiredForGain =>
      'È richiesta una categoria di entrata attiva per una plusvalenza realizzata.';

  @override
  String get errorExpenseRequiredForLoss =>
      'È richiesta una categoria di spesa attiva per una minusvalenza realizzata.';

  @override
  String errorBrokerageFailedAfterBuy(String detail) {
    return 'Acquisto registrato, ma la commissione di intermediazione non è riuscita: $detail';
  }

  @override
  String errorBrokerageFailedAfterSell(String detail) {
    return 'Vendita registrata, ma la commissione di intermediazione non è riuscita: $detail';
  }

  @override
  String get errorDividendMustBePositive =>
      'L\'importo del dividendo deve essere positivo.';

  @override
  String get errorNotInvestmentAccount =>
      'Quello non è un conto di investimento.';

  @override
  String get errorNoInventoryCompanion =>
      'A questo conto di investimento manca il suo inventario abbinato.';

  @override
  String errorInvestmentReversalBlocked(String sells) {
    return 'Impossibile stornare questo acquisto: vendite successive dipendono dalle sue unità. Storna prima le vendite dipendenti: $sells.';
  }

  @override
  String get errorMonthlyLimitMustBePositive =>
      'Il limite mensile deve essere positivo.';

  @override
  String get errorTemplateAmountMustBePositive =>
      'L\'importo del modello deve essere positivo.';

  @override
  String get errorOfxUnrecognized =>
      'Non è stato possibile riconoscere questo file come OFX.';

  @override
  String get errorCsvEmpty => 'Il file selezionato è vuoto.';

  @override
  String get errorCsvUnreadable =>
      'Non è stato possibile leggere questo file come CSV.';

  @override
  String get errorCsvNoRows => 'Il file selezionato non ha righe.';

  @override
  String get skipMissingDate => 'Data mancante.';

  @override
  String skipUnparseableDate(String raw, String pattern) {
    return 'Impossibile interpretare la data \"$raw\" con il modello \"$pattern\".';
  }

  @override
  String get skipOfxMissingOrInvalidDate =>
      'Data della transazione mancante o non valida.';

  @override
  String skipOfxUnparseableDate(String raw) {
    return 'Impossibile interpretare la data della transazione \"$raw\".';
  }

  @override
  String get skipMissingAmount => 'Importo mancante.';

  @override
  String skipUnparseableAmount(String raw) {
    return 'Impossibile interpretare l\'importo \"$raw\".';
  }

  @override
  String get skipZeroAmount => 'L\'importo è zero.';

  @override
  String get skipUnparseableDebitCreditAmount =>
      'Impossibile interpretare l\'importo di addebito o accredito.';

  @override
  String get skipBothDebitAndCreditNonZero =>
      'Le colonne addebito e accredito hanno entrambe un importo.';

  @override
  String get skipBothDebitAndCreditZero =>
      'Le colonne addebito e accredito sono entrambe zero.';

  @override
  String errorBackupCreateFailed(String detail) {
    return 'Non è stato possibile creare il backup: $detail';
  }

  @override
  String get errorBackupRestoreFailed =>
      'Non è stato possibile ripristinare questo backup - passphrase errata, oppure non è un file di backup Smara.';

  @override
  String get validationAmountAccountCategoryRequired =>
      'Importo, conto e categoria sono obbligatori.';

  @override
  String get validationAmountAccountRequired =>
      'Importo e conto sono obbligatori.';

  @override
  String get validationSplitLineIncomplete =>
      'Ogni riga della suddivisione richiede una categoria e un importo.';

  @override
  String get validationSplitSumMismatch =>
      'Le righe della suddivisione devono sommarsi al totale della transazione.';

  @override
  String get validationFromToAmountRequired =>
      'Conto di origine, conto di destinazione e importo sono obbligatori.';

  @override
  String get validationAmountArrivedRequired =>
      'L\'importo arrivato è obbligatorio.';

  @override
  String get validationChooseReceivingAccount =>
      'Scegli quale conto ha ricevuto i fondi.';

  @override
  String get validationAccountCategoryRequired =>
      'Conto e categoria sono obbligatori.';

  @override
  String get validationFixFailed =>
      'Non è stato possibile salvare questa correzione.';

  @override
  String get validationNameRequired => 'Dai un nome al tuo conto principale.';

  @override
  String get validationStillLoading =>
      'Ancora in caricamento - riprova tra un momento.';

  @override
  String get validationSaveAccountNameFailed =>
      'Non è stato possibile salvare il nome del conto.';

  @override
  String get validationWrongPin => 'PIN errato. Riprova.';

  @override
  String get validationCategoryMustBeIncomeOrExpense =>
      'La categoria deve essere Entrata o Spesa.';

  @override
  String get validationOnlyExpenseHasMonthlyLimit =>
      'Solo una categoria di spesa può avere un limite mensile.';

  @override
  String get validationInvalidTemplate => 'Modello non valido.';

  @override
  String validationGenerateKeyFailed(String detail) {
    return 'Non è stato possibile generare una chiave di firma su questo dispositivo: $detail';
  }

  @override
  String validationSaveCurrencyFailed(String detail) {
    return 'Non è stato possibile salvare questa valuta: $detail';
  }

  @override
  String get validationChooseBackupFile => 'Scegli prima un file di backup.';

  @override
  String get validationPassphraseRequired => 'Inserisci una passphrase.';

  @override
  String get validationPinsDoNotMatch => 'I due PIN non corrispondono.';

  @override
  String get validationFeePositiveWithCategory =>
      'Una commissione di trasferimento deve essere un importo positivo con una categoria di spesa selezionata.';

  @override
  String get validationFeeMustBeLessThanAmount =>
      'La commissione deve essere inferiore all\'importo per un trasferimento con commissione dedotta.';

  @override
  String validationTransferSavedFeeFailed(String detail) {
    return 'Trasferimento salvato, ma non è stato possibile registrare la commissione: $detail';
  }

  @override
  String get validationEnterValidAmount => 'Inserisci un importo valido.';

  @override
  String get errorBuyQuantityAndPriceMustBePositive =>
      'La quantità e il prezzo unitario di acquisto devono essere positivi.';

  @override
  String get errorInstrumentArchived =>
      'Impossibile acquistare uno strumento nascosto.';

  @override
  String get errorNonCashCannotIncludeBrokerage =>
      'Le acquisizioni non monetarie non possono includere una commissione di intermediazione.';

  @override
  String get errorBrokerageRequiresExpenseCategory =>
      'È richiesta una categoria di spesa attiva quando la commissione di intermediazione è positiva.';

  @override
  String get errorSellProceedsMustCoverBrokerage =>
      'Il ricavato della vendita deve essere almeno pari alla commissione di intermediazione.';

  @override
  String homeSpentOfLimitThisMonth(String spent, String limit) {
    return '$spent di $limit questo mese';
  }

  @override
  String get unlockBiometricReason => 'Sblocca Smara Contabilità';

  @override
  String get searchLabel => 'Cerca';

  @override
  String get openingBalance => 'Saldo iniziale';

  @override
  String transferToName(String name) {
    return 'Trasferimento: $name';
  }

  @override
  String get feeForTransfer => 'Commissione per il trasferimento';

  @override
  String feeForTransferTo(String name) {
    return 'Commissione per il trasferimento a $name';
  }

  @override
  String couldNotOpenFilePicker(String detail) {
    return 'Non è stato possibile aprire il selettore file: $detail';
  }

  @override
  String pleaseSelectFile(String extensions) {
    return 'Seleziona un file .$extensions';
  }

  @override
  String get currencyCodeIso => 'Codice valuta (ISO 4217, es. USD)';

  @override
  String splitCounterpartMore(String name, String count) {
    return '$name +$count altri';
  }

  @override
  String get dateLabel => 'Data';

  @override
  String get noneSelected => 'Nessuno';

  @override
  String reviewEntriesBeforeContinuing(String count) {
    return 'Rivedi le voci sottostanti ($count in totale) prima di continuare.';
  }

  @override
  String youReceived(String amount) {
    return 'Hai ricevuto $amount';
  }

  @override
  String get leaveBlankIfRateUnknown =>
      'Lascia vuoto se il tasso di cambio non è ancora noto.';

  @override
  String get recordTradeBlurb =>
      'Registra un\'operazione già avvenuta. Questa app non inoltra ordini.';

  @override
  String get feeOnTopBlurb =>
      'Attivo: l\'importo sopra è il totale prelevato da questo conto; la commissione viene dedotta da esso.';

  @override
  String get feeBankBlurb =>
      'Una commissione anticipata addebitata dalla tua banca o da un intermediario.';

  @override
  String get validationPinMinLength => 'Il PIN deve avere almeno 4 cifre.';

  @override
  String get restoreBackupBlurb =>
      'Questo sostituisce tutto ciò che è attualmente in questa app con il backup — non lo unisce. Scegli un file di backup e inserisci la passphrase con cui lo hai protetto.';

  @override
  String get actionReplace => 'Sostituisci';

  @override
  String hideAccountBody(String name) {
    return '$name non sarà più disponibile per nuove transazioni.';
  }

  @override
  String hideGroupBody(String name) {
    return '$name non sarà più proposto quando crei o riassegni conti.';
  }

  @override
  String hideCategoryBody(String name) {
    return '$name non sarà più proposto quando registri nuove transazioni.';
  }

  @override
  String get hideInstrumentBody =>
      'Gli strumenti nascosti restano sugli acquisti e sulle vendite passati. Puoi comunque registrare un dividendo per essi.';

  @override
  String nameHidden(String name) {
    return '$name (nascosto)';
  }

  @override
  String get noCurrencySet => 'Nessuna valuta impostata';

  @override
  String deletePayeeBody(String name) {
    return '$name e i suoi valori predefiniti memorizzati verranno rimossi. Le transazioni passate non sono interessate.';
  }

  @override
  String deleteTemplateBody(String name) {
    return '$name non sarà più proposto come in scadenza. Le transazioni passate già registrate non sono interessate.';
  }

  @override
  String deleteProfileBody(String name) {
    return 'La mappatura delle colonne salvata \"$name\" verrà eliminata. Gli estratti conto già importati con essa non sono interessati.';
  }

  @override
  String deleteRuleBody(String keyword) {
    return 'Le importazioni non saranno più categorizzate automaticamente da \"$keyword\". Le transazioni già categorizzate con questa regola non sono interessate.';
  }

  @override
  String get firstWeekBlurb =>
      'Facoltativamente aggiungi ora una carta di credito o un conto in contanti - potrai sempre aggiungere altri conti in seguito dalle Impostazioni.';

  @override
  String get deliveredToDestination => 'Consegnato a destinazione';

  @override
  String deliveredToName(String name) {
    return 'Consegnato a $name';
  }

  @override
  String youReceivedLessThanExpected(String amount, String currency) {
    return 'Hai ricevuto $amount $currency in meno del previsto - scegli una categoria per coprire la differenza.';
  }

  @override
  String get dateRangeLabel => 'Intervallo di date';

  @override
  String get addTemplate => 'Aggiungi modello';

  @override
  String get editTemplate => 'Modifica modello';

  @override
  String get validationFillTemplateFields =>
      'Compila ogni campo con un importo e un giorno validi.';

  @override
  String get saveCsvExport => 'Salva esportazione CSV';

  @override
  String get referenceRate => 'Tasso di riferimento';

  @override
  String get yourRate => 'Il tuo tasso';

  @override
  String leaveBlankIfThisWasAccountCurrency(String currency) {
    return 'Lascia vuoto se questo era in $currency, la valuta propria del conto.';
  }

  @override
  String get lockUntilOptional => 'Bloccato fino al (opzionale)';

  @override
  String lockedUntilDate(String date) {
    return 'Bloccato fino al $date';
  }

  @override
  String get copiedResearchPrompt =>
      'Copiato un prompt di ricerca — nessun URL del browser disponibile, oppure sei offline.';

  @override
  String get openedFavouriteResearchTool =>
      'Aperto il tuo strumento di ricerca preferito.';

  @override
  String get looksLikeGain => 'Questo sembra un guadagno';

  @override
  String get looksLikeLoss => 'Questo sembra una perdita';

  @override
  String get looksLikeBreakEven => 'Questo sembra un pareggio';

  @override
  String sellableQuantity(String name, String qty) {
    return '$name ($qty vendibili)';
  }

  @override
  String columnN(String index) {
    return 'Colonna $index';
  }

  @override
  String get importingLabel => 'Importazione in corso...';

  @override
  String get confirmImport => 'Conferma importazione';

  @override
  String get manageSavedCategoryRules => 'Gestisci regole di categoria salvate';

  @override
  String statementCurrencyMismatch(String currency) {
    return 'La valuta di questo file ($currency) non corrisponde alla valuta del conto selezionato.';
  }

  @override
  String get categoryRulesTitle => 'Regole di categoria';

  @override
  String get possibleDuplicate => 'possibile duplicato';

  @override
  String get unknownCategory => 'Categoria sconosciuta';

  @override
  String get researchPromptIntro =>
      'Ricerca questo strumento quotato pubblicamente per un investitore privato. Identifica l\'emittente, riassumi le notizie recenti con le date se note, e delinea i rischi al ribasso e i fattori al rialzo. Separa i fatti dalle speculazioni. Non fornire una raccomandazione di acquisto, vendita o mantenimento. Questo non è un consiglio finanziario.';

  @override
  String researchPromptNameLine(String name) {
    return 'Nome: $name';
  }

  @override
  String researchPromptTickerLine(String ticker) {
    return 'Ticker: $ticker';
  }

  @override
  String get researchPromptTickerNoneProvided => 'Ticker: (non fornito)';

  @override
  String researchPromptIsinLine(String isin) {
    return 'ISIN: $isin';
  }

  @override
  String get researchPromptIsinNoneProvided => 'ISIN: (non fornito)';

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
    return 'Verranno sostituite tutte le registrazioni e le impostazioni dei libri su questo telefono ($counts). Nulla viene unito. La lingua e le impostazioni di sblocco restano su questo telefono.';
  }

  @override
  String get saveCopyFirstAction => 'Salva prima una copia';

  @override
  String replaceCountEntries(int count) {
    return '$count registrazioni';
  }

  @override
  String replaceCountAccounts(int count) {
    return '$count conti';
  }

  @override
  String replaceCountCategories(int count) {
    return '$count categorie';
  }

  @override
  String replaceCountGroups(int count) {
    return '$count gruppi di conti';
  }

  @override
  String replaceCountPayees(int count) {
    return '$count beneficiari';
  }

  @override
  String replaceCountCategoryRules(int count) {
    return '$count regole di categoria';
  }

  @override
  String replaceCountCsvProfiles(int count) {
    return '$count profili di importazione';
  }

  @override
  String replaceCountRecurringTemplates(int count) {
    return '$count modelli ricorrenti';
  }

  @override
  String replaceCountInstruments(int count) {
    return '$count strumenti';
  }

  @override
  String get claimsTitle => 'Rimborsi';

  @override
  String get claimsReviewTitle => 'Rivedi i rimborsi';

  @override
  String get claimsStatusDraft => 'Bozza';

  @override
  String get claimsStatusSubmitted => 'Inviata';

  @override
  String get claimsStatusPartlyApproved => 'Parzialmente approvata';

  @override
  String get claimsStatusApproved => 'Approvata';

  @override
  String get claimsStatusPaid => 'Pagata';

  @override
  String get claimsStatusRejected => 'Rifiutata';

  @override
  String get claimsApprove => 'Approva';

  @override
  String get claimsApproveDifferent => 'Approva un importo diverso';

  @override
  String get claimsReject => 'Rifiuta';

  @override
  String get claimsReasonRequired => 'È obbligatorio un motivo';

  @override
  String get claimsAdvances => 'Anticipi';

  @override
  String get claimsAddPerson => 'Aggiungi una persona';

  @override
  String get claimsRoleApprover => 'Approvatore';

  @override
  String get claimsRoleClaimant => 'Richiedente';

  @override
  String claimsBalanceCompanyOwesYou(String company) {
    return '$company ti deve';
  }

  @override
  String claimsBalanceYouOweCompany(String company) {
    return 'Devi a $company';
  }

  @override
  String claimsBalanceSettled(String company) {
    return 'Saldo con $company';
  }

  @override
  String get claimsReceiptRequired =>
      'È richiesta una ricevuta per questa voce della richiesta di rimborso';

  @override
  String get claimsReceiptPdfTooLarge =>
      'Questo PDF supera i 5 MB. Scegli un file più piccolo.';

  @override
  String claimsSpendingHint(String amount, String unit) {
    return 'Suggerimento: al massimo $amount per $unit';
  }

  @override
  String get claimsPersonalLimitsTitle => 'Limiti delle note spese';

  @override
  String claimsPersonalLimitsTitleFor(String name) {
    return 'Limiti delle note spese di $name';
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
    return 'Oltre il limite di $limit';
  }

  @override
  String get claimsNoPersonalLimits => 'Nessun limite personale impostato.';

  @override
  String get claimsClearPersonalLimit => 'Cancella limite';

  @override
  String get claimsNoClaimsYet => 'Ancora nessuna richiesta di rimborso.';

  @override
  String get claimsNoClaimsToReview =>
      'Nessuna richiesta di rimborso da rivedere.';

  @override
  String get claimsAdvanceDefault => 'Anticipo';

  @override
  String claimsItemCount(int count) {
    return '$count voce/i';
  }

  @override
  String get claimsRejectReasonTitle => 'Motivo del rifiuto';

  @override
  String get claimsApproveDifferentReasonTitle =>
      'Motivo dell\'importo diverso';

  @override
  String get claimsPersonNameLabel => 'Nome della persona';

  @override
  String get claimsRemovePerson => 'Rimuovi';

  @override
  String claimsRemovePersonTitle(String name) {
    return 'Rimuovere $name?';
  }

  @override
  String claimsRemovePersonWarning(String name, int openClaims) {
    return '$name ha $openClaims richieste di rimborso aperte e un saldo diverso da zero. Cronologia e ricevute restano in questi libri.';
  }

  @override
  String claimsRemovePersonWarningOpenOnly(String name, int openClaims) {
    return '$name ha $openClaims richieste di rimborso aperte. Cronologia e ricevute restano in questi libri.';
  }

  @override
  String claimsRemovePersonWarningBalanceOnly(String name) {
    return '$name ha un saldo diverso da zero. Cronologia e ricevute restano in questi libri.';
  }

  @override
  String claimsRemovePersonWarningClean(String name) {
    return 'Rimuovere $name? Cronologia e ricevute restano in questi libri.';
  }

  @override
  String get claimsRemovePersonConfirm => 'Rimuovi';

  @override
  String get claimsEditorTitle => 'Modifica richiesta di rimborso';

  @override
  String get claimsSubmit => 'Invia';

  @override
  String get claimsAddItem => 'Aggiungi voce';

  @override
  String get claimsEditItem => 'Modifica voce';

  @override
  String get claimsNoItemsYet => 'Aggiungi almeno una voce prima di inviare.';

  @override
  String get claimsNoAllowlistedCategories =>
      'Non ci sono ancora categorie di spesa consentite per i rimborsi.';

  @override
  String get claimsCategoryLabel => 'Categoria';

  @override
  String get claimsExpenseDateLabel => 'Data della spesa';

  @override
  String get claimsPaidAmountLabel => 'Importo pagato';

  @override
  String get claimsPaidCurrencyLabel => 'Valuta pagata';

  @override
  String get claimsRateOptionalLabel => 'Tasso (facoltativo)';

  @override
  String claimsCompanyAmountLabel(String currency) {
    return 'Importo in $currency';
  }

  @override
  String get claimsDescriptionLabel => 'Descrizione';

  @override
  String get claimsAttachCamera => 'Scatta foto';

  @override
  String get claimsAttachGallery => 'Scegli foto';

  @override
  String get claimsAttachPdf => 'Scegli PDF';

  @override
  String claimsReceiptAttached(String fileName) {
    return 'Ricevuta: $fileName';
  }

  @override
  String get claimsReceiptRequiredHint =>
      'È richiesta una ricevuta per questo importo.';

  @override
  String get claimsReceiptPermissionSentence =>
      'Per allegare una foto della ricevuta, Smara ha bisogno dell\'accesso alla fotocamera o alla libreria foto. Le foto restano in questi libri sui tuoi dispositivi.';

  @override
  String claimsReviewClaimHeading(String status) {
    return 'Rimborso · $status';
  }
}
