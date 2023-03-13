// ignore: one_member_abstracts
abstract class IOutputBuilder {
  Future<void> build({
    required String flavor,
    required String entryPointPath,
    required String buildType,
  });
}
