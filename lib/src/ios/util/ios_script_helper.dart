class IosScriptHelper {
  static String get preBuildScript => '''
fvm flutter clean
fvm flutter pub get''';

  const IosScriptHelper._();

  static String composeScript({
    required String flavor,
    required String buildType,
  }) =>
      'bash lib/src/ios/build.sh -f $flavor -b $buildType';
}
