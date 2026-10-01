import 'package:smara_accounting/domain/claims/claim_status_derivation.dart';
import 'package:smara_accounting/domain/models/claim_item.dart';
import 'package:smara_accounting/domain/models/claim_item_decision.dart';
import 'package:smara_accounting/domain/models/claim_item_decision_kind.dart';
import 'package:smara_accounting/domain/models/claim_status.dart';
import 'package:test/test.dart';

ClaimItem _item({ClaimItemDecision? decision}) {
  return ClaimItem(
    id: 'i1',
    claimId: 'c1',
    categoryId: 'cat',
    expenseDate: DateTime(2026, 1, 1),
    paidCurrency: 'USD',
    paidAmountMinor: 100,
    companyCurrencyAmountMinor: 100,
    sortOrder: 0,
    createdAt: DateTime(2026, 1, 1),
    decision: decision,
  );
}

ClaimItemDecision _dec(ClaimItemDecisionKind kind) => ClaimItemDecision(
  id: 'd',
  claimItemId: 'i1',
  kind: kind,
  decidedByDeviceId: 'a',
  decidedAt: DateTime(2026, 1, 2),
  approvedAmountMinor: kind == ClaimItemDecisionKind.reject ? null : 100,
  reason: kind == ClaimItemDecisionKind.reject ? 'no' : null,
);

void main() {
  test('draft when not submitted', () {
    expect(
      ClaimStatusDerivation.derive(
        isSubmitted: false,
        items: [_item()],
        approvedAmountFullySettled: false,
      ),
      ClaimStatus.draft,
    );
  });

  test('submitted when no decisions', () {
    expect(
      ClaimStatusDerivation.derive(
        isSubmitted: true,
        items: [_item(), _item()],
        approvedAmountFullySettled: false,
      ),
      ClaimStatus.submitted,
    );
  });

  test('partly approved when mix of approved and pending', () {
    expect(
      ClaimStatusDerivation.derive(
        isSubmitted: true,
        items: [
          _item(decision: _dec(ClaimItemDecisionKind.approve)),
          _item(),
        ],
        approvedAmountFullySettled: false,
      ),
      ClaimStatus.partlyApproved,
    );
  });

  test('rejected when all rejected', () {
    expect(
      ClaimStatusDerivation.derive(
        isSubmitted: true,
        items: [
          _item(decision: _dec(ClaimItemDecisionKind.reject)),
          _item(decision: _dec(ClaimItemDecisionKind.reject)),
        ],
        approvedAmountFullySettled: false,
      ),
      ClaimStatus.rejected,
    );
  });

  test('approved then paid when settled', () {
    final items = [_item(decision: _dec(ClaimItemDecisionKind.approve))];
    expect(
      ClaimStatusDerivation.derive(
        isSubmitted: true,
        items: items,
        approvedAmountFullySettled: false,
      ),
      ClaimStatus.approved,
    );
    expect(
      ClaimStatusDerivation.derive(
        isSubmitted: true,
        items: items,
        approvedAmountFullySettled: true,
      ),
      ClaimStatus.paid,
    );
  });
}
