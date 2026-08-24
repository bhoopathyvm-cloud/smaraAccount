import 'package:mockito/annotations.dart';
import 'package:smara_accounting/data/exchange_rate_service.dart';
import 'package:smara_accounting/data/repositories/account_repository.dart';
import 'package:smara_accounting/data/repositories/ledger_repository.dart';
import 'package:smara_accounting/data/repositories/settings_repository.dart';
import 'package:smara_accounting/data/repositories/statement_import_repository.dart';
import 'package:smara_accounting/domain/lock/app_lock_service.dart';
import 'package:smara_accounting/domain/lock/biometric_authenticator.dart';
import 'package:smara_accounting/ui/core/app_lock_controller.dart';

@GenerateNiceMocks([
  MockSpec<LedgerRepository>(),
  MockSpec<AccountRepository>(),
  MockSpec<ExchangeRateService>(),
  MockSpec<SettingsRepository>(),
  MockSpec<StatementImportRepository>(),
  MockSpec<AppLockService>(),
  MockSpec<BiometricAuthenticator>(),
  MockSpec<AppLockController>(),
])
void main() {}
