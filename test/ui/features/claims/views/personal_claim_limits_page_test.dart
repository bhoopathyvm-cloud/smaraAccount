import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smara_accounting/l10n/l10n.dart';
import 'package:smara_accounting/ui/features/claims/views/personal_claim_limits_page.dart';

void main() {
  testWidgets('Owner sees person limits; denied viewer is refused', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const PersonalClaimLimitsPage(
          personName: 'Ravi',
          lines: ['Hotel 120 per night'],
        ),
      ),
    );
    expect(find.text('Hotel 120 per night'), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const PersonalClaimLimitsPage(
          personName: 'Ravi',
          lines: ['Hotel 120 per night'],
          viewerIsOwner: false,
        ),
      ),
    );
    expect(find.text('Hotel 120 per night'), findsNothing);
  });

  testWidgets('Claimant sees own personal limits and company limits', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const PersonalClaimLimitsPage(
          personName: 'Ravi',
          lines: ['Hotel 120 per night'],
          companyLines: ['Hotel 150 per night', 'Meals 40 per day'],
          viewerIsOwner: false,
          allowClaimantSelf: true,
        ),
      ),
    );
    expect(find.text('My claim limits'), findsOneWidget);
    expect(find.text('Hotel 120 per night'), findsOneWidget);
    expect(find.text('Hotel 150 per night'), findsOneWidget);
    expect(find.text('Meals 40 per day'), findsOneWidget);
    expect(find.textContaining("Mia"), findsNothing);
  });
}
