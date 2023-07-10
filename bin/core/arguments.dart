import 'package:args/args.dart';

import 'const_strings.dart';
import 'message_show.dart';

/// {@template classdoc}
/// Объект получаемых аргументов для начала работы утилиты.
/// {@endtemplate}
class Arguments {
  /// Результат парсинга аргументов.
  final ArgResults _results;

  /// Окружение.
  String get env => _results[ConstStrings.flagEnvironment] ?? '';

  /// Проект.
  String get proj => _results[ConstStrings.flagProject] ?? '';

  /// Таргет сборки.
  String get target => _results[ConstStrings.flagTarget] ?? '';

  /// Куда будет осуществляться выгрузка.
  String? get deployTo => _results[ConstStrings.flagDeploy];

  /// Основная команда для выполнения.
  String get mainCommand => _results.rest.isNotEmpty ? _results.rest[0] : '';

  /// Конструктор.
  ///
  /// {@macro classdoc}
  const Arguments._(this._results);

  /// Создаёт экземплят из списка аргументов и парсера этих аргументов.
  ///
  /// {@macro classdoc}
  factory Arguments.parseAndCheck(List<String> arguments, ArgParser parser) {
    if (arguments.isEmpty || arguments.contains('-h') || arguments.contains('--help')) {
      throw ExitException();
    }
    try {
      final results = parser.parse(arguments);

      final args = Arguments._(results);
      if (args.mainCommand.isEmpty ||
          args.env.isEmpty ||
          args.proj.isEmpty ||
          args.target.isEmpty) {
        print('Missing arguments.');
        throw ExitException();
      }
      return args;
    } on Object catch (_) {
      throw ExitException();
    }
  }
}
