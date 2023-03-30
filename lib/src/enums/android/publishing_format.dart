import 'dart:io';

import 'package:surf_flutter_ci_cd/src/util/printer.dart';

const _apk = 'apk';
const _aab = 'appbundle';

enum PublishingFormat {
  apk(_apk),
  appbundle(_aab);

  final String format;

  const PublishingFormat(this.format);

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

  static PublishingFormat fromDeployService(String value) {
    switch (value) {
      case 'fb':
        return PublishingFormat.apk;
      case 'gp':
        return PublishingFormat.appbundle;
      default:
        Printer.printError('Deploy to flag error!');
        exit(1);
    }
  }

  @override
  String toString() => format;
}
