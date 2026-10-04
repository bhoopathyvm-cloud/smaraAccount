## ADDED Requirements

### Requirement: Multi-Device Company Acceptance Run
The system SHALL provide a fully automated acceptance run of a small company using expense claims across real, separately running app instances that sync over real sockets: the macOS app as the Owner, an iPad simulator as the accountant (Approver), and 2 to 5 Claimants chosen with `--employees` on iOS simulators (iPhone SE 3rd generation, iPhone 17, iPhone 17 Pro Max). With `--real-devices`, Claimants SHALL instead run on physical iPhones on the same Wi-Fi as the Mac: the first iPhone as Ravi, and with `--second-iphone` a second iPhone as Mia. Android emulators SHALL be optional, used only when explicitly requested; the required runs are iOS and macOS only (decision of 2026-10-04). Each instance SHALL run its own role's script against the real launched app, and devices SHALL join through the GUI using "Enter code instead" and the check code.

#### Scenario: Simulator cast
- **WHEN** a developer runs `tool/run_company_sync_test.sh --employees 3 --ios-only`
- **THEN** the macOS Owner, the iPad accountant and three iPhone-simulator Claimants join by code and run the company scenario to the end, including Kenji's erase

#### Scenario: Real iPhones over Wi-Fi
- **WHEN** a developer runs `tool/run_company_sync_test.sh --employees 3 --real-devices --second-iphone` with two iPhones on the Mac's Wi-Fi
- **THEN** Ravi and Mia run on the physical iPhones, every device reaches the others at its Wi-Fi address, and the company scenario runs to the end

### Requirement: Physical iPhones Launch One at a Time
Physical iPhones SHALL be launched one after another, each only once the previous one has reported ready, and before the other instances, because two Xcode-driven launches at once do not start. A physical device SHALL publish only its Wi-Fi/LAN addresses (never cellular, VPN or peer-to-peer interfaces) for peers to reach it, and SHALL keep retrying its first connection to the conductor for up to 3 minutes while iOS asks for local-network permission.

#### Scenario: Second iPhone waits for the first
- **WHEN** the run uses two physical iPhones
- **THEN** the second iPhone's launch starts only after the first iPhone has reported ready

#### Scenario: Cellular address is never published
- **WHEN** an iPhone on Wi-Fi also has a mobile-data address
- **THEN** the address it publishes for sync is its Wi-Fi address, and peers do not try the mobile-data one

### Requirement: Household Multi-Device Sync Run
The system SHALL provide an automated run, `tool/run_company_sync_test.sh --household`, of one person using the macOS app and two phones on the same books, linked with "Add a device" (no claims or roles). It SHALL check that:
1. each of the three devices records an entry and, after Sync now, every device shows all three entries with the same Cash & Bank balance;
2. when the Mac and then a phone rename the same category, the later rename wins on every device;
3. when the Mac removes the second phone, that phone's copy is erased and the Mac shows "Erased on <date>";
4. after the removal, the Mac and the remaining phone still sync a new entry.

With `--real-devices` the phones SHALL be physical iPhones (with `--second-iphone`, both phones), otherwise iPhone simulators.

#### Scenario: Every device sees every entry
- **WHEN** the Mac records 42.00, phone A 4.50 and phone B 60.00, and each syncs
- **THEN** all three devices hold the same entries and the same Cash & Bank balance

#### Scenario: Later rename wins
- **WHEN** the Mac renames Groceries to "Food (Mac)" and phone A then renames it to "Supermarket (phone A)"
- **THEN** every device shows "Supermarket (phone A)"

#### Scenario: Removed phone is erased and the rest keep syncing
- **WHEN** the Mac removes phone B, and phone A then records an entry
- **THEN** phone B's copy is erased, the Mac shows "Erased on <date>", and the Mac receives phone A's new entry

### Requirement: A Conductor Sequences the Devices and Reports One Result
A conductor on the host SHALL start every instance, tell each one when it may perform its next step, and wait for each instance to report a step as done before releasing the steps that depend on it. It SHALL fail the whole run when any instance fails, times out, or crashes, and SHALL produce one report listing every step with its device, role and time. The conductor SHALL be test tooling only, and SHALL NOT be part of any app build.

#### Scenario: One device fails
- **WHEN** Mia's instance fails an assertion while the others pass
- **THEN** the run fails, and the report names the step, Mia's device, and the failure

#### Scenario: Ordering is enforced
- **WHEN** the accountant's script reaches "decide Ravi's claim"
- **THEN** it waits until the conductor confirms that Ravi's instance has submitted and the accountant's books have received the claim

### Requirement: Deterministic Device Setup
Before the scenario, the run SHALL:
- create or reuse the simulators and emulators it needs, and start every app from a clean state;
- when Android emulators are explicitly requested, connect them to a shared host network so that Bonjour discovery reaches every instance;
- load fixture receipt images and one PDF into each Claimant device's photo library or files, attached through the app's normal picker;
- fix the exchange rates used for the expense dates, with a test-only setting that release builds do not contain.

