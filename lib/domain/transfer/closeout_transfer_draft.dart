/// Mutable archived-account closeout form state: destination account, its
/// currency, an optional description, the transaction date, and (for a
/// cross-currency closeout) the known destination amount.
///
/// Concentrates the closeout form's currency rules: whether the move is
/// cross-currency, that a destination amount is submitted only for a
/// cross-currency closeout (a same-currency closeout moves the full
/// balance), and that changing the destination account drops any amount
/// entered for the previous pick. Currency snapshots are supplied by the
/// dialog/ViewModel; this module never touches Drift, a Repository, or
/// Flutter.
class CloseoutTransferDraft {
  CloseoutTransferDraft({this.sourceCurrency});

  /// Currency of the archived source account (fixed for the flow).
  final String? sourceCurrency;

  String? toAccountId;
  String? destinationCurrency;
  int? destinationAmountMinor;
  DateTime transactionDate = DateTime.now();
  String? description;

  bool get isCrossCurrency {
    final from = sourceCurrency;
    final to = destinationCurrency;
    return from != null && to != null && from != to;
  }

  /// Whether a destination account is chosen - the dialog's submit gate.
  bool get hasDestinationAccount => toAccountId != null;

  /// Destination amount to submit: the entered amount for a cross-currency
  /// closeout, and null for a same-currency one (which moves the full
  /// source balance and never carries a destination amount).
  int? get destinationAmountForSubmit =>
      isCrossCurrency ? destinationAmountMinor : null;

  /// Choose the destination account and record its currency, clearing any
  /// destination amount entered for a previous pick.
  void setDestinationAccount(String? accountId, String? currency) {
    toAccountId = accountId;
    destinationCurrency = currency;
    destinationAmountMinor = null;
  }
}
