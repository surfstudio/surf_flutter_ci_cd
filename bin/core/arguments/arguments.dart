import 'package:args/args.dart';

import '../message_show.dart';
import 'lib_argument_types.dart';

/// {@template classdoc}
/// Объект получаемых аргументов для начала работы утилиты.
/// {@endtemplate}
class Arguments {
  /// Результат парсинга аргументов.
  final ArgResults _results;

  /// Окружение.
  String get env => _results[LibArgumentTypes.environment.flag] ?? '';

  /// Проект.
  String get proj => _results[LibArgumentTypes.project.flag] ?? '';

  /// Платформа сборки.
  String get platform => _results[LibArgumentTypes.platform.flag] ?? '';

  /// Куда будет осуществляться выгрузка.
  String? get deployTo => _results[LibArgumentTypes.deployTo.flag];

  /// Токен Firebase авторизации.
  String? get firebaseToken => _results[LibArgumentTypes.firebaseToken.flag];

  /// Testflight key id.
  String? get testflightKeyId => _results[LibArgumentTypes.testflightKeyId.flag];

  /// Testflight issuer id.
  String? get testflightIssuerId => _results[LibArgumentTypes.testflightIssuerId.flag];

  /// Testflight key содержимое файла ключа.
  String? get testflightKeyData => _results[LibArgumentTypes.testflightKeyData.flag];

  /// Содержимое json ключа для выгрузки приложения в google play.
  String? get googlePlayData => _results[LibArgumentTypes.googlePlayData.flag];

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
          args.platform.isEmpty) {
        print('Missing arguments.');
        throw ExitException();
      }
      return args;
    } on Object catch (e) {
      print(e);
      throw ExitException();
    }
  }
}
