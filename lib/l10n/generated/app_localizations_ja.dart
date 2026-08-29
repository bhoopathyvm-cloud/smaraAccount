// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Smara家計簿';

  @override
  String get navHome => 'ホーム';

  @override
  String get navRegister => '明細';

  @override
  String get navSummary => '概要';

  @override
  String get navAccounts => '口座';

  @override
  String get navCategories => 'カテゴリ';

  @override
  String get actionCancel => 'キャンセル';

  @override
  String get actionSave => '保存';

  @override
  String get actionDelete => '削除';

  @override
  String get actionDone => '完了';

  @override
  String get actionContinue => '続ける';

  @override
  String get actionDismiss => '閉じる';

  @override
  String get actionRetry => '再試行';

  @override
  String get actionSkip => 'スキップ';

  @override
  String get actionConfirm => '確認';

  @override
  String get actionAdd => '追加';

  @override
  String get actionEdit => '編集';

  @override
  String get actionRename => '名前を変更';

  @override
  String get actionHide => '非表示';

  @override
  String get actionCreate => '作成';

  @override
  String get actionCloseApp => 'アプリを閉じる';

  @override
  String get actionUnlock => 'ロック解除';

  @override
  String get actionSettle => '確定';

  @override
  String get actionFinish => '完了';

  @override
  String get actionPreview => 'プレビュー';

  @override
  String get actionImport => 'インポート';

  @override
  String get actionExportCsv => 'CSVを書き出す';

  @override
  String get actionChooseFile => 'ファイルを選択';

  @override
  String get actionRestore => '復元';

  @override
  String get actionFix => '修正';

  @override
  String get actionBuy => '買う';

  @override
  String get actionSell => '売る';

  @override
  String get actionDividend => '配当';

  @override
  String get actionRecordBuy => '買いを記録';

  @override
  String get actionRecordSell => '売りを記録';

  @override
  String get actionRecordDividend => '配当を記録';

  @override
  String get actionPayCard => 'カードの支払い';

  @override
  String get actionTransfer => '振替';

  @override
  String get actionRecordTransaction => '取引を記録';

  @override
  String get actionImportStatement => '明細書をインポート';

  @override
  String get actionClearDates => '日付をクリア';

  @override
  String get actionClearSearch => '検索とフィルターをクリア';

  @override
  String get actionUseBiometrics => '生体認証を使う';

  @override
  String get actionSetPin => 'PINを設定';

  @override
  String get actionChangePin => 'PINを変更';

  @override
  String get actionSaveBackup => 'バックアップを保存';

  @override
  String get actionRestoreBackup => 'バックアップを復元';

  @override
  String get actionSaveRule => 'ルールを保存';

  @override
  String get actionConfirmFix => '修正を確定';

  @override
  String get captureSpent => '支出';

  @override
  String get captureReceived => '収入';

  @override
  String get captureMovedMoney => '資金移動';

  @override
  String get captureImportStatement => '明細書をインポート';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsLanguage => '言語';

  @override
  String get settingsLanguageSystem => '端末の言語';

  @override
  String get settingsFetchFxRates => '参考為替レートを取得';

  @override
  String get settingsFetchFxRatesSubtitle =>
      '異なる通貨間の振替で、目安となる市場レートを送金先金額の横に表示します。比較目的のみで、金額の入力には一切使用しません。';

  @override
  String get settingsRateProvider => 'レート提供元';

  @override
  String get settingsFetchMarketPrices => '投資の市場価格を取得';

  @override
  String get settingsFetchMarketPricesSubtitle =>
      'ティッカーまたはISINが設定されている銘柄の最終価格を調べ、ポートフォリオの評価額を見積もります。取引の記録には使用されず、保有数量が送信されることもありません。';

  @override
  String get settingsMarketPriceProvider => '市場価格の提供元';

  @override
  String get settingsFavouriteResearchTool => 'お気に入りの調査ツール';

  @override
  String get settingsFavouriteResearchToolSubtitle =>
      '保有資産の銘柄名をタップすると、このツールがブラウザで調査用のプロンプトとともに開きます — 連携機能ではなく、助言でもありません。';

  @override
  String get settingsBackup => 'バックアップ';

  @override
  String get settingsBackupBlurb =>
      '選んだ場所に帳簿の暗号化コピーを保存する、またはそこから復元します。これは署名鍵をバックアップするリカバリーフレーズやキーストアファイルとは別のもので、帳簿そのものをバックアップするわけではありません。';

  @override
  String get settingsLock => 'ロック';

  @override
  String get settingsLockBlurb => 'アプリを開くのにPIN、または利用可能な場合は生体認証を必須にします。';

  @override
  String get settingsRequireUnlock => 'アプリを開くのにロック解除を必須にする';

  @override
  String get settingsLockAfter => 'ロックまでの時間';

  @override
  String get settingsLockImmediately => 'すぐに';

  @override
  String get settingsLock1Minute => '1分';

  @override
  String get settingsLock5Minutes => '5分';

  @override
  String get settingsLock15Minutes => '15分';

  @override
  String get settingsAllowBiometrics => '生体認証も許可する';

  @override
  String get settingsHideSnapshot => 'アプリ切り替え画面で残高を隠す';

  @override
  String get settingsHideSnapshotSubtitle =>
      '他のアプリに切り替えたときにこの画面を隠し、アプリ切り替え画面で一目で見えないようにします。';

  @override
  String get settingsHideSnapshotUnavailable =>
      'このプラットフォームでは、アプリ切り替え画面で残高を隠す機能は利用できません。';

  @override
  String get settingsPayees => '支払先';

  @override
  String get settingsManagePayees => '支払先を管理';

  @override
  String get settingsPayeesBlurb =>
      '記憶された支払先の名前と、そのデフォルトのカテゴリ・口座です。取引の記録時にオートコンプリートで候補として表示されます。';

  @override
  String get settingsRecurring => '定期テンプレート';

  @override
  String get settingsManageRecurring => '定期テンプレートを管理';

  @override
  String get settingsRecurringBlurb =>
      '家賃や給料のように毎月繰り返される支払いや収入です。期日が来たテンプレートはホーム画面に表示され、ワンタップで記録できます - 自動的に記帳されることはありません。';

  @override
  String get settingsAbout => 'このアプリについて';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get providerFrankfurter => 'Frankfurter（ECBレート）';

  @override
  String get providerOpenErApi => 'ExchangeRate-API（open.er-api.com）';

  @override
  String get providerStooq => 'Stooq（日次相場）';

  @override
  String get providerYahooFinance => 'Yahoo Finance（チャートAPI）';

  @override
  String get researchChatGpt => 'ChatGPT';

  @override
  String get researchClaude => 'Claude';

  @override
  String get researchGemini => 'Gemini';

  @override
  String get researchMetaAi => 'Meta AI';

  @override
  String get systemGroupCashEquivalents => '現金及び現金同等物';

  @override
  String get systemGroupPensionRetirement => '年金・退職金';

  @override
  String get systemGroupCreditShortTerm => 'クレジット・短期債務';

  @override
  String get systemGroupLoansMortgages => 'ローン・住宅ローン';

  @override
  String get systemGroupInvestments => '投資';

  @override
  String get systemAccountCashBank => '現金・銀行口座';

  @override
  String get systemCategorySalary => '給与';

  @override
  String get systemCategoryOtherIncome => 'その他の収入';

  @override
  String get systemCategoryGroceries => '食料品';

  @override
  String get systemCategoryRentMortgage => '家賃・住宅ローン';

  @override
  String get systemCategoryUtilities => '光熱費';

  @override
  String get systemCategoryTransport => '交通費';

  @override
  String get systemCategoryFoodOut => '外食';

  @override
  String get systemCategoryPhone => '通信費';

  @override
  String get systemCategoryHealth => '医療費';

  @override
  String get systemCategoryOtherExpense => 'その他の支出';

  @override
  String get systemDescriptionCsvImport => 'CSVインポート';

  @override
  String get systemDescriptionOfxImport => 'OFXインポート';

  @override
  String get homeThisMonth => '今月';

  @override
  String get homeMoneyInTransit => '送金中の資金';

  @override
  String get homeWhatYouHaveMinusWhatYouOwe => '資産から負債を引いた額';

  @override
  String homeWhatYouHave(String amount, String currency) {
    return '保有額 $amount $currency';
  }

  @override
  String homeNetPosition(String amount, String currency) {
    return '$amount $currency';
  }

  @override
  String homeHaveAndOwe(String haveAmount, String currency, String oweAmount) {
    return '資産 $haveAmount $currency  •  負債 $oweAmount $currency';
  }

  @override
  String youSentFrom(String amount, String currency, String name) {
    return '$nameから$amount $currencyを送金しました';
  }

  @override
  String youSentTo(String amount, String currency, String name) {
    return '$nameへ$amount $currencyを送金しました';
  }

  @override
  String get hiddenLabel => '非表示';

  @override
  String get allAccounts => 'すべての口座';

  @override
  String savedToPath(String path) {
    return '$pathに保存しました';
  }

  @override
  String get keystoreExportFailed => 'キーストアファイルを書き出せませんでした。この手順はスキップできます。';

  @override
  String get enterPassphraseToProtect => 'ファイルを保護するパスフレーズを入力してください。';

  @override
  String get homeTapWhenArrived => '何が届いたか分かったらタップしてください';

  @override
  String homeReturnedTo(String name) {
    return '$nameへ返金されました';
  }

  @override
  String get homeDueToday => '本日期日';

  @override
  String homeDueLine(String category, String account) {
    return '$category · $account · タップして記録';
  }

  @override
  String get homeOverLimit => '上限超過';

  @override
  String homeSpentOfLimit(String spent, String limit) {
    return '$limit中$spent';
  }

  @override
  String homeRemaining(String amount) {
    return '残り: $amount';
  }

  @override
  String get homeNoAccounts => '口座がありません';

  @override
  String get homeCashRegister => 'レジ';

  @override
  String get homeMarketEstimate => '市場推定額';

  @override
  String get registerTitle => '明細';

  @override
  String get registerSearchHint => '摘要、カテゴリ、または金額';

  @override
  String get registerNoTransactions => '取引がまだありません';

  @override
  String get registerNoEntries => '記録された項目がまだありません。';

  @override
  String get registerSpentOnly => '支出のみ';

  @override
  String get registerReceivedOnly => '収入のみ';

  @override
  String get registerAll => 'すべて';

  @override
  String get registerUnverified => '未検証 - 合計から除外';

  @override
  String get registerSuperseded => '移行により置き換え済み - 合計から除外';

  @override
  String get summaryTitle => '概要';

  @override
  String get summaryTotalIncome => '総収入';

  @override
  String get summaryTotalExpense => '総支出';

  @override
  String summaryDateRange(String start, String end) {
    return '$start〜$end';
  }

  @override
  String get accountsTitle => '口座';

  @override
  String get categoriesTitle => 'カテゴリ';

  @override
  String get accountName => '口座名';

  @override
  String get createAccount => '口座を作成';

  @override
  String get createGroup => 'グループを作成';

  @override
  String get editGroup => 'グループを編集';

  @override
  String get renameAccount => '口座名を変更';

  @override
  String get renameCategory => 'カテゴリ名を変更';

  @override
  String get addCategory => 'カテゴリを追加';

  @override
  String get groupLabel => 'グループ';

  @override
  String get kindLabel => '種類';

  @override
  String get asset => '資産';

  @override
  String get liability => '負債';

  @override
  String get income => '収入';

  @override
  String get expense => '支出';

  @override
  String get thisAccountHoldsInvestments => 'この口座は投資を保有しています';

  @override
  String get thisAccountHoldsInvestmentsSubtitle =>
      '現金に加え、買い・売り・配当で記録する保有資産です。';

  @override
  String get thisIsACreditCard => 'これはクレジットカードです';

  @override
  String get openingBalanceOptional => '初期残高（任意）';

  @override
  String get currencyIso => '通貨（ISO 4217）';

  @override
  String get currencyIsoExample => '通貨（ISO 4217、例: USD）';

  @override
  String get hideAccountTitle => 'この口座を新規取引の対象から外しますか？';

  @override
  String get hideCategoryTitle => 'このカテゴリを新規取引の対象から外しますか？';

  @override
  String get hideGroupTitle => 'このグループを新規取引の対象から外しますか？';

  @override
  String get reassignGroup => 'グループを再割り当て';

  @override
  String get transferRemainingBalance => '残高を振り替える';

  @override
  String get monthlyLimit => '月間上限';

  @override
  String get monthlyLimitHint => '上限（空欄でクリア）';

  @override
  String get monthlyLimitBlurb => 'この支出カテゴリに対する、月初からの任意の支出目安です。';

  @override
  String get manageCategoryRules => 'カテゴリルールを管理';

  @override
  String get amount => '金額';

  @override
  String get category => 'カテゴリ';

  @override
  String get account => '口座';

  @override
  String get fromAccount => '振替元口座';

  @override
  String get toAccount => '振替先口座';

  @override
  String get descriptionOptional => '摘要（任意）';

  @override
  String get alsoRememberPayee => '支払先としても記憶する';

  @override
  String get splitIntoCategories => '複数のカテゴリに分割';

  @override
  String categoryN(String n) {
    return 'カテゴリ $n';
  }

  @override
  String get destinationAmount => '振替先金額';

  @override
  String get destinationAmountOptional => '振替先金額（任意）';

  @override
  String get accountCurrencyAmountOptional => '口座通貨での金額（任意）';

  @override
  String get transactionCurrencyOptional => '取引通貨（任意）';

  @override
  String get feeOptional => '手数料（任意）';

  @override
  String get feeAmount => '手数料額';

  @override
  String get feeCategory => '手数料カテゴリ';

  @override
  String get feeDescriptionOptional => '手数料の摘要（任意）';

  @override
  String get feeDeducted => '手数料は上記の金額から差し引かれます';

  @override
  String get needTwoAccountsToTransfer => '振替を行うには、有効な口座を2つ以上作成してください。';

  @override
  String get whatArrivedTitle => '何が届きましたか？';

  @override
  String get whatArrivedBlurb => '実際に届いたものを教えてください。';

  @override
  String get amountThatArrived => '届いた金額';

  @override
  String get feeLossCategory => '手数料／損失カテゴリ';

  @override
  String get alreadySettled => 'すでに確定済みです。';

  @override
  String get holdingsTitle => '保有資産';

  @override
  String get holdingsCash => '現金';

  @override
  String get holdingsInventory => '保有銘柄';

  @override
  String holdingsBook(String amount, String currency) {
    return '帳簿価額（現金＋取得原価） $amount $currency';
  }

  @override
  String holdingsMarketEstimate(String amount, String currency) {
    return '市場推定額 $amount $currency';
  }

  @override
  String get holdingsNoHoldings => '保有資産はまだありません。買いを記録して銘柄を追加してください。';

  @override
  String get holdingsQuotesBlurb => '相場は推定値であり、証券会社の価格ではありません。このアプリは注文を発注しません。';

  @override
  String get holdingsTapNameToResearch =>
      '銘柄名をタップして調べられます。相場は推定値であり、助言ではありません。';

  @override
  String get instrument => '銘柄';

  @override
  String get newInstrument => '新しい銘柄';

  @override
  String get renameInstrument => '銘柄名を変更';

  @override
  String get instrumentActions => '銘柄の操作';

  @override
  String hideInstrumentTitle(String name) {
    return '$nameを非表示にしますか？';
  }

  @override
  String get tickerOptional => 'ティッカー（任意）';

  @override
  String get isinOptional => 'ISIN（任意）';

  @override
  String get quantity => '数量';

  @override
  String get unitPrice => '単価';

  @override
  String get brokerageOptional => '取引手数料（任意）';

  @override
  String get brokerageExpenseCategory => '取引手数料の支出カテゴリ';

  @override
  String get incomeCategory => '収入カテゴリ';

  @override
  String get gainIncomeCategory => '売却益の収入カテゴリ';

  @override
  String get lossExpenseCategory => '売却損の支出カテゴリ';

  @override
  String get nonCash => '非現金';

  @override
  String get cash => '現金';

  @override
  String get locked => 'ロック中';

  @override
  String get lockUntilHint => '証券会社のルールではなく、あなた自身が記録する制限メモです。';

  @override
  String get instrumentKindStock => '株式';

  @override
  String get instrumentKindEtf => 'ETF';

  @override
  String get instrumentKindMutualFund => '投資信託';

  @override
  String get instrumentKindBond => '債券';

  @override
  String get instrumentKindOther => 'その他';

  @override
  String get quoteUseLive => 'リアルタイム価格';

  @override
  String get quoteUseCached => 'キャッシュ価格';

  @override
  String get quoteUseStale => '古い価格';

  @override
  String get quoteUseMissing => '価格なし（取得原価を使用）';

  @override
  String get quoteUseDisabled => '相場取得オフ — 取得原価／キャッシュを使用';

  @override
  String get quoteUseCurrencyMismatch => '取得原価を使用（価格の通貨が異なる）';

  @override
  String unrealizedLabel(String amount, String currency) {
    return '含み損益 $amount $currency';
  }

  @override
  String holdingsUnitsCost(String qty) {
    return '$qty 単位 · ';
  }

  @override
  String get recoveryPhraseTitle => 'リカバリーフレーズ';

  @override
  String get recoveryPhraseConfirmTitle => 'フレーズを確認';

  @override
  String get recoveryPhraseBlurb =>
      'この24個の単語は、この端末を紛失・初期化・交換した場合に取引履歴を復元する唯一の方法です。Smara家計簿にはサーバーがなく、代わりに復元することはできません。\n\nこの端末とこのフレーズを両方失うと、記録したすべての取引は永久に検証できなくなります。';

  @override
  String get recoveryPhraseWriteDown =>
      'これらの単語を順番に書き留め、この端末とは別の安全な場所に保管してください。';

  @override
  String get iveSavedRecoveryPhrase => 'リカバリーフレーズを保存しました';

  @override
  String get confirmPhraseBlurb => '先ほど保存したフレーズから指定された単語を入力してください。';

  @override
  String wordNumber(String n) {
    return '単語 #$n';
  }

  @override
  String get keystoreExportTitle => 'キーストアファイルを書き出す';

  @override
  String get keystoreExportBlurb =>
      'リカバリーフレーズに加えて、任意のパスフレーズで保護した暗号化キーストアファイルを保存できます。これは任意です - リカバリーフレーズだけでも常に署名鍵を復元するのに十分です。';

  @override
  String get keystorePassphrase => 'パスフレーズ';

  @override
  String get exportKeystoreFile => 'キーストアファイルを書き出す';

  @override
  String get chooseCurrencyTitle => '通貨を選択してください';

  @override
  String get chooseCurrencyBlurb =>
      '現時点では、各口座グループ（現金及び現金同等物、年金・退職金など）はこの1つの通貨を使用します。後で新しいグループを作成すれば、別の通貨の口座を追加することもできます。';

  @override
  String get currencyBackfillTitle => '既存のグループの通貨を選択';

  @override
  String get currencyBackfillBlurb =>
      'このアプリは複数通貨に対応しました。既存の口座と口座グループには通貨の設定が必要です。この機能が導入される前に作成されたものなので、すべてに同じ選択が適用されます。';

  @override
  String get firstAccountTitle => '口座に名前を付ける';

  @override
  String get firstAccountBlurb =>
      'これはあなたのためにあらかじめ用意された口座です - 銀行名のような、わかりやすい名前を付けてください。次に支出または収入を1件記録し、その後リカバリーフレーズで端末を保護します。';

  @override
  String get whatsMainAccountCalled => 'メインの口座の名前は何ですか？';

  @override
  String get restoreTitle => '署名鍵を復元';

  @override
  String get restoreBlurb =>
      'この端末には既存の帳簿がありますが、一致する署名鍵がありません。保存したリカバリーフレーズまたはキーストアファイルから復元してください - データは通常どおり検証され、何も再署名や変更はされません。';

  @override
  String get recoveryPhrase24 => 'リカバリーフレーズ（24個すべての単語）';

  @override
  String get keystoreFile => 'キーストアファイル';

  @override
  String get keystoreFileContents => 'キーストアファイルの内容';

  @override
  String get optionalBackupFile => '任意のバックアップファイル';

  @override
  String get iDontHavePhrase => 'リカバリーフレーズもキーストアファイルもありません';

  @override
  String get migrationTitle => '新しい鍵に移行';

  @override
  String get migrationBlurb =>
      'リカバリーフレーズもキーストアファイルもない場合、この端末の署名鍵は復元できません。新しい鍵を開始できます。古い項目は表示されたままですが、置き換え済みとなります。';

  @override
  String get iConfirmBooksValid => '現在の帳簿が正しいことを確認しました';

  @override
  String get whyWeDontEdit => '古い項目を編集しない理由';

  @override
  String get whyWeDontEditBody =>
      '誤りを修正するとき、すでに入力した内容を変更するのではなく、古い行をそのまま残し、隣に修正を追加します。こうすることで、何が起きたか、いつ修正したかが履歴に常に正確に表示され、気づかないうちに内容が変わることはありません。';

  @override
  String get lockTitle => 'ロック解除';

  @override
  String get lockScreenTitle => 'ロック中';

  @override
  String get enterPinToContinue => '続けるにはPINを入力してください';

  @override
  String get pinLabel => 'PIN';

  @override
  String get setPinTitle => 'PINを設定';

  @override
  String get currentPin => '現在のPIN';

  @override
  String get newPin => '新しいPIN';

  @override
  String get confirmPin => 'PINを確認';

  @override
  String get confirmNewPin => '新しいPINを確認';

  @override
  String get firstWeekTitle => '口座を設定する';

  @override
  String get addCashAccount => '現金口座を追加';

  @override
  String get addCreditCard => 'クレジットカードを追加';

  @override
  String get cashAccountName => '現金口座名';

  @override
  String get cardName => 'カード名';

  @override
  String get paidFromBank => '銀行から支払い';

  @override
  String get paidFromCard => 'カードから支払い';

  @override
  String get choosePassphraseTitle =>
      'このバックアップを保護するパスフレーズを選んでください。忘れた場合、復元する方法はありません。';

  @override
  String get replaceBooksTitle => 'この端末の帳簿を置き換えますか？';

  @override
  String get replaceBooksBody =>
      'これにより、現在このアプリにあるすべてのデータがバックアップの内容に置き換わります。その後アプリを閉じて開き直してください。';

  @override
  String get chooseBackupFileFirst => '先にバックアップファイルを選択してください。';

  @override
  String get backupRestored => 'バックアップを復元しました';

  @override
  String get backupRestoredBody => '帳簿が復元されました。続けるにはアプリを閉じて開き直してください。';

  @override
  String get fixThisEntry => 'この項目を修正';

  @override
  String get fixBlurb => '古い行はそのまま残ります。確定すると、取消行と修正後の行が追加されます。';

  @override
  String get importStatementTitle => '明細書をインポート';

  @override
  String get importOfx => 'OFXをインポート';

  @override
  String get importOfxQfxFile => 'OFX / QFXファイルをインポート';

  @override
  String get importCsvFile => 'CSVファイルをインポート';

  @override
  String get whatKindOfStatement => 'お持ちの明細書ファイルの種類は？';

  @override
  String get chooseAccountForFile => 'このファイルがどの口座のものか選択してください。';

  @override
  String get importIntoAccount => 'インポート先の口座';

  @override
  String get useSavedProfile => '保存済みプロファイルを使う';

  @override
  String get saveMappingProfile => 'このマッピングをプロファイルとして保存（任意）';

  @override
  String get renameProfile => 'プロファイル名を変更';

  @override
  String get deleteProfileTitle => 'プロファイルを削除しますか？';

  @override
  String get fileHasHeader => 'ファイルにヘッダー行がある';

  @override
  String get dateColumn => '日付の列';

  @override
  String get dateFormatHint => '日付形式（例: dd/MM/yyyy）';

  @override
  String get amountColumn => '金額の列';

  @override
  String get amountConvention => '金額の符号規則';

  @override
  String get signedAmountColumn => '符号付き金額の列';

  @override
  String get separateDebitCredit => '借方／貸方の列を分ける';

  @override
  String get debitColumn => '借方の列';

  @override
  String get creditColumn => '貸方の列';

  @override
  String get decimalSeparator => '小数点の記号（. または ,）';

  @override
  String get descriptionColumns => '摘要の列';

  @override
  String get referenceIdColumn => '参照IDの列（任意）';

  @override
  String get skippedRows => 'スキップされた行';

  @override
  String parsedTransactionCount(String count) {
    return '$count件の取引を解析しました';
  }

  @override
  String skippedOrExcludedCount(String count) {
    return '$count件をスキップまたは除外';
  }

  @override
  String postedFailedCount(String posted, String failed) {
    return '$posted件記帳、$failed件失敗';
  }

  @override
  String get categoryForAll => 'すべてに適用するカテゴリ';

  @override
  String get saveAsRule => 'ルールとして保存しますか？';

  @override
  String get saveAsRuleBlurb => '今後、摘要にこのキーワードを含むインポートには、このカテゴリが使用されます。';

  @override
  String get keyword => 'キーワード';

  @override
  String get noSavedRules => '保存されたルールはまだありません。行のグループにカテゴリを割り当てるとルールを保存できます。';

  @override
  String get deleteRuleTitle => 'ルールを削除しますか？';

  @override
  String get editRule => 'ルールを編集';

  @override
  String rowsGrouped(String count) {
    return '$count行';
  }

  @override
  String selectStatementFile(String extensions) {
    return 'インポートする$extensions明細書ファイルを選択してください';
  }

  @override
  String get payeesTitle => '支払先';

  @override
  String get addPayee => '支払先を追加';

  @override
  String get renamePayee => '支払先名を変更';

  @override
  String get deletePayeeTitle => '支払先を削除しますか？';

  @override
  String get noPayeesYet => '支払先はまだありません';

  @override
  String get recurringTitle => '定期テンプレート';

  @override
  String get noRecurringYet => '定期テンプレートはまだありません';

  @override
  String get deleteTemplateTitle => '定期テンプレートを削除しますか？';

  @override
  String get dayOfMonth => '毎月の日（1〜31）';

  @override
  String get dayOfMonthNote => '日数が少ない月では、その月の最終日が使用されます。';

  @override
  String dayOfMonthLine(String day) {
    return '毎月$day日 - ';
  }

  @override
  String get name => '名前';

  @override
  String get none => 'なし';

  @override
  String get currency => '通貨';

  @override
  String get errorGeneric => '問題が発生しました。もう一度お試しください。';

  @override
  String get errorSigningIdentityMismatch =>
      'このリカバリーフレーズまたはキーストアファイルは、このデータベース内のどの署名アイデンティティとも一致しません。';

  @override
  String get errorInvalidLedgerBackup => 'このファイルは有効なSmaraのバックアップではありません。';

  @override
  String get errorInvalidLedgerBackupNoIdentity =>
      'このバックアップには署名アイデンティティがありません - 有効なSmaraのバックアップではありません。';

  @override
  String get errorInvalidLedgerBackupUnverified =>
      'このバックアップは正常な帳簿として検証できなかったため、復元されませんでした。';

  @override
  String errorInvalidLedgerBackupUnreadable(String detail) {
    return 'このファイルをSmaraのバックアップとして開けませんでした: $detail';
  }

  @override
  String get errorForeignBackupIdentity =>
      'このバックアップは、この端末のものとは異なる署名アイデンティティに属しています。';

  @override
  String get errorAccountNotFinancial => 'それは財務口座ではありません。';

  @override
  String get errorAccountArchived => 'その口座は非表示になっています。';

  @override
  String get errorAccountNotArchived => 'その口座は非表示になっていません。';

  @override
  String get errorAccountNoPositiveBalanceToCloseOut => '振り替える残高がありません。';

  @override
  String get errorAccountHasNoGroup => 'その口座にはグループが割り当てられていません。';

  @override
  String get errorGroupHasNoCurrency => 'そのグループにはまだ通貨が設定されていません。';

  @override
  String get errorGroupNotFound => 'その口座グループが見つかりませんでした。';

  @override
  String get errorInvestmentAccountsMustBeAssets => '資産口座のみを投資口座として設定できます。';

  @override
  String get errorCreditCardsMustBeLiabilities => '負債口座のみをクレジットカードとして設定できます。';

  @override
  String get errorOpeningBalanceMustBePositive => '初期残高を指定する場合は正の値である必要があります。';

  @override
  String get errorAccountTypeDoesNotMatchGroup => 'その口座の種類はグループと一致しません。';

  @override
  String get errorLastActiveAccount => '最後の有効な財務口座を非表示にすることはできません。';

  @override
  String get errorCurrencyRequiredToCreateGroup => 'グループを作成するには通貨が必要です。';

  @override
  String get errorSystemGroupCannotBeArchived => '組み込みの口座グループは非表示にできません。';

  @override
  String get errorGroupAlreadyArchived => 'そのグループはすでに非表示になっています。';

  @override
  String get errorCannotArchiveGroupWithAccounts => '有効な口座がまだあるグループは非表示にできません。';

  @override
  String get errorSystemGroupNeverArchived => '組み込みの口座グループが非表示になることはありません。';

  @override
  String get errorAccountGroupsCannotBeDeleted => '口座グループは削除できません。';

  @override
  String get errorCannotReassignDifferentCurrency =>
      'この口座を別の通貨のグループに移動することはできません。';

  @override
  String get errorCannotChangeGroupCurrencyWithAccounts =>
      'グループに有効な口座がある間は通貨を変更できません。';

  @override
  String get errorAmountMustBePositive => '金額は正の値にしてください。';

  @override
  String get errorAccountCurrencyAmountMustBePositive => '口座通貨での金額は正の値にしてください。';

  @override
  String get errorAccountCurrencyAmountNotForSameCurrency =>
      '口座通貨での金額は、外貨建ての項目にのみ使用します。';

  @override
  String get errorSplitNeedsTwoLines => '分割には少なくとも2つのカテゴリ行が必要です。';

  @override
  String get errorSplitLineMustBePositive => '分割した各行の金額は正の値である必要があります。';

  @override
  String get errorSplitLinesMustSumToTotal => '分割した行の合計は取引の総額と一致する必要があります。';

  @override
  String get errorTransferAmountMustBePositive => '振替金額は正の値にしてください。';

  @override
  String get errorTransferAccountsMustDiffer => '振替元口座と振替先口座は異なる必要があります。';

  @override
  String get errorCloseoutRequiresDestinationAmount =>
      '異なる通貨間の決済には、振替先金額が既知である必要があります。';

  @override
  String get errorDestinationAmountNotForSameCurrency =>
      '振替先金額は、異なる通貨間の振替にのみ使用します。';

  @override
  String get errorDestinationAmountMustBePositive => '振替先金額は正の値にしてください。';

  @override
  String get errorInvestmentCashExceeded => 'この投資口座の現金を超えて振り替えることはできません。';

  @override
  String get errorCannotReverseUnsettledProvisional =>
      '取り消す代わりに、この保留中の振替を確定してください。';

  @override
  String get errorAlreadyReversed => 'この項目はすでに修正されています。元の行はそのまま残ります。';

  @override
  String get errorNotActiveExpenseCategory => '有効な支出カテゴリを選択してください。';

  @override
  String get errorNotActiveIncomeCategory => '有効な収入カテゴリを選択してください。';

  @override
  String get errorSettledAmountMustNotBeNegative => '届いた金額を負の値にすることはできません。';

  @override
  String get errorPendingTransferNotFound => 'その保留中の振替が見つかりませんでした。';

  @override
  String get errorPendingTransferAlreadySettled => 'その保留中の振替はすでに確定しています。';

  @override
  String get errorSettledToMustBeSourceOrDestination =>
      '元の振替元口座または振替先口座を選択してください。';

  @override
  String get errorFeeCategoryOnlyWhenReturningToSource =>
      '手数料カテゴリは、資金が振替元口座に戻る場合にのみ使用します。';

  @override
  String get errorSettledAmountMustBePositiveForDelivery =>
      '届いた金額として正の値を入力してください。';

  @override
  String get errorSettledAmountExceedsProvisional => 'その金額は送金額を超えています。';

  @override
  String get errorInstrumentNotFound => 'その銘柄が見つかりませんでした。';

  @override
  String get errorIncomeRequiredForNonCash => '非現金での取得には有効な収入カテゴリが必要です。';

  @override
  String get errorInsufficientCash => 'この投資口座には、その買いを行うための現金が不足しています。';

  @override
  String get errorSellQuantityAndPriceMustBePositive => '売却数量と単価は正の値にしてください。';

  @override
  String errorLockedUntil(String date) {
    return '売却できません: 一部の単位は$dateまでロックされています。';
  }

  @override
  String get errorInsufficientQuantity => '現在ロック解除されている保有数を超えて売却することはできません。';

  @override
  String get errorIncomeRequiredForGain => '実現利益には有効な収入カテゴリが必要です。';

  @override
  String get errorExpenseRequiredForLoss => '実現損失には有効な支出カテゴリが必要です。';

  @override
  String errorBrokerageFailedAfterBuy(String detail) {
    return '買いは記帳されましたが、取引手数料の記帳に失敗しました: $detail';
  }

  @override
  String errorBrokerageFailedAfterSell(String detail) {
    return '売りは記帳されましたが、取引手数料の記帳に失敗しました: $detail';
  }

  @override
  String get errorDividendMustBePositive => '配当金額は正の値にしてください。';

  @override
  String get errorNotInvestmentAccount => 'それは投資口座ではありません。';

  @override
  String get errorNoInventoryCompanion => 'この投資口座には対応する保有資産の記録がありません。';

  @override
  String errorInvestmentReversalBlocked(String sells) {
    return 'この買いを取り消せません: 後の売り取引がその単位に依存しています。先に依存する売り取引を取り消してください: $sells。';
  }

  @override
  String get errorMonthlyLimitMustBePositive => '月間上限は正の値にしてください。';

  @override
  String get errorTemplateAmountMustBePositive => 'テンプレートの金額は正の値にしてください。';

  @override
  String get errorOfxUnrecognized => 'このファイルをOFXとして認識できませんでした。';

  @override
  String get errorCsvEmpty => '選択されたファイルは空です。';

  @override
  String get errorCsvUnreadable => 'このファイルをCSVとして読み取れませんでした。';

  @override
  String get errorCsvNoRows => '選択されたファイルに行がありません。';

  @override
  String get skipMissingDate => '日付がありません。';

  @override
  String skipUnparseableDate(String raw, String pattern) {
    return 'パターン「$pattern」で日付「$raw」を解析できませんでした。';
  }

  @override
  String get skipOfxMissingOrInvalidDate => '取引日がないか、無効です。';

  @override
  String skipOfxUnparseableDate(String raw) {
    return '取引日「$raw」を解析できませんでした。';
  }

  @override
  String get skipMissingAmount => '金額がありません。';

  @override
  String skipUnparseableAmount(String raw) {
    return '金額「$raw」を解析できませんでした。';
  }

  @override
  String get skipZeroAmount => '金額がゼロです。';

  @override
  String get skipUnparseableDebitCreditAmount => '借方または貸方の金額を解析できませんでした。';

  @override
  String get skipBothDebitAndCreditNonZero => '借方列と貸方列の両方に金額があります。';

  @override
  String get skipBothDebitAndCreditZero => '借方列と貸方列が両方ともゼロです。';

  @override
  String errorBackupCreateFailed(String detail) {
    return 'バックアップを作成できませんでした: $detail';
  }

  @override
  String get errorBackupRestoreFailed =>
      'このバックアップを復元できませんでした - パスフレーズが間違っているか、Smaraのバックアップファイルではありません。';

  @override
  String get validationAmountAccountCategoryRequired => '金額、口座、カテゴリは必須です。';

  @override
  String get validationAmountAccountRequired => '金額と口座は必須です。';

  @override
  String get validationSplitLineIncomplete => '分割した各行にはカテゴリと金額が必要です。';

  @override
  String get validationSplitSumMismatch => '分割した行の合計は取引の総額と一致する必要があります。';

  @override
  String get validationFromToAmountRequired => '振替元口座、振替先口座、金額は必須です。';

  @override
  String get validationAmountArrivedRequired => '届いた金額は必須です。';

  @override
  String get validationChooseReceivingAccount => '資金を受け取った口座を選択してください。';

  @override
  String get validationAccountCategoryRequired => '口座とカテゴリは必須です。';

  @override
  String get validationFixFailed => 'この修正を保存できませんでした。';

  @override
  String get validationNameRequired => 'メインの口座に名前を付けてください。';

  @override
  String get validationStillLoading => '読み込み中です - しばらくしてからもう一度お試しください。';

  @override
  String get validationSaveAccountNameFailed => '口座名を保存できませんでした。';

  @override
  String get validationWrongPin => 'PINが違います。もう一度お試しください。';

  @override
  String get validationCategoryMustBeIncomeOrExpense =>
      'カテゴリは収入または支出である必要があります。';

  @override
  String get validationOnlyExpenseHasMonthlyLimit => '月間上限を設定できるのは支出カテゴリのみです。';

  @override
  String get validationInvalidTemplate => '無効なテンプレートです。';

  @override
  String get validationWrongKeystorePassphrase => 'このキーストアファイルのパスフレーズが違います。';

  @override
  String get validationInvalidKeystoreFile => 'これは有効なキーストアファイルではないようです。';

  @override
  String get validationRestorePhraseFailed => 'そのリカバリーフレーズから復元できませんでした。';

  @override
  String validationGenerateKeyFailed(String detail) {
    return 'この端末で署名鍵を生成できませんでした: $detail';
  }

  @override
  String validationSaveCurrencyFailed(String detail) {
    return 'この通貨を保存できませんでした: $detail';
  }

  @override
  String get validationMigrationFailed => '移行に失敗しました。もう一度お試しください。';

  @override
  String get validationChooseBackupFile => '先にバックアップファイルを選択してください。';

  @override
  String get validationPassphraseRequired => 'パスフレーズを入力してください。';

  @override
  String get validationPinsDoNotMatch => '2つのPINが一致しません。';

  @override
  String get validationFeePositiveWithCategory =>
      '振替手数料は、支出カテゴリを選択したうえで正の値にする必要があります。';

  @override
  String get validationFeeMustBeLessThanAmount =>
      '手数料差し引き方式の振替では、手数料は金額より小さくする必要があります。';

  @override
  String validationTransferSavedFeeFailed(String detail) {
    return '振替は保存されましたが、手数料を記録できませんでした: $detail';
  }

  @override
  String get validationEnterValidAmount => '有効な金額を入力してください。';

  @override
  String validationConfirmWordMismatch(String n) {
    return '単語$nが保存したフレーズと一致しません。確認してもう一度お試しください。';
  }

  @override
  String get errorBuyQuantityAndPriceMustBePositive => '買いの数量と単価は正の値にしてください。';

  @override
  String get errorInstrumentArchived => '非表示にした銘柄を買うことはできません。';

  @override
  String get errorNonCashCannotIncludeBrokerage =>
      '非現金での取得には取引手数料を含めることはできません。';

  @override
  String get errorBrokerageRequiresExpenseCategory =>
      '取引手数料が正の値の場合、有効な支出カテゴリが必要です。';

  @override
  String get errorSellProceedsMustCoverBrokerage => '売却代金は取引手数料以上である必要があります。';

  @override
  String homeSpentOfLimitThisMonth(String spent, String limit) {
    return '今月 $limit中$spent';
  }

  @override
  String get unlockBiometricReason => 'Smara家計簿のロックを解除';

  @override
  String get searchLabel => '検索';

  @override
  String get openingBalance => '初期残高';

  @override
  String transferToName(String name) {
    return '振替: $name';
  }

  @override
  String get feeForTransfer => '振替手数料';

  @override
  String feeForTransferTo(String name) {
    return '$nameへの振替手数料';
  }

  @override
  String couldNotOpenFilePicker(String detail) {
    return 'ファイル選択画面を開けませんでした: $detail';
  }

  @override
  String pleaseSelectFile(String extensions) {
    return '.$extensionsファイルを選択してください';
  }

  @override
  String get currencyCodeIso => '通貨コード（ISO 4217、例: USD）';

  @override
  String splitCounterpartMore(String name, String count) {
    return '$name 他$count件';
  }

  @override
  String get dateLabel => '日付';

  @override
  String get noneSelected => 'なし';

  @override
  String reviewEntriesBeforeContinuing(String count) {
    return '続ける前に、以下の項目（合計$count件）を確認してください。';
  }

  @override
  String youReceived(String amount) {
    return '$amountを受け取りました';
  }

  @override
  String get leaveBlankIfRateUnknown => '為替レートがまだわからない場合は空欄のままにしてください。';

  @override
  String get recordTradeBlurb => 'すでに行われた取引を記録します。このアプリは注文を発注しません。';

  @override
  String get feeOnTopBlurb => 'オン: 上記の金額はこの口座から差し引かれる総額で、手数料はそこから差し引かれます。';

  @override
  String get feeBankBlurb => '銀行または仲介業者によって前もって請求される手数料です。';

  @override
  String get validationPinMinLength => 'PINは4桁以上である必要があります。';

  @override
  String get restoreBackupBlurb =>
      'これは、現在このアプリにあるすべてのデータをバックアップの内容に置き換えます — 結合はされません。バックアップファイルを選択し、保護に使用したパスフレーズを入力してください。';

  @override
  String get actionReplace => '置き換える';

  @override
  String hideAccountBody(String name) {
    return '$nameは今後、新しい取引には使用できなくなります。';
  }

  @override
  String hideGroupBody(String name) {
    return '$nameは今後、口座の作成や再割り当ての際に候補として表示されなくなります。';
  }

  @override
  String hideCategoryBody(String name) {
    return '$nameは今後、新しい取引を記録する際に候補として表示されなくなります。';
  }

  @override
  String get hideInstrumentBody =>
      '非表示にした銘柄は、過去の買い・売りにはそのまま残ります。配当も引き続き記録できます。';

  @override
  String nameHidden(String name) {
    return '$name（非表示）';
  }

  @override
  String get noCurrencySet => '通貨が設定されていません';

  @override
  String deletePayeeBody(String name) {
    return '$nameとその記憶されたデフォルト値が削除されます。過去の取引には影響しません。';
  }

  @override
  String deleteTemplateBody(String name) {
    return '$nameは今後、期日として表示されなくなります。すでに記録された過去の取引には影響しません。';
  }

  @override
  String deleteProfileBody(String name) {
    return '保存された列マッピング「$name」が削除されます。すでにそれを使ってインポートした明細書には影響しません。';
  }

  @override
  String deleteRuleBody(String keyword) {
    return '今後のインポートは「$keyword」による自動カテゴリ分けの対象外になります。このルールですでにカテゴリ分けされた取引には影響しません。';
  }

  @override
  String get firstWeekBlurb =>
      '任意で、今すぐクレジットカードや現金口座を追加できます - 口座は後からいつでも設定画面から追加できます。';

  @override
  String get deliveredToDestination => '振替先に到着済み';

  @override
  String deliveredToName(String name) {
    return '$nameに到着済み';
  }

  @override
  String youReceivedLessThanExpected(String amount, String currency) {
    return '予定より$amount $currency少なく受け取りました - 差額を計上するカテゴリを選択してください。';
  }

  @override
  String get dateRangeLabel => '日付範囲';

  @override
  String get addTemplate => 'テンプレートを追加';

  @override
  String get editTemplate => 'テンプレートを編集';

  @override
  String get validationFillTemplateFields => 'すべての項目に有効な金額と日を入力してください。';

  @override
  String get saveCsvExport => 'CSVの書き出しを保存';

  @override
  String get referenceRate => '参考レート';

  @override
  String get yourRate => 'あなたのレート';

  @override
  String leaveBlankIfThisWasAccountCurrency(String currency) {
    return '口座自体の通貨である$currencyだった場合は空欄のままにしてください。';
  }

  @override
  String get lockUntilOptional => 'ロック期限（任意）';

  @override
  String lockedUntilDate(String date) {
    return '$dateまでロック中';
  }

  @override
  String get copiedResearchPrompt =>
      '調査用プロンプトをコピーしました — ブラウザのURLが利用できないか、オフラインです。';

  @override
  String get openedFavouriteResearchTool => 'お気に入りの調査ツールを開きました。';

  @override
  String get looksLikeGain => 'これは利益のようです';

  @override
  String get looksLikeLoss => 'これは損失のようです';

  @override
  String get looksLikeBreakEven => 'これは損益ゼロのようです';

  @override
  String sellableQuantity(String name, String qty) {
    return '$name（売却可能 $qty）';
  }

  @override
  String columnN(String index) {
    return '列 $index';
  }

  @override
  String get importingLabel => 'インポート中...';

  @override
  String get confirmImport => 'インポートを確定';

  @override
  String get manageSavedCategoryRules => '保存済みカテゴリルールを管理';

  @override
  String statementCurrencyMismatch(String currency) {
    return 'このファイルの通貨（$currency）は選択した口座の通貨と一致しません。';
  }

  @override
  String get categoryRulesTitle => 'カテゴリルール';

  @override
  String get possibleDuplicate => '重複の可能性';

  @override
  String get unknownCategory => '不明なカテゴリ';

  @override
  String get researchPromptIntro =>
      '家庭の投資家のために、この公開上場銘柄を調べてください。発行体を特定し、判明していれば日付付きで最近のニュースを要約し、下落リスクと上昇要因を整理してください。事実と推測を区別してください。買い、売り、保有の推奨はしないでください。これは投資助言ではありません。';

  @override
  String researchPromptNameLine(String name) {
    return '名称: $name';
  }

  @override
  String researchPromptTickerLine(String ticker) {
    return 'ティッカー: $ticker';
  }

  @override
  String get researchPromptTickerNoneProvided => 'ティッカー: (未指定)';

  @override
  String researchPromptIsinLine(String isin) {
    return 'ISIN: $isin';
  }

  @override
  String get researchPromptIsinNoneProvided => 'ISIN: (未指定)';
}
