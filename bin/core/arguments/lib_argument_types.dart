enum LibArgumentTypes {
  /// Флаг используемого окружения.
  environment._('evn', 'e', 'Environment name'),

  /// Флаг указания используемого проекта.
  project._('project', 'pr', 'Project name'),

  /// Флаг используемой плафтормы.
  platform._('platform', 'pl', 'Target platform: android|ios'),

  /// Флаг указания метода выгрузки артефакта.
  deployTo._('deploy-to', 'd', 'Deploy to service fb|tf|gp'),

  /// Токен Firebase авторизации.
  firebaseToken._('firebase-token', 'fb', 'Authorization token for firebase app distribution'),

  /// Флаг для передачи testflight key id.
  testflightKeyId._('testflight-key-id', 'tfk', 'Testflight key id'),

  /// Флаг для передачи testflight issuer id.
  testflightIssuerId._('testflight-issuer-id', 'tfi', 'Testflight issuer id'),

  /// Флаг для передачи testflight key raw data.
  testflightKeyData._('testflight-data', 'tfd', 'Testflight key raw data'),

  /// Флаг для передачи содержимого json ключа для выгрузки приложения в google play.
  googlePlayData._(
    'google-play-data',
    'gpd',
    'Raw data of google play service account json, used to authenticate with Google',
  ),
  ;

  final String flag;
  final String abbr;
  final String hint;

  const LibArgumentTypes._(this.flag, this.abbr, this.hint);
}
