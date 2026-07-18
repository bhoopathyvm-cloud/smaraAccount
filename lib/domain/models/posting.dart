/// One leg of a journal entry. Every entry has exactly two postings whose
/// [amountMinor] values sum to zero (design.md: "Signed-amount postings
/// instead of explicit debit/credit columns").
class Posting({
  required final String id,
  required final String entryId,
  required final String accountId,
  required final int amountMinor,
  required final int lineNumber,
});
