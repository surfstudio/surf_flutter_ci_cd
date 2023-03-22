import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:process_run/shell.dart';
import 'package:surf_flutter_ci_cd/src/util/package_path_converter.dart';
import 'package:surf_flutter_ci_cd/src/util/printer.dart';
import 'package:path/path.dart' as path;

Future<void> deployAndroidToFirebase({
  required String appId,
  required String groups,
  String? token,
}) async {
  // Путь хранения собранного APK файла.
  final source =
      Directory('${Directory.current.path}/build/app/outputs/flutter-apk/');
  // Путь до папки lib/ пакета внутри основного проекта.
  final rootPath = await PackagePathResolver.packagePath();
  // Путь в котором будет хранится скопированные данные из [source]
  final destination = Directory('${rootPath}build/app/outputs/flutter-apk/');

  await _copyDirectory(source, destination);

  await for (final file in destination.list(recursive: true)) {
    Printer.printSuccess('File path ${file.path}');
  }

  final makefilePath = await PackagePathResolver.resolve(
    path: 'package:surf_flutter_ci_cd/lib/src/android/',
  );

  // Создание переменных окружения.
  final environment = ShellEnvironment(environment: {
    'APP_ID': appId,
    'GROUPS': groups,
    // По умолчанию токен добавляется в окружение на CICD.
    if (token != null) 'FIREBASE_TOKEN': token,
  });

  final shell = _createShellWithEnvironment(environment);

  //TODO(): Возможно версию ruby тоже следует вынести.
  await shell.run('rvm use 3.0.0');
  await shell.run('make -C $makefilePath init');
  await shell.run('make -C $makefilePath dev');
}

Future<void> deployIosToTestFlight({
  required String keyId,
  required String issuerId,
}) async {
  // Путь до папки lib/ пакета внутри основного проекта.
  final rootPath = await PackagePathResolver.packagePath();

  // Путь хранения собранного IPA файла.
  final ipaSource = Directory('${Directory.current.path}/build/ios/ipa/');

  // Путь в котором будет хранится скопированные данные из [source]
  final ipaDestination = Directory('${rootPath}build/ios/ipa/');

  // Копирование ipa файла.
  final outputIpaFile = await _copyFilesWithExtension(
      source: ipaSource, destination: ipaDestination, extension: '.ipa');

  final ipaPath =
      '../../build/ios/ipa/${path.basename(outputIpaFile.first.path)}';

  // Путь хранения ключа p8.
  final keySource = Directory('${Directory.current.path}/ios/certs/');

  // Путь в котором будет хранится скопированный ключ из [keySource].
  final keyDestination = Directory('${rootPath}ios/certs/');

  final outputP8File = await _copyFilesWithExtension(
      source: keySource, destination: keyDestination, extension: '.p8');

  final p8Path = '../../ios/certs/${path.basename(outputP8File.first.path)}';

  // Создание переменных окружения.
  final environment = ShellEnvironment(
    environment: {
      'KEY_ID': keyId,
      'ISSUER_ID': issuerId,
      'IPA_PATH': ipaPath,
      'P8_PATH': p8Path,
    },
  );
  final shell = _createShellWithEnvironment(environment);

  final makefilePath = await PackagePathResolver.resolve(
    path: 'package:surf_flutter_ci_cd/lib/src/ios/',
  );

  await shell.run('rvm use 3.0.0');
  await shell.run('make -C $makefilePath init');
  await shell.run('make -C $makefilePath beta');
}

/// Создание Shell.
Shell _createShellWithEnvironment(ShellEnvironment environment) {
  final stdoutController = StreamController<List<int>>();
  final stderrController = StreamController<List<int>>();
  final shell = Shell(
    stdout: stdoutController,
    stderr: stderrController,
    environment: environment,
  );

  stdoutController.stream.transform(utf8.decoder).listen(stdout.write);
  stderrController.stream.transform(utf8.decoder).listen(stderr.write);

  final envValues = StringBuffer();

  environment.forEach((key, value) {
    envValues.writeln();
    envValues.write('KEY: $key, VALUE: $value');
  });

  Printer.printSuccess('Run shell with environment: $envValues');

  return shell;
}

/// Указывать расширение [extension] в формате '.apk', '.ipa'.
/// Возвращает копированный файл.
Future<List<File>> _copyFilesWithExtension({
  required Directory source,
  required Directory destination,
  required String extension,
}) async {
  Printer.printNormal('''Copy files with extension = $extension from
  ${source.path}
  to
  ${destination.path}''');

  if (!(await destination.exists())) {
    await destination.create(recursive: true);
  }

  final outputFiles = <File>[];

  await for (final entity in source.list()) {
    final ext = path.extension(entity.path);

    if (ext != extension) continue;
    final sourceFile = File(entity.path);
    final destinationFile =
        File('${destination.path}/${sourceFile.path.split('/').last}');
    final outputFile = await sourceFile.copy(destinationFile.path);
    outputFiles.add(outputFile);
  }

  final destinationContent = StringBuffer()..write('Files after copy:');

  await for (final file in destination.list(recursive: true)) {
    destinationContent.writeln();
    destinationContent.write(file.path);
  }

  /// Если итоговый файл не создался, то выводим ошибку и останавливаем программу.
  if (outputFiles.isEmpty) {
    Printer.printError(
        'No such file with extension $extension in $source or can not copy file.');
    exit(1);
  }

  return outputFiles;
}

/// Удалить после проверки работы копирования по расширению!
Future<void> _copyDirectory(Directory source, Directory destination) async {
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
      _copyDirectory(entity, subDirectory);
    }
  });
}
