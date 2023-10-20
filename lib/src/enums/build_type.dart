const _qa = 'qa';
const _release = 'release';

/// Тип сборки.
enum BuildType {
  /// QA-сборка для внутреннего тестирования.
  qa(_qa),

  /// Релизная сборка.
  release(_release);

  /// Значение для передачи в сборку.
  final String value;

  const BuildType(this.value);

  @override
  String toString() => value;

  /// Получение типа сборки из строкового значения.
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
