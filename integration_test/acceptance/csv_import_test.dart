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

/// A fake [PlatformFile]/[FilePickerPlatform] pair, structurally identical
/// to the `_RecordingUrlLauncherPlatform` fake used for research links
/// (investment-research-enablement acceptance-investment-research): the
/// native OS file-picker dialog has no automation surface, but
/// `FilePicker.pickFile()` always delegates to the swappable
/// `FilePickerPlatform.instance` singleton, so this substitutes a canned
/// answer for the dialog without touching lib/.
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

const _csvFixture =
    'Date,Description,Amount\n'
    '15/01/2026,Grocery Store,-45.67\n'
    '16/01/2026,Paycheck,1200.00\n';

/// The CSV mapping step's per-column dropdowns are `DropdownButtonFormField`
/// of int, not the String instantiation `dropdownWithLabel` (in the shared
/// harness) matches - a distinct generic instantiation fails an `is` check
/// against a different one, so this is a separate finder.
Finder _intDropdownWithLabel(String label) {
  return find.byWidgetPredicate((widget) {
    if (widget is! DropdownButtonFormField<int>) return false;
    return widget.decoration.labelText == label;
  });
}

/// Picks [category] from a single preview row's category dropdown
/// (identified by its unique [description]), then dismisses the
/// "save as rule?" dialog every category assignment triggers
/// (import-category-rules: "Save a Category Rule From a Group
/// Assignment") without saving one - declining leaves the row's category
/// applied to this import only, which is all this scenario needs.
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

/// Real-build acceptance coverage for csv-transaction-import: importing a
/// real CSV file through the platform file picker (faked via
/// [FilePickerPlatform.instance], design.md's approved substitution point)
/// and posting the mapped, categorized rows to the register.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final l10n = AppLocalizationsEn();
  late final FilePickerPlatform defaultFilePickerPlatform;

  setUpAll(() async {
    defaultFilePickerPlatform = FilePickerPlatform.instance;
    await resetToFreshDevice();
  });

  testWidgets(
    'importing a CSV file maps columns, categorizes rows, and posts them',
    (tester) async {
      addTearDown(() {
        FilePickerPlatform.instance = defaultFilePickerPlatform;
        return resetToFreshDevice(tester);
      });
      FilePickerPlatform.instance = _FakeFilePickerPlatform(
        _FakePlatformFile(
          name: 'statement.csv',
          bytes: Uint8List.fromList(_csvFixture.codeUnits),
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
        () => find.text(l10n.importCsvFile),
        () => find.text(l10n.actionChooseFile).evaluate().isNotEmpty,
      );
      // The native dialog is faked - this tap resolves synchronously to the
      // canned file above, no OS UI ever appears.
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
      // Selecting the account triggers an async currency lookup before the
      // mapping step renders (design.md Risks: real I/O isn't instant).
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text(l10n.dateColumn), findsOneWidget);

      await tapReliably(
        tester,
        () => _intDropdownWithLabel(l10n.dateColumn).hitTestable(),
        dropdownOverlayOpen,
      );
      await tester.pump(const Duration(milliseconds: 400));
      await tapReliably(
        tester,
        () => find.descendant(of: dropdownMenu(), matching: find.text('Date')),
        () => !dropdownOverlayOpen(),
        scrollIntoView: false,
      );

      await tapReliably(
        tester,
        () => find.widgetWithText(CheckboxListTile, 'Description'),
        () {
          final tile =
              find
                      .widgetWithText(CheckboxListTile, 'Description')
                      .evaluate()
                      .single
                      .widget
                  as CheckboxListTile;
          return tile.value == true;
        },
      );

      await tapReliably(
        tester,
        () => _intDropdownWithLabel(l10n.amountColumn).hitTestable(),
        dropdownOverlayOpen,
      );
      await tester.pump(const Duration(milliseconds: 400));
      await tapReliably(
        tester,
        () =>
            find.descendant(of: dropdownMenu(), matching: find.text('Amount')),
        () => !dropdownOverlayOpen(),
        scrollIntoView: false,
      );

      await tapReliably(
        tester,
        () => find.widgetWithText(ElevatedButton, l10n.actionContinue),
        () => find.text(l10n.confirmImport).evaluate().isNotEmpty,
        innerTries: 150,
      );

      await _categorizeRow(
        tester,
        l10n,
        description: 'Grocery Store',
        category: 'Other Expense',
      );
      await _categorizeRow(
        tester,
        l10n,
        description: 'Paycheck',
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

      // Navigate to Register - find.text(l10n.navRegister) is ambiguous
      // there (bottom-nav label plus Register's own AppBar title), so this
      // scopes the tap to the bottom nav's icon instead, mirroring
      // shellNavIcon's own pattern. Register's rows stream from the real
      // database asynchronously (design.md Risks), hence pumpUntilFound
      // rather than tapReliably's own limited-attempt retry.
      // Register's row subtitle combines date and description into one
      // Text ("2026-01-15 · Grocery Store"), not a standalone description
      // node - textContaining, not text, is the correct match here.
      await tester.tap(find.byIcon(TablerIcons.receipt).first);
      await pumpUntilFound(tester, find.textContaining('Grocery Store'));
      expect(find.textContaining('Grocery Store'), findsOneWidget);
      expect(find.textContaining('Paycheck'), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );
}
