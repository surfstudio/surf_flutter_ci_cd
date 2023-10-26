import 'dart:io';

import 'package:yaml/yaml.dart';

const _defaultProjectConfigPath = 'cd.yaml';

/// Парсинг конфигурации из YAML конфигурации в корне проекта.
///
/// - [configPath] - путь до файла с конфигурацией в проекте,
/// по умолчанию файл ожидается в корне проекта с названием `cd.yaml`
Future<YamlMap> readYamlConfig({String configPath = _defaultProjectConfigPath}) async {
  final yamlContent = await File(configPath).readAsString();
  final config = loadYaml(yamlContent) as YamlMap;
  return config;
}
