import 'package:surf_flutter_ci_cd/src/util/printer.dart';
import 'package:surf_flutter_ci_cd/surf_flutter_ci_cd.dart';

import 'message_show.dart';

const _androidTarget = 'android';
const _iosTarget = 'ios';

/// Команда для вызова утилитой для выполнения основной работы.
abstract class BuildFunction {
  /// Метод вызова операции.
  Future<void> call({
    required String flutter,
    required String flavor,
    required String buildType,
    required String entryPointPath,
    required String flags,
    required String extension,
  });

  /// Создание функции в зависимости от значение платформы [target].
  factory BuildFunction.create(String target) {
    const targets = {
      _androidTarget: BuildAndroid(),
      _iosTarget: BuildIos(),
    };

    final buildFunction = targets[target];

    if (buildFunction == null) {
      Printer.printError('Invalid command.');
      throw ExitException();
    }
    return buildFunction;
  }
}

/// Команда для сборки Android-артефакта.
class BuildAndroid implements BuildFunction {
  const BuildAndroid();

  @override
  Future<void> call({
    required String flutter,
    required String flavor,
    required String buildType,
    required String entryPointPath,
    required String flags,
    required String extension,
  }) async {
    Printer.printWarning('Android build started');
    return buildAndroidOutput(
      flutter: flutter,
      flavor: flavor,
      buildType: buildType,
      entryPointPath: entryPointPath,
      format: PublishingFormat.fromString(extension) ?? PublishingFormat.apk,
      flags: flags,
    );
  }
}

/// Команда для сборки iOS-артефакта.
class BuildIos implements BuildFunction {
  const BuildIos();

  @override
  Future<void> call({
    required String flutter,
    required String flavor,
    required String buildType,
    required String entryPointPath,
    required String flags,
    // Не используется. Передается для совпадения сигнатур у всех основных команд.
    required String extension,
  }) async {
    Printer.printWarning('iOS build started');
    return buildIosOutput(
      flutter: flutter,
      flavor: flavor,
      buildType: buildType,
      entryPointPath: entryPointPath,
      flags: flags,
    );
  }
}
