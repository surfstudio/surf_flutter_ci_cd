import 'dart:io';

import 'package:flutter_deployer/src/util/printer.dart';

import 'core/arguments/argument_parser_factory.dart';
import 'core/arguments/arguments.dart';
import 'core/deploy_configuration/deploy_secrets.dart';
import 'core/function_command.dart';
import 'core/message_show.dart';

/// Точка входа в приложение.
void main(List<String> arguments) {
  try {
    cdProcess(arguments);
  } on Object catch (error, stackTrace) {
    Printer.printError('Error while execution cd process: $error');
    Printer.printError('With stack trace: $stackTrace');
    MessageShow.exitWithShowUsage();
  }
}

/// Запуск основного процесса.
Future<void> cdProcess(List<String> arguments) async {
  // Получение пути для вызова flutter.
  final flutterPath = Platform.environment['FLUTTER_ROOT'];
  final flutter = '$flutterPath/bin/flutter';

  // Создание парсера для разбора аргументов, переданных при запуске.
  final parser = createParser();
  // Полученные аргументы.
  final Arguments args = Arguments.parseAndCheck(arguments, parser);
  // Команда, которая создана после разбора аргументов.
  final command = CommandFunction.create(args.mainCommand);

  // Получены секреты из secrets.yaml и аргументов командной строки.
  final secrets = await DeploySecrets.create().then((value) => value.overrideByCliArguments(args));

  /// Выполнение команды.
  command(CommandFunctionArguments(
    flutter: flutter,
    proj: args.proj,
    env: args.env,
    platform: args.platform,
    deployTo: args.deployTo,
    secrets: secrets,
  ));
}
