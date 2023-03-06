const _qa = 'qa';
const _release = 'release';

enum BuildType {
  qa(_qa),
  release(_release);

  final String value;

  const BuildType(this.value);

  @override
  String toString() => value;

  static BuildType? fromValue(String value) {
    switch (value) {
      case _qa:
        return BuildType.qa;
      case _release:
        return BuildType.release;
      default:
        return null;
    }
  }
}
