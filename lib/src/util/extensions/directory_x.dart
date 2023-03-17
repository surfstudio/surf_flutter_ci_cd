import 'dart:io';
import 'package:path/path.dart' as path;

extension DirectoryX on Directory {
  void copy(Directory destination) {
    final entities = listSync();

    for (final entity in entities) {
      if (entity is File) {
        entity.copySync(
          path.join(
            destination.path,
            path.basename(entity.path),
          ),
        );

        continue;
      }

      if (entity is Directory) {
        final newDirectory = Directory(
          path.join(
            destination.absolute.path,
            path.basename(entity.path),
          ),
        )..createSync();

        entity.absolute.copy(newDirectory);
      }
    }
  }
}
