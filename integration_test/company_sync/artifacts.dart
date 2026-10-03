import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Writes screenshot / visible-text / log under the instance artifact dir (task 7.5).
class CompanySyncArtifacts {
  CompanySyncArtifacts({
    required this.role,
    required this.root,
    IntegrationTestWidgetsFlutterBinding? binding,
  }) : _binding = binding;

  final String role;
  final Directory root;
  final IntegrationTestWidgetsFlutterBinding? _binding;

  Directory get roleDir => Directory('${root.path}/$role');

  Future<void> ensureReady() async {
    await roleDir.create(recursive: true);
  }

  Future<void> writeVisibleText(String stepId, String text) async {
    await ensureReady();
    final safe = stepId.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    await File('${roleDir.path}/$safe.visible.txt').writeAsString(text);
  }

  Future<void> writeLog(String stepId, String message) async {
    await ensureReady();
    final file = File('${roleDir.path}/instance.log');
    await file.writeAsString(
      '${DateTime.now().toUtc().toIso8601String()} [$stepId] $message\n',
      mode: FileMode.append,
    );
  }

  Future<void> takeScreenshot(String stepId) async {
    final binding = _binding;
    if (binding == null) return;
    await ensureReady();
    final safe = stepId.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    try {
      await binding.takeScreenshot('$role-$safe');
    } catch (e) {
      debugPrint('screenshot failed for $stepId: $e');
    }
  }
}
