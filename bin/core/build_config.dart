import 'package:surf_flutter_ci_cd/src/util/printer.dart';

import 'message_show.dart';
import 'yaml_utils.dart';

class BuildConfig {
  final String flavor;
  final String entryPointPath;
  final String flags;
  final String extension;

  const BuildConfig({
    required this.flavor,
    required this.entryPointPath,
    required this.flags,
    required this.extension,
  });

  static Future<BuildConfig> create(String proj, String env, String target) async {
    final config = await readYamlConfig();
    final envMap = config[proj]?[env];
    final buildMap = envMap?[target]?['build'];

    final flavor = buildMap['flavor'] as String?;
    final entryPointPath = envMap?['file_path'] as String?;
    final flags = buildMap['flags'] as String?;
    final extension = buildMap['extension'] as String?;

    if (flavor == null || entryPointPath == null || flags == null || extension == null) {
      Printer.printError('Wrong cd.yaml configuration');
      throw ExitException();
    }

    return BuildConfig(flavor: flavor, entryPointPath: entryPointPath, flags: flags, extension: extension);
  }
}
