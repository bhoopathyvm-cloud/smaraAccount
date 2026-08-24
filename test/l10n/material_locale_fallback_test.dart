import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smara_accounting/l10n/l10n.dart';

void main() {
  test('Flutter-shipped locales are untouched (e.g. Tamil)', () {
    expect(
      GlobalMaterialLocalizations.delegate.isSupported(const Locale('ta')),
      isTrue,
      reason: 'sanity check: Tamil needs no fallback in the first place',
    );
  });

  group('kMaterialLocaleFallback', () {
    test('sa/doi/mai/kok/brx map to hi', () {
      for (final tag in ['sa', 'doi', 'mai', 'kok', 'brx']) {
        expect(kMaterialLocaleFallback[tag], equals('hi'), reason: tag);
      }
    });

    test('ks/sd map to ur', () {
      for (final tag in ['ks', 'sd']) {
        expect(kMaterialLocaleFallback[tag], equals('ur'), reason: tag);
      }
    });

    test('mni/sat map to en (no honest sibling)', () {
      for (final tag in ['mni', 'sat']) {
        expect(kMaterialLocaleFallback[tag], equals('en'), reason: tag);
      }
    });
  });

  group('appLocalizationsDelegatesWithMaterialFallback', () {
    LocalizationsDelegate<MaterialLocalizations> materialDelegate() =>
        appLocalizationsDelegatesWithMaterialFallback
            .whereType<LocalizationsDelegate<MaterialLocalizations>>()
            .first;

    test('a locale Flutter does not ship now reports supported', () async {
      final delegate = materialDelegate();
      expect(delegate.isSupported(const Locale('sa')), isTrue);
    });

    test('loading an unshipped locale loads its sibling\'s data', () async {
      final delegate = materialDelegate();
      final sanskritMaterial = await delegate.load(const Locale('sa'));
      final hindiMaterial = await GlobalMaterialLocalizations.delegate.load(
        const Locale('hi'),
      );
      // Same underlying data set (e.g. the OK/Cancel button labels) as
      // Hindi, not English.
      expect(
        sanskritMaterial.okButtonLabel,
        equals(hindiMaterial.okButtonLabel),
      );
    });

    test('a locale Flutter does ship (Tamil) is not redirected', () async {
      final delegate = materialDelegate();
      final tamilMaterial = await delegate.load(const Locale('ta'));
      final directTamilMaterial = await GlobalMaterialLocalizations.delegate
          .load(const Locale('ta'));
      expect(
        tamilMaterial.okButtonLabel,
        equals(directTamilMaterial.okButtonLabel),
      );
    });
  });
}
