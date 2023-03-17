import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:process_run/shell.dart';

Future<void> deployAndroidToFirebase({
  required String appId,
  required String groups,
}) async {
  final stdoutController = StreamController<List<int>>();
  final stderrController = StreamController<List<int>>();

  final shell = Shell(stdout: stdoutController, stderr: stderrController);

  stdoutController.stream.transform(utf8.decoder).listen(stdout.write);
  stderrController.stream.transform(utf8.decoder).listen(stderr.write);

  final script = <String>[
    // 'set +x',
    // 'source ~/.bashrc',
    // 'source ~/.rvm/scripts/rvm',
    //
    'export APP_ID="$appId"',
    'export GROUPS="$groups"',
    r'echo ${APP_ID}',
    r'echo ${GROUPS}',
    'ls',
    'make -C android_deploy/ init',
    'make -C android_deploy/ beta',
  ];

  await shell.run(script.join(' && '));
}
