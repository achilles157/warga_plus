/// Hybrid configuration class for API keys.
/// - In PRODUCTION: Uses compile-time --dart-define values
/// - In LOCAL/DEBUG: Falls back to .env file via flutter_dotenv
///
/// Usage in build command for production:
/// flutter build web --dart-define=GROQ_API_KEY=your_actual_key_here
class AppConfig {
  // Compile-time constants from --dart-define
  static const String _groqApiKeyFromDefine =
      String.fromEnvironment('GROQ_API_KEY', defaultValue: '');

  // Runtime .env values (set by main.dart after dotenv.load)
  static String? _groqApiKeyFromEnv;

  /// Call this after dotenv.load() in main.dart
  static void initFromEnv(String? envValue) {
    _groqApiKeyFromEnv = envValue;
  }

  /// Get the GROQ API Key.
  /// Priority: --dart-define > .env
  static String? get groqApiKey {
    // If dart-define has a value, use it (production)
    if (_groqApiKeyFromDefine.isNotEmpty) {
      return _groqApiKeyFromDefine;
    }
    // Otherwise, fall back to .env (local development)
    return _groqApiKeyFromEnv;
  }

  /// Check if we're running in production mode (dart-define was used)
  static bool get isProduction => _groqApiKeyFromDefine.isNotEmpty;
}
