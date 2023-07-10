import 'package:args/args.dart';

import 'const_strings.dart';

/// Фабрика для создания парсера аргументов.
ArgParser createParser() => ArgParser()
  ..addOption(
    ConstStrings.flagEnvironment,
    abbr: ConstStrings.flagEnvironmentAbbr,
    help: ConstStrings.flagEnvironmentHint,
  )
  ..addOption(
    ConstStrings.flagProject,
    abbr: ConstStrings.flagProjectAbbr,
    help: ConstStrings.flagProjectHint,
  )
  ..addOption(
    ConstStrings.flagTarget,
    abbr: ConstStrings.flagTargetAbbr,
    help: ConstStrings.flagTargetHint,
  )
  ..addOption(
    ConstStrings.flagDeploy,
    abbr: ConstStrings.flagDeployAbbr,
    help: ConstStrings.flagDeployHint,
  );
