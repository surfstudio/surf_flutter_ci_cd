import 'package:flutter_deployer/src/deployer.dart';
import 'package:flutter_deployer/src/util/printer.dart';
import 'package:yaml/yaml.dart';

import 'deploy_secrets.dart';
import 'message_show.dart';

const _androidTarget = 'android';
const _iosTarget = 'ios';

const _firebase = 'fb';
const _googlePlay = 'gp';
const _testFlight = 'tf';

/// Команда для выгрузки артефакта.
abstract class DeployFunction {
  /// Вызов команды выгрузки.
  Future<void> call({
    required YamlMap config,
    required String project,
    required String env,
    required DeploySecrets secrets,
  });

  /// Создание нужной команды выгрузки на основе переданных параметров.
  /// - [target] - платформа, под которую выполнялась сборка;
  /// - [deployTo] - платформа, куда будет выгружаться артефакт.
  factory DeployFunction.create(String target, String deployTo) {
    const targets = {
      _androidTarget: {
        _firebase: DeployAndroidFB(),
        _googlePlay: DeployAndroidGP(),
      },
      _iosTarget: {
        _testFlight: DeployIosTF(),
        _firebase: DeployIosFB(),
      },
    };

    final targetMap = targets[target];
    if (targetMap == null) {
      Printer.printError('Wrong target param. Current value: $target');
      throw ExitException();
    }

    final deployFunction = targetMap[deployTo];
    if (deployFunction == null) {
      Printer.printError('Wrong deployTo param for $target. Current value: $deployTo');
      throw ExitException();
    }
    return deployFunction;
  }
}

/// Команда выгрузки Android-артефакта в Firebase.
class DeployAndroidFB implements DeployFunction {
  const DeployAndroidFB();
  @override
  Future<void> call({
    required YamlMap config,
    required String project,
    required String env,
    required DeploySecrets secrets,
  }) {
    if (secrets.firebaseToken.isEmpty) {
      Printer.printError('Specify the firebase_token in secrets.yaml for deploy to Firebase.');
      MessageShow.exitWithShowUsage();
    }
    final androidConfig = _getAndroidConfig(config, project, env);
    final firebaseMap = androidConfig['deploy']['firebase'];

    final appId = firebaseMap['firebase_app_id'] as String;
    final groups = firebaseMap['groups'] as String;
    final flavor = androidConfig['build']['flavor'] as String;
    return deployAndroidToFirebase(
      appId: appId,
      groups: groups,
      flavor: flavor,
      token: secrets.firebaseToken,
    );
  }
}

/// Команда выгрузки Android-артефакта в Google Play.
class DeployAndroidGP implements DeployFunction {
  const DeployAndroidGP();
  @override
  Future<void> call({
    required YamlMap config,
    required String project,
    required String env,
    required DeploySecrets secrets,
  }) {
    final androidConfig = _getAndroidConfig(config, project, env);
    final packageName = androidConfig['deploy']['google_play']['package_name'] as String;
    final flavor = androidConfig['build']['flavor'] as String;
    return deployAndroidToGPC(packageName: packageName, flavor: flavor);
  }
}

/// Команда выгрузки iOS-артефакта в TestFlight.
class DeployIosTF implements DeployFunction {
  const DeployIosTF();
  @override
  Future<void> call({
    required YamlMap config,
    required String project,
    required String env,
    required DeploySecrets secrets,
  }) {
    if (secrets.testflightKeyId.isEmpty || secrets.testflightIssuerId.isEmpty) {
      Printer.printError(
          'Specify the testflight_key_id and testflight_issuer_id in secrets.yaml for deploy to TestFlight.');
      MessageShow.exitWithShowUsage();
    }
    return deployIosToTestFlight(
      keyId: secrets.testflightKeyId,
      issuerId: secrets.testflightIssuerId,
    );
  }
}

/// Команда выгрузки iOS-артефакта в Firebase.
class DeployIosFB implements DeployFunction {
  const DeployIosFB();

  @override
  Future<void> call({
    required YamlMap config,
    required String project,
    required String env,
    required DeploySecrets secrets,
  }) {
    if (secrets.firebaseToken.isEmpty) {
      Printer.printError('Specify the firebase_token in secrets.yaml for deploy to Firebase.');
      MessageShow.exitWithShowUsage();
    }
    final iosConfig = _getIosConfig(config, project, env);
    final firebaseMap = iosConfig['deploy']['firebase'];

    final appId = firebaseMap['firebase_app_id'] as String;
    final groups = firebaseMap['groups'] as String;
    return deployIosToFirebase(appId: appId, groups: groups, token: secrets.firebaseToken);
  }
}

/// Получение из YAML-конфигурации конфигурации для Android.
YamlMap _getAndroidConfig(YamlMap config, String proj, String env) {
  return config[proj][env]['android'] as YamlMap;
}

/// Получение из YAML-конфигурации конфигурации для iOS.
YamlMap _getIosConfig(YamlMap config, String proj, String env) {
  return config[proj][env]['ios'] as YamlMap;
}
