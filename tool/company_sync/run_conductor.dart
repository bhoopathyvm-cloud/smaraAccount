#!/usr/bin/env dart

// Starts the company-sync conductor and prints its port.
// Usage: dart run tool/company_sync/run_conductor.dart <reportDir> [--dry|--employees N]

import 'dart:io';

import 'conductor.dart';
import 'scenario.dart';

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln(
      'Usage: dart run tool/company_sync/run_conductor.dart <reportDir> [--dry|--employees N]',
    );
    exit(64);
  }
  final reportDir = Directory(args.first);
  var dry = false;
  var employees = 2;
  for (var i = 1; i < args.length; i++) {
    if (args[i] == '--dry') dry = true;
    if (args[i] == '--employees' && i + 1 < args.length) {
      employees = int.parse(args[++i]);
    }
  }
  final steps = dry
      ? dryRunScenario()
      : acmeTravelScenario(employees: employees);
  final conductor = CompanySyncConductor(
    steps: steps,
    reportDirectory: reportDir,
  );
  await conductor.start();
  stdout.writeln('CONDUCTOR_PORT=${conductor.port}');
  // Stay alive until SIGINT / stdin closes.
  await ProcessSignal.sigint.watch().first;
  await conductor.stop();
}
