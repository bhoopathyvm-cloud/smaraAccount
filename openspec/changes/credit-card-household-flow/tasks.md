## Tasks

- [ ] 1.1 Schema: `isCreditCard` boolean on liability accounts, set at creation, immutable, rejected for asset accounts.
- [ ] 1.2 Record-transaction capture: "Paid from card" / "Paid from bank" shortcuts when at least one card-flagged account exists; both resolve to the existing account picker, pre-filtered.
- [ ] 1.3 "Pay card" action: pre-fills the existing transfer flow (bank source, card destination), no new repository method.
- [ ] 1.4 Home: style card-flagged liability rows distinctly (label/icon) — the balance figure itself is already shown by existing per-account display; no new data needed.
- [ ] 1.5 Tests: card flag immutable and asset-rejected; "Paid from card" posts an ordinary expense against the card; "Pay card" posts an ordinary transfer and reduces the card's amount owed.
- [ ] 1.6 User guide: marking a card, the paid-from shortcut, and Pay card.
