// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Smara Comptabilité';

  @override
  String get navHome => 'Accueil';

  @override
  String get navRegister => 'Registre';

  @override
  String get navSummary => 'Résumé';

  @override
  String get navAccounts => 'Comptes';

  @override
  String get navCategories => 'Catégories';

  @override
  String get actionCancel => 'Annuler';

  @override
  String get actionSave => 'Enregistrer';

  @override
  String get actionDelete => 'Supprimer';

  @override
  String get actionDone => 'Terminé';

  @override
  String get actionContinue => 'Continuer';

  @override
  String get actionDismiss => 'Fermer';

  @override
  String get actionRetry => 'Réessayer';

  @override
  String get actionSkip => 'Ignorer';

  @override
  String get actionConfirm => 'Confirmer';

  @override
  String get actionAdd => 'Ajouter';

  @override
  String get actionEdit => 'Modifier';

  @override
  String get actionRename => 'Renommer';

  @override
  String get actionHide => 'Masquer';

  @override
  String get actionCreate => 'Créer';

  @override
  String get actionCloseApp => 'Fermer l\'application';

  @override
  String get actionUnlock => 'Déverrouiller';

  @override
  String get actionSettle => 'Régler';

  @override
  String get actionFinish => 'Terminer';

  @override
  String get actionPreview => 'Aperçu';

  @override
  String get actionImport => 'Importer';

  @override
  String get actionExportCsv => 'Exporter en CSV';

  @override
  String get actionChooseFile => 'Choisir un fichier';

  @override
  String get actionRestore => 'Restaurer';

  @override
  String get actionFix => 'Corriger';

  @override
  String get actionBuy => 'Acheter';

  @override
  String get actionSell => 'Vendre';

  @override
  String get actionDividend => 'Dividende';

  @override
  String get actionRecordBuy => 'Enregistrer un achat';

  @override
  String get actionRecordSell => 'Enregistrer une vente';

  @override
  String get actionRecordDividend => 'Enregistrer un dividende';

  @override
  String get actionPayCard => 'Payer la carte';

  @override
  String get actionTransfer => 'Virement';

  @override
  String get actionRecordTransaction => 'Enregistrer une transaction';

  @override
  String get actionImportStatement => 'Importer un relevé';

  @override
  String get actionClearDates => 'Effacer les dates';

  @override
  String get actionClearSearch => 'Effacer la recherche et les filtres';

  @override
  String get actionUseBiometrics => 'Utiliser la biométrie';

  @override
  String get actionSetPin => 'Définir un code PIN';

  @override
  String get actionChangePin => 'Changer le code PIN';

  @override
  String get actionSaveBackup => 'Enregistrer la sauvegarde';

  @override
  String get actionRestoreBackup => 'Restaurer la sauvegarde';

  @override
  String get actionSaveRule => 'Enregistrer la règle';

  @override
  String get actionConfirmFix => 'Confirmer la correction';

  @override
  String get captureSpent => 'Dépensé';

  @override
  String get captureReceived => 'Reçu';

  @override
  String get captureMovedMoney => 'Argent déplacé';

  @override
  String get captureImportStatement => 'Importer un relevé';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsLanguageSystem => 'Langue de l\'appareil';

  @override
  String get settingsFetchFxRates =>
      'Récupérer les taux de change de référence';

  @override
  String get settingsFetchFxRatesSubtitle =>
      'Affiche un taux de change indicatif à côté du montant de destination lors des virements entre devises, à titre de comparaison uniquement - il n\'est jamais utilisé pour remplir le montant.';

  @override
  String get settingsRateProvider => 'Fournisseur de taux';

  @override
  String get settingsFetchMarketPrices =>
      'Récupérer les cours du marché pour les investissements';

  @override
  String get settingsFetchMarketPricesSubtitle =>
      'Recherche les derniers cours des instruments ayant un symbole boursier ou un code ISIN, pour estimer la valeur du portefeuille. Jamais utilisé pour enregistrer une opération, et n\'envoie jamais la quantité que vous détenez.';

  @override
  String get settingsMarketPriceProvider => 'Fournisseur de cours du marché';

  @override
  String get settingsFavouriteResearchTool => 'Outil de recherche favori';

  @override
  String get settingsFavouriteResearchToolSubtitle =>
      'Toucher le nom d\'un instrument dans vos positions ouvre cet outil dans le navigateur avec une requête de recherche — ce n\'est pas une intégration, ni un conseil.';

  @override
  String get settingsBackup => 'Sauvegarde';

  @override
  String get settingsBackupBlurb =>
      'Enregistrez une copie chiffrée de vos livres à l\'endroit de votre choix, ou restaurez-en une. Ceci est indépendant de votre phrase de récupération ou de votre fichier de clés, qui sauvegardent votre clé de signature, et non vos livres.';

  @override
  String get settingsLock => 'Verrouillage';

  @override
  String get settingsLockBlurb =>
      'Exiger un code PIN, ou la biométrie si disponible, pour ouvrir l\'application.';

  @override
  String get settingsRequireUnlock =>
      'Exiger un déverrouillage pour ouvrir l\'application';

  @override
  String get settingsLockAfter => 'Verrouiller après';

  @override
  String get settingsLockImmediately => 'Immédiatement';

  @override
  String get settingsLock1Minute => '1 minute';

  @override
  String get settingsLock5Minutes => '5 minutes';

  @override
  String get settingsLock15Minutes => '15 minutes';

  @override
  String get settingsAllowBiometrics => 'Autoriser aussi la biométrie';

  @override
  String get settingsHideSnapshot =>
      'Masquer les soldes dans le sélecteur d\'applications';

  @override
  String get settingsHideSnapshotSubtitle =>
      'Floute cet écran lorsque vous passez à une autre application, afin qu\'il ne soit pas visible d\'un coup d\'œil dans le sélecteur d\'applications.';

  @override
  String get settingsHideSnapshotUnavailable =>
      'Le masquage des soldes dans le sélecteur d\'applications n\'est pas disponible sur cette plateforme.';

  @override
  String get settingsPayees => 'Bénéficiaires';

  @override
  String get settingsManagePayees => 'Gérer les bénéficiaires';

  @override
  String get settingsPayeesBlurb =>
      'Noms de bénéficiaires mémorisés ainsi que leur catégorie et compte par défaut, suggérés par saisie automatique lors de l\'enregistrement d\'une transaction.';

  @override
  String get settingsRecurring => 'Modèles récurrents';

  @override
  String get settingsManageRecurring => 'Gérer les modèles récurrents';

  @override
  String get settingsRecurringBlurb =>
      'Factures ou revenus qui se répètent chaque mois, comme un loyer ou un salaire. Un modèle arrivé à échéance apparaît sur l\'accueil pour que vous l\'enregistriez d\'un geste - il n\'est jamais comptabilisé automatiquement.';

  @override
  String get settingsAbout => 'À propos';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsPrivacyPolicyOpenFailed =>
      'Could not open the privacy policy in a browser.';

  @override
  String get providerFrankfurter => 'Frankfurter (taux de la BCE)';

  @override
  String get providerOpenErApi => 'ExchangeRate-API (open.er-api.com)';

  @override
  String get providerStooq => 'Stooq (cours quotidiens)';

  @override
  String get providerYahooFinance => 'Yahoo Finance (API graphique)';

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
      'Trésorerie et équivalents de trésorerie';

  @override
  String get systemGroupPensionRetirement => 'Retraite et pension';

  @override
  String get systemGroupCreditShortTerm => 'Crédit et dette à court terme';

  @override
  String get systemGroupLoansMortgages => 'Prêts et hypothèques';

  @override
  String get systemGroupInvestments => 'Investissements';

  @override
  String get systemAccountCashBank => 'Espèces et banque';

  @override
  String get systemCategorySalary => 'Salaire';

  @override
  String get systemCategoryOtherIncome => 'Autres revenus';

  @override
  String get systemCategoryGroceries => 'Courses';

  @override
  String get systemCategoryRentMortgage => 'Loyer/Hypothèque';

  @override
  String get systemCategoryUtilities => 'Charges';

  @override
  String get systemCategoryTransport => 'Transport';

  @override
  String get systemCategoryFoodOut => 'Restauration';

  @override
  String get systemCategoryPhone => 'Téléphone';

  @override
  String get systemCategoryHealth => 'Santé';

  @override
  String get systemCategoryOtherExpense => 'Autres dépenses';

  @override
  String get systemDescriptionCsvImport => 'Import CSV';

  @override
  String get systemDescriptionOfxImport => 'Import OFX';

  @override
  String get homeThisMonth => 'CE MOIS-CI';

  @override
  String get homeMoneyInTransit => 'ARGENT EN TRANSIT';

  @override
  String get homeWhatYouHaveMinusWhatYouOwe =>
      'CE QUE VOUS AVEZ MOINS CE QUE VOUS DEVEZ';

  @override
  String homeWhatYouHave(String amount, String currency) {
    return 'Ce que vous avez $amount $currency';
  }

  @override
  String homeNetPosition(String amount, String currency) {
    return '$amount $currency';
  }

  @override
  String homeHaveAndOwe(String haveAmount, String currency, String oweAmount) {
    return 'Ce que vous avez $haveAmount $currency  •  Ce que vous devez $oweAmount $currency';
  }

  @override
  String youSentFrom(String amount, String currency, String name) {
    return 'Vous avez envoyé $amount $currency depuis $name';
  }

  @override
  String youSentTo(String amount, String currency, String name) {
    return 'Vous avez envoyé $amount $currency à $name';
  }

  @override
  String get hiddenLabel => 'Masqué';

  @override
  String get allAccounts => 'Tous les comptes';

  @override
  String savedToPath(String path) {
    return 'Enregistré dans $path';
  }

  @override
  String get keystoreExportFailed =>
      'Impossible d\'exporter le fichier de clés. Vous pouvez ignorer cette étape.';

  @override
  String get enterPassphraseToProtect =>
      'Saisissez une phrase secrète pour protéger le fichier.';

  @override
  String get homeTapWhenArrived =>
      'Appuyez lorsque vous savez ce qui est arrivé';

  @override
  String homeReturnedTo(String name) {
    return 'Retourné à $name';
  }

  @override
  String get homeDueToday => 'À ÉCHÉANCE AUJOURD\'HUI';

  @override
  String homeDueLine(String category, String account) {
    return '$category · $account · touchez pour enregistrer';
  }

  @override
  String get homeOverLimit => 'Limite dépassée';

  @override
  String homeSpentOfLimit(String spent, String limit) {
    return '$spent sur $limit';
  }

  @override
  String homeRemaining(String amount) {
    return 'Restant : $amount';
  }

  @override
  String get homeNoAccounts => 'Aucun compte';

  @override
  String get homeCashRegister => 'Caisse';

  @override
  String get homeMarketEstimate => 'Estimation du marché';

  @override
  String get registerTitle => 'Registre';

  @override
  String get registerSearchHint => 'Description, catégorie ou montant';

  @override
  String get registerNoTransactions => 'Aucune transaction pour l\'instant';

  @override
  String get registerNoEntries =>
      'Aucune écriture enregistrée pour l\'instant.';

  @override
  String get registerSpentOnly => 'Dépenses uniquement';

  @override
  String get registerReceivedOnly => 'Recettes uniquement';

  @override
  String get registerAll => 'Tout';

  @override
  String get registerUnverified => 'Non vérifié - exclu des totaux';

  @override
  String get registerSuperseded =>
      'Remplacé par une migration - exclu des totaux';

  @override
  String get summaryTitle => 'Résumé';

  @override
  String get summaryTotalIncome => 'Revenu total';

  @override
  String get summaryTotalExpense => 'Dépense totale';

  @override
  String summaryDateRange(String start, String end) {
    return '$start au $end';
  }

  @override
  String get accountsTitle => 'Comptes';

  @override
  String get categoriesTitle => 'Catégories';

  @override
  String get accountName => 'Nom du compte';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get createGroup => 'Créer un groupe';

  @override
  String get editGroup => 'Modifier le groupe';

  @override
  String get renameAccount => 'Renommer le compte';

  @override
  String get renameCategory => 'Renommer la catégorie';

  @override
  String get addCategory => 'Ajouter une catégorie';

  @override
  String get groupLabel => 'Groupe';

  @override
  String get kindLabel => 'Type';

  @override
  String get asset => 'Actif';

  @override
  String get liability => 'Passif';

  @override
  String get income => 'Revenu';

  @override
  String get expense => 'Dépense';

  @override
  String get thisAccountHoldsInvestments =>
      'Ce compte détient des investissements';

  @override
  String get thisAccountHoldsInvestmentsSubtitle =>
      'Trésorerie plus l\'inventaire que vous enregistrez avec Acheter, Vendre et Dividende.';

  @override
  String get thisIsACreditCard => 'Ceci est une carte de crédit';

  @override
  String get openingBalanceOptional => 'Solde initial (facultatif)';

  @override
  String get currencyIso => 'Devise (ISO 4217)';

  @override
  String get currencyIsoExample => 'Devise (ISO 4217, p. ex. USD)';

  @override
  String get hideAccountTitle =>
      'Masquer ce compte pour les nouvelles écritures ?';

  @override
  String get hideCategoryTitle =>
      'Masquer cette catégorie pour les nouvelles écritures ?';

  @override
  String get hideGroupTitle =>
      'Masquer ce groupe pour les nouvelles écritures ?';

  @override
  String get reassignGroup => 'Réattribuer le groupe';

  @override
  String get transferRemainingBalance => 'Transférer le solde restant';

  @override
  String get monthlyLimit => 'Limite mensuelle';

  @override
  String get monthlyLimitHint => 'Limite (laisser vide pour l\'effacer)';

  @override
  String get monthlyLimitBlurb =>
      'Un repère facultatif des dépenses du mois en cours pour cette catégorie de dépense.';

  @override
  String get manageCategoryRules => 'Gérer les règles de catégorie';

  @override
  String get amount => 'Montant';

  @override
  String get category => 'Catégorie';

  @override
  String get account => 'Compte';

  @override
  String get fromAccount => 'Compte source';

  @override
  String get toAccount => 'Compte de destination';

  @override
  String get descriptionOptional => 'Description (facultatif)';

  @override
  String get alsoRememberPayee => 'Mémoriser aussi comme bénéficiaire';

  @override
  String get splitIntoCategories => 'Répartir en plusieurs catégories';

  @override
  String categoryN(String n) {
    return 'Catégorie $n';
  }

  @override
  String get destinationAmount => 'Montant de destination';

  @override
  String get destinationAmountOptional => 'Montant de destination (facultatif)';

  @override
  String get accountCurrencyAmountOptional =>
      'Montant en devise du compte (facultatif)';

  @override
  String get transactionCurrencyOptional =>
      'Devise de la transaction (facultatif)';

  @override
  String get feeOptional => 'Frais (facultatif)';

  @override
  String get feeAmount => 'Montant des frais';

  @override
  String get feeCategory => 'Catégorie des frais';

  @override
  String get feeDescriptionOptional => 'Description des frais (facultatif)';

  @override
  String get feeDeducted => 'Les frais sont déduits du montant ci-dessus';

  @override
  String get needTwoAccountsToTransfer =>
      'Créez au moins deux comptes actifs pour effectuer un virement.';

  @override
  String get whatArrivedTitle => 'Qu\'est-ce qui est arrivé ?';

  @override
  String get whatArrivedBlurb => 'Indiquez-nous ce qui est réellement arrivé.';

  @override
  String get amountThatArrived => 'Montant reçu';

  @override
  String get feeLossCategory => 'Catégorie de frais / perte';

  @override
  String get alreadySettled => 'Déjà réglé.';

  @override
  String get holdingsTitle => 'Positions';

  @override
  String get holdingsCash => 'Liquidités';

  @override
  String get holdingsInventory => 'INVENTAIRE';

  @override
  String holdingsBook(String amount, String currency) {
    return 'Comptable (liquidités + coût) $amount $currency';
  }

  @override
  String holdingsMarketEstimate(String amount, String currency) {
    return 'Estimation du marché $amount $currency';
  }

  @override
  String get holdingsNoHoldings =>
      'Aucune position pour l\'instant. Enregistrez un achat pour ajouter un instrument.';

  @override
  String get holdingsQuotesBlurb =>
      'Les cours sont des estimations, pas un prix de courtier. Cette application ne passe pas d\'ordres.';

  @override
  String get holdingsTapNameToResearch =>
      'Touchez le nom pour effectuer une recherche. Les cours sont des estimations, pas des conseils.';

  @override
  String get instrument => 'Instrument';

  @override
  String get newInstrument => 'Nouvel instrument';

  @override
  String get renameInstrument => 'Renommer l\'instrument';

  @override
  String get instrumentActions => 'Actions sur l\'instrument';

  @override
  String hideInstrumentTitle(String name) {
    return 'Masquer $name ?';
  }

  @override
  String get tickerOptional => 'Symbole boursier (facultatif)';

  @override
  String get isinOptional => 'ISIN (facultatif)';

  @override
  String get quantity => 'Quantité';

  @override
  String get unitPrice => 'Prix unitaire';

  @override
  String get brokerageOptional => 'Frais de courtage (facultatif)';

  @override
  String get brokerageExpenseCategory => 'Catégorie de dépense de courtage';

  @override
  String get incomeCategory => 'Catégorie de revenu';

  @override
  String get gainIncomeCategory => 'Catégorie de revenu de plus-value';

  @override
  String get lossExpenseCategory => 'Catégorie de dépense de moins-value';

  @override
  String get nonCash => 'Hors trésorerie';

  @override
  String get cash => 'Liquidités';

  @override
  String get locked => 'Bloqué';

  @override
  String get lockUntilHint =>
      'Votre propre note sur une restriction, pas une règle du courtier.';

  @override
  String get instrumentKindStock => 'Action';

  @override
  String get instrumentKindEtf => 'ETF';

  @override
  String get instrumentKindMutualFund => 'Fonds commun de placement';

  @override
  String get instrumentKindBond => 'Obligation';

  @override
  String get instrumentKindOther => 'Autre';

  @override
  String get quoteUseLive => 'Cours en direct';

  @override
  String get quoteUseCached => 'Cours en cache';

  @override
  String get quoteUseStale => 'Cours obsolète';

  @override
  String get quoteUseMissing => 'Utilisation du coût (pas de cours)';

  @override
  String get quoteUseDisabled => 'Cours désactivés — utilisation du coût/cache';

  @override
  String get quoteUseCurrencyMismatch =>
      'Utilisation du coût (devise du cours différente)';

  @override
  String unrealizedLabel(String amount, String currency) {
    return 'Non réalisé $amount $currency';
  }

  @override
  String holdingsUnitsCost(String qty) {
    return '$qty unités · ';
  }

  @override
  String get recoveryPhraseTitle => 'Votre phrase de récupération';

  @override
  String get recoveryPhraseConfirmTitle => 'Confirmez votre phrase';

  @override
  String get recoveryPhraseBlurb =>
      'Ces 24 mots sont le seul moyen de récupérer votre historique de transactions si cet appareil est perdu, réinitialisé ou remplacé. Smara Accounting n\'a pas de serveur et ne peut pas les récupérer à votre place.\n\nSi vous perdez cet appareil et cette phrase ensemble, chaque transaction que vous avez enregistrée devient définitivement invérifiable.';

  @override
  String get recoveryPhraseWriteDown =>
      'Notez ces mots dans l\'ordre et conservez-les dans un endroit sûr, séparé de cet appareil.';

  @override
  String get iveSavedRecoveryPhrase =>
      'J\'ai enregistré ma phrase de récupération';

  @override
  String get confirmPhraseBlurb =>
      'Saisissez les mots demandés de la phrase que vous venez d\'enregistrer.';

  @override
  String wordNumber(String n) {
    return 'Mot n° $n';
  }

  @override
  String get keystoreExportTitle => 'Exporter le fichier de clés';

  @override
  String get keystoreExportBlurb =>
      'En plus de votre phrase de récupération, vous pouvez enregistrer un fichier de clés chiffré protégé par une phrase secrète de votre choix. Ceci est facultatif - votre phrase de récupération seule suffit toujours à restaurer votre clé de signature.';

  @override
  String get keystorePassphrase => 'Phrase secrète';

  @override
  String get exportKeystoreFile => 'Exporter le fichier de clés';

  @override
  String get chooseCurrencyTitle => 'Choisissez votre devise';

  @override
  String get chooseCurrencyBlurb =>
      'Pour l\'instant, chaque groupe de comptes (Trésorerie et équivalents de trésorerie, Retraite et pension, etc.) utilise cette devise unique. Vous pourrez toujours ajouter des comptes dans une autre devise plus tard en créant un nouveau groupe pour celle-ci.';

  @override
  String get currencyBackfillTitle =>
      'Choisissez une devise pour les groupes existants';

  @override
  String get currencyBackfillBlurb =>
      'Cette application prend désormais en charge plusieurs devises. Vos comptes et groupes de comptes existants ont besoin d\'une devise - comme ils ont tous été créés avant l\'existence de cette fonctionnalité, un seul choix s\'applique à tous.';

  @override
  String get firstAccountTitle => 'Nommez votre compte';

  @override
  String get firstAccountBlurb =>
      'Voici le compte déjà créé pour vous - donnez-lui un nom que vous reconnaissez, comme celui de votre banque. Vous enregistrerez ensuite une dépense ou une recette, puis protégerez l\'appareil avec votre phrase de récupération.';

  @override
  String get whatsMainAccountCalled =>
      'Comment s\'appelle votre compte principal ?';

  @override
  String get restoreTitle => 'Restaurer la clé de signature';

  @override
  String get restoreBlurb =>
      'Cet appareil possède des livres existants, mais aucune clé de signature correspondante. Restaurez-la à partir de votre phrase de récupération enregistrée ou de votre fichier de clés - vos données se vérifieront normalement, et rien ne sera re-signé ni modifié.';

  @override
  String get recoveryPhrase24 => 'Phrase de récupération (les 24 mots)';

  @override
  String get keystoreFile => 'Fichier de clés';

  @override
  String get keystoreFileContents => 'Contenu du fichier de clés';

  @override
  String get optionalBackupFile => 'Fichier de sauvegarde facultatif';

  @override
  String get iDontHavePhrase =>
      'Je n\'ai ni ma phrase de récupération ni le fichier de clés';

  @override
  String get migrationTitle => 'Migrer vers une nouvelle clé';

  @override
  String get migrationBlurb =>
      'Sans votre phrase de récupération ou votre fichier de clés, la clé de signature de cet appareil ne peut pas être récupérée. Vous pouvez créer une nouvelle clé. Les anciennes écritures restent visibles mais sont remplacées.';

  @override
  String get iConfirmBooksValid =>
      'Je confirme que les livres actuels sont valides';

  @override
  String get whyWeDontEdit =>
      'Pourquoi nous ne modifions pas les anciennes écritures';

  @override
  String get whyWeDontEditBody =>
      'Lorsque vous corrigez une erreur, nous conservons la ligne d\'origine et ajoutons une correction à côté au lieu de modifier ce que vous avez déjà saisi. Ainsi, votre historique montre toujours exactement ce qui s\'est passé et quand vous l\'avez corrigé — rien ne change discrètement dans votre dos.';

  @override
  String get lockTitle => 'Déverrouiller';

  @override
  String get lockScreenTitle => 'Verrouillé';

  @override
  String get enterPinToContinue => 'Entrez votre code pour continuer';

  @override
  String get pinLabel => 'Code PIN';

  @override
  String get setPinTitle => 'Définir un code PIN';

  @override
  String get currentPin => 'Code PIN actuel';

  @override
  String get newPin => 'Nouveau code PIN';

  @override
  String get confirmPin => 'Confirmer le code PIN';

  @override
  String get confirmNewPin => 'Confirmer le nouveau code PIN';

  @override
  String get firstWeekTitle => 'Configurez vos comptes';

  @override
  String get addCashAccount => 'Ajouter un compte espèces';

  @override
  String get addCreditCard => 'Ajouter une carte de crédit';

  @override
  String get cashAccountName => 'Nom du compte espèces';

  @override
  String get cardName => 'Nom de la carte';

  @override
  String get paidFromBank => 'Payé depuis la banque';

  @override
  String get paidFromCard => 'Payé depuis la carte';

  @override
  String get choosePassphraseTitle =>
      'Choisissez une phrase secrète pour protéger cette sauvegarde. Il n\'y a aucun moyen de la récupérer si vous l\'oubliez.';

  @override
  String get replaceBooksTitle => 'Remplacer vos livres locaux ?';

  @override
  String get replaceBooksBody =>
      'Cela remplace tout ce qui se trouve actuellement dans cette application par la sauvegarde. Fermez puis rouvrez l\'application ensuite.';

  @override
  String get chooseBackupFileFirst =>
      'Choisissez d\'abord un fichier de sauvegarde.';

  @override
  String get backupRestored => 'Sauvegarde restaurée';

  @override
  String get backupRestoredBody =>
      'Vos livres ont été restaurés. Fermez puis rouvrez l\'application pour continuer.';

  @override
  String get fixThisEntry => 'Corriger cette écriture';

  @override
  String get fixBlurb =>
      'La ligne d\'origine reste exactement telle quelle. Confirmer ajoute une ligne d\'extourne et la ligne corrigée.';

  @override
  String get importStatementTitle => 'Importer un relevé';

  @override
  String get importOfx => 'Importer OFX';

  @override
  String get importOfxQfxFile => 'Importer un fichier OFX / QFX';

  @override
  String get importCsvFile => 'Importer un fichier CSV';

  @override
  String get whatKindOfStatement =>
      'Quel type de fichier de relevé possédez-vous ?';

  @override
  String get chooseAccountForFile =>
      'Choisissez à quel compte appartient ce fichier.';

  @override
  String get importIntoAccount => 'Importer dans le compte';

  @override
  String get useSavedProfile => 'Utiliser un profil enregistré';

  @override
  String get saveMappingProfile =>
      'Enregistrer ce mappage comme profil (facultatif)';

  @override
  String get renameProfile => 'Renommer le profil';

  @override
  String get deleteProfileTitle => 'Supprimer le profil ?';

  @override
  String get fileHasHeader => 'Le fichier comporte une ligne d\'en-tête';

  @override
  String get dateColumn => 'Colonne de date';

  @override
  String get dateFormatHint => 'Format de date (p. ex. jj/MM/aaaa)';

  @override
  String get amountColumn => 'Colonne de montant';

  @override
  String get amountConvention => 'Convention de montant';

  @override
  String get signedAmountColumn => 'Colonne de montant signé';

  @override
  String get separateDebitCredit => 'Colonnes distinctes débit / crédit';

  @override
  String get debitColumn => 'Colonne de débit';

  @override
  String get creditColumn => 'Colonne de crédit';

  @override
  String get decimalSeparator => 'Séparateur décimal (, ou .)';

  @override
  String get descriptionColumns => 'Colonne(s) de description';

  @override
  String get referenceIdColumn =>
      'Colonne d\'identifiant de référence (facultatif)';

  @override
  String get skippedRows => 'Lignes ignorées';

  @override
  String parsedTransactionCount(String count) {
    return '$count transactions analysées';
  }

  @override
  String skippedOrExcludedCount(String count) {
    return '$count ignorées ou exclues';
  }

  @override
  String postedFailedCount(String posted, String failed) {
    return '$posted enregistrées, $failed échouées';
  }

  @override
  String get categoryForAll => 'Catégorie pour toutes';

  @override
  String get saveAsRule => 'Enregistrer comme règle ?';

  @override
  String get saveAsRuleBlurb =>
      'Les prochaines importations dont la description contient ce mot-clé utiliseront cette catégorie.';

  @override
  String get keyword => 'Mot-clé';

  @override
  String get noSavedRules =>
      'Aucune règle enregistrée pour l\'instant. Attribuez une catégorie à un groupe de lignes pour enregistrer une règle.';

  @override
  String get deleteRuleTitle => 'Supprimer la règle ?';

  @override
  String get editRule => 'Modifier la règle';

  @override
  String rowsGrouped(String count) {
    return '$count lignes';
  }

  @override
  String selectStatementFile(String extensions) {
    return 'Sélectionnez un fichier de relevé $extensions à importer';
  }

  @override
  String get payeesTitle => 'Bénéficiaires';

  @override
  String get addPayee => 'Ajouter un bénéficiaire';

  @override
  String get renamePayee => 'Renommer le bénéficiaire';

  @override
  String get deletePayeeTitle => 'Supprimer le bénéficiaire ?';

  @override
  String get noPayeesYet => 'Aucun bénéficiaire pour l\'instant';

  @override
  String get recurringTitle => 'Modèles récurrents';

  @override
  String get noRecurringYet => 'Aucun modèle récurrent pour l\'instant';

  @override
  String get deleteTemplateTitle => 'Supprimer le modèle récurrent ?';

  @override
  String get dayOfMonth => 'Jour du mois (1-31)';

  @override
  String get dayOfMonthNote =>
      'Un mois comportant moins de jours utilise son propre dernier jour.';

  @override
  String dayOfMonthLine(String day) {
    return 'Jour $day du mois - ';
  }

  @override
  String get name => 'Nom';

  @override
  String get none => 'Aucun';

  @override
  String get currency => 'Devise';

  @override
  String get errorGeneric => 'Une erreur s\'est produite. Réessayez.';

  @override
  String get errorSigningIdentityMismatch =>
      'Cette phrase de récupération ou ce fichier de clés ne correspond à aucune identité de signature dans cette base de données.';

  @override
  String get errorInvalidLedgerBackup =>
      'Ce fichier n\'est pas une sauvegarde Smara valide.';

  @override
  String get errorInvalidLedgerBackupNoIdentity =>
      'Cette sauvegarde n\'a pas d\'identité de signature - ce n\'est pas une sauvegarde Smara valide.';

  @override
  String get errorInvalidLedgerBackupUnverified =>
      'Cette sauvegarde n\'a pas été vérifiée comme des livres intacts, elle n\'a donc pas été restaurée.';

  @override
  String errorInvalidLedgerBackupUnreadable(String detail) {
    return 'Ce fichier n\'a pas pu être ouvert comme sauvegarde Smara : $detail';
  }

  @override
  String get errorForeignBackupIdentity =>
      'Cette sauvegarde appartient à une identité de signature différente de celle de cet appareil.';

  @override
  String get errorAccountNotFinancial => 'Ce n\'est pas un compte financier.';

  @override
  String get errorAccountArchived => 'Ce compte est masqué.';

  @override
  String get errorAccountNotArchived => 'Ce compte n\'est pas masqué.';

  @override
  String get errorAccountNoPositiveBalanceToCloseOut =>
      'Il ne reste aucun solde à transférer.';

  @override
  String get errorAccountHasNoGroup => 'Ce compte n\'a aucun groupe attribué.';

  @override
  String get errorGroupHasNoCurrency =>
      'Ce groupe n\'a pas encore de devise définie.';

  @override
  String get errorGroupNotFound => 'Ce groupe de comptes est introuvable.';

  @override
  String get errorInvestmentAccountsMustBeAssets =>
      'Seuls les comptes d\'actif peuvent être marqués comme comptes d\'investissement.';

  @override
  String get errorCreditCardsMustBeLiabilities =>
      'Seuls les comptes de passif peuvent être marqués comme cartes de crédit.';

  @override
  String get errorOpeningBalanceMustBePositive =>
      'Le solde initial doit être positif lorsqu\'il est renseigné.';

  @override
  String get errorAccountTypeDoesNotMatchGroup =>
      'Ce type de compte ne correspond pas au groupe.';

  @override
  String get errorLastActiveAccount =>
      'Impossible de masquer le dernier compte financier actif.';

  @override
  String get errorCurrencyRequiredToCreateGroup =>
      'Une devise est requise pour créer un groupe.';

  @override
  String get errorSystemGroupCannotBeArchived =>
      'Les groupes de comptes intégrés ne peuvent pas être masqués.';

  @override
  String get errorGroupAlreadyArchived => 'Ce groupe est déjà masqué.';

  @override
  String get errorCannotArchiveGroupWithAccounts =>
      'Impossible de masquer un groupe qui a encore des comptes actifs.';

  @override
  String get errorSystemGroupNeverArchived =>
      'Les groupes de comptes intégrés ne sont jamais masqués.';

  @override
  String get errorAccountGroupsCannotBeDeleted =>
      'Les groupes de comptes ne peuvent pas être supprimés.';

  @override
  String get errorCannotReassignDifferentCurrency =>
      'Impossible de déplacer ce compte vers un groupe avec une devise différente.';

  @override
  String get errorCannotChangeGroupCurrencyWithAccounts =>
      'Impossible de changer la devise tant que le groupe a des comptes actifs.';

  @override
  String get errorAmountMustBePositive => 'Le montant doit être positif.';

  @override
  String get errorAccountCurrencyAmountMustBePositive =>
      'Le montant en devise du compte doit être positif.';

  @override
  String get errorAccountCurrencyAmountNotForSameCurrency =>
      'Le montant en devise du compte n\'est valable que pour une écriture en devise étrangère.';

  @override
  String get errorSplitNeedsTwoLines =>
      'Une répartition nécessite au moins deux lignes de catégorie.';

  @override
  String get errorSplitLineMustBePositive =>
      'Chaque ligne de répartition doit être un montant positif.';

  @override
  String get errorSplitLinesMustSumToTotal =>
      'Les lignes de répartition doivent totaliser le montant de la transaction.';

  @override
  String get errorTransferAmountMustBePositive =>
      'Le montant du virement doit être positif.';

  @override
  String get errorTransferAccountsMustDiffer =>
      'Les comptes source et de destination doivent être différents.';

  @override
  String get errorCloseoutRequiresDestinationAmount =>
      'Une clôture entre devises nécessite un montant de destination connu.';

  @override
  String get errorDestinationAmountNotForSameCurrency =>
      'Le montant de destination n\'est valable que pour un virement entre devises.';

  @override
  String get errorDestinationAmountMustBePositive =>
      'Le montant de destination doit être positif.';

  @override
  String get errorInvestmentCashExceeded =>
      'Impossible de transférer plus que les liquidités de ce compte d\'investissement.';

  @override
  String get errorCannotReverseUnsettledProvisional =>
      'Réglez ce virement en attente au lieu de l\'annuler.';

  @override
  String get errorAlreadyReversed =>
      'Cette écriture a déjà été corrigée. La ligne d\'origine reste telle quelle.';

  @override
  String get errorNotActiveExpenseCategory =>
      'Choisissez une catégorie de dépense active.';

  @override
  String get errorNotActiveIncomeCategory =>
      'Choisissez une catégorie de revenu active.';

  @override
  String get errorSettledAmountMustNotBeNegative =>
      'Le montant reçu ne peut pas être négatif.';

  @override
  String get errorPendingTransferNotFound =>
      'Ce virement en attente est introuvable.';

  @override
  String get errorPendingTransferAlreadySettled =>
      'Ce virement en attente est déjà réglé.';

  @override
  String get errorSettledToMustBeSourceOrDestination =>
      'Choisissez le compte source ou de destination d\'origine.';

  @override
  String get errorFeeCategoryOnlyWhenReturningToSource =>
      'Une catégorie de frais n\'est utilisée que lorsque l\'argent est retourné au compte source.';

  @override
  String get errorSettledAmountMustBePositiveForDelivery =>
      'Saisissez un montant positif pour ce qui est arrivé.';

  @override
  String get errorSettledAmountExceedsProvisional =>
      'Ce montant est supérieur à celui envoyé.';

  @override
  String get errorInstrumentNotFound => 'Cet instrument est introuvable.';

  @override
  String get errorIncomeRequiredForNonCash =>
      'Une catégorie de revenu active est requise pour une acquisition hors trésorerie.';

  @override
  String get errorInsufficientCash =>
      'Trésorerie insuffisante dans ce compte d\'investissement pour cet achat.';

  @override
  String get errorSellQuantityAndPriceMustBePositive =>
      'La quantité vendue et le prix unitaire doivent être positifs.';

  @override
  String errorLockedUntil(String date) {
    return 'Vente impossible : certaines unités sont bloquées jusqu\'au $date.';
  }

  @override
  String get errorInsufficientQuantity =>
      'Impossible de vendre plus que ce que vous détenez actuellement non bloqué.';

  @override
  String get errorIncomeRequiredForGain =>
      'Une catégorie de revenu active est requise pour une plus-value réalisée.';

  @override
  String get errorExpenseRequiredForLoss =>
      'Une catégorie de dépense active est requise pour une moins-value réalisée.';

  @override
  String errorBrokerageFailedAfterBuy(String detail) {
    return 'Achat comptabilisé, mais les frais de courtage ont échoué : $detail';
  }

  @override
  String errorBrokerageFailedAfterSell(String detail) {
    return 'Vente comptabilisée, mais les frais de courtage ont échoué : $detail';
  }

  @override
  String get errorDividendMustBePositive =>
      'Le montant du dividende doit être positif.';

  @override
  String get errorNotInvestmentAccount =>
      'Ce n\'est pas un compte d\'investissement.';

  @override
  String get errorNoInventoryCompanion =>
      'Ce compte d\'investissement n\'a pas son compte d\'inventaire associé.';

  @override
  String errorInvestmentReversalBlocked(String sells) {
    return 'Impossible d\'annuler cet achat : des ventes ultérieures dépendent de ses unités. Annulez d\'abord les ventes dépendantes : $sells.';
  }

  @override
  String get errorMonthlyLimitMustBePositive =>
      'La limite mensuelle doit être positive.';

  @override
  String get errorTemplateAmountMustBePositive =>
      'Le montant du modèle doit être positif.';

  @override
  String get errorOfxUnrecognized =>
      'Ce fichier n\'a pas pu être reconnu comme OFX.';

  @override
  String get errorCsvEmpty => 'Le fichier sélectionné est vide.';

  @override
  String get errorCsvUnreadable => 'Ce fichier n\'a pas pu être lu comme CSV.';

  @override
  String get errorCsvNoRows =>
      'Le fichier sélectionné ne contient aucune ligne.';

  @override
  String get skipMissingDate => 'Date manquante.';

  @override
  String skipUnparseableDate(String raw, String pattern) {
    return 'Impossible d\'interpréter la date \"$raw\" avec le format \"$pattern\".';
  }

  @override
  String get skipOfxMissingOrInvalidDate =>
      'Date de transaction manquante ou invalide.';

  @override
  String skipOfxUnparseableDate(String raw) {
    return 'Impossible d\'interpréter la date de transaction \"$raw\".';
  }

  @override
  String get skipMissingAmount => 'Montant manquant.';

  @override
  String skipUnparseableAmount(String raw) {
    return 'Impossible d\'interpréter le montant \"$raw\".';
  }

  @override
  String get skipZeroAmount => 'Le montant est nul.';

  @override
  String get skipUnparseableDebitCreditAmount =>
      'Impossible d\'interpréter le montant débit ou crédit.';

  @override
  String get skipBothDebitAndCreditNonZero =>
      'Les colonnes débit et crédit contiennent toutes deux un montant.';

  @override
  String get skipBothDebitAndCreditZero =>
      'Les colonnes débit et crédit sont toutes deux nulles.';

  @override
  String errorBackupCreateFailed(String detail) {
    return 'Impossible de créer la sauvegarde : $detail';
  }

  @override
  String get errorBackupRestoreFailed =>
      'Impossible de restaurer cette sauvegarde - phrase secrète incorrecte, ou ce n\'est pas un fichier de sauvegarde Smara.';

  @override
  String get validationAmountAccountCategoryRequired =>
      'Le montant, le compte et la catégorie sont requis.';

  @override
  String get validationAmountAccountRequired =>
      'Le montant et le compte sont requis.';

  @override
  String get validationSplitLineIncomplete =>
      'Chaque ligne de répartition nécessite une catégorie et un montant.';

  @override
  String get validationSplitSumMismatch =>
      'Les lignes de répartition doivent totaliser le montant de la transaction.';

  @override
  String get validationFromToAmountRequired =>
      'Le compte source, le compte de destination et le montant sont requis.';

  @override
  String get validationAmountArrivedRequired => 'Le montant reçu est requis.';

  @override
  String get validationChooseReceivingAccount =>
      'Choisissez le compte ayant reçu les fonds.';

  @override
  String get validationAccountCategoryRequired =>
      'Le compte et la catégorie sont requis.';

  @override
  String get validationFixFailed =>
      'Impossible d\'enregistrer cette correction.';

  @override
  String get validationNameRequired => 'Nommez votre compte principal.';

  @override
  String get validationStillLoading =>
      'Chargement en cours - réessayez dans un instant.';

  @override
  String get validationSaveAccountNameFailed =>
      'Impossible d\'enregistrer le nom du compte.';

  @override
  String get validationWrongPin => 'Code incorrect. Réessayez.';

  @override
  String get validationCategoryMustBeIncomeOrExpense =>
      'La catégorie doit être Revenu ou Dépense.';

  @override
  String get validationOnlyExpenseHasMonthlyLimit =>
      'Seule une catégorie de dépense peut avoir une limite mensuelle.';

  @override
  String get validationInvalidTemplate => 'Modèle non valide.';

  @override
  String get validationWrongKeystorePassphrase =>
      'Phrase secrète incorrecte pour ce fichier de clés.';

  @override
  String get validationInvalidKeystoreFile =>
      'Cela ne ressemble pas à un fichier de clés valide.';

  @override
  String get validationRestorePhraseFailed =>
      'Impossible de restaurer à partir de cette phrase de récupération.';

  @override
  String validationGenerateKeyFailed(String detail) {
    return 'Impossible de générer une clé de signature sur cet appareil : $detail';
  }

  @override
  String validationSaveCurrencyFailed(String detail) {
    return 'Impossible d\'enregistrer cette devise : $detail';
  }

  @override
  String get validationMigrationFailed => 'Échec de la migration. Réessayez.';

  @override
  String get validationChooseBackupFile =>
      'Choisissez d\'abord un fichier de sauvegarde.';

  @override
  String get validationPassphraseRequired => 'Saisissez une phrase secrète.';

  @override
  String get validationPinsDoNotMatch =>
      'Les deux codes PIN ne correspondent pas.';

  @override
  String get validationFeePositiveWithCategory =>
      'Les frais de virement doivent être un montant positif avec une catégorie de dépense sélectionnée.';

  @override
  String get validationFeeMustBeLessThanAmount =>
      'Les frais doivent être inférieurs au montant pour un virement avec frais déduits.';

  @override
  String validationTransferSavedFeeFailed(String detail) {
    return 'Virement enregistré, mais les frais n\'ont pas pu être enregistrés : $detail';
  }

  @override
  String get validationEnterValidAmount => 'Saisissez un montant valide.';

  @override
  String validationConfirmWordMismatch(String n) {
    return 'Le mot $n ne correspond pas à votre phrase enregistrée. Vérifiez-le et réessayez.';
  }

  @override
  String get errorBuyQuantityAndPriceMustBePositive =>
      'La quantité achetée et le prix unitaire doivent être positifs.';

  @override
  String get errorInstrumentArchived =>
      'Impossible d\'acheter un instrument masqué.';

  @override
  String get errorNonCashCannotIncludeBrokerage =>
      'Les acquisitions hors trésorerie ne peuvent pas inclure de frais de courtage.';

  @override
  String get errorBrokerageRequiresExpenseCategory =>
      'Une catégorie de dépense active est requise lorsque les frais de courtage sont positifs.';

  @override
  String get errorSellProceedsMustCoverBrokerage =>
      'Le produit de la vente doit être au moins égal aux frais de courtage.';

  @override
  String homeSpentOfLimitThisMonth(String spent, String limit) {
    return '$spent sur $limit ce mois-ci';
  }

  @override
  String get unlockBiometricReason => 'Déverrouiller Smara Account';

  @override
  String get searchLabel => 'Rechercher';

  @override
  String get openingBalance => 'Solde initial';

  @override
  String transferToName(String name) {
    return 'Virement : $name';
  }

  @override
  String get feeForTransfer => 'Frais de virement';

  @override
  String feeForTransferTo(String name) {
    return 'Frais de virement à $name';
  }

  @override
  String couldNotOpenFilePicker(String detail) {
    return 'Impossible d\'ouvrir le sélecteur de fichiers : $detail';
  }

  @override
  String pleaseSelectFile(String extensions) {
    return 'Veuillez sélectionner un fichier .$extensions';
  }

  @override
  String get currencyCodeIso => 'Code de devise (ISO 4217, p. ex. USD)';

  @override
  String splitCounterpartMore(String name, String count) {
    return '$name et $count de plus';
  }

  @override
  String get dateLabel => 'Date';

  @override
  String get noneSelected => 'Aucun';

  @override
  String reviewEntriesBeforeContinuing(String count) {
    return 'Vérifiez les écritures ci-dessous ($count au total) avant de continuer.';
  }

  @override
  String youReceived(String amount) {
    return 'Vous avez reçu $amount';
  }

  @override
  String get leaveBlankIfRateUnknown =>
      'Laissez vide si le taux de change n\'est pas encore connu.';

  @override
  String get recordTradeBlurb =>
      'Enregistrez une opération déjà réalisée. Cette application ne passe pas d\'ordres.';

  @override
  String get feeOnTopBlurb =>
      'Activé : le montant ci-dessus est le total prélevé sur ce compte ; les frais en sont déduits.';

  @override
  String get feeBankBlurb =>
      'Une commission prélevée d\'avance par votre banque ou un intermédiaire.';

  @override
  String get validationPinMinLength =>
      'Le code PIN doit comporter au moins 4 chiffres.';

  @override
  String get restoreBackupBlurb =>
      'Cela remplace tout ce qui se trouve actuellement dans cette application par la sauvegarde — il n\'y a pas de fusion. Choisissez un fichier de sauvegarde et saisissez la phrase secrète avec laquelle vous l\'avez protégé.';

  @override
  String get actionReplace => 'Remplacer';

  @override
  String hideAccountBody(String name) {
    return '$name ne sera plus disponible pour les nouvelles transactions.';
  }

  @override
  String hideGroupBody(String name) {
    return '$name ne sera plus proposé lors de la création ou de la réattribution de comptes.';
  }

  @override
  String hideCategoryBody(String name) {
    return '$name ne sera plus proposée lors de l\'enregistrement de nouvelles transactions.';
  }

  @override
  String get hideInstrumentBody =>
      'Les instruments masqués restent sur les achats et ventes passés. Vous pouvez toujours enregistrer un dividende pour eux.';

  @override
  String nameHidden(String name) {
    return '$name (masqué)';
  }

  @override
  String get noCurrencySet => 'Aucune devise définie';

  @override
  String deletePayeeBody(String name) {
    return '$name et ses valeurs par défaut mémorisées seront supprimés. Les transactions passées ne sont pas affectées.';
  }

  @override
  String deleteTemplateBody(String name) {
    return '$name ne sera plus proposé comme échéance. Les transactions passées qu\'il a déjà enregistrées ne sont pas affectées.';
  }

  @override
  String deleteProfileBody(String name) {
    return 'Le mappage de colonnes enregistré « $name » sera supprimé. Les relevés déjà importés avec celui-ci ne sont pas affectés.';
  }

  @override
  String deleteRuleBody(String keyword) {
    return 'Les importations ne seront plus catégorisées automatiquement par « $keyword ». Les transactions déjà catégorisées avec cette règle ne sont pas affectées.';
  }

  @override
  String get firstWeekBlurb =>
      'Ajoutez éventuellement une carte de crédit ou un compte espèces dès maintenant - vous pourrez toujours ajouter d\'autres comptes plus tard depuis les Paramètres.';

  @override
  String get deliveredToDestination => 'Livré à destination';

  @override
  String deliveredToName(String name) {
    return 'Livré à $name';
  }

  @override
  String youReceivedLessThanExpected(String amount, String currency) {
    return 'Vous avez reçu $amount $currency de moins que prévu - choisissez une catégorie pour couvrir la différence.';
  }

  @override
  String get dateRangeLabel => 'Plage de dates';

  @override
  String get addTemplate => 'Ajouter un modèle';

  @override
  String get editTemplate => 'Modifier le modèle';

  @override
  String get validationFillTemplateFields =>
      'Remplissez tous les champs avec un montant et un jour valides.';

  @override
  String get saveCsvExport => 'Enregistrer l\'export CSV';

  @override
  String get referenceRate => 'Taux de référence';

  @override
  String get yourRate => 'Votre taux';

  @override
  String leaveBlankIfThisWasAccountCurrency(String currency) {
    return 'Laissez vide si c\'était en $currency, la devise propre du compte.';
  }

  @override
  String get lockUntilOptional => 'Bloqué jusqu\'au (facultatif)';

  @override
  String lockedUntilDate(String date) {
    return 'Bloqué jusqu\'au $date';
  }

  @override
  String get copiedResearchPrompt =>
      'Une requête de recherche a été copiée — aucune URL de navigateur disponible, ou vous êtes hors ligne.';

  @override
  String get openedFavouriteResearchTool =>
      'Votre outil de recherche favori a été ouvert.';

  @override
  String get looksLikeGain => 'Cela ressemble à une plus-value';

  @override
  String get looksLikeLoss => 'Cela ressemble à une moins-value';

  @override
  String get looksLikeBreakEven => 'Cela ressemble à un seuil de rentabilité';

  @override
  String sellableQuantity(String name, String qty) {
    return '$name ($qty vendable)';
  }

  @override
  String columnN(String index) {
    return 'Colonne $index';
  }

  @override
  String get importingLabel => 'Importation...';

  @override
  String get confirmImport => 'Confirmer l\'importation';

  @override
  String get manageSavedCategoryRules =>
      'Gérer les règles de catégorie enregistrées';

  @override
  String statementCurrencyMismatch(String currency) {
    return 'La devise de ce fichier ($currency) ne correspond pas à la devise du compte sélectionné.';
  }

  @override
  String get categoryRulesTitle => 'Règles de catégorie';

  @override
  String get possibleDuplicate => 'doublon possible';

  @override
  String get unknownCategory => 'Catégorie inconnue';

  @override
  String get researchPromptIntro =>
      'Recherchez cet instrument coté en bourse pour un investisseur particulier. Identifiez l\'émetteur, résumez les actualités récentes avec les dates si elles sont connues, et décrivez les risques de baisse et les moteurs de hausse. Séparez les faits des spéculations. Ne donnez pas de recommandation d\'achat, de vente ou de conservation. Ceci n\'est pas un conseil financier.';

  @override
  String researchPromptNameLine(String name) {
    return 'Nom : $name';
  }

  @override
  String researchPromptTickerLine(String ticker) {
    return 'Symbole : $ticker';
  }

  @override
  String get researchPromptTickerNoneProvided => 'Symbole : (non fourni)';

  @override
  String researchPromptIsinLine(String isin) {
    return 'ISIN : $isin';
  }

  @override
  String get researchPromptIsinNoneProvided => 'ISIN : (non fourni)';
}
