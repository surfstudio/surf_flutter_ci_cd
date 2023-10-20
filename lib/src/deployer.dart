import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_deployer/src/util/package_path_converter.dart';
import 'package:flutter_deployer/src/util/printer.dart';
import 'package:path/path.dart' as path;
import 'package:process_run/shell.dart';

/// Запуск выгрузки Android артефакта в Firebase.
Future<void> deployAndroidToFirebase({
  required String appId,
  required String groups,
  required String flavor,
  String? token,
}) async {
  // Путь хранения собранного APK файла.
  final source = Directory('${Directory.current.path}/build/app/outputs/flutter-apk/');
  // Путь до папки lib/ пакета внутри основного проекта.
  final rootPath = await PackagePathResolver.packagePath();
  // Путь в котором будет хранится скопированные данные из [source]
  final destination = Directory('${rootPath}build/app/outputs/flutter-apk/');

  final outputApkFiles = await _copyFilesWithExtension(
    source: source,
    destination: destination,
    extension: '.apk',
    pattern: flavor,
  );

  final apkPath = '../../build/app/outputs/flutter-apk/${path.basename(outputApkFiles.first.path)}';

  await for (final file in destination.list(recursive: true)) {
    Printer.printSuccess('APK file path ${file.path}');
  }

  final makefilePath = await PackagePathResolver.resolve(
    path: 'package:flutter_deployer/lib/src/android/',
  );

  // Создание переменных окружения.
  final environment = ShellEnvironment(environment: {
    'APP_ID': appId,
    'GROUPS': groups,
    'APK_PATH': apkPath,
    // По умолчанию токен добавляется в окружение на CICD.
    if (token != null) 'FIREBASE_TOKEN': token,
  });

  final shell = _createShellWithEnvironment(environment);

  await shell.run('rvm use 3.0.0');
  await shell.run('make -C $makefilePath init');
  await shell.run('make -C $makefilePath firebase');
}

/// Выгрузка Android-артефакта в Google Play.
Future<void> deployAndroidToGPC({
  required String packageName,
  required String flavor,
}) async {
  // Путь хранения собранного AppBundle файла.
  final source = Directory('${Directory.current.path}/build/app/outputs/bundle/');
  // Путь до папки lib/ пакета внутри основного проекта.
  final rootPath = await PackagePathResolver.packagePath();
  // Путь в котором будет хранится скопированные данные из [source]
  final destination = Directory('${rootPath}build/app/outputs/bundle/');

  final outputAppFiles = await _copyFilesWithExtension(
    source: source,
    destination: destination,
    extension: '.aab',
    pattern: flavor,
  );

  final appPath = '../../build/app/outputs/bundle/${path.basename(outputAppFiles.first.path)}';

  await for (final file in destination.list(recursive: true)) {
    Printer.printSuccess('AAB file path ${file.path}');
  }

  // Путь хранения ключа json.
  final keySource = Directory('${Directory.current.path}/android/keystore/');

  // Путь в котором будет хранится скопированный ключ из [keySource].
  final keyDestination = Directory('${rootPath}android/keystore/');

  final outputJsonFile =
      await _copyFilesWithExtension(source: keySource, destination: keyDestination, extension: '.json');

  final jsonPath = '../../android/keystore/${path.basename(outputJsonFile.first.path)}';

  await for (final file in keyDestination.list(recursive: true)) {
    Printer.printSuccess('Json key file path ${file.path}');
  }

  // Создание переменных окружения.
  final environment = ShellEnvironment(
    environment: {
      'AAB_PATH': appPath,
      'PKG_NAME': packageName,
      'JSON_PATH': jsonPath,
    },
  );
  final shell = _createShellWithEnvironment(environment);

  final makefilePath = await PackagePathResolver.resolve(
    path: 'package:flutter_deployer/lib/src/android/',
  );

  await shell.run('rvm use 3.0.0');
  await shell.run('make -C $makefilePath init');
  await shell.run('make -C $makefilePath google_play');
}

