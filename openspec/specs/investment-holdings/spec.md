# investment-holdings

## Purpose

Model an investment account as a wrapper with cash, an instrument inventory built from individually tracked acquisition lots, and user-recorded buy/sell/dividend activity (price plus brokerage), and show portfolio value and unrealized gain/loss from background free-market quotes — not a broker, not order routing.

## Requirements

### Requirement: Investment Account Has Cash and Inventory
A user-facing investment account SHALL present two parts in one wrapper: a **cash** balance that increases when money is transferred in from another of the user's financial accounts and decreases when money is transferred out, and an **inventory** of instruments (quantity held and cost). Only an asset account marked as an investment account at creation SHALL have this shape. The investment-account flag SHALL NOT be changeable after creation. A liability SHALL NOT be an investment account. Because an investment account is still an ordinary asset financial account, `multi-account-ledger`'s optional opening-balance-on-creation mechanism applies to it unchanged and seeds only its cash — the inventory leg has no opening-balance path and is only ever populated by a buy.

#### Scenario: An investment account can start with an opening cash balance
- **WHEN** the user creates an investment account with a positive opening balance, e.g. to record cash already sitting in an existing brokerage account being onboarded
- **THEN** the account's cash equals that opening balance
- **AND** inventory remains empty until a buy is recorded

#### Scenario: Cash in from a user account
- **WHEN** the user transfers a positive amount from a different active financial account into an investment account
- **THEN** the investment account's cash increases by that amount
- **AND** inventory quantities are unchanged

#### Scenario: Cash out to a user account
- **WHEN** the user transfers a positive amount from an investment account's cash to a different active financial account
- **THEN** the investment account's cash decreases by that amount
- **AND** inventory quantities are unchanged

#### Scenario: Cash out cannot exceed cash
- **WHEN** the user attempts to transfer more than the investment account's current cash to another account
- **THEN** the system rejects the transfer and no journal entry is posted

### Requirement: Ordinary Transactions Against Investment Account Cash
An investment account's cash SHALL remain a selectable financial account for `multi-account-ledger`'s ordinary income/expense transaction recording, unmodified — the escape hatch for a cash-only event that Buy/Sell/Dividend/brokerage don't name (a custody fee, an account maintenance fee, a wire fee), without inventing a bespoke action for each one. It SHALL never touch inventory.

#### Scenario: A miscellaneous cash fee is recorded as an ordinary expense
- **WHEN** the user records an ordinary expense transaction (e.g. an account maintenance fee) against an investment account's cash, outside of Buy/Sell/Dividend/brokerage
- **THEN** the system posts it exactly as for any other financial account
- **AND** inventory is unaffected

#### Scenario: A new investment account with zero cash cannot buy until funded
- **WHEN** the user creates an investment account with no opening balance and attempts a cash-funded buy before transferring cash in
- **THEN** the buy is rejected for insufficient cash
- **AND** the user must transfer cash in first or record a non-cash acquisition

### Requirement: Inventory Is Built From Acquisition Lots
Instruments SHALL be global, shared across every investment account, the same way Income/Expense categories are already shared across the whole ledger rather than scoped per financial account — creating "Apple Inc" once makes it available to buy in any investment account, and archiving it hides it from new buys everywhere, not only in the account where it was last sold. Each account's holding of an instrument is tracked separately regardless. Each acquisition of an instrument (a Buy, of either funding source defined below) SHALL be recorded as a distinct **lot**, scoped to one investment account: quantity, unit cost, funding source, acquisition date, and an optional lock-until date. The inventory SHALL list each instrument the investment account holds with a positive quantity; an instrument's quantity and average cost are computed from the full set of its non-reversed lots together with its sells, as defined by the date-ordered computation requirement below — a sell reduces the instrument's date-ordered average, not any single identified lot — this change does not offer specific-lot or FIFO selection on sell. An instrument with quantity zero SHALL NOT appear as a current holding. Instruments are user-defined: a name, a **kind** chosen from a fixed predefined list (e.g. stock, ETF, mutual fund, bond, other — informational only, with no effect on buy/sell/quote behavior), and an optional ticker and optional ISIN. Instruments are renameable, archivable, and never permanently deleted.

#### Scenario: Kind is chosen from a fixed list
- **WHEN** the user creates or edits an instrument
- **THEN** kind is chosen from the application's predefined list
- **AND** there is no free-text kind field

