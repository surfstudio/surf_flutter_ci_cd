enum LibArgumentTypes {
  /// Флаг используемого окружения.
  environment._('env', 'Environment name', 'e'),

  /// Флаг указания используемого проекта.
  project._('project', 'Project name', 'p'),

  /// Флаг указания метода выгрузки артефакта.
  deployTo._('deploy-to', 'Deploy to service fb|tf|gp', 'd'),

  /// Флаг используемой плафтормы.
  platform._('platform', 'Target platform: android|ios'),

  /// Токен Firebase авторизации.
  firebaseToken._('firebase-token', 'Authorization token for firebase app distribution'),

  /// Флаг для передачи testflight key id.
  testflightKeyId._('testflight-key-id', 'Testflight key id'),

  /// Флаг для передачи testflight issuer id.
  testflightIssuerId._('testflight-issuer-id', 'Testflight issuer id'),

  /// Флаг для передачи testflight key raw data.
  testflightKeyData._('testflight-data', 'Testflight key raw data'),

  /// Флаг для передачи содержимого json ключа для выгрузки приложения в google play.
  googlePlayData._(
    'google-play-data',
    'Raw data of google play service account json, used to authenticate with Google',
  ),
  ;

  final String flag;
  final String hint;
  final String? abbr;

  const LibArgumentTypes._(
    this.flag,
    this.hint, [
    this.abbr,
  ]);
}
