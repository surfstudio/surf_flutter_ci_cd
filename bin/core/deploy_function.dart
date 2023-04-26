import 'package:surf_flutter_ci_cd/src/deployer.dart';
import 'package:surf_flutter_ci_cd/src/util/printer.dart';

import 'deploy_secrets.dart';
import 'message_show.dart';

abstract class DeployFunction {
  Future<void> call({
    required Map<dynamic, dynamic> config,
    required String project,
    required String env,
    required DeploySecrets secrets,
  });

  factory DeployFunction.create(String target, String deployTo) {
    const targets = {
      'android': {
        'fb': DeployAndroidFB(),
        'gp': DeployAndroidGP(),
      },
      'ios': {
        'tf': DeployIosTF(),
        'fb': DeployIosFB(),
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

class DeployAndroidFB implements DeployFunction {
  const DeployAndroidFB();
  @override
  Future<void> call({
    required Map config,
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
    return deployAndroidToFirebase(appId: appId, groups: groups, flavor: flavor, token: secrets.firebaseToken);
  }
}

class DeployAndroidGP implements DeployFunction {
  const DeployAndroidGP();
  @override
  Future<void> call(
      {required Map config, required String project, required String env, required DeploySecrets secrets}) {
    final androidConfig = _getAndroidConfig(config, project, env);
    final packageName = androidConfig['deploy']['google_play']['package_name'] as String;
    final flavor = androidConfig['build']['flavor'] as String;
    return deployAndroidToGPC(packageName: packageName, flavor: flavor);
  }
}

class DeployIosTF implements DeployFunction {
  const DeployIosTF();
  @override
  Future<void> call(
      {required Map config, required String project, required String env, required DeploySecrets secrets}) {
    if (secrets.testflightKeyId.isEmpty || secrets.testflightIssuerId.isEmpty) {
      Printer.printError(
          'Specify the testflight_key_id and testflight_issuer_id in secrets.yaml for deploy to TestFlight.');
      MessageShow.exitWithShowUsage();
    }
    return deployIosToTestFlight(keyId: secrets.testflightKeyId, issuerId: secrets.testflightIssuerId);
  }
}

class DeployIosFB implements DeployFunction {
  const DeployIosFB();

  @override
  Future<void> call(
      {required Map config, required String project, required String env, required DeploySecrets secrets}) {
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

Map<String, dynamic> _getAndroidConfig(Map<dynamic, dynamic> config, String proj, String env) {
  return config[proj][env]['android'] as Map<String, dynamic>;
}

Map<String, dynamic> _getIosConfig(Map<dynamic, dynamic> config, String proj, String env) {
  return config[proj][env]['ios'] as Map<String, dynamic>;
}
