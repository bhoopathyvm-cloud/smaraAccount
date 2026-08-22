import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smara_accounting/domain/exceptions.dart';
import 'package:smara_accounting/l10n/l10n.dart';

class _FakeViewModel extends ChangeNotifier with LocalizedErrorMixin {
  void fail() =>
      setFailure(const AppFailure(AppErrorCode.amountMustBePositive));
}

void main() {
  test('errorMessageFor follows the active locale; errorMessage stays English '
      'for VM unit tests (regression: error messages were permanently baked '
      'to English at throw-time via localizeVmError, never re-localized)', () {
    final vm = _FakeViewModel();
    vm.fail();

    final en = lookupAppLocalizations(const Locale('en'));
    final ta = lookupAppLocalizations(const Locale('ta'));

    expect(vm.errorMessageFor(en), equals(en.errorAmountMustBePositive));
    expect(vm.errorMessageFor(ta), equals(ta.errorAmountMustBePositive));
    expect(
      vm.errorMessageFor(ta),
      isNot(equals(vm.errorMessageFor(en))),
      reason: 'Tamil and English must not produce the same text here',
    );
    // The English-only getter (documented as for VM unit tests) must
    // still match errorMessageFor(en), so existing tests asserting on
    // it keep working unchanged.
    expect(vm.errorMessage, equals(vm.errorMessageFor(en)));
  });

  test('clearFailure only notifies when a failure was actually set', () {
    final vm = _FakeViewModel();
    var notifications = 0;
    vm.addListener(() => notifications++);

    vm.clearFailure();
    expect(notifications, equals(0));

    vm.fail();
    expect(notifications, equals(1));

    vm.clearFailure();
    expect(notifications, equals(2));
    expect(vm.failure, isNull);
  });
}
