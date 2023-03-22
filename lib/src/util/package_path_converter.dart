import 'dart:io';
import 'dart:isolate';

class PackagePathResolver {
  /// Converts package path to absolute path
  static Future<String> resolve({
    required String path,
  }) async {
    final uri = Uri.parse(path);
    final resolvedUri = await Isolate.resolvePackageUri(uri);

    final convertedFilePath =
        resolvedUri!.toFilePath(windows: Platform.operatingSystem == 'windows');

    var fixedPath = convertedFilePath;
    final regExp = RegExp(r'\blib/');
    final matches = regExp.allMatches(convertedFilePath);

    if (matches.length > 1) {
      for (var i = 0; i < matches.length - 1; i++) {
        final match = matches.elementAt(i);
        fixedPath = fixedPath.replaceRange(match.start, match.end, '');
      }
    }

    return fixedPath;
  }

  static Future<String> packagePath() =>
      resolve(path: 'package:surf_flutter_ci_cd/');
}
