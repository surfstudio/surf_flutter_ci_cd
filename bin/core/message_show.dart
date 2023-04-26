import 'dart:io';

/// Отображение сообщения ошибки в консоли.
class MessageShow {
  static Never exitWithShowUsage() {
    print(_usage);
    exit(1);
  }

  static const _usage =
      'Usage: flutter pub run surf_flutter_ci_cd [build|deploy|full] --env=<environment> --proj=<project> --target=<target platform>';
}

/// Ошибка, которая приводит к закрытию программы.
class ExitException implements Exception {}
