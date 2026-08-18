## Tasks

- [ ] 1.1 Add `intl` to `pubspec.yaml`.
- [ ] 1.2 `formatAmountMinor` (or a new currency-aware equivalent) uses `NumberFormat.currency(name: currencyCode)` instead of the hardcoded two-decimal string join.
- [ ] 1.3 `MoneyAmountField`: parse using the currency's own decimal separator; show an explicit invalid-input state instead of silently treating unparseable text as empty.
- [ ] 1.4 Sweep Home, Register, Summary, and the transfer implied-rate comment (`transfer_view_model.dart:165`) for the old two-decimal assumption.
- [ ] 1.5 Tests: INR/JPY/EUR formatting matches `intl`'s own currency data; comma-decimal input parses for a comma-decimal currency; unparseable input is rejected, not silently emptied; same amount formats identically regardless of device locale.
- [ ] 1.6 User guide: money now displays per its own currency's convention.
