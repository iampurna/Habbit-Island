//static const String _supabaseUrl = 'https://ojvuuxabbstdfqoaqpxq.supabase.co';
//static const String _supabaseAnonKey = 'sb_publishable_ZxgFj7z7fPGtU2ICI5wd6A_hytxTDbS';
import 'environment.dart';

/// Supabase Configuration
/// Manages Supabase credentials per environment

class SupabaseConfig {
  // Development
  static const String _devUrl = 'https://your-dev-project.supabase.co';
  static const String _devAnonKey = 'your-dev-anon-key';

  // Staging
  static const String _stagingUrl = 'https://your-staging-project.supabase.co';
  static const String _stagingAnonKey = 'your-staging-anon-key';

  // Production
  static const String _prodUrl = 'https://your-prod-project.supabase.co';
  static const String _prodAnonKey = 'your-prod-anon-key';

  /// Get Supabase URL for current environment
  static String get url {
    switch (EnvironmentConfig.current) {
      case Environment.development:
        return _devUrl;
      case Environment.staging:
        return _stagingUrl;
      case Environment.production:
        return _prodUrl;
    }
  }

  /// Get Supabase anon key for current environment
  static String get anonKey {
    switch (EnvironmentConfig.current) {
      case Environment.development:
        return _devAnonKey;
      case Environment.staging:
        return _stagingAnonKey;
      case Environment.production:
        return _prodAnonKey;
    }
  }

  /// Get service role key (for admin operations - never expose to client!)
  static String get serviceRoleKey {
    // Only available in development/staging
    if (EnvironmentConfig.isProduction) {
      throw Exception('Service role key not available in production');
    }
    return 'your-service-role-key';
  }
}
