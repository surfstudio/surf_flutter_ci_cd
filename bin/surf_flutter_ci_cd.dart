import 'dart:io';

import 'package:args/args.dart';
import 'package:process_run/shell.dart';
import 'package:surf_flutter_ci_cd/utils/printer.dart';

void main(List<String> arguments) {
  var parser = ArgParser();
  parser.addOption('env', abbr: 'e', help: 'Environment name');
  parser.addOption('proj', abbr: 'p', help: 'Project name');
  parser.addOption('target', abbr: 't', help: 'Target platform');

  var env;
  var proj;
  var target;
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
      _shellCommand();
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

Future<void> _shellCommand() async {
  final shell = Shell();
  final res = await shell.run('ls');

  for (final out in res) {
    stdout
      ..write(out.stderr)
      ..write(out.stdout);
  }

  await shell.run('cd ..');
  final res1 = await shell.run('ls');
  for (final out in res1) {
    stdout
      ..write(out.stderr)
      ..write(out.stdout);
  }
}
