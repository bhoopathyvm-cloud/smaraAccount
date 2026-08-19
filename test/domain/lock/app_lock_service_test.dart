import 'package:smara_accounting/domain/lock/app_lock_service.dart';
import 'package:test/test.dart';

import '../crypto/in_memory_secure_key_storage.dart';

void main() {
  late AppLockService service;

  setUp(() {
    service = AppLockService(secureStorage: InMemorySecureKeyStorage());
  });

  test('hasPinSet is false until a PIN is set', () async {
    expect(await service.hasPinSet(), isFalse);

    await service.setPin('1234');

    expect(await service.hasPinSet(), isTrue);
  });

  test('verifyPin accepts the correct PIN and rejects a wrong one', () async {
    await service.setPin('4242');

    expect(await service.verifyPin('4242'), isTrue);
    expect(await service.verifyPin('0000'), isFalse);
  });

  test(
    'verifyPin is false (not throwing) when no PIN has ever been set',
    () async {
      expect(await service.verifyPin('1234'), isFalse);
    },
  );

  test('setPin overwrites a previous PIN - only the newest verifies', () async {
    await service.setPin('1111');
    await service.setPin('2222');

    expect(await service.verifyPin('1111'), isFalse);
    expect(await service.verifyPin('2222'), isTrue);
  });

  test('clearPin removes the stored PIN entirely', () async {
    await service.setPin('1234');
    await service.clearPin();

    expect(await service.hasPinSet(), isFalse);
    expect(await service.verifyPin('1234'), isFalse);
  });

  test(
    'the same PIN set twice produces different stored records (salted)',
    () async {
      final storage = InMemorySecureKeyStorage();
      final serviceA = AppLockService(secureStorage: storage);
      await serviceA.setPin('1234');
      final firstRecord = await storage.read('app_lock_pin_record');

      await serviceA.setPin('1234');
      final secondRecord = await storage.read('app_lock_pin_record');

      expect(firstRecord, isNot(equals(secondRecord)));
    },
  );
}
