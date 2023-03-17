class AndroidScriptHelper {
  static String get preBuildScript => '''
fvm flutter pub get
''';

  const AndroidScriptHelper._();
}
