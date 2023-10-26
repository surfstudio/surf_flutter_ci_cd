import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_deployer/flutter_deployer.dart';
import 'package:flutter_deployer/src/util/printer.dart';
import 'package:process_run/shell.dart';

/// Процесс сборки Android-артефакта.
Future<void> buildAndroidOutput({
  required String flutter,
  required String flavor,
  required String buildType,
  required String entryPointPath,
  required String flags,
  PublishingFormat format = PublishingFormat.apk,
}) async {
  exitCode = 0;
  Printer.printWarning(
    'Build type: $buildType, Format: $format, Flavor: $flavor, Target: $entryPointPath, flags: $flags',
  );
  try {
    final stdoutController = StreamController<List<int>>();
    final stderrController = StreamController<List<int>>();

    final shell = Shell(stdout: stdoutController, stderr: stderrController);

    stdoutController.stream.transform(utf8.decoder).listen(stdout.write);
    stderrController.stream.transform(utf8.decoder).listen(stderr.write);

    Printer.printNormal('Flutter clean');
    await shell.run('$flutter clean');

    Printer.printNormal('Flutter pub get');
    await shell.run('$flutter pub get');

    Printer.printNormal('Build start Android start with flags:');
    await shell.run('$flutter build ${format.format} -t $entryPointPath --flavor $flavor $flags');
  } on Object catch (e) {
    Printer.printError(e.toString());
    exit(1);
  }
}

/// Процесс сборки iOS артефакта.
Future<void> buildIosOutput({
  required String flutter,
  required String flavor,
  required String buildType,
  required String entryPointPath,
  required String flags,
}) async {
  exitCode = 0;

  Printer.printWarning('Build type: $buildType, Format: ipa, Flavor: $flavor, Target: $entryPointPath, flags: $flags');

  try {
    final stdoutController = StreamController<List<int>>();
    final stderrController = StreamController<List<int>>();

    final shell = Shell(stdout: stdoutController, stderr: stderrController);

    stdoutController.stream.transform(utf8.decoder).listen(stdout.write);
    stderrController.stream.transform(utf8.decoder).listen(stderr.write);

    Printer.printNormal('Flutter clean');
    await shell.run('$flutter clean');

    Printer.printNormal('Flutter pub get');
    await shell.run('$flutter pub get');

    Printer.printNormal('Build start Android start with flags:');
    await shell.run('$flutter build ipa -t $entryPointPath --flavor $flavor $flags');
  } on Object catch (e) {
    Printer.printError(e.toString());
    exit(1);
  }
}
