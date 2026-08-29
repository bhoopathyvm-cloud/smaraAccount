// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Smara Contabilidade';

  @override
  String get navHome => 'Início';

  @override
  String get navRegister => 'Registo';

  @override
  String get navSummary => 'Resumo';

  @override
  String get navAccounts => 'Contas';

  @override
  String get navCategories => 'Categorias';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionSave => 'Guardar';

  @override
  String get actionDelete => 'Eliminar';

  @override
  String get actionDone => 'Concluído';

  @override
  String get actionContinue => 'Continuar';

  @override
  String get actionDismiss => 'Fechar';

  @override
  String get actionRetry => 'Tentar novamente';

  @override
  String get actionSkip => 'Ignorar';

  @override
  String get actionConfirm => 'Confirmar';

  @override
  String get actionAdd => 'Adicionar';

  @override
  String get actionEdit => 'Editar';

  @override
  String get actionRename => 'Mudar o nome';

  @override
  String get actionHide => 'Ocultar';

  @override
  String get actionCreate => 'Criar';

  @override
  String get actionCloseApp => 'Fechar aplicação';

  @override
  String get actionUnlock => 'Desbloquear';

  @override
  String get actionSettle => 'Liquidar';

  @override
  String get actionFinish => 'Concluir';

  @override
  String get actionPreview => 'Pré-visualizar';

  @override
  String get actionImport => 'Importar';

  @override
  String get actionExportCsv => 'Exportar CSV';

  @override
  String get actionChooseFile => 'Escolher ficheiro';

  @override
  String get actionRestore => 'Restaurar';

  @override
  String get actionFix => 'Corrigir';

  @override
  String get actionBuy => 'Comprar';

  @override
  String get actionSell => 'Vender';

  @override
  String get actionDividend => 'Dividendo';

  @override
  String get actionRecordBuy => 'Registar compra';

  @override
  String get actionRecordSell => 'Registar venda';

  @override
  String get actionRecordDividend => 'Registar dividendo';

  @override
  String get actionPayCard => 'Pagar cartão';

  @override
  String get actionTransfer => 'Transferir';

  @override
  String get actionRecordTransaction => 'Registar transação';

  @override
  String get actionImportStatement => 'Importar extrato';

  @override
  String get actionClearDates => 'Limpar datas';

  @override
  String get actionClearSearch => 'Limpar pesquisa e filtros';

  @override
  String get actionUseBiometrics => 'Usar biometria';

  @override
  String get actionSetPin => 'Definir PIN';

  @override
  String get actionChangePin => 'Alterar PIN';

  @override
  String get actionSaveBackup => 'Guardar cópia de segurança';

  @override
  String get actionRestoreBackup => 'Restaurar cópia de segurança';

  @override
  String get actionSaveRule => 'Guardar regra';

  @override
  String get actionConfirmFix => 'Confirmar correção';

  @override
  String get captureSpent => 'Gasto';

  @override
  String get captureReceived => 'Recebido';

  @override
  String get captureMovedMoney => 'Dinheiro movimentado';

  @override
  String get captureImportStatement => 'Importar extrato';

  @override
  String get settingsTitle => 'Definições';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSystem => 'Idioma do dispositivo';

  @override
  String get settingsFetchFxRates => 'Obter taxas de câmbio de referência';

  @override
  String get settingsFetchFxRatesSubtitle =>
      'Mostra uma taxa de mercado indicativa junto ao montante de destino em transferências entre moedas, apenas para comparação - nunca é usada para preencher o montante.';

  @override
  String get settingsRateProvider => 'Fornecedor de taxas';

  @override
  String get settingsFetchMarketPrices =>
      'Obter preços de mercado para investimentos';

  @override
  String get settingsFetchMarketPricesSubtitle =>
      'Procura os últimos preços de instrumentos com ticker ou ISIN, para estimar o valor da carteira. Nunca é usado para registar uma operação, e nunca envia quantas unidades possui.';

  @override
  String get settingsMarketPriceProvider => 'Fornecedor de preços de mercado';

  @override
  String get settingsFavouriteResearchTool =>
      'Ferramenta de pesquisa preferida';

  @override
  String get settingsFavouriteResearchToolSubtitle =>
      'Tocar no nome de um instrumento nas participações abre esta ferramenta no navegador com uma pesquisa pronta — não é uma integração, nem um conselho.';

  @override
  String get settingsBackup => 'Cópia de segurança';

  @override
  String get settingsBackupBlurb =>
      'Guarde uma cópia encriptada dos seus livros num local à sua escolha, ou restaure a partir de uma. Isto é diferente da sua frase de recuperação ou ficheiro de keystore, que salvaguardam a sua chave de assinatura, não os seus livros.';

  @override
  String get settingsLock => 'Bloqueio';

  @override
  String get settingsLockBlurb =>
      'Exija um PIN, ou biometria quando disponível, para abrir a aplicação.';

  @override
  String get settingsRequireUnlock =>
      'Exigir desbloqueio para abrir a aplicação';

  @override
  String get settingsLockAfter => 'Bloquear após';

  @override
  String get settingsLockImmediately => 'Imediatamente';

  @override
  String get settingsLock1Minute => '1 minuto';

  @override
  String get settingsLock5Minutes => '5 minutos';

  @override
  String get settingsLock15Minutes => '15 minutos';

  @override
  String get settingsAllowBiometrics => 'Permitir também biometria';

  @override
  String get settingsHideSnapshot =>
      'Ocultar saldos no alternador de aplicações';

  @override
  String get settingsHideSnapshotSubtitle =>
      'Oculta este ecrã quando muda para outra aplicação, para que não fique visível à primeira vista no alternador de aplicações.';

  @override
  String get settingsHideSnapshotUnavailable =>
      'Ocultar saldos no alternador de aplicações não está disponível nesta plataforma.';

  @override
  String get settingsPayees => 'Beneficiários';

  @override
  String get settingsManagePayees => 'Gerir beneficiários';

  @override
  String get settingsPayeesBlurb =>
      'Nomes de beneficiários memorizados com a respetiva categoria e conta predefinidas, sugeridos por preenchimento automático ao registar uma transação.';

  @override
  String get settingsRecurring => 'Modelos recorrentes';

  @override
  String get settingsManageRecurring => 'Gerir modelos recorrentes';

  @override
  String get settingsRecurringBlurb =>
      'Contas ou receitas que se repetem mensalmente, como a renda ou o salário. Um modelo com vencimento aparece no Início para o registar com um toque - nunca é lançado automaticamente.';

  @override
  String get settingsAbout => 'Acerca';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get providerFrankfurter => 'Frankfurter (taxas do BCE)';

  @override
  String get providerOpenErApi => 'ExchangeRate-API (open.er-api.com)';

  @override
  String get providerStooq => 'Stooq (cotações diárias)';

  @override
  String get providerYahooFinance => 'Yahoo Finance (API de gráficos)';

  @override
  String get researchChatGpt => 'ChatGPT';

  @override
  String get researchClaude => 'Claude';

  @override
  String get researchGemini => 'Gemini';

  @override
  String get researchMetaAi => 'Meta AI';

  @override
  String get systemGroupCashEquivalents => 'Caixa e equivalentes de caixa';

  @override
  String get systemGroupPensionRetirement => 'Pensão e reforma';

  @override
  String get systemGroupCreditShortTerm => 'Crédito e dívida de curto prazo';

  @override
  String get systemGroupLoansMortgages => 'Empréstimos e hipotecas';

  @override
  String get systemGroupInvestments => 'Investimentos';

  @override
  String get systemAccountCashBank => 'Dinheiro e banco';

  @override
  String get systemCategorySalary => 'Salário';

  @override
  String get systemCategoryOtherIncome => 'Outras receitas';

  @override
  String get systemCategoryGroceries => 'Compras de mercearia';

  @override
  String get systemCategoryRentMortgage => 'Renda/Hipoteca';

  @override
  String get systemCategoryUtilities => 'Serviços públicos';

  @override
  String get systemCategoryTransport => 'Transportes';

  @override
  String get systemCategoryFoodOut => 'Refeições fora';

  @override
  String get systemCategoryPhone => 'Telefone';

  @override
  String get systemCategoryHealth => 'Saúde';

  @override
  String get systemCategoryOtherExpense => 'Outras despesas';

  @override
  String get systemDescriptionCsvImport => 'Importação CSV';

  @override
  String get systemDescriptionOfxImport => 'Importação OFX';

  @override
  String get homeThisMonth => 'ESTE MÊS';

  @override
  String get homeMoneyInTransit => 'DINHEIRO EM TRÂNSITO';

  @override
  String get homeWhatYouHaveMinusWhatYouOwe => 'O QUE TEM MENOS O QUE DEVE';

  @override
  String homeWhatYouHave(String amount, String currency) {
    return 'Tem $amount $currency';
  }

  @override
  String homeNetPosition(String amount, String currency) {
    return '$amount $currency';
  }

  @override
  String homeHaveAndOwe(String haveAmount, String currency, String oweAmount) {
    return 'Tem $haveAmount $currency  •  Deve $oweAmount $currency';
  }

  @override
  String youSentFrom(String amount, String currency, String name) {
    return 'Enviou $amount $currency de $name';
  }

  @override
  String youSentTo(String amount, String currency, String name) {
    return 'Enviou $amount $currency para $name';
  }

  @override
  String get hiddenLabel => 'Oculto';

  @override
  String get allAccounts => 'Todas as contas';

  @override
  String savedToPath(String path) {
    return 'Guardado em $path';
  }

  @override
  String get keystoreExportFailed =>
      'Não foi possível exportar o ficheiro de keystore. Pode ignorar este passo.';

  @override
  String get enterPassphraseToProtect =>
      'Introduza uma frase-passe para proteger o ficheiro.';

  @override
  String get homeTapWhenArrived => 'Toque quando souber o que chegou';

  @override
  String homeReturnedTo(String name) {
    return 'Devolvido a $name';
  }

  @override
  String get homeDueToday => 'VENCE HOJE';

  @override
  String homeDueLine(String category, String account) {
    return '$category · $account · toque para registar';
  }

  @override
  String get homeOverLimit => 'Acima do limite';

  @override
  String homeSpentOfLimit(String spent, String limit) {
    return '$spent de $limit';
  }

  @override
  String homeRemaining(String amount) {
    return 'Restante: $amount';
  }

  @override
  String get homeNoAccounts => 'Sem contas';

  @override
  String get homeCashRegister => 'Caixa';

  @override
  String get homeMarketEstimate => 'Estimativa de mercado';

  @override
  String get registerTitle => 'Registo';

  @override
  String get registerSearchHint => 'Descrição, categoria ou montante';

  @override
  String get registerNoTransactions => 'Ainda não há transações';

  @override
  String get registerNoEntries => 'Ainda não há lançamentos registados.';

  @override
  String get registerSpentOnly => 'Apenas despesas';

  @override
  String get registerReceivedOnly => 'Apenas receitas';

  @override
  String get registerAll => 'Todas';

  @override
  String get registerUnverified => 'Não verificado - excluído dos totais';

  @override
  String get registerSuperseded =>
      'Substituído pela migração - excluído dos totais';

  @override
  String get summaryTitle => 'Resumo';

  @override
  String get summaryTotalIncome => 'Total de receitas';

  @override
  String get summaryTotalExpense => 'Total de despesas';

  @override
  String summaryDateRange(String start, String end) {
    return '$start a $end';
  }

  @override
  String get accountsTitle => 'Contas';

  @override
  String get categoriesTitle => 'Categorias';

  @override
  String get accountName => 'Nome da conta';

  @override
  String get createAccount => 'Criar conta';

  @override
  String get createGroup => 'Criar grupo';

  @override
  String get editGroup => 'Editar grupo';

  @override
  String get renameAccount => 'Mudar o nome da conta';

  @override
  String get renameCategory => 'Mudar o nome da categoria';

  @override
  String get addCategory => 'Adicionar categoria';

  @override
  String get groupLabel => 'Grupo';

  @override
  String get kindLabel => 'Tipo';

  @override
  String get asset => 'Ativo';

  @override
  String get liability => 'Passivo';

  @override
  String get income => 'Receita';

  @override
  String get expense => 'Despesa';

  @override
  String get thisAccountHoldsInvestments => 'Esta conta contém investimentos';

  @override
  String get thisAccountHoldsInvestmentsSubtitle =>
      'Dinheiro mais o inventário que regista com Comprar, Vender e Dividendo.';

  @override
  String get thisIsACreditCard => 'Este é um cartão de crédito';

  @override
  String get openingBalanceOptional => 'Saldo inicial (opcional)';

  @override
  String get currencyIso => 'Moeda (ISO 4217)';

  @override
  String get currencyIsoExample => 'Moeda (ISO 4217, ex.: USD)';

  @override
  String get hideAccountTitle => 'Ocultar a conta de novos lançamentos?';

  @override
  String get hideCategoryTitle => 'Ocultar a categoria de novos lançamentos?';

  @override
  String get hideGroupTitle => 'Ocultar o grupo de novos lançamentos?';

  @override
  String get reassignGroup => 'Reatribuir grupo';

  @override
  String get transferRemainingBalance => 'Transferir saldo remanescente';

  @override
  String get monthlyLimit => 'Limite mensal';

  @override
  String get monthlyLimitHint => 'Limite (deixe em branco para remover)';

  @override
  String get monthlyLimitBlurb =>
      'Um guia opcional de despesas do mês até à data para esta categoria de despesa.';

  @override
  String get manageCategoryRules => 'Gerir regras de categorias';

  @override
  String get amount => 'Montante';

  @override
  String get category => 'Categoria';

  @override
  String get account => 'Conta';

  @override
  String get fromAccount => 'Conta de origem';

  @override
  String get toAccount => 'Conta de destino';

  @override
  String get descriptionOptional => 'Descrição (opcional)';

  @override
  String get alsoRememberPayee => 'Memorizar também como beneficiário';

  @override
  String get splitIntoCategories => 'Dividir em várias categorias';

  @override
  String categoryN(String n) {
    return 'Categoria $n';
  }

  @override
  String get destinationAmount => 'Montante de destino';

  @override
  String get destinationAmountOptional => 'Montante de destino (opcional)';

  @override
  String get accountCurrencyAmountOptional =>
      'Montante na moeda da conta (opcional)';

  @override
  String get transactionCurrencyOptional => 'Moeda da transação (opcional)';

  @override
  String get feeOptional => 'Comissão (opcional)';

  @override
  String get feeAmount => 'Valor da comissão';

  @override
  String get feeCategory => 'Categoria da comissão';

  @override
  String get feeDescriptionOptional => 'Descrição da comissão (opcional)';

  @override
  String get feeDeducted => 'A comissão é deduzida do montante acima';

  @override
  String get needTwoAccountsToTransfer =>
      'Crie pelo menos duas contas ativas para fazer uma transferência.';

  @override
  String get whatArrivedTitle => 'O que chegou?';

  @override
  String get whatArrivedBlurb => 'Diga-nos o que realmente chegou.';

  @override
  String get amountThatArrived => 'Montante que chegou';

  @override
  String get feeLossCategory => 'Categoria de comissão / perda';

  @override
  String get alreadySettled => 'Já liquidado.';

  @override
  String get holdingsTitle => 'Carteira';

  @override
  String get holdingsCash => 'Dinheiro';

  @override
  String get holdingsInventory => 'INVENTÁRIO';

  @override
  String holdingsBook(String amount, String currency) {
    return 'Valor contabilístico (dinheiro + custo) $amount $currency';
  }

  @override
  String holdingsMarketEstimate(String amount, String currency) {
    return 'Estimativa de mercado $amount $currency';
  }

  @override
  String get holdingsNoHoldings =>
      'Ainda não há participações. Registe uma compra para adicionar um instrumento.';

  @override
  String get holdingsQuotesBlurb =>
      'As cotações são estimativas, não um preço de corretora. Esta aplicação não executa ordens.';

  @override
  String get holdingsTapNameToResearch =>
      'Toque no nome para pesquisar. As cotações são estimativas, não um conselho.';

  @override
  String get instrument => 'Instrumento';

  @override
  String get newInstrument => 'Novo instrumento';

  @override
  String get renameInstrument => 'Mudar o nome do instrumento';

  @override
  String get instrumentActions => 'Ações do instrumento';

  @override
  String hideInstrumentTitle(String name) {
    return 'Ocultar $name?';
  }

  @override
  String get tickerOptional => 'Símbolo (opcional)';

  @override
  String get isinOptional => 'ISIN (opcional)';

  @override
  String get quantity => 'Quantidade';

  @override
  String get unitPrice => 'Preço unitário';

  @override
  String get brokerageOptional => 'Corretagem (opcional)';

  @override
  String get brokerageExpenseCategory => 'Categoria de despesa de corretagem';

  @override
  String get incomeCategory => 'Categoria de receita';

  @override
  String get gainIncomeCategory => 'Categoria de receita de mais-valia';

  @override
  String get lossExpenseCategory => 'Categoria de despesa de menos-valia';

  @override
  String get nonCash => 'Não monetário';

  @override
  String get cash => 'Dinheiro';

  @override
  String get locked => 'Bloqueado';

  @override
  String get lockUntilHint =>
      'A sua própria nota sobre uma restrição, não uma regra da corretora.';

  @override
  String get instrumentKindStock => 'Ação';

  @override
  String get instrumentKindEtf => 'ETF';

  @override
  String get instrumentKindMutualFund => 'Fundo de investimento';

  @override
  String get instrumentKindBond => 'Obrigação';

  @override
  String get instrumentKindOther => 'Outro';

  @override
  String get quoteUseLive => 'Preço em tempo real';

  @override
  String get quoteUseCached => 'Preço em cache';

  @override
  String get quoteUseStale => 'Preço desatualizado';

  @override
  String get quoteUseMissing => 'A usar o custo (sem preço)';

  @override
  String get quoteUseDisabled => 'Cotações desativadas — a usar custo/cache';

  @override
  String get quoteUseCurrencyMismatch =>
      'A usar o custo (moeda do preço diferente)';

  @override
  String unrealizedLabel(String amount, String currency) {
    return 'Não realizado $amount $currency';
  }

  @override
  String holdingsUnitsCost(String qty) {
    return '$qty unidades · ';
  }

  @override
  String get recoveryPhraseTitle => 'A sua frase de recuperação';

  @override
  String get recoveryPhraseConfirmTitle => 'Confirme a sua frase';

  @override
  String get recoveryPhraseBlurb =>
      'Estas 24 palavras são a única forma de recuperar o seu histórico de transações se este dispositivo for perdido, reposto ou substituído. A Smara Accounting não tem servidor e não pode recuperá-las por si.\n\nSe perder este dispositivo e esta frase juntos, todas as transações que registou tornam-se permanentemente impossíveis de verificar.';

  @override
  String get recoveryPhraseWriteDown =>
      'Escreva estas palavras pela ordem indicada e guarde-as num local seguro, separado deste dispositivo.';

  @override
  String get iveSavedRecoveryPhrase => 'Guardei a minha frase de recuperação';

  @override
  String get confirmPhraseBlurb =>
      'Introduza as palavras pedidas da frase que acabou de guardar.';

  @override
  String wordNumber(String n) {
    return 'Palavra n.º $n';
  }

  @override
  String get keystoreExportTitle => 'Exportar ficheiro de keystore';

  @override
  String get keystoreExportBlurb =>
      'Além da sua frase de recuperação, pode guardar um ficheiro de keystore encriptado, protegido por uma frase-passe à sua escolha. Isto é opcional - a sua frase de recuperação sozinha é sempre suficiente para restaurar a sua chave de assinatura.';

  @override
  String get keystorePassphrase => 'Frase-passe';

  @override
  String get exportKeystoreFile => 'Exportar ficheiro de keystore';

  @override
  String get chooseCurrencyTitle => 'Escolha a sua moeda';

  @override
  String get chooseCurrencyBlurb =>
      'Cada grupo de contas (Caixa e equivalentes de caixa, Pensão e reforma, etc.) usa esta única moeda por agora. Pode sempre adicionar contas numa moeda diferente mais tarde, criando um novo grupo para isso.';

  @override
  String get currencyBackfillTitle =>
      'Escolha uma moeda para os grupos existentes';

  @override
  String get currencyBackfillBlurb =>
      'Esta aplicação agora suporta várias moedas. As suas contas e grupos de contas existentes precisam de uma moeda - como foram todos criados antes desta funcionalidade existir, uma única escolha aplica-se a todos.';

  @override
  String get firstAccountTitle => 'Dê um nome à sua conta';

  @override
  String get firstAccountBlurb =>
      'Esta é a conta já configurada para si - dê-lhe um nome que reconheça, como o do seu banco. A seguir vai registar um Gasto ou Recebimento, e depois proteger o dispositivo com a sua frase de recuperação.';

  @override
  String get whatsMainAccountCalled => 'Como se chama a sua conta principal?';

  @override
  String get restoreTitle => 'Restaurar chave de assinatura';

  @override
  String get restoreBlurb =>
      'Este dispositivo tem livros existentes, mas nenhuma chave de assinatura correspondente. Restaure-a a partir da sua frase de recuperação guardada ou do ficheiro de keystore - os seus dados serão verificados normalmente, e nada será novamente assinado ou alterado.';

  @override
  String get recoveryPhrase24 => 'Frase de recuperação (todas as 24 palavras)';

  @override
  String get keystoreFile => 'Ficheiro de keystore';

  @override
  String get keystoreFileContents => 'Conteúdo do ficheiro de keystore';

  @override
  String get optionalBackupFile => 'Ficheiro de cópia de segurança opcional';

  @override
  String get iDontHavePhrase =>
      'Não tenho a minha frase de recuperação nem o ficheiro de keystore';

  @override
  String get migrationTitle => 'Migrar para uma nova chave';

  @override
  String get migrationBlurb =>
      'Sem a sua frase de recuperação ou ficheiro de keystore, a chave de assinatura deste dispositivo não pode ser recuperada. Pode iniciar uma nova chave. As entradas antigas continuam visíveis mas são substituídas.';

  @override
  String get iConfirmBooksValid => 'Confirmo que os livros atuais são válidos';

  @override
  String get whyWeDontEdit => 'Porque não editamos lançamentos antigos';

  @override
  String get whyWeDontEditBody =>
      'Quando corrige um erro, mantemos a linha antiga e adicionamos uma correção ao lado dela, em vez de alterar o que já introduziu. Assim, o seu histórico mostra sempre exatamente o que aconteceu e quando o corrigiu — nada muda silenciosamente nos bastidores.';

  @override
  String get lockTitle => 'Desbloquear';

  @override
  String get lockScreenTitle => 'Bloqueado';

  @override
  String get enterPinToContinue => 'Introduza o seu PIN para continuar';

  @override
  String get pinLabel => 'PIN';

  @override
  String get setPinTitle => 'Definir um PIN';

  @override
  String get currentPin => 'PIN atual';

  @override
  String get newPin => 'Novo PIN';

  @override
  String get confirmPin => 'Confirmar PIN';

  @override
  String get confirmNewPin => 'Confirmar novo PIN';

  @override
  String get firstWeekTitle => 'Configure as suas contas';

  @override
  String get addCashAccount => 'Adicionar uma conta de dinheiro';

  @override
  String get addCreditCard => 'Adicionar um cartão de crédito';

  @override
  String get cashAccountName => 'Nome da conta de dinheiro';

  @override
  String get cardName => 'Nome do cartão';

  @override
  String get paidFromBank => 'Pago a partir do banco';

  @override
  String get paidFromCard => 'Pago com o cartão';

  @override
  String get choosePassphraseTitle =>
      'Escolha uma frase-passe para proteger esta cópia de segurança. Não há forma de a recuperar se se esquecer dela.';

  @override
  String get replaceBooksTitle => 'Substituir os seus livros locais?';

  @override
  String get replaceBooksBody =>
      'Isto substitui tudo o que está atualmente nesta aplicação pela cópia de segurança. Feche e reabra a aplicação depois.';

  @override
  String get chooseBackupFileFirst =>
      'Escolha primeiro um ficheiro de cópia de segurança.';

  @override
  String get backupRestored => 'Cópia de segurança restaurada';

  @override
  String get backupRestoredBody =>
      'Os seus livros foram restaurados. Feche e reabra a aplicação para continuar.';

  @override
  String get fixThisEntry => 'Corrigir este lançamento';

  @override
  String get fixBlurb =>
      'A linha antiga mantém-se exatamente como estava. Ao confirmar, adiciona uma linha de estorno e a corrigida.';

  @override
  String get importStatementTitle => 'Importar extrato';

  @override
  String get importOfx => 'Importar OFX';

  @override
  String get importOfxQfxFile => 'Importar ficheiro OFX / QFX';

  @override
  String get importCsvFile => 'Importar ficheiro CSV';

  @override
  String get whatKindOfStatement => 'Que tipo de ficheiro de extrato tem?';

  @override
  String get chooseAccountForFile =>
      'Escolha a que conta pertence este ficheiro.';

  @override
  String get importIntoAccount => 'Importar para a conta';

  @override
  String get useSavedProfile => 'Usar um perfil guardado';

  @override
  String get saveMappingProfile =>
      'Guardar este mapeamento como perfil (opcional)';

  @override
  String get renameProfile => 'Mudar o nome do perfil';

  @override
  String get deleteProfileTitle => 'Eliminar o perfil?';

  @override
  String get fileHasHeader => 'O ficheiro tem uma linha de cabeçalho';

  @override
  String get dateColumn => 'Coluna da data';

  @override
  String get dateFormatHint => 'Formato da data (ex.: dd/MM/aaaa)';

  @override
  String get amountColumn => 'Coluna do montante';

  @override
  String get amountConvention => 'Convenção do montante';

  @override
  String get signedAmountColumn => 'Coluna de montante com sinal';

  @override
  String get separateDebitCredit => 'Colunas separadas de débito / crédito';

  @override
  String get debitColumn => 'Coluna de débito';

  @override
  String get creditColumn => 'Coluna de crédito';

  @override
  String get decimalSeparator => 'Separador decimal (. ou ,)';

  @override
  String get descriptionColumns => 'Coluna(s) de descrição';

  @override
  String get referenceIdColumn => 'Coluna de ID de referência (opcional)';

  @override
  String get skippedRows => 'Linhas ignoradas';

  @override
  String parsedTransactionCount(String count) {
    return '$count transações analisadas';
  }

  @override
  String skippedOrExcludedCount(String count) {
    return '$count ignoradas ou excluídas';
  }

  @override
  String postedFailedCount(String posted, String failed) {
    return '$posted lançadas, $failed falharam';
  }

  @override
  String get categoryForAll => 'Categoria para todas';

  @override
  String get saveAsRule => 'Guardar como regra?';

  @override
  String get saveAsRuleBlurb =>
      'Futuras importações cuja descrição contenha esta palavra-chave usarão esta categoria.';

  @override
  String get keyword => 'Palavra-chave';

  @override
  String get noSavedRules =>
      'Ainda não há regras guardadas. Atribua uma categoria a um grupo de linhas para guardar uma regra.';

  @override
  String get deleteRuleTitle => 'Eliminar a regra?';

  @override
  String get editRule => 'Editar regra';

  @override
  String rowsGrouped(String count) {
    return '$count linhas';
  }

  @override
  String selectStatementFile(String extensions) {
    return 'Selecione um ficheiro de extrato $extensions para importar';
  }

  @override
  String get payeesTitle => 'Beneficiários';

  @override
  String get addPayee => 'Adicionar beneficiário';

  @override
  String get renamePayee => 'Mudar o nome do beneficiário';

  @override
  String get deletePayeeTitle => 'Eliminar o beneficiário?';

  @override
  String get noPayeesYet => 'Ainda não há beneficiários';

  @override
  String get recurringTitle => 'Modelos recorrentes';

  @override
  String get noRecurringYet => 'Ainda não há modelos recorrentes';

  @override
  String get deleteTemplateTitle => 'Eliminar o modelo recorrente?';

  @override
  String get dayOfMonth => 'Dia do mês (1-31)';

  @override
  String get dayOfMonthNote =>
      'Um mês com menos dias usa o seu próprio último dia.';

  @override
  String dayOfMonthLine(String day) {
    return 'Dia $day do mês - ';
  }

  @override
  String get name => 'Nome';

  @override
  String get none => 'Nenhum';

  @override
  String get currency => 'Moeda';

  @override
  String get errorGeneric => 'Algo correu mal. Tente novamente.';

  @override
  String get errorSigningIdentityMismatch =>
      'Esta frase de recuperação ou ficheiro de keystore não corresponde a nenhuma identidade de assinatura nesta base de dados.';

  @override
  String get errorInvalidLedgerBackup =>
      'Este ficheiro não é uma cópia de segurança válida da Smara.';

  @override
  String get errorInvalidLedgerBackupNoIdentity =>
      'Esta cópia de segurança não tem identidade de assinatura - não é uma cópia de segurança Smara válida.';

  @override
  String get errorInvalidLedgerBackupUnverified =>
      'Esta cópia de segurança não foi verificada como livros íntegros, pelo que não foi restaurada.';

  @override
  String errorInvalidLedgerBackupUnreadable(String detail) {
    return 'Não foi possível abrir este ficheiro como uma cópia de segurança Smara: $detail';
  }

  @override
  String get errorForeignBackupIdentity =>
      'Esta cópia de segurança pertence a uma identidade de assinatura diferente da deste dispositivo.';

  @override
  String get errorAccountNotFinancial => 'Essa não é uma conta financeira.';

  @override
  String get errorAccountArchived => 'Essa conta está oculta.';

  @override
  String get errorAccountNotArchived => 'Essa conta não está oculta.';

  @override
  String get errorAccountNoPositiveBalanceToCloseOut =>
      'Não há saldo remanescente para transferir.';

  @override
  String get errorAccountHasNoGroup => 'Essa conta não tem um grupo atribuído.';

  @override
  String get errorGroupHasNoCurrency =>
      'Esse grupo ainda não tem uma moeda definida.';

  @override
  String get errorGroupNotFound => 'Esse grupo de contas não foi encontrado.';

  @override
  String get errorInvestmentAccountsMustBeAssets =>
      'Apenas contas de ativos podem ser marcadas como contas de investimento.';

  @override
  String get errorCreditCardsMustBeLiabilities =>
      'Apenas contas de passivo podem ser marcadas como cartões de crédito.';

  @override
  String get errorOpeningBalanceMustBePositive =>
      'O saldo inicial deve ser positivo quando indicado.';

  @override
  String get errorAccountTypeDoesNotMatchGroup =>
      'Esse tipo de conta não corresponde ao grupo.';

  @override
  String get errorLastActiveAccount =>
      'Não é possível ocultar a última conta financeira ativa.';

  @override
  String get errorCurrencyRequiredToCreateGroup =>
      'É necessária uma moeda para criar um grupo.';

  @override
  String get errorSystemGroupCannotBeArchived =>
      'Os grupos de contas incorporados não podem ser ocultados.';

  @override
  String get errorGroupAlreadyArchived => 'Esse grupo já está oculto.';

  @override
  String get errorCannotArchiveGroupWithAccounts =>
      'Não é possível ocultar um grupo que ainda tem contas ativas.';

  @override
  String get errorSystemGroupNeverArchived =>
      'Os grupos de contas incorporados nunca são ocultados.';

  @override
  String get errorAccountGroupsCannotBeDeleted =>
      'Os grupos de contas não podem ser eliminados.';

  @override
  String get errorCannotReassignDifferentCurrency =>
      'Não é possível mover esta conta para um grupo com uma moeda diferente.';

  @override
  String get errorCannotChangeGroupCurrencyWithAccounts =>
      'Não é possível alterar a moeda enquanto o grupo tiver contas ativas.';

  @override
  String get errorAmountMustBePositive => 'O montante deve ser positivo.';

  @override
  String get errorAccountCurrencyAmountMustBePositive =>
      'O montante na moeda da conta deve ser positivo.';

  @override
  String get errorAccountCurrencyAmountNotForSameCurrency =>
      'O montante na moeda da conta é apenas para um lançamento em moeda estrangeira.';

  @override
  String get errorSplitNeedsTwoLines =>
      'Uma divisão precisa de pelo menos duas linhas de categoria.';

  @override
  String get errorSplitLineMustBePositive =>
      'Cada linha de divisão deve ter um montante positivo.';

  @override
  String get errorSplitLinesMustSumToTotal =>
      'As linhas de divisão devem somar o total da transação.';

  @override
  String get errorTransferAmountMustBePositive =>
      'O montante da transferência deve ser positivo.';

  @override
  String get errorTransferAccountsMustDiffer =>
      'As contas de origem e destino devem ser diferentes.';

  @override
  String get errorCloseoutRequiresDestinationAmount =>
      'Um encerramento entre moedas diferentes requer um montante de destino conhecido.';

  @override
  String get errorDestinationAmountNotForSameCurrency =>
      'O montante de destino é apenas para uma transferência entre moedas diferentes.';

  @override
  String get errorDestinationAmountMustBePositive =>
      'O montante de destino deve ser positivo.';

  @override
  String get errorInvestmentCashExceeded =>
      'Não é possível transferir mais do que o dinheiro desta conta de investimento.';

  @override
  String get errorCannotReverseUnsettledProvisional =>
      'Liquide esta transferência pendente em vez de a estornar.';

  @override
  String get errorAlreadyReversed =>
      'Este lançamento já foi corrigido. A linha original mantém-se como está.';

  @override
  String get errorNotActiveExpenseCategory =>
      'Escolha uma categoria de despesa ativa.';

  @override
  String get errorNotActiveIncomeCategory =>
      'Escolha uma categoria de receita ativa.';

  @override
  String get errorSettledAmountMustNotBeNegative =>
      'O montante que chegou não pode ser negativo.';

  @override
  String get errorPendingTransferNotFound =>
      'Essa transferência pendente não foi encontrada.';

  @override
  String get errorPendingTransferAlreadySettled =>
      'Essa transferência pendente já está liquidada.';

  @override
  String get errorSettledToMustBeSourceOrDestination =>
      'Escolha a conta de origem ou de destino original.';

  @override
  String get errorFeeCategoryOnlyWhenReturningToSource =>
      'Uma categoria de comissão só é usada quando o dinheiro é devolvido à conta de origem.';

  @override
  String get errorSettledAmountMustBePositiveForDelivery =>
      'Introduza um montante positivo para o que chegou.';

  @override
  String get errorSettledAmountExceedsProvisional =>
      'Esse montante é superior ao que foi enviado.';

  @override
  String get errorInstrumentNotFound => 'Esse instrumento não foi encontrado.';

  @override
  String get errorIncomeRequiredForNonCash =>
      'É necessária uma categoria de receita ativa para uma aquisição não monetária.';

  @override
  String get errorInsufficientCash =>
      'Não há dinheiro suficiente nesta conta de investimento para essa compra.';

  @override
  String get errorSellQuantityAndPriceMustBePositive =>
      'A quantidade e o preço unitário de venda devem ser positivos.';

  @override
  String errorLockedUntil(String date) {
    return 'Não é possível vender: algumas unidades estão bloqueadas até $date.';
  }

  @override
  String get errorInsufficientQuantity =>
      'Não é possível vender mais do que atualmente detém desbloqueado.';

  @override
  String get errorIncomeRequiredForGain =>
      'É necessária uma categoria de receita ativa para uma mais-valia realizada.';

  @override
  String get errorExpenseRequiredForLoss =>
      'É necessária uma categoria de despesa ativa para uma menos-valia realizada.';

  @override
  String errorBrokerageFailedAfterBuy(String detail) {
    return 'Compra registada, mas a comissão de corretagem falhou: $detail';
  }

  @override
  String errorBrokerageFailedAfterSell(String detail) {
    return 'Venda registada, mas a comissão de corretagem falhou: $detail';
  }

  @override
  String get errorDividendMustBePositive =>
      'O montante do dividendo deve ser positivo.';

  @override
  String get errorNotInvestmentAccount =>
      'Essa não é uma conta de investimento.';

  @override
  String get errorNoInventoryCompanion =>
      'A esta conta de investimento falta o seu inventário associado.';

  @override
  String errorInvestmentReversalBlocked(String sells) {
    return 'Não é possível estornar esta compra: vendas posteriores dependem das suas unidades. Estorne primeiro as vendas dependentes: $sells.';
  }

  @override
  String get errorMonthlyLimitMustBePositive =>
      'O limite mensal deve ser positivo.';

  @override
  String get errorTemplateAmountMustBePositive =>
      'O montante do modelo deve ser positivo.';

  @override
  String get errorOfxUnrecognized =>
      'Não foi possível reconhecer este ficheiro como OFX.';

  @override
  String get errorCsvEmpty => 'O ficheiro selecionado está vazio.';

  @override
  String get errorCsvUnreadable =>
      'Não foi possível ler este ficheiro como CSV.';

  @override
  String get errorCsvNoRows => 'O ficheiro selecionado não tem linhas.';

  @override
  String get skipMissingDate => 'Data em falta.';

  @override
  String skipUnparseableDate(String raw, String pattern) {
    return 'Não foi possível interpretar a data \"$raw\" com o padrão \"$pattern\".';
  }

  @override
  String get skipOfxMissingOrInvalidDate =>
      'Data da transação em falta ou inválida.';

  @override
  String skipOfxUnparseableDate(String raw) {
    return 'Não foi possível interpretar a data da transação \"$raw\".';
  }

  @override
  String get skipMissingAmount => 'Valor em falta.';

  @override
  String skipUnparseableAmount(String raw) {
    return 'Não foi possível interpretar o valor \"$raw\".';
  }

  @override
  String get skipZeroAmount => 'O valor é zero.';

  @override
  String get skipUnparseableDebitCreditAmount =>
      'Não foi possível interpretar o valor de débito ou crédito.';

  @override
  String get skipBothDebitAndCreditNonZero =>
      'As colunas de débito e crédito têm ambas um valor.';

  @override
  String get skipBothDebitAndCreditZero =>
      'As colunas de débito e crédito são ambas zero.';

  @override
  String errorBackupCreateFailed(String detail) {
    return 'Não foi possível criar a cópia de segurança: $detail';
  }

  @override
  String get errorBackupRestoreFailed =>
      'Não foi possível restaurar esta cópia de segurança - frase-passe incorreta, ou não é um ficheiro de cópia de segurança Smara.';

  @override
  String get validationAmountAccountCategoryRequired =>
      'O montante, a conta e a categoria são obrigatórios.';

  @override
  String get validationAmountAccountRequired =>
      'O montante e a conta são obrigatórios.';

  @override
  String get validationSplitLineIncomplete =>
      'Cada linha de divisão precisa de uma categoria e um montante.';

  @override
  String get validationSplitSumMismatch =>
      'As linhas de divisão devem somar o total da transação.';

  @override
  String get validationFromToAmountRequired =>
      'A conta de origem, a conta de destino e o montante são obrigatórios.';

  @override
  String get validationAmountArrivedRequired =>
      'O montante que chegou é obrigatório.';

  @override
  String get validationChooseReceivingAccount =>
      'Escolha a conta que recebeu os fundos.';

  @override
  String get validationAccountCategoryRequired =>
      'A conta e a categoria são obrigatórias.';

  @override
  String get validationFixFailed => 'Não foi possível guardar esta correção.';

  @override
  String get validationNameRequired => 'Dê um nome à sua conta principal.';

  @override
  String get validationStillLoading =>
      'Ainda a carregar - tente novamente dentro de momentos.';

  @override
  String get validationSaveAccountNameFailed =>
      'Não foi possível guardar o nome da conta.';

  @override
  String get validationWrongPin => 'PIN incorreto. Tente novamente.';

  @override
  String get validationCategoryMustBeIncomeOrExpense =>
      'A categoria deve ser Receita ou Despesa.';

  @override
  String get validationOnlyExpenseHasMonthlyLimit =>
      'Apenas uma categoria de despesa pode ter um limite mensal.';

  @override
  String get validationInvalidTemplate => 'Modelo inválido.';

  @override
  String get validationWrongKeystorePassphrase =>
      'Frase-passe incorreta para este ficheiro de keystore.';

  @override
  String get validationInvalidKeystoreFile =>
      'Isso não parece ser um ficheiro de keystore válido.';

  @override
  String get validationRestorePhraseFailed =>
      'Não foi possível restaurar a partir dessa frase de recuperação.';

  @override
  String validationGenerateKeyFailed(String detail) {
    return 'Não foi possível gerar uma chave de assinatura neste dispositivo: $detail';
  }

  @override
  String validationSaveCurrencyFailed(String detail) {
    return 'Não foi possível guardar esta moeda: $detail';
  }

  @override
  String get validationMigrationFailed => 'A migração falhou. Tente novamente.';

  @override
  String get validationChooseBackupFile =>
      'Escolha primeiro um ficheiro de cópia de segurança.';

  @override
  String get validationPassphraseRequired => 'Introduza uma frase-passe.';

  @override
  String get validationPinsDoNotMatch => 'Os dois PIN não coincidem.';

  @override
  String get validationFeePositiveWithCategory =>
      'Uma comissão de transferência deve ser um montante positivo com uma categoria de despesa selecionada.';

  @override
  String get validationFeeMustBeLessThanAmount =>
      'A comissão deve ser inferior ao montante numa transferência com comissão deduzida.';

  @override
  String validationTransferSavedFeeFailed(String detail) {
    return 'Transferência guardada, mas não foi possível registar a comissão: $detail';
  }

  @override
  String get validationEnterValidAmount => 'Introduza um montante válido.';

  @override
  String validationConfirmWordMismatch(String n) {
    return 'A palavra $n não coincide com a sua frase guardada. Verifique-a e tente novamente.';
  }

  @override
  String get errorBuyQuantityAndPriceMustBePositive =>
      'A quantidade e o preço unitário de compra devem ser positivos.';

  @override
  String get errorInstrumentArchived =>
      'Não é possível comprar um instrumento arquivado.';

  @override
  String get errorNonCashCannotIncludeBrokerage =>
      'As aquisições não monetárias não podem incluir corretagem.';

  @override
  String get errorBrokerageRequiresExpenseCategory =>
      'É necessária uma categoria de despesa ativa quando a corretagem é positiva.';

  @override
  String get errorSellProceedsMustCoverBrokerage =>
      'As receitas da venda devem ser pelo menos o montante da corretagem.';

  @override
  String homeSpentOfLimitThisMonth(String spent, String limit) {
    return '$spent de $limit este mês';
  }

  @override
  String get unlockBiometricReason => 'Desbloquear Smara Accounting';

  @override
  String get searchLabel => 'Pesquisar';

  @override
  String get openingBalance => 'Saldo inicial';

  @override
  String transferToName(String name) {
    return 'Transferência: $name';
  }

  @override
  String get feeForTransfer => 'Comissão de transferência';

  @override
  String feeForTransferTo(String name) {
    return 'Comissão de transferência para $name';
  }

  @override
  String couldNotOpenFilePicker(String detail) {
    return 'Não foi possível abrir o seletor de ficheiros: $detail';
  }

  @override
  String pleaseSelectFile(String extensions) {
    return 'Selecione um ficheiro .$extensions';
  }

  @override
  String get currencyCodeIso => 'Código da moeda (ISO 4217, ex.: USD)';

  @override
  String splitCounterpartMore(String name, String count) {
    return '$name +$count mais';
  }

  @override
  String get dateLabel => 'Data';

  @override
  String get noneSelected => 'Nenhum';

  @override
  String reviewEntriesBeforeContinuing(String count) {
    return 'Reveja os lançamentos abaixo ($count no total) antes de continuar.';
  }

  @override
  String youReceived(String amount) {
    return 'Recebeu $amount';
  }

  @override
  String get leaveBlankIfRateUnknown =>
      'Deixe em branco se a taxa de câmbio ainda não for conhecida.';

  @override
  String get recordTradeBlurb =>
      'Registe uma operação que já ocorreu. Esta aplicação não executa ordens.';

  @override
  String get feeOnTopBlurb =>
      'Incluída: o montante acima é o total retirado desta conta; a comissão sai dele.';

  @override
  String get feeBankBlurb =>
      'Uma comissão inicial cobrada pelo seu banco ou por um intermediário.';

  @override
  String get validationPinMinLength => 'O PIN deve ter pelo menos 4 dígitos.';

  @override
  String get restoreBackupBlurb =>
      'Isto substitui tudo o que está atualmente nesta aplicação pela cópia de segurança — não faz uma junção. Escolha um ficheiro de cópia de segurança e introduza a frase-passe com que a protegeu.';

  @override
  String get actionReplace => 'Substituir';

  @override
  String hideAccountBody(String name) {
    return '$name deixará de estar disponível para novas transações.';
  }

  @override
  String hideGroupBody(String name) {
    return '$name deixará de ser oferecido ao criar ou reatribuir contas.';
  }

  @override
  String hideCategoryBody(String name) {
    return '$name deixará de ser oferecida ao registar novas transações.';
  }

  @override
  String get hideInstrumentBody =>
      'Os instrumentos ocultos mantêm-se nas compras e vendas passadas. Ainda pode registar um dividendo para eles.';

  @override
  String nameHidden(String name) {
    return '$name (oculto)';
  }

  @override
  String get noCurrencySet => 'Nenhuma moeda definida';

  @override
  String deletePayeeBody(String name) {
    return '$name e as suas predefinições memorizadas serão removidos. As transações passadas não são afetadas.';
  }

  @override
  String deleteTemplateBody(String name) {
    return '$name deixará de ser oferecido como vencido. As transações passadas já registadas por ele não são afetadas.';
  }

  @override
  String deleteProfileBody(String name) {
    return 'O mapeamento de colunas guardado \"$name\" será eliminado. Os extratos já importados com ele não são afetados.';
  }

  @override
  String deleteRuleBody(String keyword) {
    return 'As importações deixarão de ser categorizadas automaticamente por \"$keyword\". As transações já categorizadas com esta regra não são afetadas.';
  }

  @override
  String get firstWeekBlurb =>
      'Opcionalmente, adicione agora um cartão de crédito ou uma conta de dinheiro - pode sempre adicionar mais contas mais tarde a partir das Definições.';

  @override
  String get deliveredToDestination => 'Entregue ao destino';

  @override
  String deliveredToName(String name) {
    return 'Entregue a $name';
  }

  @override
  String youReceivedLessThanExpected(String amount, String currency) {
    return 'Recebeu $amount $currency a menos do que o esperado - escolha uma categoria para cobrir a diferença.';
  }

  @override
  String get dateRangeLabel => 'Intervalo de datas';

  @override
  String get addTemplate => 'Adicionar modelo';

  @override
  String get editTemplate => 'Editar modelo';

  @override
  String get validationFillTemplateFields =>
      'Preencha todos os campos com um montante e um dia válidos.';

  @override
  String get saveCsvExport => 'Guardar exportação CSV';

  @override
  String get referenceRate => 'Taxa de referência';

  @override
  String get yourRate => 'A sua taxa';

  @override
  String leaveBlankIfThisWasAccountCurrency(String currency) {
    return 'Deixe em branco se isto foi em $currency, a moeda própria da conta.';
  }

  @override
  String get lockUntilOptional => 'Bloqueado até (opcional)';

  @override
  String lockedUntilDate(String date) {
    return 'Bloqueado até $date';
  }

  @override
  String get copiedResearchPrompt =>
      'Copiado um pedido de pesquisa — sem URL de navegador disponível, ou está offline.';

  @override
  String get openedFavouriteResearchTool =>
      'Abriu a sua ferramenta de pesquisa preferida.';

  @override
  String get looksLikeGain => 'Isto parece uma mais-valia';

  @override
  String get looksLikeLoss => 'Isto parece uma menos-valia';

  @override
  String get looksLikeBreakEven => 'Isto parece um ponto de equilíbrio';

  @override
  String sellableQuantity(String name, String qty) {
    return '$name ($qty disponíveis para venda)';
  }

  @override
  String columnN(String index) {
    return 'Coluna $index';
  }

  @override
  String get importingLabel => 'A importar...';

  @override
  String get confirmImport => 'Confirmar importação';

  @override
  String get manageSavedCategoryRules => 'Gerir regras de categorias guardadas';

  @override
  String statementCurrencyMismatch(String currency) {
    return 'A moeda deste ficheiro ($currency) não corresponde à moeda da conta selecionada.';
  }

  @override
  String get categoryRulesTitle => 'Regras de categorias';

  @override
  String get possibleDuplicate => 'possível duplicado';

  @override
  String get unknownCategory => 'Categoria desconhecida';

  @override
  String get researchPromptIntro =>
      'Pesquise este instrumento cotado publicamente para um investidor doméstico. Identifique o emissor, resuma notícias recentes com datas se forem conhecidas, e descreva os riscos de queda e os fatores de subida. Separe factos de especulação. Não dê uma recomendação de compra, venda ou manutenção. Isto não é aconselhamento financeiro.';

  @override
  String researchPromptNameLine(String name) {
    return 'Nome: $name';
  }

  @override
  String researchPromptTickerLine(String ticker) {
    return 'Ticker: $ticker';
  }

  @override
  String get researchPromptTickerNoneProvided => 'Ticker: (não fornecido)';

  @override
  String researchPromptIsinLine(String isin) {
    return 'ISIN: $isin';
  }

  @override
  String get researchPromptIsinNoneProvided => 'ISIN: (não fornecido)';
}
