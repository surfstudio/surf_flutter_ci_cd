// ignore_for_file: avoid_print

import 'dart:io';

import 'package:surf_flutter_ci_cd/src/util/printer.dart';

/// Script for build application.
/// Need parameter: build type -release or -qa.
/// See also usage.
///
/// Exit codes:
/// 0 - success
/// 1 - error

Future<void> build({
  required String flavor,
  required String buildType,
  required String entryPointPath,
}) async {
  await _buildIpa(
    flavor: flavor,
    buildType: buildType,
    entryPointPath: entryPointPath,
  );
}

Future<void> _buildIpa({
  required String buildType,
  required String entryPointPath,
  required String flavor,
}) async {
  Printer.printWarning('Build type: $buildType, Format: ipa, Flavor: $flavor');

  final result = await Process.run('fvm', [
    'flutter',
    'build',
    'ipa',
    '-t',
    entryPointPath,
    '--flavor',
    flavor,
    '--release',
  ]);
  stdout.write(result.stdout);
  stderr.write(result.stderr);
}
