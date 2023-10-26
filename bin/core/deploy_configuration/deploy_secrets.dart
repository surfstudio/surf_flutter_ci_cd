import 'dart:io';

import 'package:flutter_deployer/src/util/printer.dart';
import 'package:yaml/yaml.dart';

import '../arguments/arguments.dart';

/// Размещение файла с секретами по умолчанию.
const _defaultSecretPath = 'secrets.yaml';

/// {@template classdoc}
/// Секреты для деплоя приложения.
/// {@endtemplate}
class DeploySecrets {
  /// Токен для загрузки в Firebase.
  final String? firebaseToken;

  /// Идентификатор ключа API для загрузки в TestFlight.
  final String? testflightKeyId;

  /// Идентификатор выпускающего ключа API для загрузки в TestFlight.
  final String? testflightIssuerId;

  /// Содержимое для передачи testflight key raw data.
  final String? testflightKeyData;

  /// Cодержимое json ключа для выгрузки приложения в google play.
  final String? googlePlayData;

  /// Конструктор.
  ///
  /// {@macro classdoc}
  const DeploySecrets({
    required this.firebaseToken,
    required this.testflightKeyId,
    required this.testflightIssuerId,
    required this.testflightKeyData,
    required this.googlePlayData,
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

    final firebaseToken = secretsMap['firebase_token'] as String?;
    final testflightKeyId = secretsMap['testflight_key_id'] as String?;
    final testflightIssuerId = secretsMap['testflight_issuer_id'] as String?;
    final testflightKeyData = secretsMap['testflight_key_data'] as String?;
    final googlePlayData = secretsMap['google_play_data'] as String?;

    return DeploySecrets(
      firebaseToken: firebaseToken,
      testflightKeyId: testflightKeyId,
      testflightIssuerId: testflightIssuerId,
      testflightKeyData: testflightKeyData,
      googlePlayData: googlePlayData,
    );
  }

  DeploySecrets overrideByCliArguments(Arguments args) {
    return DeploySecrets(
      firebaseToken: args.firebaseToken ?? firebaseToken,
      testflightKeyId: args.testflightKeyId ?? testflightKeyId,
      testflightIssuerId: args.testflightIssuerId ?? testflightIssuerId,
      testflightKeyData: args.testflightKeyData ?? testflightKeyData,
      googlePlayData: args.googlePlayData ?? googlePlayData,
    );
  }
}