#### Scenario: Inventory shows units held
- **WHEN** the user opens an investment account that holds two instruments
- **THEN** the inventory lists each instrument with its quantity
- **AND** does not list instruments with quantity zero

#### Scenario: Archived instrument stays on existing holdings
- **WHEN** the user archives an instrument that is still held
- **THEN** the holding remains visible in inventory
- **AND** the instrument is not offered for a new buy

#### Scenario: Renaming an instrument does not affect its holdings or history
- **WHEN** the user renames an instrument
- **THEN** the new name is used going forward in the inventory list, buy/sell/dividend pickers, and past entries' display
- **AND** the instrument's quantity, cost, and lot history are unchanged

#### Scenario: An instrument is never permanently deleted
- **WHEN** the user has archived an instrument with zero current quantity
- **THEN** the instrument remains available in read-only history views
- **AND** there is no action that removes it or its past lots from the record

#### Scenario: The same instrument can be held independently across accounts
- **WHEN** the user holds the same instrument in two different investment accounts
- **THEN** each account shows its own quantity and cost for that instrument, computed only from that account's own lots
- **AND** renaming or archiving the instrument applies to it everywhere it's held, not to just one account

### Requirement: Buy Records a Cash-Funded or Non-Cash Acquisition
The user SHALL record a buy by providing an instrument, a positive quantity, a positive price per unit, a transaction date, a funding source (**cash-funded** or **non-cash acquisition**), an optional lock-until date, an optional description, and, for a cash-funded buy, an optional brokerage amount that is zero or positive. A **cash-funded** buy SHALL decrease cash by (quantity × price) and increase inventory by that lot's quantity and (quantity × price) cost. A **non-cash acquisition** (e.g. an employer share match, a grant, or a gift) SHALL post no cash leg, SHALL post (quantity × price) as income against an active income category, and SHALL increase inventory by that lot's quantity and (quantity × price) cost — a non-cash lot's price still represents a real cost basis (its fair value at acquisition), never zero. When a cash-funded buy's brokerage is positive, it SHALL be posted as a separate same-currency money-out expense entry against the investment account's cash and an active expense category, independent of and reversible independently from the buy entry itself — the same shape as a transfer fee. The system SHALL validate that an active expense category is selected whenever brokerage is positive, before posting the buy; invalid brokerage configuration SHALL reject the submit without posting the buy or the fee. If the buy has already posted and the subsequent brokerage post fails, the system SHALL leave the buy posted, SHALL NOT roll it back, and SHALL surface that the buy succeeded while the brokerage fee failed. The system SHALL NOT place a broker order. A cash-funded buy SHALL be rejected if cash is insufficient for (quantity × price) alone (brokerage is checked and posted separately). A non-cash acquisition SHALL be rejected if no active income category is selected. Either kind SHALL be rejected if the investment account is archived. When multiple validation failures apply (e.g. insufficient cash and missing brokerage category), the system MAY report any or all; no partial posting occurs.

#### Scenario: Cash-funded buy with brokerage
- **WHEN** the user buys 10 units at 100.00 with brokerage 5.00, funded by cash, with sufficient cash and an active expense category
- **THEN** cash decreases by 1000.00 for the buy itself
- **AND** inventory of that instrument increases by 10 units and 1000.00 cost
- **AND** a separate, independently reversible expense entry of 5.00 posts against the chosen category, further decreasing cash by 5.00

#### Scenario: Cash-funded buy without brokerage
- **WHEN** the user buys with no brokerage entered
- **THEN** cash decreases by quantity × price only
- **AND** no fee expense entry is posted

#### Scenario: Cash-funded buy with insufficient cash is rejected
- **WHEN** the user attempts a cash-funded buy whose (quantity × price) exceeds the investment account's cash
- **THEN** the system rejects the buy and no journal entry is posted
- **AND** inventory is unchanged

#### Scenario: A posted buy is not rolled back if its brokerage fee fails to post
- **WHEN** a cash-funded buy has posted successfully and the subsequent brokerage fee entry fails to post
- **THEN** the buy and its inventory effect remain posted
- **AND** the system reports that the buy succeeded while the brokerage fee failed

#### Scenario: Non-cash acquisition posts income, not a cash decrease
- **WHEN** the user records a non-cash acquisition of 1 unit at a fair value of 100.00, with an active income category selected, alongside a separate cash-funded buy of 3 units at 100.00 (an employer "buy 3, get 1 free" match)
- **THEN** the investment account's cash decreases only by the 3-unit cash-funded buy's cost
- **AND** inventory increases by 4 units total: 3 at cash-funded cost, 1 at the non-cash acquisition's cost
- **AND** income of 100.00 is posted for the non-cash acquisition

