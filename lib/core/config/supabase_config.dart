// File: lib/core/config/supabase_config.dart
// Centralized Supabase configuration for the application.
// IMPORTANT: Do not commit real credentials. Use environment variables
// or CI secrets in production. Replace placeholders with real values
// using `--dart-define` or a secure dotenv loader in development.

class SupabaseConfig {
  // Use --dart-define to inject real values at build/run time.
  // Example: flutter run --dart-define=SUPABASE_URL=https://xyz.supabase.co --dart-define=SUPABASE_ANON_KEY=pk_...
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'YOUR_SUPABASE_URL',
  );

  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR_SUPABASE_ANON_KEY',
  );

  static bool get isConfigured => url != 'YOUR_SUPABASE_URL' && anonKey != 'YOUR_SUPABASE_ANON_KEY';
}
