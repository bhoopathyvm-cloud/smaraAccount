import 'package:smara_accounting/l10n/generated/app_localizations.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_en.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_ta.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_te.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_ml.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_kn.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_hi.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_ur.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_pa.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_ne.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_sa.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_doi.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_ks.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_mai.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_mr.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_gu.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_kok.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_sd.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_bn.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_as.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_or.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_mni.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_brx.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_sat.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_de.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_fr.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_es.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_it.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_pt.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_hu.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_ro.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_ja.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_zh.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_ko.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_ar.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_ru.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_id.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_tr.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_vi.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_th.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_ms.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_uk.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_pl.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_nl.dart';
import 'package:smara_accounting/l10n/supported_locales.dart';

/// Compile-time-selected locale for an acceptance run. Set via
/// `--dart-define=ACCEPTANCE_LOCALE=<tag>` (see `tool/run_acceptance_tests.sh`'s
/// `-l/--locale` flag); defaults to English, reproducing this suite's
/// original, single-locale behavior exactly when omitted
/// (acceptance-tests-multi-locale design.md Decision 1).
const kAcceptanceLocaleTag = String.fromEnvironment(
  'ACCEPTANCE_LOCALE',
  defaultValue: 'en',
);

/// The generated [AppLocalizations] instance for [tag] - an exhaustive
/// switch over every tag in [kSupportedLocaleTags], so a locale newly added
/// to the curated fixture set (`locale_fixtures.dart`) needs no change here.
/// Replaces this suite's original hardcoded `AppLocalizationsEn()` at every
/// call site (acceptance-tests-multi-locale design.md Decision 2) - a run
/// with no `--dart-define` still resolves to exactly that instance via
/// [kAcceptanceLocaleTag]'s `'en'` default.
AppLocalizations l10nFor(String tag) {
  return switch (tag) {
    'en' => AppLocalizationsEn(),
    'ta' => AppLocalizationsTa(),
    'te' => AppLocalizationsTe(),
    'ml' => AppLocalizationsMl(),
    'kn' => AppLocalizationsKn(),
    'hi' => AppLocalizationsHi(),
    'ur' => AppLocalizationsUr(),
    'pa' => AppLocalizationsPa(),
    'ne' => AppLocalizationsNe(),
    'sa' => AppLocalizationsSa(),
    'doi' => AppLocalizationsDoi(),
    'ks' => AppLocalizationsKs(),
    'mai' => AppLocalizationsMai(),
    'mr' => AppLocalizationsMr(),
    'gu' => AppLocalizationsGu(),
    'kok' => AppLocalizationsKok(),
    'sd' => AppLocalizationsSd(),
    'bn' => AppLocalizationsBn(),
    'as' => AppLocalizationsAs(),
    'or' => AppLocalizationsOr(),
    'mni' => AppLocalizationsMni(),
    'brx' => AppLocalizationsBrx(),
    'sat' => AppLocalizationsSat(),
    'de' => AppLocalizationsDe(),
    'fr' => AppLocalizationsFr(),
    'es' => AppLocalizationsEs(),
    'it' => AppLocalizationsIt(),
    'pt' => AppLocalizationsPt(),
    'hu' => AppLocalizationsHu(),
    'ro' => AppLocalizationsRo(),
    'ja' => AppLocalizationsJa(),
    'zh' => AppLocalizationsZh(),
    'ko' => AppLocalizationsKo(),
    'ar' => AppLocalizationsAr(),
    'ru' => AppLocalizationsRu(),
    'id' => AppLocalizationsId(),
    'tr' => AppLocalizationsTr(),
    'vi' => AppLocalizationsVi(),
    'th' => AppLocalizationsTh(),
    'ms' => AppLocalizationsMs(),
    'uk' => AppLocalizationsUk(),
    'pl' => AppLocalizationsPl(),
    'nl' => AppLocalizationsNl(),
    _ => throw ArgumentError.value(
      tag,
      'tag',
      'Not a supported acceptance-suite locale tag (see kSupportedLocaleTags)',
    ),
  };
}
