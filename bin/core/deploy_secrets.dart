import 'dart:io';

import 'package:surf_flutter_ci_cd/src/util/printer.dart';
import 'package:yaml/yaml.dart';

/// Размещение файла с секретами по умолчанию.
const _defaultSecretPath = 'secrets.yaml';

/// {@template classdoc}
/// Секреты для деплоя приложения.
/// {@endtemplate}
class DeploySecrets {
  /// Токен для загрузки в Firebase.
  final String firebaseToken;

  /// Идентификатор ключа API для загрузки в TestFlight.
  final String testflightKeyId;

  /// Идентификатор выпускающего ключа API для загрузки в TestFlight.
  final String testflightIssuerId;

  /// Конструктор.
  ///
  /// {@macro classdoc}
  const DeploySecrets({
    required this.firebaseToken,
    required this.testflightKeyId,
    required this.testflightIssuerId,
  });

  /// Создание объекта `DeploySecrets` из YAML-файла.
  static Future<DeploySecrets> create({String secretPath = _defaultSecretPath}) async {
    final secretsYaml = File(secretPath);
    final secretsMap = <dynamic, dynamic>{};

    if (secretsYaml.existsSync()) {
      secretsMap.addAll(loadYaml(await secretsYaml.readAsString()) as Map<dynamic, dynamic>);
      Printer.printWarning('Local deploy with secrets:');
      secretsMap.forEach((key, value) => Printer.printWarning('$key: $value'));
    } else {
      Printer.printWarning('Remote deploy');
    }

    final firebaseToken = secretsMap['firebase_token'] as String;
    final testflightKeyId = secretsMap['testflight_key_id'] as String;
    final testflightIssuerId = secretsMap['testflight_issuer_id'] as String;

    return DeploySecrets(
      firebaseToken: firebaseToken,
      testflightKeyId: testflightKeyId,
      testflightIssuerId: testflightIssuerId,
    );
  }
}
