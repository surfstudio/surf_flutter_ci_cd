/// Префиксы для Android-сборки приложения.
enum ApkPrefix {
  /// armeabi-v7a
  v7('armeabi-v7a'),

  /// x86_64
  x86('x86_64'),

  /// arm64-v8a
  x64('arm64-v8a'),

  /// universal
  universal('universal');

  /// Используемое значение.
  final String value;

  const ApkPrefix(this.value);

  @override
  String toString() => value;
}
