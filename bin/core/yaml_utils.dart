import 'dart:io';

import 'package:yaml/yaml.dart';

Future<YamlMap> readYamlConfig() async {
  final yamlContent = await File('cd.yaml').readAsString();
  final config = loadYaml(yamlContent) as YamlMap;
  return config;
}
