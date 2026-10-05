# Research: Existing expense-claim and accounting products, and how they bill

The question was: "Is there similar accounting or travel cost claiming
software existing? If yes, how do they bill for such a use case?"

Gathered 2026-10-05. Every price below was read that day on the vendor's
own pricing page, help centre or official site (see [Sources](#sources)).
Prices change often and many vendors run introductory discounts, so treat
them as a snapshot. **UNVERIFIED** marks anything I could not confirm at a
primary source. Vendor pricing pages often vary by region and the INR prices
are shown only where the vendor publishes them. Indian GST (18%) is extra
unless stated.

Short answer: yes. Many products already do expense and travel claims, and
most accounting products have a claims feature or add-on. Almost all of them
hold your data on the vendor's cloud. Only a few desktop or self-hosted tools
keep the books local, and among the products checked only Actual Budget
offers end-to-end encryption (optionally). None of them combine claims,
double-entry books and serverless device-to-device sync the way Smara does.

---

## 1. Comparison table

| Product | What it does for claims | Billing model | Headline price (as read 2026-10-05) | Free tier | Data held |
|---|---|---|---|---|---|
| **Expensify** | Receipt scan, submit, approve, reimburse | Per member/month; card use discounts subscription | Collect $5/unique member/mo; Control $36/active member/mo pay-per-use or $18 annual, down to $9 with Expensify Card use | Free "Submit" workspace for individuals (no approvals or payments) | Vendor cloud |
| **SAP Concur Expense** | Enterprise travel and expense | **Per expense report**, volume commitment | Base "starting at $7 per report", Plus "starting at $11 per report", unlimited users; Premium custom | No | Vendor cloud |
| **Zoho Expense (India)** | Claims, approvals, trips, advances | Per user/month, 5-user minimum | Standard ₹79 (annual) / ₹99 (monthly); Premium ₹149 / ₹199 per user/mo | Free up to 3 users, 20 scans/user/mo | Vendor cloud |
| **Ramp** | Corporate cards + reimbursements | Free base; paid tier per user + platform fee | Free $0; Plus $15/user/mo + platform fee; Enterprise custom | Yes | Vendor cloud |
| **Brex** | Corporate cards + expense | Free base; paid tier per user | Essentials $0; Premium $12/user/mo; Enterprise custom | Yes | Vendor cloud |
| **Navan** | Travel booking + expense | Travel free, paid by travel-provider commissions; expense per user | Business: travel free (≤300 employees); expense free for first 5 users, then $15/user/mo | Yes (travel, 5 expense users) | Vendor cloud |
| **Rydoo** | Expense claims, mileage, per diem | Per **active** user/month, 5-user minimum | Essentials €8 (annual) / €10 (monthly); Pro €10 / €12 per active user/mo | No | Vendor cloud |
| **Fyle → Sage Expense Management** | Claims, card feeds | Per **active** user/month (user who created an expense or has an active card) | Growth $11.99; Business $14.99 per active user/mo, billed annually | No | Vendor cloud |
| **Pleo** | Company cards + reimbursements | Per user/month | Start £8, Build £14, Optimise £18 per user/mo (Build/Optimise yearly, 3-user minimum) | No | Vendor cloud |
| **Spendesk** | Cards, invoices, claims | Fixed platform fee + variable transaction fees, unlimited users | Not published, contact sales | No | Vendor cloud |
| **Emburse** | Expense/cards (Emburse Spend page) | User-band tiers; API per card | 5 users $45/mo … 50 users $225/mo; API $0.25/card, $500/mo minimum | Not stated | Vendor cloud |
| **Happay (India, by MakeMyTrip)** | Claims, trip reimbursement, prepaid cards | Not published | Contact sales | Not stated | Vendor cloud |
| **QuickBooks Online** | Expense tracking; claims via bills/add-ons | Flat per company tier, users capped by tier | Simple Start $38, Essentials $85, Plus $140, Advanced $340 /mo (50% off 3 months) | Free plan (1 user, 2 invoices/mo) | Vendor cloud. **Withdrawn from India** |
| **Xero** | Expense claims only on top plan | Flat per organisation tier | Early $27, Growing $59, Established $97 /mo (US); claims only in Established | No (80% off 3 months) | Vendor cloud |
| **Zoho Books (India)** | Expense claims as a paid add-on | Flat per organisation tier + add-ons | Standard ₹749 … Ultimate ₹7,999 /org/mo (annual); Expense Claim add-on ₹149/mo (annual) | Free if turnover ≤ ₹25 lakh (1 user + 1 accountant) | Vendor cloud |
| **FreshBooks** | Expenses; team claims not stated | Flat tier + $11 per extra user | Lite $23, Plus $43, Premium $70 /mo | No | Vendor cloud |
| **Wave** | Bookkeeping, receipts | Freemium; earns from payment processing + Pro | Starter free; Pro $19/mo; card fees 2.9% + $0.60 | Yes | Vendor cloud |
| **TallyPrime (India)** | Full accounting; claims via vouchers (no claims workflow checked) | **Perpetual licence** + yearly TSS, or rental | Silver ₹22,500 / Gold ₹67,500 + GST one-time; TSS ₹4,500 / ₹13,500 + GST/yr; rental Silver ₹750/mo | No | **Local** (cloud backup paid extra) |
| **Vyapar (India)** | GST billing + expenses | Yearly licence per plan (desktop); mobile app free | Silver ₹3,799/yr, Gold ₹4,099/yr (desktop page); Platinum ₹9,999/yr | Mobile app free; 7-day desktop trial | Works offline; local backup on desktop (mobile storage UNVERIFIED) |
| **Manager.io** | Built-in **Expense Claims** tab | Desktop free; Server one-time licence; Cloud flat subscription, not per user or business | Desktop free; Server and Cloud prices not shown in extracted page | Desktop free, unlimited | **Desktop: local, offline**; Cloud: vendor |
| **Smart Receipts** | Receipt capture + expense reports | Freemium mobile subscription | Pro $99.99/yr; Max $139/yr | Free plan (manual entry) | Paid tiers back up to vendor cloud |
| **GnuCash** | Double-entry books; no claims workflow | Free, GPL | Free | Free | **Local**, desktop only |
| **Actual Budget** | Household budgeting | Free open source (donations); you host the sync server | Free | Free | Local + your own server; **optional E2EE** |
| **Firefly III** | Double-entry personal finance | Free open source, self-hosted | Free | Free | Your own server |
| **YNAB** | Household budgeting | Flat subscription, shared by up to 6 people | $14.99/mo or $109/yr | 34-day trial | Vendor cloud |
| **Monarch** | Household finance | Subscription only, no ads, no data sales | Price not readable from the official pages fetched (UNVERIFIED) | Trial only | Vendor cloud |

---

## 2. Details

### 2.1 Expense and travel claim tools

- **Expensify.** Collect is pay-per-use at $5 per *unique* member a month.
  Control costs $36 per *active* member a month pay-per-use, or $18 per
  included member on an annual subscription plus $36 for each active member
  above it. Control Annual gets up to 50% off depending on how much spend
  went through the Expensify Card, so it can fall to $9 per member. A free
  "Submit" workspace lets an individual submit to an approver, but without
  approvals, payments or integrations. An "active member" is one with
  expense activity that month.
- **SAP Concur.** Billed per expense report, not per user: Base starts at
  $7 a report and Plus at $11 a report, both with unlimited users. Price
  depends on a monthly commitment. Premium is custom.
- **Zoho Expense (India).** Free for up to 3 users with 20 receipt scans per
  user a month. Standard costs ₹79 per user a month annually or ₹99 monthly.
  Premium costs ₹149 annually or ₹199 monthly. Paid plans need at least 5
  users, and prices exclude GST.
- **Ramp and Brex.** The base product is free ($0 per user), with paid tiers
  at $15 per user plus a platform fee (Ramp Plus) and $12 per user (Brex
  Premium). Neither pricing page says how the free tier is paid for. These
  are card companies, and earning interchange on card spend is the usual
  model, but that is **UNVERIFIED** on their pricing pages (Brex mentions
  "competitive card rewards" and a separate fee schedule).
- **Navan.** Travel booking is free for companies with up to 300 employees.
  The page says revenue comes from "travel providers' commission fees".
  Expense is free for the first 5 users, then $15 per user a month.
- **Rydoo.** Billed per *active* user, meaning someone who did at least one
  action that month (created an expense, approved one, ran a report). Plans
  cost €8 to €12 per user a month, with a 5-user minimum. There is no free
  tier.
- **Fyle (now Sage Expense Management).** fylehq.com/pricing now shows Sage
  Expense Management. It bills per active user: $11.99 (Growth) or $14.99
  (Business) a month, billed annually. An active user is someone who
  "create[s] at least one expense" or has an active connected card. Inactive
  employees are free.
- **Pleo (UK pricing).** £8, £14 and £18 per user a month. Reimbursements
  are not included in Start. Build and Optimise show "0.90%" next to
  reimbursements. **UNVERIFIED**: the extracted page did not make clear
  whether that is a fee on reimbursements or a cashback rate.
- **Spendesk.** Prices are not published. The FAQ describes a fixed
  platform fee plus variable fees on transactions (card purchases, invoice
  payments and expense claims), with no per-user fees.
- **Emburse.** The pricing page shows user-band pricing ($45 a month for 5
  users up to $225 for 50) and API pricing of $0.25 per card with a $500
  monthly minimum. It reads like the Emburse Spend card product. Emburse's
  enterprise expense products (Certify, Chrome River) are not priced there
  (**UNVERIFIED** whether they are contact-sales).
- **Happay (India).** Owned by MakeMyTrip ("© 2026 MakeMyTrip (India)
  Limited"). It offers claims, trip-based reimbursement and prepaid
  corporate cards. No pricing is published, so it is contact-sales. The
  /pricing URL returned HTTP 410.

### 2.2 Small-business accounting with expense claims

- **QuickBooks Online** costs $38, $85, $140 or $340 a month, with users
  capped by tier, and there is a $0 plan for 1 user. **Intuit has withdrawn
  QuickBooks Online from India**: its staff said it will "discontinue
  providing and maintaining QuickBooks Solutions… throughout India". The
  exact date is not in the page text I fetched, but the community threads
  point to 2023.
- **Xero (US)** costs $27, $59 or $97 a month. Expense claims are included
  only in the top Established plan and are not offered as an add-on on the
  lower plans. The India pricing URL returned a 404.
- **Zoho Books (India)** charges a flat price per organisation, from ₹749 a
  month (Standard, 3 users) to ₹7,999 (Ultimate, 25 users) on annual
  billing. It is **free if annual turnover is at most ₹25 lakh** (1 user
  plus 1 accountant, 1,000 invoices and 1,000 expenses a year). Expense
  claims are a separate **Expense Claim add-on at ₹149 a month (annual)**
  or ₹199 a month (monthly). Extra users cost ₹150 a month.
- **FreshBooks** costs $23, $43 or $70 a month for 1 user, plus $11 a month
  per extra team member. The page does not state whether employee claims
  are included.
- **Wave.** The Starter plan is free, and Wave earns from card processing
  at 2.9% + $0.60. Pro costs $19 a month. Receipt scanning is an $11 a month
  add-on.
- **TallyPrime (India)** uses a **one-time perpetual licence**: Silver
  (single user) costs ₹22,500 + GST and Gold (unlimited network users)
  ₹67,500 + GST. Both include one year of TSS, which then renews at ₹4,500
  or ₹13,500 + GST a year. There is also a rental option at ₹750 or ₹2,250 a
  month. Company data is stored locally, and TallyDrive cloud backup costs
  ₹100 a month per 10 GB.
- **Vyapar (India).** The mobile app is free and invoicing works offline
  and syncs later. Desktop plans cost ₹3,799 a year (Silver) or ₹4,099
  (Gold, which adds multi-device sync), and Platinum costs ₹9,999 a year.
  The full pricing page could not be read, so the tier list may be
  incomplete.
- **Manager.io.** The Desktop edition is free with no limits, and it
  "works offline". The **Server edition is a one-time purchase** with
  12 months of updates included. The **Cloud edition is a flat subscription,
  not per user or per business** ("5 or 50, the price is the same"). The
  actual Server and Cloud prices were not in the extracted page text
  (**UNVERIFIED**). It has a built-in **Expense Claims** tab for employees
  or members who paid from their own money.

### 2.3 Closest to Smara's model (local, offline, private, household)

- **Manager.io Desktop** and **TallyPrime** keep the books local and offline,
  and both handle business claims or vouchers. Neither is end-to-end
  encrypted, and neither has peer-to-peer sync. Tally's multi-user setup
  works over a network, with cloud access as a paid extra.
- **GnuCash** is free (GPL), double-entry and local on the desktop. It has
  no claims workflow and the official site describes no mobile sync.
- **Actual Budget** is the closest match in architecture. It is local-first,
  syncs through a server you host yourself, and has **optional end-to-end
  encryption** ("the server will no longer be able to access your budget
  information"). It is free and open source, funded by donations. It is for
  household budgeting, not double-entry books or claims.
- **Firefly III** is free, open source, self-hosted and double-entry. It is
  for personal finance and has no claim workflow.
- **YNAB** costs $14.99 a month or $109 a year, and one subscription can be
  **shared by up to 6 people**, which is a household model. Data lives on
  the vendor's cloud.
- **Monarch** is subscription-only and says it makes no money from ads or
  from selling data. The price was not readable from the pages fetched.
- **Smart Receipts** captures receipts and builds expense reports. It has a
  free plan, and Pro ($99.99 a year) adds cloud backup. The site does not
  say whether the free tier stays purely on the device (**UNVERIFIED**).

Of all the products checked, **none is end-to-end encrypted and serverless
while also handling claims**. Actual Budget is the only one with E2EE, and
it still needs a sync server.

---

## 3. Billing patterns seen

| Pattern | Who uses it |
|---|---|
| Per user (seat) per month, often with a minimum | Zoho Expense (min 5), Pleo, Brex Premium, Ramp Plus, FreshBooks extra users |
| Per **active** user per month (inactive users free) | Rydoo, Sage Expense Management (ex-Fyle), Expensify Control |
| Per unique member, pay-per-use, no contract | Expensify Collect ($5) |
| **Per expense report** (usage) | SAP Concur ($7 or $11 per report) |
| Flat per company or organisation tier, users capped | QuickBooks, Xero, Zoho Books, Manager Cloud (not per user at all) |
| Claims as a **paid add-on or top-tier-only feature** | Zoho Books (Expense Claim add-on ₹149/mo), Xero (Established only) |
| Free software paid for by **card interchange or payments** | Ramp, Brex (likely; UNVERIFIED on page), Wave (2.9% card processing), Expensify (card use discounts the subscription) |
| Free software paid for by **travel commissions** | Navan |
| Platform fee + transaction fees, unlimited users | Spendesk, Ramp Plus (platform fee) |
| Freemium with a size or turnover cap | Zoho Expense (3 users), Zoho Books (≤ ₹25 lakh), QuickBooks Free, Navan (≤300 employees, 5 expense users) |
| **One-time perpetual licence + optional yearly updates** | TallyPrime (+ TSS), Manager Server |
| Yearly licence per plan | Vyapar desktop |
| Free and open source / self-host (donations) | GnuCash, Actual Budget, Firefly III, Manager Desktop |
| Household subscription shared by several people | YNAB (up to 6) |
| Freemium mobile app, paid tier adds cloud backup | Smart Receipts, TallyDrive (paid cloud backup add-on) |

---

## 4. What could fit Smara (inference)

**This section is my inference, not something a source says.**

Smara has no server and stores data only on the devices, so the patterns
that depend on vendor-side infrastructure don't fit naturally:

- *Interchange or travel commissions* need Smara to issue cards or book
  travel, which is a regulated business far outside this product.
- *Per active user or per report* needs a server to count activity. Smara
  could only count on the device, which can't be enforced. It also undercuts
  the "we see nothing" privacy promise.

The patterns that fit:

1. **Free household tier, paid business ("company books") tier.** This
   mirrors Zoho Books (free under ₹25 lakh) and YNAB's household sharing.
   Household books stay free. Turning on company features (Claims, Approver
   roles, more than N Members) unlocks with a paid licence.
2. **Per-company (per set of books) subscription, not per seat.** This is
   Manager Cloud's "5 or 50, the price is the same" and the Zoho or Xero
   per-organisation tiers. The Approver's device holds the licence, and
   Claimants submit for free. That matches how claims tools already favour
   submitters (Expensify's free Submit workspace, Sage and Rydoo charging
   only active users). It is also easy to enforce offline, through a signed
   licence held by the books owner.
3. **One-time licence plus optional yearly updates**, like TallyPrime and
   Manager Server. Indian small businesses already know this model from
   Tally, and it suits an app that works without any server. It could be
   sold through the app stores as a one-time unlock per company.
4. **A paid optional relay**, if remote claims (see
   `remote-sync-and-claim-options.md`) ever bring in an end-to-end encrypted
   relay. That relay has real running costs, so a small subscription for
   "sync and claim away from the office Wi-Fi" is easy to justify. Wi-Fi
   sync stays free. The relay only ever carries ciphertext, so the privacy
   pitch holds. Actual Budget makes the same split by having users run
   their own server, and Smara could offer self-hosting as the free route.
5. **Price anchors for India.** Zoho Expense is ₹79 to ₹199 per user a month
   and the Zoho Books Expense Claim add-on is ₹149 a month. Vyapar costs
   ₹3,799 to ₹9,999 a year and Tally Silver ₹22,500 one-time. A
   per-company plan in the low hundreds of rupees a month, or a one-time
   price of a few thousand, would sit inside the range Indian small
   businesses already pay.

Suggested lead combination: **free household, a per-company subscription
or one-time unlock for business claims, and a paid optional relay later.**
None of the competitors checked can make the "your claims never touch our
servers" promise, so privacy is the selling point.

---

## 5. Not verified

- Ramp and Brex revenue from interchange (not stated on their pricing pages).
- What Pleo's "0.90%" next to reimbursements means (fee or cashback).
- Manager.io Server and Cloud prices, Monarch's price, and Happay's and
  Spendesk's prices (contact sales).
- Pricing for Emburse's enterprise expense products (Certify, Chrome River).
- Xero India pricing (the URL returned 404, so US prices are shown).
- Vyapar's full tier list (the pricing page body could not be read) and
  whether Smart Receipts' free tier is device-only.
- The exact date QuickBooks Online India shut down.

---

## Sources

All read 2026-10-05.

- Expensify pricing (help centre): https://help.expensify.com/articles/new-expensify/billing-and-subscriptions/explore-plans-subscriptions-and-pricing/Understand-Expensify-Pricing
- SAP Concur pricing: https://www.concur.com/about/pricing
- Zoho Expense India pricing: https://www.zoho.com/in/expense/pricing/
- Ramp pricing: https://ramp.com/pricing
- Brex pricing: https://www.brex.com/pricing
- Navan pricing: https://navan.com/pricing
- Rydoo pricing: https://www.rydoo.com/pricing/
- Fyle / Sage Expense Management pricing: https://www.fylehq.com/pricing
- Pleo pricing: https://www.pleo.io/en/pricing
- Spendesk pricing: https://www.spendesk.com/en/pricing/
- Emburse pricing: https://www.emburse.com/pricing
- Happay home page: https://happay.com/
- QuickBooks pricing: https://quickbooks.intuit.com/pricing/
- QuickBooks India withdrawal (Intuit community, staff answer): https://quickbooks.intuit.com/learn-support/global/manage-customers-and-income/can-i-know-why-quickbooks-india-online-will-not-be-available/00/1228249
- Xero US pricing: https://www.xero.com/us/pricing-plans/
- Zoho Books India pricing: https://www.zoho.com/in/books/pricing/
- FreshBooks pricing: https://www.freshbooks.com/pricing
- Wave pricing: https://www.waveapps.com/pricing
- TallyPrime cost of ownership (Tally's own guide): https://tallysolutions.com/business-guides/tallyprime-total-cost-of-ownership-india/
- Vyapar desktop page: https://vyaparapp.in/gst-accounting-pc ; Vyapar Platinum: https://vyaparapp.in/platinum-plan
- Manager.io home: https://www2.manager.io/ ; Cloud pricing: https://www2.manager.io/cloud/pricing ; Server: https://www2.manager.io/server/ ; Expense claims guide: https://www2.manager.io/guides/6898
- Smart Receipts: https://www.smartreceipts.co/
- GnuCash: https://www.gnucash.org/
- Actual Budget sync docs: https://actualbudget.org/docs/getting-started/sync
- Firefly III: https://www.firefly-iii.org/
- YNAB pricing: https://www.ynab.com/pricing
- Monarch pricing help article: https://help.monarch.com/hc/en-us/articles/9136169422996-Pricing
