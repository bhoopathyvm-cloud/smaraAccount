// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appTitle => 'Smara облік';

  @override
  String get navHome => 'Головна';

  @override
  String get navRegister => 'Журнал';

  @override
  String get navSummary => 'Підсумок';

  @override
  String get navAccounts => 'Рахунки';

  @override
  String get navCategories => 'Категорії';

  @override
  String get actionCancel => 'Скасувати';

  @override
  String get actionSave => 'Зберегти';

  @override
  String get actionDelete => 'Видалити';

  @override
  String get actionDone => 'Готово';

  @override
  String get actionContinue => 'Продовжити';

  @override
  String get actionDismiss => 'Закрити';

  @override
  String get actionRetry => 'Повторити';

  @override
  String get actionSkip => 'Пропустити';

  @override
  String get actionConfirm => 'Підтвердити';

  @override
  String get actionAdd => 'Додати';

  @override
  String get actionEdit => 'Редагувати';

  @override
  String get actionRename => 'Перейменувати';

  @override
  String get actionHide => 'Приховати';

  @override
  String get actionCreate => 'Створити';

  @override
  String get actionCloseApp => 'Закрити застосунок';

  @override
  String get actionUnlock => 'Розблокувати';

  @override
  String get actionSettle => 'Закрити';

  @override
  String get actionFinish => 'Завершити';

  @override
  String get actionPreview => 'Попередній перегляд';

  @override
  String get actionImport => 'Імпортувати';

  @override
  String get actionExportCsv => 'Експортувати CSV';

  @override
  String get actionChooseFile => 'Вибрати файл';

  @override
  String get actionRestore => 'Відновити';

  @override
  String get actionFix => 'Виправити';

  @override
  String get actionBuy => 'Купити';

  @override
  String get actionSell => 'Продати';

  @override
  String get actionDividend => 'Дивіденд';

  @override
  String get actionRecordBuy => 'Записати купівлю';

  @override
  String get actionRecordSell => 'Записати продаж';

  @override
  String get actionRecordDividend => 'Записати дивіденд';

  @override
  String get actionPayCard => 'Оплатити картку';

  @override
  String get actionTransfer => 'Переказати';

  @override
  String get actionRecordTransaction => 'Записати операцію';

  @override
  String get actionImportStatement => 'Імпортувати виписку';

  @override
  String get actionClearDates => 'Очистити дати';

  @override
  String get actionClearSearch => 'Очистити пошук і фільтри';

  @override
  String get actionUseBiometrics => 'Використати біометрію';

  @override
  String get actionSetPin => 'Встановити PIN';

  @override
  String get actionChangePin => 'Змінити PIN';

  @override
  String get actionSaveBackup => 'Зберегти резервну копію';

  @override
  String get actionRestoreBackup => 'Відновити з резервної копії';

  @override
  String get actionSaveRule => 'Зберегти правило';

  @override
  String get actionConfirmFix => 'Підтвердити виправлення';

  @override
  String get captureSpent => 'Витрачено';

  @override
  String get captureReceived => 'Отримано';

  @override
  String get captureMovedMoney => 'Переказ коштів';

  @override
  String get captureImportStatement => 'Імпортувати виписку';

  @override
  String get settingsTitle => 'Налаштування';

  @override
  String get settingsLanguage => 'Мова';

  @override
  String get settingsLanguageSystem => 'Мова пристрою';

  @override
  String get settingsFetchFxRates => 'Отримувати довідкові курси обміну';

  @override
  String get settingsFetchFxRatesSubtitle =>
      'Показує орієнтовний ринковий курс поруч із сумою отримання при переказах між валютами — лише для порівняння, ніколи не використовується для заповнення суми.';

  @override
  String get settingsRateProvider => 'Постачальник курсів';

  @override
  String get settingsFetchMarketPrices =>
      'Отримувати ринкові ціни для інвестицій';

  @override
  String get settingsFetchMarketPricesSubtitle =>
      'Шукає останні ціни для інструментів, що мають тікер або ISIN, щоб оцінити вартість портфеля. Ніколи не використовується для запису угоди і ніколи не надсилає, скільки одиниць ви утримуєте.';

  @override
  String get settingsMarketPriceProvider => 'Постачальник ринкових цін';

  @override
  String get settingsFavouriteResearchTool =>
      'Улюблений інструмент для аналізу';

  @override
  String get settingsFavouriteResearchToolSubtitle =>
      'Дотик до назви інструмента в активах відкриває цей інструмент у браузері із запитом для аналізу — це не інтеграція і не порада.';

  @override
  String get settingsBackup => 'Резервне копіювання';

  @override
  String get settingsBackupBlurb =>
      'Збережіть зашифровану копію ваших книг у обране вами місце або відновіть з неї. Це окремо від вашої відновлювальної фрази чи файлу keystore, які резервують ваш ключ підпису, а не ваші книги.';

  @override
  String get settingsLock => 'Блокування';

  @override
  String get settingsLockBlurb =>
      'Вимагати PIN-код або біометрію (де доступно) для відкриття застосунку.';

  @override
  String get settingsRequireUnlock =>
      'Вимагати розблокування для відкриття застосунку';

  @override
  String get settingsLockAfter => 'Блокувати через';

  @override
  String get settingsLockImmediately => 'Одразу';

  @override
  String get settingsLock1Minute => '1 хвилину';

  @override
  String get settingsLock5Minutes => '5 хвилин';

  @override
  String get settingsLock15Minutes => '15 хвилин';

  @override
  String get settingsAllowBiometrics => 'Також дозволити біометрію';

  @override
  String get settingsHideSnapshot =>
      'Приховувати баланси в перемикачі застосунків';

  @override
  String get settingsHideSnapshotSubtitle =>
      'Приховує цей екран, коли ви переходите до іншого застосунку, щоб його не було видно одразу в перемикачі застосунків.';

  @override
  String get settingsHideSnapshotUnavailable =>
      'Приховування балансів у перемикачі застосунків недоступне на цій платформі.';

  @override
  String get settingsPayees => 'Отримувачі';

  @override
  String get settingsManagePayees => 'Керувати отримувачами';

  @override
  String get settingsPayeesBlurb =>
      'Запам\'ятовані імена отримувачів разом із категорією та рахунком за замовчуванням, що пропонуються автозаповненням під час запису операції.';

  @override
  String get settingsRecurring => 'Регулярні шаблони';

  @override
  String get settingsManageRecurring => 'Керувати регулярними шаблонами';

  @override
  String get settingsRecurringBlurb =>
      'Рахунки або дохід, що повторюються щомісяця, наприклад оренда чи зарплата. Шаблон із настанням терміну з\'являється на Головній, щоб ви записали його одним дотиком — ніколи не проводиться автоматично.';

  @override
  String get settingsAbout => 'Про застосунок';

  @override
  String get settingsPrivacyPolicy => 'Політика конфіденційності';

  @override
  String get settingsPrivacyPolicyOpenFailed =>
      'Не вдалося відкрити політику конфіденційності в браузері.';

  @override
  String get providerFrankfurter => 'Frankfurter (курси ЄЦБ)';

  @override
  String get providerOpenErApi => 'ExchangeRate-API (open.er-api.com)';

  @override
  String get providerStooq => 'Stooq (щоденні котирування)';

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
  String get systemGroupCashEquivalents => 'Готівка та її еквіваленти';

  @override
  String get systemGroupPensionRetirement => 'Пенсія та пенсійні накопичення';

  @override
  String get systemGroupCreditShortTerm =>
      'Кредит і короткострокова заборгованість';

  @override
  String get systemGroupLoansMortgages => 'Кредити та іпотеки';

  @override
  String get systemGroupInvestments => 'Інвестиції';

  @override
  String get systemAccountCashBank => 'Готівка та банк';

  @override
  String get systemCategorySalary => 'Зарплата';

  @override
  String get systemCategoryOtherIncome => 'Інший дохід';

  @override
  String get systemCategoryGroceries => 'Продукти';

  @override
  String get systemCategoryRentMortgage => 'Оренда/Іпотека';

  @override
  String get systemCategoryUtilities => 'Комунальні послуги';

  @override
  String get systemCategoryTransport => 'Транспорт';

  @override
  String get systemCategoryFoodOut => 'Харчування поза домом';

  @override
  String get systemCategoryPhone => 'Телефон';

  @override
  String get systemCategoryHealth => 'Здоров\'я';

  @override
  String get systemCategoryOtherExpense => 'Інші витрати';

  @override
  String get systemDescriptionCsvImport => 'Імпорт CSV';

  @override
  String get systemDescriptionOfxImport => 'Імпорт OFX';

  @override
  String get homeThisMonth => 'ЦЕЙ МІСЯЦЬ';

  @override
  String get homeMoneyInTransit => 'КОШТИ В ДОРОЗІ';

  @override
  String get homeWhatYouHaveMinusWhatYouOwe => 'ВАШІ КОШТИ МІНУС ВАШІ БОРГИ';

  @override
  String homeWhatYouHave(String amount, String currency) {
    return 'У вас є $amount $currency';
  }

  @override
  String homeNetPosition(String amount, String currency) {
    return '$amount $currency';
  }

  @override
  String homeHaveAndOwe(String haveAmount, String currency, String oweAmount) {
    return 'У вас є $haveAmount $currency  •  Ви винні $oweAmount $currency';
  }

  @override
  String youSentFrom(String amount, String currency, String name) {
    return 'Ви надіслали $amount $currency з $name';
  }

  @override
  String youSentTo(String amount, String currency, String name) {
    return 'Ви надіслали $amount $currency на $name';
  }

  @override
  String get hiddenLabel => 'Приховано';

  @override
  String get allAccounts => 'Усі рахунки';

  @override
  String savedToPath(String path) {
    return 'Збережено в $path';
  }

  @override
  String get homeTapWhenArrived => 'Натисніть, коли дізнаєтеся, що надійшло';

  @override
  String homeReturnedTo(String name) {
    return 'Повернено на $name';
  }

  @override
  String get homeDueToday => 'СЬОГОДНІ ТЕРМІН';

  @override
  String homeDueLine(String category, String account) {
    return '$category · $account · натисніть, щоб записати';
  }

  @override
  String get homeOverLimit => 'Перевищено ліміт';

  @override
  String homeSpentOfLimit(String spent, String limit) {
    return '$spent з $limit';
  }

  @override
  String homeRemaining(String amount) {
    return 'Залишок: $amount';
  }

  @override
  String get homeNoAccounts => 'Немає рахунків';

  @override
  String get homeCashRegister => 'Готівкові кошти';

  @override
  String get homeMarketEstimate => 'Оцінка за ринком';

  @override
  String get registerTitle => 'Журнал';

  @override
  String get registerSearchHint => 'Опис, категорія або сума';

  @override
  String get registerNoTransactions => 'Ще немає операцій';

  @override
  String get registerNoEntries => 'Ще не записано жодного запису.';

  @override
  String get registerSpentOnly => 'Тільки витрати';

  @override
  String get registerReceivedOnly => 'Тільки надходження';

  @override
  String get registerAll => 'Усі';

  @override
  String get registerUnverified =>
      'Не підтверджено - не враховується в підсумках';

  @override
  String get registerSuperseded =>
      'Замінено внаслідок міграції ключа - не враховується в підсумках';

  @override
  String get summaryTitle => 'Підсумок';

  @override
  String get summaryTotalIncome => 'Загальний дохід';

  @override
  String get summaryTotalExpense => 'Загальні витрати';

  @override
  String summaryDateRange(String start, String end) {
    return '$start — $end';
  }

  @override
  String get accountsTitle => 'Рахунки';

  @override
  String get categoriesTitle => 'Категорії';

  @override
  String get accountName => 'Назва рахунку';

  @override
  String get createAccount => 'Створити рахунок';

  @override
  String get createGroup => 'Створити групу';

  @override
  String get editGroup => 'Редагувати групу';

  @override
  String get renameAccount => 'Перейменувати рахунок';

  @override
  String get renameCategory => 'Перейменувати категорію';

  @override
  String get addCategory => 'Додати категорію';

  @override
  String get groupLabel => 'Група';

  @override
  String get kindLabel => 'Тип';

  @override
  String get asset => 'Актив';

  @override
  String get liability => 'Зобов\'язання';

  @override
  String get income => 'Дохід';

  @override
  String get expense => 'Витрата';

  @override
  String get thisAccountHoldsInvestments => 'Цей рахунок утримує інвестиції';

  @override
  String get thisAccountHoldsInvestmentsSubtitle =>
      'Готівка плюс запаси, які ви записуєте за допомогою Купівлі, Продажу та Дивіденду.';

  @override
  String get thisIsACreditCard => 'Це кредитна картка';

  @override
  String get openingBalanceOptional => 'Початковий баланс (необов\'язково)';

  @override
  String get currencyIso => 'Валюта (ISO 4217)';

  @override
  String get currencyIsoExample => 'Валюта (ISO 4217, напр. USD)';

  @override
  String get hideAccountTitle => 'Приховати рахунок від нових записів?';

  @override
  String get hideCategoryTitle => 'Приховати категорію від нових записів?';

  @override
  String get hideGroupTitle => 'Приховати групу від нових записів?';

  @override
  String get reassignGroup => 'Змінити групу';

  @override
  String get transferRemainingBalance => 'Перевести залишок балансу';

  @override
  String get monthlyLimit => 'Місячний ліміт';

  @override
  String get monthlyLimitHint => 'Ліміт (залиште порожнім, щоб очистити)';

  @override
  String get monthlyLimitBlurb =>
      'Необов\'язковий орієнтир витрат з початку місяця для цієї категорії витрат.';

  @override
  String get translateCategoryWithAi => 'Перекласти за допомогою AI';

  @override
  String get addCategoryTranslation => 'Додати переклад';

  @override
  String get categoryTranslationLocale => 'Мова';

  @override
  String get categoryTranslationName => 'Перекладена назва';

  @override
  String get mergeCategories => 'Об\'єднати категорії';

  @override
  String get mergeCategoriesSuggested =>
      'Ці категорії виглядають однаково. Об\'єднати їх?';

  @override
  String get categoryDefaultLanguage => 'Мова назв категорій за замовчуванням';

  @override
  String get categoryDefaultLanguageSubtitle =>
      'Спільна для пов\'язаних пристроїв. Кожен пристрій і далі показує свою мову, якщо є переклад.';

  @override
  String get manageCategoryRules => 'Керувати правилами категорій';

  @override
  String get amount => 'Сума';

  @override
  String get category => 'Категорія';

  @override
  String get account => 'Рахунок';

  @override
  String get fromAccount => 'З рахунку';

  @override
  String get toAccount => 'На рахунок';

  @override
  String get descriptionOptional => 'Опис (необов\'язково)';

  @override
  String get alsoRememberPayee => 'Також запам\'ятати як отримувача';

  @override
  String get splitIntoCategories => 'Розділити на кілька категорій';

  @override
  String categoryN(String n) {
    return 'Категорія $n';
  }

  @override
  String get destinationAmount => 'Сума отримання';

  @override
  String get destinationAmountOptional => 'Сума отримання (необов\'язково)';

  @override
  String get accountCurrencyAmountOptional =>
      'Сума у валюті рахунку (необов\'язково)';

  @override
  String get transactionCurrencyOptional => 'Валюта операції (необов\'язково)';

  @override
  String get feeOptional => 'Комісія (необов\'язково)';

  @override
  String get feeAmount => 'Сума комісії';

  @override
  String get feeCategory => 'Категорія комісії';

  @override
  String get feeDescriptionOptional => 'Опис комісії (необов\'язково)';

  @override
  String get feeDeducted => 'Комісія утримується із суми вище';

  @override
  String get needTwoAccountsToTransfer =>
      'Створіть щонайменше два активні рахунки, щоб здійснити переказ.';

  @override
  String get whatArrivedTitle => 'Що надійшло?';

  @override
  String get whatArrivedBlurb => 'Повідомте, що саме надійшло.';

  @override
  String get amountThatArrived => 'Сума, що надійшла';

  @override
  String get feeLossCategory => 'Категорія комісії / збитку';

  @override
  String get alreadySettled => 'Уже закрито.';

  @override
  String get holdingsTitle => 'Активи';

  @override
  String get holdingsCash => 'Готівка';

  @override
  String get holdingsInventory => 'ЗАПАСИ';

  @override
  String holdingsBook(String amount, String currency) {
    return 'За обліком (готівка + вартість) $amount $currency';
  }

  @override
  String holdingsMarketEstimate(String amount, String currency) {
    return 'Оцінка за ринком $amount $currency';
  }

  @override
  String get holdingsNoHoldings =>
      'Активів ще немає. Запишіть купівлю, щоб додати інструмент.';

  @override
  String get holdingsQuotesBlurb =>
      'Котирування є оцінковими, а не ціною брокера. Цей застосунок не подає заявки.';

  @override
  String get holdingsTapNameToResearch =>
      'Натисніть на назву, щоб дослідити. Котирування є оцінковими, а не порадою.';

  @override
  String get instrument => 'Інструмент';

  @override
  String get newInstrument => 'Новий інструмент';

  @override
  String get renameInstrument => 'Перейменувати інструмент';

  @override
  String get instrumentActions => 'Дії з інструментом';

  @override
  String hideInstrumentTitle(String name) {
    return 'Приховати $name?';
  }

  @override
  String get tickerOptional => 'Тікер (необов\'язково)';

  @override
  String get isinOptional => 'ISIN (необов\'язково)';

  @override
  String get quantity => 'Кількість';

  @override
  String get unitPrice => 'Ціна за одиницю';

  @override
  String get brokerageOptional => 'Брокерська комісія (необов\'язково)';

  @override
  String get brokerageExpenseCategory =>
      'Категорія витрат на брокерську комісію';

  @override
  String get incomeCategory => 'Категорія доходу';

  @override
  String get gainIncomeCategory => 'Категорія доходу від прибутку';

  @override
  String get lossExpenseCategory => 'Категорія витрат від збитку';

  @override
  String get nonCash => 'Негрошове';

  @override
  String get cash => 'Готівка';

  @override
  String get locked => 'Заблоковано';

  @override
  String get lockUntilHint =>
      'Ваша власна нотатка про обмеження, а не правило брокера.';

  @override
  String get instrumentKindStock => 'Акція';

  @override
  String get instrumentKindEtf => 'ETF';

  @override
  String get instrumentKindMutualFund => 'Пайовий фонд';

  @override
  String get instrumentKindBond => 'Облігація';

  @override
  String get instrumentKindOther => 'Інше';

  @override
  String get quoteUseLive => 'Актуальна ціна';

  @override
  String get quoteUseCached => 'Кешована ціна';

  @override
  String get quoteUseStale => 'Застаріла ціна';

  @override
  String get quoteUseMissing => 'Використовується вартість (немає ціни)';

  @override
  String get quoteUseDisabled =>
      'Котирування вимкнено — використовується вартість/кеш';

  @override
  String get quoteUseCurrencyMismatch =>
      'Використовується вартість (валюта ціни відрізняється)';

  @override
  String unrealizedLabel(String amount, String currency) {
    return 'Нереалізовано $amount $currency';
  }

  @override
  String holdingsUnitsCost(String qty) {
    return '$qty од. · ';
  }

  @override
  String get chooseLanguageTitle => 'Оберіть свою мову';

  @override
  String get chooseLanguageBlurb =>
      'Усе в застосунку відображатиметься цією мовою. Ви можете змінити це пізніше в Налаштуваннях.';

  @override
  String get chooseCurrencyTitle => 'Виберіть вашу валюту';

  @override
  String get chooseCurrencyBlurb =>
      'Кожна група рахунків (Готівка та її еквіваленти, Пенсія та пенсійні накопичення тощо) наразі використовує цю одну валюту. Пізніше ви все ще зможете додати рахунки в іншій валюті, створивши для неї нову групу.';

  @override
  String get currencyBackfillTitle => 'Виберіть валюту для наявних груп';

  @override
  String get currencyBackfillBlurb =>
      'Цей застосунок тепер підтримує кілька валют. Ваші наявні рахунки та групи рахунків потребують валюти - оскільки всі вони були налаштовані до появи цієї функції, один вибір застосовується до всіх них.';

  @override
  String get firstAccountTitle => 'Назвіть свій рахунок';

  @override
  String get firstAccountBlurb =>
      'Це рахунок, який уже налаштований для вас - дайте йому назву, яку ви впізнаєте, наприклад назву вашого банку. Далі ви запишете одну операцію Витрачено або Отримано, а потім захистите пристрій своєю відновлювальною фразою.';

  @override
  String get whatsMainAccountCalled => 'Як називається ваш основний рахунок?';

  @override
  String get setupChoiceTitle => 'Ласкаво просимо до Smara облік';

  @override
  String get setupChoiceBlurb =>
      'Починаєте з нуля чи переходите з іншого пристрою?';

  @override
  String get actionNewSetup => 'Нове налаштування';

  @override
  String get continueBooksTitle => 'Продовжити мої книги на цьому телефоні';

  @override
  String get continueBooksBlurb =>
      'Ці книги потрапили на цей телефон без свого ключа підпису. Ви можете продовжити їх з новим ключем для цього телефона або натомість відновити зі збереженої копії.';

  @override
  String get continueBooksAction => 'Продовжити мої книги на цьому телефоні';

  @override
  String get restoreFromCopyAction => 'Відновити з копії';

  @override
  String get saveBooksCopyAction => 'Зберегти копію моїх книг';

  @override
  String get deviceHistoryTitle => 'Історія пристроїв';

  @override
  String get deviceHistoryEmpty =>
      'Продовжень поки немає. Коли ви продовжите книги на новому телефоні, вони з’являться тут.';

  @override
  String deviceHistoryContinuedOn(String date) {
    return 'Ваші книги продовжено на цьому телефоні $date';
  }

  @override
  String deviceHistoryContinuedFromCopy(String continuedDate, String copyDate) {
    return 'Ваші книги продовжено на цьому телефоні $continuedDate (з копії, збереженої $copyDate)';
  }

  @override
  String get backupReminderBannerTitle => 'Збережіть копію своїх книг';

  @override
  String get backupReminderSaveAction => 'Зберегти копію';

  @override
  String get backupReminderLaterAction => 'Пізніше';

  @override
  String get settingsBackupReminder => 'Нагадування про копію';

  @override
  String get settingsBackupReminderBlurb =>
      'Через деякий час або після багатьох нових записів ми м’яко нагадаємо зберегти копію книг. Збережена копія — єдиний спосіб повернути книги, якщо цей телефон загубиться.';

  @override
  String get settingsBackupReminderEnabled => 'Нагадувати про збереження копії';

  @override
  String get settingsBackupReminderDays => 'Нагадати через стільки днів';

  @override
  String get settingsBackupReminderEntries =>
      'Нагадати після стількох нових записів';

  @override
  String get settingsBackupReminderSnoozeDays =>
      'Сховати на стільки днів після «Пізніше»';

  @override
  String get settingsBackupReminderSnoozeEntries =>
      'Сховати на стільки нових записів після «Пізніше»';

  @override
  String get settingsBooksSwitcher => 'Книги на цьому пристрої';

  @override
  String get settingsBooksSwitcherBlurb =>
      'Кожен набір книг має власний ключ підпису та історію. Перемикання відкриває цей набір — на Головній і в Журналі видно лише його записи.';

  @override
  String get settingsBooksSwitcherActive => 'Відкрито зараз';

  @override
  String get settingsBooksSwitcherSwitch => 'Перемкнути';

  @override
  String get settingsBooksSwitcherCreate => 'Нові книги';

  @override
  String get settingsBooksSwitcherCreateTitle => 'Назвіть ці книги';

  @override
  String get settingsBooksSwitcherNameLabel => 'Назва';

  @override
  String get settingsBooksSwitcherRemoveTitle => 'Видалити ці книги?';

  @override
  String settingsBooksSwitcherRemoveBody(String name) {
    return 'Це видалить «$name» із цього пристрою, включно з ключем підпису. Інші книги на цьому пристрої не змінюються.';
  }

  @override
  String get settingsBooksSwitcherRemoveConfirm => 'Видалити';

  @override
  String settingsBooksSwitcherFallbackName(int number) {
    return 'Книги $number';
  }

  @override
  String get settingsLinkedDevices => 'Пов\'язані пристрої';

  @override
  String get settingsLinkedDevicesCatchUp =>
      'Ваші пристрої наздоганяють одне одного, коли на обох відкрито Smara в одній мережі Wi-Fi.';

  @override
  String get settingsLinkedDevicesPermissionSentence =>
      'Щоб ділитися книгами, Smara має знайти ваші інші пристрої в цій мережі Wi-Fi. Нічого не йде в інтернет.';

  @override
  String get settingsLinkedDevicesAddDevice => 'Додати пристрій';

  @override
  String get settingsLinkedDevicesContinue => 'Продовжити';

  @override
  String get settingsLinkedDevicesRoleOwner => 'Власник';

  @override
  String get settingsLinkedDevicesRoleMember => 'Учасник';

  @override
  String get settingsLinkedDevicesCanAdd => 'Може додавати пристрої';

  @override
  String get settingsLinkedDevicesErasePending => 'Очікує стирання';

  @override
  String settingsLinkedDevicesErasedOn(String date) {
    return 'Стерто $date';
  }

  @override
  String get settingsLinkedDevicesSuggestSecondOwner =>
      'У цих книг лише один Власник. Розгляньте можливість зробити Власником і інший пов\'язаний пристрій.';

  @override
  String get settingsLinkedDevicesJoinSameWifi =>
      'Обидва пристрої мають бути в одній мережі Wi-Fi. Smara не підключається через інтернет.';

  @override
  String get settingsLinkedDevicesApproveJoin => 'Схвалити';

  @override
  String get settingsLinkedDevicesRefuseJoin => 'Відхилити';

  @override
  String settingsLinkedDevicesPendingJoin(String name) {
    return '$name хоче приєднатися до цих книг';
  }

  @override
  String get settingsLinkedDevicesEmpty => 'Поки пов\'язано лише цей пристрій.';

  @override
  String get settingsLinkedDevicesSyncNow => 'Синхронізувати зараз';

  @override
  String get settingsLinkedDevicesSyncNowBusy => 'Наздоганяємо…';

  @override
  String membershipNoticeDeviceAdded(String name) {
    return 'Додано пристрій: $name';
  }

  @override
  String membershipNoticeDeviceRemoved(String name) {
    return 'Видалено пристрій: $name';
  }

  @override
  String membershipNoticeErasePending(String name) {
    return 'Очікує стирання для $name';
  }

  @override
  String membershipNoticeErased(String name, String date) {
    return 'Стерто $name $date';
  }

  @override
  String membershipNoticeSoleOwnerClaimed(String name) {
    return '$name заявив(-ла) одноосібне володіння';
  }

  @override
  String membershipNoticeSoleOwnerCancelled(String name) {
    return 'Заявку на одноосібного Власника для $name скасовано';
  }

  @override
  String membershipNoticeSoleOwnerEffective(String name) {
    return '$name тепер Власник';
  }

  @override
  String membershipNoticeEntryNotAccepted(String name) {
    return 'Не прийнято: не вдалося перевірити (від $name)';
  }

  @override
  String membershipNoticeOwnerVerificationAlert(String name) {
    return 'Запис від $name не вдалося перевірити, його не прийнято';
  }

  @override
  String get membershipNoticeCompetingFixCheck =>
      'Два Виправлення одного запису узгоджено — перевірте';

  @override
  String get whyWeDontEdit => 'Чому ми не редагуємо старі записи';

  @override
  String get whyWeDontEditBody =>
      'Коли ви виправляєте помилку, ми зберігаємо старий рядок і додаємо виправлення поруч із ним, замість того щоб змінювати те, що ви вже ввели. Так ваша історія завжди показує, що саме сталося і коли ви це виправили — нічого не змінюється непомітно у вас за спиною.';

  @override
  String get lockTitle => 'Розблокувати';

  @override
  String get lockScreenTitle => 'Заблоковано';

  @override
  String get enterPinToContinue => 'Введіть свій PIN-код, щоб продовжити';

  @override
  String get pinLabel => 'PIN';

  @override
  String get setPinTitle => 'Встановити PIN-код';

  @override
  String get currentPin => 'Поточний PIN-код';

  @override
  String get newPin => 'Новий PIN-код';

  @override
  String get confirmPin => 'Підтвердити PIN-код';

  @override
  String get confirmNewPin => 'Підтвердити новий PIN-код';

  @override
  String get firstWeekTitle => 'Налаштуйте свої рахунки';

  @override
  String get addCashAccount => 'Додати готівковий рахунок';

  @override
  String get addCreditCard => 'Додати кредитну картку';

  @override
  String get cashAccountName => 'Назва готівкового рахунку';

  @override
  String get cardName => 'Назва картки';

  @override
  String get paidFromBank => 'Оплачено з банку';

  @override
  String get paidFromCard => 'Оплачено з картки';

  @override
  String get choosePassphraseTitle =>
      'Виберіть парольну фразу для захисту цієї резервної копії. Якщо ви її забудете, відновлення неможливе.';

  @override
  String get replaceBooksTitle => 'Замінити ваші локальні книги?';

  @override
  String get replaceBooksBody =>
      'Це замінить усе, що зараз є в цьому застосунку, резервною копією. Після цього закрийте і знову відкрийте застосунок.';

  @override
  String get chooseBackupFileFirst => 'Спочатку виберіть файл резервної копії.';

  @override
  String get backupRestored => 'Резервну копію відновлено';

  @override
  String get backupRestoredBody =>
      'Ваші книги відновлено. Закрийте і знову відкрийте застосунок, щоб продовжити.';

  @override
  String get fixThisEntry => 'Виправити цей запис';

  @override
  String get fixBlurb =>
      'Старий рядок залишається точно таким, яким він був. Підтвердження додає сторнувальний рядок і виправлений.';

  @override
  String get importStatementTitle => 'Імпорт виписки';

  @override
  String get importOfx => 'Імпортувати OFX';

  @override
  String get importOfxQfxFile => 'Імпортувати файл OFX / QFX';

  @override
  String get importCsvFile => 'Імпортувати файл CSV';

  @override
  String get whatKindOfStatement => 'Який тип файлу виписки у вас є?';

  @override
  String get chooseAccountForFile =>
      'Виберіть, якому рахунку належить цей файл.';

  @override
  String get importIntoAccount => 'Імпортувати на рахунок';

  @override
  String get useSavedProfile => 'Використати збережений профіль';

  @override
  String get saveMappingProfile =>
      'Зберегти це зіставлення як профіль (необов\'язково)';

  @override
  String get renameProfile => 'Перейменувати профіль';

  @override
  String get deleteProfileTitle => 'Видалити профіль?';

  @override
  String get fileHasHeader => 'Файл містить рядок заголовка';

  @override
  String get dateColumn => 'Стовпець дати';

  @override
  String get dateFormatHint => 'Формат дати (напр. дд/ММ/рррр)';

  @override
  String get amountColumn => 'Стовпець суми';

  @override
  String get amountConvention => 'Правило знаку суми';

  @override
  String get signedAmountColumn => 'Стовпець суми зі знаком';

  @override
  String get separateDebitCredit => 'Окремі стовпці дебету / кредиту';

  @override
  String get debitColumn => 'Стовпець дебету';

  @override
  String get creditColumn => 'Стовпець кредиту';

  @override
  String get decimalSeparator => 'Десятковий роздільник (. або ,)';

  @override
  String get descriptionColumns => 'Стовпець(-ці) опису';

  @override
  String get referenceIdColumn => 'Стовпець номера посилання (необов\'язково)';

  @override
  String get skippedRows => 'Пропущені рядки';

  @override
  String parsedTransactionCount(String count) {
    return 'Розпізнано $count операцій';
  }

  @override
  String skippedOrExcludedCount(String count) {
    return 'Пропущено або виключено $count';
  }

  @override
  String postedFailedCount(String posted, String failed) {
    return 'Проведено $posted, помилок $failed';
  }

  @override
  String get categoryForAll => 'Категорія для всіх';

  @override
  String get saveAsRule => 'Зберегти як правило?';

  @override
  String get saveAsRuleBlurb =>
      'Майбутні імпорти, опис яких містить це ключове слово, використовуватимуть цю категорію.';

  @override
  String get keyword => 'Ключове слово';

  @override
  String get noSavedRules =>
      'Ще немає збережених правил. Призначте категорію групі рядків, щоб зберегти правило.';

  @override
  String get deleteRuleTitle => 'Видалити правило?';

  @override
  String get editRule => 'Редагувати правило';

  @override
  String rowsGrouped(String count) {
    return '$count рядків';
  }

  @override
  String selectStatementFile(String extensions) {
    return 'Виберіть файл виписки $extensions для імпорту';
  }

  @override
  String get payeesTitle => 'Отримувачі';

  @override
  String get addPayee => 'Додати отримувача';

  @override
  String get renamePayee => 'Перейменувати отримувача';

  @override
  String get deletePayeeTitle => 'Видалити отримувача?';

  @override
  String get noPayeesYet => 'Ще немає отримувачів';

  @override
  String get recurringTitle => 'Регулярні шаблони';

  @override
  String get noRecurringYet => 'Ще немає регулярних шаблонів';

  @override
  String get deleteTemplateTitle => 'Видалити регулярний шаблон?';

  @override
  String get dayOfMonth => 'День місяця (1-31)';

  @override
  String get dayOfMonthNote =>
      'Місяць з меншою кількістю днів використовує свій останній день.';

  @override
  String dayOfMonthLine(String day) {
    return '$day-й день місяця - ';
  }

  @override
  String get name => 'Назва';

  @override
  String get none => 'Немає';

  @override
  String get currency => 'Валюта';

  @override
  String get errorGeneric => 'Щось пішло не так. Спробуйте ще раз.';

  @override
  String get errorInvalidLedgerBackup =>
      'Цей файл не є дійсною резервною копією Smara.';

  @override
  String get errorInvalidLedgerBackupNoIdentity =>
      'Ця резервна копія не має ідентифікатора підпису - вона не є дійсною резервною копією Smara.';

  @override
  String get errorInvalidLedgerBackupUnverified =>
      'Цю резервну копію не вдалося перевірити як цілісні книги, тому її не було відновлено.';

  @override
  String errorInvalidLedgerBackupUnreadable(String detail) {
    return 'Не вдалося відкрити цей файл як резервну копію Smara: $detail';
  }

  @override
  String get errorAccountNotFinancial => 'Це не фінансовий рахунок.';

  @override
  String get errorAccountArchived => 'Цей рахунок приховано.';

  @override
  String get errorAccountNotArchived => 'Цей рахунок не приховано.';

  @override
  String get errorAccountNoPositiveBalanceToCloseOut =>
      'Немає залишку балансу для переказу.';

  @override
  String get errorAccountHasNoGroup => 'Цьому рахунку не призначено групу.';

  @override
  String get errorGroupHasNoCurrency =>
      'Для цієї групи ще не встановлено валюту.';

  @override
  String get errorGroupNotFound => 'Цю групу рахунків не знайдено.';

  @override
  String get errorInvestmentAccountsMustBeAssets =>
      'Лише рахунки активів можуть бути позначені як інвестиційні рахунки.';

  @override
  String get errorCreditCardsMustBeLiabilities =>
      'Лише рахунки зобов\'язань можуть бути позначені як кредитні картки.';

  @override
  String get errorOpeningBalanceMustBePositive =>
      'Початковий баланс повинен бути додатним, якщо вказано.';

  @override
  String get errorAccountTypeDoesNotMatchGroup =>
      'Цей тип рахунку не відповідає групі.';

  @override
  String get errorLastActiveAccount =>
      'Неможливо приховати останній активний фінансовий рахунок.';

  @override
  String get errorCurrencyRequiredToCreateGroup =>
      'Для створення групи потрібна валюта.';

  @override
  String get errorSystemGroupCannotBeArchived =>
      'Вбудовані групи рахунків не можна приховати.';

  @override
  String get errorGroupAlreadyArchived => 'Ця група вже прихована.';

  @override
  String get errorCannotArchiveGroupWithAccounts =>
      'Неможливо приховати групу, яка все ще має активні рахунки.';

  @override
  String get errorSystemGroupNeverArchived =>
      'Вбудовані групи рахунків ніколи не приховуються.';

  @override
  String get errorAccountGroupsCannotBeDeleted =>
      'Групи рахунків не можна видаляти.';

  @override
  String get errorCannotReassignDifferentCurrency =>
      'Неможливо перемістити цей рахунок до групи з іншою валютою.';

  @override
  String get errorCannotChangeGroupCurrencyWithAccounts =>
      'Неможливо змінити валюту, поки в групі є активні рахунки.';

  @override
  String get errorAmountMustBePositive => 'Сума має бути додатною.';

  @override
  String get errorAccountCurrencyAmountMustBePositive =>
      'Сума у валюті рахунку має бути додатною.';

  @override
  String get errorAccountCurrencyAmountNotForSameCurrency =>
      'Сума у валюті рахунку призначена лише для запису в іноземній валюті.';

  @override
  String get errorSplitNeedsTwoLines =>
      'Розподіл потребує щонайменше двох рядків категорій.';

  @override
  String get errorSplitLineMustBePositive =>
      'Кожен рядок розподілу має бути додатною сумою.';

  @override
  String get errorSplitLinesMustSumToTotal =>
      'Сума рядків розподілу повинна дорівнювати загальній сумі операції.';

  @override
  String get errorTransferAmountMustBePositive =>
      'Сума переказу має бути додатною.';

  @override
  String get errorTransferAccountsMustDiffer =>
      'Рахунок джерела та рахунок призначення мають відрізнятися.';

  @override
  String get errorCloseoutRequiresDestinationAmount =>
      'Закриття з обміном валют потребує відомої суми отримання.';

  @override
  String get errorDestinationAmountNotForSameCurrency =>
      'Сума отримання призначена лише для переказу між валютами.';

  @override
  String get errorDestinationAmountMustBePositive =>
      'Сума отримання має бути додатною.';

  @override
  String get errorInvestmentCashExceeded =>
      'Неможливо перевести більше готівки, ніж є на цьому інвестиційному рахунку.';

  @override
  String get errorCannotReverseUnsettledProvisional =>
      'Закрийте цей очікуваний переказ замість сторнування.';

  @override
  String get errorAlreadyReversed =>
      'Цей запис уже виправлено. Оригінальний рядок залишається без змін.';

  @override
  String get errorNotActiveExpenseCategory =>
      'Виберіть активну категорію витрат.';

  @override
  String get errorNotActiveIncomeCategory =>
      'Виберіть активну категорію доходу.';

  @override
  String get errorSettledAmountMustNotBeNegative =>
      'Сума, що надійшла, не може бути від\'ємною.';

  @override
  String get errorPendingTransferNotFound =>
      'Цей очікуваний переказ не знайдено.';

  @override
  String get errorPendingTransferAlreadySettled =>
      'Цей очікуваний переказ уже закрито.';

  @override
  String get errorSettledToMustBeSourceOrDestination =>
      'Виберіть початковий рахунок джерела або призначення.';

  @override
  String get errorFeeCategoryOnlyWhenReturningToSource =>
      'Категорія комісії використовується лише тоді, коли кошти повертаються на рахунок джерела.';

  @override
  String get errorSettledAmountMustBePositiveForDelivery =>
      'Введіть додатну суму того, що надійшло.';

  @override
  String get errorSettledAmountExceedsProvisional =>
      'Ця сума більша за надіслану.';

  @override
  String get errorInstrumentNotFound => 'Цей інструмент не знайдено.';

  @override
  String get errorIncomeRequiredForNonCash =>
      'Для негрошового надходження потрібна активна категорія доходу.';

  @override
  String get errorInsufficientCash =>
      'Недостатньо готівки на цьому інвестиційному рахунку для цієї купівлі.';

  @override
  String get errorSellQuantityAndPriceMustBePositive =>
      'Кількість продажу та ціна за одиницю мають бути додатними.';

  @override
  String errorLockedUntil(String date) {
    return 'Неможливо продати: деякі одиниці заблоковано до $date.';
  }

  @override
  String get errorInsufficientQuantity =>
      'Неможливо продати більше, ніж наразі є незаблокованим.';

  @override
  String get errorIncomeRequiredForGain =>
      'Для реалізованого прибутку потрібна активна категорія доходу.';

  @override
  String get errorExpenseRequiredForLoss =>
      'Для реалізованого збитку потрібна активна категорія витрат.';

  @override
  String errorBrokerageFailedAfterBuy(String detail) {
    return 'Купівлю проведено, але брокерську комісію не вдалося записати: $detail';
  }

  @override
  String errorBrokerageFailedAfterSell(String detail) {
    return 'Продаж проведено, але брокерську комісію не вдалося записати: $detail';
  }

  @override
  String get errorDividendMustBePositive => 'Сума дивіденду має бути додатною.';

  @override
  String get errorNotInvestmentAccount => 'Це не інвестиційний рахунок.';

  @override
  String get errorNoInventoryCompanion =>
      'У цього інвестиційного рахунку відсутній супутній рахунок запасів.';

  @override
  String errorInvestmentReversalBlocked(String sells) {
    return 'Неможливо сторнувати цю купівлю: наступні продажі залежать від цих одиниць. Спочатку сторнуйте залежні продажі: $sells.';
  }

  @override
  String get errorMonthlyLimitMustBePositive =>
      'Місячний ліміт має бути додатним.';

  @override
  String get errorTemplateAmountMustBePositive =>
      'Сума шаблону має бути додатною.';

  @override
  String get errorOfxUnrecognized => 'Не вдалося розпізнати цей файл як OFX.';

  @override
  String get errorCsvEmpty => 'Вибраний файл порожній.';

  @override
  String get errorCsvUnreadable => 'Не вдалося прочитати цей файл як CSV.';

  @override
  String get errorCsvNoRows => 'У вибраному файлі немає рядків.';

  @override
  String get skipMissingDate => 'Дата відсутня.';

  @override
  String skipUnparseableDate(String raw, String pattern) {
    return 'Не вдалося розпізнати дату \"$raw\" за шаблоном \"$pattern\".';
  }

  @override
  String get skipOfxMissingOrInvalidDate =>
      'Дата операції відсутня або недійсна.';

  @override
  String skipOfxUnparseableDate(String raw) {
    return 'Не вдалося розпізнати дату операції \"$raw\".';
  }

  @override
  String get skipMissingAmount => 'Сума відсутня.';

  @override
  String skipUnparseableAmount(String raw) {
    return 'Не вдалося розпізнати суму \"$raw\".';
  }

  @override
  String get skipZeroAmount => 'Сума дорівнює нулю.';

  @override
  String get skipUnparseableDebitCreditAmount =>
      'Не вдалося розпізнати суму дебету або кредиту.';

  @override
  String get skipBothDebitAndCreditNonZero =>
      'У стовпцях дебету та кредиту вказано суму в обох.';

  @override
  String get skipBothDebitAndCreditZero =>
      'Стовпці дебету та кредиту обидва дорівнюють нулю.';

  @override
  String errorBackupCreateFailed(String detail) {
    return 'Не вдалося створити резервну копію: $detail';
  }

  @override
  String get errorBackupRestoreFailed =>
      'Не вдалося відновити цю резервну копію - неправильна парольна фраза або це не файл резервної копії Smara.';

  @override
  String get validationAmountAccountCategoryRequired =>
      'Потрібні сума, рахунок і категорія.';

  @override
  String get validationAmountAccountRequired => 'Потрібні сума та рахунок.';

  @override
  String get validationSplitLineIncomplete =>
      'Кожен рядок розподілу потребує категорії та суми.';

  @override
  String get validationSplitSumMismatch =>
      'Сума рядків розподілу повинна дорівнювати загальній сумі операції.';

  @override
  String get validationFromToAmountRequired =>
      'Потрібні рахунок джерела, рахунок призначення та сума.';

  @override
  String get validationAmountArrivedRequired => 'Потрібна сума, що надійшла.';

  @override
  String get validationChooseReceivingAccount =>
      'Виберіть, який рахунок отримав кошти.';

  @override
  String get validationAccountCategoryRequired =>
      'Потрібні рахунок і категорія.';

  @override
  String get validationFixFailed => 'Не вдалося зберегти це виправлення.';

  @override
  String get validationNameRequired => 'Назвіть свій основний рахунок.';

  @override
  String get validationStillLoading =>
      'Ще завантажується - спробуйте ще раз за хвилину.';

  @override
  String get validationSaveAccountNameFailed =>
      'Не вдалося зберегти назву рахунку.';

  @override
  String get validationWrongPin => 'Неправильний PIN. Спробуйте ще раз.';

  @override
  String get validationCategoryMustBeIncomeOrExpense =>
      'Категорія має бути Дохід або Витрата.';

  @override
  String get validationOnlyExpenseHasMonthlyLimit =>
      'Лише категорія Витрата може мати місячний ліміт.';

  @override
  String get validationInvalidTemplate => 'Недійсний шаблон.';

  @override
  String validationGenerateKeyFailed(String detail) {
    return 'Не вдалося згенерувати ключ підпису на цьому пристрої: $detail';
  }

  @override
  String validationSaveCurrencyFailed(String detail) {
    return 'Не вдалося зберегти цю валюту: $detail';
  }

  @override
  String get validationChooseBackupFile =>
      'Спочатку виберіть файл резервної копії.';

  @override
  String get validationPassphraseRequired => 'Введіть парольну фразу.';

  @override
  String get validationPinsDoNotMatch => 'Два PIN-коди не збігаються.';

  @override
  String get validationFeePositiveWithCategory =>
      'Комісія за переказ має бути додатною сумою з вибраною категорією витрат.';

  @override
  String get validationFeeMustBeLessThanAmount =>
      'Комісія має бути меншою за суму для переказу з утриманням комісії.';

  @override
  String validationTransferSavedFeeFailed(String detail) {
    return 'Переказ збережено, але комісію не вдалося записати: $detail';
  }

  @override
  String get validationEnterValidAmount => 'Введіть дійсну суму.';

  @override
  String get errorBuyQuantityAndPriceMustBePositive =>
      'Кількість купівлі та ціна за одиницю мають бути додатними.';

  @override
  String get errorInstrumentArchived =>
      'Неможливо купити прихований інструмент.';

  @override
  String get errorNonCashCannotIncludeBrokerage =>
      'Негрошові надходження не можуть містити брокерську комісію.';

  @override
  String get errorBrokerageRequiresExpenseCategory =>
      'Коли брокерська комісія додатна, потрібна активна категорія витрат.';

  @override
  String get errorSellProceedsMustCoverBrokerage =>
      'Виручка від продажу має бути не меншою за суму брокерської комісії.';

  @override
  String homeSpentOfLimitThisMonth(String spent, String limit) {
    return '$spent з $limit цього місяця';
  }

  @override
  String get unlockBiometricReason => 'Розблокувати Smara Account';

  @override
  String get searchLabel => 'Пошук';

  @override
  String get openingBalance => 'Початковий баланс';

  @override
  String transferToName(String name) {
    return 'Переказ: $name';
  }

  @override
  String get feeForTransfer => 'Комісія за переказ';

  @override
  String feeForTransferTo(String name) {
    return 'Комісія за переказ на $name';
  }

  @override
  String couldNotOpenFilePicker(String detail) {
    return 'Не вдалося відкрити засіб вибору файлів: $detail';
  }

  @override
  String pleaseSelectFile(String extensions) {
    return 'Виберіть файл .$extensions';
  }

  @override
  String get currencyCodeIso => 'Код валюти (ISO 4217, напр. USD)';

  @override
  String splitCounterpartMore(String name, String count) {
    return '$name і ще $count';
  }

  @override
  String get dateLabel => 'Дата';

  @override
  String get noneSelected => 'Немає';

  @override
  String reviewEntriesBeforeContinuing(String count) {
    return 'Перегляньте записи нижче (усього $count) перед продовженням.';
  }

  @override
  String youReceived(String amount) {
    return 'Ви отримали $amount';
  }

  @override
  String get leaveBlankIfRateUnknown =>
      'Залиште порожнім, якщо курс обміну ще не відомий.';

  @override
  String get recordTradeBlurb =>
      'Запишіть угоду, яка вже відбулася. Цей застосунок не подає заявки.';

  @override
  String get feeOnTopBlurb =>
      'Увімкнено: сума вище — це загальна сума, знята з цього рахунку; комісія утримується з неї.';

  @override
  String get feeBankBlurb =>
      'Попередня комісія, що стягується вашим банком або посередником.';

  @override
  String get validationPinMinLength =>
      'PIN-код має містити щонайменше 4 цифри.';

  @override
  String get restoreBackupBlurb =>
      'Це замінить усе, що зараз є в цьому застосунку, резервною копією — без об\'єднання. Виберіть файл резервної копії та введіть парольну фразу, якою ви його захистили.';

  @override
  String get actionReplace => 'Замінити';

  @override
  String hideAccountBody(String name) {
    return '$name більше не буде доступний для нових операцій.';
  }

  @override
  String hideGroupBody(String name) {
    return '$name більше не пропонуватиметься під час створення або перепризначення рахунків.';
  }

  @override
  String hideCategoryBody(String name) {
    return '$name більше не пропонуватиметься під час запису нових операцій.';
  }

  @override
  String get hideInstrumentBody =>
      'Приховані інструменти залишаються в минулих купівлях і продажах. Ви все ще можете записати для них дивіденд.';

  @override
  String nameHidden(String name) {
    return '$name (приховано)';
  }

  @override
  String get noCurrencySet => 'Валюту не встановлено';

  @override
  String deletePayeeBody(String name) {
    return '$name та його запам\'ятовані значення за замовчуванням буде видалено. Минулі операції не постраждають.';
  }

  @override
  String deleteTemplateBody(String name) {
    return '$name більше не пропонуватиметься як такий, що настав. Минулі операції, які він уже записав, не постраждають.';
  }

  @override
  String deleteProfileBody(String name) {
    return 'Збережене зіставлення стовпців \"$name\" буде видалено. Виписки, вже імпортовані з ним, не постраждають.';
  }

  @override
  String deleteRuleBody(String keyword) {
    return 'Імпорти більше не будуть автоматично категоризуватися за \"$keyword\". Операції, вже категоризовані цим правилом, не постраждають.';
  }

  @override
  String get firstWeekBlurb =>
      'За бажанням додайте кредитну картку або готівковий рахунок зараз - ви завжди зможете додати більше рахунків пізніше в Налаштуваннях.';

  @override
  String get deliveredToDestination => 'Доставлено на призначення';

  @override
  String deliveredToName(String name) {
    return 'Доставлено на $name';
  }

  @override
  String youReceivedLessThanExpected(String amount, String currency) {
    return 'Ви отримали на $amount $currency менше, ніж очікувалося - виберіть категорію, щоб покрити різницю.';
  }

  @override
  String get dateRangeLabel => 'Діапазон дат';

  @override
  String get addTemplate => 'Додати шаблон';

  @override
  String get editTemplate => 'Редагувати шаблон';

  @override
  String get validationFillTemplateFields =>
      'Заповніть усі поля дійсною сумою та днем.';

  @override
  String get saveCsvExport => 'Зберегти експорт CSV';

  @override
  String get referenceRate => 'Довідковий курс';

  @override
  String get yourRate => 'Ваш курс';

  @override
  String leaveBlankIfThisWasAccountCurrency(String currency) {
    return 'Залиште порожнім, якщо це було у $currency — власній валюті рахунку.';
  }

  @override
  String get lockUntilOptional => 'Заблокувати до (необов\'язково)';

  @override
  String lockedUntilDate(String date) {
    return 'Заблоковано до $date';
  }

  @override
  String get copiedResearchPrompt =>
      'Скопійовано запит для аналізу — немає доступного URL браузера, або ви офлайн.';

  @override
  String get openedFavouriteResearchTool =>
      'Відкрито ваш улюблений інструмент для аналізу.';

  @override
  String get looksLikeGain => 'Це схоже на прибуток';

  @override
  String get looksLikeLoss => 'Це схоже на збиток';

  @override
  String get looksLikeBreakEven => 'Це схоже на беззбитковість';

  @override
  String sellableQuantity(String name, String qty) {
    return '$name (доступно для продажу $qty)';
  }

  @override
  String columnN(String index) {
    return 'Стовпець $index';
  }

  @override
  String get importingLabel => 'Імпортування...';

  @override
  String get confirmImport => 'Підтвердити імпорт';

  @override
  String get manageSavedCategoryRules =>
      'Керувати збереженими правилами категорій';

  @override
  String statementCurrencyMismatch(String currency) {
    return 'Валюта цього файлу ($currency) не відповідає валюті вибраного рахунку.';
  }

  @override
  String get categoryRulesTitle => 'Правила категорій';

  @override
  String get possibleDuplicate => 'можливий дублікат';

  @override
  String get unknownCategory => 'Невідома категорія';

  @override
  String get researchPromptIntro =>
      'Дослідіть цей публічно котирований інструмент для приватного інвестора. Визначте емітента, підсумуйте останні новини з датами, якщо вони відомі, і окресліть ризики зниження та фактори зростання. Відокремлюйте факти від припущень. Не давайте рекомендацію купувати, продавати чи утримувати. Це не є фінансовою консультацією.';

  @override
  String researchPromptNameLine(String name) {
    return 'Назва: $name';
  }

  @override
  String researchPromptTickerLine(String ticker) {
    return 'Тікер: $ticker';
  }

  @override
  String get researchPromptTickerNoneProvided => 'Тікер: (не вказано)';

  @override
  String researchPromptIsinLine(String isin) {
    return 'ISIN: $isin';
  }

  @override
  String get researchPromptIsinNoneProvided => 'ISIN: (не вказано)';

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
  String get booksCopyPassphrase => 'Парольна фраза';

  @override
  String replaceBooksWarning(String counts) {
    return 'Це замінить усі записи й налаштування книг на цьому телефоні ($counts). Нічого не об’єднується. Мова й налаштування розблокування залишаються на цьому телефоні.';
  }

  @override
  String get saveCopyFirstAction => 'Спершу зберегти копію';

  @override
  String replaceCountEntries(int count) {
    return 'Записів: $count';
  }

  @override
  String replaceCountAccounts(int count) {
    return 'Рахунків: $count';
  }

  @override
  String replaceCountCategories(int count) {
    return 'Категорій: $count';
  }

  @override
  String replaceCountGroups(int count) {
    return 'Груп рахунків: $count';
  }

  @override
  String replaceCountPayees(int count) {
    return 'Отримувачів: $count';
  }

  @override
  String replaceCountCategoryRules(int count) {
    return 'Правил категорій: $count';
  }

  @override
  String replaceCountCsvProfiles(int count) {
    return 'Профілів імпорту: $count';
  }

  @override
  String replaceCountRecurringTemplates(int count) {
    return 'Повторюваних шаблонів: $count';
  }

  @override
  String replaceCountInstruments(int count) {
    return 'Інструментів: $count';
  }

  @override
  String get claimsTitle => 'Заявки';

  @override
  String get claimsReviewTitle => 'Перегляд заявок';

  @override
  String get claimsStatusDraft => 'Чернетка';

  @override
  String get claimsStatusSubmitted => 'Надіслано';

  @override
  String get claimsStatusPartlyApproved => 'Частково схвалено';

  @override
  String get claimsStatusApproved => 'Схвалено';

  @override
  String get claimsStatusPaid => 'Оплачено';

  @override
  String get claimsStatusRejected => 'Відхилено';

  @override
  String get claimsApprove => 'Схвалити';

  @override
  String get claimsApproveDifferent => 'Схвалити іншу суму';

  @override
  String get claimsReject => 'Відхилити';

  @override
  String get claimsReasonRequired => 'Потрібна причина';

  @override
  String get claimsAdvances => 'Аванси';

  @override
  String get claimsAddPerson => 'Додати особу';

  @override
  String get claimsRoleApprover => 'Затверджувач';

  @override
  String get claimsRoleClaimant => 'Заявник';

  @override
  String claimsBalanceCompanyOwesYou(String company) {
    return '$company винна вам';
  }

  @override
  String claimsBalanceYouOweCompany(String company) {
    return 'Ви винні компанії $company';
  }

  @override
  String claimsBalanceSettled(String company) {
    return 'Розрахунки з $company закрито';
  }

  @override
  String get claimsReceiptRequired => 'Для цієї позиції заявки потрібен чек';

  @override
  String get claimsReceiptPdfTooLarge =>
      'Цей PDF більший за 5 MB. Оберіть менший файл.';

  @override
  String claimsSpendingHint(String amount, String unit) {
    return 'Підказка: щонайбільше $amount за $unit';
  }

  @override
  String get claimsNoClaimsYet => 'Заявок ще немає.';

  @override
  String get claimsNoClaimsToReview => 'Немає заявок для перегляду.';

  @override
  String get claimsAdvanceDefault => 'Аванс';

  @override
  String claimsItemCount(int count) {
    return 'Позицій: $count';
  }

  @override
  String get claimsRejectReasonTitle => 'Причина відхилення';

  @override
  String get claimsApproveDifferentReasonTitle =>
      'Причина схвалення іншої суми';

  @override
  String get claimsPersonNameLabel => 'Ім\'я особи';

  @override
  String get claimsRemovePerson => 'Видалити';

  @override
  String claimsRemovePersonTitle(String name) {
    return 'Видалити $name?';
  }

  @override
  String claimsRemovePersonWarning(String name, int openClaims) {
    return 'У $name є $openClaims відкритих Заявок і ненульовий залишок заборгованості. Історія та чеки залишаються в цих книгах.';
  }

  @override
  String claimsRemovePersonWarningOpenOnly(String name, int openClaims) {
    return 'У $name є $openClaims відкритих Заявок. Історія та чеки залишаються в цих книгах.';
  }

  @override
  String claimsRemovePersonWarningBalanceOnly(String name) {
    return 'У $name ненульовий залишок заборгованості. Історія та чеки залишаються в цих книгах.';
  }

  @override
  String claimsRemovePersonWarningClean(String name) {
    return 'Видалити $name? Історія та чеки залишаються в цих книгах.';
  }

  @override
  String get claimsRemovePersonConfirm => 'Видалити';

  @override
  String get claimsEditorTitle => 'Редагувати заявку';

  @override
  String get claimsSubmit => 'Надіслати';

  @override
  String get claimsAddItem => 'Додати позицію';

  @override
  String get claimsEditItem => 'Редагувати позицію';

  @override
  String get claimsNoItemsYet =>
      'Додайте щонайменше одну позицію перед надсиланням.';

  @override
  String get claimsNoAllowlistedCategories =>
      'Для заявок ще не дозволено жодної категорії витрат.';

  @override
  String get claimsCategoryLabel => 'Категорія';

  @override
  String get claimsExpenseDateLabel => 'Дата витрати';

  @override
  String get claimsPaidAmountLabel => 'Сплачена сума';

  @override
  String get claimsPaidCurrencyLabel => 'Валюта платежу';

  @override
  String get claimsRateOptionalLabel => 'Курс (необов\'язково)';

  @override
  String claimsCompanyAmountLabel(String currency) {
    return 'Сума в $currency';
  }

  @override
  String get claimsDescriptionLabel => 'Опис';

  @override
  String get claimsAttachCamera => 'Зробити фото';

  @override
  String get claimsAttachGallery => 'Вибрати фото';

  @override
  String get claimsAttachPdf => 'Вибрати PDF';

  @override
  String claimsReceiptAttached(String fileName) {
    return 'Чек: $fileName';
  }

  @override
  String get claimsReceiptRequiredHint => 'Для цієї суми потрібен чек.';

  @override
  String get claimsReceiptPermissionSentence =>
      'Щоб додати фото чека, Smara потрібен доступ до камери або бібліотеки фото. Фото залишаються в цих книгах на ваших пристроях.';

  @override
  String claimsReviewClaimHeading(String status) {
    return 'Заявка · $status';
  }
}
