import 'dart:io';

import 'package:args/args.dart';
import 'package:surf_flutter_ci_cd/src/util/printer.dart';
import 'package:surf_flutter_ci_cd/surf_flutter_ci_cd.dart';
import 'package:yaml/yaml.dart';

void main(List<String> arguments) {
  var parser = ArgParser();
  parser.addOption('env', abbr: 'e', help: 'Environment name');
  parser.addOption('proj', abbr: 'p', help: 'Project name');
  parser.addOption('target', abbr: 't', help: 'Target platform');

  final String? env;
  final String? proj;
  final String? target;
  final ArgResults results;

  try {
    results = parser.parse(arguments);
    env = results['env'];
    proj = results['proj'];
    target = results['target'];
  } on Object catch (e) {
    Printer.printError(e.toString());
    exit(1);
  }

  if (arguments.isEmpty ||
      arguments.contains('-h') ||
      arguments.contains('--help')) {
    print(
        'Usage: dart script.dart [build|deploy] --env=<environment> --proj=<project> --target=<target platform>');
    print(parser.usage);
    exit(1);
  }

  if (env == null || proj == null || target == null) {
    print(
        'Missing arguments. Usage: dart script.dart [build|deploy] --env=<environment> --proj=<project> --target=<target platform>');
    exit(1);
  }

  switch (results.rest.isNotEmpty ? results.rest[0] : '') {
    case 'build':
      print('Building $proj for $target in $env environment');
      _build(proj, env, target);
      break;
    case 'deploy':
      print('Deploying $proj for $target to $env environment');
      // execute deploy command here
      break;
    default:
      print(
          'Invalid command. Usage: dart script.dart [build|deploy] --env=<environment> --proj=<project> --target=<target platform>');
      exit(1);
  }
}

Future<void> _build(String proj, String env, String target) async {
  final yamlContent = await File('cd.yaml').readAsString();
  final config = loadYaml(yamlContent) as Map;
  final ext = config[proj][env][target]['build']['extension'] as String;
  final flavor = config[proj][env][target]['build']['flavor'] as String;
  final entryPointPath = config[proj][env]['file_path'] as String;

  switch (target) {
    case 'android':
      print('Android build started');
      await buildAndroidOutput(
        flavor: flavor,
        buildType: env,
        entryPointPath: entryPointPath,
        format: PublishingFormat.fromString(ext) ?? PublishingFormat.appbundle,
      );
      break;
    case 'ios':
      print('Ios build started');
      await buildIosOutput(
        flavor: flavor,
        buildType: env,
        entryPointPath: entryPointPath,
      );
      break;
    default:
  }
}
