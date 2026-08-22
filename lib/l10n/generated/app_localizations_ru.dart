// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Smara учёт';

  @override
  String get navHome => 'Главная';

  @override
  String get navRegister => 'Журнал';

  @override
  String get navSummary => 'Итоги';

  @override
  String get navAccounts => 'Счета';

  @override
  String get navCategories => 'Категории';

  @override
  String get actionCancel => 'Отмена';

  @override
  String get actionSave => 'Сохранить';

  @override
  String get actionDelete => 'Удалить';

  @override
  String get actionDone => 'Готово';

  @override
  String get actionContinue => 'Продолжить';

  @override
  String get actionDismiss => 'Закрыть';

  @override
  String get actionRetry => 'Повторить';

  @override
  String get actionSkip => 'Пропустить';

  @override
  String get actionConfirm => 'Подтвердить';

  @override
  String get actionAdd => 'Добавить';

  @override
  String get actionEdit => 'Изменить';

  @override
  String get actionRename => 'Переименовать';

  @override
  String get actionHide => 'Скрыть';

  @override
  String get actionCreate => 'Создать';

  @override
  String get actionCloseApp => 'Закрыть приложение';

  @override
  String get actionUnlock => 'Разблокировать';

  @override
  String get actionSettle => 'Закрыть';

  @override
  String get actionFinish => 'Завершить';

  @override
  String get actionPreview => 'Предпросмотр';

  @override
  String get actionImport => 'Импорт';

  @override
  String get actionExportCsv => 'Экспорт в CSV';

  @override
  String get actionChooseFile => 'Выбрать файл';

  @override
  String get actionRestore => 'Восстановить';

  @override
  String get actionFix => 'Исправить';

  @override
  String get actionBuy => 'Купить';

  @override
  String get actionSell => 'Продать';

  @override
  String get actionDividend => 'Дивиденд';

  @override
  String get actionRecordBuy => 'Записать покупку';

  @override
  String get actionRecordSell => 'Записать продажу';

  @override
  String get actionRecordDividend => 'Записать дивиденд';

  @override
  String get actionPayCard => 'Оплатить карту';

  @override
  String get actionTransfer => 'Перевод';

  @override
  String get actionRecordTransaction => 'Записать операцию';

  @override
  String get actionImportStatement => 'Импортировать выписку';

  @override
  String get actionClearDates => 'Очистить даты';

  @override
  String get actionClearSearch => 'Очистить поиск и фильтры';

  @override
  String get actionUseBiometrics => 'Использовать биометрию';

  @override
  String get actionSetPin => 'Задать PIN';

  @override
  String get actionChangePin => 'Изменить PIN';

  @override
  String get actionSaveBackup => 'Сохранить резервную копию';

  @override
  String get actionRestoreBackup => 'Восстановить из резервной копии';

  @override
  String get actionSaveRule => 'Сохранить правило';

  @override
  String get actionConfirmFix => 'Подтвердить исправление';

  @override
  String get captureSpent => 'Расход';

  @override
  String get captureReceived => 'Приход';

  @override
  String get captureMovedMoney => 'Перемещение денег';

  @override
  String get captureImportStatement => 'Импорт выписки';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsLanguageSystem => 'Язык устройства';

  @override
  String get settingsFetchFxRates => 'Получать справочные курсы валют';

  @override
  String get settingsFetchFxRatesSubtitle =>
      'Показывает ориентировочный рыночный курс рядом с суммой назначения при переводах между валютами — только для сравнения, никогда не используется для заполнения суммы.';

  @override
  String get settingsRateProvider => 'Поставщик курсов';

  @override
  String get settingsFetchMarketPrices =>
      'Получать рыночные цены для инвестиций';

  @override
  String get settingsFetchMarketPricesSubtitle =>
      'Показывает последние цены для инструментов с тикером или ISIN, чтобы оценить стоимость портфеля. Никогда не используется для записи сделки и не передаёт, сколько вы держите.';

  @override
  String get settingsMarketPriceProvider => 'Поставщик рыночных цен';

  @override
  String get settingsFavouriteResearchTool => 'Любимый инструмент анализа';

  @override
  String get settingsFavouriteResearchToolSubtitle =>
      'Нажатие на название инструмента в портфеле открывает этот инструмент в браузере с исследовательским запросом — это не интеграция и не финансовый совет.';

  @override
  String get settingsBackup => 'Резервное копирование';

  @override
  String get settingsBackupBlurb =>
      'Сохраните зашифрованную копию ваших книг в выбранном месте или восстановите из неё. Это не то же самое, что фраза восстановления или файл ключей, которые защищают ваш ключ подписи, а не сами книги.';

  @override
  String get settingsLock => 'Блокировка';

  @override
  String get settingsLockBlurb =>
      'Требовать PIN-код или биометрию (где доступна) для открытия приложения.';

  @override
  String get settingsRequireUnlock =>
      'Требовать разблокировку для открытия приложения';

  @override
  String get settingsLockAfter => 'Блокировать через';

  @override
  String get settingsLockImmediately => 'Немедленно';

  @override
  String get settingsLock1Minute => '1 минуту';

  @override
  String get settingsLock5Minutes => '5 минут';

  @override
  String get settingsLock15Minutes => '15 минут';

  @override
  String get settingsAllowBiometrics => 'Также разрешить биометрию';

  @override
  String get settingsHideSnapshot => 'Скрывать баланс в списке приложений';

  @override
  String get settingsHideSnapshotSubtitle =>
      'Скрывает этот экран, когда вы переключаетесь на другое приложение, чтобы он не был виден мельком в списке приложений.';

  @override
  String get settingsHideSnapshotUnavailable =>
      'Скрытие баланса в списке приложений недоступно на этой платформе.';

  @override
  String get settingsPayees => 'Получатели платежей';

  @override
  String get settingsManagePayees => 'Управление получателями платежей';

  @override
  String get settingsPayeesBlurb =>
      'Запомненные имена получателей платежей вместе с их категорией и счётом по умолчанию, предлагаемые автозаполнением при записи операции.';

  @override
  String get settingsRecurring => 'Регулярные шаблоны';

  @override
  String get settingsManageRecurring => 'Управление регулярными шаблонами';

  @override
  String get settingsRecurringBlurb =>
      'Счета или доходы, повторяющиеся ежемесячно, например аренда или зарплата. Наступивший шаблон появляется на главном экране, чтобы вы могли записать его одним нажатием — никогда не проводится автоматически.';

  @override
  String get settingsAbout => 'О приложении';

  @override
  String get providerFrankfurter => 'Frankfurter (курсы ЕЦБ)';

  @override
  String get providerOpenErApi => 'ExchangeRate-API (open.er-api.com)';

  @override
  String get providerStooq => 'Stooq (дневные котировки)';

  @override
  String get providerYahooFinance => 'Yahoo Finance (API графиков)';

  @override
  String get researchChatGpt => 'ChatGPT';

  @override
  String get researchClaude => 'Claude';

  @override
  String get researchGemini => 'Gemini';

  @override
  String get researchMetaAi => 'Meta AI';

  @override
  String get systemGroupCashEquivalents => 'Денежные средства и эквиваленты';

  @override
  String get systemGroupPensionRetirement => 'Пенсия и пенсионные накопления';

  @override
  String get systemGroupCreditShortTerm => 'Кредиты и краткосрочные долги';

  @override
  String get systemGroupLoansMortgages => 'Займы и ипотека';

  @override
  String get systemGroupInvestments => 'Инвестиции';

  @override
  String get systemAccountCashBank => 'Наличные и банк';

  @override
  String get systemCategorySalary => 'Зарплата';

  @override
  String get systemCategoryOtherIncome => 'Прочие доходы';

  @override
  String get systemCategoryGroceries => 'Продукты';

  @override
  String get systemCategoryRentMortgage => 'Аренда/ипотека';

  @override
  String get systemCategoryUtilities => 'Коммунальные услуги';

  @override
  String get systemCategoryTransport => 'Транспорт';

  @override
  String get systemCategoryFoodOut => 'Еда вне дома';

  @override
  String get systemCategoryPhone => 'Телефон';

  @override
  String get systemCategoryHealth => 'Здоровье';

  @override
  String get systemCategoryOtherExpense => 'Прочие расходы';

  @override
  String get homeThisMonth => 'ЭТОТ МЕСЯЦ';

  @override
  String get homeMoneyInTransit => 'ДЕНЬГИ В ПУТИ';

  @override
  String get homeWhatYouHaveMinusWhatYouOwe =>
      'ЧТО У ВАС ЕСТЬ МИНУС ЧТО ВЫ ДОЛЖНЫ';

  @override
  String homeWhatYouHave(String amount, String currency) {
    return 'У вас есть $amount $currency';
  }

  @override
  String homeNetPosition(String amount, String currency) {
    return '$amount $currency';
  }

  @override
  String homeHaveAndOwe(String haveAmount, String currency, String oweAmount) {
    return 'У вас есть $haveAmount $currency  •  Вы должны $oweAmount $currency';
  }

  @override
  String youSentFrom(String amount, String currency, String name) {
    return 'Вы отправили $amount $currency со счёта $name';
  }

  @override
  String youSentTo(String amount, String currency, String name) {
    return 'Вы отправили $amount $currency на счёт $name';
  }

  @override
  String get hiddenLabel => 'Скрыто';

  @override
  String get allAccounts => 'Все счета';

  @override
  String savedToPath(String path) {
    return 'Сохранено в $path';
  }

  @override
  String get keystoreExportFailed =>
      'Не удалось экспортировать файл ключей. Этот шаг можно пропустить.';

  @override
  String get enterPassphraseToProtect =>
      'Введите парольную фразу для защиты файла.';

  @override
  String get homeTapWhenArrived => 'Нажмите, когда узнаете, что пришло';

  @override
  String homeReturnedTo(String name) {
    return 'Возвращено на $name';
  }

  @override
  String get homeDueToday => 'СЕГОДНЯ СРОК';

  @override
  String homeDueLine(String category, String account) {
    return '$category · $account · нажмите, чтобы записать';
  }

  @override
  String get homeOverLimit => 'Превышен лимит';

  @override
  String homeSpentOfLimit(String spent, String limit) {
    return '$spent из $limit';
  }

  @override
  String homeRemaining(String amount) {
    return 'Осталось: $amount';
  }

  @override
  String get homeNoAccounts => 'Нет счетов';

  @override
  String get homeCashRegister => 'Денежные средства';

  @override
  String get homeMarketEstimate => 'Рыночная оценка';

  @override
  String get registerTitle => 'Журнал';

  @override
  String get registerSearchHint => 'Описание, категория или сумма';

  @override
  String get registerNoTransactions => 'Пока нет операций';

  @override
  String get registerNoEntries => 'Записей пока нет.';

  @override
  String get registerSpentOnly => 'Только расходы';

  @override
  String get registerReceivedOnly => 'Только поступления';

  @override
  String get registerAll => 'Все';

  @override
  String get registerUnverified => 'Не подтверждено - не входит в итоги';

  @override
  String get registerSuperseded => 'Заменено при миграции - не входит в итоги';

  @override
  String get summaryTitle => 'Итоги';

  @override
  String get summaryTotalIncome => 'Общий доход';

  @override
  String get summaryTotalExpense => 'Общий расход';

  @override
  String summaryDateRange(String start, String end) {
    return '$start — $end';
  }

  @override
  String get accountsTitle => 'Счета';

  @override
  String get categoriesTitle => 'Категории';

  @override
  String get accountName => 'Название счёта';

  @override
  String get createAccount => 'Создать счёт';

  @override
  String get createGroup => 'Создать группу';

  @override
  String get editGroup => 'Изменить группу';

  @override
  String get renameAccount => 'Переименовать счёт';

  @override
  String get renameCategory => 'Переименовать категорию';

  @override
  String get addCategory => 'Добавить категорию';

  @override
  String get groupLabel => 'Группа';

  @override
  String get kindLabel => 'Вид';

  @override
  String get asset => 'Актив';

  @override
  String get liability => 'Обязательство';

  @override
  String get income => 'Доход';

  @override
  String get expense => 'Расход';

  @override
  String get thisAccountHoldsInvestments => 'Этот счёт хранит инвестиции';

  @override
  String get thisAccountHoldsInvestmentsSubtitle =>
      'Денежные средства плюс активы, которые вы записываете через Покупку, Продажу и Дивиденды.';

  @override
  String get thisIsACreditCard => 'Это кредитная карта';

  @override
  String get openingBalanceOptional => 'Начальный баланс (необязательно)';

  @override
  String get currencyIso => 'Валюта (ISO 4217)';

  @override
  String get currencyIsoExample => 'Валюта (ISO 4217, напр. USD)';

  @override
  String get hideAccountTitle => 'Скрыть счёт от новых записей?';

  @override
  String get hideCategoryTitle => 'Скрыть категорию от новых записей?';

  @override
  String get hideGroupTitle => 'Скрыть группу от новых записей?';

  @override
  String get reassignGroup => 'Изменить группу';

  @override
  String get transferRemainingBalance => 'Перевести оставшийся баланс';

  @override
  String get monthlyLimit => 'Месячный лимит';

  @override
  String get monthlyLimitHint => 'Лимит (оставьте пустым, чтобы очистить)';

  @override
  String get monthlyLimitBlurb =>
      'Необязательный ориентир расходов с начала месяца для этой категории расходов.';

  @override
  String get manageCategoryRules => 'Управление правилами категорий';

  @override
  String get amount => 'Сумма';

  @override
  String get category => 'Категория';

  @override
  String get account => 'Счёт';

  @override
  String get fromAccount => 'Со счёта';

  @override
  String get toAccount => 'На счёт';

  @override
  String get descriptionOptional => 'Описание (необязательно)';

  @override
  String get alsoRememberPayee => 'Также запомнить как получателя платежа';

  @override
  String get splitIntoCategories => 'Разделить на несколько категорий';

  @override
  String categoryN(String n) {
    return 'Категория $n';
  }

  @override
  String get destinationAmount => 'Сумма назначения';

  @override
  String get destinationAmountOptional => 'Сумма назначения (необязательно)';

  @override
  String get accountCurrencyAmountOptional =>
      'Сумма в валюте счёта (необязательно)';

  @override
  String get transactionCurrencyOptional => 'Валюта операции (необязательно)';

  @override
  String get feeOptional => 'Комиссия (необязательно)';

  @override
  String get feeAmount => 'Сумма комиссии';

  @override
  String get feeCategory => 'Категория комиссии';

  @override
  String get feeDescriptionOptional => 'Описание комиссии (необязательно)';

  @override
  String get feeDeducted => 'Комиссия вычитается из указанной выше суммы';

  @override
  String get needTwoAccountsToTransfer =>
      'Создайте как минимум два активных счёта, чтобы выполнить перевод.';

  @override
  String get whatArrivedTitle => 'Что пришло?';

  @override
  String get whatArrivedBlurb => 'Укажите, что фактически пришло.';

  @override
  String get amountThatArrived => 'Сумма, которая пришла';

  @override
  String get feeLossCategory => 'Категория комиссии / убытка';

  @override
  String get alreadySettled => 'Уже завершено.';

  @override
  String get holdingsTitle => 'Портфель';

  @override
  String get holdingsCash => 'Денежные средства';

  @override
  String get holdingsInventory => 'АКТИВЫ';

  @override
  String holdingsBook(String amount, String currency) {
    return 'Балансовая стоимость (деньги + себестоимость) $amount $currency';
  }

  @override
  String holdingsMarketEstimate(String amount, String currency) {
    return 'Рыночная оценка $amount $currency';
  }

  @override
  String get holdingsNoHoldings =>
      'Пока нет активов. Запишите покупку, чтобы добавить инструмент.';

  @override
  String get holdingsQuotesBlurb =>
      'Котировки являются оценкой, а не брокерской ценой. Это приложение не размещает заявки.';

  @override
  String get holdingsTapNameToResearch =>
      'Нажмите на название для анализа. Котировки — это оценка, а не совет.';

  @override
  String get instrument => 'Инструмент';

  @override
  String get newInstrument => 'Новый инструмент';

  @override
  String get renameInstrument => 'Переименовать инструмент';

  @override
  String get instrumentActions => 'Действия с инструментом';

  @override
  String hideInstrumentTitle(String name) {
    return 'Скрыть $name?';
  }

  @override
  String get tickerOptional => 'Тикер (необязательно)';

  @override
  String get isinOptional => 'ISIN (необязательно)';

  @override
  String get quantity => 'Количество';

  @override
  String get unitPrice => 'Цена за единицу';

  @override
  String get brokerageOptional => 'Брокерская комиссия (необязательно)';

  @override
  String get brokerageExpenseCategory =>
      'Категория расходов на брокерскую комиссию';

  @override
  String get incomeCategory => 'Категория дохода';

  @override
  String get gainIncomeCategory => 'Категория дохода от прибыли';

  @override
  String get lossExpenseCategory => 'Категория расходов от убытка';

  @override
  String get nonCash => 'Неденежное';

  @override
  String get cash => 'Денежные средства';

  @override
  String get locked => 'Заблокировано';

  @override
  String get lockUntilHint =>
      'Ваша собственная заметка об ограничении, а не правило брокера.';

  @override
  String get instrumentKindStock => 'Акция';

  @override
  String get instrumentKindEtf => 'ETF';

  @override
  String get instrumentKindMutualFund => 'Паевой фонд';

  @override
  String get instrumentKindBond => 'Облигация';

  @override
  String get instrumentKindOther => 'Другое';

  @override
  String get quoteUseLive => 'Актуальная цена';

  @override
  String get quoteUseCached => 'Цена из кэша';

  @override
  String get quoteUseStale => 'Устаревшая цена';

  @override
  String get quoteUseMissing => 'Используется себестоимость (цена отсутствует)';

  @override
  String get quoteUseDisabled =>
      'Котировки отключены — используется себестоимость/кэш';

  @override
  String get quoteUseCurrencyMismatch =>
      'Используется себестоимость (валюта цены отличается)';

  @override
  String unrealizedLabel(String amount, String currency) {
    return 'Нереализовано $amount $currency';
  }

  @override
  String holdingsUnitsCost(String qty) {
    return '$qty ед. · ';
  }

  @override
  String get recoveryPhraseTitle => 'Ваша фраза восстановления';

  @override
  String get recoveryPhraseConfirmTitle => 'Подтвердите вашу фразу';

  @override
  String get recoveryPhraseBlurb =>
      'Эти 24 слова — единственный способ восстановить историю ваших операций, если это устройство будет утеряно, сброшено или заменено. У Smara учёта нет сервера, и он не может восстановить их за вас.\n\nЕсли вы потеряете это устройство и эту фразу вместе, каждая записанная вами операция станет навсегда непроверяемой.';

  @override
  String get recoveryPhraseWriteDown =>
      'Запишите эти слова по порядку и храните их в безопасном месте отдельно от этого устройства.';

  @override
  String get iveSavedRecoveryPhrase => 'Я сохранил свою фразу восстановления';

  @override
  String get confirmPhraseBlurb =>
      'Введите запрошенные слова из фразы, которую вы только что сохранили.';

  @override
  String wordNumber(String n) {
    return 'Слово №$n';
  }

  @override
  String get keystoreExportTitle => 'Экспорт файла ключей';

  @override
  String get keystoreExportBlurb =>
      'Помимо фразы восстановления, вы можете сохранить зашифрованный файл ключей, защищённый выбранной вами парольной фразой. Это необязательно - одной фразы восстановления всегда достаточно, чтобы восстановить ключ подписи.';

  @override
  String get keystorePassphrase => 'Парольная фраза';

  @override
  String get exportKeystoreFile => 'Экспортировать файл ключей';

  @override
  String get chooseCurrencyTitle => 'Выберите вашу валюту';

  @override
  String get chooseCurrencyBlurb =>
      'Каждая группа счетов (Денежные средства и эквиваленты, Пенсия и накопления и т. д.) пока использует одну эту валюту. Вы всегда сможете добавить счета в другой валюте позже, создав для неё новую группу.';

  @override
  String get currencyBackfillTitle => 'Выберите валюту для существующих групп';

  @override
  String get currencyBackfillBlurb =>
      'Теперь приложение поддерживает несколько валют. Вашим существующим счетам и группам счетов нужна валюта - поскольку все они были созданы до появления этой функции, для всех них применяется один выбор.';

  @override
  String get firstAccountTitle => 'Назовите ваш счёт';

  @override
  String get firstAccountBlurb =>
      'Это уже настроенный для вас счёт - дайте ему узнаваемое название, например, название вашего банка. Далее вы запишете одну операцию «Расход» или «Приход», а затем защитите устройство фразой восстановления.';

  @override
  String get whatsMainAccountCalled => 'Как называется ваш основной счёт?';

  @override
  String get restoreTitle => 'Восстановление ключа подписи';

  @override
  String get restoreBlurb =>
      'На этом устройстве есть книги учёта, но нет подходящего ключа подписи. Восстановите его из сохранённой фразы восстановления или файла ключей - ваши данные будут проверяться как обычно, ничего не будет переподписано или изменено.';

  @override
  String get recoveryPhrase24 => 'Фраза восстановления (все 24 слова)';

  @override
  String get keystoreFile => 'Файл ключей';

  @override
  String get keystoreFileContents => 'Содержимое файла ключей';

  @override
  String get optionalBackupFile => 'Необязательный файл резервной копии';

  @override
  String get iDontHavePhrase =>
      'У меня нет фразы восстановления или файла ключей';

  @override
  String get migrationTitle => 'Переход на новый ключ';

  @override
  String get migrationBlurb =>
      'Без фразы восстановления или файла ключей ключ подписи этого устройства невозможно восстановить. Вы можете начать с нового ключа. Старые записи остаются видимыми, но считаются замещёнными.';

  @override
  String get iConfirmBooksValid =>
      'Я подтверждаю, что текущие книги учёта верны';

  @override
  String get whyWeDontEdit => 'Почему мы не редактируем старые записи';

  @override
  String get whyWeDontEditBody =>
      'Когда вы исправляете ошибку, мы сохраняем старую строку и добавляем рядом с ней исправление, вместо того чтобы менять то, что вы уже ввели. Так ваша история всегда показывает, что именно произошло и когда вы это исправили — ничто не меняется незаметно.';

  @override
  String get lockTitle => 'Разблокировка';

  @override
  String get lockScreenTitle => 'Заблокировано';

  @override
  String get enterPinToContinue => 'Введите ваш PIN, чтобы продолжить';

  @override
  String get pinLabel => 'PIN';

  @override
  String get setPinTitle => 'Задайте PIN';

  @override
  String get currentPin => 'Текущий PIN';

  @override
  String get newPin => 'Новый PIN';

  @override
  String get confirmPin => 'Подтвердите PIN';

  @override
  String get confirmNewPin => 'Подтвердите новый PIN';

  @override
  String get firstWeekTitle => 'Настройте ваши счета';

  @override
  String get addCashAccount => 'Добавить наличный счёт';

  @override
  String get addCreditCard => 'Добавить кредитную карту';

  @override
  String get cashAccountName => 'Название наличного счёта';

  @override
  String get cardName => 'Название карты';

  @override
  String get paidFromBank => 'Оплачено с банковского счёта';

  @override
  String get paidFromCard => 'Оплачено картой';

  @override
  String get choosePassphraseTitle =>
      'Выберите парольную фразу для защиты этой резервной копии. Если вы её забудете, восстановление будет невозможно.';

  @override
  String get replaceBooksTitle => 'Заменить ваши локальные книги учёта?';

  @override
  String get replaceBooksBody =>
      'Это заменит всё текущее содержимое приложения резервной копией. После этого закройте и снова откройте приложение.';

  @override
  String get chooseBackupFileFirst => 'Сначала выберите файл резервной копии.';

  @override
  String get backupRestored => 'Резервная копия восстановлена';

  @override
  String get backupRestoredBody =>
      'Ваши книги учёта восстановлены. Закройте и снова откройте приложение, чтобы продолжить.';

  @override
  String get fixThisEntry => 'Исправить эту запись';

  @override
  String get fixBlurb =>
      'Старая строка остаётся точно такой, какой была. Подтверждение добавляет сторнирующую строку и исправленную.';

  @override
  String get importStatementTitle => 'Импорт выписки';

  @override
  String get importOfx => 'Импорт OFX';

  @override
  String get importOfxQfxFile => 'Импорт файла OFX / QFX';

  @override
  String get importCsvFile => 'Импорт файла CSV';

  @override
  String get whatKindOfStatement => 'Какой у вас тип файла выписки?';

  @override
  String get chooseAccountForFile =>
      'Выберите, какому счёту принадлежит этот файл.';

  @override
  String get importIntoAccount => 'Импортировать в счёт';

  @override
  String get useSavedProfile => 'Использовать сохранённый профиль';

  @override
  String get saveMappingProfile =>
      'Сохранить это сопоставление как профиль (необязательно)';

  @override
  String get renameProfile => 'Переименовать профиль';

  @override
  String get deleteProfileTitle => 'Удалить профиль?';

  @override
  String get fileHasHeader => 'Файл содержит строку заголовка';

  @override
  String get dateColumn => 'Столбец даты';

  @override
  String get dateFormatHint => 'Формат даты (напр. дд/ММ/гггг)';

  @override
  String get amountColumn => 'Столбец суммы';

  @override
  String get amountConvention => 'Соглашение о сумме';

  @override
  String get signedAmountColumn => 'Столбец суммы со знаком';

  @override
  String get separateDebitCredit => 'Отдельные столбцы дебета / кредита';

  @override
  String get debitColumn => 'Столбец дебета';

  @override
  String get creditColumn => 'Столбец кредита';

  @override
  String get decimalSeparator => 'Десятичный разделитель (. или ,)';

  @override
  String get descriptionColumns => 'Столбец(-ы) описания';

  @override
  String get referenceIdColumn => 'Столбец референс-номера (необязательно)';

  @override
  String get skippedRows => 'Пропущенные строки';

  @override
  String parsedTransactionCount(String count) {
    return '$count операций распознано';
  }

  @override
  String skippedOrExcludedCount(String count) {
    return '$count пропущено или исключено';
  }

  @override
  String postedFailedCount(String posted, String failed) {
    return '$posted проведено, $failed не удалось';
  }

  @override
  String get categoryForAll => 'Категория для всех';

  @override
  String get saveAsRule => 'Сохранить как правило?';

  @override
  String get saveAsRuleBlurb =>
      'Будущие импорты, описание которых содержит это ключевое слово, будут использовать эту категорию.';

  @override
  String get keyword => 'Ключевое слово';

  @override
  String get noSavedRules =>
      'Пока нет сохранённых правил. Назначьте категорию группе строк, чтобы сохранить правило.';

  @override
  String get deleteRuleTitle => 'Удалить правило?';

  @override
  String get editRule => 'Изменить правило';

  @override
  String rowsGrouped(String count) {
    return '$count строк(и)';
  }

  @override
  String selectStatementFile(String extensions) {
    return 'Выберите файл выписки $extensions для импорта';
  }

  @override
  String get payeesTitle => 'Получатели платежей';

  @override
  String get addPayee => 'Добавить получателя';

  @override
  String get renamePayee => 'Переименовать получателя';

  @override
  String get deletePayeeTitle => 'Удалить получателя?';

  @override
  String get noPayeesYet => 'Пока нет получателей';

  @override
  String get recurringTitle => 'Регулярные шаблоны';

  @override
  String get noRecurringYet => 'Пока нет регулярных шаблонов';

  @override
  String get deleteTemplateTitle => 'Удалить регулярный шаблон?';

  @override
  String get dayOfMonth => 'День месяца (1-31)';

  @override
  String get dayOfMonthNote =>
      'В месяце с меньшим числом дней используется его последний день.';

  @override
  String dayOfMonthLine(String day) {
    return 'День $day месяца - ';
  }

  @override
  String get name => 'Имя';

  @override
  String get none => 'Нет';

  @override
  String get currency => 'Валюта';

  @override
  String get errorGeneric => 'Что-то пошло не так. Попробуйте ещё раз.';

  @override
  String get errorSigningIdentityMismatch =>
      'Эта фраза восстановления или файл ключей не соответствуют ни одной подписывающей идентичности в этой базе данных.';

  @override
  String get errorInvalidLedgerBackup =>
      'Этот файл не является действительной резервной копией Smara.';

  @override
  String get errorInvalidLedgerBackupNoIdentity =>
      'В этой резервной копии нет подписывающей идентичности - это не действительная резервная копия Smara.';

  @override
  String get errorInvalidLedgerBackupUnverified =>
      'Эта резервная копия не прошла проверку как целостные книги учёта, поэтому не была восстановлена.';

  @override
  String errorInvalidLedgerBackupUnreadable(String detail) {
    return 'Не удалось открыть этот файл как резервную копию Smara: $detail';
  }

  @override
  String get errorForeignBackupIdentity =>
      'Эта резервная копия принадлежит другой подписывающей идентичности, отличной от той, что на этом устройстве.';

  @override
  String get errorAccountNotFinancial => 'Это не финансовый счёт.';

  @override
  String get errorAccountArchived => 'Этот счёт скрыт.';

  @override
  String get errorAccountNotArchived => 'Этот счёт не скрыт.';

  @override
  String get errorAccountNoPositiveBalanceToCloseOut =>
      'Нет оставшегося баланса для перевода.';

  @override
  String get errorAccountHasNoGroup => 'У этого счёта не назначена группа.';

  @override
  String get errorGroupHasNoCurrency => 'У этой группы ещё не задана валюта.';

  @override
  String get errorGroupNotFound => 'Эта группа счетов не найдена.';

  @override
  String get errorInvestmentAccountsMustBeAssets =>
      'Только счета-активы могут быть отмечены как инвестиционные счета.';

  @override
  String get errorCreditCardsMustBeLiabilities =>
      'Только счета-обязательства могут быть отмечены как кредитные карты.';

  @override
  String get errorOpeningBalanceMustBePositive =>
      'Начальный баланс должен быть положительным, если он указан.';

  @override
  String get errorAccountTypeDoesNotMatchGroup =>
      'Тип этого счёта не соответствует группе.';

  @override
  String get errorLastActiveAccount =>
      'Нельзя скрыть последний активный финансовый счёт.';

  @override
  String get errorCurrencyRequiredToCreateGroup =>
      'Для создания группы требуется валюта.';

  @override
  String get errorSystemGroupCannotBeArchived =>
      'Встроенные группы счетов нельзя скрыть.';

  @override
  String get errorGroupAlreadyArchived => 'Эта группа уже скрыта.';

  @override
  String get errorCannotArchiveGroupWithAccounts =>
      'Нельзя скрыть группу, в которой ещё есть активные счета.';

  @override
  String get errorSystemGroupNeverArchived =>
      'Встроенные группы счетов никогда не скрываются.';

  @override
  String get errorAccountGroupsCannotBeDeleted =>
      'Группы счетов нельзя удалить.';

  @override
  String get errorCannotReassignDifferentCurrency =>
      'Нельзя переместить этот счёт в группу с другой валютой.';

  @override
  String get errorCannotChangeGroupCurrencyWithAccounts =>
      'Нельзя изменить валюту, пока в группе есть активные счета.';

  @override
  String get errorAmountMustBePositive => 'Сумма должна быть положительной.';

  @override
  String get errorAccountCurrencyAmountMustBePositive =>
      'Сумма в валюте счёта должна быть положительной.';

  @override
  String get errorAccountCurrencyAmountNotForSameCurrency =>
      'Сумма в валюте счёта указывается только для записи в иностранной валюте.';

  @override
  String get errorSplitNeedsTwoLines =>
      'Для разделения нужно как минимум две строки категорий.';

  @override
  String get errorSplitLineMustBePositive =>
      'Каждая строка разделения должна быть положительной суммой.';

  @override
  String get errorSplitLinesMustSumToTotal =>
      'Сумма строк разделения должна совпадать с общей суммой операции.';

  @override
  String get errorTransferAmountMustBePositive =>
      'Сумма перевода должна быть положительной.';

  @override
  String get errorTransferAccountsMustDiffer =>
      'Счёт-источник и счёт назначения должны отличаться.';

  @override
  String get errorCloseoutRequiresDestinationAmount =>
      'Для закрытия межвалютного перевода нужна известная сумма назначения.';

  @override
  String get errorDestinationAmountNotForSameCurrency =>
      'Сумма назначения указывается только для межвалютного перевода.';

  @override
  String get errorDestinationAmountMustBePositive =>
      'Сумма назначения должна быть положительной.';

  @override
  String get errorInvestmentCashExceeded =>
      'Нельзя перевести больше, чем есть денежных средств на этом инвестиционном счёте.';

  @override
  String get errorCannotReverseUnsettledProvisional =>
      'Вместо отмены завершите этот ожидающий перевод.';

  @override
  String get errorAlreadyReversed =>
      'Эта запись уже исправлена. Исходная строка остаётся без изменений.';

  @override
  String get errorNotActiveExpenseCategory =>
      'Выберите активную категорию расходов.';

  @override
  String get errorNotActiveIncomeCategory =>
      'Выберите активную категорию доходов.';

  @override
  String get errorSettledAmountMustNotBeNegative =>
      'Сумма, которая пришла, не может быть отрицательной.';

  @override
  String get errorPendingTransferNotFound =>
      'Этот ожидающий перевод не найден.';

  @override
  String get errorPendingTransferAlreadySettled =>
      'Этот ожидающий перевод уже завершён.';

  @override
  String get errorSettledToMustBeSourceOrDestination =>
      'Выберите исходный счёт или счёт назначения.';

  @override
  String get errorFeeCategoryOnlyWhenReturningToSource =>
      'Категория комиссии используется только тогда, когда деньги возвращаются на счёт-источник.';

  @override
  String get errorSettledAmountMustBePositiveForDelivery =>
      'Введите положительную сумму того, что пришло.';

  @override
  String get errorSettledAmountExceedsProvisional =>
      'Эта сумма больше, чем было отправлено.';

  @override
  String get errorInstrumentNotFound => 'Этот инструмент не найден.';

  @override
  String get errorIncomeRequiredForNonCash =>
      'Для неденежного приобретения требуется активная категория доходов.';

  @override
  String get errorInsufficientCash =>
      'На этом инвестиционном счёте недостаточно денежных средств для этой покупки.';

  @override
  String get errorSellQuantityAndPriceMustBePositive =>
      'Количество и цена за единицу при продаже должны быть положительными.';

  @override
  String errorLockedUntil(String date) {
    return 'Нельзя продать: часть единиц заблокирована до $date.';
  }

  @override
  String get errorInsufficientQuantity =>
      'Нельзя продать больше, чем у вас есть незаблокированного в наличии.';

  @override
  String get errorIncomeRequiredForGain =>
      'Для реализованной прибыли требуется активная категория доходов.';

  @override
  String get errorExpenseRequiredForLoss =>
      'Для реализованного убытка требуется активная категория расходов.';

  @override
  String errorBrokerageFailedAfterBuy(String detail) {
    return 'Покупка проведена, но не удалось записать брокерскую комиссию: $detail';
  }

  @override
  String errorBrokerageFailedAfterSell(String detail) {
    return 'Продажа проведена, но не удалось записать брокерскую комиссию: $detail';
  }

  @override
  String get errorDividendMustBePositive =>
      'Сумма дивиденда должна быть положительной.';

  @override
  String get errorNotInvestmentAccount => 'Это не инвестиционный счёт.';

  @override
  String get errorNoInventoryCompanion =>
      'У этого инвестиционного счёта отсутствует парный счёт активов.';

  @override
  String errorInvestmentReversalBlocked(String sells) {
    return 'Нельзя отменить эту покупку: последующие продажи зависят от этих единиц. Сначала отмените зависимые продажи: $sells.';
  }

  @override
  String get errorMonthlyLimitMustBePositive =>
      'Месячный лимит должен быть положительным.';

  @override
  String get errorTemplateAmountMustBePositive =>
      'Сумма шаблона должна быть положительной.';

  @override
  String get errorOfxUnrecognized => 'Не удалось распознать этот файл как OFX.';

  @override
  String get errorCsvEmpty => 'Выбранный файл пуст.';

  @override
  String get errorCsvUnreadable => 'Не удалось прочитать этот файл как CSV.';

  @override
  String get errorCsvNoRows => 'В выбранном файле нет строк.';

  @override
  String errorBackupCreateFailed(String detail) {
    return 'Не удалось создать резервную копию: $detail';
  }

  @override
  String get errorBackupRestoreFailed =>
      'Не удалось восстановить эту резервную копию - неверная парольная фраза либо это не файл резервной копии Smara.';

  @override
  String get validationAmountAccountCategoryRequired =>
      'Необходимо указать сумму, счёт и категорию.';

  @override
  String get validationAmountAccountRequired =>
      'Необходимо указать сумму и счёт.';

  @override
  String get validationSplitLineIncomplete =>
      'Для каждой строки разделения нужны категория и сумма.';

  @override
  String get validationSplitSumMismatch =>
      'Сумма строк разделения должна совпадать с общей суммой операции.';

  @override
  String get validationFromToAmountRequired =>
      'Необходимо указать счёт-источник, счёт назначения и сумму.';

  @override
  String get validationAmountArrivedRequired =>
      'Необходимо указать сумму, которая пришла.';

  @override
  String get validationChooseReceivingAccount =>
      'Выберите счёт, который получил средства.';

  @override
  String get validationAccountCategoryRequired =>
      'Необходимо указать счёт и категорию.';

  @override
  String get validationFixFailed => 'Не удалось сохранить это исправление.';

  @override
  String get validationNameRequired => 'Назовите ваш основной счёт.';

  @override
  String get validationStillLoading =>
      'Ещё загружается - попробуйте снова через мгновение.';

  @override
  String get validationSaveAccountNameFailed =>
      'Не удалось сохранить название счёта.';

  @override
  String get validationWrongPin => 'Неверный PIN. Попробуйте ещё раз.';

  @override
  String get validationCategoryMustBeIncomeOrExpense =>
      'Категория должна быть доходом или расходом.';

  @override
  String get validationOnlyExpenseHasMonthlyLimit =>
      'Месячный лимит может быть только у категории расходов.';

  @override
  String get validationInvalidTemplate => 'Недопустимый шаблон.';

  @override
  String get validationWrongKeystorePassphrase =>
      'Неверная парольная фраза для этого файла ключей.';

  @override
  String get validationInvalidKeystoreFile =>
      'Это не похоже на действительный файл ключей.';

  @override
  String get validationRestorePhraseFailed =>
      'Не удалось восстановить по этой фразе восстановления.';

  @override
  String validationGenerateKeyFailed(String detail) {
    return 'Не удалось сгенерировать ключ подписи на этом устройстве: $detail';
  }

  @override
  String validationSaveCurrencyFailed(String detail) {
    return 'Не удалось сохранить эту валюту: $detail';
  }

  @override
  String get validationMigrationFailed =>
      'Миграция не удалась. Попробуйте ещё раз.';

  @override
  String get validationChooseBackupFile =>
      'Сначала выберите файл резервной копии.';

  @override
  String get validationPassphraseRequired => 'Введите парольную фразу.';

  @override
  String get validationPinsDoNotMatch => 'Два PIN-кода не совпадают.';

  @override
  String get validationFeePositiveWithCategory =>
      'Комиссия за перевод должна быть положительной суммой с выбранной категорией расходов.';

  @override
  String get validationFeeMustBeLessThanAmount =>
      'Для перевода с удержанием комиссии комиссия должна быть меньше суммы.';

  @override
  String validationTransferSavedFeeFailed(String detail) {
    return 'Перевод сохранён, но не удалось записать комиссию: $detail';
  }

  @override
  String get validationEnterValidAmount => 'Введите корректную сумму.';

  @override
  String validationConfirmWordMismatch(String n) {
    return 'Слово $n не совпадает с вашей сохранённой фразой. Проверьте и попробуйте снова.';
  }

  @override
  String get errorBuyQuantityAndPriceMustBePositive =>
      'Количество и цена за единицу при покупке должны быть положительными.';

  @override
  String get errorInstrumentArchived => 'Нельзя купить скрытый инструмент.';

  @override
  String get errorNonCashCannotIncludeBrokerage =>
      'Неденежные приобретения не могут включать брокерскую комиссию.';

  @override
  String get errorBrokerageRequiresExpenseCategory =>
      'При положительной брокерской комиссии требуется активная категория расходов.';

  @override
  String get errorSellProceedsMustCoverBrokerage =>
      'Выручка от продажи должна быть не меньше суммы брокерской комиссии.';

  @override
  String homeSpentOfLimitThisMonth(String spent, String limit) {
    return '$spent из $limit за этот месяц';
  }

  @override
  String get unlockBiometricReason => 'Разблокировать Smara учёт';

  @override
  String get searchLabel => 'Поиск';

  @override
  String get openingBalance => 'Начальный баланс';

  @override
  String transferToName(String name) {
    return 'Перевод: $name';
  }

  @override
  String get feeForTransfer => 'Комиссия за перевод';

  @override
  String feeForTransferTo(String name) {
    return 'Комиссия за перевод к $name';
  }

  @override
  String couldNotOpenFilePicker(String detail) {
    return 'Не удалось открыть выбор файла: $detail';
  }

  @override
  String pleaseSelectFile(String extensions) {
    return 'Выберите файл .$extensions';
  }

  @override
  String get currencyCodeIso => 'Код валюты (ISO 4217, напр. USD)';

  @override
  String splitCounterpartMore(String name, String count) {
    return '$name и ещё $count';
  }

  @override
  String get dateLabel => 'Дата';

  @override
  String get noneSelected => 'Нет';

  @override
  String reviewEntriesBeforeContinuing(String count) {
    return 'Прежде чем продолжить, просмотрите записи ниже (всего $count).';
  }

  @override
  String youReceived(String amount) {
    return 'Вы получили $amount';
  }

  @override
  String get leaveBlankIfRateUnknown =>
      'Оставьте пустым, если курс обмена ещё неизвестен.';

  @override
  String get recordTradeBlurb =>
      'Запишите сделку, которая уже состоялась. Это приложение не размещает заявки.';

  @override
  String get feeOnTopBlurb =>
      'Сверху: указанная выше сумма — это общая сумма, списываемая с этого счёта; комиссия удерживается из неё.';

  @override
  String get feeBankBlurb =>
      'Авансовая комиссия, взимаемая вашим банком или посредником.';

  @override
  String get validationPinMinLength => 'PIN должен содержать не менее 4 цифр.';

  @override
  String get restoreBackupBlurb =>
      'Это заменит всё текущее содержимое приложения резервной копией — без объединения. Выберите файл резервной копии и введите парольную фразу, которой вы её защитили.';

  @override
  String get actionReplace => 'Заменить';

  @override
  String hideAccountBody(String name) {
    return '$name больше не будет доступен для новых операций.';
  }

  @override
  String hideGroupBody(String name) {
    return '$name больше не будет предлагаться при создании или переназначении счетов.';
  }

  @override
  String hideCategoryBody(String name) {
    return '$name больше не будет предлагаться при записи новых операций.';
  }

  @override
  String get hideInstrumentBody =>
      'Скрытые инструменты остаются в прошлых покупках и продажах. Вы всё ещё можете записать для них дивиденд.';

  @override
  String nameHidden(String name) {
    return '$name (скрыто)';
  }

  @override
  String get noCurrencySet => 'Валюта не задана';

  @override
  String deletePayeeBody(String name) {
    return '$name и его запомненные значения по умолчанию будут удалены. Прошлые операции не затронуты.';
  }

  @override
  String deleteTemplateBody(String name) {
    return '$name больше не будет предлагаться как наступивший. Уже записанные им прошлые операции не затронуты.';
  }

  @override
  String deleteProfileBody(String name) {
    return 'Сохранённое сопоставление столбцов «$name» будет удалено. Уже импортированные с его помощью выписки не затронуты.';
  }

  @override
  String deleteRuleBody(String keyword) {
    return 'Импорты больше не будут автоматически категоризироваться по «$keyword». Уже категоризированные по этому правилу операции не затронуты.';
  }

  @override
  String get firstWeekBlurb =>
      'По желанию добавьте сейчас кредитную карту или наличный счёт - вы всегда сможете добавить больше счетов позже, в настройках.';

  @override
  String get deliveredToDestination => 'Доставлено в пункт назначения';

  @override
  String deliveredToName(String name) {
    return 'Доставлено на $name';
  }

  @override
  String youReceivedLessThanExpected(String amount, String currency) {
    return 'Вы получили на $amount $currency меньше, чем ожидалось - выберите категорию, чтобы покрыть разницу.';
  }

  @override
  String get dateRangeLabel => 'Диапазон дат';

  @override
  String get addTemplate => 'Добавить шаблон';

  @override
  String get editTemplate => 'Изменить шаблон';

  @override
  String get validationFillTemplateFields =>
      'Заполните каждое поле корректной суммой и днём.';

  @override
  String get saveCsvExport => 'Сохранить экспорт CSV';

  @override
  String get referenceRate => 'Справочный курс';

  @override
  String get yourRate => 'Ваш курс';

  @override
  String leaveBlankIfThisWasAccountCurrency(String currency) {
    return 'Оставьте пустым, если это было в $currency, собственной валюте счёта.';
  }

  @override
  String get lockUntilOptional => 'Заблокировать до (необязательно)';

  @override
  String lockedUntilDate(String date) {
    return 'Заблокировано до $date';
  }

  @override
  String get copiedResearchPrompt =>
      'Скопирован исследовательский запрос — ссылка на браузер недоступна либо вы не в сети.';

  @override
  String get openedFavouriteResearchTool =>
      'Открыт ваш любимый инструмент анализа.';

  @override
  String get looksLikeGain => 'Похоже на прибыль';

  @override
  String get looksLikeLoss => 'Похоже на убыток';

  @override
  String get looksLikeBreakEven => 'Похоже на безубыточность';

  @override
  String sellableQuantity(String name, String qty) {
    return '$name (доступно к продаже: $qty)';
  }

  @override
  String columnN(String index) {
    return 'Столбец $index';
  }

  @override
  String get importingLabel => 'Импортируется...';

  @override
  String get confirmImport => 'Подтвердить импорт';

  @override
  String get manageSavedCategoryRules =>
      'Управление сохранёнными правилами категорий';

  @override
  String statementCurrencyMismatch(String currency) {
    return 'Валюта этого файла ($currency) не совпадает с валютой выбранного счёта.';
  }

  @override
  String get categoryRulesTitle => 'Правила категорий';

  @override
  String get possibleDuplicate => 'возможный дубликат';

  @override
  String get unknownCategory => 'Неизвестная категория';
}
