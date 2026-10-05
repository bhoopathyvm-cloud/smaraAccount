# Research: Mobile-first bookkeeping for Indian micro and small businesses

The question (verbatim): "in india most of small business run using
smartphones only and normally they record expense in hand of in a computer
with deticated person. for such cases, replacing with mobile would enable
the cost management easier and with onlinepayment, person on mobile can do
without any assitance. for such cases synch is important and having a small
fee only for synch might help them to streamline their account. is there any
accounting system exsist already to cover this aspects?"

Gathered 2026-10-05. Everything below was read that day on the vendor's own
site, help centre, FAQ, Play Store or App Store listing, unless marked
**third-party** (a reseller or review site) or **UNVERIFIED**. "Not stated"
means the vendor's pages I could reach did not say. Several Indian vendors
serve their pricing pages only through JavaScript and blocked plain fetches
(Vyapar, myBillBook, Marg, Khatabook privacy policy), so for those the
headline prices come from the App Store / Play Store in-app-purchase lists or
from third-party pages, and are labelled. Indian GST (18%) is extra unless
stated. This note does not repeat the expense-claim tools and global
accounting suites already covered in
`expense-and-accounting-competitor-pricing.md`, nor the sync options in
`remote-sync-and-claim-options.md`.

## 0. Main table

