import 'package:test/test.dart';

import 'package:smara_accounting/domain/account/financial_account_draft.dart';
import 'package:smara_accounting/domain/models/account.dart';
import 'package:smara_accounting/domain/models/account_group.dart';

AccountGroup _group({
  required String id,
  required AccountGroupKind kind,
  String? currency = 'USD',
}) {
  return AccountGroup(
    id: id,
    name: id,
    kind: kind,
    sortOrder: 0,
    isSystem: false,
    currency: currency,
    archived: false,
  );
}

void main() {
  group('FinancialAccountDraft', () {
    final assetGroups = [
      _group(id: 'cash', kind: AccountGroupKind.assetGroup, currency: 'EUR'),
      _group(id: 'savings', kind: AccountGroupKind.assetGroup, currency: 'EUR'),
    ];

    test('ensureValidGroupSelection defaults to first, then keeps a valid pick', () {
      final draft = FinancialAccountDraft();
      draft.ensureValidGroupSelection(assetGroups);
      expect(draft.groupId, 'cash');
      draft.groupId = 'savings';
      draft.ensureValidGroupSelection(assetGroups);
      expect(draft.groupId, 'savings');
    });

    test('ensureValidGroupSelection nulls out when the list is empty', () {
      final draft = FinancialAccountDraft()..groupId = 'cash';
      draft.ensureValidGroupSelection(const []);
      expect(draft.groupId, isNull);
    });

    test('selectedGroupCurrency reflects the chosen group', () {
      final draft = FinancialAccountDraft();
      draft.ensureValidGroupSelection(assetGroups);
      expect(draft.selectedGroupCurrency(assetGroups), 'EUR');
      draft.groupId = null;
      expect(draft.selectedGroupCurrency(assetGroups), isNull);
    });

    test('setType clears group and the flag that no longer applies', () {
      final draft = FinancialAccountDraft()..holdsInvestments = true;
      draft.ensureValidGroupSelection(assetGroups);
      expect(draft.groupId, 'cash');

      draft.setType(AccountType.liability);
      expect(draft.groupId, isNull);
      expect(draft.holdsInvestments, isFalse);
      expect(draft.hasSelectedGroup, isFalse);

      draft.isCreditCard = true;
      draft.setType(AccountType.asset);
      expect(draft.isCreditCard, isFalse);
    });

    test('setType is a no-op for the same type (keeps flags and selection)', () {
      final draft = FinancialAccountDraft()..holdsInvestments = true;
      draft.ensureValidGroupSelection(assetGroups);
      draft.setType(AccountType.asset);
      expect(draft.groupId, 'cash');
      expect(draft.holdsInvestments, isTrue);
    });
  });
}
