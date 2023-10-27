import 'package:flutter_deployer/src/util/printer.dart';

import 'build_configuration/build_config.dart';
import 'build_configuration/build_function.dart';
import 'deploy_configuration/deploy_function.dart';
import 'deploy_configuration/deploy_secrets.dart';
import 'message_show.dart';
import 'yaml_parser/yaml_utils.dart';

const _buildCommand = 'build';
const _deployCommand = 'deploy';
const _buildAndDeployCommand = 'full';

/// Аргументы для метода.
class CommandFunctionArguments {
  /// Путь до flutter, который запускал пакет.
  final String flutter;

  /// Проект, для которого необходимо сделать сборку.
  final String proj;

  /// Тип сборки
  final String env;

  /// Платформа для сборки
  final String platform;

  /// Куда планируется отпарвка сборки.
  final String? deployTo;

  /// Секреты для сборки.
  final DeploySecrets secrets;

  const CommandFunctionArguments({
    required this.flutter,
    required this.proj,
    required this.env,
    required this.platform,
    required this.deployTo,
    required this.secrets,
  });
}

/// Общая команда, которая определяет в зависимости от вызова, какую команду требуется вызвать.
abstract class CommandFunction {
  Future<void> call(CommandFunctionArguments arguments);

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
  Future<void> call(arguments) => _build(arguments);
}

/// Команда сборки и выгрузки приложения.
class BuildAndDeployCommand implements CommandFunction {
  @override
  Future<void> call(CommandFunctionArguments arguments) async {
    await _build(arguments);
    await _deploy(arguments);
  }
}

/// Команда выгрузки проекта без сборки.
class DeployCommand implements CommandFunction {
  @override
  Future<void> call(CommandFunctionArguments arguments) {
    return _deploy(arguments);
  }
}

/// Вызов сборки приложения через соответствующую функцию.
Future<void> _build(CommandFunctionArguments arguments) async {
  Printer.printNormal(
      'Building ${arguments.proj} for ${arguments.platform} in ${arguments.env} environment');

  final buildConfig = await BuildConfig.create(arguments.proj, arguments.env, arguments.platform);
  final buildFunction = BuildFunction.create(arguments.platform);

  await buildFunction(
    flutter: arguments.flutter,
    flavor: buildConfig.flavor,
    buildType: arguments.env,
    entryPointPath: buildConfig.entryPointPath,
    flags: buildConfig.flags,
    extension: buildConfig.extension,
  );
}

/// Вызов выгрузки приложения через соответствующую функцию.
Future<void> _deploy(CommandFunctionArguments arguments) async {
  Printer.printNormal(
      'Deploying ${arguments.proj} for ${arguments.platform} in ${arguments.env} environment and deploy to ${arguments.deployTo}.');

  final config = await readYamlConfig();

  final deployTo = arguments.deployTo;
  if (deployTo == null) {
    Printer.printError('Please specify the flag deploy.');
    throw ExitException();
  }
  final deployFunction = DeployFunction.create(arguments.platform, deployTo);

  await deployFunction(
    config: config,
    env: arguments.env,
    project: arguments.proj,
    secrets: arguments.secrets,
  );
}
