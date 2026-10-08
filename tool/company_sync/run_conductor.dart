#!/usr/bin/env dart

// Starts the company-sync conductor and prints its port.
// Usage: dart run tool/company_sync/run_conductor.dart <reportDir> [--dry|--household|--pair|--employees N]

import 'dart:io';

import 'conductor.dart';
import 'scenario.dart';

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln(
      'Usage: dart run tool/company_sync/run_conductor.dart <reportDir> '
      '[--dry|--household|--pair|--employees N] [--bind-lan]',
    );
    exit(64);
  }
  final reportDir = Directory(args.first);
  var dry = false;
  var household = false;
  var pair = false;
  var employees = 2;
  var bindLan = false;
  for (var i = 1; i < args.length; i++) {
    if (args[i] == '--dry') dry = true;
    if (args[i] == '--household') household = true;
    if (args[i] == '--pair') pair = true;
    if (args[i] == '--bind-lan') bindLan = true;
    if (args[i] == '--employees' && i + 1 < args.length) {
      employees = int.parse(args[++i]);
    }
  }
  final steps = pair
      ? pairScenario()
      : household
      ? householdScenario()
      : dry
      ? dryRunScenario()
      : acmeTravelScenario(employees: employees);
  final conductor = CompanySyncConductor(
    steps: steps,
    reportDirectory: reportDir,
  );
  await conductor.start(address: bindLan ? InternetAddress.anyIPv4 : null);
  stdout.writeln('CONDUCTOR_PORT=${conductor.port}');
  // Stay alive until SIGINT / stdin closes.
  await ProcessSignal.sigint.watch().first;
  await conductor.stop();
}
