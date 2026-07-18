/// One leg of a journal entry. Every entry has exactly two postings whose
/// [amountMinor] values sum to zero (design.md: "Signed-amount postings
/// instead of explicit debit/credit columns").
class Posting {
  const Posting({
    required this.id,
    required this.entryId,
    required this.accountId,
    required this.amountMinor,
    required this.lineNumber,
  });

  final String id;
  final String entryId;
  final String accountId;
  final int amountMinor;
  final int lineNumber;
}
