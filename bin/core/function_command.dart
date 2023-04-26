import 'package:surf_flutter_ci_cd/src/util/printer.dart';

import 'build_config.dart';
import 'build_function.dart';
import 'deploy_function.dart';
import 'deploy_secrets.dart';
import 'message_show.dart';
import 'yaml_utils.dart';

abstract class CommandFunction {
  Future<void> call(String proj, String env, String target, String? deployTo);

  factory CommandFunction.create(String mainCommand) {
    switch (mainCommand) {
      case 'build':
        return BuildCommand();
      case 'deploy':
        return DeployCommand();
      case 'full':
        return BuildAndDeployCommand();
      default:
        Printer.printError('Invalid command.');
        throw ExitException();
    }
  }
}

class BuildCommand implements CommandFunction {
  @override
  Future<void> call(
    String proj,
    String env,
    String target,
    // Не используется. Передается для совпадения сигнатур у всех основных команд.
    String? deployTo,
  ) =>
      build(proj, env, target);
}

/// Функция сборки приложения.
Future<void> build(
  String proj,
  String env,
  String target,
) async {
  Printer.printNormal('Building $proj for $target in $env environment');

  final buildConfig = await BuildConfig.create(proj, env, target);

  final buildFunction = BuildFunction.create(target);

  await buildFunction(
    flavor: buildConfig.flavor,
    buildType: env,
    entryPointPath: buildConfig.entryPointPath,
    flags: buildConfig.flags,
    extension: buildConfig.extension,
  );
}

class DeployCommand implements CommandFunction {
  @override
  Future<void> call(
    String proj,
    String env,
    String target,
    String? deployTo,
  ) {
    if (deployTo == null) {
      Printer.printError('Please specify the flag deploy.');
      throw ExitException();
    }
    return deploy(proj, env, target, deployTo);
  }
}

/// Функция деплоя приложения.
Future<void> deploy(
  String proj,
  String env,
  String target,
  String deployTo,
) async {
  Printer.printNormal('Deploying $proj for $target in $env environment and deploy to $deployTo.');

  final secrets = await DeploySecrets.create();

  final config = await readYamlConfig();

  final deployFunction = DeployFunction.create(target, deployTo);

  await deployFunction(config: config, env: env, project: proj, secrets: secrets);
}

class BuildAndDeployCommand implements CommandFunction {
  @override
  Future<void> call(
    String proj,
    String env,
    String target,
    String? deployTo,
  ) {
    if (deployTo == null) {
      Printer.printError('Please specify the flag deploy.');
      throw ExitException();
    }
    return buildAndDeploy(proj, env, target, deployTo);
  }
}

Future<void> buildAndDeploy(
  String proj,
  String env,
  String target,
  String deployTo,
) async {
  await build(proj, env, target);
  await deploy(proj, env, target, deployTo);
}
