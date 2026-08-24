import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_picker_platform_interface/file_picker_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_en.dart';
import 'package:smara_accounting/main.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import 'support/acceptance_harness.dart';

/// Same fake-singleton substitution as csv_import_test.dart/
/// ofx_import_test.dart, extended with `saveFile` - Settings' Save Backup
/// button goes through `FilePicker.saveFile`, which delegates to the same
/// `FilePickerPlatform.instance` singleton as `pickFile`. Recording lets a
/// later `pickFile` call hand back exactly what was just "saved", without
/// ever touching a real OS dialog.
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

class _RecordingFilePickerPlatform extends FilePickerPlatform {
  Uint8List? lastSavedBytes;

  /// Handed back by [pickFile] on the next call - set explicitly by the
  /// test rather than always echoing [lastSavedBytes], so a "restore a
  /// different (foreign) backup" scenario can hand back different bytes.
  PlatformFile? nextPickedFile;

  @override
  Future<Uri?> saveFile({
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
    String? dialogTitle,
    String? initialDirectory,
    Function(FilePickerStatus)? onFileSaving,
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) async {
    lastSavedBytes = bytes;
    return Uri.file(fileName);
  }

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
  }) async => nextPickedFile;
}

const _backupPassphrase = 'correct-horse-battery-staple';

/// Creates a new EUR account group through the real "Create group" dialog
/// (the same proven flow currency_transfers_test.dart uses) - enough to
/// make local state diverge from a backup taken before it, so restoring
/// can be proven to actually replace the ledger rather than merely not
/// corrupt it.
Future<void> _createDivergentGroupThroughGui(
  WidgetTester tester,
  AppLocalizationsEn l10n,
) async {
  await tapReliably(
    tester,
    () => find.text(l10n.navAccounts),
    () => find.byTooltip(l10n.createGroup).evaluate().isNotEmpty,
  );
  await tapReliably(
    tester,
    () => find.byTooltip(l10n.createGroup),
    () => find.byType(AlertDialog).evaluate().isNotEmpty,
  );
  await enterTextReliably(
    tester,
    () => find.byType(TextField).first,
    'Euro Group',
    () {
      final field = find.byType(TextField).evaluate().first.widget as TextField;
      return field.controller?.text == 'Euro Group';
    },
  );
  await tapReliably(tester, () => find.text('EUR'), () {
    final chip =
        find.widgetWithText(ChoiceChip, 'EUR').evaluate().single.widget
            as ChoiceChip;
    return chip.selected;
  });
  await tapReliably(
    tester,
    () => find.widgetWithText(ElevatedButton, l10n.actionCreate),
    () => find.byType(AlertDialog).evaluate().isEmpty,
    innerTries: 150,
  );
}

/// Exports a passphrase-protected backup through the real Settings GUI,
/// returning the captured bytes `_RecordingFilePickerPlatform.saveFile`
/// recorded.
Future<Uint8List> _exportBackupThroughGui(
  WidgetTester tester,
  AppLocalizationsEn l10n,
  _RecordingFilePickerPlatform fakePicker, {
  required String passphrase,
}) async {
  await tapReliably(
    tester,
    () => find.byTooltip(l10n.settingsTitle),
    () => find.text(l10n.settingsBackup).evaluate().isNotEmpty,
  );
  // Settings has many sections above Backup (language, FX/market-price
  // toggles, research tool) - below the live window's fold (design.md
  // Risks). Dragging from either the ListView's own render box or a
  // specific text widget's computed center was observed to derive wildly
  // wrong offsets on this screen (massive overshoot, or a center outside
  // the live window's own 800x600 bounds) on different runs - dragging
  // from a fixed point known to sit over the list's body sidesteps
  // whatever is miscomputing those.
  await tester.dragFrom(const Offset(400, 300), const Offset(0, -250));
  await tester.pump(const Duration(milliseconds: 300));
  await tapReliably(
    tester,
    () => find.widgetWithText(ElevatedButton, l10n.actionSaveBackup),
    () => find.text(l10n.keystorePassphrase).evaluate().isNotEmpty,
  );
  await enterTextReliably(
    tester,
    () => find.byType(TextField).first,
    passphrase,
    () {
      final field = find.byType(TextField).evaluate().first.widget as TextField;
      return field.controller?.text == passphrase;
    },
  );
  await tapReliably(
    tester,
    () => find.widgetWithText(ElevatedButton, l10n.actionSave),
    () => fakePicker.lastSavedBytes != null,
  );
  final bytes = fakePicker.lastSavedBytes;
  if (bytes == null) fail('Save Backup never captured any bytes');
  await tapReliably(
    tester,
    () => find.byTooltip('Back'),
    () => find.text(l10n.settingsTitle).evaluate().isEmpty,
  );
  return bytes;
}

