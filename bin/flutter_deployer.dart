import 'dart:io';

import 'package:flutter_deployer/src/util/printer.dart';

import 'core/argument_parser_factory.dart';
import 'core/arguments.dart';
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
void cdProcess(List<String> arguments) {
  // Получение пути для вызова flutter.
  final flutterPath = Platform.environment['FLUTTER_ROOT'];
  final flutter = '$flutterPath/bin/flutter';

  // Создание парсера для разбора аргументов, переданных при запуске.
  final parser = createParser();
  // Полученные аргументы.
  final Arguments args = Arguments.parseAndCheck(arguments, parser);
  // Команда, которая создана после разбора аргументов.
  final command = CommandFunction.create(args.mainCommand);

  /// Выполнение команды.
  command(flutter, args.proj, args.env, args.target, args.deployTo);
}
