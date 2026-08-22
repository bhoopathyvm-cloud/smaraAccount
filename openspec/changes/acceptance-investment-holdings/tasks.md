## 1. Shared harness helpers

- [x] 1.1 Add `createInvestmentAccountThroughGui` to `integration_test/acceptance/support/acceptance_harness.dart`: Accounts tab → Create account → check `thisAccountHoldsInvestments` → pick the Investments group → optional opening cash → Create. Wait until the new account name is visible.
- [x] 1.2 Add `openHoldingsFor(accountName)` that taps the investment account from Home (the `onInvestmentAccountTap` path) and waits for the holdings cash label.
- [x] 1.3 Add a small `recordCashFundedBuyThroughGui` helper (new instrument name/kind/qty/price, optional brokerage + expense category) so later scenarios do not re-script the whole Buy dialog. Scroll the dialog; use `enterTextReliably` / `tapReliably` with `innerTries: 150` on Record Buy.

## 2. Cash and inventory

- [x] 2.1 Scenario: create investment account with opening cash; holdings shows that cash and empty inventory (`holdingsNoHoldings`).
- [x] 2.2 Scenario: transfer cash in from the onboarding checking account, then a smaller cash out; inventory still empty. Assert the transfer picker never lists an inventory companion.
- [x] 2.3 Scenario: cash-out greater than cash is rejected; cash unchanged.
- [x] 2.4 Scenario: record Spent against the investment account through the ordinary record-transaction GUI; cash decreases; inventory empty.
- [x] 2.5 Scenario: investment account with no opening cash; cash-funded Buy is rejected; inventory empty.

## 3. Buy, sell, and dividend

- [ ] 3.1 Scenario: cash-funded Buy of a new Stock instrument with brokerage; inventory shows quantity; cash decreased by qty×price plus brokerage.
- [ ] 3.2 Scenario: cash Buy of 3 plus non-cash 1 with a future lock-until; inventory 4; Sell of 4 rejected and the message includes the lock date.
- [ ] 3.3 Scenario: sell unlocked units at a gain with an income category; quantity down; cash up.
- [ ] 3.4 Scenario: Dividend on a held instrument increases cash; quantity unchanged.
- [ ] 3.5 Scenario: sell remaining sellable quantity, then Dividend for that instrument still posts; inventory has no positive quantity for it.

## 4. Archive, closeout, and home

- [ ] 4.1 Scenario: archive an investment account that has cash; closeout to checking; Sell still works; Buy is disabled; after the sell, closeout is offered again.
- [ ] 4.2 Scenario: disable market-price fetch in Settings (or assert the labeled-estimate copy); Home shows the investment account as a market estimate; tapping it opens holdings.

## 5. File wiring and verification

- [ ] 5.1 Create `integration_test/acceptance/investment_holdings_test.dart` with `IntegrationTestWidgetsFlutterBinding`, `resetToFreshDevice` in `setUpAll` and each `addTearDown`, English l10n finders, and 5-minute timeouts. Do not call Repository methods to seed state.
- [ ] 5.2 Run the file with `flutter test integration_test/acceptance/investment_holdings_test.dart -d macos` and fix harness/timing issues until the file passes. Document any scenario skipped because a control is unreachable in the live window, with a pointer to the existing unit test.
