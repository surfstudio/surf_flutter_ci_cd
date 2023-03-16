import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:process_run/shell.dart';
import 'package:surf_flutter_ci_cd/src/enums/enums.dart';
import 'package:surf_flutter_ci_cd/src/util/printer.dart';

Future<void> buildAndroidOutput({
  required String flavor,
  required String buildType,
  required String entryPointPath,
  required String projectName,
  required String flags,
  PublishingFormat format = PublishingFormat.appbundle,
}) async {
  exitCode = 0;
  Printer.printWarning(
    'Build type: $buildType, Format: $format, Flavor: $flavor, Target: $entryPointPath, flags: $flags',
  );
  try {
    final controller = StreamController<List<int>>();
    final controllerError = StreamController<List<int>>();

    final shell = Shell(stdout: controller, stderr: controllerError);

    controller.stream.transform(utf8.decoder).listen(print);
    controllerError.stream.transform(utf8.decoder).listen(print);

    Printer.printNormal('Activate fvm');

    await shell.run('dart pub global activate fvm');

    // final fvmProcess = await Process.start('dart', [
    //   'pub',
    //   'global',
    //   'activate',
    //   'fvm',
    // ]);

    // fvmProcess.stdout.transform(utf8.decoder).forEach(stdout.write);
    // fvmProcess.stderr.transform(utf8.decoder).forEach(stderr.write);

    Printer.printNormal('Flutter clean');

    await shell.run('fvm flutter clean');

    // final cleanProcess = await Process.start('fvm', [
    //   'flutter',
    //   'clean',
    // ]);

    // cleanProcess.stdout.transform(utf8.decoder).forEach(stdout.write);
    // cleanProcess.stderr.transform(utf8.decoder).forEach(stderr.write);

    Printer.printNormal('Flutter pub get');

    await shell.run('fvm flutter pub get');

    // final getProcess = await Process.start('fvm', [
    //   'flutter',
    //   'pub',
    //   'get',
    // ]);

    // getProcess.stdout.transform(utf8.decoder).forEach(stdout.write);
    // getProcess.stderr.transform(utf8.decoder).forEach(stderr.write);

    // results = await shell.run('fvm flutter clean');

    // for (var element in results) {
    //   stdout.write(element.stdout);
    //   stderr.write(element.stderr);
    // }

    // results = await shell.run('fvm flutter pub get');

    // for (var element in results) {
    //   stdout.write(element.stdout);
    //   stderr.write(element.stderr);
    // }
    Printer.printNormal('Build start Android start with flags:');

    await shell.run(
        'fvm flutter build ${format.format} -t $entryPointPath --flavor $flavor $flags');

    // final buildProcess = await Process.start(
    //   'fvm',
    //   [
    //     'flutter',
    //     'build',
    //     (),
    //     '-t',
    //     entryPointPath,
    //     '--flavor',
    //     flavor,
    //     flags,
    //   ],
    // );

    // buildProcess.stdout.transform(utf8.decoder).forEach(stdout.write);
    // buildProcess.stderr.transform(utf8.decoder).forEach(stderr.write);
  } on Object catch (e) {
    Printer.printError(e.toString());
    exit(1);
  }
}

Future<void> buildIosOutput({
  required String flavor,
  required String buildType,
  required String entryPointPath,
  required String flags,
}) async {
  exitCode = 0;

  try {
    Printer.printWarning(
        'Build type: $buildType, Format: ipa, Flavor: $flavor, Target: $entryPointPath, flags: $flags');

    final result = await Process.run('fvm', [
      'flutter',
      'build',
      'ipa',
      '-t',
      entryPointPath,
      '--flavor',
      flavor,
      flags,
    ]);
    stdout.write(result.stdout);
    stderr.write(result.stderr);
  } on Object catch (e) {
    Printer.printError(e.toString());
    exit(1);
  }
}
