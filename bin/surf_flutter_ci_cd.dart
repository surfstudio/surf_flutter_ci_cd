import 'dart:io';

void main(List<String> arguments) {
  var parser = ArgParser();
  parser.addOption('env', abbr: 'e', help: 'Environment name');
  parser.addOption('proj', abbr: 'p', help: 'Project name');
  parser.addOption('platform', abbr: 'plat', help: 'Target platform');

  var results = parser.parse(arguments);
  var env = results['env'];
  var proj = results['proj'];
  var platform = results['platform'];

  if (arguments.isEmpty || arguments.contains('-h') || arguments.contains('--help')) {
    print('Usage: dart script.dart [build|deploy] --env=<environment> --proj=<project> --platform=<target platform>');
    print(parser.usage);
    exit(0);
  }

  if (env == null || proj == null || platform == null) {
    print('Missing arguments. Usage: dart script.dart [build|deploy] --env=<environment> --proj=<project> --platform=<target platform>');
    exit(1);
  }

  switch (results.rest.length > 0 ? results.rest[0] : '') {
    case 'build':
      print('Building $proj for $platform in $env environment');
      // execute build command here
      break;
    case 'deploy':
      print('Deploying $proj for $platform to $env environment');
      // execute deploy command here
      break;
    default:
      print('Invalid command. Usage: dart script.dart [build|deploy] --env=<environment> --proj=<project> --platform=<target platform>');
      exit(1);
  }
}
