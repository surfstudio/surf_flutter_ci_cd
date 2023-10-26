import 'package:flutter_deployer/src/util/printer.dart';

import 'build_config.dart';
import 'build_function.dart';
import 'deploy_function.dart';
import 'deploy_secrets.dart';
import 'message_show.dart';
import 'yaml_utils.dart';

const _buildCommand = 'build';
const _deployCommand = 'deploy';
const _buildAndDeployCommand = 'full';

/// Общая команда, которая определяет в зависимости от вызова, какую команду требуется вызвать.
abstract class CommandFunction {
  Future<void> call(String flutter, String proj, String env, String target, String? deployTo);

  /// Создаёт требуемую команду, в зависимости от переданной команды в параметре [mainCommand].
  factory CommandFunction.create(String mainCommand) {
    switch (mainCommand) {
      case _buildCommand:
        return BuildCommand();
      case _deployCommand:
        return DeployCommand();
      case _buildAndDeployCommand:
        return BuildAndDeployCommand();
      default:
        Printer.printError('Invalid command.');
        throw ExitException();
    }
  }
}

/// Команда сборки проекта без выгрузки.
class BuildCommand implements CommandFunction {
  @override
  Future<void> call(
    String flutter,
    String proj,
    String env,
    String target,
    // Не используется. Передается для совпадения сигнатур у всех основных команд.
    String? deployTo,
  ) =>
      build(flutter, proj, env, target);
}

/// Вызов сборки приложения через соответствующую функцию.
Future<void> build(
  String flutter,
  String proj,
  String env,
  String target,
) async {
  Printer.printNormal('Building $proj for $target in $env environment');

  final buildConfig = await BuildConfig.create(proj, env, target);

  final buildFunction = BuildFunction.create(target);

  await buildFunction(
    flutter: flutter,
    flavor: buildConfig.flavor,
    buildType: env,
    entryPointPath: buildConfig.entryPointPath,
    flags: buildConfig.flags,
    extension: buildConfig.extension,
  );
}

/// Команда выгрузки проекта без сборки.
class DeployCommand implements CommandFunction {
  @override
  Future<void> call(
    // Не используется. Передается для совпадения сигнатур у всех основных команд.
    String flutter,
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

/// Вызов выгрузки приложения через соответствующую функцию.
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

/// Команда сборки и выгрузки приложения.
class BuildAndDeployCommand implements CommandFunction {
  @override
  Future<void> call(
    String flutter,
    String proj,
    String env,
    String target,
    String? deployTo,
  ) {
    if (deployTo == null) {
      Printer.printError('Please specify the flag deploy.');
      throw ExitException();
    }
    return buildAndDeploy(flutter, proj, env, target, deployTo);
  }
}

/// Вызов сборки приложения и выгрузки через соответствующие функции.
Future<void> buildAndDeploy(
  String flutter,
  String proj,
  String env,
  String target,
  String deployTo,
) async {
  await build(flutter, proj, env, target);
  await deploy(proj, env, target, deployTo);
}
