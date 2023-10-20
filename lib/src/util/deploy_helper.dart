import 'dart:io';

import 'package:flutter_deployer/src/util/extensions/directory_x.dart';
import 'package:flutter_deployer/src/util/package_path_converter.dart';
import 'package:flutter_deployer/src/util/printer.dart';
import 'package:process_run/shell_run.dart';

typedef ShellEnvironmentBuilder = ShellEnvironment Function(
  Directory fastlaneDestinationDir,
  Map<String, String> environmentMap,
);

class DeployHelper {
  static Future<void> deploy(DeployHelperSettings settings) async {
    File? copiedGemfile;
    File? copiedMakefile;
    Directory? fastlaneDestinationDir;
    try {
      final platformDirectoryName = settings.platformDirectoryName;

      final gemfile = await _createFile(platformDirectoryName, 'Gemfile');
      final makefile = await _createFile(platformDirectoryName, 'Makefile');

      copiedGemfile = await gemfile.copy('$platformDirectoryName/Gemfile');
      copiedMakefile = await makefile.copy('$platformDirectoryName/Makefile');

      final fastlaneDirPath = await PackagePathResolver.resolve(
        path: 'package:flutter_deployer/lib/src/$platformDirectoryName/fastlane',
      );

      fastlaneDestinationDir = await _createFastlaneDirectory(
        fastlaneDirPath,
        platformDirectoryName,
      );

      final environmentMap = <String, String>{};
      final environment = settings.shellEnvironmentBuilder(
        fastlaneDestinationDir,
        environmentMap,
      );
      final shell = Shell(environment: environment);

      final res = await shell.run(
        'make -C ${settings.platformDirectoryName}/ ${settings.makefileArgs.join(' ')}',
      );

      if (res.outText.isNotEmpty) Printer.printNormal(res.outText);
      if (res.errText.isNotEmpty) Printer.printError(res.errText);
    } on Object catch (e) {
      Printer.printError(e.toString());
      exitCode = 1;
    } finally {
      copiedGemfile?.deleteSync();
      copiedMakefile?.deleteSync();
      fastlaneDestinationDir?.deleteSync(recursive: true);

      if (exitCode == 1) exit(1);
    }
  }

  static Future<File> _createFile(
    String platformDirectoryName,
    String fileName,
  ) async {
    final makeFilePath = await PackagePathResolver.resolve(
      path: 'package:flutter_deployer/lib/src/$platformDirectoryName/$fileName',
    );

    final makefile = File(makeFilePath);

    return makefile;
  }

  static Future<Directory> _createFastlaneDirectory(
    String sourcePath,
    String platformDirectoryName,
  ) async {
    final fastlaneSourceDir = Directory(sourcePath);
    final fastlaneDestinationDir = Directory('$platformDirectoryName/fastlane')..createSync();

    fastlaneSourceDir.copy(fastlaneDestinationDir);

    return fastlaneDestinationDir;
  }
}

// /// Source file paths should be passed as package paths
// ///
// /// For example: ```'package:flutter_deployer/lib/src/platform/Gemfile'```
class DeployHelperSettings {
  // final String sourceGemfilePath;
  // final String sourceMakefilePath;
  // final String destinationGemfilePath;
  // final String destinationMakefilePath;
  // final String sourceFastlaneDirPath;
  // final String desinationFastlaneDirPath;
  final String platformDirectoryName;
  final ShellEnvironmentBuilder shellEnvironmentBuilder;
  // final String shellRunScript;
  final List<String> makefileArgs;

  const DeployHelperSettings({
    // required this.desinationFastlaneDirPath,
    // required this.destinationGemfilePath,
    // required this.destinationMakefilePath,
    // required this.sourceFastlaneDirPath,
    // required this.sourceGemfilePath,
    // required this.sourceMakefilePath,
    required this.platformDirectoryName,
    required this.shellEnvironmentBuilder,
    required this.makefileArgs,
  });
}
