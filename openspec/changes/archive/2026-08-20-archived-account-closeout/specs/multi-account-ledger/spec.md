## ADDED Requirements

### Requirement: Closeout Transfer Is Offered From the Archived Account Register
When an archived financial account has a strictly positive current display balance, the system SHALL offer a closeout-transfer action on that account's register. The action SHALL let the user choose a different, active destination financial account and SHALL post the archived account's full current display balance. The amount posted SHALL be computed at submit time from the account's current display balance; it SHALL NOT be taken from a user-editable amount field. The general Transfer screen SHALL continue to exclude archived financial accounts as both source and destination. When the archived account's current display balance is zero or negative, the closeout action SHALL NOT be offered.

#### Scenario: Closeout action shown for an archived account with a positive balance
- **WHEN** the user opens the register for an archived financial account whose current display balance is strictly positive
- **THEN** the system offers a closeout-transfer action on that register
- **AND** the ordinary register-scoped Transfer action remains unavailable

#### Scenario: Closeout action hidden when the balance is not positive
- **WHEN** the user opens the register for an archived financial account whose current display balance is zero or negative
- **THEN** the system does not offer a closeout-transfer action

#### Scenario: Closeout amount is the full current balance, not user-entered
- **WHEN** the user confirms a closeout transfer to a different, active financial account
- **THEN** the posted source amount equals the archived account's current display balance at submit time
- **AND** the user is not asked to type that amount

#### Scenario: General transfer screen still excludes archived accounts
- **WHEN** the user opens the general Transfer screen
- **THEN** archived financial accounts are not offered as source or destination
- **AND** closeout is not started from that screen

### Requirement: Cross-Currency Closeout Requires a Known Destination Amount
When the closeout destination account's group currency differs from the archived source account's group currency, the system SHALL require the destination-currency amount at submit time and SHALL post a single complete journal entry covering both currencies. The system SHALL NOT create a pending transfer for a closeout.

#### Scenario: Cross-currency closeout with a known destination amount posts a complete entry
- **WHEN** the user confirms a closeout from an archived account to an active account in a different-currency group and supplies the destination-currency amount
- **THEN** the system posts one complete journal entry
- **AND** no pending transfer is created
- **AND** the archived account's current display balance becomes zero

#### Scenario: Cross-currency closeout without a destination amount is rejected
- **WHEN** the user attempts a closeout to a different-currency active account without supplying a destination-currency amount
- **THEN** the system rejects the closeout
- **AND** no journal entry is posted
- **AND** no pending transfer is created
