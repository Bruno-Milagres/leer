abstract final class EnvConfig {
  static const calibreWebHost = String.fromEnvironment(
    'CALIBRE_WEB_HOST',
    defaultValue: '10.0.2.2',
  );

  static const calibreWebPort = String.fromEnvironment(
    'CALIBRE_WEB_PORT',
    defaultValue: '8083',
  );

  static const calibreWebUsername = String.fromEnvironment(
    'CALIBRE_WEB_USERNAME',
    defaultValue: 'admin',
  );

  static const calibreWebPassword = String.fromEnvironment(
    'CALIBRE_WEB_PASSWORD',
    defaultValue: 'admin123',
  );

  static String get calibreWebBaseUrl =>
      'http://$calibreWebHost:$calibreWebPort';

  static String get calibreWebOpdsUrl => '$calibreWebBaseUrl/opds';
}
