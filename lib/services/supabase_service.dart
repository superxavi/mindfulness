import 'package:supabase_flutter/supabase_flutter.dart';

/// Provides a single point to access the initialized Supabase client.
class SupabaseService {
  SupabaseService._();

  static SupabaseClient get client => Supabase.instance.client;
}
