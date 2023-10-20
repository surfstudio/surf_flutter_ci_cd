import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:process_run/shell.dart';
import 'package:surf_flutter_ci_cd/src/enums/enums.dart';
import 'package:surf_flutter_ci_cd/src/util/printer.dart';

/// Процесс сборки Android-артефакта.
Future<void> buildAndroidOutput({
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

    Printer.printNormal('Activate fvm');
    await shell.run('dart pub global activate fvm');

    Printer.printNormal('Flutter clean');
    await shell.run('fvm flutter clean');

    Printer.printNormal('Flutter pub get');
    await shell.run('fvm flutter pub get');

    Printer.printNormal('Build start Android start with flags:');
    await shell
        .run('fvm flutter build ${format.format} -t $entryPointPath --flavor $flavor $flags');
  } on Object catch (e) {
    Printer.printError(e.toString());
    exit(1);
  }
}

/// Процесс сборки iOS артефакта.
Future<void> buildIosOutput({
  required String flavor,
  required String buildType,
  required String entryPointPath,
  required String flags,
}) async {
  exitCode = 0;

  Printer.printWarning(
      'Build type: $buildType, Format: ipa, Flavor: $flavor, Target: $entryPointPath, flags: $flags');

  try {
    final stdoutController = StreamController<List<int>>();
    final stderrController = StreamController<List<int>>();

    final shell = Shell(stdout: stdoutController, stderr: stderrController);

    stdoutController.stream.transform(utf8.decoder).listen(stdout.write);
    stderrController.stream.transform(utf8.decoder).listen(stderr.write);

    Printer.printNormal('Activate fvm');
    await shell.run('dart pub global activate fvm');

    Printer.printNormal('Flutter clean');
    await shell.run('fvm flutter clean');

    Printer.printNormal('Flutter pub get');
    await shell.run('fvm flutter pub get');

    Printer.printNormal('Build start Android start with flags:');
    await shell.run('fvm flutter build ipa -t $entryPointPath --flavor $flavor $flags');
  } on Object catch (e) {
    Printer.printError(e.toString());
    exit(1);
  }
}
