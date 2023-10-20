import 'package:flutter_deployer/src/util/printer.dart';

import 'message_show.dart';
import 'yaml_config_fields.dart';
import 'yaml_utils.dart';

/// {@template classdoc}
/// Описание конфигурации сборки.
/// {@endtemplate}
class BuildConfig {
  /// Флейвор сборки.
  final String flavor;

  /// Точка входа в приложение.
  final String entryPointPath;

  /// Флаги, которые надо передать при сборке.
  final String flags;

  /// Расширение артефакта для сборки.
  final String extension;

  /// Конструктор.
  ///
  /// {@macro classdoc}
  const BuildConfig({
    required this.flavor,
    required this.entryPointPath,
    required this.flags,
    required this.extension,
  });

  /// Создание конфига из YAML конфигурации для проекта [project], с окружением [environment] для таргета [target].
  static Future<BuildConfig> create(String project, String environment, String target) async {
    final config = await readYamlConfig();
    final envMap = config[project]?[environment];
    final buildMap = envMap?[target]?[YamlConfigFields.buildField];

    final entryPointPath = _readFieldSafely(envMap, YamlConfigFields.filePathField);
    final flavor = _readFieldSafely(buildMap, YamlConfigFields.flavorField);
    final flags = _readFieldSafely(buildMap, YamlConfigFields.flagsField);
    final extension = _readFieldSafely(buildMap, YamlConfigFields.extensionField);

    return BuildConfig(
      flavor: flavor,
      entryPointPath: entryPointPath,
      flags: flags,
      extension: extension,
    );
  }

  /// Получение значения из Map-подобного объекта по ключу.
  ///
  /// Если значения нет, выбрасывает исключение
  static String _readFieldSafely(dynamic map, String fieldName) {
    final value = map[fieldName] as String?;

    if (value == null) {
      Printer.printError('Wrong YAML configuration: field $fieldName is not valid');
      throw ExitException();
    }

    return value;
  }
}
