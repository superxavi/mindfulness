import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

/// Simple AuthService wrapping Supabase Auth APIs. Returns Supabase session or throws.
class AuthService {
  /// Sign up a new user with email and password.
  static Future<AuthResponse> signUp(String email, String password) async {
    final res = await SupabaseService.client.auth.signUp(
      email: email,
      password: password,
    );
    return res;
  }

  /// Sign in existing user with email and password.
  static Future<AuthResponse> signIn(String email, String password) async {
    final res = await SupabaseService.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return res;
  }

  /// Sign out current user.
  static Future<void> signOut() async {
    await SupabaseService.client.auth.signOut();
  }

  /// Returns current user, or null.
  static User? get currentUser => SupabaseService.client.auth.currentUser;
}
