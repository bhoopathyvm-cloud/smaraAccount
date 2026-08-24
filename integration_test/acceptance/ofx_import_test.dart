import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_picker_platform_interface/file_picker_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_en.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import 'support/acceptance_harness.dart';

/// Same fake-singleton substitution as csv_import_test.dart's
/// `_FakePlatformFile`/`_FakeFilePickerPlatform` - kept as a separate copy
/// rather than shared, since each file's fixture bytes differ and the
/// class is a handful of lines.
final class _FakePlatformFile extends PlatformFile {
  _FakePlatformFile({required this.name, required Uint8List bytes})
    : _bytes = bytes;

  @override
  final String name;
  final Uint8List _bytes;

  @override
  Uri get uri => Uri.file(name);

  @override
  XFile get xFile => XFile.fromData(_bytes, name: name);

  @override
  Future<int> length() async => _bytes.length;

  @override
  Future<Uint8List> readAsBytes() async => _bytes;

  @override
  Stream<Uint8List> readAsByteStream() => Stream.value(_bytes);
}

class _FakeFilePickerPlatform extends FilePickerPlatform {
  _FakeFilePickerPlatform(this._file);

  final PlatformFile? _file;

  @override
  Future<PlatformFile?> pickFile({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    int compressionQuality = 0,
    AndroidOptions androidOptions = const AndroidOptions(),
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) async => _file;
}

const _ofxFixture = '''
<?xml version="1.0" encoding="UTF-8"?>
<?OFX OFXHEADER="200" VERSION="211" SECURITY="NONE" OLDFILEUID="NONE" NEWFILEUID="NONE"?>
<OFX>
  <SIGNONMSGSRSV1>
    <SONRS>
      <STATUS><CODE>0</CODE><SEVERITY>INFO</SEVERITY></STATUS>
      <DTSERVER>20260101120000</DTSERVER>
      <LANGUAGE>ENG</LANGUAGE>
    </SONRS>
  </SIGNONMSGSRSV1>
  <BANKMSGSRSV1>
    <STMTTRNRS>
      <TRNUID>1</TRNUID>
      <STATUS><CODE>0</CODE><SEVERITY>INFO</SEVERITY></STATUS>
      <STMTRS>
        <CURDEF>USD</CURDEF>
        <BANKACCTFROM><BANKID>123456789</BANKID><ACCTID>987654321</ACCTID><ACCTTYPE>CHECKING</ACCTTYPE></BANKACCTFROM>
        <BANKTRANLIST>
          <DTSTART>20260101</DTSTART>
          <DTEND>20260131</DTEND>
          <STMTTRN>
            <TRNTYPE>DEBIT</TRNTYPE>
            <DTPOSTED>20260105</DTPOSTED>
            <TRNAMT>-42.17</TRNAMT>
            <FITID>2026010500001</FITID>
            <NAME>Coffee Shop</NAME>
          </STMTTRN>
          <STMTTRN>
            <TRNTYPE>CREDIT</TRNTYPE>
            <DTPOSTED>20260110</DTPOSTED>
            <TRNAMT>1500.00</TRNAMT>
            <FITID>2026011000002</FITID>
            <NAME>Payroll</NAME>
          </STMTTRN>
        </BANKTRANLIST>
        <LEDGERBAL><BALAMT>1457.83</BALAMT><DTASOF>20260131</DTASOF></LEDGERBAL>
      </STMTRS>
    </STMTTRNRS>
  </BANKMSGSRSV1>
</OFX>
''';

/// Picks [category] from a single preview row's category dropdown
/// (identified by its unique [description]), then dismisses the
/// "save as rule?" dialog every category assignment triggers
/// (import-category-rules: "Save a Category Rule From a Group
/// Assignment") without saving one.
Future<void> _categorizeRow(
  WidgetTester tester,
  AppLocalizationsEn l10n, {
  required String description,
  required String category,
}) async {
  final rowCard = find.ancestor(
    of: find.text(description),
    matching: find.byType(Card),
  );
  await tapReliably(
    tester,
    () => find
        .descendant(
          of: rowCard,
          matching: find.byType(DropdownButtonFormField<String>),
        )
        .hitTestable(),
    dropdownOverlayOpen,
  );
  await tester.pump(const Duration(milliseconds: 400));
  await tapReliably(
    tester,
    () => find.descendant(of: dropdownMenu(), matching: find.text(category)),
    () => !dropdownOverlayOpen(),
    scrollIntoView: false,
  );
  await tapReliably(
    tester,
    () => find.widgetWithText(TextButton, l10n.actionSkip),
    () => find.byType(AlertDialog).evaluate().isEmpty,
  );
}

/// Real-build acceptance coverage for ofx-transaction-import: importing a
/// real OFX file through the platform file picker (faked via
/// [FilePickerPlatform.instance], the same substitution as
/// csv_import_test.dart) and posting the parsed, categorized rows to the
/// register. Unlike CSV, OFX parses immediately on file load - there is no
/// column-mapping step.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final l10n = AppLocalizationsEn();
  late final FilePickerPlatform defaultFilePickerPlatform;

