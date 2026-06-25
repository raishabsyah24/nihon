class AppConfig {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://nihon-phi.vercel.app',
  );

  static const googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue:
        '134177451774-hr5noreslca4j96281c9mje7ipgoljq3.apps.googleusercontent.com',
  );
}
