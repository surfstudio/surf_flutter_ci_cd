import 'dart:io';

import 'package:yaml/yaml.dart';

Future<Map> readYamlConfig() async {
  final yamlContent = await File('cd.yaml').readAsString();
  final config = loadYaml(yamlContent) as Map;
  return config;
}
