import 'package:args/args.dart';

extension ArgResultsX on ArgResults {
  T? tryGet<T>({
    required String name,
  }) {
    final arg = this[name];

    if (arg is T) return arg;

    return null;
  }
}
