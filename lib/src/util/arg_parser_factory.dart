import 'package:args/args.dart';
import 'package:surf_flutter_ci_cd/src/enums/enums.dart';

ArgParser createDefaultArgParser() => ArgParser()
  ..addOption(
    BuildOption.buildType.name,
    abbr: BuildOption.buildType.abbr,
    help: BuildOption.buildType.help,
    valueHelp: BuildOption.buildType.valueHelp,
    mandatory: BuildOption.buildType.mandatory,
  )
  ..addOption(
    BuildOption.flavor.name,
    abbr: BuildOption.flavor.abbr,
    help: BuildOption.flavor.help,
    valueHelp: BuildOption.flavor.valueHelp,
    mandatory: BuildOption.flavor.mandatory,
  )
  ..addOption(
    BuildOption.androidPublishingFormat.name,
    abbr: BuildOption.androidPublishingFormat.abbr,
    help: BuildOption.androidPublishingFormat.help,
    valueHelp: BuildOption.androidPublishingFormat.valueHelp,
    mandatory: BuildOption.androidPublishingFormat.mandatory,
    defaultsTo: PublishingFormat.appbundle.format,
    allowed: [
      PublishingFormat.apk.format,
      PublishingFormat.appbundle.format,
    ],
  );
