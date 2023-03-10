class AndroidScriptHelper {
  static String get preBuildScript => '''
fvm flutter clean --verbose
fvm flutter pub get''';

  const AndroidScriptHelper._();
}
