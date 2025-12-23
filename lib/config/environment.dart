/// Environment Configuration
/// Defines app environment (dev, staging, production)

enum Environment { development, staging, production }

class EnvironmentConfig {
  static Environment _currentEnvironment = Environment.development;

  /// Get current environment
  static Environment get current => _currentEnvironment;

  /// Set environment
  static void setEnvironment(Environment environment) {
    _currentEnvironment = environment;
  }

  /// Check if development
  static bool get isDevelopment =>
      _currentEnvironment == Environment.development;

  /// Check if staging
  static bool get isStaging => _currentEnvironment == Environment.staging;

  /// Check if production
  static bool get isProduction => _currentEnvironment == Environment.production;

  /// Get environment name
  static String get environmentName {
    switch (_currentEnvironment) {
      case Environment.development:
        return 'Development';
      case Environment.staging:
        return 'Staging';
      case Environment.production:
        return 'Production';
    }
  }

  /// Get environment suffix (for app name)
  static String get environmentSuffix {
    switch (_currentEnvironment) {
      case Environment.development:
        return ' (Dev)';
      case Environment.staging:
        return ' (Staging)';
      case Environment.production:
        return '';
    }
  }
}
