import '../models/user_profile.dart';
import 'supabase_service.dart';

/// Database helper for basic profile operations.
class DatabaseService {
  /// Creates or updates a user profile linked to auth `userId`.
  static Future<void> upsertProfile(UserProfile profile) async {
    final map = profile.toJson();
    final res = await SupabaseService.client
        .from('profiles')
        .upsert(map, onConflict: ['id'])
        .execute();

    if (res.error != null) {
      throw Exception('DB upsert error: ${res.error!.message}');
    }
  }

  /// Fetches profile by user id.
  static Future<UserProfile?> getProfile(String userId) async {
    final res = await SupabaseService.client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single()
        .execute();

    if (res.error != null) return null;
    return UserProfile.fromJson(Map<String, dynamic>.from(res.data));
  }
}
