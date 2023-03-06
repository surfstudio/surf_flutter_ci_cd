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

  @override
  String toString() => format;
}