/// Real-build acceptance coverage for `ledger-backup`: exporting an
/// encrypted backup through the real Settings GUI and restoring from it
/// (round trip, and a foreign-identity rejection), faking the platform
/// file picker the same way csv_import_test.dart/ofx_import_test.dart do
/// for the native save/open dialogs.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final l10n = AppLocalizationsEn();
  late final FilePickerPlatform defaultFilePickerPlatform;

  setUpAll(() async {
    defaultFilePickerPlatform = FilePickerPlatform.instance;
    await resetToFreshDevice();
  });

  testWidgets(
    'restoring a backup replaces the local ledger with what it contained',
    (tester) async {
      addTearDown(() {
        FilePickerPlatform.instance = defaultFilePickerPlatform;
        return resetToFreshDevice(tester);
      });
      final fakePicker = _RecordingFilePickerPlatform();
      FilePickerPlatform.instance = fakePicker;

      await completeOnboardingWithGuidedEntry(
        tester,
        amountText: '250',
        categoryName: 'Salary',
      );

      final backupBytes = await _exportBackupThroughGui(
        tester,
        l10n,
        fakePicker,
        passphrase: _backupPassphrase,
      );

      // Diverge local state: a new account group the backup above
      // doesn't have.
      await _createDivergentGroupThroughGui(tester, l10n);
      // The Accounts list is a lazily-built ListView and a newly-appended
      // group sorts to the end, below the live window's fold (design.md
      // Risks) - scroll before looking for it.
      await tester.drag(find.byType(ListView).first, const Offset(0, -2000));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Euro Group'), findsOneWidget);

      // Restore the earlier backup - it should replace this diverged state.
      fakePicker.nextPickedFile = _FakePlatformFile(
        name: 'smara-backup.smarabackup',
        bytes: backupBytes,
      );
      await tapReliably(
        tester,
        () => find.byIcon(TablerIcons.home).first,
        () => find.byTooltip(l10n.settingsTitle).evaluate().isNotEmpty,
      );
      await tapReliably(
        tester,
        () => find.byTooltip(l10n.settingsTitle),
        () => find.text(l10n.settingsBackup).evaluate().isNotEmpty,
      );
      await tester.dragFrom(const Offset(400, 300), const Offset(0, -250));
      await tester.pump(const Duration(milliseconds: 300));
      await tapReliably(
        tester,
        () => find.widgetWithText(OutlinedButton, l10n.actionRestoreBackup),
        () => find.text(l10n.actionChooseFile).evaluate().isNotEmpty,
      );
      // The native dialog is faked - resolves synchronously to the backup
      // bytes captured above.
      await tapReliably(
        tester,
        () => find.text(l10n.actionChooseFile),
        () => find.text('smara-backup.smarabackup').evaluate().isNotEmpty,
      );
      await enterTextReliably(
        tester,
        () => find.byType(TextField).last,
        _backupPassphrase,
        () {
          final field =
              find.byType(TextField).evaluate().last.widget as TextField;
          return field.controller?.text == _backupPassphrase;
        },
      );
      await tapReliably(
        tester,
        () => find.widgetWithText(ElevatedButton, l10n.actionRestore),
        () => find.text(l10n.replaceBooksTitle).evaluate().isNotEmpty,
      );
      // confirmDestructiveAction's confirm button is an OutlinedButton
      // (destructiveButtonStyle), not an ElevatedButton.
      await tapReliably(
        tester,
        () => find.widgetWithText(OutlinedButton, l10n.actionReplace),
        () => find.text(l10n.backupRestored).evaluate().isNotEmpty,
        innerTries: 150,
      );

      // restoreBackup() closes the database connection and expects the
      // real app to be relaunched (SettingsViewModel's own doc comment) -
      // the success dialog's own button does that via exit(0)/
      // SystemNavigator.pop(), neither safe to actually invoke from inside
      // this test process, so this simulates the relaunch directly instead.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await tester.pumpWidget(const SmaraAccountingApp());
      await tester.pump();
      await pumpUntilFound(
        tester,
        find.text(l10n.homeWhatYouHaveMinusWhatYouOwe),
      );

      // Exact match: "+250.00" (the entry row) vs. "250.00" (the running
      // balance subtitle next to it) are two separate Text widgets that
      // would both match a textContaining("250.00") search.
      await tester.tap(find.byIcon(TablerIcons.receipt).first);
      await pumpUntilFound(tester, find.text('+250.00'));
      expect(
        find.text('+250.00'),
        findsOneWidget,
        reason: 'the backed-up entry should be back',
      );

      await tester.tap(find.text(l10n.navAccounts));
      await pumpUntilFound(tester, find.byTooltip(l10n.createGroup));
      await tester.drag(find.byType(ListView).first, const Offset(0, -2000));
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        find.text('Euro Group'),
        findsNothing,
        reason: 'restore should have replaced, not merged with, local data',
      );

      await tester.pump(const Duration(seconds: 2));
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );

  testWidgets(
    'restoring a backup from a different signing identity is rejected',
    (tester) async {
      addTearDown(() {
        FilePickerPlatform.instance = defaultFilePickerPlatform;
        return resetToFreshDevice(tester);
      });
      final fakePicker = _RecordingFilePickerPlatform();
      FilePickerPlatform.instance = fakePicker;

      // Device A: onboard, record an entry, export its backup.
      await completeOnboardingWithGuidedEntry(
        tester,
        amountText: '250',
        categoryName: 'Salary',
      );
      final foreignBackupBytes = await _exportBackupThroughGui(
        tester,
        l10n,
        fakePicker,
        passphrase: _backupPassphrase,
      );

      // Simulate a full reset onto a different device, then onboard fresh
      // there - a genuinely different signing identity, not just a
      // cleared keychain (identity_restore_test.dart's scenario).
      await resetToFreshDevice(tester);
      await tester.pumpWidget(const SmaraAccountingApp());
      await tester.pump();
      await completeOnboardingWithGuidedEntry(
        tester,
        amountText: '800',
        categoryName: 'Salary',
      );

      // Attempt to restore device A's backup onto this device (B).
      fakePicker.nextPickedFile = _FakePlatformFile(
        name: 'foreign-backup.smarabackup',
        bytes: foreignBackupBytes,
      );
      await tapReliably(
        tester,
        () => find.byTooltip(l10n.settingsTitle),
        () => find.text(l10n.settingsBackup).evaluate().isNotEmpty,
      );
      await tester.dragFrom(const Offset(400, 300), const Offset(0, -250));
      await tester.pump(const Duration(milliseconds: 300));
      await tapReliably(
        tester,
        () => find.widgetWithText(OutlinedButton, l10n.actionRestoreBackup),
        () => find.text(l10n.actionChooseFile).evaluate().isNotEmpty,
      );
      await tapReliably(
        tester,
        () => find.text(l10n.actionChooseFile),
        () => find.text('foreign-backup.smarabackup').evaluate().isNotEmpty,
      );
      await enterTextReliably(
        tester,
        () => find.byType(TextField).last,
        _backupPassphrase,
        () {
          final field =
              find.byType(TextField).evaluate().last.widget as TextField;
          return field.controller?.text == _backupPassphrase;
        },
      );
      await tapReliably(
        tester,
        () => find.widgetWithText(ElevatedButton, l10n.actionRestore),
        () => find.text(l10n.replaceBooksTitle).evaluate().isNotEmpty,
      );
      await tapReliably(
        tester,
        () => find.widgetWithText(OutlinedButton, l10n.actionReplace),
        () => find.text(l10n.errorForeignBackupIdentity).evaluate().isNotEmpty,
        innerTries: 150,
      );
      expect(
        find.text(l10n.backupRestored),
        findsNothing,
        reason: 'a foreign identity must not be treated as a success',
      );

      // Own data (device B's identity and entry) must be untouched. Not
      // an explicit Cancel tap on the restore dialog first: the rejected
      // restore's error message was observed to have already unwound the
      // dialog itself by this point on at least one run, so this just
      // gets back to Home/Register regardless of whichever screen that
      // left this on.
      if (find.text(l10n.settingsTitle).evaluate().isNotEmpty) {
        await tapReliably(
          tester,
          () => find.byTooltip('Back'),
          () => find.text(l10n.settingsTitle).evaluate().isEmpty,
        );
      }
      await tester.tap(find.byIcon(TablerIcons.receipt).first);
      await pumpUntilFound(tester, find.text('+800.00'));
      expect(find.text('+800.00'), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );
}
