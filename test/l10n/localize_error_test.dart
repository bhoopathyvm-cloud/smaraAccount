import 'package:flutter/widgets.dart';
import 'package:smara_accounting/domain/exceptions.dart';
import 'package:smara_accounting/l10n/l10n.dart';
import 'package:test/test.dart';

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = lookupAppLocalizations(const Locale('en'));
  });

  test('maps last-active-account code to the English ARB string', () {
    expect(
      localizeError(l10n, AppErrorCode.lastActiveAccount),
      equals('Cannot hide the last active financial account.'),
    );
  });

  test('maps a locked-until failure with the date placeholder', () {
    expect(
      localizeCaughtError(
        l10n,
        const LockedQuantityException(
          'debug',
          params: {'date': '2027-06-15'},
        ),
      ),
      equals('Cannot sell: some units are locked until 2027-06-15.'),
    );
  });

  test('maps a ViewModel validation failure through AppLocalizations', () {
    expect(
      localizeCaughtError(
        l10n,
        const AppFailure(AppErrorCode.validationAmountAccountCategoryRequired),
      ),
      equals('Amount, account, and category are required.'),
    );
  });

  test('localizeVmError uses English ARB even without a BuildContext', () {
    expect(
      localizeVmError(const AppFailure(AppErrorCode.validationWrongPin)),
      equals('Wrong PIN. Try again.'),
    );
  });
}
