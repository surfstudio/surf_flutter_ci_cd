import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:process_run/shell.dart';
import 'package:surf_flutter_ci_cd/src/util/deploy_helper.dart';
import 'package:surf_flutter_ci_cd/src/util/package_path_converter.dart';
import 'package:surf_flutter_ci_cd/src/util/printer.dart';
//

// void main(List<String> args) {
//   deployAndroidToFirebase(appId: '1234567', groups: 'SURF');
// }

const _plarformFolderName = 'android';

const _googleCredsEnvName = 'GOOGLE_APPLICATION_CREDENTIALS';
const _apkPathEnvName = 'APK_PATH';
const _testersEnvName = 'TESTERS';
const _firebaseAppIdEnvName = 'FIREBASE_APP_ID';
const _firebaseReleaseNotesEnvName = 'FIREBASE_RELEASE_NOTES';

Future<void> deployAndroidToFirebase({
  required String appId,
  required String groups,
}) async {
  final stdoutController = StreamController<List<int>>();
  final stderrController = StreamController<List<int>>();

  final env = ShellEnvironment(environment: {
    'APP_ID': appId,
    'GROUPS': groups,
    'FIREBASE_TOKEN': '123TOKEN123',
  });

  final shell = Shell(
    stdout: stdoutController,
    stderr: stderrController,
    environment: env,
  );

  stdoutController.stream.transform(utf8.decoder).listen(stdout.write);
  stderrController.stream.transform(utf8.decoder).listen(stderr.write);

  final path = await PackagePathResolver.resolve(
    path: 'package:surf_flutter_ci_cd/lib/src/android/',
  );

  await shell.run('rvm use 3.0.0');
  await shell.run('make -C $path init');
  await shell.run('make -C $path beta');

  // await DeployHelper.deploy(
  //   DeployHelperSettings(
  //     // android
  //     platformDirectoryName: _plarformFolderName,
  //     //
  //     shellEnvironmentBuilder: (fastlaneDestinationDir, environmentMap) {
  //       final credentialsFile = fastlaneDestinationDir.listSync().firstWhere(
  //             (entity) => entity.path.contains('credentials.json'),
  //           );

  //       environmentMap[_googleCredsEnvName] = credentialsFile.absolute.path;
  //       environmentMap[_testersEnvName] = groups;
  //       environmentMap[_firebaseAppIdEnvName] = appId;
  //       environmentMap[_firebaseReleaseNotesEnvName] = 'Some release notes';
  //       final env = ShellEnvironment(environment: environmentMap);

  //       return env;
  //     },
  //     makefileArgs: ['beta'],
  //   ),
  // );
}


  // await shell.run('ls');

  // await shell.run('bundle exec fastlane beta app_id:$appId groups:$groups');

  // await shell.run('make -C android_deploy/ test APP_ID=$appId GROUPS=$groups');
//   await shell.run('''
// echo "${['APP_ID']}"
// echo "${['GROUPS']}"''');
// }
// final script = <String>[
//   'echo \$APP_ID',
//   'echo \$GROUPS',
//   'ls',
//   'make -C android_deploy/ init',
//   'make -C android_deploy/ beta',
// ];

// await shell.run(script.join(' && '));
