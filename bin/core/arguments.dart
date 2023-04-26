import 'package:args/args.dart';

import 'const_strings.dart';
import 'message_show.dart';

// Объект получаемых аргументов.
class Arguments {
  final ArgResults _results;
  String get env => _results[ConstStrings.flagEnvironment] ?? '';
  String get proj => _results[ConstStrings.flagProject] ?? '';
  String get target => _results[ConstStrings.flagTarget] ?? '';
  String? get deployTo => _results[ConstStrings.flagDeploy];
  String get mainCommand => _results.rest.isNotEmpty ? _results.rest[0] : '';

  const Arguments(this._results);

  factory Arguments.parseAndCheck(List<String> arguments, ArgParser parser) {
    if (arguments.isEmpty || arguments.contains('-h') || arguments.contains('--help')) {
      throw ExitException();
    }
    try {
      final results = parser.parse(arguments);

      final args = Arguments(results);
      if (args.mainCommand.isEmpty || args.env.isEmpty || args.proj.isEmpty || args.target.isEmpty) {
        print('Missing arguments.');
        throw ExitException();
      }
      return args;
    } on Object catch (_) {
      throw ExitException();
    }
  }
}