/// Выгрузка iOS-артефакта в TestFlight.
Future<void> deployIosToTestFlight({
  String? keyId,
  String? issuerId,
}) async {
  // Путь до папки lib/ пакета внутри основного проекта.
  final rootPath = await PackagePathResolver.packagePath();

  // Путь хранения собранного IPA файла.
  final ipaPath = await _getIpaPath(rootPath);

  // Путь хранения ключа p8.
  final keySource = Directory('${Directory.current.path}/ios/certs/');

  // Путь в котором будет хранится скопированный ключ из [keySource].
  final keyDestination = Directory('${rootPath}ios/certs/');

  final outputP8File = await _copyFilesWithExtension(source: keySource, destination: keyDestination, extension: '.p8');

  final p8Path = '../../ios/certs/${path.basename(outputP8File.first.path)}';

  // Создание переменных окружения.
  final environment = ShellEnvironment(
    environment: {
      if (keyId != null) 'KEY_ID': keyId,
      if (issuerId != null) 'ISSUER_ID': issuerId,
      'IPA_PATH': ipaPath,
      'P8_PATH': p8Path,
    },
  );
  final shell = _createShellWithEnvironment(environment);

  final makefilePath = await PackagePathResolver.resolve(
    path: 'package:flutter_deployer/lib/src/ios/',
  );

  await shell.run('rvm use 3.0.0');
  await shell.run('make -C $makefilePath init');
  await shell.run('make -C $makefilePath testflight');
}

/// Выгрузка iOS-артефакта в Firebase.
Future<void> deployIosToFirebase({
  required String appId,
  required String groups,
  String? token,
}) async {
  // Путь до папки lib/ пакета внутри основного проекта.
  final rootPath = await PackagePathResolver.packagePath();

  // Путь хранения собранного IPA файла.
  final ipaPath = await _getIpaPath(rootPath);

  // Создание переменных окружения.
  final environment = ShellEnvironment(environment: {
    'APP_ID': appId,
    'GROUPS': groups,
    'IPA_PATH': ipaPath,
    // По умолчанию токен добавляется в окружение на CI/CD.
    if (token != null) 'FIREBASE_TOKEN': token,
  });

  final shell = _createShellWithEnvironment(environment);

  final makefilePath = await PackagePathResolver.resolve(
    path: 'package:flutter_deployer/lib/src/ios/',
  );

  await shell.run('rvm use 3.0.0');
  await shell.run('make -C $makefilePath init');
  await shell.run('make -C $makefilePath firebase');
}

/// Получение пути хранения IPA файла.
Future<String> _getIpaPath(String rootPath) async {
  // Путь хранения собранного IPA файла.
  final ipaSource = Directory('${Directory.current.path}/build/ios/ipa/');

  // Путь в котором будет хранится скопированные данные из [source]
  final ipaDestination = Directory('${rootPath}build/ios/ipa/');

  // Копирование ipa файла.
  final outputIpaFiles =
      await _copyFilesWithExtension(source: ipaSource, destination: ipaDestination, extension: '.ipa');

  final ipaPath = '../../build/ios/ipa/${path.basename(outputIpaFiles.first.path)}';
  return ipaPath;
}

/// Создание Shell оболочки с данными окружения [environment].
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

/// Копирует файлы из [source] в [destination].
///
/// - [extension] - расширение файлов в формате '.apk' или '.ipa'.
///
/// Возвращает список скопированных файлов.
Future<List<File>> _copyFilesWithExtension({
  required Directory source,
  required Directory destination,
  required String extension,
  String pattern = '',
}) async {
  Printer.printNormal('''Copy files with extension = $extension and name pattern ${pattern.toLowerCase()} from
  ${source.path}
  to
  ${destination.path}''');

  if (!(await destination.exists())) {
    await destination.create(recursive: true);
  }

  final outputFiles = <File>[];

  await for (final entity in source.list(recursive: true)) {
    final ext = path.extension(entity.path);
    if (ext != extension) continue;

    final name = path.basename(entity.path);
    if (!(name.contains(pattern.toLowerCase()))) continue;

    final sourceFile = File(entity.path);
    final destinationFile = File('${destination.path}/${sourceFile.path.split('/').last}');
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
    Printer.printError('No such file with extension $extension in $source or can not copy file.');
    exit(1);
  }

  return outputFiles;
}
