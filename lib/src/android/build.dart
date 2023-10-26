// ignore_for_file: implicit_dynamic_variable, avoid_print

import 'package:flutter_deployer/src/android/output_builder.dart';
import 'package:flutter_deployer/src/enums/enums.dart';
import 'package:flutter_deployer/src/output_builder/i_output_builder.dart';

/// Script for build apk and appBundle.
/// Need parameter: build type -release or -qa.
/// See also usage.
///
/// Exit codes:
/// 0 - success
/// 1 - error
Future<void> build({
  required String flavor,
  required String buildType,
  required String entryPointPath,
  required String flags,
  required String projectName,
  required PublishingFormat format,
}) async {
  final outputBuilder = _resolveOutputBuilder(format);

  await outputBuilder.build(
    flavor: flavor,
    entryPointPath: entryPointPath,
    flags: flags,
    buildType: buildType,
    projectName: projectName,
  );
}

IOutputBuilder _resolveOutputBuilder(PublishingFormat? publishingFormat) {
  switch (publishingFormat) {
    case PublishingFormat.apk:
      return ApkBuilder();

    default:
      return AppBundleBuilder();
  }
}
