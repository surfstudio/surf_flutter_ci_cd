class AndroidScriptHelper {
  static String get preBuildScript => '''
fvm flutter clean
fvm flutter pub get''';

  const AndroidScriptHelper._();
}
