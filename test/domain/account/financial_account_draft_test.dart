import 'package:test/test.dart';

import 'package:smara_accounting/domain/account/financial_account_draft.dart';
import 'package:smara_accounting/domain/models/account.dart';
import 'package:smara_accounting/domain/models/account_group.dart';

AccountGroup _group({
  required String id,
  required AccountGroupKind kind,
  String? currency = 'USD',
  bool archived = false,
}) {
  return AccountGroup(
    id: id,
    name: id,
    kind: kind,
    sortOrder: 0,
    isSystem: false,
    currency: currency,
    archived: archived,
  );
}

void main() {
  group('FinancialAccountDraft', () {
    final groups = [
      _group(id: 'assets', kind: AccountGroupKind.assetGroup, currency: 'EUR'),
      _group(id: 'archived-assets', kind: AccountGroupKind.assetGroup, archived: true),
      _group(id: 'debts', kind: AccountGroupKind.liabilityGroup, currency: 'GBP'),
    ];

    test('groupsForType filters by kind and excludes archived', () {
      final draft = FinancialAccountDraft()..groups = groups;
      expect(draft.groupsForType.map((g) => g.id), ['assets']);
      draft.type = AccountType.liability;
      expect(draft.groupsForType.map((g) => g.id), ['debts']);
    });

    test('ensureValidGroupSelection defaults to first available, then keeps it', () {
      final draft = FinancialAccountDraft()..groups = groups;
      draft.ensureValidGroupSelection();
      expect(draft.groupId, 'assets');
      // A still-valid selection is left untouched.
      draft.ensureValidGroupSelection();
      expect(draft.groupId, 'assets');
    });

    test('ensureValidGroupSelection nulls out when no group of the kind exists', () {
      final draft = FinancialAccountDraft()
        ..groups = [_group(id: 'debts', kind: AccountGroupKind.liabilityGroup)];
      draft.ensureValidGroupSelection();
      expect(draft.groupId, isNull);
    });

    test('selectedGroupCurrency reflects the chosen group', () {
      final draft = FinancialAccountDraft()..groups = groups;
      draft.ensureValidGroupSelection();
      expect(draft.selectedGroupCurrency, 'EUR');
      draft.groupId = null;
      expect(draft.selectedGroupCurrency, isNull);
    });

    test('setType clears group and the flag that no longer applies', () {
      final draft = FinancialAccountDraft()
        ..groups = groups
        ..holdsInvestments = true;
      draft.ensureValidGroupSelection();
      expect(draft.groupId, 'assets');

      draft.setType(AccountType.liability);
      expect(draft.groupId, isNull);
      expect(draft.holdsInvestments, isFalse);
      expect(draft.hasSelectedGroup, isFalse);

      draft.isCreditCard = true;
      draft.setType(AccountType.asset);
      expect(draft.isCreditCard, isFalse);
    });

    test('setType is a no-op for the same type (keeps flags and selection)', () {
      final draft = FinancialAccountDraft()
        ..groups = groups
        ..holdsInvestments = true;
      draft.ensureValidGroupSelection();
      draft.setType(AccountType.asset);
      expect(draft.groupId, 'assets');
      expect(draft.holdsInvestments, isTrue);
    });
  });
}
