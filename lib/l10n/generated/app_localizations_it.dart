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
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsPrivacyPolicyOpenFailed =>
      'Could not open the privacy policy in a browser.';

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
  String get keystoreExportFailed =>
      'Non è stato possibile esportare il file keystore. Puoi saltare questo passaggio.';

  @override
  String get enterPassphraseToProtect =>
      'Inserisci una passphrase per proteggere il file.';

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
  String get recoveryPhraseTitle => 'La tua frase di recupero';

  @override
  String get recoveryPhraseConfirmTitle => 'Conferma la tua frase';

  @override
  String get recoveryPhraseBlurb =>
      'Queste 24 parole sono l\'unico modo per recuperare la cronologia delle tue transazioni se questo dispositivo viene perso, ripristinato o sostituito. Smara Accounting non ha un server e non può recuperarle per te.\n\nSe perdi questo dispositivo insieme a questa frase, ogni transazione che hai registrato diventa permanentemente non verificabile.';

  @override
  String get recoveryPhraseWriteDown =>
      'Scrivi queste parole in ordine e conservale in un luogo sicuro, separato da questo dispositivo.';

  @override
  String get iveSavedRecoveryPhrase => 'Ho salvato la mia frase di recupero';

  @override
  String get confirmPhraseBlurb =>
      'Inserisci le parole richieste dalla frase che hai appena salvato.';

  @override
  String wordNumber(String n) {
    return 'Parola n. $n';
  }

  @override
  String get keystoreExportTitle => 'Esporta file keystore';

  @override
  String get keystoreExportBlurb =>
      'Oltre alla tua frase di recupero, puoi salvare un file keystore cifrato protetto da una passphrase a tua scelta. È opzionale - la tua sola frase di recupero è sempre sufficiente per ripristinare la tua chiave di firma.';

  @override
  String get keystorePassphrase => 'Passphrase';

  @override
  String get exportKeystoreFile => 'Esporta file keystore';

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
  String get restoreTitle => 'Ripristina chiave di firma';

  @override
  String get restoreBlurb =>
      'Questo dispositivo ha libri contabili esistenti, ma nessuna chiave di firma corrispondente. Ripristinala dalla tua frase di recupero salvata o dal file keystore - i tuoi dati verranno verificati normalmente, e nulla verrà ri-firmato o alterato.';

  @override
  String get recoveryPhrase24 => 'Frase di recupero (tutte le 24 parole)';

  @override
  String get keystoreFile => 'File keystore';

  @override
  String get keystoreFileContents => 'Contenuto del file keystore';

  @override
  String get optionalBackupFile => 'File di backup opzionale';

  @override
  String get iDontHavePhrase =>
      'Non ho la mia frase di recupero o il file keystore';

  @override
  String get migrationTitle => 'Migra a una nuova chiave';

  @override
  String get migrationBlurb =>
      'Senza la tua frase di recupero o il file keystore, la chiave di firma di questo dispositivo non può essere recuperata. Puoi avviare una nuova chiave. Le voci precedenti restano visibili ma vengono sostituite.';

  @override
  String get iConfirmBooksValid =>
      'Confermo che i libri contabili attuali sono validi';

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
  String get errorSigningIdentityMismatch =>
      'Questa frase di recupero o file keystore non corrisponde a nessuna identità di firma in questo database.';

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
  String get errorForeignBackupIdentity =>
      'Questo backup appartiene a un\'identità di firma diversa da quella su questo dispositivo.';

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
  String get validationWrongKeystorePassphrase =>
      'Passphrase errata per questo file keystore.';

  @override
  String get validationInvalidKeystoreFile =>
      'Questo non sembra un file keystore valido.';

  @override
  String get validationRestorePhraseFailed =>
      'Non è stato possibile ripristinare da quella frase di recupero.';

  @override
  String validationGenerateKeyFailed(String detail) {
    return 'Non è stato possibile generare una chiave di firma su questo dispositivo: $detail';
  }

  @override
  String validationSaveCurrencyFailed(String detail) {
    return 'Non è stato possibile salvare questa valuta: $detail';
  }

  @override
  String get validationMigrationFailed => 'Migrazione non riuscita. Riprova.';

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
  String validationConfirmWordMismatch(String n) {
    return 'La parola $n non corrisponde alla tua frase salvata. Controllala e riprova.';
  }

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
}
