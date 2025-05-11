import 'dart:io'; // Added for File
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:edu_sync/models/user.dart' as app_user; // Aliased to avoid conflict with supabase_flutter.User

class AuthService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<User?> signUp(String email, String password, String role, {String? fullName, int? schoolIdIfKnown, String? profilePhotoUrl}) async {
    final Map<String, dynamic> userMetadata = {'role': role};
    if (fullName != null) userMetadata['full_name'] = fullName;
    if (schoolIdIfKnown != null) userMetadata['school_id'] = schoolIdIfKnown;
    if (profilePhotoUrl != null) userMetadata['profile_photo_url'] = profilePhotoUrl;
    
    final AuthResponse response = await _supabaseClient.auth.signUp(
      email: email,
      password: password,
      data: userMetadata,
    );
    return response.user;
  }

  Future<User?> signIn(String email, String password) async {
    final AuthResponse response = await _supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response.user;
  }

  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }

  User? getCurrentUser() {
    return _supabaseClient.auth.currentUser;
  }

  String? getUserRole() {
    final User? user = getCurrentUser();
    // Prefer fetching role from public.users table as it's our source of truth for app-specific roles
    // This requires an async call, so this synchronous getter might need to be rethought
    // or we rely on userMetadata if populated reliably at sign-in/sign-up.
    // For now, let's assume userMetadata is the primary source during active session.
    if (user != null && user.userMetadata != null) {
      return user.userMetadata!['role'] as String?;
    }
    return null;
  }

  // Fetch a specific user's details (app_user.User model) by their ID
  Future<app_user.User?> getUserById(String userId) async {
    try {
      final response = await _supabaseClient
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      return app_user.User.fromMap(response);
    } catch (e) {
      print('Error fetching user by ID $userId: $e');
      return null;
    }
  }

  // Fetches the school_id from the public.users table for the current authenticated user
  Future<int?> getCurrentUserSchoolId() async {
    final currentUser = _supabaseClient.auth.currentUser;
    if (currentUser == null) return null;
    try {
      final response = await _supabaseClient
          .from('users')
          .select('school_id')
          .eq('id', currentUser.id)
          .single();
      return response['school_id'] as int?;
    } catch (e) {
      print('Error fetching current user school_id: $e');
      return null;
    }
  }

  // Fetch users by role (e.g., 'Teacher', 'Parent') for a specific school
  Future<List<app_user.User>> getUsersByRole(String role, int schoolId) async {
    try {
      final response = await _supabaseClient
          .from('users')
          .select()
          .eq('role', role)
          .eq('school_id', schoolId); // Assuming users table has school_id

      return response.map((userData) => app_user.User.fromMap(userData)).toList();
    } catch (e) {
      print('Error fetching users by role: $e');
      return [];
    }
  }

  // Add a new user (e.g., Teacher or Parent by Admin)
  // IMPORTANT: Client-side user creation with admin privileges (_supabaseClient.auth.admin.createUser)
  // is generally insecure and might be blocked by Supabase policies or require a service_role_key.
  // This method is likely to fail with a "User not allowed" or "not_admin" error if called from a standard client.
  // The recommended approach is to use Supabase Edge Functions for such admin operations.
  // For now, this method is commented out to prevent errors. User creation should be handled
  // via user self-registration (signUp) or an Edge Function.
  /*
  Future<app_user.User?> createUser({
    required String email,
    required String password,
    required String role,
    required int schoolId,
    String? fullName,
    String? profilePhotoUrl,
  }) async {
    try {
      // THIS WILL LIKELY FAIL FROM CLIENT-SIDE WITHOUT SERVICE_ROLE_KEY
      final UserResponse response = await _supabaseClient.auth.admin.createUser(
        AdminUserAttributes(
          email: email,
          password: password,
          emailConfirm: true, 
          userMetadata: {
            'role': role,
            'full_name': fullName,
            'school_id': schoolId,
            'profile_photo_url': profilePhotoUrl,
          },
        ),
      );
      
      if (response.user != null) {
        await _supabaseClient.from('users').update({
          'full_name': fullName,
          'profile_photo_url': profilePhotoUrl,
          'school_id': schoolId,
          'role': role,
        }).eq('id', response.user!.id);

        final profileResponse = await _supabaseClient.from('users').select().eq('id', response.user!.id).single();
        return app_user.User.fromMap(profileResponse);
      }
      return null;
    } catch (e) {
      print('Error creating user by admin (this method is problematic from client-side): $e');
      return null;
    }
  }
  */

  Future<app_user.User?> createUserViaEdgeFunction({
    required String email,
    required String password,
    required String role,
    required int schoolId,
    String? fullName,
    String? profilePhotoUrl,
  }) async {
    try {
      final response = await _supabaseClient.functions.invoke(
        'create-user-admin', // Ensure this matches your deployed Edge Function name
        body: {
          'email': email,
          'password': password,
          'role': role,
          'school_id': schoolId,
          'full_name': fullName,
          'profile_photo_url': profilePhotoUrl,
        },
      );

      // Check if the function invocation itself resulted in an error (e.g., network issue, function not found)
      // The supabase_flutter client might throw an exception for this, which would be caught by the outer catch.
      // If the function executed but returned an error status code (e.g. 400, 500),
      // response.data might contain an error object from the function.
      
      if (response.data == null) {
        // This case might indicate a more fundamental issue with the function call or an empty successful response.
        print('Edge Function "create-user-admin" returned no data or failed to invoke.');
        throw Exception('Failed to create user: Edge function returned no data.');
      }

      // Check if the data returned by the function contains an error key (as per our Edge Function design)
      final responseData = response.data as Map<String, dynamic>;
      if (responseData.containsKey('error')) {
        print('Error from create-user-admin Edge Function: ${responseData['error']}');
        throw Exception('Failed to create user: ${responseData['error']}');
      }
      
      // If no error key and data is present, assume success
      return app_user.User.fromMap(responseData);
    } catch (e) {
      print('Exception calling create-user-admin function: $e');
      // Rethrow or provide a user-friendly error
      throw Exception('Failed to create user due to an unexpected error: ${e.toString()}');
    }
  }

  // Update user details (by Admin or user themselves)
  Future<bool> updateUser(app_user.User user) async { // Use app_user.User
    try {
      await _supabaseClient.from('users').update({
        'full_name': user.fullName, // Use fullName from app_user.User
        'profile_photo_url': user.profilePhotoUrl,
        'role': user.role,
        'school_id': user.schoolId,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', user.id);
      return true;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  // Delete a user (by Admin)
  Future<bool> deleteUser(String userId) async {
    try {
      // First, delete from auth.users (requires admin privileges)
      await _supabaseClient.auth.admin.deleteUser(userId);
      // Then, the trigger on auth.users should handle deletion from public.users if set up for ON DELETE CASCADE
      // Or, delete manually if trigger is not sufficient or for cleanup.
      // await _supabaseClient.from('users').delete().eq('id', userId); // This might be redundant if FK is ON DELETE CASCADE
      print("User $userId deleted from auth.users. Corresponding public.users entry should be removed by trigger/cascade.");
      return true;
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }

  // Upload user profile photo
  Future<String?> uploadProfilePhoto(String userId, String filePath, String fileName) async {
    try {
      final file = File(filePath);
      final storagePath = 'users/profile_photos/$userId/$fileName';
      await _supabaseClient.storage
          .from('edusync')
          .upload(storagePath, file, fileOptions: const FileOptions(cacheControl: '3600', upsert: true));
      
      final publicUrl = _supabaseClient.storage.from('edusync').getPublicUrl(storagePath);
      return publicUrl;
    } catch (e) {
      print('Error uploading profile photo: $e');
    }
    return null;
  }
}
