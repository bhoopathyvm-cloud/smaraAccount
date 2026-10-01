import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smara_accounting/l10n/l10n.dart';
import 'package:smara_accounting/l10n/supported_locales.dart';
import 'package:smara_accounting/ui/core/date_formatter.dart';

void main() {
  for (final locale in supportedAppLocales) {
    testWidgets('mediumDateFormatFor formats a date in $locale', (
      tester,
    ) async {
      String? formatted;
      await tester.pumpWidget(
        MaterialApp(
          locale: locale,
          localizationsDelegates: appLocalizationsDelegatesWithMaterialFallback,
          supportedLocales: supportedAppLocales,
          home: Builder(
            builder: (context) {
              formatted = mediumDateFormatFor(
                context,
              ).format(DateTime(2026, 10, 1));
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(formatted, isNotEmpty);
    });
  }
}
