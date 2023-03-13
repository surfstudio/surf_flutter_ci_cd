import 'dart:io';

import 'package:process_run/shell.dart';
import 'package:surf_flutter_ci_cd/src/android/build.dart' as android;
import 'package:surf_flutter_ci_cd/src/android/util/android_script_helper.dart';
import 'package:surf_flutter_ci_cd/src/enums/enums.dart';
import 'package:surf_flutter_ci_cd/src/ios/build.dart' as ios;
import 'package:surf_flutter_ci_cd/src/ios/util/ios_script_helper.dart';
import 'package:surf_flutter_ci_cd/src/util/printer.dart';

Future<void> buildAndroidOutput({
  required String flavor,
  required String buildType,
  required String entryPointPath,
  required String projectName,
  PublishingFormat format = PublishingFormat.appbundle,
}) async {
  exitCode = 0;

  try {
    final shell = Shell();

    final res = await shell.run(AndroidScriptHelper.preBuildScript);

    for (final out in res) {
      stdout
        ..write(out.stderr)
        ..write(out.stdout);
    }

    await android.build(
      flavor: flavor,
      buildType: buildType,
      entryPointPath: entryPointPath,
      format: format,
      projectName: projectName,
    );
  } on Object catch (e) {
    Printer.printError(e.toString());
    exit(1);
  }
}

Future<void> buildIosOutput({
  required String flavor,
  required String buildType,
  required String entryPointPath,
}) async {
  exitCode = 0;

  try {
    final shell = Shell();

    final res = await shell.run(IosScriptHelper.preBuildScript);

    for (final out in res) {
      stdout
        ..write(out.stderr)
        ..write(out.stdout);
    }

    await ios.build(
      flavor: flavor,
      buildType: buildType,
      entryPointPath: entryPointPath,
    );
  } on Object catch (e) {
    Printer.printError(e.toString());
    exit(1);
  }
}