Legend: ✓ yes · ✗ no · ◐ partial · ns = not stated on any vendor page I
could reach. Footnote numbers point to [Sources](#sources). Price = INR
headline as read 2026-10-05, GST extra unless stated. "Operator access"
answers: can the vendor's staff read the books? ✓ means the vendor holds
plaintext books on its cloud (nothing on its pages says otherwise); ✗ means
the books never leave the user's devices.

| Product | Price (free tier -> paid) | Mobile-first | Offline | Multi-device sync (paid?) | Online payments into books | Expense claims | Double-entry | Tamper-proof / signing | Audit log | Operator can read data | E2EE |
|---|---|---|---|---|---|---|---|---|---|---|---|
| **Khatabook** [1] | Free ("100% free!"); no paid plan found | ✓ Android/iOS/web | ns (auto backup to cloud) | ✓ bundled free (same phone number login) | ✓ UPI/QR 0% fee, "automatic sync of all transactions" into khata | ✗ | ✗ single-entry khata | ✗ | ns | ✓ vendor cloud | ✗ |
| **OkCredit** [2] | Free (ads); ₹30 / **₹75 (multi-device)** / ₹99 per month | ✓ Android/iOS/web | ✓ "Works offline" | ✓ **paid** (Ads Free++ ₹75/mo) | ✓ QR payment "posts to their khata automatically" | ✗ | ✗ single-entry | ✗ | ns | ✓ vendor cloud, may store outside India | ✗ |
| **Vyapar** [3] | Mobile free; Gold Mobile ₹999-₹1,109/yr; desktop Silver ₹3,799, Gold ₹4,099, Retail Pro ₹8,999/yr | ✓ Android/iOS + Win/Mac | ✓ "completely offline on a single device"; sync resumes online; conflict rule ns | ✓ **paid** ("Paid/Premium feature", licence per device) | ◐ UPI/QR + payment links; blog: "automatically get matched"; gateway/fee ns | ✗ (expense categories only) | ◐ P&L, balance sheet; model ns | ✗ (editable; Audit Trail is history) | ✓ Audit Trail "View History" + user activity log | ✓ vendor cloud for sync; T&C licence to "use, reproduce, adapt" content | ✗ |
| **myBillBook** [4] | 14-day trial; Silver ₹399/yr (Play); third-party: ₹2,599 / ₹2,999 / ₹4,999 per yr | ✓ Android/iOS/web/PC | ns | ✓ bundled ("Real-Time Sync Across Devices", unlimited devices) | ◐ UPI links in reminders; auto-record ns | ✗ (staff attendance/payroll only) | ◐ balance sheet reports; model ns | ✗ | ns | ✓ "end-to-end encryption on cloud servers" = vendor-held | ✗ (wording is storage encryption) |
| **Swipe** [5] | Free plan; Pro ₹3,399, Jet ₹4,999, Rise ₹5,499, E-Invoicing ₹8,899 (App Store IAP) | ✓ Android/iOS/web | ns | ✓ bundled ("Works across mobile and desktop") | ◐ UPI/payment links; auto-record ns | ✗ | ◐ P&L reports; model ns | ◐ e-invoice IRN via GST IRP only | ns | ✓ vendor cloud; "Always encrypted" | ✗ |
| **TallyPrime** (+Edit Log, TallyDrive, Cloud Access) [6] | Silver ₹22,500 one-time / ₹8,100 yr; Gold ₹67,500; Cloud Access from ₹600/user/mo | ✗ desktop; phone browser view-only | ✓ fully offline on PC | ◐ via TallyDrive backup / Cloud Access / Remote Access (paid TSS) | ns | ✗ | ✓ | ◐ Edit Log release: log cannot be disabled or deleted, but vouchers can still be altered/deleted; TallyVault encrypts file | ✓ Edit Log (Created/Altered/Deleted, user, time) | ✗ on-prem; ✓ for TallyDrive/Cloud Access copies | ✗ |
| **Biz Analyst** (Tally companion) [7] | ₹3,300/device/yr | ✓ Android/iOS | ✓ "truly offline app" | ✓ **paid per device** | ns | ✗ | ✓ (Tally's) | ✗ (Tally rules apply) | via Tally Edit Log | ◐ "can only be accessed on your devices" (relay role ns) | ◐ claimed in transit only |
| **Zoho Books** (India) [8] | Free ≤ ₹25 lakh revenue; Standard ₹749/mo (annual) … Ultimate ₹7,999/mo; Expense Claim add-on ₹149-₹199/user/mo | ◐ cloud with mobile apps | ✗ (offline ns; cloud product) | ✓ bundled (users per plan) | ✓ Razorpay/ICICI "invoice's status will be marked as paid" | ✓ add-on | ✓ | ◐ Transaction Locking: "cannot be added, modified, or deleted" before lock date (admin can unlock) | ✓ (Audit Trail / activity, not fetched) | ✓ vendor cloud; "controls … prohibit employees from arbitrarily accessing" | ✗ |
| **BUSY** [9] | Express free; Magic ₹5,000 / ₹8,000 / ₹12,000 / ₹50,000 per 360 days | ✗ desktop + Lite app | ✓ desktop | ◐ BUSY On Cloud / mobile Lite (paid) | ns | ✗ | ✓ | ns | ns | ✗ on-prem | ✗ |
| **MargBooks** [10] | "₹15/Day" | ◐ cloud + apps | ns | ✓ bundled | ns | ns | ✓ (claims accounting) | ns | ns | ✓ vendor cloud | ✗ |
| **BharatBills** [11] | Free | ✓ Android | ✓ "even when you struggle with internet" | ns | ✓ gateway with UPI/QR | ✗ | ✗ | ✗ | ns | Play: "No data collected" (ns how sync works) | ✗ |
| **HisabKhata** [12] | Free | ✓ Android + web | ✓ "Works offline" | ✓ bundled | ✓ payment links UPI | ✗ | ✗ | ✗ | ns | ✓ vendor cloud | ✗ |
| **Paytm / PhonePe / BharatPe Business** [13] | Free app; UPI MDR 0%; PhonePe SmartSpeaker ₹125/mo | ✓ | ✗ | n/a (payments only) | ✓ settlements, no books | ✗ | ✗ no books | ✗ | ns | ✓ vendor cloud | ✗ |
| **Open Money** [14] | ₹4,000/mo billed annually | ◐ | ✗ | ✓ bundled | ✓ links 1.85% | ✓ reimbursements | via Tally/Zoho | ns | ns | ✓ vendor cloud | ✗ |
| **Wave** (US/CA) [15] | Starter free; Pro $19/mo | ◐ | ✗ | ✓ bundled (Pro users) | ✓ 2.9% + $0.60 | ✗ | ✓ | ✗ | ns | ✓ cloud; "limiting access to only the people who need it"; PCI L1 | ✗ |
| **Bokio** (SE) [16] | 269-599 kr/mo | ◐ | ✗ | ✓ bundled; extra user +49 kr | ✓ Swish 49 kr/mo + 2 kr | ◐ expense handling | ✓ | ns | ns | ✓ vendor cloud | ✗ |
| **bexio** (CH) [17] | CHF 35-119/mo | ◐ | ✗ | ✓ bundled | ✓ bexio Pay | ✓ expenses | ✓ | ns | ns | ✓ cloud, "exclusively in Switzerland", ISO 27001 | ✗ |
| **Banana Accounting+** (CH) [18] | Free ≤ 70 transactions; CHF 89 / 179 per yr | ✗ desktop | ✓ local file | ✗ none | ✗ | ✗ | ✓ | ✓ **hash-chain lock** ("Lock transactions with the Blockchain technology"): alterations detectable, not prevented | ◐ via lock | ✗ local file | n/a (no cloud) |
| **SumUp / Zettle** (UK) [19] | Free app; 1.69% / 1.75% | ✓ | ✗ | ✓ bundled | ✓ card/QR | ✗ | ✗ no books | ✗ | ns | ✓ vendor cloud | ✗ |

**Reading the two hard columns.** *Genuinely tamper-proof entries* (an
altered entry is at least detectable, or a posted entry cannot be changed
at all) exist only in Banana (hash chain, detect-only) and, for a closed
period, Zoho Books Transaction Locking (prevent, but an admin can unlock).
Tally's Edit Log and Vyapar's Audit Trail are **audit logs**: they record
who changed what, and in Tally's Edit Log release the log cannot be switched
off or deleted, but the vouchers themselves stay editable and deletable.
GST e-invoicing (IRP returns a "digitally signed e-invoice and QR code")
signs the *invoice document* for the tax authority; it does not sign the
ledger, and it applies only above ₹10 crore turnover. No product checked
signs ledger entries or chains them, and none makes them immutable by
construction.

*Data out of the operator's reach*: only the on-device products - Banana,
TallyPrime on-prem, Biz Analyst's phone copy ("can only be accessed on your
devices") and BharatBills' "No data collected" label. Every cloud-synced
Indian app (Khatabook, OkCredit, Vyapar sync, myBillBook, Swipe, Zoho,
MargBooks, HisabKhata) holds readable books on its servers; the strongest
statements are process controls (Zoho: least privilege; Wave: "only the
people who need it"), not cryptography. None claims end-to-end or
zero-knowledge encryption.

---

## Short answer

Yes, the Indian market already has a dense layer of **mobile-first, free-to-
start bookkeeping apps** for exactly this user: Khatabook, OkCredit (digital
"khata" / udhaar ledgers), Vyapar, myBillBook and Swipe (GST billing +
accounting), plus the merchant payment apps (Paytm, PhonePe, BharatPe) that
collect UPI at 0% MDR but keep no books. Most of them:

- run fully on Android (often with a web/desktop twin) and several work
  offline (Vyapar, OkCredit, Khatabook backup, BharatBills, HisabKhata);
- post QR/UPI collections straight into the customer ledger (Khatabook,
  OkCredit) or mark the invoice paid (Zoho Books via Razorpay/ICICI, Vyapar
  claims "payments automatically get matched with invoices");
- sync across devices **through the vendor's cloud**, and that sync is
  usually the thing you pay for.

Two products come very close to the "everything free, pay a small fee for
sync" idea:

1. **OkCredit** - the basic khata is "free forever", works offline, backs up
   online, posts QR payments to the ledger automatically; **multi-device
   login is gated behind the ₹75/month "Ads Free++" plan** (which also removes
   ads and adds GST bills). That is the closest existing match to the user's
   pricing idea, but it is a single-entry customer-credit ledger, not books.
2. **Vyapar** - the mobile app is free and "works completely offline on a
   single device"; "Multi-device synchronisation is a Paid/Premium feature",
   with a licence attached to each device. Mobile Gold is ₹999-₹1,109/year
   (App Store in-app purchase). It has expense categories, cash/bank books,
   balance sheet and GST reports, so it is real bookkeeping, but it is still
   sync-via-vendor-cloud, no claim/reimbursement workflow, and no end-to-end
   encryption claim.

What **no product found does**: combine (a) a double-entry ledger, (b) a
staff expense-claim flow, (c) device-to-device sync without a vendor server,
and (d) a fee that pays only for sync. Every Indian app checked holds the
books on its own cloud and none makes an end-to-end-encryption claim (the
closest is myBillBook's "end-to-end encryption on cloud servers" wording,
which describes storage encryption that the vendor can read, not E2EE in the
usual sense; and Biz Analyst's "can only be accessed on your devices" for
its Tally companion). Expense **claims** (an employee submits, an owner
approves and reimburses) exist only in the mid-market tier: Zoho Books'
Expense Claim add-on (₹149-₹199/user/month) and Open Money (₹4,000/month).

---

## 1. Feature comparison (payments, expenses, pricing detail)

Prices as read 2026-10-05, INR unless stated, GST extra unless stated.
"Sync" = multi-device/multi-user over the vendor's cloud unless noted.

| Product | Mobile-first / offline / sync | Online payments into the books | Expenses / claims | Ledger model, GST | Data held | Pricing (free tier -> paid) |
|---|---|---|---|---|---|---|
| **Khatabook** | Android/iOS/web; offline not stated; automatic backup, log in with same number on another phone | UPI/QR "0% fees on QR transactions", "automatic sync of all transactions" into the khata | Cash book / khata entries; no claim flow | Single-entry customer khata + GST and non-GST invoices | Vendor cloud; privacy page unreachable | "100% free"; no paid plan found on site |
| **OkCredit** | Android/iOS/web; "Works offline"; online backup; **multi-device only on paid plan** | QR in reminder; "The payment posts to their khata automatically" | Khata entries only | Single-entry khata; GST bills on paid plan | Vendor cloud ("backed up online and on your device") | Basic free with ads; Unlimited ₹30/mo; **Ads Free++ ₹75/mo (multi-device, GST bills, desktop)**; Premium ₹99/mo |
| **Vyapar** | Android/iOS/Windows/Mac; mobile free, "works completely offline on a single device"; **sync is a Paid/Premium feature**, licence per device | UPI/QR on invoice, payment links in reminders; blog: "Payments automatically get matched with invoices"; gateway/fees not stated | Expense categories with/without GST, expense reports; no claim flow | Cash/bank books, P&L, balance sheet, GSTR reports (double-entry not stated) | Device + Google Drive backup; sync via Vyapar cloud, "encrypts your data during sync" | Mobile free; App Store IAP: Gold Mobile ₹999/₹1,109, Retail Pro Mobile ₹1,699/₹1,899, Gold Combo ₹5,999/₹6,600, Platinum Combo ₹12,700; desktop Silver ₹3,799/yr, Gold ₹4,099/yr (multi-device sync), Retail Pro ₹8,999/yr |
| **myBillBook** | Android/iOS/web/desktop; "Real-Time Sync Across Devices", "Multi-User Access"; offline not stated | UPI links in WhatsApp/SMS reminders; auto-recording not stated; "AI bank reconciliation" | Expense entries, staff attendance + payroll; no claim flow | Balance sheet, GST returns, e-invoice | Vendor cloud, "end-to-end encryption on cloud servers" (Play listing) | 14-day trial; Silver ₹399/yr (Play listing); **third-party**: Diamond ₹2,599, Platinum ₹2,999 (3 users + 1 CA, unlimited devices), Enterprise ₹4,999 |
| **Swipe** | Android/iOS/web; "Works across mobile and desktop"; offline not stated | "Accept payments via UPI, WhatsApp, Email & payment links"; auto-recording not stated | P&L and expense reports; no claim flow | GST invoicing, e-way bill, e-invoice, Tally sync | Vendor cloud, "Your data stays private. Always encrypted." | Free plan (**third-party**: unlimited invoices); App Store IAP Pro ₹3,399, Jet ₹4,999, Rise ₹5,499, E-Invoicing ₹8,899 |
| **TallyPrime** (+ TallyDrive, Cloud Access, browser reports) | Desktop; browser reports on phone are **view-only** ("you can only view and download vouchers"); remote data entry needs TallyPrime on a PC | Not stated | Full accounting; no claim flow | Full double-entry, GST | Device; TallyDrive backup on Tally cloud, Cloud Access on Oracle Cloud | Silver ₹22,500 one-time or ₹8,100/yr; Gold ₹67,500; TallyDrive free 1 GB/3 GB with TSS, +₹1,200/yr per 10 GB; Cloud Access from ₹600/user/mo |
| **Biz Analyst** (Khatabook-owned Tally companion) | Android/iOS; "truly offline app. Your data is stored on your mobile phone"; syncs with Tally | Not stated | View expense analysis; create receipts/payments that sync to Tally | Tally's double-entry | Phone + the Tally PC; "encrypted during the sync process and can only be accessed on your devices" | 7-day trial; ₹3,300/yr per mobile device per Tally licence (₹6,600/3 yr) |
| **Zoho Books** (India) | Android/iOS/web/Windows; cloud only | Razorpay / ICICI: "the invoice's status will be marked as paid" automatically; UPI via payment link | Expenses, bills; **Expense Claim add-on ₹149-₹199/user/mo** | Full double-entry, GST | Vendor cloud | Free (revenue <= ₹25 lakh, 1 user + 1 accountant, 1,000 invoices/yr); Standard ₹749/mo annual (3 users) ... Ultimate ₹7,999/mo |
| **BUSY** | Desktop; "Mobile App Lite" free first 360 days; BUSY On Cloud | Not stated | Full accounting | Double-entry, GST | Device / vendor cloud | Express free; Magic Start ₹5,000, Smart ₹8,000, Power ₹12,000, Power+ ₹50,000 per 360 days |
| **MargBooks** (Marg ERP cloud) | Android/iOS/web/desktop | Not stated on reachable pages | Not stated | GST billing + accounting | Vendor cloud | "just ₹15/Day"; plan detail page blocked |
| **BharatBills** | Android; works "even when you struggle with internet issues" | "Integrated payment gateway" with UPI/QR | Expense reports | GST billing, e-way, e-invoice | Play "No data collected" | Free; 5,000+ downloads (tiny) |
| **HisabKhata** | Android + web; "Works offline" | Payment links, UPI | Udhaar book | GST invoices; single-entry | Vendor cloud (web app) | "100% Free. No Commission" |
| **Paytm for Business** | Android/iOS merchant app | UPI MDR "0.00%", payment links, settlement view | None stated | No books | Vendor cloud | Free app; Soundbox rental not stated |
| **PhonePe Business** | Android/iOS merchant app | UPI QR, payment links, SettleNow | None stated | No books | Vendor cloud | Free app; SmartSpeaker ₹125/mo (₹318 setup) or ₹999 setup + ₹25/mo |
| **BharatPe** | Merchant app | QR "for free", instant card settlement | None stated | No books | Vendor cloud | Free; device prices not stated |
| **Open Money** | Android/iOS/web neobank | Payment links 1.85%/txn, connected banking | Budgets, policies, employee reimbursements | Integrates with Tally/Zoho | Vendor cloud | ₹4,000/mo billed annually |
| *Global:* **Wave** (US/CA) | Mobile + web | Card 2.9% + $0.60 (Starter) | Receipts add-on $11/mo (Starter) / $8 (Pro) | Double-entry | Vendor cloud | Starter free; Pro $19/mo |
| **Bokio** (SE) | Mobile + web | Swish Företag 49 kr/mo + 2 kr/txn | Expense handling from Premium | Double-entry | Vendor cloud | 269 / 359 / 459 / 599 kr/mo; bank feed +49 kr/mo; extra user +49 kr/mo |
| **bexio** (CH) | Mobile + web | bexio Pay +CHF 14/mo on Advanced, included above | Expenses in all plans | Double-entry | "Data stored securely in Switzerland" | CHF 35 (1 user) / 42 (2) / 69 (5) / 119 (25) per month |
| **Banana Accounting+** (CH) | Desktop; local file | None | Income/expense or double-entry | Double-entry | **Local file** on the user's device | Free up to 70 transactions; Professional CHF 89/yr; Advanced CHF 179/yr |
| **SumUp** (UK) | Phone + reader | 1.69% pay-as-you-go; Payments Plus £19/mo for 0.99% | Invoices Plus £8/mo | No books (reporting) | Vendor cloud | Free app, pay per transaction |
| **Zettle / PayPal POS** (UK) | Phone + reader | 1.75% card and PayPal QR; 2.5% invoice/payment link | None | No books, accounting integrations | Vendor cloud | Reader from £29 |

---

## 2. Per-product details

### 2.1 Khatabook

- **What it is**: digital bahi-khata (customer credit/debit ledger) for
  kirana and retail; "Over 5 CRORE active merchants", 5 crore+ Play
  downloads, last updated 1 Oct 2026.
- **Mobile / offline / sync**: Android, iOS (listing by a third-party
  developer name on the US App Store - UNVERIFIED that it is the official
  app), web. Offline not stated. "No matter what happens to your phone,
  your data remains intact. With our automatic backup feature"; help centre:
  "Simply log in to Khatabook with the same phone number as earlier."
- **Payments**: "Receive payments directly into your bank account with UPI
  payments", "0% Fees on QR Transactions", "Save precious hours with
  automatic sync of all transactions".
- **Expenses / claims**: khata entries; staff features are a separate
  product (PagarBook is attendance/payroll, no expense claims stated).
- **Ledger model / GST**: single-entry khata, "GST and non-GST invoice
  generation", inventory.
- **Data**: vendor cloud (backup). Privacy policy page returned 403; no
  E2EE claim seen.
- **Price**: "100% free!" on the site; business loans via NBFC partners are
  the visible monetisation. No paid plan found.

### 2.2 OkCredit

- **Mobile / offline / sync**: Android/iOS/web (web.okcredit.in). "Works
  offline too"; "Every entry is backed up online. Lose or change your phone,
  log in, and your complete khata is back." Multi-device: "Multi device
  enabled. Login with same OkCredit number on multiple devices" - **only in
  Ads Free++ and Premium**.
- **Payments**: "Your customer scans the QR in the reminder and pays
  instantly through GPay, PhonePe, BHIM or Paytm. The payment posts to their
  khata automatically."
- **Expenses / claims**: khata only.
- **Ledger / GST**: single-entry; "Create Bills (Normal Bills, GST Bills)"
  from Ads Free++.
- **Data**: vendor cloud + device; "Only you have access to your data and no
  one else" (FAQ); no encryption detail.
- **Price** (okcredit.in/pricing): Basic free (ads, SMS from your SIM);
  Unlimited Transactions ₹30/mo; Ads Free++ ₹75/mo (no ads, multi-device,
  GST bills, desktop, priority support); Premium ₹99/mo (+ unlimited
  OkCredit-sent SMS).

### 2.3 Vyapar

- **Mobile / offline / sync**: "Mobile App is FREE and Desktop App has a
  15-day FREE trial period" (feature blog; the PC page says 7 days).
  "It works completely offline on a single device." Backups: "Backup to
  phone", "Backup to email", "Auto Backup ... uploaded to your google drive
  account". Sync guide: "Multi-device synchronisation is a Paid/Premium
  feature in Vyapar", "you must have attached the license to each device",
  "You need a working internet connection on both devices to sync data
  initially", roles like Salesperson or Accountant; cloud page: "syncing
  automatically once the device is back online". The FAQ still says cloud is
  "in process of launching" - stale.
- **Payments**: "Cash/Cheque/UPI/QR Code", "collect payments directly online
  using UPI payments", reminders with "embedded payment links (UPI, Net
  Banking, or Cards)". Blog: "every invoice can include a QR code",
  "Payments automatically get matched with invoices". Which gateway and what
  fee: not stated.
- **Expenses / claims**: "create different expense categories", expense
  reports. No staff claim/reimbursement flow stated.
- **Ledger / GST**: cash-in-hand, bank accounts, cheques, P&L, balance
  sheet, GSTR-1/3B, e-invoice, e-way bill. Double-entry under the hood is
  not stated (inference: the balance-sheet reports imply an internal
  double-entry or equivalent, but the UI is a cash/party ledger).
- **Data**: device; sync through Vyapar's cloud ("high-level encryption ...
  during the synchronisation process"); no E2EE claim.
- **Price**: desktop page (vendor): Silver ₹3,799/yr (3 firms), Gold
  ₹4,099/yr (5 firms, adds multi-device sync), Retail Pro ₹8,999/yr. App
  Store in-app purchases (vendor-listed): Gold Mobile ₹999 / ₹1,109, Retail
  Pro Mobile ₹1,699 / ₹1,899, Gold Combo ₹5,999 / ₹6,600, Retail Pro Combo
  ₹10,600 / ₹11,799, Manufacturing Pro Combo ₹10,600, Platinum Combo
  ₹12,700. **Third-party** reseller: mobile Silver ₹699, Gold ₹799, Platinum
  ₹2,399 per year, all listing "Sync data across devices" (UNVERIFIED).

### 2.4 myBillBook (FloBiz)

- **Mobile / offline / sync**: Android/iOS/web/PC; "Multi-User Access for
  Teams", "Real-Time Sync Across Devices"; 1 crore+ downloads, updated 30 Sep
  2026. Offline: not stated.
- **Payments**: "Send WhatsApp and SMS payment reminders with UPI links,
  share live ledgers"; auto-recording of the received payment not stated;
  "AI bank reconciliation".
- **Expenses / claims**: expense entries; "Staff role assignment, vendor
  management, attendance, and payroll"; no claim flow.
- **Ledger / GST**: "25+ business reports including GST returns and balance
  sheets", e-invoicing, e-way bills.
- **Data**: "Data is securely stored with end-to-end encryption on cloud
  servers" (Play listing) - vendor-held cloud; "bank-grade security".
- **Price**: Play listing "Silver plan at ₹399/year"; 14-day trial.
  **Third-party** (Techjockey): Diamond ₹2,599/yr (1 user + 1 CA, mobile and
  web), Platinum ₹2,999/yr (2 businesses, 3 users + 1 CA, adds desktop and
  payroll), Enterprise ₹4,999/yr; "Devices: Unlimited"; "No free plan".
  Official pricing page is JS-only and could not be read.

### 2.5 Swipe (NextSpeed Technologies)

- **Mobile / offline / sync**: Android/iOS/web; "Works across mobile and
  desktop"; "add multiple users, businesses, price lists"; offline not
  stated; 10 lakh+ downloads, updated 9 Sep 2026.
- **Payments**: "Online Payment Collection - Accept payments via UPI,
  WhatsApp, Email & payment links"; auto-recording not stated.
- **Expenses / claims**: P&L and expense reports; no claim flow.
- **Ledger / GST**: GST invoicing, e-way, e-invoice, GSTR JSON, Tally sync.
- **Data**: vendor cloud; "Your data stays private. Always encrypted."
- **Price**: free plan ("Create invoices for free"); App Store in-app
  purchases Pro ₹3,399, Jet ₹4,999, Rise ₹5,499, E-Invoicing ₹8,899.
  **Third-party** (SaaSrat) lists Pro ₹1,499/yr, Jet ₹2,799, Rise ₹3,499
  with conflicting figures - UNVERIFIED.

### 2.6 Tally family

- **TallyPrime**: desktop; Silver ₹22,500 one-time or ₹8,100/12-month
  rental; Gold ₹67,500 (TSS renewal ₹13,500/yr). Browser reports on a phone
  need an active TSS and the PC running TallyPrime and are view-only: "No,
  currently you can only view and download vouchers in a browser." Remote
  data entry is possible via Remote Access but from another TallyPrime
  installation, not a phone.
- **TallyDrive**: cloud backup inside TallyPrime; free 1 GB (single-user) /
  3 GB (multi-user) with TSS, ₹1,200/yr per extra 10 GB; data on Tally's
  cloud, 90-day retention after TSS lapses.
- **TallyPrime Cloud Access**: hosted TallyPrime on Oracle Cloud, from ₹600
  per user per month, needs a TallyPrime licence.
- **Biz Analyst** (acquired by Khatabook): the de-facto "Tally on mobile".
  "Create Sales Invoices, Sales Orders and Receipts from the app ... Syncs
  automatically with TallyPrime"; "truly offline app. Your data is stored on
  your mobile phone"; "encrypted during the sync process and can only be
  accessed on your devices"; ₹3,300 per mobile device per Tally licence per
  year (₹6,600 for 3 years). This is the one Indian product where the fee is
  explicitly **per synced device**.

### 2.7 Zoho Books (India)

Free plan: revenue <= ₹25 lakh, "1 User + 1 Accountant", 1,000 invoices and
1,000 bills/expenses a year, 50 receipt scans/month. Paid: Standard
₹749/mo (annual) for 3 users up to Ultimate ₹7,999/mo for 25 users. UPI via
Razorpay or ICICI: "After the payment goes through, the status of the
invoice is automatically updated to paid"; Razorpay fees land in a Razorpay
Clearing account for reconciliation. Expense Claim add-on ₹149-₹199 per
user per month (the only mobile-capable claim flow in this list). Full
double-entry, vendor cloud.

### 2.8 BUSY, Marg, BharatBills, HisabKhata

- **BUSY**: Express "100% Free Billing & Accounting"; BUSY Magic Start
  ₹5,000, Smart ₹8,000 (GST, e-invoice), Power ₹12,000, Power+ ₹50,000 per
  360 days; "Get Mobile App Lite free for the first 360 days"; BUSY On
  Cloud for remote access. Desktop-centred.
- **MargBooks**: "Cloud-Based GST, Billing & Accounting Software ... for
  just ₹15/Day", iOS/Android apps and a "Mobile Lite App"; plan detail and
  Marg ERP 9+ desktop prices could not be read (page blocked).
- **BharatBills** (30Days Technologies): free, offline-tolerant, UPI/QR
  gateway, expense reports, e-way/e-invoice; 5,000+ downloads, so marginal.
- **HisabKhata**: "100% Free. No Commission", "Works offline", payment links
  with UPI/cards/wallets, udhaar book, GST invoices, web + Android.

### 2.9 Merchant payment apps (Paytm, PhonePe, BharatPe)

All three collect UPI at zero MDR (Paytm pricing page: UPI "0.00%"; BharatPe:
QR "for free"), show settlements and offer payment links and loans. None
describes a khata, expense or accounting feature on its site or store
listing. The only recurring fee is the sound box: PhonePe SmartSpeaker ₹318
setup + ₹125/month, or ₹999 setup + ₹25/month (Paytm's not stated). They
are the payment rail the bookkeeping apps plug into, not books.

### 2.10 Open Money and Dukaan

Open Money is a neobank: ₹4,000/month billed annually, payment links at
1.85%, "Manage employee reimbursements", Tally/Zoho integrations - too
expensive for the micro segment but the one Indian mobile product with a
reimbursement flow outside Zoho. Dukaan is an online-store builder with no
accounting; excluded from the table.

### 2.11 Global equivalents (briefly)

The same freemium-plus-payments pattern shows up outside India: Wave (free
books, 2.9% + $0.60 card fee, $19/mo Pro, receipts as an add-on); SumUp and
Zettle (free app, 1.69-1.75% per transaction, optional monthly plans);
Bokio (flat monthly tiers, bank feed and extra users as +49 kr/month
add-ons); bexio (CHF 35-119/month, "Data stored securely in Switzerland");
Banana Accounting+ (local file, free up to 70 transactions, CHF 89/179 a
year - the only one here that is local-first, and it has no sync).

---

## 2b. Offline, accounts, tamper-proofing and operator access, per product

Four questions per product: (i) what works offline and how conflicts are
handled; (ii) how accounts/users are managed; (iii) signing, immutability or
audit log; (iv) who holds the data and whether staff can read it. "ns" =
not stated on any vendor page reachable on 2026-10-05. **No vendor in this
list documents a conflict-resolution rule for two devices editing offline**;
where a sync exists it is described only as "reflects on other devices in
near real-time" (Vyapar) or "backed up online" (OkCredit).

| Product | (i) Offline and conflicts | (ii) Accounts and roles | (iii) Signing / immutability / audit | (iv) Storage, encryption, operator access, export/delete |
|---|---|---|---|---|
| Khatabook | Offline ns; "automatic backup"; restore = "log in … with the same phone number" [1] | Single owner login by phone number + OTP; multiple businesses under one account ("One app for multiple businesses"); staff roles ns (PagarBook is a separate product) [1] | None stated; edits/deletes ns; no audit log stated; app lock PIN only [1] | Vendor cloud; location, encryption at rest, staff access, deletion: ns (privacy page 403, Play data-safety blocked) [1] |
| OkCredit | "Works offline"; "backed up online and on your device"; conflict rule ns [2] | Phone-number + OTP login; "Login with same OkCredit number on multiple devices" on paid plan; roles/staff ns [2] | None; audit log ns [2] | Vendor cloud; privacy policy: data "may be transferred to and stored at countries other than India", protected by "encryption, firewalls, and socket layer technology"; shared with "storage providers, payments systems providers, marketing partners, data analytics providers" and lenders (SMS-based credit scoring); deletion right not explicit [2] |
| Vyapar | Mobile "works completely offline on a single device"; synced devices "syncing automatically once the device is back online"; initial sync needs internet on both; conflict rule ns; backups to phone / email / Google Drive are the user's job ("performing necessary backups … solely the User's responsibility") [3] | Primary Admin, Secondary Admin, Salesperson (CA/Biller/Stock-keeper roles exist in product, not on reachable pages); "separate password for each user"; per-user restrictions on "delete/edit transactions, take data back-up, see purchase price"; up to 3/5/unlimited firms per plan [3] | **Audit Trail**: "automatically start recording every small change made to your transactions", "View History" per transaction, "Even after cancellation, the full transaction history remains available"; entries remain editable/deletable by permitted users; no signing [3] | Device-local DB; sync via Vyapar servers ("images … stored on our servers", "encrypts your data during sync"); encryption at rest "advanced encryption methods" (unspecified); T&C grants Vyapar a licence to "use, reproduce, adapt, modify, publish or distribute the content … for Vyapar internal purpose"; deletion on request; transactional logs kept 6 months [3] |
| myBillBook | Offline ns (cloud-synced); conflict ns [4] | Admin, Partner, Salesman, Delivery boy, CA (vendor design article); plan seats "1 user + 1 CA" / "3 users + 1 CA"; "Add your staff like salesman, delivery boys, stock managers … give them access to certain features" [4] | ns (no audit-trail or lock feature found) [4] | "Data is securely stored with end-to-end encryption on cloud servers", "bank-grade security" (Play listing); privacy and user-management pages JS-only; staff access, location, export: ns [4] |
| Swipe | Offline ns; conflict ns [5] | "add multiple users, businesses"; roles ns; "Unlimited users" on startup plan [5] | e-invoice IRN/QR through GST IRP for applicable firms; no ledger signing or lock stated; audit ns [5] | Vendor cloud; "Your data stays private. Always encrypted."; privacy policy: storage location, at-rest encryption, staff access **not disclosed**; GDPR-style erase/transfer rights listed [5] |
| TallyPrime | Fully offline on PC; multi-user over LAN (Gold); Remote Access / Cloud Access need TSS + internet; browser reports view-only [6] | Owner + users with security levels (Data Entry etc.), Tally.NET IDs for remote; TallyVault password-encrypts company data (page not fetched; known feature - UNVERIFIED here) [6] | **Edit Log**: logs "Created, Altered, … Deleted" with "Username and Date & Time"; in the Edit Log release "not possible to disable" and "not possible to remove or delete the Edit Log data"; vouchers still editable/deletable → audit log, not immutability; MCA audit-trail rule is the driver [6] | On-premises file; TallyDrive copies to Tally cloud ("encrypted, password-protected"), Cloud Access on Oracle Cloud; 90-day retention after TSS lapse [6] |
| Biz Analyst | "truly offline app. Your data is stored on your mobile phone"; sync with the Tally PC; conflict ns [7] | Admin grants limited access; "no restriction on the number of users", charged per device; any number of Tally companies [7] | Relies on Tally; entries created on phone post into Tally [7] | Phone + PC; "completely encrypted during the sync process and can only be accessed on your devices"; whether a relay server exists: ns [7] |
| Zoho Books | Cloud; mobile offline ns (user-voice requests exist, no feature page) [8] | Super Admin, Admin, Staff, Timesheet Staff, Staff (assigned customers), custom roles; Accountant invite "to handle tax filing, auditing, and compliance"; users capped per plan [8] | **Transaction Locking**: "cannot be added, modified, or deleted if recorded before the specified lock date"; per module; admin can unlock or unlock a period → period immutability, not entry signing; audit trail exists (help page not reachable) [8] | Vendor cloud; "Sensitive customer data at rest is encrypted using 256-bit AES", TLS in transit; "technical access controls and internal policies to prohibit employees from arbitrarily accessing user data"; ISO 27001/27017/27018, SOC 1, SOC 2 Type 2; India data centres referenced for SOC 1 [8] |
| BUSY | Desktop offline; cloud/mobile Lite paid [9] | Multi-user per plan ("10 users" on Power+) [9] | ns | On-prem; BUSY On Cloud ns [9] |
| MargBooks | ns | "plans vary based on users, GSTINs" [10] | ns | Vendor cloud; ns [10] |
| BharatBills | Offline-tolerant [11] | ns | ns | Play data-safety: "No data collected or shared with third parties" [11] |
| HisabKhata | "Works offline" [12] | ns | ns | Vendor cloud (web app); ns [12] |
| Paytm / PhonePe / BharatPe | Payment apps need network [13] | Merchant login; staff/sub-user ns | n/a | Vendor cloud; ns |
| Open Money | Cloud | Budgets, policies, roles for reimbursement [14] | ns | Vendor cloud; ns |
| Wave | Cloud | Pro: "admin, editor, or viewer roles" [15] | ns | "up to 256-bit TLS", encrypted at rest, "PCI Level 1 Service Provider", "limiting access to only the people who need it to do their jobs" [15] |
| Bokio | Cloud | 1-3 users per plan, +49 kr/user [16] | ns | Vendor cloud [16] |
| bexio | Cloud | 1/2/5/25 users per plan [17] | ns on reachable pages (Swiss GeBüV compliance not fetched) | "stored and processed exclusively in Switzerland", ISO 27001, SSL in transit, encrypted backups in several data centres; 30-day export after cancellation; staff access ns [17] |
| Banana | Local file, fully offline; no sync (user copies file) [18] | Single file, OS-level; no roles [18] | "Lock transactions with the Blockchain technology": each row's hash (LockProg) chains contents, running balance and previous hash; "one cannot prevent that the data are being altered, but it will allow you to know if the data are the original ones"; unlock possible [18] | User's own disk; no operator [18] |
| SumUp / Zettle | Online POS | Staff accounts (not fetched) | n/a | Vendor cloud [19] |

---

## 3. The "small fee only for sync" pattern

Products that already split "free on one device" from "pay to sync":

| Product | Free part | What the fee buys | Fee |
|---|---|---|---|
| **OkCredit** | Whole khata, offline, online backup, QR collection | Multi-device login (bundled with no-ads, GST bills, desktop) | ₹75/mo |
| **Vyapar** | Full mobile app, offline, Google Drive backup | Multi-device sync + more firms, licence per device | Mobile Gold ₹999-₹1,109/yr (App Store); desktop Gold ₹4,099/yr |
| **Biz Analyst** | 7-day trial only | Per-device sync with the Tally PC | ₹3,300/device/yr |
| **TallyDrive** | 1-3 GB cloud backup with TSS | Extra cloud storage | ₹1,200/yr per 10 GB |
| **BUSY** | Express desktop, offline | Mobile Lite app + cloud after year one | from ₹5,000/360 days |
| **Bokio** | - | Bank feed, extra users as add-ons | 49 kr/mo each |
| **Banana** | Local file, 70 transactions | More transactions; no sync offered | CHF 89/yr |
| *(earlier note)* Smart Receipts, Actual Budget | Local app | Cloud backup / self-hosted sync server | small or self-hosted |

Observations (inference, labelled):

- Nobody sells sync **alone**. OkCredit bundles it with ad removal and GST
  bills; Vyapar bundles it with company count and features. But in both, the
  sync is the headline reason a one-phone shop would upgrade, and the price
  points (₹75/month, ~₹1,000/year) show what the segment tolerates.
- Every paid sync in India is **vendor-cloud sync**, so the fee also pays
  for storage and the vendor can read the books. Only Biz Analyst phrases it
  as device-to-device ("can only be accessed on your devices"), and it still
  needs the Tally PC switched on.
- Payment collection is **free** everywhere (0% UPI MDR is a regulatory
  fact in India), so nobody can cross-subsidise the books from payment fees
  the way Wave/SumUp do; Indian vendors monetise through subscriptions,
  loans (Khatabook, PhonePe, BharatPe) and hardware (sound boxes).
- The "dedicated person on a computer" the user describes is served today by
  Tally + Biz Analyst (owner on the phone, accountant on the PC, ₹3,300/yr
  per phone) or by Vyapar/myBillBook multi-user plans where the accountant
  gets a "CA" seat (myBillBook: "1 user + 1 CA").

## 4. Does anything already cover the user's four points?

| Requirement | Who does it | How well |
|---|---|---|
| (a) Runs fully on phones for a bookkeeper + owner | Vyapar (mobile Gold, licence per device), myBillBook (3 users, unlimited devices, mobile + web), Swipe, OkCredit Ads Free++ | Yes for all four, but Vyapar is the only one that states offline-first; the others need the cloud |
| (b) Online payment lands in the books automatically | Khatabook and OkCredit (QR payment "posts to their khata automatically"), Zoho Books via Razorpay/ICICI, Vyapar (claims matching) | Khata apps: yes but into a customer ledger, not double-entry books. Zoho: yes, full books, but ₹749/mo+ and cloud. Vyapar: stated in a blog, gateway and fee not disclosed |
| (c) Sync across devices | All of the above | Always through the vendor's cloud; no LAN or peer sync |
| (d) Charge mainly for sync, rest free | OkCredit (₹75/mo), Vyapar mobile (~₹1,000/yr) | Closest matches; both bundle other features with the sync tier |

**Closest overall**: Vyapar for a real bookkeeping use (expenses, cash/bank,
GST, free offline single device, paid sync), and OkCredit for the pricing
shape (free forever, ₹75/month for multi-device). Neither has:

- a staff **expense-claim / reimbursement** flow (only Zoho Books add-on at
  ₹149-₹199 per user per month and Open Money at ₹4,000/month do);
- an explicit **double-entry** ledger with immutable history exposed to the
  user (Tally and Zoho have double-entry, the khata/billing apps do not
  state it);
- **serverless or end-to-end-encrypted** sync; every one stores the books on
  the vendor's servers and none makes an E2EE claim;
- a fee that is **only** for sync.

That gap - free offline double-entry books on every phone, claims from the
owner's phone into the company books, sync that never touches a vendor
server, and a small fee only when sync has to leave the shop's Wi-Fi (see
`remote-sync-and-claim-options.md`, Option 4 relay) - is exactly the space
none of the sixteen Indian products checked occupies. The price anchors for
that fee, from this market, are ₹75/month (OkCredit) to about ₹1,000/year
(Vyapar mobile Gold), with ₹3,300/year per device (Biz Analyst) as the upper
bound small businesses already pay for "phone synced to the accountant's
books".

## 5. Not verified / could not read

- Vyapar's own pricing page and myBillBook's, Marg's and Khatabook's privacy
  pages are JavaScript-only or blocked; mobile Silver/Gold/Platinum prices
  for Vyapar (₹699/₹799/₹2,399) and myBillBook's Diamond/Platinum/Enterprise
  prices are from third parties. Vyapar's App Store in-app-purchase list is
  vendor-published and is the figure to trust.
- Whether Vyapar's and myBillBook's received UPI payments post into the
  books automatically (Vyapar's blog says payments "automatically get
  matched"; neither names the gateway or fee).
- Whether Khatabook's iOS listing (developer name differs) is the official
  app; Khatabook's data-storage location and encryption.
- Offline behaviour of Khatabook, myBillBook and Swipe (not stated).
- Marg ERP 9+ desktop prices and MargBooks plan details.
- Paytm Soundbox rental and BharatPe device prices.
- Swipe free-plan limits (third-party says unlimited invoices).
- Play Store "Data safety" sections for every app (robots.txt blocks the
  fetch); the only data-safety statement quoted is BharatBills', seen in its
  listing summary.
- Conflict handling when two devices edit offline: no vendor documents it.
- Zoho Books Audit Trail help page and Accountant-seat pricing (404s);
  TallyVault details (page not fetched).
- Vyapar's full role list (CA, Biller, Stock keeper) and whether Audit
  Trail is a paid feature; myBillBook role permissions (JS-only pages,
  design article used instead).

## Sources

All read 2026-10-05. Footnote numbers in the main table: [1] Khatabook,
[2] OkCredit, [3] Vyapar, [4] myBillBook, [5] Swipe, [6] Tally, [7] Biz
Analyst, [8] Zoho Books, [9] BUSY, [10] MargBooks, [11] BharatBills,
[12] HisabKhata, [13] Paytm/PhonePe/BharatPe, [14] Open Money, [15] Wave,
[16] Bokio, [17] bexio, [18] Banana, [19] SumUp/Zettle; GST e-invoice:
https://einvoice1.gst.gov.in/ .

- Vyapar: https://play.google.com/store/apps/details?id=in.android.vyapar ;
  https://apps.apple.com/in/app/vyapar-billing-accounting/id6478382307 ;
  https://vyaparapp.in/gst-accounting-pc ;
  https://vyaparapp.in/guides/how-to-use-vyapar-app-on-multiple-devices ;
  https://vyaparapp.in/blog/sync-multiple-devices-vyapar/ ;
  https://vyaparapp.in/blog/vyapar-app-features/ ;
  https://vyaparapp.in/free/small-business-accounting-software/cloud-based ;
  https://vyaparapp.in/free/invoice-reminder-software ;
  https://vyaparapp.in/blog/integrate-payment-gateway-business-software/ ;
  https://vyaparapp.in/faq ; https://vyaparapp.in/privacy ;
  https://vyaparapp.in/terms ; https://vyaparapp.in/videos/how-to-use-audit-trail ;
  https://vyaparapp.in/blog/how-to-assign-user-role-permission-in-vyapar/ ;
  https://vyaparapp.in/blog/user-roles-permissions-vyapar/ ; third-party:
  https://www.itforsme.in/pricing/vyapar-india ,
  https://www.108techsolutionz.com/vyapar-app-1-year-mobile-plans.html
- Khatabook: https://khatabook.com/en ;
  https://play.google.com/store/apps/details?id=com.vaibhavkalpe.android.khatabook ;
  https://khatabook.com/blog/khatabook-app-features/ ;
  https://khatabook.com/help/en-us/category/X1Uq1BAAACUAXK03/ ;
  https://apps.apple.com/us/app/id6633420817 ; https://pagarbook.com/pricing/
- OkCredit: https://okcredit.in/ ; https://okcredit.in/en/ ;
  https://okcredit.in/pricing ; https://okcredit.in/faq ; https://okcredit.in/privacy
- myBillBook: https://mybillbook.in/ ;
  https://play.google.com/store/apps/details?id=com.valorem.flobooks ;
  https://mybillbook.in/ca-icai ; vendor design write-up:
  https://medium.com/design-bootcamp/multi-user-feature-in-mybillbook-app-795499370498 ;
  third-party: https://www.techjockey.com/detail/mybillbook-accounting-software
- Swipe: https://getswipe.in/ ;
  https://play.google.com/store/apps/details?id=in.swipe.app ;
  https://apps.apple.com/in/app/swipe-billing-invoicing-app/id6451307318 ;
  https://getswipe.in/blog/startups ; https://getswipe.in/terms ;
  https://getswipe.in/policy ; third-party:
  https://saasrat.com/products/swipe-billing
- Tally: https://tallysolutions.com/tally/tallyprime-pricing/ ;
  https://tallysolutions.com/tally/tallydrive/ ;
  https://tallysolutions.com/tally/tallyprime-cloud-access/ ;
  https://help.tallysolutions.com/tally-prime/connected-services/browser-reports-faq-tally/ ;
  https://help.tallysolutions.com/tally-prime/connected-services/work-from-home-or-anywhere/ ;
  https://help.tallysolutions.com/edit-log-in-tallyprime-faq/ ;
  https://help.tallysolutions.com/tracking-modifications/
- Biz Analyst: https://bizanalyst.in/ ; https://bizanalyst.in/pricing
- Zoho Books: https://www.zoho.com/in/books/pricing/ ;
  https://www.zoho.com/in/books/help/online-payments/razorpay.html ;
  https://www.zoho.com/in/books/academy/banking-and-payments/upi-payments-with-zoho-books.html ;
  https://www.zoho.com/in/books/help/accountant/transaction-lock.html ;
  https://www.zoho.com/in/books/help/settings/users.html ;
  https://www.zoho.com/us/books/kb/users-and-roles/accountant-role.html ;
  https://www.zoho.com/security.html ; https://www.zoho.com/compliance.html
- BUSY: https://busy.in/pricing/
- MargBooks: https://www.margbooks.com/
- BharatBills: https://play.google.com/store/apps/details?id=in30days.bharatbills
- HisabKhata: https://www.hisabkhata.in/
- Paytm: https://business.paytm.com/ ; https://business.paytm.com/pricing
- PhonePe: https://business.phonepe.com/ ;
  https://apps.apple.com/in/app/phonepe-business-merchant-app/id1463742453 ;
  https://cms.phonepe.com/en/mx/merchant-help/phonepe-smartspeaker/about-phonepe-smartspeaker/what-are-charges-applicable-phonepe-smartspeaker/
- BharatPe: https://bharatpe.com/
- Open Money: https://open.money/pricing ; Dukaan: https://mydukaan.io/pricing
- Wave: https://www.waveapps.com/pricing ; https://www.waveapps.com/receipts ;
  https://www.waveapps.com/legal/security-and-privacy ;
  https://support.waveapps.com/hc/en-us/articles/115004085146-How-Wave-keeps-your-data-secure
- Bokio: https://www.bokio.se/priser/
- bexio: https://www.bexio.com/en-CH/packages-and-prices ;
  https://www.bexio.com/en-CH/cloud ; https://www.bexio.com/en-CH/policies/privacy-policy
- Banana: https://www.banana.ch/en/buy ; https://www.banana.ch/doc/en/node/3353
- SumUp: https://www.sumup.com/en-gb/pricing/ ; Zettle: https://www.zettle.com/gb/pricing
