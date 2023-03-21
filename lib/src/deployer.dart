import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:process_run/shell.dart';
import 'package:surf_flutter_ci_cd/src/util/package_path_converter.dart';
import 'package:surf_flutter_ci_cd/src/util/printer.dart';

Future<void> deployAndroidToFirebase({
  required String appId,
  required String groups,
  String? token,
}) async {
  final stdoutController = StreamController<List<int>>();
  final stderrController = StreamController<List<int>>();

  final env = ShellEnvironment(environment: {
    'APP_ID': appId,
    'GROUPS': groups,
    // По умолчанию токен добавляется в окружение на CICD.
    if (token != null) 'FIREBASE_TOKEN': token,
  });

  final shell = Shell(
    stdout: stdoutController,
    stderr: stderrController,
    environment: env,
  );

  stdoutController.stream.transform(utf8.decoder).listen(stdout.write);
  stderrController.stream.transform(utf8.decoder).listen(stderr.write);

  final envValues = StringBuffer();

  env.forEach((key, value) {
    envValues.write('key:$key, value:$value');
    envValues.writeln();
  });

  Printer.printSuccess('Execute shell with environment: $envValues');

  final source =
      Directory('${Directory.current.path}/build/app/outputs/flutter-apk/');
  final rootPath =
      await PackagePathResolver.resolve(path: 'package:surf_flutter_ci_cd/');
  final destination = Directory('${rootPath}build/app/outputs/flutter-apk/');

  await copyDirectory(source, destination);

  await for (final file in destination.list(recursive: true)) {
    Printer.printSuccess('File path ${file.path}');
  }

  final path = await PackagePathResolver.resolve(
    path: 'package:surf_flutter_ci_cd/lib/src/android/',
  );

  await shell.run('rvm use 3.0.0');
  await shell.run('make -C $path init');
  await shell.run('make -C $path dev');
}

Future<void> copyDirectory(Directory source, Directory destination) async {
  Printer.printNormal('''Copy all files from
  ${source.path}
  to
  ${destination.path}''');

  // Create the destination directory if it doesn't exist
  if (!(await destination.exists())) {
    await destination.create(recursive: true);
  }

  // Iterate through the source directory and its subdirectories
  source.listSync(recursive: true).forEach((entity) {
    if (entity is File) {
      // If the entity is a file, copy it to the destination directory
      final sourceFile = File(entity.path);
      final destinationFile =
          File('${destination.path}/${sourceFile.path.split('/').last}');
      sourceFile.copySync(destinationFile.path);
    } else if (entity is Directory) {
      // If the entity is a directory, create a corresponding subdirectory
      // in the destination directory and recurse into it
      final subDirectory =
          Directory('${destination.path}/${entity.path.split('/').last}');
      copyDirectory(entity, subDirectory);
    }
  });
}


//

// void main(List<String> args) {
//   deployAndroidToFirebase(appId: '1234567', groups: 'SURF');
// }

// const _plarformFolderName = 'android';

// const _googleCredsEnvName = 'GOOGLE_APPLICATION_CREDENTIALS';
// const _apkPathEnvName = 'APK_PATH';
// const _testersEnvName = 'TESTERS';
// const _firebaseAppIdEnvName = 'FIREBASE_APP_ID';
// const _firebaseReleaseNotesEnvName = 'FIREBASE_RELEASE_NOTES';

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
