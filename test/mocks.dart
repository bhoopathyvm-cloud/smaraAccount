import 'package:mockito/annotations.dart';
import 'package:smara_accounting/data/exchange_rate_service.dart';
import 'package:smara_accounting/data/repositories/ledger_repository.dart';
import 'package:smara_accounting/data/repositories/settings_repository.dart';
import 'package:smara_accounting/data/repositories/statement_import_repository.dart';

@GenerateNiceMocks([
  MockSpec<LedgerRepository>(),
  MockSpec<ExchangeRateService>(),
  MockSpec<SettingsRepository>(),
  MockSpec<StatementImportRepository>(),
])
void main() {}
