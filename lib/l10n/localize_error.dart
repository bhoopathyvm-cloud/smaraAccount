import '../domain/exceptions.dart';
import 'generated/app_localizations.dart';

({AppErrorCode code, Map<String, String> params})? _failureOf(Object error) {
  return switch (error) {
    AppFailure f => (code: f.code, params: f.params),
    InvalidTransactionAmountException e => (code: e.code, params: e.params),
    SigningIdentityMismatchException e => (code: e.code, params: e.params),
    InvalidTransferException e => (code: e.code, params: e.params),
    InvalidOpeningBalanceException e => (code: e.code, params: e.params),
    AccountGroupException e => (code: e.code, params: e.params),
    LastActiveAccountException e => (code: e.code, params: e.params),
    PendingTransferException e => (code: e.code, params: e.params),
    OfxParseException e => (code: e.code, params: e.params),
    CsvParseException e => (code: e.code, params: e.params),
    InvalidLedgerBackupException e => (code: e.code, params: e.params),
    ForeignBackupIdentityException e => (code: e.code, params: e.params),
    InvestmentException e => (code: e.code, params: e.params),
    AlreadyReversedException e => (code: e.code, params: e.params),
    _ => null,
  };
}

/// Resolves the `{detail}` placeholder some codes below embed. Repositories
/// and ViewModels must never forward a caught exception's raw
/// `toString()`/message as this placeholder's value - that would be
/// unlocalized English inside an otherwise-translated sentence
/// (i18n-full-ui-and-input-language design.md Risk: "Detail params still
/// English"). Two shapes are supported instead:
///
/// - `params['innerCode']` names another [AppErrorCode] (set when the
///   catch site wrapped a domain exception that already carries its own
///   stable code, e.g. a brokerage-fee post failing with an
///   [InvalidTransactionAmountException] mid-buy) - resolved recursively
///   through [localizeError] in the caller's active locale, so the nested
///   failure reads as a real translated sentence, not raw debug text.
/// - Otherwise (a genuinely unpredictable platform/I-O exception with no
///   stable code of its own, e.g. a failed file write), falls back to
///   [AppLocalizations.errorGeneric] - a translated "something went
///   wrong" rather than the exception's untranslatable English text.
String _detailFor(AppLocalizations l10n, Map<String, String> params) {
  final innerCodeName = params['innerCode'];
  if (innerCodeName != null) {
    for (final candidate in AppErrorCode.values) {
      if (candidate.name == innerCodeName) {
        return localizeError(l10n, candidate, params);
      }
    }
  }
  return l10n.errorGeneric;
}

