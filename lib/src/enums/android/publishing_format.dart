import 'dart:io';

import 'package:flutter_deployer/src/util/printer.dart';

const _apk = 'apk';
const _aab = 'appbundle';

const _firebase = 'fb';
const _googlePlay = 'gp';

/// Тип сборки Android-артефакта.
enum PublishingFormat {
  /// APK-файл.
  apk(_apk),

  /// AAB-файл.
  appbundle(_aab);

  /// Тип, используемый командой сборки.
  final String format;

  /// Конструктор.
  const PublishingFormat(this.format);

  /// Извлечение формата из строкового значения.
  static PublishingFormat? fromString(String value) {
    switch (value) {
      case _apk:
        return PublishingFormat.apk;
      case _aab:
        return PublishingFormat.appbundle;
      default:
        return null;
    }
  }

  /// Получение формата из способа публикации.
  static PublishingFormat fromDeployService(String value) {
    switch (value) {
      case _firebase:
        return PublishingFormat.apk;
      case _googlePlay:
        return PublishingFormat.appbundle;
      default:
        Printer.printError('Deploy to flag error!');
        exit(1);
    }
  }

  @override
  String toString() => format;
}
