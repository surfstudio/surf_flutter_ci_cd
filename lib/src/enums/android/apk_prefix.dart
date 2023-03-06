enum ApkPrefix {
  v7('armeabi-v7a'),
  x86('x86_64'),
  x64('arm64-v8a'),
  universal('universal');

  final String value;

  const ApkPrefix(this.value);

  @override
  String toString() => value;
}