#### Scenario: Fixed rates
- **WHEN** Kenji records a hotel item of 21 000 JPY
- **THEN** the proposed company amount uses the fixed test rate, so the expected totals in the scenario are exact

#### Scenario: Receipts without a camera
- **WHEN** a Claimant attaches a receipt on a simulator
- **THEN** it picks a seeded fixture image through the normal "pick image" path, and the receipt syncs with the item

### Requirement: The Acme Travel Co Scenario
The run SHALL play this company story. Company currency EUR; "Receipt required above 0"; company limit hints Hotel 150 per night, Meals 40, Taxi 60. Personal limits: Ravi Hotel 120, Mia Hotel 200, Sara Meals 60.

| Person | Role | Items | Accountant's decision |
|---|---|---|---|
| Ravi (advance 200) | Claimant | Train 89 EUR; Hotel 180 GBP at his card rate; Dinner 45 EUR | Train approved; Hotel approved at 120 EUR ("Personal hotel limit 120"); Dinner rejected ("client dinner — bill client") |
| Mia | Claimant | Hotel 190 EUR; Taxi 35 EUR | Both approved |
| Kenji | Claimant | Hotel 21 000 JPY; Meals 6 000 JPY; Souvenir 30 EUR | Hotel and Meals approved; Souvenir rejected ("not a business expense") |
| Sara (advance 100) | Claimant | Meals 55 EUR; Train 60 EUR | Both approved |
| Tom | Claimant | Taxi 80 EUR with an unreadable receipt | Rejected ("receipt unreadable"); resubmitted with a clear receipt and approved |

With fewer employees, the run SHALL use the people in table order. After the decisions, the Owner SHALL settle each claim: approved totals are set against advances, and the Owner records payments in either direction until every "Owed to" balance is 0.

#### Scenario: Reduced approval with reason
- **WHEN** the accountant approves Ravi's hotel at 120 EUR
- **THEN** Ravi's device shows the item as approved at 120 with the reason "Personal hotel limit 120", and the original 180 GBP

#### Scenario: Gaps closed
- **WHEN** the Owner has recorded the final payments
- **THEN** every claim is Paid and every "Owed to <name>" balance is 0 on the Owner's and the accountant's devices

### Requirement: Hard Sync Cases in the Company Run
The run SHALL include:
- **Rush hour:** all Claimants submit at the same moment, and every claim arrives once.
- **Offline employee:** Tom's app is closed while the accountant decides; on reopening, his device receives every decision.
- **Leaver:** after being paid, Kenji is removed; an entry his device signs afterwards is refused by the others, and his copy of the books is erased on next contact and reported "Erased on <date>" on the Owner's device.
- **Competing rename:** the Owner and the accountant rename the same category at nearly the same time; the later change wins on every device and is still the winner after every app restarts.

#### Scenario: Rush hour
- **WHEN** the conductor releases "submit" to every Claimant at once
- **THEN** the accountant's queue holds exactly one claim per Claimant

#### Scenario: Removed device is erased
- **WHEN** Kenji's device next meets a linked device after his removal
- **THEN** his books are erased, and the Owner's Linked devices list shows "Erased on <date>" for his device

#### Scenario: Latest rename survives a restart
- **WHEN** both renames have synced and every instance is restarted
- **THEN** every device shows the later name

### Requirement: Company Run Pass Criteria and Artifacts
The run SHALL pass only when, on every instance at the end:
1. the Owner's and the accountant's books are identical in entries, hashes and balances, and verify;
2. each Claimant sees only their own claims, decisions with reasons, payments and balance, and none of the company bank account or other people's claims;
3. each Claimant's partial copy verifies within its scope;
4. every claim is Paid and every "Owed to" balance is 0;
5. each Claimant sees their own limits (Ravi 120, Mia 200, Kenji the company 150);
6. the whole run finishes within 30 minutes (10 with `--employees 2`).

On failure, the run SHALL keep every instance's screenshot, log and visible-text dump, and the conductor's step timeline, under `build/company_sync/<timestamp>/`.

#### Scenario: Privacy check
- **WHEN** the run checks Mia's device
- **THEN** no text of the company bank account, Ravi's, Kenji's, Sara's or Tom's claims appears anywhere in her app

#### Scenario: Artifacts on failure
- **WHEN** any step fails
- **THEN** `build/company_sync/<timestamp>/` contains a screenshot, log and visible-text dump for each instance, plus the step timeline

### Requirement: Company Run Is Local and Opt-In
The company and household runs SHALL be started by a developer on a Mac with Xcode (the Android SDK only when Android emulators are requested). It SHALL NOT run in pull-request CI or the nightly Linux acceptance workflow, and the regular acceptance suite SHALL NOT start it.

#### Scenario: Normal suite unaffected
- **WHEN** a developer runs `tool/run_acceptance_tests.sh -d macos`
- **THEN** the company run does not start
