import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:process_run/shell.dart';

Future<void> deployAndroidToFirebase({
  required String appId,
  required String groups,
}) async {
  final environment = <String, String>{
    'APP_ID': appId,
    'GROUPS': groups,
  };

  final stdoutController = StreamController<List<int>>();
  final stderrController = StreamController<List<int>>();

  final shell = Shell(
    stdout: stdoutController,
    stderr: stderrController,
    environment: environment,
  );

  stdoutController.stream.transform(utf8.decoder).listen(stdout.write);
  stderrController.stream.transform(utf8.decoder).listen(stderr.write);

  await shell.run('echo \$APP_ID');
  await shell.run('echo \$GROUPS');
  await shell.run('''
echo \$APP_ID
echo \$GROUPS''');

  final script = <String>[
    'echo \$APP_ID',
    'echo \$GROUPS',
    'ls',
    'make -C android_deploy/ init',
    'make -C android_deploy/ beta',
  ];

  await shell.run(script.join(' && '));
}
