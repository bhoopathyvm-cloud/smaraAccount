// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Sổ kế toán Smara';

  @override
  String get navHome => 'Trang chủ';

  @override
  String get navRegister => 'Sổ';

  @override
  String get navSummary => 'Tóm tắt';

  @override
  String get navAccounts => 'Tài khoản';

  @override
  String get navCategories => 'Danh mục';

  @override
  String get actionCancel => 'Hủy';

  @override
  String get actionSave => 'Lưu';

  @override
  String get actionDelete => 'Xóa';

  @override
  String get actionDone => 'Xong';

  @override
  String get actionContinue => 'Tiếp tục';

  @override
  String get actionDismiss => 'Đóng';

  @override
  String get actionRetry => 'Thử lại';

  @override
  String get actionSkip => 'Bỏ qua';

  @override
  String get actionConfirm => 'Xác nhận';

  @override
  String get actionAdd => 'Thêm';

  @override
  String get actionEdit => 'Sửa';

  @override
  String get actionRename => 'Đổi tên';

  @override
  String get actionHide => 'Ẩn';

  @override
  String get actionCreate => 'Tạo';

  @override
  String get actionCloseApp => 'Đóng ứng dụng';

  @override
  String get actionUnlock => 'Mở khóa';

  @override
  String get actionSettle => 'Quyết toán';

  @override
  String get actionFinish => 'Hoàn tất';

  @override
  String get actionPreview => 'Xem trước';

  @override
  String get actionImport => 'Nhập';

  @override
  String get actionExportCsv => 'Xuất CSV';

  @override
  String get actionChooseFile => 'Chọn tệp';

  @override
  String get actionRestore => 'Khôi phục';

  @override
  String get actionFix => 'Sửa';

  @override
  String get actionBuy => 'Mua';

  @override
  String get actionSell => 'Bán';

  @override
  String get actionDividend => 'Cổ tức';

  @override
  String get actionRecordBuy => 'Ghi nhận giao dịch mua';

  @override
  String get actionRecordSell => 'Ghi nhận giao dịch bán';

  @override
  String get actionRecordDividend => 'Ghi nhận cổ tức';

  @override
  String get actionPayCard => 'Thanh toán thẻ';

  @override
  String get actionTransfer => 'Chuyển khoản';

  @override
  String get actionRecordTransaction => 'Ghi nhận giao dịch';

  @override
  String get actionImportStatement => 'Nhập sao kê';

  @override
  String get actionClearDates => 'Xóa ngày';

  @override
  String get actionClearSearch => 'Xóa tìm kiếm và bộ lọc';

  @override
  String get actionUseBiometrics => 'Dùng sinh trắc học';

  @override
  String get actionSetPin => 'Đặt mã PIN';

  @override
  String get actionChangePin => 'Đổi mã PIN';

  @override
  String get actionSaveBackup => 'Lưu bản sao lưu';

  @override
  String get actionRestoreBackup => 'Khôi phục bản sao lưu';

  @override
  String get actionSaveRule => 'Lưu quy tắc';

  @override
  String get actionConfirmFix => 'Xác nhận sửa';

  @override
  String get captureSpent => 'Chi';

  @override
  String get captureReceived => 'Thu';

  @override
  String get captureMovedMoney => 'Chuyển tiền';

  @override
  String get captureImportStatement => 'Nhập sao kê';

  @override
  String get settingsTitle => 'Cài đặt';

  @override
  String get settingsLanguage => 'Ngôn ngữ';

  @override
  String get settingsLanguageSystem => 'Ngôn ngữ thiết bị';

  @override
  String get settingsFetchFxRates => 'Lấy tỷ giá hối đoái tham khảo';

  @override
  String get settingsFetchFxRatesSubtitle =>
      'Hiển thị tỷ giá thị trường tham khảo bên cạnh số tiền đích trong các giao dịch chuyển khoản khác loại tiền tệ, chỉ để so sánh - không bao giờ dùng để tự điền số tiền.';

  @override
  String get settingsRateProvider => 'Nhà cung cấp tỷ giá';

  @override
  String get settingsFetchMarketPrices => 'Lấy giá thị trường cho khoản đầu tư';

  @override
  String get settingsFetchMarketPricesSubtitle =>
      'Tra cứu giá gần nhất cho các công cụ đầu tư có mã ticker hoặc ISIN, để ước tính giá trị danh mục. Không bao giờ dùng để ghi nhận giao dịch, và không bao giờ gửi đi số lượng bạn đang nắm giữ.';

  @override
  String get settingsMarketPriceProvider => 'Nhà cung cấp giá thị trường';

  @override
  String get settingsFavouriteResearchTool => 'Công cụ nghiên cứu yêu thích';

  @override
  String get settingsFavouriteResearchToolSubtitle =>
      'Chạm vào tên một công cụ đầu tư trong danh mục nắm giữ sẽ mở công cụ này trên trình duyệt kèm gợi ý tra cứu — đây không phải tích hợp, và không phải lời khuyên đầu tư.';

  @override
  String get settingsBackup => 'Sao lưu';

  @override
  String get settingsBackupBlurb =>
      'Lưu một bản sao mã hóa của sổ sách của bạn vào nơi bạn chọn, hoặc khôi phục từ đó. Việc này khác với cụm từ khôi phục hoặc tệp keystore của bạn, vốn sao lưu khóa ký của bạn, chứ không phải sổ sách.';

  @override
  String get settingsLock => 'Khóa';

  @override
  String get settingsLockBlurb =>
      'Yêu cầu mã PIN, hoặc sinh trắc học nếu có, để mở ứng dụng.';

  @override
  String get settingsRequireUnlock => 'Yêu cầu mở khóa để vào ứng dụng';

  @override
  String get settingsLockAfter => 'Khóa sau';

  @override
  String get settingsLockImmediately => 'Ngay lập tức';

  @override
  String get settingsLock1Minute => '1 phút';

  @override
  String get settingsLock5Minutes => '5 phút';

  @override
  String get settingsLock15Minutes => '15 phút';

  @override
  String get settingsAllowBiometrics => 'Cũng cho phép sinh trắc học';

  @override
  String get settingsHideSnapshot => 'Ẩn số dư trong trình chuyển ứng dụng';

  @override
  String get settingsHideSnapshotSubtitle =>
      'Làm mờ màn hình này khi bạn chuyển sang ứng dụng khác, để nó không hiện ra ngay trong trình chuyển ứng dụng.';

  @override
  String get settingsHideSnapshotUnavailable =>
      'Tính năng ẩn số dư trong trình chuyển ứng dụng không khả dụng trên nền tảng này.';

  @override
  String get settingsPayees => 'Người thụ hưởng';

  @override
  String get settingsManagePayees => 'Quản lý người thụ hưởng';

  @override
  String get settingsPayeesBlurb =>
      'Tên người thụ hưởng đã lưu cùng danh mục và tài khoản mặc định của họ, được gợi ý tự động khi bạn ghi nhận một giao dịch.';

  @override
  String get settingsRecurring => 'Mẫu định kỳ';

  @override
  String get settingsManageRecurring => 'Quản lý mẫu định kỳ';

  @override
  String get settingsRecurringBlurb =>
      'Hóa đơn hoặc thu nhập lặp lại hàng tháng, như tiền thuê nhà hay lương. Một mẫu đến hạn sẽ hiện trên Trang chủ để bạn ghi nhận chỉ với một chạm - không bao giờ tự động ghi sổ.';

  @override
  String get settingsAbout => 'Giới thiệu';

  @override
  String get providerFrankfurter => 'Frankfurter (tỷ giá ECB)';

  @override
  String get providerOpenErApi => 'ExchangeRate-API (open.er-api.com)';

  @override
  String get providerStooq => 'Stooq (báo giá hàng ngày)';

  @override
  String get providerYahooFinance => 'Yahoo Finance (API biểu đồ)';

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
      'Tiền mặt và các khoản tương đương tiền';

  @override
  String get systemGroupPensionRetirement => 'Lương hưu và hưu trí';

  @override
  String get systemGroupCreditShortTerm => 'Tín dụng và nợ ngắn hạn';

  @override
  String get systemGroupLoansMortgages => 'Khoản vay và thế chấp';

  @override
  String get systemGroupInvestments => 'Đầu tư';

  @override
  String get systemAccountCashBank => 'Tiền mặt & Ngân hàng';

  @override
  String get systemCategorySalary => 'Lương';

  @override
  String get systemCategoryOtherIncome => 'Thu nhập khác';

  @override
  String get systemCategoryGroceries => 'Hàng tạp hóa';

  @override
  String get systemCategoryRentMortgage => 'Tiền thuê/Thế chấp';

  @override
  String get systemCategoryUtilities => 'Tiện ích';

  @override
  String get systemCategoryTransport => 'Đi lại';

  @override
  String get systemCategoryFoodOut => 'Ăn ngoài';

  @override
  String get systemCategoryPhone => 'Điện thoại';

  @override
  String get systemCategoryHealth => 'Sức khỏe';

  @override
  String get systemCategoryOtherExpense => 'Chi phí khác';

  @override
  String get homeThisMonth => 'THÁNG NÀY';

  @override
  String get homeMoneyInTransit => 'TIỀN ĐANG CHUYỂN';

  @override
  String get homeWhatYouHaveMinusWhatYouOwe =>
      'NHỮNG GÌ BẠN CÓ TRỪ NHỮNG GÌ BẠN NỢ';

  @override
  String homeWhatYouHave(String amount, String currency) {
    return 'Số bạn có $amount $currency';
  }

  @override
  String homeNetPosition(String amount, String currency) {
    return '$amount $currency';
  }

  @override
  String homeHaveAndOwe(String haveAmount, String currency, String oweAmount) {
    return 'Số bạn có $haveAmount $currency  •  Số bạn nợ $oweAmount $currency';
  }

  @override
  String youSentFrom(String amount, String currency, String name) {
    return 'Bạn đã gửi $amount $currency từ $name';
  }

  @override
  String youSentTo(String amount, String currency, String name) {
    return 'Bạn đã gửi $amount $currency đến $name';
  }

  @override
  String get hiddenLabel => 'Đã ẩn';

  @override
  String get allAccounts => 'Tất cả tài khoản';

  @override
  String savedToPath(String path) {
    return 'Đã lưu vào $path';
  }

  @override
  String get keystoreExportFailed =>
      'Không thể xuất tệp keystore. Bạn có thể bỏ qua bước này.';

  @override
  String get enterPassphraseToProtect =>
      'Nhập một cụm mật khẩu để bảo vệ tệp này.';

  @override
  String get homeTapWhenArrived => 'Chạm khi bạn biết đã nhận được gì';

  @override
  String homeReturnedTo(String name) {
    return 'Đã hoàn về $name';
  }

  @override
  String get homeDueToday => 'ĐẾN HẠN HÔM NAY';

  @override
  String homeDueLine(String category, String account) {
    return '$category · $account · chạm để ghi nhận';
  }

  @override
  String get homeOverLimit => 'Vượt hạn mức';

  @override
  String homeSpentOfLimit(String spent, String limit) {
    return '$spent trên $limit';
  }

  @override
  String homeRemaining(String amount) {
    return 'Còn lại: $amount';
  }

  @override
  String get homeNoAccounts => 'Không có tài khoản';

  @override
  String get homeCashRegister => 'Quỹ tiền mặt';

  @override
  String get homeMarketEstimate => 'Ước tính thị trường';

  @override
  String get registerTitle => 'Sổ';

  @override
  String get registerSearchHint => 'Mô tả, danh mục, hoặc số tiền';

  @override
  String get registerNoTransactions => 'Chưa có giao dịch nào';

  @override
  String get registerNoEntries => 'Chưa có mục nào được ghi nhận.';

  @override
  String get registerSpentOnly => 'Chỉ chi';

  @override
  String get registerReceivedOnly => 'Chỉ thu';

  @override
  String get registerAll => 'Tất cả';

  @override
  String get registerUnverified => 'Chưa xác minh - không tính vào tổng';

  @override
  String get registerSuperseded =>
      'Đã bị thay thế do di chuyển khóa - không tính vào tổng';

  @override
  String get summaryTitle => 'Tóm tắt';

  @override
  String get summaryTotalIncome => 'Tổng thu nhập';

  @override
  String get summaryTotalExpense => 'Tổng chi tiêu';

  @override
  String summaryDateRange(String start, String end) {
    return '$start đến $end';
  }

  @override
  String get accountsTitle => 'Tài khoản';

  @override
  String get categoriesTitle => 'Danh mục';

  @override
  String get accountName => 'Tên tài khoản';

  @override
  String get createAccount => 'Tạo tài khoản';

  @override
  String get createGroup => 'Tạo nhóm';

  @override
  String get editGroup => 'Sửa nhóm';

  @override
  String get renameAccount => 'Đổi tên tài khoản';

  @override
  String get renameCategory => 'Đổi tên danh mục';

  @override
  String get addCategory => 'Thêm danh mục';

  @override
  String get groupLabel => 'Nhóm';

  @override
  String get kindLabel => 'Loại';

  @override
  String get asset => 'Tài sản';

  @override
  String get liability => 'Nợ phải trả';

  @override
  String get income => 'Thu nhập';

  @override
  String get expense => 'Chi tiêu';

  @override
  String get thisAccountHoldsInvestments =>
      'Tài khoản này nắm giữ khoản đầu tư';

  @override
  String get thisAccountHoldsInvestmentsSubtitle =>
      'Tiền mặt cộng với hàng tồn kho đầu tư mà bạn ghi nhận bằng Mua, Bán và Cổ tức.';

  @override
  String get thisIsACreditCard => 'Đây là thẻ tín dụng';

  @override
  String get openingBalanceOptional => 'Số dư đầu kỳ (không bắt buộc)';

  @override
  String get currencyIso => 'Đơn vị tiền tệ (ISO 4217)';

  @override
  String get currencyIsoExample => 'Đơn vị tiền tệ (ISO 4217, ví dụ USD)';

  @override
  String get hideAccountTitle => 'Ẩn tài khoản khỏi các mục mới?';

  @override
  String get hideCategoryTitle => 'Ẩn danh mục khỏi các mục mới?';

  @override
  String get hideGroupTitle => 'Ẩn nhóm khỏi các mục mới?';

  @override
  String get reassignGroup => 'Chuyển sang nhóm khác';

  @override
  String get transferRemainingBalance => 'Chuyển số dư còn lại';

  @override
  String get monthlyLimit => 'Hạn mức hàng tháng';

  @override
  String get monthlyLimitHint => 'Hạn mức (để trống để xóa)';

  @override
  String get monthlyLimitBlurb =>
      'Một mức chi tiêu tham khảo tùy chọn tính từ đầu tháng cho danh mục chi tiêu này.';

  @override
  String get manageCategoryRules => 'Quản lý quy tắc danh mục';

  @override
  String get amount => 'Số tiền';

  @override
  String get category => 'Danh mục';

  @override
  String get account => 'Tài khoản';

  @override
  String get fromAccount => 'Tài khoản nguồn';

  @override
  String get toAccount => 'Tài khoản đích';

  @override
  String get descriptionOptional => 'Mô tả (không bắt buộc)';

  @override
  String get alsoRememberPayee => 'Đồng thời lưu làm người thụ hưởng';

  @override
  String get splitIntoCategories => 'Chia thành nhiều danh mục';

  @override
  String categoryN(String n) {
    return 'Danh mục $n';
  }

  @override
  String get destinationAmount => 'Số tiền đích';

  @override
  String get destinationAmountOptional => 'Số tiền đích (không bắt buộc)';

  @override
  String get accountCurrencyAmountOptional =>
      'Số tiền theo tiền tệ tài khoản (không bắt buộc)';

  @override
  String get transactionCurrencyOptional =>
      'Loại tiền giao dịch (không bắt buộc)';

  @override
  String get feeOptional => 'Phí (không bắt buộc)';

  @override
  String get feeAmount => 'Số tiền phí';

  @override
  String get feeCategory => 'Danh mục phí';

  @override
  String get feeDescriptionOptional => 'Mô tả phí (không bắt buộc)';

  @override
  String get feeDeducted => 'Phí được trừ từ số tiền ở trên';

  @override
  String get needTwoAccountsToTransfer =>
      'Tạo ít nhất hai tài khoản đang hoạt động để thực hiện chuyển khoản.';

  @override
  String get whatArrivedTitle => 'Đã nhận được gì?';

  @override
  String get whatArrivedBlurb =>
      'Cho chúng tôi biết số tiền thực tế đã nhận được.';

  @override
  String get amountThatArrived => 'Số tiền đã nhận';

  @override
  String get feeLossCategory => 'Danh mục phí / lỗ';

  @override
  String get alreadySettled => 'Đã quyết toán.';

  @override
  String get holdingsTitle => 'Danh mục nắm giữ';

  @override
  String get holdingsCash => 'Tiền mặt';

  @override
  String get holdingsInventory => 'CÔNG CỤ ĐẦU TƯ';

  @override
  String holdingsBook(String amount, String currency) {
    return 'Giá trị sổ sách (tiền mặt + giá gốc) $amount $currency';
  }

  @override
  String holdingsMarketEstimate(String amount, String currency) {
    return 'Ước tính thị trường $amount $currency';
  }

  @override
  String get holdingsNoHoldings =>
      'Chưa có khoản nắm giữ nào. Ghi nhận một giao dịch mua để thêm công cụ đầu tư.';

  @override
  String get holdingsQuotesBlurb =>
      'Giá tham chiếu chỉ là ước tính, không phải giá của công ty môi giới. Ứng dụng này không đặt lệnh giao dịch.';

  @override
  String get holdingsTapNameToResearch =>
      'Chạm vào tên để tra cứu. Giá tham chiếu chỉ là ước tính, không phải lời khuyên đầu tư.';

  @override
  String get instrument => 'Công cụ đầu tư';

  @override
  String get newInstrument => 'Công cụ đầu tư mới';

  @override
  String get renameInstrument => 'Đổi tên công cụ đầu tư';

  @override
  String get instrumentActions => 'Thao tác với công cụ đầu tư';

  @override
  String hideInstrumentTitle(String name) {
    return 'Ẩn $name?';
  }

  @override
  String get tickerOptional => 'Mã chứng khoán (không bắt buộc)';

  @override
  String get isinOptional => 'ISIN (không bắt buộc)';

  @override
  String get quantity => 'Số lượng';

  @override
  String get unitPrice => 'Đơn giá';

  @override
  String get brokerageOptional => 'Phí môi giới (không bắt buộc)';

  @override
  String get brokerageExpenseCategory => 'Danh mục chi phí môi giới';

  @override
  String get incomeCategory => 'Danh mục thu nhập';

  @override
  String get gainIncomeCategory => 'Danh mục thu nhập từ lãi';

  @override
  String get lossExpenseCategory => 'Danh mục chi phí do lỗ';

  @override
  String get nonCash => 'Phi tiền mặt';

  @override
  String get cash => 'Tiền mặt';

  @override
  String get locked => 'Bị khóa';

  @override
  String get lockUntilHint =>
      'Đây là ghi chú riêng của bạn về một hạn chế, không phải quy định của công ty môi giới.';

  @override
  String get instrumentKindStock => 'Cổ phiếu';

  @override
  String get instrumentKindEtf => 'ETF';

  @override
  String get instrumentKindMutualFund => 'Quỹ tương hỗ';

  @override
  String get instrumentKindBond => 'Trái phiếu';

  @override
  String get instrumentKindOther => 'Khác';

  @override
  String get quoteUseLive => 'Giá trực tiếp';

  @override
  String get quoteUseCached => 'Giá đã lưu tạm';

  @override
  String get quoteUseStale => 'Giá đã cũ';

  @override
  String get quoteUseMissing => 'Đang dùng giá gốc (không có giá)';

  @override
  String get quoteUseDisabled => 'Đã tắt báo giá — dùng giá gốc/giá lưu tạm';

  @override
  String get quoteUseCurrencyMismatch =>
      'Đang dùng giá gốc (khác loại tiền với giá niêm yết)';

  @override
  String unrealizedLabel(String amount, String currency) {
    return 'Chưa thực hiện $amount $currency';
  }

  @override
  String holdingsUnitsCost(String qty) {
    return '$qty đơn vị · ';
  }

  @override
  String get recoveryPhraseTitle => 'Cụm từ khôi phục của bạn';

  @override
  String get recoveryPhraseConfirmTitle => 'Xác nhận cụm từ của bạn';

  @override
  String get recoveryPhraseBlurb =>
      '24 từ này là cách duy nhất để khôi phục lịch sử giao dịch của bạn nếu thiết bị này bị mất, đặt lại, hoặc thay thế. Smara Accounting không có máy chủ và không thể khôi phục chúng thay bạn.\n\nNếu bạn làm mất cả thiết bị này lẫn cụm từ này, mọi giao dịch bạn đã ghi nhận sẽ vĩnh viễn không thể xác minh được.';

  @override
  String get recoveryPhraseWriteDown =>
      'Ghi lại các từ này theo đúng thứ tự và cất giữ ở nơi an toàn, tách biệt với thiết bị này.';

  @override
  String get iveSavedRecoveryPhrase => 'Tôi đã lưu cụm từ khôi phục của mình';

  @override
  String get confirmPhraseBlurb =>
      'Nhập các từ được yêu cầu từ cụm từ bạn vừa lưu.';

  @override
  String wordNumber(String n) {
    return 'Từ số $n';
  }

  @override
  String get keystoreExportTitle => 'Xuất tệp keystore';

  @override
  String get keystoreExportBlurb =>
      'Ngoài cụm từ khôi phục, bạn có thể lưu một tệp keystore đã mã hóa được bảo vệ bởi cụm mật khẩu do bạn chọn. Việc này không bắt buộc - chỉ riêng cụm từ khôi phục của bạn luôn đủ để khôi phục khóa ký.';

  @override
  String get keystorePassphrase => 'Cụm mật khẩu';

  @override
  String get exportKeystoreFile => 'Xuất tệp keystore';

  @override
  String get chooseCurrencyTitle => 'Chọn đơn vị tiền tệ của bạn';

  @override
  String get chooseCurrencyBlurb =>
      'Mỗi nhóm tài khoản (Tiền mặt và các khoản tương đương tiền, Lương hưu và hưu trí, v.v.) hiện đang dùng chung một đơn vị tiền tệ này. Sau này bạn vẫn có thể thêm tài khoản bằng một loại tiền tệ khác bằng cách tạo một nhóm mới cho nó.';

  @override
  String get currencyBackfillTitle =>
      'Chọn đơn vị tiền tệ cho các nhóm hiện có';

  @override
  String get currencyBackfillBlurb =>
      'Ứng dụng này hiện hỗ trợ nhiều loại tiền tệ. Các tài khoản và nhóm tài khoản hiện có của bạn cần một loại tiền tệ - vì tất cả đều được thiết lập trước khi tính năng này ra đời, một lựa chọn sẽ áp dụng cho tất cả.';

  @override
  String get firstAccountTitle => 'Đặt tên cho tài khoản của bạn';

  @override
  String get firstAccountBlurb =>
      'Đây là tài khoản đã được thiết lập sẵn cho bạn - hãy đặt cho nó một cái tên bạn dễ nhận ra, như tên ngân hàng của bạn. Tiếp theo bạn sẽ ghi nhận một khoản Chi hoặc Thu, sau đó bảo vệ thiết bị bằng cụm từ khôi phục của bạn.';

  @override
  String get whatsMainAccountCalled => 'Tài khoản chính của bạn tên là gì?';

  @override
  String get restoreTitle => 'Khôi phục khóa ký';

  @override
  String get restoreBlurb =>
      'Thiết bị này đã có sổ sách, nhưng không có khóa ký phù hợp. Hãy khôi phục nó từ cụm từ khôi phục hoặc tệp keystore đã lưu - dữ liệu của bạn sẽ được xác minh bình thường, và không có gì bị ký lại hay thay đổi.';

  @override
  String get recoveryPhrase24 => 'Cụm từ khôi phục (đủ 24 từ)';

  @override
  String get keystoreFile => 'Tệp keystore';

  @override
  String get keystoreFileContents => 'Nội dung tệp keystore';

  @override
  String get optionalBackupFile => 'Tệp sao lưu (không bắt buộc)';

  @override
  String get iDontHavePhrase =>
      'Tôi không có cụm từ khôi phục hoặc tệp keystore';

  @override
  String get migrationTitle => 'Chuyển sang khóa mới';

  @override
  String get migrationBlurb =>
      'Nếu không có cụm từ khôi phục hoặc tệp keystore, khóa ký của thiết bị này không thể khôi phục được. Bạn có thể bắt đầu với một khóa mới. Các mục cũ vẫn hiển thị nhưng sẽ bị thay thế.';

  @override
  String get iConfirmBooksValid => 'Tôi xác nhận sổ sách hiện tại là hợp lệ';

  @override
  String get whyWeDontEdit => 'Vì sao chúng tôi không sửa các mục cũ';

  @override
  String get whyWeDontEditBody =>
      'Khi bạn sửa một sai sót, chúng tôi giữ nguyên dòng cũ và thêm một điều chỉnh bên cạnh nó, thay vì thay đổi những gì bạn đã nhập. Nhờ vậy lịch sử của bạn luôn cho thấy chính xác điều gì đã xảy ra và khi nào bạn đã sửa nó — không có gì âm thầm thay đổi sau lưng bạn.';

  @override
  String get lockTitle => 'Mở khóa';

  @override
  String get lockScreenTitle => 'Đã khóa';

  @override
  String get enterPinToContinue => 'Nhập mã PIN của bạn để tiếp tục';

  @override
  String get pinLabel => 'Mã PIN';

  @override
  String get setPinTitle => 'Đặt mã PIN';

  @override
  String get currentPin => 'Mã PIN hiện tại';

  @override
  String get newPin => 'Mã PIN mới';

  @override
  String get confirmPin => 'Xác nhận mã PIN';

  @override
  String get confirmNewPin => 'Xác nhận mã PIN mới';

  @override
  String get firstWeekTitle => 'Thiết lập tài khoản của bạn';

  @override
  String get addCashAccount => 'Thêm tài khoản tiền mặt';

  @override
  String get addCreditCard => 'Thêm thẻ tín dụng';

  @override
  String get cashAccountName => 'Tên tài khoản tiền mặt';

  @override
  String get cardName => 'Tên thẻ';

  @override
  String get paidFromBank => 'Thanh toán từ ngân hàng';

  @override
  String get paidFromCard => 'Thanh toán từ thẻ';

  @override
  String get choosePassphraseTitle =>
      'Chọn một cụm mật khẩu để bảo vệ bản sao lưu này. Sẽ không có cách khôi phục nếu bạn quên nó.';

  @override
  String get replaceBooksTitle => 'Thay thế sổ sách trên máy này?';

  @override
  String get replaceBooksBody =>
      'Việc này sẽ thay thế toàn bộ dữ liệu hiện có trong ứng dụng bằng bản sao lưu. Sau đó hãy đóng và mở lại ứng dụng.';

  @override
  String get chooseBackupFileFirst => 'Hãy chọn một tệp sao lưu trước.';

  @override
  String get backupRestored => 'Đã khôi phục bản sao lưu';

  @override
  String get backupRestoredBody =>
      'Sổ sách của bạn đã được khôi phục. Hãy đóng và mở lại ứng dụng để tiếp tục.';

  @override
  String get fixThisEntry => 'Sửa mục này';

  @override
  String get fixBlurb =>
      'Dòng cũ vẫn giữ nguyên như trước. Xác nhận sẽ thêm một dòng đảo ngược và dòng đã điều chỉnh.';

  @override
  String get importStatementTitle => 'Nhập sao kê';

  @override
  String get importOfx => 'Nhập tệp OFX';

  @override
  String get importOfxQfxFile => 'Nhập tệp OFX / QFX';

  @override
  String get importCsvFile => 'Nhập tệp CSV';

  @override
  String get whatKindOfStatement => 'Bạn có loại tệp sao kê nào?';

  @override
  String get chooseAccountForFile => 'Chọn tài khoản mà tệp này thuộc về.';

  @override
  String get importIntoAccount => 'Nhập vào tài khoản';

  @override
  String get useSavedProfile => 'Dùng một hồ sơ đã lưu';

  @override
  String get saveMappingProfile =>
      'Lưu ánh xạ này thành một hồ sơ (không bắt buộc)';

  @override
  String get renameProfile => 'Đổi tên hồ sơ';

  @override
  String get deleteProfileTitle => 'Xóa hồ sơ?';

  @override
  String get fileHasHeader => 'Tệp có dòng tiêu đề';

  @override
  String get dateColumn => 'Cột ngày';

  @override
  String get dateFormatHint => 'Định dạng ngày (ví dụ dd/MM/yyyy)';

  @override
  String get amountColumn => 'Cột số tiền';

  @override
  String get amountConvention => 'Quy ước số tiền';

  @override
  String get signedAmountColumn => 'Cột số tiền có dấu';

  @override
  String get separateDebitCredit => 'Cột nợ / có riêng biệt';

  @override
  String get debitColumn => 'Cột nợ';

  @override
  String get creditColumn => 'Cột có';

  @override
  String get decimalSeparator => 'Dấu phân cách thập phân (. hoặc ,)';

  @override
  String get descriptionColumns => '(Các) cột mô tả';

  @override
  String get referenceIdColumn => 'Cột mã tham chiếu (không bắt buộc)';

  @override
  String get skippedRows => 'Các hàng bị bỏ qua';

  @override
  String parsedTransactionCount(String count) {
    return 'Đã phân tích $count giao dịch';
  }

  @override
  String skippedOrExcludedCount(String count) {
    return '$count bị bỏ qua hoặc loại trừ';
  }

  @override
  String postedFailedCount(String posted, String failed) {
    return '$posted đã ghi sổ, $failed thất bại';
  }

  @override
  String get categoryForAll => 'Danh mục cho tất cả';

  @override
  String get saveAsRule => 'Lưu thành quy tắc?';

  @override
  String get saveAsRuleBlurb =>
      'Các lần nhập sau này có mô tả chứa từ khóa này sẽ dùng danh mục này.';

  @override
  String get keyword => 'Từ khóa';

  @override
  String get noSavedRules =>
      'Chưa có quy tắc nào được lưu. Gán một danh mục cho một nhóm hàng để lưu quy tắc.';

  @override
  String get deleteRuleTitle => 'Xóa quy tắc?';

  @override
  String get editRule => 'Sửa quy tắc';

  @override
  String rowsGrouped(String count) {
    return '$count hàng';
  }

  @override
  String selectStatementFile(String extensions) {
    return 'Chọn một tệp sao kê $extensions để nhập';
  }

  @override
  String get payeesTitle => 'Người thụ hưởng';

  @override
  String get addPayee => 'Thêm người thụ hưởng';

  @override
  String get renamePayee => 'Đổi tên người thụ hưởng';

  @override
  String get deletePayeeTitle => 'Xóa người thụ hưởng?';

  @override
  String get noPayeesYet => 'Chưa có người thụ hưởng nào';

  @override
  String get recurringTitle => 'Mẫu định kỳ';

  @override
  String get noRecurringYet => 'Chưa có mẫu định kỳ nào';

  @override
  String get deleteTemplateTitle => 'Xóa mẫu định kỳ?';

  @override
  String get dayOfMonth => 'Ngày trong tháng (1-31)';

  @override
  String get dayOfMonthNote =>
      'Tháng có ít ngày hơn sẽ dùng ngày cuối cùng của chính tháng đó.';

  @override
  String dayOfMonthLine(String day) {
    return 'Ngày $day trong tháng - ';
  }

  @override
  String get name => 'Tên';

  @override
  String get none => 'Không có';

  @override
  String get currency => 'Đơn vị tiền tệ';

  @override
  String get errorGeneric => 'Đã xảy ra lỗi. Thử lại.';

  @override
  String get errorSigningIdentityMismatch =>
      'Cụm từ khôi phục hoặc tệp keystore này không khớp với bất kỳ danh tính ký nào trong cơ sở dữ liệu này.';

  @override
  String get errorInvalidLedgerBackup =>
      'Tệp này không phải là bản sao lưu Smara hợp lệ.';

  @override
  String get errorInvalidLedgerBackupNoIdentity =>
      'Bản sao lưu này không có danh tính ký - đây không phải bản sao lưu Smara hợp lệ.';

  @override
  String get errorInvalidLedgerBackupUnverified =>
      'Bản sao lưu này không được xác minh là sổ sách nguyên vẹn, nên đã không được khôi phục.';

  @override
  String errorInvalidLedgerBackupUnreadable(String detail) {
    return 'Không thể mở tệp này dưới dạng bản sao lưu Smara: $detail';
  }

  @override
  String get errorForeignBackupIdentity =>
      'Bản sao lưu này thuộc về một danh tính ký khác với danh tính trên thiết bị này.';

  @override
  String get errorAccountNotFinancial =>
      'Đó không phải là tài khoản tài chính.';

  @override
  String get errorAccountArchived => 'Tài khoản đó đang bị ẩn.';

  @override
  String get errorAccountNotArchived => 'Tài khoản đó không bị ẩn.';

  @override
  String get errorAccountNoPositiveBalanceToCloseOut =>
      'Không còn số dư nào để chuyển.';

  @override
  String get errorAccountHasNoGroup =>
      'Tài khoản đó chưa được gán vào nhóm nào.';

  @override
  String get errorGroupHasNoCurrency =>
      'Nhóm đó chưa được thiết lập đơn vị tiền tệ.';

  @override
  String get errorGroupNotFound => 'Không tìm thấy nhóm tài khoản đó.';

  @override
  String get errorInvestmentAccountsMustBeAssets =>
      'Chỉ tài khoản tài sản mới có thể được đánh dấu là tài khoản đầu tư.';

  @override
  String get errorCreditCardsMustBeLiabilities =>
      'Chỉ tài khoản nợ phải trả mới có thể được đánh dấu là thẻ tín dụng.';

  @override
  String get errorOpeningBalanceMustBePositive =>
      'Số dư đầu kỳ phải là số dương nếu được cung cấp.';

  @override
  String get errorAccountTypeDoesNotMatchGroup =>
      'Loại tài khoản đó không khớp với nhóm.';

  @override
  String get errorLastActiveAccount =>
      'Không thể ẩn tài khoản tài chính đang hoạt động cuối cùng.';

  @override
  String get errorCurrencyRequiredToCreateGroup =>
      'Cần chọn đơn vị tiền tệ để tạo nhóm.';

  @override
  String get errorSystemGroupCannotBeArchived =>
      'Không thể ẩn các nhóm tài khoản có sẵn.';

  @override
  String get errorGroupAlreadyArchived => 'Nhóm đó đã bị ẩn rồi.';

  @override
  String get errorCannotArchiveGroupWithAccounts =>
      'Không thể ẩn một nhóm vẫn còn tài khoản đang hoạt động.';

  @override
  String get errorSystemGroupNeverArchived =>
      'Các nhóm tài khoản có sẵn không bao giờ bị ẩn.';

  @override
  String get errorAccountGroupsCannotBeDeleted =>
      'Không thể xóa nhóm tài khoản.';

  @override
  String get errorCannotReassignDifferentCurrency =>
      'Không thể chuyển tài khoản này sang nhóm có đơn vị tiền tệ khác.';

  @override
  String get errorCannotChangeGroupCurrencyWithAccounts =>
      'Không thể thay đổi đơn vị tiền tệ khi nhóm còn tài khoản đang hoạt động.';

  @override
  String get errorAmountMustBePositive => 'Số tiền phải dương.';

  @override
  String get errorAccountCurrencyAmountMustBePositive =>
      'Số tiền theo tiền tệ tài khoản phải là số dương.';

  @override
  String get errorAccountCurrencyAmountNotForSameCurrency =>
      'Số tiền theo tiền tệ tài khoản chỉ dùng cho giao dịch ngoại tệ.';

  @override
  String get errorSplitNeedsTwoLines =>
      'Một giao dịch chia cần ít nhất hai dòng danh mục.';

  @override
  String get errorSplitLineMustBePositive =>
      'Mỗi dòng chia phải là một số tiền dương.';

  @override
  String get errorSplitLinesMustSumToTotal =>
      'Tổng các dòng chia phải bằng tổng số tiền giao dịch.';

  @override
  String get errorTransferAmountMustBePositive =>
      'Số tiền chuyển khoản phải là số dương.';

  @override
  String get errorTransferAccountsMustDiffer =>
      'Tài khoản nguồn và tài khoản đích phải khác nhau.';

  @override
  String get errorCloseoutRequiresDestinationAmount =>
      'Một giao dịch tất toán khác loại tiền tệ cần một số tiền đích đã biết.';

  @override
  String get errorDestinationAmountNotForSameCurrency =>
      'Số tiền đích chỉ dùng cho chuyển khoản khác loại tiền tệ.';

  @override
  String get errorDestinationAmountMustBePositive =>
      'Số tiền đích phải là số dương.';

  @override
  String get errorInvestmentCashExceeded =>
      'Không thể chuyển nhiều hơn số tiền mặt của tài khoản đầu tư này.';

  @override
  String get errorCannotReverseUnsettledProvisional =>
      'Hãy quyết toán khoản chuyển đang chờ này thay vì đảo ngược nó.';

  @override
  String get errorAlreadyReversed =>
      'Mục này đã được điều chỉnh trước đó. Dòng gốc vẫn giữ nguyên.';

  @override
  String get errorNotActiveExpenseCategory =>
      'Hãy chọn một danh mục chi tiêu đang hoạt động.';

  @override
  String get errorNotActiveIncomeCategory =>
      'Hãy chọn một danh mục thu nhập đang hoạt động.';

  @override
  String get errorSettledAmountMustNotBeNegative =>
      'Số tiền đã nhận không được là số âm.';

  @override
  String get errorPendingTransferNotFound =>
      'Không tìm thấy khoản chuyển đang chờ đó.';

  @override
  String get errorPendingTransferAlreadySettled =>
      'Khoản chuyển đang chờ đó đã được quyết toán rồi.';

  @override
  String get errorSettledToMustBeSourceOrDestination =>
      'Hãy chọn tài khoản nguồn hoặc tài khoản đích ban đầu.';

  @override
  String get errorFeeCategoryOnlyWhenReturningToSource =>
      'Danh mục phí chỉ được dùng khi tiền được hoàn về tài khoản nguồn.';

  @override
  String get errorSettledAmountMustBePositiveForDelivery =>
      'Nhập một số tiền dương cho số đã nhận.';

  @override
  String get errorSettledAmountExceedsProvisional =>
      'Số tiền đó nhiều hơn số tiền đã gửi.';

  @override
  String get errorInstrumentNotFound => 'Không tìm thấy công cụ đầu tư đó.';

  @override
  String get errorIncomeRequiredForNonCash =>
      'Cần một danh mục thu nhập đang hoạt động cho một giao dịch mua phi tiền mặt.';

  @override
  String get errorInsufficientCash =>
      'Không đủ tiền mặt trong tài khoản đầu tư này cho giao dịch mua đó.';

  @override
  String get errorSellQuantityAndPriceMustBePositive =>
      'Số lượng bán và đơn giá phải là số dương.';

  @override
  String errorLockedUntil(String date) {
    return 'Không thể bán: một số đơn vị bị khóa đến $date.';
  }

  @override
  String get errorInsufficientQuantity =>
      'Không thể bán nhiều hơn số lượng chưa bị khóa mà bạn hiện đang nắm giữ.';

  @override
  String get errorIncomeRequiredForGain =>
      'Cần một danh mục thu nhập đang hoạt động cho khoản lãi đã thực hiện.';

  @override
  String get errorExpenseRequiredForLoss =>
      'Cần một danh mục chi tiêu đang hoạt động cho khoản lỗ đã thực hiện.';

  @override
  String errorBrokerageFailedAfterBuy(String detail) {
    return 'Giao dịch mua đã ghi sổ, nhưng phí môi giới thất bại: $detail';
  }

  @override
  String errorBrokerageFailedAfterSell(String detail) {
    return 'Giao dịch bán đã ghi sổ, nhưng phí môi giới thất bại: $detail';
  }

  @override
  String get errorDividendMustBePositive => 'Số tiền cổ tức phải là số dương.';

  @override
  String get errorNotInvestmentAccount => 'Đó không phải là tài khoản đầu tư.';

  @override
  String get errorNoInventoryCompanion =>
      'Tài khoản đầu tư này thiếu tài khoản hàng tồn kho đi kèm.';

  @override
  String errorInvestmentReversalBlocked(String sells) {
    return 'Không thể đảo ngược giao dịch mua này: các giao dịch bán sau đó phụ thuộc vào các đơn vị của nó. Hãy đảo ngược các giao dịch bán phụ thuộc trước: $sells.';
  }

  @override
  String get errorMonthlyLimitMustBePositive =>
      'Hạn mức hàng tháng phải là số dương.';

  @override
  String get errorTemplateAmountMustBePositive =>
      'Số tiền của mẫu phải là số dương.';

  @override
  String get errorOfxUnrecognized => 'Không thể nhận dạng tệp này là OFX.';

  @override
  String get errorCsvEmpty => 'Tệp đã chọn trống rỗng.';

  @override
  String get errorCsvUnreadable => 'Không thể đọc tệp này dưới dạng CSV.';

  @override
  String get errorCsvNoRows => 'Tệp đã chọn không có hàng dữ liệu nào.';

  @override
  String errorBackupCreateFailed(String detail) {
    return 'Không thể tạo bản sao lưu: $detail';
  }

  @override
  String get errorBackupRestoreFailed =>
      'Không thể khôi phục bản sao lưu này - sai cụm mật khẩu, hoặc không phải tệp sao lưu Smara.';

  @override
  String get validationAmountAccountCategoryRequired =>
      'Cần có số tiền, tài khoản, và danh mục.';

  @override
  String get validationAmountAccountRequired => 'Cần có số tiền và tài khoản.';

  @override
  String get validationSplitLineIncomplete =>
      'Mỗi dòng chia cần có danh mục và số tiền.';

  @override
  String get validationSplitSumMismatch =>
      'Tổng các dòng chia phải bằng tổng số tiền giao dịch.';

  @override
  String get validationFromToAmountRequired =>
      'Cần có tài khoản nguồn, tài khoản đích, và số tiền.';

  @override
  String get validationAmountArrivedRequired => 'Cần nhập số tiền đã nhận.';

  @override
  String get validationChooseReceivingAccount =>
      'Chọn tài khoản đã nhận số tiền.';

  @override
  String get validationAccountCategoryRequired =>
      'Cần có tài khoản và danh mục.';

  @override
  String get validationFixFailed => 'Không thể lưu bản sửa này.';

  @override
  String get validationNameRequired =>
      'Hãy đặt tên cho tài khoản chính của bạn.';

  @override
  String get validationStillLoading =>
      'Vẫn đang tải - hãy thử lại sau một chút.';

  @override
  String get validationSaveAccountNameFailed => 'Không thể lưu tên tài khoản.';

  @override
  String get validationWrongPin => 'Mã PIN sai. Thử lại.';

  @override
  String get validationCategoryMustBeIncomeOrExpense =>
      'Danh mục phải là Thu nhập hoặc Chi tiêu.';

  @override
  String get validationOnlyExpenseHasMonthlyLimit =>
      'Chỉ danh mục Chi tiêu mới có thể có hạn mức hàng tháng.';

  @override
  String get validationInvalidTemplate => 'Mẫu không hợp lệ.';

  @override
  String get validationWrongKeystorePassphrase =>
      'Sai cụm mật khẩu cho tệp keystore này.';

  @override
  String get validationInvalidKeystoreFile =>
      'Tệp đó có vẻ không phải là tệp keystore hợp lệ.';

  @override
  String get validationRestorePhraseFailed =>
      'Không thể khôi phục từ cụm từ khôi phục đó.';

  @override
  String validationGenerateKeyFailed(String detail) {
    return 'Không thể tạo khóa ký trên thiết bị này: $detail';
  }

  @override
  String validationSaveCurrencyFailed(String detail) {
    return 'Không thể lưu loại tiền tệ này: $detail';
  }

  @override
  String get validationMigrationFailed =>
      'Di chuyển khóa thất bại. Vui lòng thử lại.';

  @override
  String get validationChooseBackupFile => 'Hãy chọn một tệp sao lưu trước.';

  @override
  String get validationPassphraseRequired => 'Nhập một cụm mật khẩu.';

  @override
  String get validationPinsDoNotMatch => 'Hai mã PIN không khớp nhau.';

  @override
  String get validationFeePositiveWithCategory =>
      'Phí chuyển khoản phải là số dương và phải chọn một danh mục chi tiêu.';

  @override
  String get validationFeeMustBeLessThanAmount =>
      'Đối với giao dịch chuyển khoản trừ phí, phí phải nhỏ hơn số tiền chuyển.';

  @override
  String validationTransferSavedFeeFailed(String detail) {
    return 'Giao dịch chuyển khoản đã lưu, nhưng không thể ghi nhận phí: $detail';
  }

  @override
  String get validationEnterValidAmount => 'Nhập một số tiền hợp lệ.';

  @override
  String validationConfirmWordMismatch(String n) {
    return 'Từ số $n không khớp với cụm từ đã lưu của bạn. Hãy kiểm tra lại và thử lại.';
  }

  @override
  String get errorBuyQuantityAndPriceMustBePositive =>
      'Số lượng mua và đơn giá phải là số dương.';

  @override
  String get errorInstrumentArchived =>
      'Không thể mua một công cụ đầu tư đã bị ẩn.';

  @override
  String get errorNonCashCannotIncludeBrokerage =>
      'Giao dịch mua phi tiền mặt không thể có phí môi giới.';

  @override
  String get errorBrokerageRequiresExpenseCategory =>
      'Cần một danh mục chi tiêu đang hoạt động khi phí môi giới lớn hơn 0.';

  @override
  String get errorSellProceedsMustCoverBrokerage =>
      'Số tiền thu được từ bán phải ít nhất bằng số tiền phí môi giới.';

  @override
  String homeSpentOfLimitThisMonth(String spent, String limit) {
    return '$spent trên $limit tháng này';
  }

  @override
  String get unlockBiometricReason => 'Mở khóa Smara Account';

  @override
  String get searchLabel => 'Tìm';

  @override
  String get openingBalance => 'Số dư đầu kỳ';

  @override
  String transferToName(String name) {
    return 'Chuyển khoản: $name';
  }

  @override
  String get feeForTransfer => 'Phí chuyển khoản';

  @override
  String feeForTransferTo(String name) {
    return 'Phí chuyển khoản đến $name';
  }

  @override
  String couldNotOpenFilePicker(String detail) {
    return 'Không thể mở trình chọn tệp: $detail';
  }

  @override
  String pleaseSelectFile(String extensions) {
    return 'Vui lòng chọn một tệp .$extensions';
  }

  @override
  String get currencyCodeIso => 'Mã đơn vị tiền tệ (ISO 4217, ví dụ USD)';

  @override
  String splitCounterpartMore(String name, String count) {
    return '$name +$count nữa';
  }

  @override
  String get dateLabel => 'Ngày';

  @override
  String get noneSelected => 'Không có';

  @override
  String reviewEntriesBeforeContinuing(String count) {
    return 'Xem lại các mục bên dưới (tổng cộng $count) trước khi tiếp tục.';
  }

  @override
  String youReceived(String amount) {
    return 'Bạn đã nhận $amount';
  }

  @override
  String get leaveBlankIfRateUnknown =>
      'Để trống nếu chưa biết tỷ giá hối đoái.';

  @override
  String get recordTradeBlurb =>
      'Ghi nhận một giao dịch đã xảy ra. Ứng dụng này không đặt lệnh giao dịch.';

  @override
  String get feeOnTopBlurb =>
      'Bật: số tiền ở trên là tổng số tiền bị trừ từ tài khoản này; phí được lấy từ trong đó.';

  @override
  String get feeBankBlurb =>
      'Một khoản hoa hồng thu trước bởi ngân hàng của bạn hoặc một bên trung gian.';

  @override
  String get validationPinMinLength => 'Mã PIN phải có ít nhất 4 chữ số.';

  @override
  String get restoreBackupBlurb =>
      'Việc này thay thế toàn bộ dữ liệu hiện có trong ứng dụng bằng bản sao lưu — nó không hợp nhất dữ liệu. Chọn một tệp sao lưu và nhập cụm mật khẩu bạn đã dùng để bảo vệ nó.';

  @override
  String get actionReplace => 'Thay thế';

  @override
  String hideAccountBody(String name) {
    return '$name sẽ không còn khả dụng cho các giao dịch mới.';
  }

  @override
  String hideGroupBody(String name) {
    return '$name sẽ không còn được đề xuất khi tạo hoặc chuyển tài khoản sang nhóm khác.';
  }

  @override
  String hideCategoryBody(String name) {
    return '$name sẽ không còn được đề xuất khi ghi nhận giao dịch mới.';
  }

  @override
  String get hideInstrumentBody =>
      'Các công cụ đầu tư đã ẩn vẫn giữ nguyên trên các giao dịch mua bán trước đó. Bạn vẫn có thể ghi nhận cổ tức cho chúng.';

  @override
  String nameHidden(String name) {
    return '$name (đã ẩn)';
  }

  @override
  String get noCurrencySet => 'Chưa thiết lập đơn vị tiền tệ';

  @override
  String deletePayeeBody(String name) {
    return '$name và các mặc định đã lưu của người này sẽ bị xóa. Các giao dịch trước đây không bị ảnh hưởng.';
  }

  @override
  String deleteTemplateBody(String name) {
    return '$name sẽ không còn được nhắc đến hạn nữa. Các giao dịch trước đây mà nó đã ghi nhận không bị ảnh hưởng.';
  }

  @override
  String deleteProfileBody(String name) {
    return 'Ánh xạ cột đã lưu \"$name\" sẽ bị xóa. Các sao kê đã được nhập bằng ánh xạ này không bị ảnh hưởng.';
  }

  @override
  String deleteRuleBody(String keyword) {
    return 'Các lần nhập sẽ không còn được tự động phân loại theo \"$keyword\" nữa. Các giao dịch đã được phân loại bằng quy tắc này không bị ảnh hưởng.';
  }

  @override
  String get firstWeekBlurb =>
      'Bạn có thể tùy chọn thêm thẻ tín dụng hoặc tài khoản tiền mặt ngay bây giờ - bạn luôn có thể thêm tài khoản khác sau này từ Cài đặt.';

  @override
  String get deliveredToDestination => 'Đã đến nơi đích';

  @override
  String deliveredToName(String name) {
    return 'Đã đến $name';
  }

  @override
  String youReceivedLessThanExpected(String amount, String currency) {
    return 'Bạn đã nhận ít hơn dự kiến $amount $currency - hãy chọn một danh mục để bù đắp phần chênh lệch.';
  }

  @override
  String get dateRangeLabel => 'Khoảng thời gian';

  @override
  String get addTemplate => 'Thêm mẫu';

  @override
  String get editTemplate => 'Sửa mẫu';

  @override
  String get validationFillTemplateFields =>
      'Điền vào mọi trường với số tiền và ngày hợp lệ.';

  @override
  String get saveCsvExport => 'Lưu tệp xuất CSV';

  @override
  String get referenceRate => 'Tỷ giá tham khảo';

  @override
  String get yourRate => 'Tỷ giá của bạn';

  @override
  String leaveBlankIfThisWasAccountCurrency(String currency) {
    return 'Để trống nếu giao dịch này bằng $currency, đơn vị tiền tệ riêng của tài khoản.';
  }

  @override
  String get lockUntilOptional => 'Khóa đến (không bắt buộc)';

  @override
  String lockedUntilDate(String date) {
    return 'Bị khóa đến $date';
  }

  @override
  String get copiedResearchPrompt =>
      'Đã sao chép gợi ý tra cứu — không có URL trình duyệt khả dụng, hoặc bạn đang ngoại tuyến.';

  @override
  String get openedFavouriteResearchTool =>
      'Đã mở công cụ nghiên cứu yêu thích của bạn.';

  @override
  String get looksLikeGain => 'Đây có vẻ là một khoản lãi';

  @override
  String get looksLikeLoss => 'Đây có vẻ là một khoản lỗ';

  @override
  String get looksLikeBreakEven => 'Đây có vẻ là hòa vốn';

  @override
  String sellableQuantity(String name, String qty) {
    return '$name ($qty có thể bán)';
  }

  @override
  String columnN(String index) {
    return 'Cột $index';
  }

  @override
  String get importingLabel => 'Đang nhập...';

  @override
  String get confirmImport => 'Xác nhận nhập';

  @override
  String get manageSavedCategoryRules => 'Quản lý quy tắc danh mục đã lưu';

  @override
  String statementCurrencyMismatch(String currency) {
    return 'Đơn vị tiền tệ của tệp này ($currency) không khớp với đơn vị tiền tệ của tài khoản đã chọn.';
  }

  @override
  String get categoryRulesTitle => 'Quy tắc danh mục';

  @override
  String get possibleDuplicate => 'có thể trùng lặp';

  @override
  String get unknownCategory => 'Danh mục không xác định';
}
