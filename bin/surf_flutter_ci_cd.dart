import 'package:args/args.dart';

import 'core/arguments.dart';
import 'core/const_strings.dart';
import 'core/function_command.dart';
import 'core/message_show.dart';

void main(List<String> arguments) {
  try {
    cdProcess(arguments);
  } on Object catch (_) {
    MessageShow.exitWithShowUsage();
  }
}

void cdProcess(List<String> arguments) {
  // Парсер.
  final parser = createParser();
  // Аргументы.
  final Arguments args = Arguments.parseAndCheck(arguments, parser);

  final command = CommandFunction.create(args.mainCommand);

  command(args.proj, args.env, args.target, args.deployTo);
}

/// Метод создания парсера аргументов.
ArgParser createParser() {
  final parser = ArgParser();
  parser.addOption(ConstStrings.flagEnvironment, abbr: 'e', help: 'Environment name');
  parser.addOption(ConstStrings.flagProject, abbr: 'p', help: 'Project name');
  parser.addOption(ConstStrings.flagTarget, abbr: 't', help: 'Target platform');
  parser.addOption(ConstStrings.flagDeploy, abbr: 'd', help: 'Deploy to platform');
  return parser;
}