/// Maps a stable error code (and optional placeholders) to localized copy.
String localizeError(
  AppLocalizations l10n,
  AppErrorCode code, [
  Map<String, String> params = const {},
]) {
  String p(String key, [String fallback = '']) => params[key] ?? fallback;
  return switch (code) {
    AppErrorCode.generic => l10n.errorGeneric,
    AppErrorCode.signingIdentityMismatch => l10n.errorSigningIdentityMismatch,
    AppErrorCode.invalidLedgerBackup => l10n.errorInvalidLedgerBackup,
    AppErrorCode.invalidLedgerBackupNoIdentity =>
      l10n.errorInvalidLedgerBackupNoIdentity,
    AppErrorCode.invalidLedgerBackupUnverified =>
      l10n.errorInvalidLedgerBackupUnverified,
    AppErrorCode.invalidLedgerBackupUnreadable =>
      l10n.errorInvalidLedgerBackupUnreadable(_detailFor(l10n, params)),
    AppErrorCode.foreignBackupIdentity => l10n.errorForeignBackupIdentity,
    AppErrorCode.accountNotFinancial => l10n.errorAccountNotFinancial,
    AppErrorCode.accountArchived => l10n.errorAccountArchived,
    AppErrorCode.accountNotArchived => l10n.errorAccountNotArchived,
    AppErrorCode.accountNoPositiveBalanceToCloseOut =>
      l10n.errorAccountNoPositiveBalanceToCloseOut,
    AppErrorCode.accountHasNoGroup => l10n.errorAccountHasNoGroup,
    AppErrorCode.groupHasNoCurrency => l10n.errorGroupHasNoCurrency,
    AppErrorCode.groupNotFound => l10n.errorGroupNotFound,
    AppErrorCode.investmentAccountsMustBeAssets =>
      l10n.errorInvestmentAccountsMustBeAssets,
    AppErrorCode.creditCardsMustBeLiabilities =>
      l10n.errorCreditCardsMustBeLiabilities,
    AppErrorCode.openingBalanceMustBePositive =>
      l10n.errorOpeningBalanceMustBePositive,
    AppErrorCode.accountTypeDoesNotMatchGroup =>
      l10n.errorAccountTypeDoesNotMatchGroup,
    AppErrorCode.lastActiveAccount => l10n.errorLastActiveAccount,
    AppErrorCode.currencyRequiredToCreateGroup =>
      l10n.errorCurrencyRequiredToCreateGroup,
    AppErrorCode.systemGroupCannotBeArchived =>
      l10n.errorSystemGroupCannotBeArchived,
    AppErrorCode.groupAlreadyArchived => l10n.errorGroupAlreadyArchived,
    AppErrorCode.cannotArchiveGroupWithAccounts =>
      l10n.errorCannotArchiveGroupWithAccounts,
    AppErrorCode.systemGroupNeverArchived => l10n.errorSystemGroupNeverArchived,
    AppErrorCode.accountGroupsCannotBeDeleted =>
      l10n.errorAccountGroupsCannotBeDeleted,
    AppErrorCode.cannotReassignDifferentCurrency =>
      l10n.errorCannotReassignDifferentCurrency,
    AppErrorCode.cannotChangeGroupCurrencyWithAccounts =>
      l10n.errorCannotChangeGroupCurrencyWithAccounts,
    AppErrorCode.amountMustBePositive => l10n.errorAmountMustBePositive,
    AppErrorCode.accountCurrencyAmountMustBePositive =>
      l10n.errorAccountCurrencyAmountMustBePositive,
    AppErrorCode.accountCurrencyAmountNotForSameCurrency =>
      l10n.errorAccountCurrencyAmountNotForSameCurrency,
    AppErrorCode.splitNeedsTwoLines => l10n.errorSplitNeedsTwoLines,
    AppErrorCode.splitLineMustBePositive => l10n.errorSplitLineMustBePositive,
    AppErrorCode.splitLinesMustSumToTotal => l10n.errorSplitLinesMustSumToTotal,
    AppErrorCode.transferAmountMustBePositive =>
      l10n.errorTransferAmountMustBePositive,
    AppErrorCode.transferAccountsMustDiffer =>
      l10n.errorTransferAccountsMustDiffer,
    AppErrorCode.closeoutRequiresDestinationAmount =>
      l10n.errorCloseoutRequiresDestinationAmount,
    AppErrorCode.destinationAmountNotForSameCurrency =>
      l10n.errorDestinationAmountNotForSameCurrency,
    AppErrorCode.destinationAmountMustBePositive =>
      l10n.errorDestinationAmountMustBePositive,
    AppErrorCode.investmentCashExceeded => l10n.errorInvestmentCashExceeded,
    AppErrorCode.cannotReverseUnsettledProvisional =>
      l10n.errorCannotReverseUnsettledProvisional,
    AppErrorCode.alreadyReversed => l10n.errorAlreadyReversed,
    AppErrorCode.notActiveExpenseCategory => l10n.errorNotActiveExpenseCategory,
    AppErrorCode.notActiveIncomeCategory => l10n.errorNotActiveIncomeCategory,
    AppErrorCode.settledAmountMustNotBeNegative =>
      l10n.errorSettledAmountMustNotBeNegative,
    AppErrorCode.pendingTransferNotFound => l10n.errorPendingTransferNotFound,
    AppErrorCode.pendingTransferAlreadySettled =>
      l10n.errorPendingTransferAlreadySettled,
    AppErrorCode.settledToMustBeSourceOrDestination =>
      l10n.errorSettledToMustBeSourceOrDestination,
    AppErrorCode.feeCategoryOnlyWhenReturningToSource =>
      l10n.errorFeeCategoryOnlyWhenReturningToSource,
    AppErrorCode.settledAmountMustBePositiveForDelivery =>
      l10n.errorSettledAmountMustBePositiveForDelivery,
    AppErrorCode.settledAmountExceedsProvisional =>
      l10n.errorSettledAmountExceedsProvisional,
    AppErrorCode.instrumentNotFound => l10n.errorInstrumentNotFound,
    AppErrorCode.incomeRequiredForNonCash => l10n.errorIncomeRequiredForNonCash,
    AppErrorCode.insufficientCash => l10n.errorInsufficientCash,
    AppErrorCode.buyQuantityAndPriceMustBePositive =>
      l10n.errorBuyQuantityAndPriceMustBePositive,
    AppErrorCode.sellQuantityAndPriceMustBePositive =>
      l10n.errorSellQuantityAndPriceMustBePositive,
    AppErrorCode.instrumentArchived => l10n.errorInstrumentArchived,
    AppErrorCode.nonCashCannotIncludeBrokerage =>
      l10n.errorNonCashCannotIncludeBrokerage,
    AppErrorCode.brokerageRequiresExpenseCategory =>
      l10n.errorBrokerageRequiresExpenseCategory,
    AppErrorCode.sellProceedsMustCoverBrokerage =>
      l10n.errorSellProceedsMustCoverBrokerage,
    AppErrorCode.lockedUntil => l10n.errorLockedUntil(p('date')),
    AppErrorCode.insufficientQuantity => l10n.errorInsufficientQuantity,
    AppErrorCode.incomeRequiredForGain => l10n.errorIncomeRequiredForGain,
    AppErrorCode.expenseRequiredForLoss => l10n.errorExpenseRequiredForLoss,
    AppErrorCode.brokerageFailedAfterBuy => l10n.errorBrokerageFailedAfterBuy(
      _detailFor(l10n, params),
    ),
    AppErrorCode.brokerageFailedAfterSell => l10n.errorBrokerageFailedAfterSell(
      _detailFor(l10n, params),
    ),
    AppErrorCode.dividendMustBePositive => l10n.errorDividendMustBePositive,
    AppErrorCode.notInvestmentAccount => l10n.errorNotInvestmentAccount,
    AppErrorCode.noInventoryCompanion => l10n.errorNoInventoryCompanion,
    AppErrorCode.investmentReversalBlocked =>
      l10n.errorInvestmentReversalBlocked(p('sells')),
    AppErrorCode.monthlyLimitMustBePositive =>
      l10n.errorMonthlyLimitMustBePositive,
    AppErrorCode.templateAmountMustBePositive =>
      l10n.errorTemplateAmountMustBePositive,
    AppErrorCode.ofxUnrecognized => l10n.errorOfxUnrecognized,
    AppErrorCode.csvEmpty => l10n.errorCsvEmpty,
    AppErrorCode.csvUnreadable => l10n.errorCsvUnreadable,
    AppErrorCode.csvNoRows => l10n.errorCsvNoRows,
    AppErrorCode.backupCreateFailed => l10n.errorBackupCreateFailed(
      _detailFor(l10n, params),
    ),
    AppErrorCode.backupRestoreFailed => l10n.errorBackupRestoreFailed,
    AppErrorCode.validationAmountAccountCategoryRequired =>
      l10n.validationAmountAccountCategoryRequired,
    AppErrorCode.validationAmountAccountRequired =>
      l10n.validationAmountAccountRequired,
    AppErrorCode.validationSplitLineIncomplete =>
      l10n.validationSplitLineIncomplete,
    AppErrorCode.validationSplitSumMismatch => l10n.validationSplitSumMismatch,
    AppErrorCode.validationFromToAmountRequired =>
      l10n.validationFromToAmountRequired,
    AppErrorCode.validationAmountArrivedRequired =>
      l10n.validationAmountArrivedRequired,
    AppErrorCode.validationChooseReceivingAccount =>
      l10n.validationChooseReceivingAccount,
    AppErrorCode.validationAccountCategoryRequired =>
      l10n.validationAccountCategoryRequired,
    AppErrorCode.validationFixFailed => l10n.validationFixFailed,
    AppErrorCode.validationNameRequired => l10n.validationNameRequired,
    AppErrorCode.validationStillLoading => l10n.validationStillLoading,
    AppErrorCode.validationSaveAccountNameFailed =>
      l10n.validationSaveAccountNameFailed,
    AppErrorCode.validationWrongPin => l10n.validationWrongPin,
    AppErrorCode.validationCategoryMustBeIncomeOrExpense =>
      l10n.validationCategoryMustBeIncomeOrExpense,
    AppErrorCode.validationOnlyExpenseHasMonthlyLimit =>
      l10n.validationOnlyExpenseHasMonthlyLimit,
    AppErrorCode.validationInvalidTemplate => l10n.validationInvalidTemplate,
    AppErrorCode.validationWrongKeystorePassphrase =>
      l10n.validationWrongKeystorePassphrase,
    AppErrorCode.validationInvalidKeystoreFile =>
      l10n.validationInvalidKeystoreFile,
    AppErrorCode.validationRestorePhraseFailed =>
      l10n.validationRestorePhraseFailed,
    AppErrorCode.validationGenerateKeyFailed =>
      l10n.validationGenerateKeyFailed(_detailFor(l10n, params)),
    AppErrorCode.validationSaveCurrencyFailed =>
      l10n.validationSaveCurrencyFailed(_detailFor(l10n, params)),
    AppErrorCode.validationMigrationFailed => l10n.validationMigrationFailed,
    AppErrorCode.validationChooseBackupFile => l10n.validationChooseBackupFile,
    AppErrorCode.validationPassphraseRequired =>
      l10n.validationPassphraseRequired,
    AppErrorCode.validationPinsDoNotMatch => l10n.validationPinsDoNotMatch,
    AppErrorCode.validationFeePositiveWithCategory =>
      l10n.validationFeePositiveWithCategory,
    AppErrorCode.validationFeeMustBeLessThanAmount =>
      l10n.validationFeeMustBeLessThanAmount,
    AppErrorCode.validationTransferSavedFeeFailed =>
      l10n.validationTransferSavedFeeFailed(_detailFor(l10n, params)),
    AppErrorCode.validationEnterValidAmount => l10n.validationEnterValidAmount,
    AppErrorCode.validationConfirmWordMismatch =>
      l10n.validationConfirmWordMismatch(p('n')),
  };
}

/// Localizes a caught repository or validation failure.
String localizeCaughtError(AppLocalizations l10n, Object error) {
  final failure = _failureOf(error);
  if (failure != null) {
    return localizeError(l10n, failure.code, failure.params);
  }
  return l10n.errorGeneric;
}
