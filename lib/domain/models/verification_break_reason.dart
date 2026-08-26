/// Why an entry failed verification (Golden Rule #5: no magic strings for
/// fixed sets).
enum VerificationBreakReason {
  hashMismatch,
  signatureInvalid,
  chainLinkBroken,
  excludedAfterBreak,
}
