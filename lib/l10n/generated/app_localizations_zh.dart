// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Smara记账';

  @override
  String get navHome => '首页';

  @override
  String get navRegister => '流水';

  @override
  String get navSummary => '汇总';

  @override
  String get navAccounts => '账户';

  @override
  String get navCategories => '分类';

  @override
  String get actionCancel => '取消';

  @override
  String get actionSave => '保存';

  @override
  String get actionDelete => '删除';

  @override
  String get actionDone => '完成';

  @override
  String get actionContinue => '继续';

  @override
  String get actionDismiss => '关闭';

  @override
  String get actionRetry => '重试';

  @override
  String get actionSkip => '跳过';

  @override
  String get actionConfirm => '确认';

  @override
  String get actionAdd => '添加';

  @override
  String get actionEdit => '编辑';

  @override
  String get actionRename => '重命名';

  @override
  String get actionHide => '隐藏';

  @override
  String get actionCreate => '创建';

  @override
  String get actionCloseApp => '关闭应用';

  @override
  String get actionUnlock => '解锁';

  @override
  String get actionSettle => '结清';

  @override
  String get actionFinish => '完成';

  @override
  String get actionPreview => '预览';

  @override
  String get actionImport => '导入';

  @override
  String get actionExportCsv => '导出 CSV';

  @override
  String get actionChooseFile => '选择文件';

  @override
  String get actionRestore => '恢复';

  @override
  String get actionFix => '更正';

  @override
  String get actionBuy => '买入';

  @override
  String get actionSell => '卖出';

  @override
  String get actionDividend => '股息';

  @override
  String get actionRecordBuy => '记录买入';

  @override
  String get actionRecordSell => '记录卖出';

  @override
  String get actionRecordDividend => '记录股息';

  @override
  String get actionPayCard => '还款';

  @override
  String get actionTransfer => '转账';

  @override
  String get actionRecordTransaction => '记录交易';

  @override
  String get actionImportStatement => '导入对账单';

  @override
  String get actionClearDates => '清除日期';

  @override
  String get actionClearSearch => '清除搜索和筛选';

  @override
  String get actionUseBiometrics => '使用生物识别';

  @override
  String get actionSetPin => '设置 PIN';

  @override
  String get actionChangePin => '更改 PIN';

  @override
  String get actionSaveBackup => '保存备份';

  @override
  String get actionRestoreBackup => '恢复备份';

  @override
  String get actionSaveRule => '保存规则';

  @override
  String get actionConfirmFix => '确认更正';

  @override
  String get captureSpent => '支出';

  @override
  String get captureReceived => '收入';

  @override
  String get captureMovedMoney => '资金转移';

  @override
  String get captureImportStatement => '导入对账单';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsLanguage => '语言';

  @override
  String get settingsLanguageSystem => '设备语言';

  @override
  String get settingsFetchFxRates => '获取参考汇率';

  @override
  String get settingsFetchFxRatesSubtitle =>
      '在跨币种转账时，在目标金额旁显示一个仅供参考的市场汇率，仅用于比较——绝不会用来自动填写金额。';

  @override
  String get settingsRateProvider => '汇率提供方';

  @override
  String get settingsFetchMarketPrices => '获取投资的市场价格';

  @override
  String get settingsFetchMarketPricesSubtitle =>
      '为拥有股票代码或 ISIN 的投资标的查询最新价格，以估算投资组合价值。绝不用于记录交易，也绝不会发送您持有的数量。';

  @override
  String get settingsMarketPriceProvider => '市场价格提供方';

  @override
  String get settingsFavouriteResearchTool => '常用研究工具';

  @override
  String get settingsFavouriteResearchToolSubtitle =>
      '点按持仓中的标的名称，会在浏览器中打开该工具并附带一个研究提示——这不是集成功能，也不构成投资建议。';

  @override
  String get settingsBackup => '备份';

  @override
  String get settingsBackupBlurb =>
      '将您的账本加密副本保存到您选择的位置，或从中恢复。这与您的恢复短语或密钥库文件不同，后者备份的是您的签名密钥，而不是您的账本。';

  @override
  String get settingsLock => '锁定';

  @override
  String get settingsLockBlurb => '要求输入 PIN，或在可用时使用生物识别，才能打开应用。';

  @override
  String get settingsRequireUnlock => '打开应用时需要解锁';

  @override
  String get settingsLockAfter => '锁定延迟';

  @override
  String get settingsLockImmediately => '立即';

  @override
  String get settingsLock1Minute => '1 分钟';

  @override
  String get settingsLock5Minutes => '5 分钟';

  @override
  String get settingsLock15Minutes => '15 分钟';

  @override
  String get settingsAllowBiometrics => '同时允许生物识别';

  @override
  String get settingsHideSnapshot => '在应用切换器中隐藏余额';

  @override
  String get settingsHideSnapshotSubtitle =>
      '当您切换到其他应用时遮挡此屏幕，使其不会在应用切换器中一眼被看到。';

  @override
  String get settingsHideSnapshotUnavailable => '此平台不支持在应用切换器中隐藏余额。';

  @override
  String get settingsPayees => '收款人';

  @override
  String get settingsManagePayees => '管理收款人';

  @override
  String get settingsPayeesBlurb => '已记住的收款人名称及其默认分类和账户，会在记录交易时通过自动完成提示。';

  @override
  String get settingsRecurring => '定期模板';

  @override
  String get settingsManageRecurring => '管理定期模板';

  @override
  String get settingsRecurringBlurb =>
      '每月重复发生的账单或收入，例如房租或工资。到期的模板会显示在首页，供您一键记录——绝不会自动记账。';

  @override
  String get settingsAbout => '关于';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsPrivacyPolicyOpenFailed =>
      'Could not open the privacy policy in a browser.';

  @override
  String get providerFrankfurter => 'Frankfurter（欧洲央行汇率）';

  @override
  String get providerOpenErApi => 'ExchangeRate-API (open.er-api.com)';

  @override
  String get providerStooq => 'Stooq（每日报价）';

  @override
  String get providerYahooFinance => 'Yahoo Finance（图表 API）';

  @override
  String get researchChatGpt => 'ChatGPT';

  @override
  String get researchClaude => 'Claude';

  @override
  String get researchGemini => 'Gemini';

  @override
  String get researchMetaAi => 'Meta AI';

  @override
  String get systemGroupCashEquivalents => '现金及现金等价物';

  @override
  String get systemGroupPensionRetirement => '养老金与退休金';

  @override
  String get systemGroupCreditShortTerm => '信贷与短期负债';

  @override
  String get systemGroupLoansMortgages => '贷款与按揭';

  @override
  String get systemGroupInvestments => '投资';

  @override
  String get systemAccountCashBank => '现金与银行';

  @override
  String get systemCategorySalary => '工资';

  @override
  String get systemCategoryOtherIncome => '其他收入';

  @override
  String get systemCategoryGroceries => '日用杂货';

  @override
  String get systemCategoryRentMortgage => '房租/按揭';

  @override
  String get systemCategoryUtilities => '水电煤气';

  @override
  String get systemCategoryTransport => '交通';

  @override
  String get systemCategoryFoodOut => '外食';

  @override
  String get systemCategoryPhone => '电话';

  @override
  String get systemCategoryHealth => '健康';

  @override
  String get systemCategoryOtherExpense => '其他支出';

  @override
  String get systemDescriptionCsvImport => 'CSV 导入';

  @override
  String get systemDescriptionOfxImport => 'OFX 导入';

  @override
  String get homeThisMonth => '本月';

  @override
  String get homeMoneyInTransit => '在途资金';

  @override
  String get homeWhatYouHaveMinusWhatYouOwe => '您拥有的减去您所欠的';

  @override
  String homeWhatYouHave(String amount, String currency) {
    return '您拥有 $amount $currency';
  }

  @override
  String homeNetPosition(String amount, String currency) {
    return '$amount $currency';
  }

  @override
  String homeHaveAndOwe(String haveAmount, String currency, String oweAmount) {
    return '您拥有 $haveAmount $currency  •  您所欠 $oweAmount $currency';
  }

  @override
  String youSentFrom(String amount, String currency, String name) {
    return '您从 $name 发送了 $amount $currency';
  }

  @override
  String youSentTo(String amount, String currency, String name) {
    return '您向 $name 发送了 $amount $currency';
  }

  @override
  String get hiddenLabel => '已隐藏';

  @override
  String get allAccounts => '所有账户';

  @override
  String savedToPath(String path) {
    return '已保存到 $path';
  }

  @override
  String get keystoreExportFailed => '无法导出密钥库文件。您可以跳过此步骤。';

  @override
  String get enterPassphraseToProtect => '输入一个密码短语以保护此文件。';

  @override
  String get homeTapWhenArrived => '确认收到内容后点按';

  @override
  String homeReturnedTo(String name) {
    return '已退回至 $name';
  }

  @override
  String get homeDueToday => '今日到期';

  @override
  String homeDueLine(String category, String account) {
    return '$category · $account · 点按记录';
  }

  @override
  String get homeOverLimit => '超出限额';

  @override
  String homeSpentOfLimit(String spent, String limit) {
    return '$spent / $limit';
  }

  @override
  String homeRemaining(String amount) {
    return '剩余：$amount';
  }

  @override
  String get homeNoAccounts => '没有账户';

  @override
  String get homeCashRegister => '现金账户';

  @override
  String get homeMarketEstimate => '市值估算';

  @override
  String get registerTitle => '流水';

  @override
  String get registerSearchHint => '描述、分类或金额';

  @override
  String get registerNoTransactions => '尚无交易';

  @override
  String get registerNoEntries => '尚未记录任何条目。';

  @override
  String get registerSpentOnly => '仅支出';

  @override
  String get registerReceivedOnly => '仅收入';

  @override
  String get registerAll => '全部';

  @override
  String get registerUnverified => '未验证——不计入总计';

  @override
  String get registerSuperseded => '已被迁移取代——不计入总计';

  @override
  String get summaryTitle => '汇总';

  @override
  String get summaryTotalIncome => '总收入';

  @override
  String get summaryTotalExpense => '总支出';

  @override
  String summaryDateRange(String start, String end) {
    return '$start 至 $end';
  }

  @override
  String get accountsTitle => '账户';

  @override
  String get categoriesTitle => '分类';

  @override
  String get accountName => '账户名称';

  @override
  String get createAccount => '创建账户';

  @override
  String get createGroup => '创建分组';

  @override
  String get editGroup => '编辑分组';

  @override
  String get renameAccount => '重命名账户';

  @override
  String get renameCategory => '重命名分类';

  @override
  String get addCategory => '添加分类';

  @override
  String get groupLabel => '分组';

  @override
  String get kindLabel => '类型';

  @override
  String get asset => '资产';

  @override
  String get liability => '负债';

  @override
  String get income => '收入';

  @override
  String get expense => '支出';

  @override
  String get thisAccountHoldsInvestments => '此账户持有投资';

  @override
  String get thisAccountHoldsInvestmentsSubtitle =>
      '现金加上您通过“买入”“卖出”和“股息”记录的持仓。';

  @override
  String get thisIsACreditCard => '这是一张信用卡';

  @override
  String get openingBalanceOptional => '期初余额（可选）';

  @override
  String get currencyIso => '货币（ISO 4217）';

  @override
  String get currencyIsoExample => '货币（ISO 4217，例如 USD）';

  @override
  String get hideAccountTitle => '从新条目中隐藏此账户？';

  @override
  String get hideCategoryTitle => '从新条目中隐藏此分类？';

  @override
  String get hideGroupTitle => '从新条目中隐藏此分组？';

  @override
  String get reassignGroup => '重新分配分组';

  @override
  String get transferRemainingBalance => '转出剩余余额';

  @override
  String get monthlyLimit => '月度限额';

  @override
  String get monthlyLimitHint => '限额（留空以清除）';

  @override
  String get monthlyLimitBlurb => '该支出分类的可选月度累计支出参考值。';

  @override
  String get manageCategoryRules => '管理分类规则';

  @override
  String get amount => '金额';

  @override
  String get category => '分类';

  @override
  String get account => '账户';

  @override
  String get fromAccount => '转出账户';

  @override
  String get toAccount => '转入账户';

  @override
  String get descriptionOptional => '描述（可选）';

  @override
  String get alsoRememberPayee => '同时记住为收款人';

  @override
  String get splitIntoCategories => '拆分为多个分类';

  @override
  String categoryN(String n) {
    return '分类 $n';
  }

  @override
  String get destinationAmount => '目标金额';

  @override
  String get destinationAmountOptional => '目标金额（可选）';

  @override
  String get accountCurrencyAmountOptional => '账户币种金额（可选）';

  @override
  String get transactionCurrencyOptional => '交易币种（可选）';

  @override
  String get feeOptional => '手续费（可选）';

  @override
  String get feeAmount => '手续费金额';

  @override
  String get feeCategory => '手续费分类';

  @override
  String get feeDescriptionOptional => '手续费描述（可选）';

  @override
  String get feeDeducted => '手续费从上方金额中扣除';

  @override
  String get needTwoAccountsToTransfer => '至少创建两个有效账户才能进行转账。';

  @override
  String get whatArrivedTitle => '实际到账多少？';

  @override
  String get whatArrivedBlurb => '请告诉我们实际到账的金额。';

  @override
  String get amountThatArrived => '实际到账金额';

  @override
  String get feeLossCategory => '手续费/亏损分类';

  @override
  String get alreadySettled => '已结清。';

  @override
  String get holdingsTitle => '持仓';

  @override
  String get holdingsCash => '现金';

  @override
  String get holdingsInventory => '持仓明细';

  @override
  String holdingsBook(String amount, String currency) {
    return '账面价值（现金+成本）$amount $currency';
  }

  @override
  String holdingsMarketEstimate(String amount, String currency) {
    return '市值估算 $amount $currency';
  }

  @override
  String get holdingsNoHoldings => '尚无持仓。记录一笔买入以添加投资标的。';

  @override
  String get holdingsQuotesBlurb => '报价仅为估算，并非券商实时价格。此应用不进行下单交易。';

  @override
  String get holdingsTapNameToResearch => '点按名称即可查询。报价仅为估算，不构成投资建议。';

  @override
  String get instrument => '投资标的';

  @override
  String get newInstrument => '新建投资标的';

  @override
  String get renameInstrument => '重命名投资标的';

  @override
  String get instrumentActions => '投资标的操作';

  @override
  String hideInstrumentTitle(String name) {
    return '隐藏 $name？';
  }

  @override
  String get tickerOptional => '股票代码（可选）';

  @override
  String get isinOptional => 'ISIN（可选）';

  @override
  String get quantity => '数量';

  @override
  String get unitPrice => '单价';

  @override
  String get brokerageOptional => '经纪费（可选）';

  @override
  String get brokerageExpenseCategory => '经纪费支出分类';

  @override
  String get incomeCategory => '收入分类';

  @override
  String get gainIncomeCategory => '收益收入分类';

  @override
  String get lossExpenseCategory => '亏损支出分类';

  @override
  String get nonCash => '非现金';

  @override
  String get cash => '现金';

  @override
  String get locked => '已锁定';

  @override
  String get lockUntilHint => '这是您自己记录的限制说明，并非券商的规则。';

  @override
  String get instrumentKindStock => '股票';

  @override
  String get instrumentKindEtf => 'ETF';

  @override
  String get instrumentKindMutualFund => '共同基金';

  @override
  String get instrumentKindBond => '债券';

  @override
  String get instrumentKindOther => '其他';

  @override
  String get quoteUseLive => '实时价格';

  @override
  String get quoteUseCached => '缓存价格';

  @override
  String get quoteUseStale => '过期价格';

  @override
  String get quoteUseMissing => '使用成本价（无报价）';

  @override
  String get quoteUseDisabled => '报价已关闭——使用成本价/缓存';

  @override
  String get quoteUseCurrencyMismatch => '使用成本价（报价币种不同）';

  @override
  String unrealizedLabel(String amount, String currency) {
    return '未实现 $amount $currency';
  }

  @override
  String holdingsUnitsCost(String qty) {
    return '$qty 份 · ';
  }

  @override
  String get recoveryPhraseTitle => '您的恢复短语';

  @override
  String get recoveryPhraseConfirmTitle => '确认您的恢复短语';

  @override
  String get recoveryPhraseBlurb =>
      '如果此设备丢失、被重置或更换，这 24 个单词是恢复您交易历史的唯一方式。Smara Accounting 没有服务器，无法为您找回这些单词。\n\n如果您同时丢失了这台设备和这个恢复短语，您已记录的每一笔交易都将永久无法验证。';

  @override
  String get recoveryPhraseWriteDown => '按顺序写下这些单词，并将其存放在与此设备分开的安全地方。';

  @override
  String get iveSavedRecoveryPhrase => '我已保存我的恢复短语';

  @override
  String get confirmPhraseBlurb => '输入您刚保存的恢复短语中被要求的单词。';

  @override
  String wordNumber(String n) {
    return '第 $n 个单词';
  }

  @override
  String get keystoreExportTitle => '导出密钥库文件';

  @override
  String get keystoreExportBlurb =>
      '除了恢复短语外，您还可以保存一个由您选择的密码短语保护的加密密钥库文件。这是可选的——仅凭您的恢复短语始终足以恢复您的签名密钥。';

  @override
  String get keystorePassphrase => '密码短语';

  @override
  String get exportKeystoreFile => '导出密钥库文件';

  @override
  String get chooseCurrencyTitle => '选择您的货币';

  @override
  String get chooseCurrencyBlurb =>
      '目前每个账户分组（现金及现金等价物、养老金与退休金等）都使用这一种货币。您以后仍可以通过创建新的分组来添加使用其他货币的账户。';

  @override
  String get currencyBackfillTitle => '为现有分组选择货币';

  @override
  String get currencyBackfillBlurb =>
      '此应用现已支持多种货币。您现有的账户和账户分组需要指定一种货币——由于它们都是在该功能出现之前创建的，您的选择将统一应用于全部账户和分组。';

  @override
  String get firstAccountTitle => '为您的账户命名';

  @override
  String get firstAccountBlurb =>
      '这是已为您预先设置好的账户——为它取一个您能认出的名字，比如您的银行名称。接下来您会记录一笔支出或收入，然后用恢复短语保护此设备。';

  @override
  String get whatsMainAccountCalled => '您的主要账户叫什么名字？';

  @override
  String get restoreTitle => '恢复签名密钥';

  @override
  String get restoreBlurb =>
      '此设备已有账本，但没有匹配的签名密钥。请从您保存的恢复短语或密钥库文件中恢复它——您的数据将正常通过验证，不会有任何数据被重新签名或更改。';

  @override
  String get recoveryPhrase24 => '恢复短语（全部 24 个单词）';

  @override
  String get keystoreFile => '密钥库文件';

  @override
  String get keystoreFileContents => '密钥库文件内容';

  @override
  String get optionalBackupFile => '可选备份文件';

  @override
  String get iDontHavePhrase => '我没有恢复短语或密钥库文件';

  @override
  String get migrationTitle => '迁移到新密钥';

  @override
  String get migrationBlurb =>
      '如果没有恢复短语或密钥库文件，此设备的签名密钥将无法恢复。您可以创建一个新密钥。旧条目仍会显示，但会被标记为已取代。';

  @override
  String get iConfirmBooksValid => '我确认当前账本有效';

  @override
  String get whyWeDontEdit => '我们为什么不修改旧条目';

  @override
  String get whyWeDontEditBody =>
      '当您更正一个错误时，我们会保留原有的记录行，并在旁边添加一条更正记录，而不是改动您已经录入的内容。这样，您的历史记录始终能准确显示实际发生了什么，以及您何时做了更正——不会有任何内容在您不知情的情况下被悄悄改变。';

  @override
  String get lockTitle => '解锁';

  @override
  String get lockScreenTitle => '已锁定';

  @override
  String get enterPinToContinue => '输入 PIN 以继续';

  @override
  String get pinLabel => 'PIN';

  @override
  String get setPinTitle => '设置 PIN';

  @override
  String get currentPin => '当前 PIN';

  @override
  String get newPin => '新 PIN';

  @override
  String get confirmPin => '确认 PIN';

  @override
  String get confirmNewPin => '确认新 PIN';

  @override
  String get firstWeekTitle => '设置您的账户';

  @override
  String get addCashAccount => '添加现金账户';

  @override
  String get addCreditCard => '添加信用卡';

  @override
  String get cashAccountName => '现金账户名称';

  @override
  String get cardName => '卡片名称';

  @override
  String get paidFromBank => '从银行支付';

  @override
  String get paidFromCard => '从卡片支付';

  @override
  String get choosePassphraseTitle => '选择一个密码短语来保护此备份。如果您忘记它，将无法恢复。';

  @override
  String get replaceBooksTitle => '替换本机账本？';

  @override
  String get replaceBooksBody => '此操作会用备份替换此应用中当前的所有内容。完成后请关闭并重新打开应用。';

  @override
  String get chooseBackupFileFirst => '请先选择一个备份文件。';

  @override
  String get backupRestored => '备份已恢复';

  @override
  String get backupRestoredBody => '您的账本已恢复。请关闭并重新打开应用以继续。';

  @override
  String get fixThisEntry => '更正此条目';

  @override
  String get fixBlurb => '旧记录行将保持原样不变。确认后会添加一条冲正记录和一条更正后的记录。';

  @override
  String get importStatementTitle => '导入对账单';

  @override
  String get importOfx => '导入 OFX';

  @override
  String get importOfxQfxFile => '导入 OFX / QFX 文件';

  @override
  String get importCsvFile => '导入 CSV 文件';

  @override
  String get whatKindOfStatement => '您有哪种类型的对账单文件？';

  @override
  String get chooseAccountForFile => '选择此文件所属的账户。';

  @override
  String get importIntoAccount => '导入到账户';

  @override
  String get useSavedProfile => '使用已保存的配置';

  @override
  String get saveMappingProfile => '将此映射保存为配置（可选）';

  @override
  String get renameProfile => '重命名配置';

  @override
  String get deleteProfileTitle => '删除配置？';

  @override
  String get fileHasHeader => '文件包含标题行';

  @override
  String get dateColumn => '日期列';

  @override
  String get dateFormatHint => '日期格式（例如 dd/MM/yyyy）';

  @override
  String get amountColumn => '金额列';

  @override
  String get amountConvention => '金额约定';

  @override
  String get signedAmountColumn => '带符号金额列';

  @override
  String get separateDebitCredit => '借方/贷方分列';

  @override
  String get debitColumn => '借方列';

  @override
  String get creditColumn => '贷方列';

  @override
  String get decimalSeparator => '小数分隔符（. 或 ,）';

  @override
  String get descriptionColumns => '描述列';

  @override
  String get referenceIdColumn => '参考编号列（可选）';

  @override
  String get skippedRows => '已跳过的行';

  @override
  String parsedTransactionCount(String count) {
    return '已解析 $count 笔交易';
  }

  @override
  String skippedOrExcludedCount(String count) {
    return '$count 条已跳过或排除';
  }

  @override
  String postedFailedCount(String posted, String failed) {
    return '已入账 $posted 条，失败 $failed 条';
  }

  @override
  String get categoryForAll => '全部使用此分类';

  @override
  String get saveAsRule => '保存为规则？';

  @override
  String get saveAsRuleBlurb => '以后描述中包含此关键词的导入记录都将使用此分类。';

  @override
  String get keyword => '关键词';

  @override
  String get noSavedRules => '尚无已保存的规则。为一组行指定分类即可保存规则。';

  @override
  String get deleteRuleTitle => '删除规则？';

  @override
  String get editRule => '编辑规则';

  @override
  String rowsGrouped(String count) {
    return '$count 行';
  }

  @override
  String selectStatementFile(String extensions) {
    return '选择要导入的 $extensions 对账单文件';
  }

  @override
  String get payeesTitle => '收款人';

  @override
  String get addPayee => '添加收款人';

  @override
  String get renamePayee => '重命名收款人';

  @override
  String get deletePayeeTitle => '删除收款人？';

  @override
  String get noPayeesYet => '尚无收款人';

  @override
  String get recurringTitle => '定期模板';

  @override
  String get noRecurringYet => '尚无定期模板';

  @override
  String get deleteTemplateTitle => '删除定期模板？';

  @override
  String get dayOfMonth => '每月日期（1-31）';

  @override
  String get dayOfMonthNote => '天数较少的月份将使用该月的最后一天。';

  @override
  String dayOfMonthLine(String day) {
    return '每月第 $day 天 - ';
  }

  @override
  String get name => '名称';

  @override
  String get none => '无';

  @override
  String get currency => '货币';

  @override
  String get errorGeneric => '出错了，请重试。';

  @override
  String get errorSigningIdentityMismatch => '此恢复短语或密钥库文件与此数据库中的任何签名身份都不匹配。';

  @override
  String get errorInvalidLedgerBackup => '此文件不是有效的 Smara 备份。';

  @override
  String get errorInvalidLedgerBackupNoIdentity =>
      '此备份没有签名身份——它不是有效的 Smara 备份。';

  @override
  String get errorInvalidLedgerBackupUnverified => '此备份未能验证为完整的账本，因此未被恢复。';

  @override
  String errorInvalidLedgerBackupUnreadable(String detail) {
    return '无法将此文件作为 Smara 备份打开：$detail';
  }

  @override
  String get errorForeignBackupIdentity => '此备份属于与本设备不同的签名身份。';

  @override
  String get errorAccountNotFinancial => '该账户不是财务账户。';

  @override
  String get errorAccountArchived => '该账户已被隐藏。';

  @override
  String get errorAccountNotArchived => '该账户未被隐藏。';

  @override
  String get errorAccountNoPositiveBalanceToCloseOut => '没有剩余余额可供转出。';

  @override
  String get errorAccountHasNoGroup => '该账户未分配分组。';

  @override
  String get errorGroupHasNoCurrency => '该分组尚未设置货币。';

  @override
  String get errorGroupNotFound => '未找到该账户分组。';

  @override
  String get errorInvestmentAccountsMustBeAssets => '只有资产账户才能被标记为投资账户。';

  @override
  String get errorCreditCardsMustBeLiabilities => '只有负债账户才能被标记为信用卡。';

  @override
  String get errorOpeningBalanceMustBePositive => '如果提供期初余额，则必须为正数。';

  @override
  String get errorAccountTypeDoesNotMatchGroup => '该账户类型与分组不匹配。';

  @override
  String get errorLastActiveAccount => '无法隐藏最后一个有效的财务账户。';

  @override
  String get errorCurrencyRequiredToCreateGroup => '创建分组需要指定货币。';

  @override
  String get errorSystemGroupCannotBeArchived => '内置账户分组不能被隐藏。';

  @override
  String get errorGroupAlreadyArchived => '该分组已被隐藏。';

  @override
  String get errorCannotArchiveGroupWithAccounts => '无法隐藏仍有有效账户的分组。';

  @override
  String get errorSystemGroupNeverArchived => '内置账户分组永远不会被隐藏。';

  @override
  String get errorAccountGroupsCannotBeDeleted => '账户分组不能被删除。';

  @override
  String get errorCannotReassignDifferentCurrency => '无法将此账户移动到货币不同的分组。';

  @override
  String get errorCannotChangeGroupCurrencyWithAccounts => '分组中仍有有效账户时无法更改货币。';

  @override
  String get errorAmountMustBePositive => '金额必须为正数。';

  @override
  String get errorAccountCurrencyAmountMustBePositive => '账户币种金额必须为正数。';

  @override
  String get errorAccountCurrencyAmountNotForSameCurrency => '账户币种金额仅适用于外币条目。';

  @override
  String get errorSplitNeedsTwoLines => '拆分至少需要两条分类记录行。';

  @override
  String get errorSplitLineMustBePositive => '每条拆分记录行的金额必须为正数。';

  @override
  String get errorSplitLinesMustSumToTotal => '拆分记录行的合计金额必须等于交易总额。';

  @override
  String get errorTransferAmountMustBePositive => '转账金额必须为正数。';

  @override
  String get errorTransferAccountsMustDiffer => '转出账户和转入账户必须不同。';

  @override
  String get errorCloseoutRequiresDestinationAmount => '跨币种账户结清需要已知的目标金额。';

  @override
  String get errorDestinationAmountNotForSameCurrency => '目标金额仅适用于跨币种转账。';

  @override
  String get errorDestinationAmountMustBePositive => '目标金额必须为正数。';

  @override
  String get errorInvestmentCashExceeded => '转出金额不能超过该投资账户的现金余额。';

  @override
  String get errorCannotReverseUnsettledProvisional => '请结清此待处理转账，而不要将其冲正。';

  @override
  String get errorAlreadyReversed => '此条目已被更正过。原始记录行保持不变。';

  @override
  String get errorNotActiveExpenseCategory => '请选择一个有效的支出分类。';

  @override
  String get errorNotActiveIncomeCategory => '请选择一个有效的收入分类。';

  @override
  String get errorSettledAmountMustNotBeNegative => '实际到账金额不能为负数。';

  @override
  String get errorPendingTransferNotFound => '未找到该待处理转账。';

  @override
  String get errorPendingTransferAlreadySettled => '该待处理转账已结清。';

  @override
  String get errorSettledToMustBeSourceOrDestination => '请选择原始的转出或转入账户。';

  @override
  String get errorFeeCategoryOnlyWhenReturningToSource => '手续费分类仅在资金退回转出账户时使用。';

  @override
  String get errorSettledAmountMustBePositiveForDelivery => '请为实际到账金额输入一个正数。';

  @override
  String get errorSettledAmountExceedsProvisional => '该金额超过了实际发送的金额。';

  @override
  String get errorInstrumentNotFound => '未找到该投资标的。';

  @override
  String get errorIncomeRequiredForNonCash => '非现金取得需要一个有效的收入分类。';

  @override
  String get errorInsufficientCash => '该投资账户中现金不足，无法完成此次买入。';

  @override
  String get errorSellQuantityAndPriceMustBePositive => '卖出数量和单价必须为正数。';

  @override
  String errorLockedUntil(String date) {
    return '无法卖出：部分份额被锁定至 $date。';
  }

  @override
  String get errorInsufficientQuantity => '卖出数量不能超过您当前持有的未锁定数量。';

  @override
  String get errorIncomeRequiredForGain => '已实现收益需要一个有效的收入分类。';

  @override
  String get errorExpenseRequiredForLoss => '已实现亏损需要一个有效的支出分类。';

  @override
  String errorBrokerageFailedAfterBuy(String detail) {
    return '买入已入账，但经纪费记录失败：$detail';
  }

  @override
  String errorBrokerageFailedAfterSell(String detail) {
    return '卖出已入账，但经纪费记录失败：$detail';
  }

  @override
  String get errorDividendMustBePositive => '股息金额必须为正数。';

  @override
  String get errorNotInvestmentAccount => '该账户不是投资账户。';

  @override
  String get errorNoInventoryCompanion => '此投资账户缺少与其配对的持仓账户。';

  @override
  String errorInvestmentReversalBlocked(String sells) {
    return '无法冲正此买入：后续的卖出交易依赖于其份额。请先冲正相关的卖出交易：$sells。';
  }

  @override
  String get errorMonthlyLimitMustBePositive => '月度限额必须为正数。';

  @override
  String get errorTemplateAmountMustBePositive => '模板金额必须为正数。';

  @override
  String get errorOfxUnrecognized => '无法将此文件识别为 OFX 格式。';

  @override
  String get errorCsvEmpty => '所选文件为空。';

  @override
  String get errorCsvUnreadable => '无法将此文件作为 CSV 读取。';

  @override
  String get errorCsvNoRows => '所选文件没有任何数据行。';

  @override
  String get skipMissingDate => '缺少日期。';

  @override
  String skipUnparseableDate(String raw, String pattern) {
    return '无法使用格式“$pattern”解析日期“$raw”。';
  }

  @override
  String get skipOfxMissingOrInvalidDate => '交易日期缺失或无效。';

  @override
  String skipOfxUnparseableDate(String raw) {
    return '无法解析交易日期“$raw”。';
  }

  @override
  String get skipMissingAmount => '缺少金额。';

  @override
  String skipUnparseableAmount(String raw) {
    return '无法解析金额“$raw”。';
  }

  @override
  String get skipZeroAmount => '金额为零。';

  @override
  String get skipUnparseableDebitCreditAmount => '无法解析借方或贷方金额。';

  @override
  String get skipBothDebitAndCreditNonZero => '借方和贷方两列都有金额。';

  @override
  String get skipBothDebitAndCreditZero => '借方和贷方两列均为零。';

  @override
  String errorBackupCreateFailed(String detail) {
    return '无法创建备份：$detail';
  }

  @override
  String get errorBackupRestoreFailed => '无法恢复此备份——密码短语错误，或该文件不是 Smara 备份文件。';

  @override
  String get validationAmountAccountCategoryRequired => '需要填写金额、账户和分类。';

  @override
  String get validationAmountAccountRequired => '需要填写金额和账户。';

  @override
  String get validationSplitLineIncomplete => '每条拆分记录行都需要分类和金额。';

  @override
  String get validationSplitSumMismatch => '拆分记录行的合计金额必须等于交易总额。';

  @override
  String get validationFromToAmountRequired => '需要填写转出账户、转入账户和金额。';

  @override
  String get validationAmountArrivedRequired => '需要填写实际到账金额。';

  @override
  String get validationChooseReceivingAccount => '请选择接收资金的账户。';

  @override
  String get validationAccountCategoryRequired => '需要填写账户和分类。';

  @override
  String get validationFixFailed => '无法保存此项更正。';

  @override
  String get validationNameRequired => '请为您的主要账户命名。';

  @override
  String get validationStillLoading => '仍在加载中——请稍后再试。';

  @override
  String get validationSaveAccountNameFailed => '无法保存账户名称。';

  @override
  String get validationWrongPin => 'PIN 错误，请重试。';

  @override
  String get validationCategoryMustBeIncomeOrExpense => '分类必须是收入或支出。';

  @override
  String get validationOnlyExpenseHasMonthlyLimit => '只有支出分类才能设置月度限额。';

  @override
  String get validationInvalidTemplate => '模板无效。';

  @override
  String get validationWrongKeystorePassphrase => '此密钥库文件的密码短语错误。';

  @override
  String get validationInvalidKeystoreFile => '该文件看起来不是有效的密钥库文件。';

  @override
  String get validationRestorePhraseFailed => '无法从该恢复短语恢复。';

  @override
  String validationGenerateKeyFailed(String detail) {
    return '无法在此设备上生成签名密钥：$detail';
  }

  @override
  String validationSaveCurrencyFailed(String detail) {
    return '无法保存此货币：$detail';
  }

  @override
  String get validationMigrationFailed => '迁移失败。请重试。';

  @override
  String get validationChooseBackupFile => '请先选择一个备份文件。';

  @override
  String get validationPassphraseRequired => '请输入密码短语。';

  @override
  String get validationPinsDoNotMatch => '两次输入的 PIN 不一致。';

  @override
  String get validationFeePositiveWithCategory => '转账手续费必须为正数，并选择一个支出分类。';

  @override
  String get validationFeeMustBeLessThanAmount => '对于内扣手续费的转账，手续费必须小于转账金额。';

  @override
  String validationTransferSavedFeeFailed(String detail) {
    return '转账已保存，但手续费记录失败：$detail';
  }

  @override
  String get validationEnterValidAmount => '请输入有效金额。';

  @override
  String validationConfirmWordMismatch(String n) {
    return '第 $n 个单词与您保存的恢复短语不匹配。请检查后重试。';
  }

  @override
  String get errorBuyQuantityAndPriceMustBePositive => '买入数量和单价必须为正数。';

  @override
  String get errorInstrumentArchived => '无法买入已隐藏的投资标的。';

  @override
  String get errorNonCashCannotIncludeBrokerage => '非现金取得不能包含经纪费。';

  @override
  String get errorBrokerageRequiresExpenseCategory => '当经纪费大于零时，需要一个有效的支出分类。';

  @override
  String get errorSellProceedsMustCoverBrokerage => '卖出所得金额必须至少覆盖经纪费金额。';

  @override
  String homeSpentOfLimitThisMonth(String spent, String limit) {
    return '本月 $spent / $limit';
  }

  @override
  String get unlockBiometricReason => '解锁 Smara Account';

  @override
  String get searchLabel => '搜索';

  @override
  String get openingBalance => '期初余额';

  @override
  String transferToName(String name) {
    return '转账：$name';
  }

  @override
  String get feeForTransfer => '转账手续费';

  @override
  String feeForTransferTo(String name) {
    return '转账至 $name 的手续费';
  }

  @override
  String couldNotOpenFilePicker(String detail) {
    return '无法打开文件选择器：$detail';
  }

  @override
  String pleaseSelectFile(String extensions) {
    return '请选择一个 .$extensions 文件';
  }

  @override
  String get currencyCodeIso => '货币代码（ISO 4217，例如 USD）';

  @override
  String splitCounterpartMore(String name, String count) {
    return '$name 及另外 $count 项';
  }

  @override
  String get dateLabel => '日期';

  @override
  String get noneSelected => '无';

  @override
  String reviewEntriesBeforeContinuing(String count) {
    return '继续之前请查看下方条目（共 $count 条）。';
  }

  @override
  String youReceived(String amount) {
    return '您收到了 $amount';
  }

  @override
  String get leaveBlankIfRateUnknown => '如果尚不知道汇率，请留空。';

  @override
  String get recordTradeBlurb => '记录一笔已经发生的交易。此应用不进行下单交易。';

  @override
  String get feeOnTopBlurb => '开启：上方金额是从该账户扣除的总金额；手续费从中扣除。';

  @override
  String get feeBankBlurb => '由您的银行或中间机构预先收取的佣金。';

  @override
  String get validationPinMinLength => 'PIN 必须至少为 4 位数字。';

  @override
  String get restoreBackupBlurb =>
      '此操作会用备份替换此应用中当前的所有内容——不会进行合并。请选择一个备份文件，并输入您当初设置的保护密码短语。';

  @override
  String get actionReplace => '替换';

  @override
  String hideAccountBody(String name) {
    return '$name 将不再可用于新交易。';
  }

  @override
  String hideGroupBody(String name) {
    return '在创建或重新分配账户时将不再提供 $name。';
  }

  @override
  String hideCategoryBody(String name) {
    return '在记录新交易时将不再提供 $name。';
  }

  @override
  String get hideInstrumentBody => '已隐藏的投资标的仍会保留在以往的买入和卖出记录中。您仍可以为它们记录股息。';

  @override
  String nameHidden(String name) {
    return '$name（已隐藏）';
  }

  @override
  String get noCurrencySet => '未设置货币';

  @override
  String deletePayeeBody(String name) {
    return '$name 及其记住的默认设置将被删除。过去的交易不受影响。';
  }

  @override
  String deleteTemplateBody(String name) {
    return '$name 将不再显示为到期项目。它此前已记录的交易不受影响。';
  }

  @override
  String deleteProfileBody(String name) {
    return '已保存的列映射“$name”将被删除。此前使用它导入的对账单不受影响。';
  }

  @override
  String deleteRuleBody(String keyword) {
    return '导入记录将不再通过“$keyword”自动分类。此前已通过该规则分类的交易不受影响。';
  }

  @override
  String get firstWeekBlurb => '您可以现在选择添加一张信用卡或一个现金账户——以后也可以随时在设置中添加更多账户。';

  @override
  String get deliveredToDestination => '已送达目的账户';

  @override
  String deliveredToName(String name) {
    return '已送达 $name';
  }

  @override
  String youReceivedLessThanExpected(String amount, String currency) {
    return '您实际收到的金额比预期少 $amount $currency——请选择一个分类来处理差额。';
  }

  @override
  String get dateRangeLabel => '日期范围';

  @override
  String get addTemplate => '添加模板';

  @override
  String get editTemplate => '编辑模板';

  @override
  String get validationFillTemplateFields => '请为每个字段填写有效的金额和日期。';

  @override
  String get saveCsvExport => '保存 CSV 导出';

  @override
  String get referenceRate => '参考汇率';

  @override
  String get yourRate => '您的汇率';

  @override
  String leaveBlankIfThisWasAccountCurrency(String currency) {
    return '如果金额本身就是 $currency（该账户自身的货币），请留空。';
  }

  @override
  String get lockUntilOptional => '锁定至（可选）';

  @override
  String lockedUntilDate(String date) {
    return '锁定至 $date';
  }

  @override
  String get copiedResearchPrompt => '已复制研究提示——没有可用的浏览器链接，或您当前处于离线状态。';

  @override
  String get openedFavouriteResearchTool => '已打开您常用的研究工具。';

  @override
  String get looksLikeGain => '这看起来是一笔收益';

  @override
  String get looksLikeLoss => '这看起来是一笔亏损';

  @override
  String get looksLikeBreakEven => '这看起来是收支平衡';

  @override
  String sellableQuantity(String name, String qty) {
    return '$name（可卖 $qty）';
  }

  @override
  String columnN(String index) {
    return '第 $index 列';
  }

  @override
  String get importingLabel => '正在导入…';

  @override
  String get confirmImport => '确认导入';

  @override
  String get manageSavedCategoryRules => '管理已保存的分类规则';

  @override
  String statementCurrencyMismatch(String currency) {
    return '此文件的货币（$currency）与所选账户的货币不一致。';
  }

  @override
  String get categoryRulesTitle => '分类规则';

  @override
  String get possibleDuplicate => '可能重复';

  @override
  String get unknownCategory => '未知分类';

  @override
  String get researchPromptIntro =>
      '为家庭投资者研究这只公开上市的证券。识别发行方，如有已知日期请总结近期新闻，并概述下行风险与上行驱动因素。将事实与推测区分开来。不要给出买入、卖出或持有的建议。这不是财务建议。';

  @override
  String researchPromptNameLine(String name) {
    return '名称：$name';
  }

  @override
  String researchPromptTickerLine(String ticker) {
    return '股票代码：$ticker';
  }

  @override
  String get researchPromptTickerNoneProvided => '股票代码：（未提供）';

  @override
  String researchPromptIsinLine(String isin) {
    return 'ISIN：$isin';
  }

  @override
  String get researchPromptIsinNoneProvided => 'ISIN：（未提供）';
}
