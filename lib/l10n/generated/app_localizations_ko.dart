// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'Smara 회계';

  @override
  String get navHome => '홈';

  @override
  String get navRegister => '내역';

  @override
  String get navSummary => '요약';

  @override
  String get navAccounts => '계좌';

  @override
  String get navCategories => '분류';

  @override
  String get actionCancel => '취소';

  @override
  String get actionSave => '저장';

  @override
  String get actionDelete => '삭제';

  @override
  String get actionDone => '완료';

  @override
  String get actionContinue => '계속';

  @override
  String get actionDismiss => '닫기';

  @override
  String get actionRetry => '다시 시도';

  @override
  String get actionSkip => '건너뛰기';

  @override
  String get actionConfirm => '확인';

  @override
  String get actionAdd => '추가';

  @override
  String get actionEdit => '편집';

  @override
  String get actionRename => '이름 변경';

  @override
  String get actionHide => '숨기기';

  @override
  String get actionCreate => '만들기';

  @override
  String get actionCloseApp => '앱 종료';

  @override
  String get actionUnlock => '잠금 해제';

  @override
  String get actionSettle => '정산';

  @override
  String get actionFinish => '마침';

  @override
  String get actionPreview => '미리보기';

  @override
  String get actionImport => '가져오기';

  @override
  String get actionExportCsv => 'CSV 내보내기';

  @override
  String get actionChooseFile => '파일 선택';

  @override
  String get actionRestore => '복원';

  @override
  String get actionFix => '수정';

  @override
  String get actionBuy => '매수';

  @override
  String get actionSell => '매도';

  @override
  String get actionDividend => '배당금';

  @override
  String get actionRecordBuy => '매수 기록';

  @override
  String get actionRecordSell => '매도 기록';

  @override
  String get actionRecordDividend => '배당금 기록';

  @override
  String get actionPayCard => '카드 결제';

  @override
  String get actionTransfer => '이체';

  @override
  String get actionRecordTransaction => '거래 기록';

  @override
  String get actionImportStatement => '명세서 가져오기';

  @override
  String get actionClearDates => '날짜 지우기';

  @override
  String get actionClearSearch => '검색 및 필터 지우기';

  @override
  String get actionUseBiometrics => '생체 인증 사용';

  @override
  String get actionSetPin => 'PIN 설정';

  @override
  String get actionChangePin => 'PIN 변경';

  @override
  String get actionSaveBackup => '백업 저장';

  @override
  String get actionRestoreBackup => '백업 복원';

  @override
  String get actionSaveRule => '규칙 저장';

  @override
  String get actionConfirmFix => '수정 확인';

  @override
  String get captureSpent => '지출';

  @override
  String get captureReceived => '수입';

  @override
  String get captureMovedMoney => '자금 이동';

  @override
  String get captureImportStatement => '명세서 가져오기';

  @override
  String get settingsTitle => '설정';

  @override
  String get settingsLanguage => '언어';

  @override
  String get settingsLanguageSystem => '기기 언어';

  @override
  String get settingsFetchFxRates => '참고 환율 가져오기';

  @override
  String get settingsFetchFxRatesSubtitle =>
      '해외 통화 이체 시 목적지 금액 옆에 참고용 시장 환율을 표시합니다. 비교 용도로만 사용되며, 금액을 자동으로 채우는 데는 절대 사용되지 않습니다.';

  @override
  String get settingsRateProvider => '환율 제공자';

  @override
  String get settingsFetchMarketPrices => '투자 상품의 시장 가격 가져오기';

  @override
  String get settingsFetchMarketPricesSubtitle =>
      '티커나 ISIN이 있는 상품의 최근 가격을 조회하여 포트폴리오 가치를 추정합니다. 거래를 기록하는 데는 사용되지 않으며, 보유 수량을 전송하지도 않습니다.';

  @override
  String get settingsMarketPriceProvider => '시장 가격 제공자';

  @override
  String get settingsFavouriteResearchTool => '즐겨찾는 리서치 도구';

  @override
  String get settingsFavouriteResearchToolSubtitle =>
      '보유 종목에서 상품명을 탭하면 이 도구가 브라우저에서 리서치 프롬프트와 함께 열립니다 — 연동이 아니며 투자 조언도 아닙니다.';

  @override
  String get settingsBackup => '백업';

  @override
  String get settingsBackupBlurb =>
      '장부의 암호화된 사본을 원하는 위치에 저장하거나 그로부터 복원할 수 있습니다. 이는 서명 키를 백업하는 복구 구문이나 키스토어 파일과는 별개이며, 장부가 아닌 키를 백업합니다.';

  @override
  String get settingsLock => '잠금';

  @override
  String get settingsLockBlurb => '앱을 열 때 PIN 또는 (가능한 경우) 생체 인증을 요구합니다.';

  @override
  String get settingsRequireUnlock => '앱을 열 때 잠금 해제 요구';

  @override
  String get settingsLockAfter => '다음 시간 후 잠금';

  @override
  String get settingsLockImmediately => '즉시';

  @override
  String get settingsLock1Minute => '1분';

  @override
  String get settingsLock5Minutes => '5분';

  @override
  String get settingsLock15Minutes => '15분';

  @override
  String get settingsAllowBiometrics => '생체 인증도 허용';

  @override
  String get settingsHideSnapshot => '앱 전환 화면에서 잔액 숨기기';

  @override
  String get settingsHideSnapshotSubtitle =>
      '다른 앱으로 전환할 때 이 화면을 가려서 앱 전환기에서 한눈에 보이지 않도록 합니다.';

  @override
  String get settingsHideSnapshotUnavailable =>
      '이 플랫폼에서는 앱 전환 화면에서 잔액을 숨길 수 없습니다.';

  @override
  String get settingsPayees => '수취인';

  @override
  String get settingsManagePayees => '수취인 관리';

  @override
  String get settingsPayeesBlurb =>
      '저장된 수취인 이름과 기본 분류·계좌로, 거래를 기록할 때 자동완성으로 제안됩니다.';

  @override
  String get settingsRecurring => '정기 템플릿';

  @override
  String get settingsManageRecurring => '정기 템플릿 관리';

  @override
  String get settingsRecurringBlurb =>
      '임대료나 급여처럼 매달 반복되는 청구서나 수입입니다. 예정된 템플릿은 홈 화면에 표시되어 탭 한 번으로 기록할 수 있으며, 자동으로 등록되지 않습니다.';

  @override
  String get settingsAbout => '정보';

  @override
  String get providerFrankfurter => 'Frankfurter (ECB 환율)';

  @override
  String get providerOpenErApi => 'ExchangeRate-API (open.er-api.com)';

  @override
  String get providerStooq => 'Stooq (일일 시세)';

  @override
  String get providerYahooFinance => 'Yahoo Finance (차트 API)';

  @override
  String get researchChatGpt => 'ChatGPT';

  @override
  String get researchClaude => 'Claude';

  @override
  String get researchGemini => 'Gemini';

  @override
  String get researchMetaAi => 'Meta AI';

  @override
  String get systemGroupCashEquivalents => '현금 및 현금성 자산';

  @override
  String get systemGroupPensionRetirement => '연금 및 퇴직';

  @override
  String get systemGroupCreditShortTerm => '신용 및 단기 부채';

  @override
  String get systemGroupLoansMortgages => '대출 및 담보대출';

  @override
  String get systemGroupInvestments => '투자';

  @override
  String get systemAccountCashBank => '현금 및 은행';

  @override
  String get systemCategorySalary => '급여';

  @override
  String get systemCategoryOtherIncome => '기타 수입';

  @override
  String get systemCategoryGroceries => '식료품';

  @override
  String get systemCategoryRentMortgage => '임대료/담보대출';

  @override
  String get systemCategoryUtilities => '공과금';

  @override
  String get systemCategoryTransport => '교통';

  @override
  String get systemCategoryFoodOut => '외식';

  @override
  String get systemCategoryPhone => '통신비';

  @override
  String get systemCategoryHealth => '건강';

  @override
  String get systemCategoryOtherExpense => '기타 지출';

  @override
  String get homeThisMonth => '이번 달';

  @override
  String get homeMoneyInTransit => '이동 중인 자금';

  @override
  String get homeWhatYouHaveMinusWhatYouOwe => '보유 자산에서 부채를 뺀 금액';

  @override
  String homeWhatYouHave(String amount, String currency) {
    return '보유 금액 $amount $currency';
  }

  @override
  String homeNetPosition(String amount, String currency) {
    return '$amount $currency';
  }

  @override
  String homeHaveAndOwe(String haveAmount, String currency, String oweAmount) {
    return '보유 금액 $haveAmount $currency  •  부채 금액 $oweAmount $currency';
  }

  @override
  String youSentFrom(String amount, String currency, String name) {
    return '$name에서 $amount $currency를 보냈습니다';
  }

  @override
  String youSentTo(String amount, String currency, String name) {
    return '$name에게 $amount $currency를 보냈습니다';
  }

  @override
  String get hiddenLabel => '숨김';

  @override
  String get allAccounts => '모든 계좌';

  @override
  String savedToPath(String path) {
    return '$path에 저장됨';
  }

  @override
  String get keystoreExportFailed => '키스토어 파일을 내보낼 수 없습니다. 이 단계는 건너뛸 수 있습니다.';

  @override
  String get enterPassphraseToProtect => '파일을 보호할 암호를 입력하세요.';

  @override
  String get homeTapWhenArrived => '도착한 금액을 알게 되면 탭하세요';

  @override
  String homeReturnedTo(String name) {
    return '$name(으)로 반환됨';
  }

  @override
  String get homeDueToday => '오늘 예정';

  @override
  String homeDueLine(String category, String account) {
    return '$category · $account · 탭하여 기록';
  }

  @override
  String get homeOverLimit => '한도 초과';

  @override
  String homeSpentOfLimit(String spent, String limit) {
    return '$limit 중 $spent 지출';
  }

  @override
  String homeRemaining(String amount) {
    return '남은 금액: $amount';
  }

  @override
  String get homeNoAccounts => '계좌 없음';

  @override
  String get homeCashRegister => '현금 계좌';

  @override
  String get homeMarketEstimate => '시장 추정가';

  @override
  String get registerTitle => '내역';

  @override
  String get registerSearchHint => '설명, 분류 또는 금액';

  @override
  String get registerNoTransactions => '아직 거래가 없습니다';

  @override
  String get registerNoEntries => '아직 기록된 항목이 없습니다.';

  @override
  String get registerSpentOnly => '지출만';

  @override
  String get registerReceivedOnly => '수입만';

  @override
  String get registerAll => '전체';

  @override
  String get registerUnverified => '미검증 - 합계에서 제외됨';

  @override
  String get registerSuperseded => '마이그레이션으로 대체됨 - 합계에서 제외됨';

  @override
  String get summaryTitle => '요약';

  @override
  String get summaryTotalIncome => '총 수입';

  @override
  String get summaryTotalExpense => '총 지출';

  @override
  String summaryDateRange(String start, String end) {
    return '$start ~ $end';
  }

  @override
  String get accountsTitle => '계좌';

  @override
  String get categoriesTitle => '분류';

  @override
  String get accountName => '계좌 이름';

  @override
  String get createAccount => '계좌 만들기';

  @override
  String get createGroup => '그룹 만들기';

  @override
  String get editGroup => '그룹 편집';

  @override
  String get renameAccount => '계좌 이름 변경';

  @override
  String get renameCategory => '분류 이름 변경';

  @override
  String get addCategory => '분류 추가';

  @override
  String get groupLabel => '그룹';

  @override
  String get kindLabel => '종류';

  @override
  String get asset => '자산';

  @override
  String get liability => '부채';

  @override
  String get income => '수입';

  @override
  String get expense => '지출';

  @override
  String get thisAccountHoldsInvestments => '이 계좌는 투자 자산을 보유합니다';

  @override
  String get thisAccountHoldsInvestmentsSubtitle =>
      '현금에 매수·매도·배당금으로 기록하는 보유 종목을 더한 것입니다.';

  @override
  String get thisIsACreditCard => '이것은 신용카드입니다';

  @override
  String get openingBalanceOptional => '기초 잔액 (선택)';

  @override
  String get currencyIso => '통화 (ISO 4217)';

  @override
  String get currencyIsoExample => '통화 (ISO 4217, 예: USD)';

  @override
  String get hideAccountTitle => '새 항목에서 이 계좌를 숨길까요?';

  @override
  String get hideCategoryTitle => '새 항목에서 이 분류를 숨길까요?';

  @override
  String get hideGroupTitle => '새 항목에서 이 그룹을 숨길까요?';

  @override
  String get reassignGroup => '그룹 재지정';

  @override
  String get transferRemainingBalance => '남은 잔액 이체';

  @override
  String get monthlyLimit => '월 한도';

  @override
  String get monthlyLimitHint => '한도 (비워두면 해제)';

  @override
  String get monthlyLimitBlurb => '이 지출 분류에 대한 이번 달 누적 지출 가이드로, 선택 사항입니다.';

  @override
  String get manageCategoryRules => '분류 규칙 관리';

  @override
  String get amount => '금액';

  @override
  String get category => '분류';

  @override
  String get account => '계좌';

  @override
  String get fromAccount => '출금 계좌';

  @override
  String get toAccount => '입금 계좌';

  @override
  String get descriptionOptional => '설명 (선택)';

  @override
  String get alsoRememberPayee => '수취인으로도 저장';

  @override
  String get splitIntoCategories => '여러 분류로 나누기';

  @override
  String categoryN(String n) {
    return '분류 $n';
  }

  @override
  String get destinationAmount => '도착 금액';

  @override
  String get destinationAmountOptional => '도착 금액 (선택)';

  @override
  String get accountCurrencyAmountOptional => '계좌 통화 금액 (선택)';

  @override
  String get transactionCurrencyOptional => '거래 통화 (선택)';

  @override
  String get feeOptional => '수수료 (선택)';

  @override
  String get feeAmount => '수수료 금액';

  @override
  String get feeCategory => '수수료 분류';

  @override
  String get feeDescriptionOptional => '수수료 설명 (선택)';

  @override
  String get feeDeducted => '수수료는 위 금액에서 차감됩니다';

  @override
  String get needTwoAccountsToTransfer => '이체하려면 활성 계좌가 최소 두 개 필요합니다.';

  @override
  String get whatArrivedTitle => '무엇이 도착했나요?';

  @override
  String get whatArrivedBlurb => '실제로 도착한 금액을 알려주세요.';

  @override
  String get amountThatArrived => '도착한 금액';

  @override
  String get feeLossCategory => '수수료/손실 분류';

  @override
  String get alreadySettled => '이미 정산되었습니다.';

  @override
  String get holdingsTitle => '보유 종목';

  @override
  String get holdingsCash => '현금';

  @override
  String get holdingsInventory => '보유 자산';

  @override
  String holdingsBook(String amount, String currency) {
    return '장부가 (현금 + 취득원가) $amount $currency';
  }

  @override
  String holdingsMarketEstimate(String amount, String currency) {
    return '시장 추정가 $amount $currency';
  }

  @override
  String get holdingsNoHoldings => '아직 보유 종목이 없습니다. 매수를 기록하여 종목을 추가하세요.';

  @override
  String get holdingsQuotesBlurb =>
      '시세는 추정치이며 증권사 가격이 아닙니다. 이 앱은 주문을 실행하지 않습니다.';

  @override
  String get holdingsTapNameToResearch =>
      '이름을 탭하여 리서치하세요. 시세는 추정치이며 투자 조언이 아닙니다.';

  @override
  String get instrument => '종목';

  @override
  String get newInstrument => '새 종목';

  @override
  String get renameInstrument => '종목 이름 변경';

  @override
  String get instrumentActions => '종목 작업';

  @override
  String hideInstrumentTitle(String name) {
    return '$name을(를) 숨길까요?';
  }

  @override
  String get tickerOptional => '티커 (선택)';

  @override
  String get isinOptional => 'ISIN (선택)';

  @override
  String get quantity => '수량';

  @override
  String get unitPrice => '단가';

  @override
  String get brokerageOptional => '수수료 (선택)';

  @override
  String get brokerageExpenseCategory => '매매 수수료 분류';

  @override
  String get incomeCategory => '수입 분류';

  @override
  String get gainIncomeCategory => '이익 수입 분류';

  @override
  String get lossExpenseCategory => '손실 지출 분류';

  @override
  String get nonCash => '비현금';

  @override
  String get cash => '현금';

  @override
  String get locked => '잠김';

  @override
  String get lockUntilHint => '증권사 규칙이 아닌, 본인이 남기는 제한 메모입니다.';

  @override
  String get instrumentKindStock => '주식';

  @override
  String get instrumentKindEtf => 'ETF';

  @override
  String get instrumentKindMutualFund => '뮤추얼 펀드';

  @override
  String get instrumentKindBond => '채권';

  @override
  String get instrumentKindOther => '기타';

  @override
  String get quoteUseLive => '실시간 가격';

  @override
  String get quoteUseCached => '캐시된 가격';

  @override
  String get quoteUseStale => '오래된 가격';

  @override
  String get quoteUseMissing => '취득원가 사용 (가격 없음)';

  @override
  String get quoteUseDisabled => '시세 꺼짐 — 취득원가/캐시 사용';

  @override
  String get quoteUseCurrencyMismatch => '취득원가 사용 (가격 통화가 다름)';

  @override
  String unrealizedLabel(String amount, String currency) {
    return '미실현 $amount $currency';
  }

  @override
  String holdingsUnitsCost(String qty) {
    return '$qty 주 · ';
  }

  @override
  String get recoveryPhraseTitle => '복구 구문';

  @override
  String get recoveryPhraseConfirmTitle => '구문 확인';

  @override
  String get recoveryPhraseBlurb =>
      '이 24개의 단어는 이 기기를 분실, 초기화 또는 교체했을 때 거래 내역을 복구할 수 있는 유일한 방법입니다. Smara 회계는 서버가 없으며 이를 대신 복구해 드릴 수 없습니다.\n\n이 기기와 이 구문을 함께 잃어버리면 지금까지 기록한 모든 거래를 영구적으로 검증할 수 없게 됩니다.';

  @override
  String get recoveryPhraseWriteDown =>
      '이 단어들을 순서대로 적어 이 기기와 분리된 안전한 곳에 보관하세요.';

  @override
  String get iveSavedRecoveryPhrase => '복구 구문을 저장했습니다';

  @override
  String get confirmPhraseBlurb => '방금 저장한 구문에서 요청된 단어를 입력하세요.';

  @override
  String wordNumber(String n) {
    return '단어 #$n';
  }

  @override
  String get keystoreExportTitle => '키스토어 파일 내보내기';

  @override
  String get keystoreExportBlurb =>
      '복구 구문 외에도, 직접 정한 암호로 보호되는 암호화된 키스토어 파일을 저장할 수 있습니다. 이는 선택 사항입니다 — 복구 구문만으로도 항상 서명 키를 복원하기에 충분합니다.';

  @override
  String get keystorePassphrase => '암호';

  @override
  String get exportKeystoreFile => '키스토어 파일 내보내기';

  @override
  String get chooseCurrencyTitle => '통화 선택';

  @override
  String get chooseCurrencyBlurb =>
      '현재 모든 계좌 그룹(현금 및 현금성 자산, 연금 및 퇴직 등)은 이 하나의 통화를 사용합니다. 나중에 새 그룹을 만들어 다른 통화의 계좌를 추가할 수 있습니다.';

  @override
  String get currencyBackfillTitle => '기존 그룹의 통화 선택';

  @override
  String get currencyBackfillBlurb =>
      '이 앱은 이제 여러 통화를 지원합니다. 기존 계좌와 계좌 그룹은 이 기능이 있기 전에 설정되었으므로 통화가 필요하며 — 모두에 동일한 선택이 적용됩니다.';

  @override
  String get firstAccountTitle => '계좌 이름 지정';

  @override
  String get firstAccountBlurb =>
      '이미 설정된 계좌입니다 — 은행처럼 알아볼 수 있는 이름을 지정하세요. 다음으로 지출 또는 수입을 하나 기록한 뒤 복구 구문으로 기기를 보호합니다.';

  @override
  String get whatsMainAccountCalled => '주 계좌의 이름은 무엇인가요?';

  @override
  String get restoreTitle => '서명 키 복원';

  @override
  String get restoreBlurb =>
      '이 기기에는 기존 장부가 있지만 일치하는 서명 키가 없습니다. 저장된 복구 구문이나 키스토어 파일로 복원하세요 — 데이터는 정상적으로 검증되며, 다시 서명되거나 변경되지 않습니다.';

  @override
  String get recoveryPhrase24 => '복구 구문 (24개 단어 전체)';

  @override
  String get keystoreFile => '키스토어 파일';

  @override
  String get keystoreFileContents => '키스토어 파일 내용';

  @override
  String get optionalBackupFile => '선택적 백업 파일';

  @override
  String get iDontHavePhrase => '복구 구문이나 키스토어 파일이 없습니다';

  @override
  String get migrationTitle => '새 키로 마이그레이션';

  @override
  String get migrationBlurb =>
      '복구 구문이나 키스토어 파일이 없으면 이 기기의 서명 키를 복구할 수 없습니다. 새 키를 시작할 수 있습니다. 기존 항목은 계속 표시되지만 대체됨으로 표시됩니다.';

  @override
  String get iConfirmBooksValid => '현재 장부가 유효함을 확인합니다';

  @override
  String get whyWeDontEdit => '기존 항목을 수정하지 않는 이유';

  @override
  String get whyWeDontEditBody =>
      '실수를 바로잡을 때 이미 입력한 내용을 바꾸는 대신 기존 줄은 그대로 두고 그 옆에 정정 항목을 추가합니다. 이렇게 하면 이력이 항상 실제로 일어난 일과 언제 수정했는지를 정확히 보여주며, 뒤에서 몰래 바뀌는 일이 없습니다.';

  @override
  String get lockTitle => '잠금 해제';

  @override
  String get lockScreenTitle => '잠김';

  @override
  String get enterPinToContinue => '계속하려면 PIN을 입력하세요';

  @override
  String get pinLabel => 'PIN';

  @override
  String get setPinTitle => 'PIN 설정';

  @override
  String get currentPin => '현재 PIN';

  @override
  String get newPin => '새 PIN';

  @override
  String get confirmPin => 'PIN 확인';

  @override
  String get confirmNewPin => '새 PIN 확인';

  @override
  String get firstWeekTitle => '계좌 설정';

  @override
  String get addCashAccount => '현금 계좌 추가';

  @override
  String get addCreditCard => '신용카드 추가';

  @override
  String get cashAccountName => '현금 계좌 이름';

  @override
  String get cardName => '카드 이름';

  @override
  String get paidFromBank => '은행에서 결제';

  @override
  String get paidFromCard => '카드로 결제';

  @override
  String get choosePassphraseTitle => '이 백업을 보호할 암호를 선택하세요. 잊어버리면 복구할 수 없습니다.';

  @override
  String get replaceBooksTitle => '로컬 장부를 교체할까요?';

  @override
  String get replaceBooksBody =>
      '이 앱에 현재 있는 모든 내용을 백업으로 교체합니다. 완료 후 앱을 종료했다가 다시 여세요.';

  @override
  String get chooseBackupFileFirst => '먼저 백업 파일을 선택하세요.';

  @override
  String get backupRestored => '백업이 복원되었습니다';

  @override
  String get backupRestoredBody => '장부가 복원되었습니다. 계속하려면 앱을 종료했다가 다시 여세요.';

  @override
  String get fixThisEntry => '이 항목 수정';

  @override
  String get fixBlurb => '기존 줄은 그대로 유지됩니다. 확인하면 정정 줄과 수정된 줄이 추가됩니다.';

  @override
  String get importStatementTitle => '명세서 가져오기';

  @override
  String get importOfx => 'OFX 가져오기';

  @override
  String get importOfxQfxFile => 'OFX / QFX 파일 가져오기';

  @override
  String get importCsvFile => 'CSV 파일 가져오기';

  @override
  String get whatKindOfStatement => '어떤 종류의 명세서 파일을 가지고 계신가요?';

  @override
  String get chooseAccountForFile => '이 파일이 속한 계좌를 선택하세요.';

  @override
  String get importIntoAccount => '가져올 계좌';

  @override
  String get useSavedProfile => '저장된 프로필 사용';

  @override
  String get saveMappingProfile => '이 매핑을 프로필로 저장 (선택)';

  @override
  String get renameProfile => '프로필 이름 변경';

  @override
  String get deleteProfileTitle => '프로필을 삭제할까요?';

  @override
  String get fileHasHeader => '파일에 머리글 행이 있음';

  @override
  String get dateColumn => '날짜 열';

  @override
  String get dateFormatHint => '날짜 형식 (예: dd/MM/yyyy)';

  @override
  String get amountColumn => '금액 열';

  @override
  String get amountConvention => '금액 표기 방식';

  @override
  String get signedAmountColumn => '부호 있는 금액 열';

  @override
  String get separateDebitCredit => '차변/대변 열 구분';

  @override
  String get debitColumn => '차변 열';

  @override
  String get creditColumn => '대변 열';

  @override
  String get decimalSeparator => '소수점 구분 기호 (. 또는 ,)';

  @override
  String get descriptionColumns => '설명 열';

  @override
  String get referenceIdColumn => '참조 ID 열 (선택)';

  @override
  String get skippedRows => '건너뛴 행';

  @override
  String parsedTransactionCount(String count) {
    return '$count건의 거래를 분석했습니다';
  }

  @override
  String skippedOrExcludedCount(String count) {
    return '$count건 건너뜀 또는 제외됨';
  }

  @override
  String postedFailedCount(String posted, String failed) {
    return '$posted건 등록, $failed건 실패';
  }

  @override
  String get categoryForAll => '전체에 적용할 분류';

  @override
  String get saveAsRule => '규칙으로 저장할까요?';

  @override
  String get saveAsRuleBlurb => '설명에 이 키워드가 포함된 향후 가져오기는 이 분류를 사용합니다.';

  @override
  String get keyword => '키워드';

  @override
  String get noSavedRules => '아직 저장된 규칙이 없습니다. 행 그룹에 분류를 지정하면 규칙으로 저장됩니다.';

  @override
  String get deleteRuleTitle => '규칙을 삭제할까요?';

  @override
  String get editRule => '규칙 편집';

  @override
  String rowsGrouped(String count) {
    return '$count개 행';
  }

  @override
  String selectStatementFile(String extensions) {
    return '가져올 $extensions 명세서 파일을 선택하세요';
  }

  @override
  String get payeesTitle => '수취인';

  @override
  String get addPayee => '수취인 추가';

  @override
  String get renamePayee => '수취인 이름 변경';

  @override
  String get deletePayeeTitle => '수취인을 삭제할까요?';

  @override
  String get noPayeesYet => '아직 수취인이 없습니다';

  @override
  String get recurringTitle => '정기 템플릿';

  @override
  String get noRecurringYet => '아직 정기 템플릿이 없습니다';

  @override
  String get deleteTemplateTitle => '정기 템플릿을 삭제할까요?';

  @override
  String get dayOfMonth => '매월 일자 (1-31)';

  @override
  String get dayOfMonthNote => '일수가 적은 달에는 해당 달의 마지막 날을 사용합니다.';

  @override
  String dayOfMonthLine(String day) {
    return '매월 $day일 - ';
  }

  @override
  String get name => '이름';

  @override
  String get none => '없음';

  @override
  String get currency => '통화';

  @override
  String get errorGeneric => '문제가 발생했습니다. 다시 시도하세요.';

  @override
  String get errorSigningIdentityMismatch =>
      '이 복구 구문 또는 키스토어 파일은 이 데이터베이스의 서명 신원과 일치하지 않습니다.';

  @override
  String get errorInvalidLedgerBackup => '이 파일은 유효한 Smara 백업이 아닙니다.';

  @override
  String get errorInvalidLedgerBackupNoIdentity =>
      '이 백업에는 서명 신원이 없습니다 - 유효한 Smara 백업이 아닙니다.';

  @override
  String get errorInvalidLedgerBackupUnverified =>
      '이 백업은 온전한 장부로 검증되지 않아 복원되지 않았습니다.';

  @override
  String errorInvalidLedgerBackupUnreadable(String detail) {
    return '이 파일을 Smara 백업으로 열 수 없습니다: $detail';
  }

  @override
  String get errorForeignBackupIdentity => '이 백업은 이 기기의 서명 신원과 다른 신원에 속합니다.';

  @override
  String get errorAccountNotFinancial => '이는 재무 계좌가 아닙니다.';

  @override
  String get errorAccountArchived => '그 계좌는 숨겨져 있습니다.';

  @override
  String get errorAccountNotArchived => '그 계좌는 숨겨져 있지 않습니다.';

  @override
  String get errorAccountNoPositiveBalanceToCloseOut => '이체할 남은 잔액이 없습니다.';

  @override
  String get errorAccountHasNoGroup => '그 계좌에는 지정된 그룹이 없습니다.';

  @override
  String get errorGroupHasNoCurrency => '그 그룹에는 아직 통화가 설정되지 않았습니다.';

  @override
  String get errorGroupNotFound => '그 계좌 그룹을 찾을 수 없습니다.';

  @override
  String get errorInvestmentAccountsMustBeAssets => '자산 계좌만 투자 계좌로 지정할 수 있습니다.';

  @override
  String get errorCreditCardsMustBeLiabilities => '부채 계좌만 신용카드로 지정할 수 있습니다.';

  @override
  String get errorOpeningBalanceMustBePositive => '기초 잔액을 입력하는 경우 양수여야 합니다.';

  @override
  String get errorAccountTypeDoesNotMatchGroup => '그 계좌 유형은 그룹과 일치하지 않습니다.';

  @override
  String get errorLastActiveAccount => '마지막 활성 재무 계좌는 숨길 수 없습니다.';

  @override
  String get errorCurrencyRequiredToCreateGroup => '그룹을 만들려면 통화가 필요합니다.';

  @override
  String get errorSystemGroupCannotBeArchived => '기본 제공 계좌 그룹은 숨길 수 없습니다.';

  @override
  String get errorGroupAlreadyArchived => '그 그룹은 이미 숨겨져 있습니다.';

  @override
  String get errorCannotArchiveGroupWithAccounts => '활성 계좌가 있는 그룹은 숨길 수 없습니다.';

  @override
  String get errorSystemGroupNeverArchived => '기본 제공 계좌 그룹은 결코 숨겨지지 않습니다.';

  @override
  String get errorAccountGroupsCannotBeDeleted => '계좌 그룹은 삭제할 수 없습니다.';

  @override
  String get errorCannotReassignDifferentCurrency =>
      '이 계좌를 다른 통화의 그룹으로 옮길 수 없습니다.';

  @override
  String get errorCannotChangeGroupCurrencyWithAccounts =>
      '그룹에 활성 계좌가 있는 동안에는 통화를 변경할 수 없습니다.';

  @override
  String get errorAmountMustBePositive => '금액은 양수여야 합니다.';

  @override
  String get errorAccountCurrencyAmountMustBePositive => '계좌 통화 금액은 양수여야 합니다.';

  @override
  String get errorAccountCurrencyAmountNotForSameCurrency =>
      '계좌 통화 금액은 외화 항목에만 사용됩니다.';

  @override
  String get errorSplitNeedsTwoLines => '분할하려면 분류 항목이 최소 두 개 필요합니다.';

  @override
  String get errorSplitLineMustBePositive => '각 분할 항목은 양수 금액이어야 합니다.';

  @override
  String get errorSplitLinesMustSumToTotal => '분할 항목의 합계는 거래 총액과 일치해야 합니다.';

  @override
  String get errorTransferAmountMustBePositive => '이체 금액은 양수여야 합니다.';

  @override
  String get errorTransferAccountsMustDiffer => '출발 계좌와 도착 계좌는 서로 달라야 합니다.';

  @override
  String get errorCloseoutRequiresDestinationAmount =>
      '외화 청산에는 알려진 도착 금액이 필요합니다.';

  @override
  String get errorDestinationAmountNotForSameCurrency =>
      '도착 금액은 외화 이체에만 사용됩니다.';

  @override
  String get errorDestinationAmountMustBePositive => '도착 금액은 양수여야 합니다.';

  @override
  String get errorInvestmentCashExceeded => '이 투자 계좌의 현금보다 많이 이체할 수 없습니다.';

  @override
  String get errorCannotReverseUnsettledProvisional =>
      '이 대기 중인 이체는 취소하는 대신 정산하세요.';

  @override
  String get errorAlreadyReversed => '이 항목은 이미 정정되었습니다. 원본 줄은 그대로 유지됩니다.';

  @override
  String get errorNotActiveExpenseCategory => '활성 지출 분류를 선택하세요.';

  @override
  String get errorNotActiveIncomeCategory => '활성 수입 분류를 선택하세요.';

  @override
  String get errorSettledAmountMustNotBeNegative => '도착한 금액은 음수일 수 없습니다.';

  @override
  String get errorPendingTransferNotFound => '그 대기 중인 이체를 찾을 수 없습니다.';

  @override
  String get errorPendingTransferAlreadySettled => '그 대기 중인 이체는 이미 정산되었습니다.';

  @override
  String get errorSettledToMustBeSourceOrDestination =>
      '원래의 출발 또는 도착 계좌를 선택하세요.';

  @override
  String get errorFeeCategoryOnlyWhenReturningToSource =>
      '수수료 분류는 자금이 출발 계좌로 반환될 때만 사용됩니다.';

  @override
  String get errorSettledAmountMustBePositiveForDelivery =>
      '도착한 금액에 양수를 입력하세요.';

  @override
  String get errorSettledAmountExceedsProvisional => '그 금액은 보낸 금액보다 많습니다.';

  @override
  String get errorInstrumentNotFound => '그 종목을 찾을 수 없습니다.';

  @override
  String get errorIncomeRequiredForNonCash => '비현금 취득에는 활성 수입 분류가 필요합니다.';

  @override
  String get errorInsufficientCash => '이 투자 계좌에 그 매수를 위한 현금이 부족합니다.';

  @override
  String get errorSellQuantityAndPriceMustBePositive => '매도 수량과 단가는 양수여야 합니다.';

  @override
  String errorLockedUntil(String date) {
    return '매도할 수 없습니다: 일부 수량이 $date까지 잠겨 있습니다.';
  }

  @override
  String get errorInsufficientQuantity => '현재 잠기지 않은 보유 수량보다 많이 매도할 수 없습니다.';

  @override
  String get errorIncomeRequiredForGain => '실현 이익에는 활성 수입 분류가 필요합니다.';

  @override
  String get errorExpenseRequiredForLoss => '실현 손실에는 활성 지출 분류가 필요합니다.';

  @override
  String errorBrokerageFailedAfterBuy(String detail) {
    return '매수는 등록되었지만 수수료 처리에 실패했습니다: $detail';
  }

  @override
  String errorBrokerageFailedAfterSell(String detail) {
    return '매도는 등록되었지만 수수료 처리에 실패했습니다: $detail';
  }

  @override
  String get errorDividendMustBePositive => '배당금 금액은 양수여야 합니다.';

  @override
  String get errorNotInvestmentAccount => '이는 투자 계좌가 아닙니다.';

  @override
  String get errorNoInventoryCompanion => '이 투자 계좌에는 연결된 보유 자산 계좌가 없습니다.';

  @override
  String errorInvestmentReversalBlocked(String sells) {
    return '이 매수를 취소할 수 없습니다: 이후 매도 건이 이 수량에 의존합니다. 종속된 매도($sells)를 먼저 취소하세요.';
  }

  @override
  String get errorMonthlyLimitMustBePositive => '월 한도는 양수여야 합니다.';

  @override
  String get errorTemplateAmountMustBePositive => '템플릿 금액은 양수여야 합니다.';

  @override
  String get errorOfxUnrecognized => '이 파일을 OFX로 인식할 수 없습니다.';

  @override
  String get errorCsvEmpty => '선택한 파일이 비어 있습니다.';

  @override
  String get errorCsvUnreadable => '이 파일을 CSV로 읽을 수 없습니다.';

  @override
  String get errorCsvNoRows => '선택한 파일에 행이 없습니다.';

  @override
  String errorBackupCreateFailed(String detail) {
    return '백업을 만들 수 없습니다: $detail';
  }

  @override
  String get errorBackupRestoreFailed =>
      '이 백업을 복원할 수 없습니다 - 암호가 틀렸거나 Smara 백업 파일이 아닙니다.';

  @override
  String get validationAmountAccountCategoryRequired => '금액, 계좌, 분류가 필요합니다.';

  @override
  String get validationAmountAccountRequired => '금액과 계좌가 필요합니다.';

  @override
  String get validationSplitLineIncomplete => '모든 분할 항목에는 분류와 금액이 필요합니다.';

  @override
  String get validationSplitSumMismatch => '분할 항목의 합계는 거래 총액과 일치해야 합니다.';

  @override
  String get validationFromToAmountRequired => '출발 계좌, 도착 계좌, 금액이 필요합니다.';

  @override
  String get validationAmountArrivedRequired => '도착한 금액이 필요합니다.';

  @override
  String get validationChooseReceivingAccount => '자금을 받은 계좌를 선택하세요.';

  @override
  String get validationAccountCategoryRequired => '계좌와 분류가 필요합니다.';

  @override
  String get validationFixFailed => '이 수정 사항을 저장할 수 없습니다.';

  @override
  String get validationNameRequired => '주 계좌의 이름을 지정하세요.';

  @override
  String get validationStillLoading => '아직 불러오는 중입니다 - 잠시 후 다시 시도하세요.';

  @override
  String get validationSaveAccountNameFailed => '계좌 이름을 저장할 수 없습니다.';

  @override
  String get validationWrongPin => 'PIN이 올바르지 않습니다. 다시 시도하세요.';

  @override
  String get validationCategoryMustBeIncomeOrExpense => '분류는 수입 또는 지출이어야 합니다.';

  @override
  String get validationOnlyExpenseHasMonthlyLimit => '지출 분류만 월 한도를 가질 수 있습니다.';

  @override
  String get validationInvalidTemplate => '유효하지 않은 템플릿입니다.';

  @override
  String get validationWrongKeystorePassphrase => '이 키스토어 파일의 암호가 틀렸습니다.';

  @override
  String get validationInvalidKeystoreFile => '유효한 키스토어 파일이 아닌 것 같습니다.';

  @override
  String get validationRestorePhraseFailed => '그 복구 구문으로 복원할 수 없습니다.';

  @override
  String validationGenerateKeyFailed(String detail) {
    return '이 기기에서 서명 키를 생성할 수 없습니다: $detail';
  }

  @override
  String validationSaveCurrencyFailed(String detail) {
    return '이 통화를 저장할 수 없습니다: $detail';
  }

  @override
  String get validationMigrationFailed => '마이그레이션에 실패했습니다. 다시 시도하세요.';

  @override
  String get validationChooseBackupFile => '먼저 백업 파일을 선택하세요.';

  @override
  String get validationPassphraseRequired => '암호를 입력하세요.';

  @override
  String get validationPinsDoNotMatch => '두 PIN이 일치하지 않습니다.';

  @override
  String get validationFeePositiveWithCategory =>
      '이체 수수료는 양수 금액이어야 하며 지출 분류가 선택되어야 합니다.';

  @override
  String get validationFeeMustBeLessThanAmount =>
      '차감 방식 이체에서 수수료는 금액보다 작아야 합니다.';

  @override
  String validationTransferSavedFeeFailed(String detail) {
    return '이체는 저장되었지만 수수료를 기록할 수 없습니다: $detail';
  }

  @override
  String get validationEnterValidAmount => '유효한 금액을 입력하세요.';

  @override
  String validationConfirmWordMismatch(String n) {
    return '단어 $n이(가) 저장된 구문과 일치하지 않습니다. 확인 후 다시 시도하세요.';
  }

  @override
  String get errorBuyQuantityAndPriceMustBePositive => '매수 수량과 단가는 양수여야 합니다.';

  @override
  String get errorInstrumentArchived => '숨겨진 종목은 매수할 수 없습니다.';

  @override
  String get errorNonCashCannotIncludeBrokerage =>
      '비현금 취득에는 매매 수수료를 포함할 수 없습니다.';

  @override
  String get errorBrokerageRequiresExpenseCategory =>
      '매매 수수료가 양수인 경우 활성 지출 분류가 필요합니다.';

  @override
  String get errorSellProceedsMustCoverBrokerage =>
      '매도 대금은 최소한 매매 수수료 금액 이상이어야 합니다.';

  @override
  String homeSpentOfLimitThisMonth(String spent, String limit) {
    return '이번 달 $limit 중 $spent 지출';
  }

  @override
  String get unlockBiometricReason => 'Smara 회계 잠금 해제';

  @override
  String get searchLabel => '검색';

  @override
  String get openingBalance => '기초 잔액';

  @override
  String transferToName(String name) {
    return '이체: $name';
  }

  @override
  String get feeForTransfer => '이체 수수료';

  @override
  String feeForTransferTo(String name) {
    return '$name(으)로의 이체 수수료';
  }

  @override
  String couldNotOpenFilePicker(String detail) {
    return '파일 선택기를 열 수 없습니다: $detail';
  }

  @override
  String pleaseSelectFile(String extensions) {
    return '.$extensions 파일을 선택하세요';
  }

  @override
  String get currencyCodeIso => '통화 코드 (ISO 4217, 예: USD)';

  @override
  String splitCounterpartMore(String name, String count) {
    return '$name 외 $count건';
  }

  @override
  String get dateLabel => '날짜';

  @override
  String get noneSelected => '없음';

  @override
  String reviewEntriesBeforeContinuing(String count) {
    return '계속하기 전에 아래 항목($count건)을 검토하세요.';
  }

  @override
  String youReceived(String amount) {
    return '$amount을(를) 받았습니다';
  }

  @override
  String get leaveBlankIfRateUnknown => '환율을 아직 모른다면 비워두세요.';

  @override
  String get recordTradeBlurb => '이미 발생한 거래를 기록합니다. 이 앱은 주문을 실행하지 않습니다.';

  @override
  String get feeOnTopBlurb => '포함: 위 금액은 이 계좌에서 차감되는 총액이며, 수수료는 그 안에서 공제됩니다.';

  @override
  String get feeBankBlurb => '은행이나 중개기관이 선불로 청구하는 수수료입니다.';

  @override
  String get validationPinMinLength => 'PIN은 최소 4자리여야 합니다.';

  @override
  String get restoreBackupBlurb =>
      '이 앱에 현재 있는 모든 내용을 백업으로 교체합니다 — 병합되지 않습니다. 백업 파일을 선택하고 보호에 사용한 암호를 입력하세요.';

  @override
  String get actionReplace => '교체';

  @override
  String hideAccountBody(String name) {
    return '$name은(는) 더 이상 새 거래에 사용할 수 없게 됩니다.';
  }

  @override
  String hideGroupBody(String name) {
    return '$name은(는) 계좌를 만들거나 재지정할 때 더 이상 제공되지 않습니다.';
  }

  @override
  String hideCategoryBody(String name) {
    return '$name은(는) 새 거래를 기록할 때 더 이상 제공되지 않습니다.';
  }

  @override
  String get hideInstrumentBody =>
      '숨겨진 종목은 과거 매수·매도 내역에 남아 있습니다. 배당금은 계속 기록할 수 있습니다.';

  @override
  String nameHidden(String name) {
    return '$name (숨김)';
  }

  @override
  String get noCurrencySet => '설정된 통화 없음';

  @override
  String deletePayeeBody(String name) {
    return '$name과(와) 그 기본 설정이 삭제됩니다. 과거 거래에는 영향이 없습니다.';
  }

  @override
  String deleteTemplateBody(String name) {
    return '$name은(는) 더 이상 예정 항목으로 제공되지 않습니다. 이미 기록된 과거 거래에는 영향이 없습니다.';
  }

  @override
  String deleteProfileBody(String name) {
    return '저장된 열 매핑 \"$name\"이(가) 삭제됩니다. 이미 이 매핑으로 가져온 명세서에는 영향이 없습니다.';
  }

  @override
  String deleteRuleBody(String keyword) {
    return '가져오기 시 더 이상 \"$keyword\"(으)로 자동 분류되지 않습니다. 이 규칙으로 이미 분류된 거래에는 영향이 없습니다.';
  }

  @override
  String get firstWeekBlurb =>
      '지금 신용카드나 현금 계좌를 선택적으로 추가할 수 있습니다 - 나중에 설정에서 언제든 계좌를 더 추가할 수 있습니다.';

  @override
  String get deliveredToDestination => '도착 계좌로 전달됨';

  @override
  String deliveredToName(String name) {
    return '$name(으)로 전달됨';
  }

  @override
  String youReceivedLessThanExpected(String amount, String currency) {
    return '예상보다 $amount $currency 적게 받았습니다 - 차액을 처리할 분류를 선택하세요.';
  }

  @override
  String get dateRangeLabel => '날짜 범위';

  @override
  String get addTemplate => '템플릿 추가';

  @override
  String get editTemplate => '템플릿 편집';

  @override
  String get validationFillTemplateFields => '모든 필드에 유효한 금액과 날짜를 입력하세요.';

  @override
  String get saveCsvExport => 'CSV 내보내기 저장';

  @override
  String get referenceRate => '참고 환율';

  @override
  String get yourRate => '적용 환율';

  @override
  String leaveBlankIfThisWasAccountCurrency(String currency) {
    return '이 거래가 계좌 고유 통화인 $currency였다면 비워두세요.';
  }

  @override
  String get lockUntilOptional => '잠금 해제일 (선택)';

  @override
  String lockedUntilDate(String date) {
    return '$date까지 잠김';
  }

  @override
  String get copiedResearchPrompt =>
      '리서치 프롬프트를 복사했습니다 — 사용 가능한 브라우저 URL이 없거나 오프라인 상태입니다.';

  @override
  String get openedFavouriteResearchTool => '즐겨찾는 리서치 도구를 열었습니다.';

  @override
  String get looksLikeGain => '이익으로 보입니다';

  @override
  String get looksLikeLoss => '손실로 보입니다';

  @override
  String get looksLikeBreakEven => '손익 없음으로 보입니다';

  @override
  String sellableQuantity(String name, String qty) {
    return '$name (매도 가능 $qty)';
  }

  @override
  String columnN(String index) {
    return '열 $index';
  }

  @override
  String get importingLabel => '가져오는 중...';

  @override
  String get confirmImport => '가져오기 확인';

  @override
  String get manageSavedCategoryRules => '저장된 분류 규칙 관리';

  @override
  String statementCurrencyMismatch(String currency) {
    return '이 파일의 통화($currency)가 선택한 계좌의 통화와 일치하지 않습니다.';
  }

  @override
  String get categoryRulesTitle => '분류 규칙';

  @override
  String get possibleDuplicate => '중복 가능성';

  @override
  String get unknownCategory => '알 수 없는 분류';
}
