import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smara_accounting/data/database/app_database.dart';
import 'package:smara_accounting/data/repositories/account_repository.dart';
import 'package:smara_accounting/data/repositories/category_repository.dart';
import 'package:smara_accounting/data/repositories/claim_person_service.dart';
import 'package:smara_accounting/data/repositories/claim_receipt_store.dart';
import 'package:smara_accounting/data/repositories/claim_repository.dart';
import 'package:smara_accounting/data/repositories/identity_repository.dart';
import 'package:smara_accounting/data/repositories/ledger_repository.dart';
import 'package:smara_accounting/data/repositories/membership_repository.dart';
import 'package:smara_accounting/domain/app_error.dart';
import 'package:smara_accounting/domain/crypto/signing_key_service.dart';
import 'package:smara_accounting/domain/models/account_type.dart';
import 'package:smara_accounting/domain/models/claim_item_decision_kind.dart';
import 'package:smara_accounting/domain/models/claim_status.dart';
import 'package:smara_accounting/domain/models/linked_device_role.dart';

import '../../domain/crypto/in_memory_secure_key_storage.dart';

void main() {
  late AppDatabase db;
  late IdentityRepository identity;
  late MembershipRepository membership;
  late AccountRepository accounts;
  late CategoryRepository categories;
  late LedgerRepository ledger;
  late ClaimRepository claims;
  late ClaimPersonService people;
  late Directory tempDir;
  late String travelCategoryId;
  late String bankAccountId;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('claims-test-');
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final keys = SigningKeyService(secureStorage: InMemorySecureKeyStorage());
    ledger = LedgerRepository(database: db, signingKeyService: keys);
    accounts = AccountRepository(database: db, ledgerRepository: ledger);
    categories = CategoryRepository(database: db);
    identity = IdentityRepository(
      database: db,
      accountRepository: accounts,
      signingKeyService: keys,
    );
    membership = MembershipRepository(
      database: db,
      identityRepository: identity,
    );
    people = ClaimPersonService(
      membership: membership,
      accounts: accounts,
      database: db,
    );
    final receipts = ClaimReceiptStore(
      database: db,
      booksSetId: 'test-books',
      supportDirectory: tempDir,
    );
    claims = ClaimRepository(
      database: db,
      membership: membership,
      ledger: ledger,
      receipts: receipts,
    );

    final generated = await identity.generateFirstIdentity();
    await identity.confirmFirstIdentity(generated, currency: 'USD');
    await membership.ensureLocalOwner(
      localDeviceId: 'owner-device',
      displayName: 'Office',
    );

    // Promote owner roles to include Approver for decision tests.
    await (db.update(
      db.linkedDevices,
    )..where((t) => t.deviceId.equals('owner-device'))).write(
      LinkedDevicesCompanion(
        rolesCsv: Value(
          MembershipRoleGates.encodeRoles({
            LinkedDeviceRole.owner,
            LinkedDeviceRole.approver,
          }),
        ),
      ),
    );

    final cats = await categories.watchCategories().first;
    travelCategoryId = cats.firstWhere((c) => c.type == AccountType.expense).id;
    await claims.setAllowlistedCategories({travelCategoryId});

    final financial = await accounts.watchFinancialAccounts().first;
    bankAccountId = financial.first.id;

    // Seed books metadata for receipt threshold.
    await db
        .into(db.booksSetMetadata)
        .insert(
          BooksSetMetadataCompanion.insert(
            id: 'test-books',
            displayName: 'Acme',
          ),
        );
  });

  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  Future<void> addClaimantRavi() async {
    final peer = await identity.addLinkedPeerIdentity(
      publicKey: List<int>.generate(32, (i) => i + 10),
    );
    final owed = await people.ensureOwedToAccount(
      displayName: 'Ravi',
      currency: 'USD',
    );
    await membership.addDevice(
      actorDeviceId: 'owner-device',
      deviceId: 'ravi-device',
      displayName: 'Ravi phone',
      signingIdentityId: peer.identityId,
      deviceCertFingerprint: 'fp-ravi',
      roles: {LinkedDeviceRole.claimant},
      owedToAccountId: owed.id,
      personDisplayName: 'Ravi',
    );
  }

  test('Add Claimant creates Owed to account once and reuses it', () async {
    final first = await people.ensureOwedToAccount(
      displayName: 'Ravi',
      currency: 'USD',
    );
    expect(first.name, 'Owed to Ravi');
    final second = await people.ensureOwedToAccount(
      displayName: 'Ravi',
      currency: 'USD',
    );
    expect(second.id, first.id);
  });

  test('submit does not create Journal Entries', () async {
    await addClaimantRavi();
    final before = await ledger.watchEntries().first;
    final claim = await claims.createDraft(claimantDeviceId: 'ravi-device');
    await claims.addItem(
      claimId: claim.id,
      actorDeviceId: 'ravi-device',
      categoryId: travelCategoryId,
      expenseDate: DateTime(2026, 3, 1),
      paidCurrency: 'USD',
      paidAmountMinor: 5000,
      companyCurrencyAmountMinor: 5000,
      description: 'Taxi',
    );
    final item = (await claims.getClaim(claim.id))!.items.single;
    final store = ClaimReceiptStore(
      database: db,
      booksSetId: 'test-books',
      supportDirectory: tempDir,
    );
    await store.attach(
      claimItemId: item.id,
      bytes: List<int>.filled(200, 2),
      contentType: 'image/jpeg',
      fileName: 'taxi.jpg',
    );

    final submitted = await claims.submit(
      claimId: claim.id,
      actorDeviceId: 'ravi-device',
    );
    expect(submitted.status, ClaimStatus.submitted);
    final after = await ledger.watchEntries().first;
    expect(after.length, before.length);
  });

  test('approve posts balanced entry; reject does not', () async {
    await addClaimantRavi();
    final claim = await claims.createDraft(claimantDeviceId: 'ravi-device');
    await claims.addItem(
      claimId: claim.id,
      actorDeviceId: 'ravi-device',
      categoryId: travelCategoryId,
      expenseDate: DateTime(2026, 3, 2),
      paidCurrency: 'EUR',
      paidAmountMinor: 10000,
      companyCurrencyAmountMinor: 12000,
      employeeStatedRate: 1.2,
    );
    final itemA = (await claims.getClaim(claim.id))!.items.single;
    final store = ClaimReceiptStore(
      database: db,
      booksSetId: 'test-books',
      supportDirectory: tempDir,
    );
    await store.attach(
      claimItemId: itemA.id,
      bytes: List<int>.filled(50, 3),
      contentType: 'image/jpeg',
      fileName: 'a.jpg',
    );
    await claims.addItem(
      claimId: claim.id,
      actorDeviceId: 'ravi-device',
      categoryId: travelCategoryId,
      expenseDate: DateTime(2026, 3, 3),
      paidCurrency: 'USD',
      paidAmountMinor: 2000,
      companyCurrencyAmountMinor: 2000,
    );
    final itemB = (await claims.getClaim(claim.id))!.items[1];
    await store.attach(
      claimItemId: itemB.id,
      bytes: List<int>.filled(50, 4),
      contentType: 'image/jpeg',
      fileName: 'b.jpg',
    );
    await claims.submit(claimId: claim.id, actorDeviceId: 'ravi-device');

    final before = await ledger.watchEntries().first;
    await claims.approveItem(
      claimItemId: itemA.id,
      actorDeviceId: 'owner-device',
    );
    await claims.rejectItem(
      claimItemId: itemB.id,
      actorDeviceId: 'owner-device',
      reason: 'Out of policy',
    );
    final after = await ledger.watchEntries().first;
    expect(after.length, before.length + 1);

    final decided = await claims.getClaim(claim.id);
    expect(decided!.items.where((i) => i.isPendingDecision), isEmpty);
    expect(decided.status, ClaimStatus.approved);

    final entry = after.last;
    final sum = entry.postings.fold<int>(0, (s, p) => s + p.amountMinor);
    expect(sum, 0);
    expect(entry.signedByIdentityId, isNotEmpty);

    final rejectDecision = decided.items
        .firstWhere((i) => i.id == itemB.id)
        .decision!;
    expect(rejectDecision.kind, ClaimItemDecisionKind.reject);
    expect(rejectDecision.postedEntryId, isNull);
    expect(rejectDecision.reason, 'Out of policy');
  });

  test('payment updates claimant balance; advances reduce owed', () async {
    await addClaimantRavi();
    final claim = await claims.createDraft(claimantDeviceId: 'ravi-device');
    await claims.addItem(
      claimId: claim.id,
      actorDeviceId: 'ravi-device',
      categoryId: travelCategoryId,
      expenseDate: DateTime(2026, 3, 4),
      paidCurrency: 'USD',
      paidAmountMinor: 8000,
      companyCurrencyAmountMinor: 8000,
    );
    final item = (await claims.getClaim(claim.id))!.items.single;
    final store = ClaimReceiptStore(
      database: db,
      booksSetId: 'test-books',
      supportDirectory: tempDir,
    );
    await store.attach(
      claimItemId: item.id,
      bytes: List<int>.filled(40, 5),
      contentType: 'image/jpeg',
      fileName: 'c.jpg',
    );
    await claims.submit(claimId: claim.id, actorDeviceId: 'ravi-device');
    await claims.approveItem(
      claimItemId: item.id,
      actorDeviceId: 'owner-device',
    );

    // After approve: company owes claimant ~8000 (liability display).
    final afterApprove = await claims.claimantBalanceMinor('ravi-device');
    expect(afterApprove, 8000);

    await claims.recordPayment(
      actorDeviceId: 'owner-device',
      claimantDeviceId: 'ravi-device',
      bankAccountId: bankAccountId,
      amountMinor: 8000,
      claimId: claim.id,
    );
    final afterPay = await claims.claimantBalanceMinor('ravi-device');
    expect(afterPay, 0);
    expect((await claims.getClaim(claim.id))!.status, ClaimStatus.paid);

    await claims.recordAdvance(
      actorDeviceId: 'owner-device',
      claimantDeviceId: 'ravi-device',
      bankAccountId: bankAccountId,
      amountMinor: 20000,
    );
    final afterAdvance = await claims.claimantBalanceMinor('ravi-device');
    expect(afterAdvance, -20000);
    final advances = await claims.listAdvances('ravi-device');
    expect(advances, hasLength(1));
  });

  test(
    'over-hint still submittable; disallowed category hidden by allowlist',
    () async {
      await addClaimantRavi();
      await claims.setSpendingHint(
        categoryId: travelCategoryId,
        maxAmountMinor: 1000,
        unitLabel: 'night',
      );
      final claim = await claims.createDraft(claimantDeviceId: 'ravi-device');
      await claims.addItem(
        claimId: claim.id,
        actorDeviceId: 'ravi-device',
        categoryId: travelCategoryId,
        expenseDate: DateTime(2026, 3, 5),
        paidCurrency: 'USD',
        paidAmountMinor: 5000,
        companyCurrencyAmountMinor: 5000,
      );
      final item = (await claims.getClaim(claim.id))!.items.single;
      final store = ClaimReceiptStore(
        database: db,
        booksSetId: 'test-books',
        supportDirectory: tempDir,
      );
      await store.attach(
        claimItemId: item.id,
        bytes: List<int>.filled(20, 6),
        contentType: 'image/jpeg',
        fileName: 'd.jpg',
      );
      final submitted = await claims.submit(
        claimId: claim.id,
        actorDeviceId: 'ravi-device',
      );
      expect(submitted.status, ClaimStatus.submitted);

      final other = await categories.watchCategories().first;
      final otherExpense = other.firstWhere(
        (c) => c.type == AccountType.expense && c.id != travelCategoryId,
      );
      final claim2 = await claims.createDraft(claimantDeviceId: 'ravi-device');
      await expectLater(
        claims.addItem(
          claimId: claim2.id,
          actorDeviceId: 'ravi-device',
          categoryId: otherExpense.id,
          expenseDate: DateTime(2026, 3, 6),
          paidCurrency: 'USD',
          paidAmountMinor: 100,
          companyCurrencyAmountMinor: 100,
        ),
        throwsA(isA<AppFailure>()),
      );
    },
  );

  test(
    'FX: employee rate used; Approver can override before approve',
    () async {
      await addClaimantRavi();
      final claim = await claims.createDraft(claimantDeviceId: 'ravi-device');
      final item = await claims.addItem(
        claimId: claim.id,
        actorDeviceId: 'ravi-device',
        categoryId: travelCategoryId,
        expenseDate: DateTime(2026, 3, 7),
        paidCurrency: 'EUR',
        paidAmountMinor: 10000,
        companyCurrencyAmountMinor: 11000,
        employeeStatedRate: 1.1,
      );
      expect(item.rateUsed, 1.1);
      expect(item.companyCurrencyAmountMinor, 11000);

      await claims.updateItemRate(
        claimItemId: item.id,
        actorDeviceId: 'owner-device',
        rateUsed: 1.25,
        companyCurrencyAmountMinor: 12500,
      );
      final updated = (await claims.getClaim(claim.id))!.items.single;
      expect(updated.rateUsed, 1.25);
      expect(updated.companyCurrencyAmountMinor, 12500);
    },
  );

  test(
    'receipt PDF over 5MB refused; photo compressed; retention after reject',
    () async {
      await addClaimantRavi();
      final claim = await claims.createDraft(claimantDeviceId: 'ravi-device');
      await claims.addItem(
        claimId: claim.id,
        actorDeviceId: 'ravi-device',
        categoryId: travelCategoryId,
        expenseDate: DateTime(2026, 3, 8),
        paidCurrency: 'USD',
        paidAmountMinor: 100,
        companyCurrencyAmountMinor: 100,
      );
      final item = (await claims.getClaim(claim.id))!.items.single;
      final store = ClaimReceiptStore(
        database: db,
        booksSetId: 'test-books',
        supportDirectory: tempDir,
      );

      await expectLater(
        store.attach(
          claimItemId: item.id,
          bytes: List<int>.filled(ClaimReceiptStore.maxPdfBytes + 1, 9),
          contentType: 'application/pdf',
          fileName: 'big.pdf',
        ),
        throwsA(isA<AppFailure>()),
      );

      final bigPhoto = List<int>.filled(2 * 1024 * 1024, 7);
      final receipt = await store.attach(
        claimItemId: item.id,
        bytes: bigPhoto,
        contentType: 'image/jpeg',
        fileName: 'big.jpg',
      );
      expect(
        receipt.byteSize,
        lessThanOrEqualTo(ClaimReceiptStore.targetPhotoBytes),
      );

      await claims.setReceiptRequiredAboveMinor(50);
      // amount 100 > 50, receipt present — ok
      await claims.submit(claimId: claim.id, actorDeviceId: 'ravi-device');
      await claims.rejectItem(
        claimItemId: item.id,
        actorDeviceId: 'owner-device',
        reason: 'Duplicate',
      );
      final bytes = await store.readBytes(receipt.id);
      expect(bytes, isNotEmpty);
      expect((await claims.getClaim(claim.id))!.status, ClaimStatus.rejected);
    },
  );

  test('Claimant cannot approve', () async {
    await addClaimantRavi();
    final claim = await claims.createDraft(claimantDeviceId: 'ravi-device');
    await claims.addItem(
      claimId: claim.id,
      actorDeviceId: 'ravi-device',
      categoryId: travelCategoryId,
      expenseDate: DateTime(2026, 3, 9),
      paidCurrency: 'USD',
      paidAmountMinor: 100,
      companyCurrencyAmountMinor: 100,
    );
    final item = (await claims.getClaim(claim.id))!.items.single;
    final store = ClaimReceiptStore(
      database: db,
      booksSetId: 'test-books',
      supportDirectory: tempDir,
    );
    await store.attach(
      claimItemId: item.id,
      bytes: [1, 2, 3],
      contentType: 'image/jpeg',
      fileName: 'e.jpg',
    );
    await claims.submit(claimId: claim.id, actorDeviceId: 'ravi-device');
    await expectLater(
      claims.approveItem(claimItemId: item.id, actorDeviceId: 'ravi-device'),
      throwsA(isA<AppFailure>()),
    );
  });

  test(
    'removalWarning reports open claims and balance; history stays after remove',
    () async {
      await addClaimantRavi();
      final claim = await claims.createDraft(claimantDeviceId: 'ravi-device');
      await claims.addItem(
        claimId: claim.id,
        actorDeviceId: 'ravi-device',
        categoryId: travelCategoryId,
        expenseDate: DateTime(2026, 3, 10),
        paidCurrency: 'USD',
        paidAmountMinor: 8000,
        companyCurrencyAmountMinor: 8000,
        description: 'Train',
      );
      final item = (await claims.getClaim(claim.id))!.items.single;
      final store = ClaimReceiptStore(
        database: db,
        booksSetId: 'test-books',
        supportDirectory: tempDir,
      );
      final receipt = await store.attach(
        claimItemId: item.id,
        bytes: List<int>.filled(120, 3),
        contentType: 'image/jpeg',
        fileName: 'train.jpg',
      );
      await claims.submit(claimId: claim.id, actorDeviceId: 'ravi-device');
      await claims.approveItem(
        claimItemId: item.id,
        actorDeviceId: 'owner-device',
      );

      final warning = await claims.removalWarning(
        targetDeviceId: 'ravi-device',
      );
      expect(warning.openClaims, 1);
      expect(warning.balanceMinor, isNot(0));

      await people.removePerson(
        actorDeviceId: 'owner-device',
        targetDeviceId: 'ravi-device',
        balanceMinor: warning.balanceMinor,
      );

      final removed = await membership.findByDeviceId('ravi-device');
      expect(removed!.isActive, isFalse);

      final stillThere = await claims.getClaim(claim.id);
      expect(stillThere, isNotNull);
      expect(stillThere!.items, hasLength(1));
      final bytes = await store.readBytes(receipt.id);
      expect(bytes, isNotEmpty);
    },
  );
}
