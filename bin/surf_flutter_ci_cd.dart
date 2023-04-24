import 'dart:io';

import 'package:args/args.dart';
import 'package:surf_flutter_ci_cd/src/deployer.dart';
import 'package:surf_flutter_ci_cd/src/util/printer.dart';
import 'package:surf_flutter_ci_cd/surf_flutter_ci_cd.dart';
import 'package:yaml/yaml.dart';

class FlagsName {
  static const environment = 'env';
  static const project = 'proj';
  static const target = 'target';
  static const deploy = 'deploy-to';
}

class MessageShow {
  static Never exitWithShowUsage(ArgParser parser) {
    print(_usage);
    print(parser.usage);
    exit(1);
  }

  static const _usage =
      'Usage: flutter pub run surf_flutter_ci_cd [build|deploy|full] --env=<environment> --proj=<project> --target=<target platform>';
}

void main(List<String> arguments) {
  var parser = ArgParser();
  parser.addOption(FlagsName.environment, abbr: 'e', help: 'Environment name');
  parser.addOption(FlagsName.project, abbr: 'p', help: 'Project name');
  parser.addOption(FlagsName.target, abbr: 't', help: 'Target platform');
  parser.addOption(FlagsName.deploy, abbr: 'd', help: 'Deploy to platform');

  final String? env;
  final String? proj;
  final String? target;
  final String? deployTo;
  final ArgResults results;

  try {
    results = parser.parse(arguments);
    env = results[FlagsName.environment];
    proj = results[FlagsName.project];
    target = results[FlagsName.target];
    deployTo = results[FlagsName.deploy];
  } on Object catch (e) {
    Printer.printError(e.toString());
    exit(1);
  }

  if (arguments.isEmpty || arguments.contains('-h') || arguments.contains('--help')) {
    MessageShow.exitWithShowUsage(parser);
  }

  if (env == null || proj == null || target == null) {
    print('Missing arguments.');
    MessageShow.exitWithShowUsage(parser);
  }

  switch (results.rest.isNotEmpty ? results.rest[0] : '') {
    case 'build':
      Printer.printNormal('Building $proj for $target in $env environment');
      _build(proj, env, target);
      break;
    case 'deploy':
      if (deployTo == null) {
        Printer.printError('Please specify the flag deploy.');
        MessageShow.exitWithShowUsage(parser);
      }
      Printer.printNormal('Deploying $proj for $target in $env environment.');
      _deploy(proj, env, target, deployTo);
      break;
    case 'full':
      if (deployTo == null) {
        Printer.printError('Please specify the flag deploy.');
        MessageShow.exitWithShowUsage(parser);
      }
      _buildAndDeploy(proj, env, target, deployTo);
      break;
    default:
      Printer.printError('Invalid command.');
      MessageShow.exitWithShowUsage(parser);
  }
}

Future<void> _buildAndDeploy(
  String proj,
  String env,
  String target,
  String deployTo,
) async {
  Printer.printNormal('Building $proj for $target in $env environment');
  await _build(proj, env, target);
  Printer.printNormal('Deploying $proj for $target in $env environment');
  await _deploy(proj, env, target, deployTo);
}

/// Функция сборки приложения.
Future<void> _build(
  String proj,
  String env,
  String target,
) async {
  final yamlContent = await File('cd.yaml').readAsString();
  final config = loadYaml(yamlContent) as Map;
  final flavor = config[proj][env][target]['build']['flavor'] as String;
  final entryPointPath = config[proj][env]['file_path'] as String;
  final flags = config[proj][env][target]['build']['flags'] as String;
  final extension = config[proj][env][target]['build']['extension'] as String;

  final targets = {
    'android': () async {
      Printer.printWarning('Android build started');
      return await buildAndroidOutput(
        flavor: flavor,
        buildType: env,
        entryPointPath: entryPointPath,
        projectName: proj,
        format: PublishingFormat.fromString(extension) ?? PublishingFormat.apk,
        flags: flags,
      );
    },
    'ios': () async {
      Printer.printWarning('Ios build started');
      return await buildIosOutput(
        flavor: flavor,
        buildType: env,
        entryPointPath: entryPointPath,
        flags: flags,
      );
    }
  };

  final buildFunction = targets[target];

  if (buildFunction == null) {
    Printer.printError(
        'Invalid command. Use [build|deploy] --env=<environment> --proj=<project> --target=<target platform> --deploy-to=<deploy platform>');
    exit(1);
  }

  await buildFunction.call();
}

/// Функция деплоя приложения.
Future<void> _deploy(
  String proj,
  String env,
  String target,
  String deployTo,
) async {
  final yamlContent = await File('cd.yaml').readAsString();
  final config = loadYaml(yamlContent) as Map;

  // Чтение secret.yaml
  String? firebaseToken;
  String? testflightKeyId;
  String? testflightIssuerId;
  final secretsMap = await _loadSecretsYaml();

  firebaseToken = secretsMap['firebase_token'] as String;
  testflightKeyId = secretsMap['testflight_key_id'] as String;
  testflightIssuerId = secretsMap['testflight_issuer_id'] as String;

  final targets = {
    'android': {
      'fb': () async {
        final androidConfig = _getAndroidConfig(config, proj, env);
        final appId = androidConfig['deploy']['firebase']['firebase_app_id'] as String;
        final groups = androidConfig['deploy']['firebase']['groups'] as String;
        final flavor = androidConfig['build']['flavor'] as String;
        return await deployAndroidToFirebase(appId: appId, groups: groups, flavor: flavor, token: firebaseToken);
      },
      'gp': () async {
        final androidConfig = _getAndroidConfig(config, proj, env);
        final packageName = androidConfig['deploy']['google_play']['package_name'] as String;
        final flavor = androidConfig['build']['flavor'] as String;
        return await deployAndroidToGPC(packageName: packageName, flavor: flavor);
      },
    },
    'ios': {
      'tf': () async {
        return await deployIosToTestFlight(keyId: testflightKeyId, issuerId: testflightIssuerId);
      },
      'fb': () async {
        final iosConfig = _getIosConfig(config, proj, env);
        final appId = iosConfig['deploy']['firebase']['firebase_app_id'] as String;
        final groups = iosConfig['deploy']['firebase']['groups'] as String;
        return await deployIosToFirebase(appId: appId, groups: groups, token: firebaseToken);
      },
    },
  };

  final targetMap = targets[target];
  if (targetMap == null) {
    Printer.printError('Wrong target param. Current value: $target');
    exit(1);
  }

  final deployFunction = targetMap[deployTo];
  if (deployFunction == null) {
    Printer.printError('Wrong deployTo param for $target. Current value: $deployTo');
    exit(1);
  }

  await deployFunction();
}

Future<Map<dynamic, dynamic>> _loadSecretsYaml() async {
  final secretsYaml = File('secrets.yaml');
  final secretsMap = <dynamic, dynamic>{};
  if (secretsYaml.existsSync()) {
    secretsMap.addAll(loadYaml(await secretsYaml.readAsString()) as Map<dynamic, dynamic>);
    Printer.printWarning('Local deploy with secrets:');
    secretsMap.forEach((key, value) => Printer.printWarning('$key: $value'));
  } else {
    Printer.printWarning('Remote deploy');
  }
  return secretsMap;
}

Map<String, dynamic> _getAndroidConfig(Map<dynamic, dynamic> config, String proj, String env) {
  return config[proj][env]['android'] as Map<String, dynamic>;
}

Map<String, dynamic> _getIosConfig(Map<dynamic, dynamic> config, String proj, String env) {
  return config[proj][env]['ios'] as Map<String, dynamic>;
}
