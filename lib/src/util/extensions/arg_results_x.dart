import 'package:args/args.dart';
import 'package:surf_flutter_ci_cd/src/enums/enums.dart';

// ignore_for_file: implicit_dynamic_variable

extension ArgResultsX on ArgResults {
  T? tryGet<T>({
    required String name,
  }) {
    final arg = this[name];

    if (arg is T) return arg;

    return null;
  }

  String? get flavor => tryGet<String>(name: BuildOption.flavor.name);

  String? get buildType => tryGet<String>(name: BuildOption.buildType.name);

  PublishingFormat? get androidPublishingFormat {
    final raw = tryGet<String>(name: BuildOption.androidPublishingFormat.name);

    if (raw == null) return null;

    final format = PublishingFormat.fromString(raw);

    return format;
  }
}
