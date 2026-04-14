// File: lib/core/constants/supabase_config.dart
// Holds access to environment variables used by the app.
// DO NOT place real keys in this file in the repository.

class SupabaseConfig {
  // Preferable: provide values via --dart-define at build time or use flutter_dotenv.
  // These constants read values injected through --dart-define.
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://<your-project>.supabase.co',
  );

  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '<anon-key-placeholder>',
  );

  // Service role key: DO NOT use in the client. Server/CI only.
  static const String serviceRoleKey = String.fromEnvironment(
    'SUPABASE_SERVICE_ROLE_KEY',
    defaultValue: '<service-role-placeholder>',
  );

  // Quick helper to detect if configuration values are present
  static bool get isConfigured =>
      url.isNotEmpty && anonKey != '<anon-key-placeholder>';
}

/*
  Suggested usage:
  - Local development: create a `.env` file and load it with flutter_dotenv.
  - Production/CI: provide environment variables or use --dart-define.

  Example with flutter_dotenv (optional):
    await dotenv.load();
    final url = dotenv.env['SUPABASE_URL'];

  Example with --dart-define:
    flutter run --dart-define=SUPABASE_URL="https://..." --dart-define=SUPABASE_ANON_KEY="..."
*/
