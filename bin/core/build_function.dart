import 'package:surf_flutter_ci_cd/src/util/printer.dart';
import 'package:surf_flutter_ci_cd/surf_flutter_ci_cd.dart';

import 'message_show.dart';

abstract class BuildFunction {
  Future<void> call({
    required String flavor,
    required String buildType,
    required String entryPointPath,
    required String flags,
    required String extension,
  });

  factory BuildFunction.create(String target) {
    const targets = {
      'android': BuildAndroid(),
      'ios': BuildIos(),
    };

    final buildFunction = targets[target];

    if (buildFunction == null) {
      Printer.printError('Invalid command.');
      throw ExitException();
    }
    return buildFunction;
  }
}

class BuildAndroid implements BuildFunction {
  const BuildAndroid();

  @override
  Future<void> call({
    required String flavor,
    required String buildType,
    required String entryPointPath,
    required String flags,
    required String extension,
  }) async {
    Printer.printWarning('Android build started');
    return buildAndroidOutput(
      flavor: flavor,
      buildType: buildType,
      entryPointPath: entryPointPath,
      format: PublishingFormat.fromString(extension) ?? PublishingFormat.apk,
      flags: flags,
    );
  }
}

class BuildIos implements BuildFunction {
  const BuildIos();

  @override
  Future<void> call({
    required String flavor,
    required String buildType,
    required String entryPointPath,
    required String flags,
    // Не используется. Передается для совпадения сигнатур у всех основных команд.
    required String extension,
  }) async {
    Printer.printWarning('Ios build started');
    return buildIosOutput(
      flavor: flavor,
      buildType: buildType,
      entryPointPath: entryPointPath,
      flags: flags,
    );
  }
}
