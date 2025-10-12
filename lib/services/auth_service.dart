import 'dart:io'; // Added for File
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:edu_sync/utils/logger.dart';
import 'package:edu_sync/services/notification_service.dart';


import 'package:edu_sync/models/user.dart' as app_user; // Aliased to avoid conflict with supabase_flutter.User
import 'package:edu_sync/models/user_role.dart';

class AuthService {
  final SupabaseClient _supabaseClient;
  final SharedPreferences _prefs;
  final NotificationService _notificationService;


  AuthService({
    required SupabaseClient supabaseClient,
    required SharedPreferences sharedPreferences,
    required Connectivity connectivity,
    required NotificationService notificationService,
  })  : _supabaseClient = supabaseClient,
        _prefs = sharedPreferences,
        _notificationService = notificationService;
        
  void listenToAuthChanges() {
    _supabaseClient.auth.onAuthStateChange.listen((data) async {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        logger.i('User signed in, subscribing to announcements.');
        final role = await getUserRole();
        final schoolId = await getCurrentUserSchoolId();
        final user = getCurrentUser();
        if (role != null && schoolId != null && user != null) {
          _notificationService.subscribeToAnnouncements(schoolId, user.id, role);
        }
      } else if (event == AuthChangeEvent.signedOut) {
        logger.i('User signed out, unsubscribing from announcements.');
        _notificationService.unsubscribeFromAnnouncements();
      }
    });
  }

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
    await _prefs.remove('user_role');
    await _supabaseClient.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    // The redirectTo URL must be configured in the Supabase Dashboard under Authentication -> Settings -> Redirect URLs
    // and should point to a page in your app that can handle the password reset.
    // The redirectTo URL must be a URL that the app can handle as a deep link.
    await _supabaseClient.auth.resetPasswordForEmail(email,
        redirectTo: 'com.example.edusync://reset-password');
  }

  User? getCurrentUser() {
    return _supabaseClient.auth.currentUser;
  }

  Future<String?> getUserRole() async {
    final currentUser = _supabaseClient.auth.currentUser;
    if (currentUser == null) return null;

    // Try to get the role from cache first
    String? cachedRole = _prefs.getString('user_role');
    if (cachedRole != null) {
      return cachedRole;
    }
  
    try {
      final response = await _supabaseClient
          .from('users')
          .select('role')
          .eq('id', currentUser.id)
          .single();

      final role = response['role'] as String?;
      if (role != null) {
        // Cache the role
        await _prefs.setString('user_role', role);
      }
      return role;
    } catch (e) {
      logger.e('Error fetching user role: $e');
      return null;
    }
  }

  // Fetch a specific user's details (app_user.User model) by their ID
  Future<app_user.User?> getUserById(String userId) async {
    try {
      final response = await _supabaseClient
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      return app_user.User.fromJson(response);
    } catch (e) {
      logger.e('Error fetching user by ID $userId: $e');
      return null;
    }
  }

  // Fetches the school_id from the public.users table for the current authenticated user
  Future<int?> getCurrentUserSchoolId() async {
    final currentUser = _supabaseClient.auth.currentUser;
    if (currentUser == null) return null;

    // Try to get the school_id from cache first
    final cachedSchoolId = _prefs.getInt('school_id');
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none) && cachedSchoolId != null) {
      return cachedSchoolId;
    }

    try {
      final response = await _supabaseClient
          .from('users')
          .select('school_id')
          .eq('id', currentUser.id)
          .single();
      final schoolId = response['school_id'] as int?;
      if (schoolId != null) {
        // Cache the school_id
        await _prefs.setInt('school_id', schoolId);
      }
      return schoolId;
    } catch (e) {
      logger.e('Error fetching current user school_id: $e');
      // If fetching from Supabase fails, try to get from cache
      return cachedSchoolId;
    }
  }

  // Fetch users by role (e.g., 'Teacher', 'Parent') for a specific school
  Future<List<app_user.User>> getUsersByRole(UserRole role, int schoolId, {bool forceRefresh = false}) async {
    try {
      List<Map<String, dynamic>> response;
      if (role == UserRole.Teacher) {
        // If fetching teachers, also include users with 'Admin' role
        response = await _supabaseClient
            .from('users')
            .select()
            .eq('school_id', schoolId)
            .or('role.eq.${UserRole.Teacher.name},role.eq.${UserRole.Admin.name}')
            .order('created_at', ascending: false);
      } else {
        response = await _supabaseClient
            .from('users')
            .select()
            .eq('role', role.name)
            .eq('school_id', schoolId)
            .order('created_at', ascending: false);
      }

      return response.map((userData) => app_user.User.fromJson(userData)).toList();
    } catch (e) {
      logger.e('Error fetching users by role: $e');
      return [];
    }
  }

  // Fetch staff users (Admin and Teacher roles) for a specific school
  Future<List<app_user.User>> getStaffBySchool(int schoolId) async {
    try {
      final response = await _supabaseClient
          .from('users')
          .select()
          .eq('school_id', schoolId)
          .or('role.eq.${UserRole.Admin.name},role.eq.${UserRole.Teacher.name}');

      return response.map((userData) => app_user.User.fromJson(userData)).toList();
    } catch (e) {
      logger.e('Error fetching staff by school: $e');
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

  Future<void> registerSchoolAndAdmin({
    required String email,
    required String password,
    required String fullName,
    required String schoolName,
    String? schoolLogoUrl,
  }) async {
    try {
      final response = await _supabaseClient.functions.invoke(
        'create-user-admin',
        body: {
          'email': email,
          'password': password,
          'role': 'Admin',
          'full_name': fullName,
          'school_name': schoolName,
          'school_logo_url': schoolLogoUrl,
        },
      );

      if (response.data != null && response.data['error'] != null) {
        throw Exception('Failed to register: ${response.data['error']}');
      }
    } catch (e) {
      logger.e('Error during school and admin registration: $e');
      throw Exception('An error occurred during registration.');
    }
  }

  Future<app_user.User?> createUserViaEdgeFunction({
    required String email,
    required String password,
    required String role,
    required int schoolId,
    required String schoolName,
    String? fullName,
    String? profilePhotoUrl,
  }) async {
    try {
      final response = await _supabaseClient.functions.invoke(
        'create-user-admin',
        body: {
          'email': email,
          'password': password,
          'role': role,
          'school_id': schoolId,
          'school_name': schoolName,
          'full_name': fullName,
          'profile_photo_url': profilePhotoUrl,
        },
      );

      if (response.data == null) {
        logger.e('Edge Function "create-user-admin" returned no data or failed to invoke.');
        throw Exception('Failed to create user: Edge function returned no data.');
      }

      final responseData = response.data as Map<String, dynamic>;
      if (responseData.containsKey('error')) {
        logger.e('Error from create-user-admin Edge Function: ${responseData['error']}');
        throw Exception('Failed to create user: ${responseData['error']}');
      }
      
      return app_user.User.fromJson(responseData);
    } catch (e) {
      logger.e('Exception calling create-user-admin function: $e');
      throw Exception('Failed to create user due to an unexpected error: ${e.toString()}');
    }
  }

  Future<app_user.User?> createStaffByAdmin({
    required String email,
    required String password,
    required String role,
    required int schoolId,
    String? fullName,
    String? profilePhotoUrl,
    String? phoneNumber,
    double? salary,
  }) async {
    try {
      final response = await _supabaseClient.functions.invoke(
        'create-staff-by-admin',
        body: {
          'email': email,
          'password': password,
          'role': role,
          'school_id': schoolId,
          'full_name': fullName,
          'profile_photo_url': profilePhotoUrl,
          'phone_number_1': phoneNumber,
          'salary': salary,
        },
      );

      if (response.data == null) {
        logger.e('Edge Function "create-staff-by-admin" returned no data.');
        throw Exception('Failed to create staff: Edge function returned no data.');
      }

      final responseData = response.data as Map<String, dynamic>;
      if (responseData.containsKey('error')) {
        logger.e('Error from create-staff-by-admin Edge Function: ${responseData['error']}');
        throw Exception('Failed to create staff: ${responseData['error']}');
      }
      
      return app_user.User.fromJson(responseData['user']);
    } catch (e) {
      logger.e('Exception calling create-staff-by-admin function: $e');
      throw Exception('Failed to create staff: ${e.toString()}');
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
        'phone_number_1': user.phoneNumber1,
        'phone_number_2': user.phoneNumber2,
        'salary': user.salary,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', user.id);
      return true;
    } catch (e) {
      logger.e('Error updating user: $e');
      return false;
    }
  }

  // Delete a user (by Admin)
  Future<bool> deleteUser(String userId) async {
    try {
      final response = await _supabaseClient.functions.invoke(
        'delete-user-by-admin',
        body: {'user_id': userId},
      );

      if (response.data == null) {
        logger.e('Edge Function "delete-user-by-admin" returned no data.');
        return false;
      }

      final responseData = response.data as Map<String, dynamic>;
      if (responseData.containsKey('error')) {
        logger.e('Error from delete-user-by-admin Edge Function: ${responseData['error']}');
        return false;
      }

      logger.i("User $userId deleted successfully.");
      return true;
    } catch (e) {
      logger.e('Error deleting user: $e');
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
      logger.e('Error uploading profile photo: $e');
    }
    return null;
  }
}