  setUpAll(() async {
    defaultFilePickerPlatform = FilePickerPlatform.instance;
    await resetToFreshDevice();
  });

  testWidgets('importing an OFX file categorizes rows and posts them', (
    tester,
  ) async {
    addTearDown(() {
      FilePickerPlatform.instance = defaultFilePickerPlatform;
      return resetToFreshDevice(tester);
    });
    FilePickerPlatform.instance = _FakeFilePickerPlatform(
      _FakePlatformFile(
        name: 'statement.ofx',
        bytes: Uint8List.fromList(_ofxFixture.codeUnits),
      ),
    );

    await completeOnboardingWithGuidedEntry(
      tester,
      amountText: '1000',
      categoryName: 'Salary',
    );

    await tapReliably(
      tester,
      () => find.text(l10n.navAccounts),
      () => find.byTooltip(l10n.importOfx).evaluate().isNotEmpty,
    );
    await tapReliably(
      tester,
      () => find.byTooltip(l10n.importOfx),
      () => find.text(l10n.whatKindOfStatement).evaluate().isNotEmpty,
    );
    await tapReliably(
      tester,
      () => find.text(l10n.importOfxQfxFile),
      () => find.text(l10n.actionChooseFile).evaluate().isNotEmpty,
    );
    // The native dialog is faked - this tap resolves synchronously to the
    // canned file above, no OS UI ever appears. OFX parses immediately on
    // load, landing straight on account selection.
    await tapReliably(
      tester,
      () => find.text(l10n.actionChooseFile),
      () => find.text(l10n.importIntoAccount).evaluate().isNotEmpty,
    );

    await selectDropdownOption(
      tester,
      fieldLabel: l10n.importIntoAccount,
      optionText: 'Cash & Bank',
    );
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Coffee Shop'), findsOneWidget);
    expect(find.text('Payroll'), findsOneWidget);

    await _categorizeRow(
      tester,
      l10n,
      description: 'Coffee Shop',
      category: 'Other Expense',
    );
    await _categorizeRow(
      tester,
      l10n,
      description: 'Payroll',
      category: 'Salary',
    );

    await tapReliably(
      tester,
      () => find.widgetWithText(ElevatedButton, l10n.confirmImport),
      () => find.text(l10n.actionDone).evaluate().isNotEmpty,
      innerTries: 150,
    );
    expect(find.text(l10n.postedFailedCount('2', '0')), findsOneWidget);

    await tapReliably(
      tester,
      () => find.widgetWithText(ElevatedButton, l10n.actionDone),
      () => find.text(l10n.actionDone).evaluate().isEmpty,
    );

    // Register's row subtitle combines date and description into one Text
    // ("2026-01-05 · Coffee Shop") - textContaining, not text.
    await tester.tap(find.byIcon(TablerIcons.receipt).first);
    await pumpUntilFound(tester, find.textContaining('Coffee Shop'));
    expect(find.textContaining('Coffee Shop'), findsOneWidget);
    expect(find.textContaining('Payroll'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
  }, timeout: const Timeout(Duration(minutes: 5)));
}
