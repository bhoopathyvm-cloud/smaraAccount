# Research: Small-business bookkeeping apps in Europe and the USA

The question: the same analysis as
`india-mobile-first-bookkeeping.md`, but for Europe (CH, DE/AT, FR, Benelux,
Nordics, UK) and the USA. Which mobile-first or small-business bookkeeping
apps serve an owner plus perhaps a bookkeeper, and how do they handle
offline use, multi-device sync (and whether sync is the paid part), online
payments posting into the books, employee expense claims, double-entry,
tamper-proofing vs. audit logs, where the data lives and whether the vendor
can read it, and pricing.

Gathered 2026-10-05. Everything below was read that day on the vendor's own
pricing page, help centre, security page or official documentation (see
[Sources](#sources)) unless marked **third-party** or **UNVERIFIED**.
"ns" = not stated on any vendor page I could reach. Several pages render
prices only through JavaScript (QuickBooks UK, Crunch, Manager.io Cloud) or
refused automated reads (Yokoy, Hibiscus); those are listed in
[Not verified](#7-not-verified--could-not-read). Prices exclude VAT unless
stated. Banana Accounting+ was researched in depth in the India note and is
carried into the table for comparison only. Expense-claim specialists
(Expensify, Ramp, Brex, Pleo, Spendesk, Rydoo, Concur) and the sync designs
are in `expense-and-accounting-competitor-pricing.md` and
`remote-sync-and-claim-options.md` and are not repeated.

## Short answer

Europe and the USA have a dense layer of **cloud bookkeeping for owners and
their accountant** (bexio, sevdesk, Lexware Office, Pennylane, Moneybird,
Bokio, FreeAgent, Xero, QuickBooks, Wave, Zoho Books) and a newer layer of
**bank-account-plus-books apps** that are genuinely mobile-first (Qonto,
Shine, Indy, Tiime, Kontist, Holvi, ANNA, Tide, Starling, Found, Lili, Novo).
Almost all of them:

- run on phone **and** web, but **none works offline**: every cloud product
  checked is online-only, and the few that mention offline at all are the
  desktop/local tools (GnuCash, MoneyMoney, Banana, Manager Desktop,
  Moneydance, Actual Budget);
- sync across devices **through the vendor's server**, and sync is **bundled
  into the subscription** rather than sold separately. The "pay for sync"
  pattern that exists in India (OkCredit, Vyapar) does **not** appear in
  Europe or the USA. The closest relatives are: per-user seats (bexio,
  Billomat +€10/user, Bokio +49 kr/user, FreshBooks +$11/user, e-conomic
  +149 kr/user), Actual Budget (free software, you pay a host ~$2/month for
  the sync server), and Banktivity/Moneydance (local apps where the
  subscription or add-on mainly buys bank downloads and device sync);
- post online payments into the books **when the payment runs through the
  vendor's own rail**: bank-account-plus-books apps reconcile their own card
  and transfer traffic automatically (Starling "match incoming payments to
  invoices ... and mark them as paid", SumUp "Schneller Zahlungsabgleich",
  Holvi, Qonto, Shine, Found, Lili), and the accounting suites mark invoices
  paid through Stripe/GoCardless/PayPal/Mollie/iDEAL/Swish integrations
  (FreeAgent, Xero, QuickBooks, Zoho, Wave, Moneybird, Bokio, AbaNinja with
  TWINT). Third-party card data still needs manual categorisation in several
  (bexio Pay via amnis: "must always be manually assigned");
- keep **readable books on the vendor's servers**. The strongest claims are
  location and process: bexio, CashCtrl, Accounto, KLARA ("exclusively in
  Switzerland"), Pennylane (ISO 27001, AWS Ireland + SecNumCloud France),
  BuchhaltungsButler/FastBill/Kontolino/GetMyInvoices/Moss ("Serverstandort
  Deutschland"), Wave (PCI DSS Level 1, "limiting access to only the people
  who need it"). **No cloud bookkeeping product checked claims end-to-end or
  zero-knowledge encryption.** Only Actual Budget (optional E2EE, you host
  the sync server) and the pure local apps (GnuCash, MoneyMoney, Banana,
  Manager Desktop) keep the books out of the operator's reach.

On **tamper-proofing** the regions split sharply:

- **Germany/Austria** is the one market where "entries cannot be altered" is
  a regulated, advertised feature. GoBD requires *Festschreibung*: Lexware
  Office ("Mit der Festschreibung sind Buchungen im Anschluss unveränderbar
  und können somit nicht mehr gelöscht werden", automatic monthly run),
  sevdesk ("Die Daten sind nicht mehr veränderbar. Eine Löschung ist nicht
  mehr möglich"; invoices fixed automatically on completion; corrections by
  Generalumkehr), DATEV, BuchhaltungsButler, Kontolino, Papierkram all sell
  this. It is enforced by the application, not by cryptography, and the
  vendor holds the plaintext.
- **Switzerland** has the legal hook (OR 957a; GeBüV Art. 3 "nicht geändert
  werden können, ohne dass sich dies feststellen lässt"; Art. 9 allows
  changeable media only with "digitale Signaturverfahren" or time stamps)
  but, apart from Banana's hash-chain lock, none of the Swiss cloud vendors
  checked (bexio, AbaNinja, KLARA, CashCtrl, Atlanto, Milkee, Run my
  Accounts, Accounto) states on its public pages how it meets it.
- **Sweden/Denmark** rely on law plus registration: Bokio never deletes a
  posted verifikat except the latest one within 30 days ("Tumregeln ... att
  man inte får radera enskilda verifikat"; corrections create an
  annulleringsverifikat and the original stays visible under "Visa
  inaktiva"); Dinero is "certificeret af Erhvervsstyrelsen" as a registered
  digital bookkeeping system under the Danish bogføringslov.
- **France** has NF525 for cash-register software, not for bookkeeping;
  Pennylane's security page says ISO 27001 and nothing about NF525/NF203.
- **UK/US**: period locks and audit logs only. Xero lock dates, QuickBooks
  "Close the books" (an admin with the password can still edit: "Allow
  changes after viewing a warning and entering password"), FreeAgent locked
  periods and VAT returns, Zoho Books transaction locking (admin can
  unlock), Pandle transaction locking. MTD requires digital records but, in
  the HMRC text read, "contains no language addressing immutability".

**No product in either region combines** a double-entry ledger, an
employee claim flow, device-to-device sync without a vendor server, per-entry
signing, and a fee that buys only the sync. The closest existing shapes:

| Region | Closest to Smara's shape | What it still lacks |
|---|---|---|
| CH | Banana (local, hash-chain lock, free ≤70 tx) | desktop only, no sync, no claims, no payments |
| CH | bexio / AbaNinja (double-entry, TWINT/Stripe into books, Spesen, CH-hosted) | online-only, vendor reads books, no cryptographic lock |
| DE | sevdesk / Lexware Office (Festschreibung enforced in-app, mobile apps, bank+PayPal) | online-only, vendor reads books, lock is application logic |
| DE | MoneyMoney + Hibiscus (local encrypted DB, FinTS) | not bookkeeping, no sync, no claims |
| SE/DK | Bokio, Dinero (no-delete ledger, utlägg, Swish/MobilePay) | online-only, vendor reads books |
| UK | FreeAgent (free with NatWest/Mettle), Pandle (free), Starling Accounting (£7) | online-only, period lock only, no E2EE |
| US | Wave (free), Zoho Books (free ≤$50k), Found/Lili (bank + books) | online-only, no immutability, no E2EE |
| any | Actual Budget (local-first, optional E2EE, self-hosted sync) | household budgeting, not double-entry books, no claims, "avoid simultaneous usage" |

---

## 0. Main table

Legend: ✓ yes · ✗ no · ◐ partial · ns = not stated on any vendor page I
could reach. Footnote numbers point to [Sources](#sources). Price = as read
2026-10-05, headline tiers, ex-VAT unless stated. *Mobile-first* ✓ means the
phone app is a full client (or the product is app-centric); ◐ means a
companion app (scan receipts, send invoices) with the web as the main
surface. *Offline* ✗ means the vendor describes a cloud/online product and
says nothing about offline use. *Sync (paid?)* says how devices share data
and whether that sharing is what you pay for. *Payments into books* ✓ means
a payment collected online is matched/posted automatically. *Tamper-proof /
signing* answers "can a posted entry be altered without trace?": ✓ = cannot
be altered or alteration is detectable by construction; ◐ = application-
enforced lock (period lock, Festschreibung) that an admin or the vendor can
lift; ✗ = editable. *Audit log* = a who/when/what change history.
*Operator can read data* ✓ = vendor holds plaintext books; ✗ = books never
leave the user's devices.

| Product | Region | Price (free → paid) | Mobile-first | Offline | Multi-device sync (paid?) | Online payments into books | Expense claims | Double-entry | Tamper-proof / signing | Audit log | Operator can read data | E2EE |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| **bexio** [1] | CH | 30-day trial; Basic CHF 35, Advanced 42, Optima 69, Ultimate 119 /mo (annual; +CHF 10/mo if monthly); 1/2/5/25 users | ◐ bexio Go app | ✗ | ✓ bundled, seats per tier | ◐ bexio Pay cards auto-post but "must always be manually assigned" a category; e-banking in all tiers | ✓ "Smart expense management" | ✓ | ns | ns | ✓ "servers ... deliberately located in Switzerland", ISO 27001:2022 | ✗ |
| **Banana Accounting+** [2] | CH | Free ≤70 tx; CHF 89 / 179 per yr | ✗ desktop | ✓ local file | ✗ none | ✗ | ✗ | ✓ | ✓ hash-chain lock (detect, not prevent) | ◐ via lock | ✗ local file | n/a |
| **AbaNinja** (Abacus/Swiss21) [3] | CH | Starter free (1 user, 1,000 docs/yr); Basic CHF 21/mo (3 users); Pro CHF 49/mo (5 users) | ◐ AbaClik app | ✗ | ✓ bundled | ✓ "Stripe, TWINT, PayPal und Überweisung. Voll integriert"; 70+ banks daily sync | ◐ receipt scan + AI | ✓ Bilanz/Erfolgsrechnung | ns | ns | ✓ Swiss cloud | ✗ |
| **KLARA Business** [4] | CH | 30-day trial; Basic CHF 69, Plus 99, Premium 159 /mo (CHF 48/69/111 on 2-yr) | ◐ myKLARA app | ✗ | ✓ bundled (Basic ≤3 admins; Plus/Premium unlimited) | ◐ Payments module, Pay-by-Link; auto-posting ns | ✓ "expenses and credit card receipts" | ✓ | ns | ns | ✓ Lucerne-based; hosting ns | ✗ |
| **CashCtrl** [5] | CH | FREE (1 user, 1 org, full accounting); PRO price via calculator (3 users, 2 orgs, 1 GB); FL4T CHF 3,900/yr | ✗ web | ✗ | ✓ bundled | ◐ ISO 20022 bank import (PRO); payments ns | ns | ✓ | ns | ns | ✓ "Operation/backups only on Swiss servers" | ✗ |
| **Atlanto** [6] | CH | 1st month free; Sales+Accounting CHF 44.90 /user/mo; Contact Manager free | ◐ app | ✗ | ✓ bundled, per user | ◐ SumUp partnership page; posting detail ns | ns | ✓ | ns | ns | ✓ cloud | ✗ |
| **Milkee** [7] | CH | 14-day trial; Basic CHF 24.90, Business 34.90, Team 69.90 /mo (annual) | ◐ app | ✗ | ✓ bundled (2/3/5 users) | ◐ bank connection; payments ns | ◐ AI receipt scans (120/300/unlimited) | ◐ Basic simple; Business/Team double-entry | ns | ns | ✓ cloud; location ns | ✗ |
| **Run my Accounts** [8] | CH | Software: Startup free; KMU CHF 25/mo + CHF 10/user; outsourced bookkeeping CHF 0/35/290 base + CHF 1.80/1.40/0.95 per entry | ◐ "iPhone / Android App" | ✗ | ✓ bundled, per user | ◐ daily bank sync, payment processing by the service | ◐ receipt upload to bookkeepers | ✓ | ns | ns | ✓ cloud + staff bookkeepers read books by design | ✗ |
| **Accounto** [9] | CH | Not published (sold via Treuhand firms) | ✗ | ✗ | ✓ bundled | ◐ automated bank reconciliation | ◐ "Digitale Beleganlieferung" | ✓ | ns | ns | ✓ "in der Schweiz ... Tier-3-Rechenzentrum" | ✗ |
| **Lexware Office** (ex lexoffice) [10] | DE | 30-day trial; S €7.90, M €12.90, L €21.90, XL €32.90 /mo (50% off 3 mo) | ◐ apps | ✗ | ✓ bundled | ◐ Multibanking; PayPal integration; "Bezahlung offener Belege" | ◐ Belegerfassung; claims workflow ns | ✓ (L+) | ◐ **Festschreibung**: "Buchungen im Anschluss unveränderbar und können somit nicht mehr gelöscht werden"; automatic monthly | ✓ "Alle Änderungen werden lückenlos nachvollziehbar aufbewahrt" | ✓ cloud (location ns on pages read) | ✗ |
| **sevdesk** [11] | DE/AT | Free tier; Rechnung €9.90, Buchhaltung €22.90, Pro €30.90 /mo (annual; €11.90/25.90/34.90 monthly) | ◐ apps | ✗ | ✓ bundled | ◐ 4,000+ banks; payments ns | ◐ AI Belegerfassung; claims ns | ✓ | ◐ **Festschreibung**: "Die Daten sind nicht mehr veränderbar. Eine Löschung ist nicht mehr möglich"; invoices fixed on completion; Generalumkehr | ◐ "Nachvollziehbare Änderungshistorie" | ✓ cloud; location ns | ✗ |
| **DATEV Unternehmen online** [12] | DE | €11.56/mo, only via a DATEV member (Steuerberater) | ◐ | ✗ | ✓ bundled (firm + client) | ◐ bank via PIN/TAN, EBICS | ◐ receipts to the Kanzlei | ✓ (in the Kanzlei's DATEV) | ◐ "GoBD-konformes Kassenbuch"; Festschreibung ns on page | ns | ✓ "DATEV-Rechenzentrum" | ✗ |
| **BuchhaltungsButler** [13] | DE | 14-day trial; Light €39.90, Smart €46.90, Premium €89.90 /mo; +€4.90/user | ◐ Scan app | ✗ | ✓ bundled | ✓ PayPal, Stripe, Amazon, eBay, Shopify feeds | ◐ Premium "approval workflows" | ✓ | ◐ "GoBD-konform" | ns | ✓ "Frankfurt server" | ✗ |
| **FastBill** [14] | DE | 14-day trial; Solo €9, Plus €14, Pro €27, Premium €53+ /mo (annual) | ◐ Scan app | ✗ | ✓ bundled (1/1/3/5 users) | ◐ customer portal "mit Bezahlmöglichkeit" (Pro+) | ◐ receipt mgmt | ◐ invoicing-first | ◐ "GoBD-konforme Aufbewahrung" | ns | ✓ "Hosting in Deutschland" | ✗ |
| **Billomat** [15] | DE | 14-day trial; Professional €19, Business €29, Enterprise €99 /mo (annual); +€10/user | ✗ (app ns) | ✗ | ✓ bundled | ✓ Mollie (Business+) | ns | ◐ | ns | ns | ✓ cloud; location ns | ✗ |
| **Kontist** [16] | DE | Free; Start €11; Plus €25 /mo (bank account + sevdesk bundle 3/6/12 months) | ✓ app-centric bank | ✗ | ✓ bundled | ✓ own account; books via sevdesk | ✗ | via sevdesk | via sevdesk | ns | ✓ | ✗ |
| **Holvi** [17] | FI/DE | Flex €0; Lite €9; Pro €15; Business €69 /mo | ✓ app | ✗ | ✓ bundled | ✓ own payment account; receipts attach to transactions | ◐ receipts per app | ✗ (reports/exports, not a ledger) | ns | ns | ✓ payment institution (FIN-FSA) | ✗ |
| **SumUp Invoices** (ex Debitoor) [18] | DE/EU | Free (≤4 e-invoices/mo); Plus €4/mo (annual, promo) | ✓ mobile | ✗ | ✓ bundled | ✓ "Schneller Zahlungsabgleich" via SumUp account; "Automatische Ausgabenverfolgung" | ✗ | ✗ invoicing + expenses | ◐ "GoBD-Konformität", "Revisionssichere Archivierung" | ns | ✓ | ✗ |
| **Kontolino** [19] | DE | 2-month trial; Basis €11, Standard €14, Classic €19, XL €30, XXL €41 /mo | ◐ Foto-App | ✗ | ✓ bundled (1/3/3/5/5 users) | ◐ bank connections (2–25) | ◐ | ✓ | ◐ GoBD archive add-on €2/mo | ns | ✓ "Datenspeicherung ... in Deutschland" | ✗ |
| **Papierkram** [20] | DE | Free; S €12.90, M €24.90, L €49.90 /mo (annual) | ◐ (app ns) | ✗ | ✓ bundled | ◐ PSD2 bank; payments ns | ns | ✓ | ◐ "GoBD-Zertifizierung" | ns | ✓ cloud | ✗ |
| **Circula** [21] | DE | Expenses "ab 15€ pro Lizenz", 10-licence min; cards ab €99 platform | ✓ app + web | ns | ✓ bundled | n/a (claims tool) | ✓ claims, per diem, mileage, DATEV | n/a | ◐ GoBD for DMS add-on | ns | ✓ | ✗ |
| **Moss** [22] | DE/UK | Modular platform fee, "single platform fee regardless of the number of users", prices not published | ✓ app | ns | ✓ bundled | n/a | ✓ reimbursements module | n/a | ns | ns | ✓ "Developed and hosted in Germany" | ✗ |
| **Pennylane** [23] | FR | 15-day trial; Starter €7, Basique €14, Essentiel €24, Premium €79 /mo (indépendant) | ◐ app | ✗ | ✓ bundled | ✓ payment link on invoices; pro account with cards; bank sync | ✓ notes de frais (Essentiel+) | ✓ | ns (NF525/NF203 not mentioned) | ns | ✓ "AWS en Irlande" + "S3NS en France ... SecNumCloud"; ISO 27001; "contrôlons tous les accès ... par les collaborateurs autorisés" | ✗ |
| **Tiime** [24] | FR | Free; Initial €9.99, Smart €17.99, Business €24.99 /mo (annual) | ✓ app | ✗ | ✓ bundled | ✓ Tiime pro account; Stripe/GoCardless | ◐ notes de frais + mileage | ◐ | ns | ns | ✓ | ✗ |
| **Indy** [25] | FR | Essentiel €0; Plus €9; Premium €15–49; Expert-Comptable €63–108 /mo | ✓ app | ✗ | ✓ bundled | ✓ own pro account (FR IBAN, Mastercard); 12 bank accounts | ◐ | ✓ "comptabilité automatisée" | ns | ns | ✓ "Servers in France", "chiffrement de données" | ✗ |
| **Qonto** [26] | FR/DE/ES/IT | Basic €9, Smart €19, Premium €39 (solo); Essential €49, Business €109, Enterprise €199 /mo (annual) | ✓ app | ✗ | ✓ bundled, "Nombre illimité d'utilisateurs" | ✓ own account; invoices + receipts reconciled | ✓ expense management, cards | ◐ pre-accounting; export to accountant | ns | ns | ✓ ACPR-regulated payment institution; data location ns | ✗ |
| **Shine** [27] | FR | Free; Start €9; Plus €20; Business €45 /mo | ✓ app | ✗ | ✓ bundled | ✓ own account | ◐ team access €5/mo each (Plus) | ✗ pre-accounting | ns | ns | ✓ | ✗ |
| **Moneybird** [28] | NL | 60-day trial; Compact €3, Start €15, Growth €29, Complete €41 /mo | ◐ app | ✗ | ✓ bundled (1/1/5/unlimited users) | ✓ iDEAL €0.29, SEPA DD €0.25 per tx; 1,700+ banks | ◐ receipt scanning | ✓ | ns | ns | ✓ | ✗ |
| **Exact Online** [29] | NL/BE | 30-day trial; Essentials €49, Plus €99, Professional €159, Premium €299 /mo | ◐ app | ✗ | ✓ bundled; extra users €23–49 | ◐ payment links | ns | ✓ | ns | ns | ✓ | ✗ |
| **Silvasoft** [30] | NL | 30-day trial; modular, Boekhouden €13.95 /user/mo | ns | ✗ | ✓ bundled | ns | ns | ✓ | ns | ns | ✓ | ✗ |
| **Bokio** [31] | SE/UK | 14-day trial; Basic 269, Premium 359, Business 459, Plus 599 kr/mo; +49 kr/user; bank 49 kr/mo; Swish 49 kr/mo + 2 kr/tx | ◐ app | ✗ | ✓ bundled; **extra user +49 kr/mo** | ✓ Swish Företag add-on | ✓ utlägg (Premium+) | ✓ | ◐ **no-delete ledger**: posted verifikat only annulled (except latest within 30 days); lock reconciled period | ✓ inactive verifikat kept visible | ✓ | ✗ |
| **Fortnox** [32] | SE | Mini 209, Liten 349, Mellan 490, Stor 710 kr/mo (12-mo); 6 months free for new companies; Kvitto & Utlägg 4.90 kr/receipt | ◐ app | ✗ | ✓ bundled | ✓ Swish/Stripe via integrations | ✓ pay-per-receipt | ✓ | ns | ns | ✓ | ✗ |
| **e-conomic** (Visma) [33] | DK | Basis 249, Plus 299, Smart 399, Komplet 649 kr/md; **extra user 149 kr/md** | ◐ free app | ✗ | ✓ bundled, per user | ◐ Firmakort; bank direct | ◐ Smart Inbox scanning | ✓ Finansbogholderi | ns | ns | ✓ ISAE 3000/3402 | ✗ |
| **Dinero** [34] | DK | Starter free (≤100,000 kr revenue); Starter+ 245, Pro 345, Total 545 kr/md (annual) | ◐ | ✗ | ✓ bundled | ◐ | ◐ | ✓ | ◐ "certificeret af Erhvervsstyrelsen" (registered digital bookkeeping system) | ns | ✓ | ✗ |
| **Billy** [35] | DK | Free (3 invoices, 10 receipts/mo); Basic 160, Plus 295, Complete 595 kr/md | ◐ app | ✗ | ✓ bundled; unlimited users (Plus+) | ✓ card on invoices, MobilePay (Plus+) | ◐ | ✓ | ◐ bogføringslov positioning | ns | ✓ | ✗ |
| **FreeAgent** [36] | UK | £19 sole trader / £27 partnership / £33 Ltd per mo (50% off 6 mo); **free with NatWest/RBS/Ulster/Mettle account** | ◐ app | ✗ | ✓ bundled, unlimited users | ✓ "One-click payments" Stripe, GoCardless, PayPal, Tyl; bank feeds | ✓ out-of-pocket expenses | ✓ | ◐ locked accounting periods and VAT returns ("can't be fixed at all") | ◐ Find-and-Fix history, "maximum of two years" | ✓ "Data stored in AWS" | ✗ |
| **Xero** [37] | UK / US | UK: Ignite £18, Grow £39, Comprehensive £55, Ultimate £70 /mo (90% off 6 mo). US: Early $27, Growing $59, Established $97 (80% off 3 mo) | ◐ app | ✗ | ✓ bundled, "No per-user license fees" | ✓ Stripe/GoCardless invoice payments; bank feeds | ✓ UK: Grow 1 user, +£2.50/user; US: all plans | ✓ | ◐ lock dates (article body not readable, see §7) | ✓ History and notes (UNVERIFIED body) | ✓ SOC 2 + ISO 27001 on request | ✗ |
| **QuickBooks Online** [38] | US (UK) | US: Free $0 (1 user); Simple Start $38, Essentials $85, Plus $140, Advanced $340 /mo (50% off 3 mo). UK prices load dynamically (not captured) | ◐ app (Free plan: no app) | ✗ | ✓ bundled (1/3/5/25 users) | ✓ QuickBooks Payments cards + ACH ($0.50/ACH over allotment) | ◐ expenses, receipts, mileage | ✓ | ◐ Close the books: "Allow changes after viewing a warning and entering password" | ✓ Audit history "Who ... When ... What" | ✓ | ✗ |
| **Sage Accounting** [39] | UK | Start £20, Standard £43, Plus £59 /mo (90% off 6 mo); 1/3/unlimited users | ◐ app | ✗ | ✓ bundled | ◐ online payments (methods ns) | ◐ receipt capture 30/100 incl., +£0.20 | ✓ | ns | ns | ✓ | ✗ |
| **Zoho Books** [40] | UK / US | UK: Free (1+accountant, ≤1,000 invoices), Standard £10, Professional £20, Premium £25 … Ultimate £165 /mo (annual). US: Free ≤$50k revenue; Standard $15 … Ultimate $240 (annual) | ◐ app | ✗ | ✓ bundled (1–15 users; +£2–2.50 / $2.50–3 per user) | ✓ "accept online payments" all tiers | ✓ Expense Claim add-on £7–10 / $7–9 per active user/mo | ✓ | ◐ "transaction period locking" (Standard+); admin can unlock | ✓ | ✓ | ✗ |
| **Pandle** [41] | UK | **Free** (bank feeds, unlimited users, Stripe/PayPal feeds, MTD IT & VAT, transaction locking); Pro £5/mo | ◐ app | ✗ | ✓ bundled, unlimited users | ✓ Pandle Pay, Stripe, PayPal feeds | ◐ receipts, mileage | ✓ | ◐ "transaction locking" | ns | ✓ ("128-bit SSL") | ✗ |
| **Coconut** [42] | UK | 14-day trial; Bookkeeping £16.99/mo or £99.99/yr; MTD Filing £12.99/mo or £129.99/yr; Full £159.99/yr | ✓ app | ✗ | ✓ bundled | ◐ bank feeds; invoices | ◐ | ✗ (sole-trader tax books) | ✗ | ns | ✓ | ✗ |
| **ANNA Money** [43] | UK | £0 pay-as-you-use; Grow £12.90; Business £22.90; Big Business £59.90 /mo; Auto Accountant +£29/mo | ✓ app | ✗ | ✓ bundled | ✓ own account; QuickPay invoices; payment links (0.5% over £200/mo on Business) | ◐ | ✗ (tax/MTD books) | ✗ | ns | ✓ | ✗ |
| **Tide** [44] | UK | Free; Smart £12.49; Pro £27.49 (incl. Tide Accounting); Max £69.99 /mo | ✓ app | ✗ | ✓ bundled | ✓ own account; invoices | ◐ team expense cards (1/2/3) | ◐ Tide Accounting (Pro+) | ✗ | ns | ✓ | ✗ |
| **Starling Accounting** [45] | UK | Essentials free; Plus "£7 a month until April 2027, then £14" | ✓ in-app | ✗ | ✓ bundled | ✓ "match incoming payments to invoices ... and mark them as paid" | ◐ receipt attach | ✗ (categorised bank ledger, VAT) | ✗ | ns | ✓ bank | ✗ |
| **Wave** [46] | US/CA | Starter free; Pro $19/mo or $190/yr; Receipts +$8/mo; cards 2.9% + $0.60 | ◐ app | ✗ | ✓ bundled (Pro) | ✓ Wave Payments; auto-import bank (Pro) | ◐ receipts add-on | ✓ | ✗ | ns | ✓ PCI DSS L1; "limiting access to only the people who need it" | ✗ |
| **FreshBooks** [47] | US/CA | Lite $23, Plus $43, Premium $70 /mo (promos to $1–14); +$11/user | ◐ app | ✗ | ✓ bundled, per user | ✓ cards 2.9% + $0.30, ACH 1% | ◐ expenses; team members paid | ◐ "Double-Entry Accounting Reports" Plus+ | ✗ | ns | ✓ | ✗ |
| **Kashoo / TrulySmall** [48] | US/CA | Kashoo page shows $0 tier; "Unlimited users", "Double-entry ledger"; TrulySmall priced separately (ns) | ◐ | ✗ | ✓ bundled | ✓ Stripe and Square | ◐ | ✓ | ✗ | ns | ✓ | ✗ |
| **ZipBooks** [49] | US | Starter free; Smarter $15; Sophisticated $35 /mo | ◐ | ✗ | ✓ bundled (5 / unlimited users) | ✓ Square or PayPal | ◐ | ✓ | ✗ | ns | ✓ | ✗ |
| **Akaunting** [50] | US/global | Cloud Standard $12, Premium $36, Elite $84, Ultimate $218 /mo (annual $8/24/56/145); self-hosted core free (GPL), paid apps | ◐ | ✗ cloud; self-host offline-capable on own server | ✓ bundled (1/10/30/unlimited users) | ✓ Stripe/PayPal apps | ✓ "expense claims" (Premium+) | ✓ (Premium+) | ✗ | ns | ✓ cloud / ✗ self-hosted | ✗ |
| **Found** [51] | US | Free; Plus $35; Pro $80 /mo (−25% annual) | ✓ app | ✗ | ✓ bundled | ✓ own account; invoices paid in-app; imports other banks | ✗ | ✗ (tax books) | ✗ | ns | ✓ Lead Bank FDIC | ✗ |
| **Lili** [52] | US | Core free; Pro $15; Smart $35; Premium $55 /mo | ✓ app | ✗ | ✓ bundled | ✓ own account; invoices "accept payments instantly" | ✗ | ✗ (P&L/cash-flow reports) | ✗ | ns | ✓ Sunrise Banks FDIC | ✗ |
| **Novo** [53] | US | $0 monthly; free invoicing | ✓ app | ✗ | ✓ bundled | ✓ ACH, cards, PayPal into own account; QuickBooks/Xero sync | ✗ | ✗ | ✗ | ns | ✓ Middlesex Federal FDIC | ✗ |
| **Square Invoices** [54] | US | Free (fees 3.3% + 30¢ online, 1% ACH); Plus/Premium tiers | ✓ | ✗ | ✓ bundled | ✓ own processing | ✗ | ✗ no books | ✗ | ns | ✓ | ✗ |
| **Puzzle** [55] | US | Starter $30 (free 2 mo), Core $72, Complete $120, Scale $360 /mo | ✗ web | ✗ | ✓ bundled (1/5/unlimited seats) | ✓ Stripe, Ramp, Mercury, Brex | ✗ | ✓ cash & accrual | ✗ | ◐ "Clean, auditable financials" | ✓ | ✗ |
| **Keeper** [56] | US | Bookkeeping $20/mo; Standard $199/yr; Premium $399/yr; Business $1,199/yr | ✓ app | ✗ | ✓ bundled | ◐ bank feeds | ✗ | ✗ | ✗ | ns | ✓ | ✗ |
| **Hurdlr** [57] | US | Premium (price ns on page); Pro $200/yr (invoicing, GL, journal entries) | ✓ app | ✗ | ✓ bundled | ✓ invoices with card collection (Pro) | ✗ | ◐ GL + manual journals (Pro) | ✗ | ns | ✓ | ✗ |
| **Bench** [58] | US | $199 / $399 / $649 /mo (service, −20% annual) | ◐ | ✗ | n/a (bookkeepers do the books) | ◐ | ✗ | ✓ (done for you) | ✗ | ns | ✓ staff read books by design | ✗ |
| **GnuCash** [59] | any | Free (GPL) | ✗ desktop | ✓ | ✗ (file; user syncs) | ◐ OFX/HBCI import | ✗ | ✓ "Every transaction must debit one account and credit others" | ✗ | ✗ | ✗ local | n/a |
| **Manager.io** [60] | any | Desktop free; Cloud/Server paid (price page JS, not captured) | ✗ | ✓ Desktop | ◐ Cloud/Server paid | ✗ | ✓ built-in Expense Claims | ✓ | ✗ (lock date, UNVERIFIED) | ns | ✗ Desktop / ✓ Cloud | ✗ |
| **Actual Budget** [61] | any | Free (open source); host your own sync server (~$2/mo on PikaPods, third-party) | ◐ web/PWA | ✓ "works regardless of your network connection" | ✓ **you pay only for hosting the sync server** | ✗ (bank sync via GoCardless/SimpleFIN add-ons) | ✗ | ✗ envelope budgeting | ✗ | ✗ | ✗ with E2EE on | ✓ optional "enable end-to-end encryption" |
| **Firefly III** [62] | any | Free (self-hosted) | ◐ third-party apps | ✓ own server | ✓ own server | ◐ Data Importer | ✗ | ✓ "A double-entry bookkeeping system" | ✗ | ns | ✗ (own server) | ✗ |
| **MoneyMoney** [63] | DE | €79.99 one-time, macOS only | ✗ Mac | ✓ "speichert alle Daten lokal auf Ihrem Mac" | ✗ | ◐ FinTS/HBCI + PayPal accounts (reading, not books) | ✗ | ✗ bank aggregator | ✗ | ✗ | ✗ "verschlüsselten Datenbank auf Ihrer Festplatte" | n/a |
| **Banktivity** [64] | US | Bronze $6.99, Silver $8.99, Gold $10.99 /mo (annual) | ◐ Mac + iOS native | ✓ local app | ✓ **included in subscription** ("one subscription ... all of your devices") | ◐ "Direct Access" bank downloads | ✗ | ◐ personal finance | ✗ | ✗ | ◐ cloud sync relay (encryption ns) | ns |
| **Moneydance** [65] | US | one-time licence (price ns on pages read); mobile free | ◐ desktop + mobile | ✓ | ✓ "synced instantly and securely with your desktop" | ◐ bank download | ✗ | ◐ | ✗ | ✗ | ◐ "private, encrypted, and never shared" | ns |
| **iFinance 5** [66] | DE | $19.99 (promo from $39.99) one purchase for macOS/iPadOS/iOS; bank feed subscription extra | ◐ | ✓ | ✓ Wi-Fi sync between Apple devices (bundled) | ◐ bank connection (subscription) | ✗ | ◐ | ✗ | ✗ | ✗ local, "Encryption and password protection ... on all devices" | n/a |

**Reading the two hard columns.** *Genuinely tamper-proof entries* (✓)
exist only in Banana's hash chain, and even that is detect-only. The German
Festschreibung products (Lexware Office, sevdesk, DATEV, BuchhaltungsButler,
Kontolino) and Bokio's no-delete ledger come closest in practice: the
application refuses to edit or delete a fixed entry and forces a reversal,
which is exactly Smara's Golden Rule #7, but it is enforced by the vendor's
server code on the vendor's database, so the guarantee is "the vendor's
software will not let *you* change it", not "nobody can". Everything in
the UK/US tier (lock dates, Close the books, transaction locking) is a
reversible admin setting; QuickBooks even documents the override password.

*Data out of the operator's reach*: only GnuCash, MoneyMoney, iFinance,
Banana, Manager Desktop, Firefly III (your server) and Actual Budget with
E2EE switched on. Every cloud product holds readable books; the best
statements are jurisdiction (Switzerland, Germany, France/SecNumCloud),
certification (ISO 27001: bexio, Pennylane, Xero; SOC 2: Xero; ISAE 3402:
e-conomic; PCI L1: Wave) and least-privilege wording (Pennylane, Wave).
Indy's "chiffrement de données" and Pandle's "128-bit SSL" describe transport
or storage encryption the vendor can undo.

---

## 1. Per-region details

### 1.1 Switzerland

**bexio** [1] - Four packages, 30-day trial, prices CHF 35/42/69/119 per
month on annual billing with "saves CHF 120.00" versus monthly (so about CHF
10/month more if billed monthly; the page's labelling of the two columns is
ambiguous). Seats: 1, 2, 5, 25. Every package has "E-banking", "Smart expense
management" and the bexio Go app ("Mobile contact management", "Document
access", "Generation of invoices" - a companion, not a full client). bexio
Pay (amnis debit cards, Apple/Google Pay, "0% fees" multi-currency) is
included for 3 users in Ultimate and CHF 14/month as an add-on in
Advanced/Optima; "Card transactions must always be manually assigned to the
desired category and the corresponding VAT rate" in amnis before "the
transactions will automatically be posted to bexio". TWINT and PayPal are
not mentioned on the bexio Pay page. Security page: "The bexio servers are
deliberately located in Switzerland", "ISO 27001:2022 certified", SSL in
transit, encrypted backups "in several data centers". Nothing on employee
access, immutability or offline.

**AbaNinja** [3] - Abacus' Swiss21 product. Starter is free (1 user, 1,000
documents/year, 3 support tickets); Basic CHF 21/month (3 users, 2,100
docs); Pro CHF 49/month (5 users, 5,000 docs, inventory). Online payments
"Stripe, TWINT, PayPal und Überweisung. Voll integriert"; 70+ Swiss banks
with daily automatic sync; QR-Rechnung; Bilanz/Erfolgsrechnung; AI receipt
scanning; time tracking via AbaClik/AbaClock apps. Nothing on immutability
or employee access.

**KLARA Business** [4] - CHF 69/99/159 per month (CHF 48/69/111 on a 2-year
term), 30-day trial, Basic max 3 admin users, Plus/Premium unlimited.
"Automatic bank connection" in all tiers; myKLARA app "Capture receipts on
the go"; "Capture and manage expenses and credit card receipts digitally";
separate Payments module and Pay-by-Link; auto-posting of those payments is
not described.

**CashCtrl** [5] - FREE edition is a complete double-entry system (1 user, 1
organisation, QR invoices, debtors/creditors, fixed assets). PRO is priced
by a calculator (base 3 users, 2 organisations, 1 GB; the base figure did
not render); FL4T CHF 3,900/year for 200 users/organisations. "Developed and
operated exclusively in Switzerland", "Operation/backups only on Swiss
servers". Bank import is ISO 20022 camt files, not a live feed. No mobile
app, no payments, no immutability statement.

**Atlanto** [6] - Modular: Contact Manager free; Time CHF 10 per user/month;
Sales and Accounting CHF 44.90 per user/month; first month free. SumUp
partnership page exists; posting detail not stated.

**Milkee** [7] - Aimed at Selbständige. Basic CHF 24.90 (simple accounting,
2 users), Business CHF 34.90 (double-entry available, 3 users), Team CHF
69.90 (5 users), annual billing; +CHF 5 if monthly; 14-day trial, no card.
Automatic bank connection and mobile app in all tiers; AI receipt scans
capped 120/300/unlimited.

**Run my Accounts** [8] - Two offers. Software only: Startup free, KMU CHF
25/month + CHF 10/user; both include "Debitoren, Kreditoren, Auftrag,
REST-API, ... iPhone / Android App". Outsourced bookkeeping: base CHF 0/35/
290 per month plus CHF 1.80/1.40/0.95 per entry, with "Täglicher Bank Sync"
and "Abwicklung Zahlungsverkehr". Staff read the books by design.

**Accounto** [9] - Sold to Treuhand firms for SME clients (1–19 staff);
prices not published. "werden die Daten in der Schweiz aufbewahrt und in
einem Tier-3-Rechenzentrum gesichert".

**Yokoy, Expensya** - Yokoy's site refused the automated read (TLS); Expensya
publishes no prices ("Contact Sales"; "Web, Native mobile iOS and Android
applications"). Both are enterprise expense tools, not owner bookkeeping.

### 1.2 Germany and Austria

The GoBD (BMF letter, consolidated in the AO-Handbuch Anhang 33) require
that bookings be *festgeschrieben* promptly and that a booking may not be
changed so that its original content can no longer be established; changes
must be logged. Every German vendor sells this as a feature.

**Lexware Office** [10] - S €7.90 (receipts), M €12.90 (invoicing), L €21.90
(bookkeeping, EÜR, VAT), XL €32.90 (API, EU invoices) per month, 50% off for
3 months, 30-day trial, monthly cancellation. Mobile apps; "Multibanking";
PayPal integration; "GoBD Langzeitbelegarchiv". Help centre: "Der
Gesetzgeber gibt vor, dass alle steuerrelevanten Daten zeitnah, d.h. bis zum
Ablauf des Folgemonats festgeschrieben werden" and "Mit der Festschreibungen
sind Buchungen im Anschluss unveränderbar und können somit nicht mehr
gelöscht werden"; automatic Festschreibung runs "Einmal pro Monat ... nachts
im Zeitraum zwischen 22:00 Uhr - 06:00 Uhr" for everything up to the end of
the month before last. Marketing: "Alle Buchungen und Belege kannst du
unveränderbar speichern. Alle Änderungen werden lückenlos nachvollziehbar
aufbewahrt." The GoBD attestation is by an unnamed Wirtschaftsprüfungs-
gesellschaft, available on request.

**sevdesk** [11] - Free tier "Dauerhaft kostenlos"; Rechnung €9.90,
Buchhaltung €22.90, Buchhaltung Pro €30.90 per month on annual billing
(€11.90/25.90/34.90 monthly; cheaper on 24 months); 14-day trial on paid
tiers; mobile apps; "über 4.000 Banken und Neobanken"; AI Belegerfassung.
Festschreibung article: invoices are fixed automatically on completion;
expenses/income must be fixed "spätestens bis zum 30./31. des Folgemonats";
afterwards "Die Daten sind nicht mehr veränderbar. Eine Löschung ist nicht
mehr möglich"; corrections via credit note or "Generalumkehrbuchung". GoBD
page: "Buche und schreibe Einträge selbst fest, damit sie unveränderbar
gespeichert bleiben". Server location not stated on the pages read.

**DATEV Unternehmen online** [12] - "Monatlich 11,56 €", usable only through
a DATEV member (Steuerberater). Receipts and bank data sit "Im DATEV-
Rechenzentrum" for firm and client; "GoBD-konformes Kassenbuch". The client
captures, the firm books.

**BuchhaltungsButler** [13] - Light €39.90, Smart €46.90, Premium €89.90
(5 users, "approval workflows"), E-Commerce €84.90/119.90, Vereine €49.90;
+€4.90/user; 14-day trial. Feeds from "über 5.000 Banken", PayPal, Stripe,
Amazon, eBay, Shopify; "GoBD-konform" with Frankfurt servers; Scan app.

**FastBill** [14] (€9/14/27/53+ annual), **Billomat** [15] (€19/29/99
annual, +€10/user, Mollie payments), **Kontolino** [19] (€11–41, Germany-
hosted, GoBD archive €2/month), **Papierkram** [20] (free; €12.90/24.90/
49.90 annual; "GoBD-Zertifizierung"; XRechnung/ZUGFeRD), **GetMyInvoices**
(€19–179/month, document collection only, "Serverstandort Deutschland") -
all web-first with scan apps, bundled sync, German hosting where stated.

**Kontist** [16] and **Holvi** [17] - bank-account-first. Kontist: Free /
Start €11 / Plus €25 per month with sevdesk bundled for 3/6/12 months and
automatic tax set-aside; the books are sevdesk's. Holvi: Flex €0, Lite €9,
Pro €15, Business €69; receipts photographed into the account, invoices
and e-invoices, VAT and income reports, camt.052 export; it is "ein
Zahlungskonto", not a ledger.

**SumUp Invoices** (ex Debitoor) [18] - free up to 4 e-invoices a month,
Plus €4/month (annual, 50% promo); "GoBD-Konformität", "Revisionssichere
Archivierung", "Schneller Zahlungsabgleich" and "Automatische
Ausgabenverfolgung" for payments through the SumUp business account.

**Circula** [21] (expenses "ab 15€ pro Lizenz", minimum 10 licences, iOS/
Android, DATEV) and **Moss** [22] ("single platform fee regardless of the
number of users", transaction-volume based, "Developed and hosted in
Germany") are the German claim/card tools; **Pliant** publishes no prices.

### 1.3 France, Benelux, Nordics

**Pennylane** [23] - Indépendant plans €7/14/24/79 per month HT, 15-day
trial, no commitment; every plan includes a pro account with cards and
e-invoicing; "Gestion de notes de frais" from Essentiel; payment links on
invoices; bank sync. Security page: hosted "AWS en Irlande" plus "S3NS en
France, hébergement qualifié SecNumCloud 3.2"; "Chiffrement: En transit et
deux fois au repos"; "certifiés ISO 27001"; "Nous contrôlons tous les accès
aux données des utilisateurs par les collaborateurs autorisés". No NF525/
NF203 or SOC 2 mention.

**Tiime** [24] (Free; €9.99/17.99/24.99 HT annual, pro account mandatory,
Stripe/GoCardless), **Indy** [25] (Essentiel €0 with unlimited invoicing and
"comptabilité automatisée"; Plus €9; Premium €15–49; servers in France),
**Qonto** [26] (€9–199 HT, unlimited users, receipts and invoices reconciled
in-app, ACPR-regulated payment institution) and **Shine** [27] (Free; €9/20/
45 HT; team access €5/month each on Plus) are the French app-first
account-plus-books layer: strong on payments-into-books because the account
*is* the rail, weak on double-entry (pre-accounting for an expert-comptable)
and silent on immutability.

**Moneybird** [28] - Compact €3, Start €15, Growth €29, Complete €41 per
month; 60-day trial on Complete; 1/1/5/unlimited users; "1,700+ European
banks"; iDEAL €0.29 and SEPA direct debit €0.25 per transaction on invoices.
**Exact Online** [29] - €49/99/159/299, extra users €23–49, 30-day trial.
**Silvasoft** [30] - modular per user (Boekhouden €13.95), 30-day trial.

**Bokio** [31] - 269/359/459/599 kr per month; **every extra user 49 kr/
month**; bank connection 49 kr/month; "Swish Företag, 49 kr/mån + 2 kr/
transaktion"; utlägg from Premium. Help centre: "Tumregeln när det gäller
bokföring är att man inte får radera enskilda verifikat"; you may fully
delete only "inom 30 dagar om det är bokfört av dig och det är det senast
bokförda verifikatet"; otherwise an annulleringsverifikat is created ("V64
kommer ... annulleras genom V65 och sedan kommer det nya verifikatet bli
V66") and inactive verifikat stay visible via "Visa inaktiva". "Lås avstämd
period" blocks new postings in a reconciled period, but can be updated or
removed from Settings.

**Fortnox** [32] - Mini 209, Liten 349, Mellan 490, Stor 710 kr/month on a
12-month term (+15% on 3 months); six months free for newly started
companies; "Kvitto & Utlägg" 4.90 kr per receipt, Resa 4.90 kr per entry -
a pay-per-claim model with no licence fee.

**e-conomic** [33] (249/299/399/649 kr/md; **extra user 149 kr/md**; free
app; ISAE 3000/3402), **Dinero** [34] (Starter free up to 100,000 kr
revenue; 245/345/545 kr/md; "certificeret af Erhvervsstyrelsen"), **Billy**
[35] (free 3 invoices + 10 receipts/month; 160/295/595 kr/md; MobilePay on
Plus) - all position on the Danish bogføringslov, which from 2024 (classes
B–D) and 2026 (all) requires a registered digital bookkeeping system.

### 1.4 United Kingdom

**FreeAgent** [36] - £19 sole trader, £27 partnership, £33 limited company
per month (50% off 6 months), or £190/270/330 a year; **free** with a
NatWest, RBS, Ulster Bank or Mettle business account. Unlimited users,
mobile app, bank feeds, "One-click payments" via Stripe, GoCardless, PayPal
and Tyl, out-of-pocket expenses, MTD, "Data stored in AWS". Corrections:
Find and Fix can change categories/VAT/descriptions on bank explanations,
bill lines and expenses, but "It's not currently possible to correct
invoice line items, journal entries ... or items in a locked accounting
period"; a correction history is kept "for a maximum of two years".

**Xero UK** [37] - Ignite £18, Grow £39, Comprehensive £55, Ultimate £70 per
month (90% off 6 months); expense claims for 1/5/10 users, +£2.50 per extra
claimant; Stripe/GoCardless invoice payments; bank feeds free (some banks
charge). Xero publishes a SOC 2 Type II report and ISO 27001 certificate on
request. The lock-dates article exists but its body did not render.

**QuickBooks UK** [38] - Sole Trader Plus, Simple Start, Essentials (3
users), Plus (5), Advanced (25); prices "Loading live prices…" so not
captured. US prices in §1.5.

**Sage Accounting** [39] - Start £20 (1 user), Standard £43 (3), Plus £59
(unlimited) per month, 90% off 6 months; receipt capture 30/100 included
then £0.20 each; MTD; online payment methods not detailed.

**Zoho Books UK** [40] - Free plan (1 user + accountant, up to 1,000
invoices a year, MTD IT and VAT, self-assessment forms); Standard £10,
Professional £20, Premium £25, Elite £85, Ultimate £165 per month (annual);
Expense Claim add-on £7–10 per active user/month; "transaction period
locking" from Standard.

**Pandle** [41] - the free tier is unusually complete: bank feeds, unlimited
users, Stripe and PayPal feeds, Pandle Pay, MTD IT and VAT submissions,
multi-currency, transaction locking, receipt uploads, mileage. Pandle Pro
£5/month (+VAT), rolling monthly. Security statement is only "128-bit SSL".

**Coconut** [42] (sole-trader tax books, £12.99–16.99/month or £49.99–
159.99/year), **ANNA Money** [43] (£0 pay-as-you-use; £12.90/22.90/59.90;
Auto Accountant £29/month; payment links), **Tide** [44] (Free; £12.49/
27.49/69.99; Tide Accounting in Pro), **Starling Accounting** [45]
(Essentials free; Plus "£7 a month until April 2027, then £14"; "We'll match
incoming payments to invoices on Online Banking, and mark them as paid") -
app-first account-plus-books products built around MTD.

### 1.5 United States

**QuickBooks Online** [38] - Free plan $0 (1 user, no mobile app); Simple
Start $38, Essentials $85 (3 users), Plus $140 (5), Advanced $340 (25) per
month, 50% off 3 months; QuickBooks Payments for cards and ACH ("$0.50/
standard ACH transaction over monthly allotments"). Close the books offers
"Allow changes after viewing a warning and entering password"; the audit
history records "Who made the changes", "When the changes were made", "What
the changes are", visible to "users with full access rights".

**Wave** [46] - Starter free (unlimited invoices, bills, bookkeeping; cards
2.9% + $0.60); Pro $19/month or $190/year (auto-import bank transactions,
first 10 card transactions a month at 2.9% + $0); Receipts add-on $8/month;
Wave Advisors from $149/month. Security: "Level 1 PCI-DSS certified",
"limiting access to only the people who need it to do their jobs".

**FreshBooks** [47] - Lite $23, Plus $43, Premium $70 per month (promos $1–
14), +$11 per extra user; cards 2.9% + $0.30, ACH 1%; "Double-Entry
Accounting Reports" from Plus.

**Xero US** [37] - Early $27, Growing $59, Established $97 per month (80%
off 3 months); "No per-user license fees"; "Employee expense and mileage
claims" on all plans; Stripe invoice payments.

**Zoho Books US** [40] - Free "As long as your revenue ... does not exceed
the threshold of $50K"; Standard $15, Professional $40, Premium $60, Elite
$120, Ultimate $240 per month (annual); Expense Claim add-on $7/user/month
annual ($9 monthly); additional users $2.50–3.

**Kashoo** [48] ($0 tier shown, "Unlimited users", "Double-entry ledger",
Stripe and Square; TrulySmall priced separately), **ZipBooks** [49] (free;
$15; $35; Square or PayPal), **Akaunting** [50] (cloud $12–218/month;
self-hosted core free, expense claims and double-entry only in paid
Premium+), **Puzzle** [55] ($30–360/month, Stripe/Ramp/Mercury/Brex feeds,
"auditable financials"), **Bench** [58] ($199/399/649 per month, human
bookkeepers; the page read does not mention Employer.com).

**Found** [51] (free; Plus $35; Pro $80; Lead Bank FDIC), **Lili** [52]
(Core free; Pro $15; Smart $35 with "Bookkeeping automation"; Premium $55;
Sunrise Banks FDIC), **Novo** [53] ($0 monthly, free invoicing, ACH/cards/
PayPal, QuickBooks/Xero sync, Middlesex Federal FDIC) - the US bank-plus-
books layer; all app-first, all tax-oriented single-entry.

**Square Invoices** [54] - free, fees 3.3% + 30¢ online / 1% ACH; no books.
**Keeper** [56] ($20/month bookkeeping; $199–1,199/year with filing) and
**Hurdlr** [57] (Pro $200/year with GL and manual journals) are mobile tax
trackers for the self-employed.

### 1.6 Local-first, privacy and open source

**GnuCash** [59] - free, GPL, Windows/macOS/Linux; XML or SQLite/MySQL/
PostgreSQL file; QIF/OFX import and "the first free software application to
support the German Home Banking Computer Information protocol" (HBCI). No
Android app on the features page, no locking, no sync.

**Manager.io** [60] - "free desktop edition", Cloud and Server editions
paid; the cloud pricing page did not render its price. Built-in Expense
Claims tab (per earlier note).

**Actual Budget** [61] - free, open source; "all data is local by default,
but if internet is available, your data is seamlessly backed up and synced
to all other devices" through a sync server you host; "You can enable
end-to-end encryption ... in the Encryption section" with "You will not be
able to recover your data if you forget your encryption password"; on
concurrent edits: "To be safe, avoid simultaneous usage of the same budget
file". It is envelope budgeting, not double-entry books.

**Firefly III** [62] - "A double-entry bookkeeping system", "completely
self-hosted and isolated, and will never contact external servers until you
explicitly tell it to"; import "from almost any bank" via the Data Importer.

**MoneyMoney** [63] - "Basisversion einmalig 79,99 € inkl. MwSt.", macOS
10.13–27; "MoneyMoney speichert alle Daten lokal auf Ihrem Mac" in "einer
passwortgeschützten und verschlüsselten Datenbank auf Ihrer Festplatte";
FinTS/HBCI and PayPal; exports to Excel/Numbers/CSV/GrandTotal. A banking
client, not a ledger; no multi-Mac sync.

**Banktivity** [64] - Bronze $6.99, Silver $8.99, Gold $10.99 per month
billed annually; "One subscription provides access on all of your devices"
(Mac, iPhone, iPad); Direct Access bank downloads included. Sync and bank
feeds are what the subscription buys; the app itself is local.

**Moneydance** [65] - one-time desktop licence (price not on pages read);
free mobile apps "synced instantly and securely with your desktop"; "your
data is private, encrypted, and never shared".

**iFinance 5** [66] - $19.99 one purchase for macOS/iPadOS/iOS; "WiFi sync"
between Apple devices; "Encryption and password protection are provided on
all devices"; bank connection is a separate subscription.

**Hibiscus** - HBCI/FinTS client (willuhn.de); the site timed out on
robots.txt, so nothing could be verified this time. **Lunch Money** - $10/
month or $100/year, web-first budgeting; no bookkeeping claims on the
pricing page.

---

## 2. The "pay for sync" pattern

Nothing in Europe or the USA sells multi-device sync as the sole paid
feature. What exists:

| Pattern | Examples | How it relates to Smara's idea |
|---|---|---|
| Per-seat pricing (sync is free, people cost) | bexio 1/2/5/25 seats; Billomat +€10/user; Bokio +49 kr/user; e-conomic +149 kr/user; FreshBooks +$11/user; Exact +€23–49/user; Zoho +£2–3/user; KLARA Basic ≤3 admins | Charges for *people*, not devices. A sole owner on three devices pays nothing extra anywhere. |
| Free single-user, paid team | sevdesk free tier → paid; Zoho Free (1 + accountant); Pandle free unlimited users; Kashoo "Unlimited users" at $0 | The accountant seat is usually free (Zoho, QuickBooks "access for your accountant", Billy "Revisoradgang"). |
| Pay for the relay, not the software | Actual Budget (software free, you pay a host ~$2/month); Banktivity/Moneydance (local app, subscription or add-on buys device sync + bank downloads) | **This is the closest match**: the only money changes hands for the thing that moves bytes between devices. |
| Pay per claim/receipt | Fortnox Kvitto & Utlägg 4.90 kr/receipt, no licence fee; Run my Accounts CHF 0.95–1.80 per entry; Sage +£0.20/receipt over quota | Usage-metered; the India note's OkCredit/Vyapar "device licence" model does not appear. |
| Free with the bank account | FreeAgent via NatWest/RBS/Mettle; Starling Essentials; Tide Free; Kontist/Holvi/Qonto/Shine/Indy/Found/Lili/Novo free tiers | The bank pays for the books from interchange and deposits; sync is just the bank's app. |

Inference: a European or US owner would find a "small fee for sync" offer
unfamiliar but easy to understand, because the nearest things they already
pay for are Banktivity's "one subscription ... all of your devices" and
Actual's hosted sync server. The accountant seat should probably be free,
as it is almost everywhere here.

---

## 3. Regulatory drivers that make tamper-evidence a selling point

| Jurisdiction | Rule (read 2026-10-05) | What it demands of software | Vendors advertising it |
|---|---|---|---|
| **Germany** | GoBD (BMF, AO-Handbuch Anhang 33) [67] | Bookings must be fixed (*festgeschrieben*) promptly (vendors read this as by end of following month) and may not be altered so that the original content cannot be established; changes logged | Lexware Office, sevdesk, DATEV, BuchhaltungsButler, Kontolino, Papierkram, SumUp Invoices ("Revisionssichere Archivierung"), Circula |
| **Switzerland** | OR 957a (Ordnungsmässigkeit) and GeBüV [68]: Art. 3 "nicht geändert werden können, ohne dass sich dies feststellen lässt"; Art. 9 changeable media only with "technische Verfahren ... welche die Integrität der gespeicherten Informationen gewährleisten (z.B. digitale Signaturverfahren)" and provable storage time ("Zeitstempel"); Art. 10 migrations "zu protokollieren" | Detectable alteration; signatures/time stamps on changeable media | Banana (hash chain). None of bexio/AbaNinja/KLARA/CashCtrl/Atlanto/Milkee state how they meet GeBüV on public pages. **This is an open gap a signed ledger addresses directly.** |
| **Sweden** | Bokföringslagen (as described by Bokio) | Verifikat may not be deleted; corrections as new verifikat | Bokio (no-delete, annullering), Fortnox |
| **Denmark** | Bogføringsloven, registered digital bookkeeping systems (Erhvervsstyrelsen) [34] | Registered system with transaction storage, backup, ISO security, OIOUBL/Peppol e-invoicing; classes B–D 2024, all 2026 | Dinero ("certificeret af Erhvervsstyrelsen"), Billy, e-conomic |
| **France** | NF525 (cash-register/POS software, Loi anti-fraude TVA); e-invoicing mandate [69]: "toutes les entreprises ... dès le 1er septembre 2026" must receive; large/mid emit 1 Sept 2026; "petites et micro-entreprises ... jusqu'au 1er septembre 2027" via plateformes agréées; e-reporting of transaction and payment data | NF525 is POS-only; bookkeeping tamper-evidence not mandated; e-invoicing routes invoices through state-registered platforms | Pennylane (e-invoicing "incluse dans tous les plans"), Tiime, Indy, Qonto ("conformité facturation électronique") |
| **UK** | MTD for Income Tax [70]: digital records and quarterly updates from 6 April 2026 (>£50,000), 2027 (>£30,000), 2028 (>£20,000); MTD VAT already | Digital records and API filing; the HMRC text "contains no language addressing immutability" | FreeAgent, Xero, QuickBooks, Sage, Zoho, Pandle, Coconut, ANNA, Tide, Starling all lead with "MTD ready" |
| **EU e-invoicing** (background, not fetched this time) | Italy SDI (live), Belgium B2B 1 Jan 2026, Poland KSeF 2026, Germany B2B reception since 2025 with issuance phased 2027–28 | Structured invoices through state or certified platforms; signs the *invoice*, not the ledger | SumUp (XRechnung/ZUGFeRD), Papierkram, Pennylane, Exact |
| **USA** | Nothing comparable | Period close and audit log are accounting-practice features, not legal requirements | QuickBooks Close the books, Xero lock dates, Zoho locking |

Inference: tamper-evidence is a *purchase criterion* in DE/AT and CH and a
*legal baseline* in SE/DK; it is close to irrelevant in UK/US marketing. A
hash-chained, device-signed ledger is a stronger claim than any German
Festschreibung product makes (theirs is "our server refuses edits"; Smara's
is "any edit is detectable by anyone holding the chain"), and it maps
word-for-word onto GeBüV Art. 3 and Art. 9. For the UK/US the same feature
should be sold as "your bookkeeper and your auditor can prove nothing was
back-dated", not as compliance.

---

## 4. Answers to the six questions

**(a) Does anyone run fully on phones for owner + bookkeeper with offline
use?** No. The app-first products (Qonto, Shine, Indy, Tiime, Kontist,
Holvi, ANNA, Tide, Starling, Found, Lili, Novo, Keeper, Hurdlr, Coconut)
are phone-complete for the *owner*, but all are online-only and the
bookkeeper works in a web back office or via export. The accounting suites
(bexio, sevdesk, Lexware, Pennylane, Moneybird, Bokio, FreeAgent, Xero,
QuickBooks, Zoho, Wave) give the phone a companion role. Offline use exists
only in desktop/local tools (GnuCash, Banana, Manager Desktop, MoneyMoney,
Moneydance, Banktivity, iFinance) and Actual Budget. No vendor describes a
conflict-resolution rule; Actual says "avoid simultaneous usage".

**(b) Tie online payments into the books automatically?** Yes, broadly, in
two forms. Where the vendor is the payment rail (bank-plus-books apps,
SumUp, Square, Wave Payments, QuickBooks Payments, bexio Pay/amnis, Moneybird
iDEAL/SEPA DD, Bokio Swish) incoming money is matched to the invoice or
posted as an expense. Where a third-party processor is used (Stripe,
GoCardless, PayPal, Mollie, TWINT via AbaNinja) the suites mark the invoice
paid and import the feed; several still need manual categorisation (bexio
Pay). SEPA transfers arrive through open-banking feeds (PSD2 aggregators:
sevdesk 4,000 banks, BuchhaltungsButler 5,000, Moneybird 1,700, AbaNinja 70
Swiss banks) and are matched by rules.

**(c) Sync across devices?** Universally, via the vendor's cloud. The
exceptions are the local tools, which either do not sync (GnuCash, Banana,
MoneyMoney) or sync through a relay the vendor runs (Banktivity, Moneydance)
or the user hosts (Actual, Firefly III). No product syncs device-to-device
over LAN.

**(d) Charge mainly/only for sync?** No one. The nearest are Actual Budget
(pay only your host) and Banktivity ("one subscription ... all of your
devices", bundled with bank downloads). Everyone else bundles sync and
charges per seat or per feature tier (§2).

**(e) Genuinely tamper-proof entries vs audit log?** Only Banana's hash
chain is tamper-*evident* by construction. German Festschreibung products
and Bokio's no-delete ledger are *application-enforced* immutability on the
vendor's database - strong in practice, not cryptographic, and the vendor
can in principle change the data. UK/US products offer reversible period
locks (QuickBooks documents the override password; Zoho lets admins unlock;
Bokio's reconciled-period lock is removable from Settings) plus audit logs
(QuickBooks audit history, FreeAgent two-year correction history, Xero
History and notes). No product signs entries or chains them except Banana.

**(f) Keep data out of the operator's reach?** Only the local tools
(GnuCash, Banana, MoneyMoney, iFinance, Manager Desktop), self-hosted
Firefly III, and Actual Budget with E2EE enabled. Every cloud product holds
plaintext; the strongest statements are jurisdictional (Swiss-only hosting:
bexio, CashCtrl, Accounto; German hosting: BuchhaltungsButler, FastBill,
Kontolino, GetMyInvoices, Moss; French SecNumCloud option: Pennylane),
certifications (ISO 27001: bexio, Pennylane, Xero; SOC 2: Xero; ISAE 3402:
e-conomic; PCI L1: Wave) and least-privilege wording.

---

## 5. Closest matches per region and gaps vs Smara

| Region | Closest match | Has | Lacks vs Smara |
|---|---|---|---|
| CH | **Banana Accounting+** | local file, double-entry, hash-chain lock, free ≤70 tx, CHF 89/yr | no phone app, no sync, no claims, no payments, lock is detect-only and unlockable |
| CH | **bexio** / **AbaNinja** | double-entry, Swiss hosting, bank feeds, TWINT/Stripe/PayPal (AbaNinja), Spesen, free tier (AbaNinja) | online-only, companion app, vendor reads books, no signing, no GeBüV statement |
| DE/AT | **sevdesk** / **Lexware Office** | Festschreibung enforced in-app with forced reversal (same rule as Smara's Golden Rule #7), mobile apps, free tier (sevdesk), PayPal/Multibanking, €8–31/mo | online-only, vendor-side enforcement only, vendor reads books, no E2EE, claims workflow absent |
| DE | **MoneyMoney** (+ GnuCash) | local encrypted database, FinTS, €79.99 one-time | not bookkeeping, no sync, no claims, Mac only |
| FR | **Indy** / **Pennylane** | free tier (Indy), app-first, pro account posts into books, notes de frais (Pennylane), ISO 27001 + SecNumCloud option (Pennylane) | online-only, vendor reads books, no immutability claim, FR-entity-specific |
| Nordics | **Bokio** | no-delete ledger with annullering, utlägg, Swish into books, per-user pricing (+49 kr) | online-only, vendor reads books, lock removable |
| UK | **FreeAgent** (free via NatWest/Mettle) / **Pandle** (free) | double-entry, Stripe/GoCardless/PayPal auto-paid, expenses, locked periods, MTD | online-only, vendor reads books, lock reversible, two-year history cap (FreeAgent) |
| US | **Wave** / **Zoho Books Free** | free double-entry, payments into books, mobile app, expense claims add-on (Zoho) | online-only, vendor reads books, no immutability, no E2EE |
| any | **Actual Budget** | local-first, optional E2EE, self-hosted sync as the only cost, open source | envelope budgeting not double-entry, no claims, no payments, "avoid simultaneous usage" |

What none of them offers, and Smara does or plans to: (1) a ledger whose
posted entries are signed and chained on the device so that *any* party -
including the vendor - would be caught altering them (GeBüV Art. 3/9
language); (2) owner and bookkeeper on phones with full offline use and
LAN peer sync, no vendor server; (3) a claim flow (submit, approve, post)
inside the same ledger; (4) a fee attached to sync alone.

What the market has that Smara lacks (inference, for roadmap discussion):
open-banking/PSD2 feeds and processor integrations (Stripe, TWINT, SumUp,
PayPal) as the main way payments enter the books; e-invoicing formats
(QR-Rechnung, XRechnung/ZUGFeRD, Factur-X, Peppol) which are becoming
mandatory in FR/DE/BE/PL/IT and are the headline feature of every 2026
pricing page; and an accountant seat that is free everywhere.

---

## 6. Not verified / could not read

- **Yokoy** (yokoy.io) and **Hibiscus** (willuhn.de): automated fetch failed
  at TLS/robots; nothing verified.
- **Xero lock dates** article (Xero Central) and **Xero security assurance**
  page rendered only metadata; the existence of lock dates and of "History
  and notes" is from the article titles and general product knowledge -
  **UNVERIFIED** in body.
- **QuickBooks UK prices** ("Loading live prices…") and **Crunch** (quote
  tool) were not captured.
- **Manager.io Cloud** price did not render; **Moneydance** desktop price not
  on the pages read; **CashCtrl PRO** base price shown as "N/A" (calculator).
- **bexio** monthly-vs-annual column labelling on the English pricing page
  was ambiguous; the CHF 35/42/69/119 figures are the lower (annual) column.
- **Lexware Office** price table showed promo and regular columns swapped in
  the extraction; the regular prices €7.90/12.90/21.90/32.90 are consistent
  with "50% off" promo values €3.95/6.45/10.95/16.45.
- **Spendesk, Expensify, Ramp, Brex, Pleo** - not re-read; see the earlier
  pricing note.
- **Bench / Employer.com** ownership not stated on the pricing page read.
- EU e-invoicing dates for IT/BE/PL/DE in §3 are background knowledge, not
  fetched this time.
- Nothing on any vendor page described a sync **conflict** rule; "ns"
  throughout.

---

## Sources

All read 2026-10-05.

[1] bexio: https://www.bexio.com/en-CH/packages-and-prices ;
https://www.bexio.com/en-CH/cloud ;
https://www.bexio.com/en-CH/bexio-pay-ultimate-package
[2] Banana: https://www.banana.ch/en/buy ; https://www.banana.ch/doc/en/node/3353 (from the India note)
[3] AbaNinja: https://www.abaninja.ch/de/
[4] KLARA: https://www.klara.ch/en/business
[5] CashCtrl: https://cashctrl.com/en/info/plans ; https://cashctrl.com/en/info/pro
[6] Atlanto: https://atlanto.ch/en/pricing/
[7] Milkee: https://www.milkee.ch/preise
[8] Run my Accounts: https://www.runmyaccounts.ch/preise/
[9] Accounto: https://accounto.ch/en/solution/
[10] Lexware Office: https://www.lexware.de/preise/ ;
https://help.lexware.de/de-form/articles/548167-warum-mussen-buchungen-festgeschrieben-werden ;
https://help.lexware.de/de-form/articles/548842-automatische-festschreibung ;
https://www.lexware.de/gobd-zertifikat/
[11] sevdesk: https://sevdesk.de/preise/ ;
https://hilfe.sevdesk.de/de/articles/15531427-festschreibung-steuerrechtliche-pflicht-anwendung ;
https://sevdesk.de/gobd/
[12] DATEV: https://www.datev.de/web/de/shop/produkt-details/datev-unternehmen-online-95138
[13] BuchhaltungsButler: https://www.buchhaltungsbutler.de/preise/
[14] FastBill: https://www.fastbill.com/preise
[15] Billomat: https://www.billomat.com/preise/
[16] Kontist: https://kontist.com/pricing/
[17] Holvi: https://www.holvi.com/de/preise/
[18] SumUp Invoices: https://www.sumup.com/de-de/rechnungen/
[19] Kontolino: https://www.kontolino.de/preise/
[20] Papierkram: https://www.papierkram.de/preise/
[21] Circula: https://www.circula.com/de/preise
[22] Moss: https://www.getmoss.com/pricing ; Pliant: https://www.getpliant.com/de/pricing ;
GetMyInvoices: https://www.getmyinvoices.com/de/preise/
[23] Pennylane: https://www.pennylane.com/fr/tarifs/ ; https://www.pennylane.com/fr/securite
[24] Tiime: https://www.tiime.fr/tarifs
[25] Indy: https://www.indy.fr/tarifs/
[26] Qonto: https://qonto.com/fr/pricing ; https://qonto.com/fr/security
[27] Shine: https://www.shine.fr/tarifs/
[28] Moneybird: https://www.moneybird.com/pricing/
[29] Exact Online: https://www.exact.com/nl/bedrijven/boekhouden/features-en-prijzen
[30] Silvasoft: https://www.silvasoft.nl/prijzen/
[31] Bokio: https://www.bokio.se/priser/ ;
https://www.bokio.se/hjalp/bokforing/redigera-bokforing/ta-bort-och-redigera-verifikat/ ;
https://www.bokio.se/hjalp/bokforing/kontrollera-bokforing/las-avstamd-period/
[32] Fortnox: https://www.fortnox.se/produkt/prislista
[33] e-conomic: https://www.e-conomic.dk/priser
[34] Dinero: https://dinero.dk/priser/ ; https://dinero.dk/ny-bogfoeringslov/registreret-bogfoeringssystem/
[35] Billy: https://www.billy.dk/priser/
[36] FreeAgent: https://www.freeagent.com/pricing/ ;
https://support.freeagent.com/hc/en-gb/articles/25895907007890-Make-corrections-using-Find-and-Fix
[37] Xero: https://www.xero.com/uk/pricing-plans/ ; https://www.xero.com/us/pricing-plans/ ;
https://www.xero.com/us/security/soc-report/ ; (lock dates, body unreadable) https://central.xero.com/0/article/Set-up-and-work-with-lock-dates
[38] QuickBooks: https://quickbooks.intuit.com/pricing/ ; https://quickbooks.intuit.com/uk/pricing/ ;
https://quickbooks.intuit.com/learn-support/en-us/help-article/close-books/close-books-quickbooks-online/L59LelyPM_US_en_US ;
https://quickbooks.intuit.com/learn-support/en-us/help-article/audit-log/view-transaction-changes-audit-history/L7obVhic2_US_en_US
[39] Sage: https://www.sage.com/en-gb/sage-business-cloud/accounting/pricing/
[40] Zoho Books: https://www.zoho.com/uk/books/pricing/ ; https://www.zoho.com/us/books/pricing/
[41] Pandle: https://www.pandle.com/pricing/
[42] Coconut: https://www.getcoconut.com/pricing
[43] ANNA: https://anna.money/pricing
[44] Tide: https://www.tide.co/pricing/
[45] Starling: https://www.starlingbank.com/business-account/sme-business-toolkit/
[46] Wave: https://www.waveapps.com/pricing ; https://www.waveapps.com/legal/security-and-privacy
[47] FreshBooks: https://www.freshbooks.com/pricing
[48] Kashoo: https://kashoo.com/pricing
[49] ZipBooks: https://zipbooks.com/pricing/
[50] Akaunting: https://akaunting.com/pricing
[51] Found: https://found.com/pricing
[52] Lili: https://lili.co/plans
[53] Novo: https://www.novo.co/invoices
[54] Square: https://squareup.com/us/en/invoices/pricing
[55] Puzzle: https://puzzle.io/pricing
[56] Keeper: https://www.keepertax.com/pricing
[57] Hurdlr: https://university.hurdlr.com/en/articles/3703110-what-are-the-pro-features-and-how-much-does-it-cost-pro ; https://www.hurdlr.com/pricing
[58] Bench: https://www.bench.co/pricing
[59] GnuCash: https://www.gnucash.org/features.phtml
[60] Manager.io: https://www2.manager.io/cloud/ ; https://www2.manager.io/cloud/pricing (price not rendered)
[61] Actual Budget: https://actualbudget.org/docs/getting-started/sync/
[62] Firefly III: https://docs.firefly-iii.org/explanation/firefly-iii/about/introduction/
[63] MoneyMoney: https://moneymoney.app/ ; https://moneymoney.app/security/
[64] Banktivity: https://www.banktivity.com/content/plans/plans.php
[65] Moneydance: https://infinitekind.com/moneydance
[66] iFinance: https://www.syniumsoftware.com/ifinance
[67] GoBD (BMF, AO-Handbuch Anhang 33, body not rendered; cited for existence): https://esth.bundesfinanzministerium.de/ao/2025/Anhaenge/BMF-Schreiben-und-gleichlautende-Laendererlasse/Anhang-33/inhalt.html ; vendor paraphrases in [10], [11]
[68] GeBüV (Geschäftsbücherverordnung): https://www.fedlex.admin.ch/filestore/fedlex.data.admin.ch/eli/cc/2002/216/20130101/de/html/fedlex-data-admin-ch-eli-cc-2002-216-20130101-de-html.html
[69] French e-invoicing: https://www.impots.gouv.fr/professionnel/je-decouvre-la-facturation-electronique
[70] HMRC MTD for Income Tax: https://www.gov.uk/government/publications/extension-of-making-tax-digital-for-income-tax-self-assessment-to-sole-traders-and-landlords/making-tax-digital-for-income-tax-self-assessment-for-sole-traders-and-landlords
Other: Expensya https://www.expensya.com/en/pricing ; Lunch Money https://lunchmoney.app/pricing ;
Yokoy https://www.yokoy.io/en/pricing (fetch failed) ; Hibiscus https://www.willuhn.de/products/hibiscus/ (fetch failed)
