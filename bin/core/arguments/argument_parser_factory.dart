import 'package:args/args.dart';

import 'lib_argument_types.dart';

/// Фабрика для создания парсера аргументов.
ArgParser createParser() => ArgParser()
  ..addLibArgument(LibArgumentTypes.environment)
  ..addLibArgument(LibArgumentTypes.project)
  ..addLibArgument(LibArgumentTypes.platform)
  ..addLibArgument(LibArgumentTypes.deployTo)
  ..addLibArgument(LibArgumentTypes.firebaseToken)
  ..addLibArgument(LibArgumentTypes.testflightKeyId)
  ..addLibArgument(LibArgumentTypes.testflightIssuerId)
  ..addLibArgument(LibArgumentTypes.testflightKeyData)
  ..addLibArgument(LibArgumentTypes.googlePlayData);

extension on ArgParser {
  void addLibArgument(LibArgumentTypes argument) => addOption(
        argument.flag,
        abbr: argument.abbr,
        help: argument.hint,
      );
}