#### Scenario: Non-cash acquisition without an income category is rejected
- **WHEN** the user attempts a non-cash acquisition without selecting an active income category
- **THEN** the system rejects the buy and no journal entry is posted

#### Scenario: A locked lot cannot be sold before its lock-until date
- **WHEN** the user records a buy with a lock-until date in the future
- **THEN** the resulting lot's quantity is excluded from what a Sell may reduce until that date passes, as defined by the Sell requirement below

#### Scenario: A standalone non-cash acquisition with lock-until
- **WHEN** the user records only a non-cash acquisition of 10 units at 50.00 with a lock-until date one year out, with an active income category, and no companion cash-funded buy
- **THEN** inventory increases by 10 units at 500.00 cost
- **AND** cash is unchanged
- **AND** income of 500.00 is posted
- **AND** all 10 units are locked until the lock-until date

#### Scenario: An employer share match with a lock-in period, end to end
- **WHEN** the user records a cash-funded buy of 3 units at 100.00 and, alongside it, a non-cash acquisition of 1 unit at 100.00 with a lock-until date one year out, representing an employer "buy 3, get 1 free" match with a vesting period
- **THEN** inventory shows 4 units held, with 1 of them excluded from the sellable quantity until the lock-until date passes
- **AND** the 3 cash-funded units are sellable immediately
- **AND** income of 100.00 is posted for the matched unit, with no cash impact from it

