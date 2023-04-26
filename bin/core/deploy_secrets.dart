import 'dart:io';

import 'package:surf_flutter_ci_cd/src/util/printer.dart';
import 'package:yaml/yaml.dart';

class DeploySecrets {
  final String firebaseToken;
  final String testflightKeyId;
  final String testflightIssuerId;

  const DeploySecrets({required this.firebaseToken, required this.testflightKeyId, required this.testflightIssuerId});

  static Future<DeploySecrets> create() async {
    final secretsYaml = File('secrets.yaml');
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
