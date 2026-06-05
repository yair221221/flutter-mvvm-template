/// Environment configuration — swap values per flavor.
/// Use [EnvConfig.development], [EnvConfig.staging], or [EnvConfig.production].
class EnvConfig {
  final String name;
  final String baseUrl;
  final bool enableLogging;
  final bool showDebugBanner;
  final int connectTimeoutMs;
  final int receiveTimeoutMs;

  const EnvConfig._({
    required this.name,
    required this.baseUrl,
    required this.enableLogging,
    required this.showDebugBanner,
    required this.connectTimeoutMs,
    required this.receiveTimeoutMs,
  });

  static const development = EnvConfig._(
    name: 'development',
    baseUrl: 'https://jsonplaceholder.typicode.com', // free mock API for local dev
    enableLogging: true,
    showDebugBanner: true,
    connectTimeoutMs: 30000,
    receiveTimeoutMs: 30000,
  );

  static const staging = EnvConfig._(
    name: 'staging',
    baseUrl: 'https://api-staging.example.com',
    enableLogging: true,
    showDebugBanner: false,
    connectTimeoutMs: 15000,
    receiveTimeoutMs: 15000,
  );

  static const production = EnvConfig._(
    name: 'production',
    baseUrl: 'https://api.example.com',
    enableLogging: false,
    showDebugBanner: false,
    connectTimeoutMs: 10000,
    receiveTimeoutMs: 10000,
  );

  @override
  String toString() => 'EnvConfig($name, $baseUrl)';
}