### Requirement: Sell Records Price Received and Brokerage
The user SHALL record a sell by providing a held instrument, a positive quantity no greater than the quantity currently sellable (held quantity minus any quantity still locked as of the sell's transaction date), a positive price per unit, a transaction date, an optional description, and an optional brokerage amount that is zero or positive. The system SHALL increase cash by (quantity × price), SHALL reduce inventory quantity and cost using the date-ordered average cost defined below, and SHALL post the resulting realized gain as income or, if the average cost removed exceeds proceeds, the resulting realized loss as an expense — all as part of the sell entry itself, requiring an active category of the applicable type (income for a gain, expense for a loss). When brokerage is positive, it SHALL be posted as a separate same-currency money-out expense entry against the investment account's cash and an active expense category, independent of and reversible independently from the sell entry itself, following the buy requirement's posting-order and failure behavior; this expense category may be the same as or different from a realized-loss expense category. A sell SHALL be rejected if quantity exceeds the currently sellable quantity, if (quantity × price) is less than brokerage, or if a required income/expense category (for the realized gain/loss, and separately for brokerage if positive) is missing. Unlike a buy, a sell SHALL remain available even when the investment account is archived, as defined by `multi-account-ledger`'s archived-account rules. The system SHALL NOT place a broker order.

#### Scenario: Sell at a gain with brokerage
- **WHEN** the user sells 10 units at 120.00 with brokerage 5.00, average cost 100.00 per unit, with an active income category and an active expense category for brokerage
- **THEN** cash increases by 1200.00 for the sell itself
- **AND** inventory decreases by 10 units and 1000.00 cost
- **AND** income of 200.00 is posted for the realized gain
- **AND** a separate, independently reversible expense entry of 5.00 posts against the chosen category, decreasing cash by a further 5.00, so cash's net increase is 1195.00

#### Scenario: Sell at a loss
- **WHEN** the user sells 10 units at 80.00, average cost 100.00 per unit, with an active expense category selected for the loss
- **THEN** cash increases by 800.00
- **AND** inventory decreases by 10 units and 1000.00 cost
- **AND** an expense of 200.00 is posted for the realized loss
- **AND** the sell is rejected before posting if no active expense category is selected for the loss

#### Scenario: Selling more than the sellable quantity is rejected
- **WHEN** the user attempts to sell more units than the currently sellable quantity (held quantity minus any quantity still locked as of the sell's transaction date)
- **THEN** the system rejects the sell and no journal entry is posted

#### Scenario: Sell where brokerage exceeds proceeds is rejected
- **WHEN** the user attempts to sell units where (quantity × price) is less than the brokerage amount
- **THEN** the system rejects the sell and no journal entry is posted

#### Scenario: Selling a locked quantity before its lock-until date is rejected
- **WHEN** the user attempts to sell a quantity that would reduce holdings below the quantity still locked as of the sell's transaction date
- **THEN** the system rejects the sell and no journal entry is posted
- **AND** the rejection states the lock-until date

#### Scenario: A locked quantity becomes sellable once its lock-until date passes
- **WHEN** the sell's transaction date is on or after a lot's lock-until date
- **THEN** that lot's quantity counts toward the sellable quantity

### Requirement: Dividend Income Is Recorded Without Changing Inventory
The user SHALL record a cash dividend for any of the investment account's instruments — including one no longer currently held — by providing a positive amount, a transaction date, an optional description, and an active income category, so a dividend that arrives after the position was fully sold (a common lag between the ex-dividend and payment dates) can still be recorded. The system SHALL increase the investment account's cash by that amount and post it as income against the selected category. A dividend SHALL NOT change any instrument's inventory quantity or cost. Reinvesting a dividend into more units is not a single action; it is a dividend followed by an ordinary buy. Like Sell, a dividend SHALL remain available on an archived investment account — it resolves an already-earned economic event rather than opening a new position, the same justification as Sell's carve-out.

#### Scenario: Dividend increases cash without touching inventory
- **WHEN** the user records a dividend of 50.00 for a held instrument with an active income category
- **THEN** the investment account's cash increases by 50.00
- **AND** the instrument's inventory quantity and cost are unchanged

#### Scenario: A dividend can be recorded after the position was fully sold
- **WHEN** the user records a dividend for an instrument they no longer hold any quantity of
- **THEN** the dividend posts normally, increasing cash
- **AND** no inventory is created or changed

#### Scenario: A dividend can be recorded on an archived investment account
- **WHEN** the user records a dividend against an investment account that has been archived
- **THEN** the dividend posts normally
- **AND** the resulting cash remains eligible for the account's closeout transfer

### Requirement: Buy, Sell, and Dividend Are in the Account's Own Currency
Buy price, sell price, brokerage, and dividend amounts SHALL be entered and posted in the investment account's own group currency. The system SHALL NOT convert a foreign-currency trade price on entry; the user is responsible for converting a foreign-priced trade before entering it.

#### Scenario: Trade amounts post in the account's currency
- **WHEN** the user records a buy, sell, or dividend for an investment account in currency X
- **THEN** every amount involved posts in currency X
- **AND** the system performs no currency conversion on that entry

### Requirement: Current Quantity and Cost Are Computed From Lot History in Transaction-Date Order
An instrument's **current** quantity, average cost, and sellable (unlocked) quantity — used for inventory display and for validating the next buy or sell — SHALL be computed by replaying that instrument's non-reversed buy and sell entries in transaction-date order, not by maintaining a running total independent of that order. When two or more of an instrument's entries share the same transaction date, they SHALL be replayed in the order they were recorded (`recordedAt`), so a same-day buy and sell resolve to one consistent, reproducible current quantity and cost rather than an unspecified order. Recording a buy or sell with a transaction date earlier than existing entries for that instrument SHALL recompute the instrument's *current* quantity and cost as if that entry had been recorded in date order from the start. A previously posted sell's realized gain or loss is a fixed amount already posted in an immutable journal entry (matching this app's posted-entries-are-immutable rule) and SHALL NOT be silently changed by a later backdated entry, even when the recomputed current average cost implies a different figure would now apply; correcting a historical sell's realized gain/loss, if the user wants that, is done explicitly by reversing that sell and recording it again, not automatically.

#### Scenario: A backdated buy recomputes current quantity and cost, not past postings
- **WHEN** the user records a buy dated earlier than sells already recorded for that instrument
- **THEN** the instrument's current quantity and cost reflect the full history in transaction-date order, correctly informing any future buy or sell
- **AND** the previously recorded sells' already-posted realized gain/loss amounts are unchanged

#### Scenario: A same-day buy and sell resolve in recorded order
- **WHEN** a buy and a sell of the same instrument share the same transaction date
- **THEN** the replay orders them by when each was recorded
- **AND** the resulting current quantity and cost are the same every time they are recomputed

### Requirement: Buy, Sell, and Dividend Entries Can Be Reversed, Unless the Reversal Would Imply Negative Quantity
A posted buy, sell, or dividend entry, and a posted brokerage fee entry, SHALL each be reversible independently using the same reversal mechanism as any other journal entry (a new, swapped-side entry referencing the original, dated when the reversal is recorded — the original entry is never deleted or excluded) — reversing one SHALL NOT require or automatically reverse the other, the same independence a transfer and its fee already have. Reversing a buy SHALL be rejected if doing so would make the instrument's replayed quantity negative at any point in transaction-date order — this happens when a later-dated sell already relied on units that buy contributed and no other lot covers the shortfall. Reversing a sell or a dividend SHALL always be accepted: a sell reversal restores quantity and cost and cannot itself cause a negative, and a dividend never touches quantity or cost at all. Reversing only a brokerage fee entry SHALL NOT change quantity, cost, or sellable quantity.

#### Scenario: Reversing a buy removes its lot from holdings
- **WHEN** the user reverses a previously posted buy and no later sell of that instrument depended on its units
- **THEN** the reversal posts and the instrument's replayed quantity and cost no longer include that buy's contribution
- **AND** any lock-until constraint that lot carried is also removed from the replay
- **AND** the investment account's cash and, for a non-cash acquisition, the income it posted are also reversed
- **AND** a separately posted brokerage fee entry for that buy, if any, is unaffected unless the user reverses it too

#### Scenario: Reversing a buy is rejected when a later sell already depends on it
- **WHEN** the user attempts to reverse a buy, and a sell dated after it (given the current lots) would leave the instrument's replayed quantity negative once that buy's contribution is removed
- **THEN** the system rejects the reversal and no journal entry is posted
- **AND** the message tells the user to reverse or adjust the dependent sell first

#### Scenario: Reversing a sell restores the units it removed
- **WHEN** the user reverses a previously posted sell
- **THEN** the units and cost that sell removed from holdings are restored
- **AND** the investment account's cash and the realized gain/loss the sell posted are also reversed
- **AND** a separately posted brokerage fee entry for that sell, if any, is unaffected unless the user reverses it too

#### Scenario: Reversing a dividend is always accepted
- **WHEN** the user reverses a previously posted dividend
- **THEN** the reversal posts, reducing cash and income by the dividend amount
- **AND** no instrument's quantity or cost is affected

#### Scenario: Reversing only a brokerage fee leaves the trade and holdings untouched
- **WHEN** the user reverses a buy's or sell's separately posted brokerage fee entry, without reversing the buy or sell itself
- **THEN** only the brokerage expense is reversed, restoring that amount of cash
- **AND** the buy or sell entry, and the instrument's quantity, cost, and sellable quantity, are unaffected

### Requirement: Background Market Prices for Portfolio Value and Unrealized Gain/Loss
The system SHALL fetch a latest market price for held instruments that have a ticker or ISIN from a fixed, predefined set of free market-data providers, in the background while the application is in the foreground on home or the holdings view. The request SHALL include the identifiers needed for the quote (ticker and/or ISIN) and SHALL NOT include quantities, costs, account ids, or account names. Portfolio value for an investment account SHALL equal cash plus the sum over inventory of (quantity × last fetched price). When a quote is missing, stale, or the fetch failed, the system SHALL use the last cached price if any, otherwise cost, and SHALL indicate that the figure is not a current market price. The holdings view SHALL show, per instrument, unrealized gain or loss equal to that instrument's contribution to portfolio value minus its book cost. Quote fetches SHALL NOT post journal entries. The user SHALL be able to disable quote fetching; when disabled, no market-data request is made.

#### Scenario: Portfolio value uses cash plus quoted inventory
- **WHEN** an investment account has cash 500 and holds 10 units whose last fetched price is 20
- **THEN** the displayed portfolio value is 700
- **AND** no journal entry is posted by the quote

#### Scenario: Unrealized gain/loss is shown per instrument
- **WHEN** an instrument's held quantity has a book cost of 1000 and a current market contribution of 1200
- **THEN** the holdings view shows an unrealized gain of 200 for that instrument

#### Scenario: Quote request does not upload the ledger
- **WHEN** the system fetches a market price
- **THEN** the request includes the instrument's ticker and/or ISIN as needed for the quote
- **AND** the request does not include quantity, cost, account id, or account name

#### Scenario: Failed quote does not block the account
- **WHEN** a quote fetch fails, times out, or quote fetching is disabled
- **THEN** the user can still transfer cash, buy, sell, and record a dividend
- **AND** portfolio value uses cached price or cost, labeled as not current

#### Scenario: Quote fetching can be disabled
- **WHEN** the user disables market-price fetching
- **THEN** no market-data network request is made until it is enabled again
