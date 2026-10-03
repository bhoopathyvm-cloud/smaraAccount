import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/domain/models/account.dart';
import 'package:smara_accounting/domain/models/summary.dart';
import 'package:smara_accounting/l10n/generated/app_localizations.dart';
import 'package:smara_accounting/ui/features/category_management/view_models/category_management_view_model.dart';
import 'package:smara_accounting/ui/features/category_management/views/category_management_view.dart';

import '../../../../mocks.mocks.dart';

void main() {
  late MockCategoryRepository repository;

  const groceries = Account(
    id: 'expense-1',
    name: 'Groceries',
    type: AccountType.expense,
    archived: false,
  );

  setUp(() {
    repository = MockCategoryRepository();
    when(
      repository.watchCategories(includeArchived: anyNamed('includeArchived')),
    ).thenAnswer((_) => Stream.value([groceries]));
    when(
      repository.watchCategoryTotals(
        start: anyNamed('start'),
        end: anyNamed('end'),
      ),
    ).thenAnswer((_) => Stream.value(const <CategoryTotal>[]));
    when(repository.defaultCategoryLocale()).thenAnswer((_) async => 'en');
    when(
      repository.displayNameFor(any, appLocale: anyNamed('appLocale')),
    ).thenAnswer((invocation) async {
      final locale = invocation.namedArguments[#appLocale] as String;
      if (locale.startsWith('de')) return 'Lebensmittel';
      return 'Groceries';
    });
    when(repository.suggestedMerges()).thenAnswer((_) async => const []);
    when(repository.mergeMap()).thenAnswer((_) async => const {});
  });

  Widget wrap(Widget child) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('de'),
      home: child,
    );
  }

  testWidgets('7.1 shows app-locale translation when available', (
    tester,
  ) async {
    final viewModel = CategoryManagementViewModel(
      categoryRepository: repository,
      appLocaleTag: 'de',
    );
    addTearDown(viewModel.dispose);

    await tester.pumpWidget(wrap(CategoryManagementView(viewModel: viewModel)));
    await tester.pumpAndSettle();

    expect(find.text('Lebensmittel'), findsOneWidget);
    expect(find.text('Groceries'), findsNothing);
    final l10n = lookupAppLocalizations(const Locale('de'));
    expect(find.text(l10n.mergeCategories), findsOneWidget);
  });
}
