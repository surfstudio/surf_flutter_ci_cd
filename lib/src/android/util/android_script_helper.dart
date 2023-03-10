class AndroidScriptHelper {
  static String get preBuildScript => '''
dart pub global activate fvm
fvm flutter clean
fvm flutter pub get''';

  const AndroidScriptHelper._();
}
