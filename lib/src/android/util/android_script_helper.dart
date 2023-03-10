class AndroidScriptHelper {
  static String get preBuildScript => '''
dart pub global activate fvm
fvm flutter clean --verbose
fvm flutter pub get''';

  const AndroidScriptHelper._();
}
