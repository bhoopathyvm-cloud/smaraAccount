# Proposal: extract-investment-trade-posting

## Why
Holdings drafts and valuation domain are done; buy/sell/dividend write composition (~350 lines) still sits on `InvestmentRepository`. Architecture cycle 14: extract `InvestmentTradePosting` (LedgerPosting facade pattern).

## What Changes
- Add `investment_trade_posting.dart` with recordBuy/Sell/Dividend.
- `InvestmentRepository` becomes instruments/holdings + thin trade facade.

## Impact
- Spec: `investment-trade-posting`. Public API unchanged.
