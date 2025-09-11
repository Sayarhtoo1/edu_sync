import 'package:flutter_test/flutter_test.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'auth_service_test.mocks.dart';

@GenerateMocks([SupabaseClient, SharedPreferences, Connectivity, GoTrueClient])
void main() {
  late AuthService authService;
  late MockSupabaseClient mockSupabaseClient;
  late MockSharedPreferences mockSharedPreferences;
  late MockConnectivity mockConnectivity;
  late MockGoTrueClient mockGoTrueClient;

  setUp(() async {
    mockSupabaseClient = MockSupabaseClient();
    mockSharedPreferences = MockSharedPreferences();
    mockConnectivity = MockConnectivity();
    mockGoTrueClient = MockGoTrueClient();

    when(mockSupabaseClient.auth).thenReturn(mockGoTrueClient);

    authService = AuthService(
      supabaseClient: mockSupabaseClient,
      sharedPreferences: mockSharedPreferences,
      connectivity: mockConnectivity,
    );
  });

  group('AuthService', () {
    test('signUp creates a new user', () async {
      final authResponse = AuthResponse(
        session: Session(
          accessToken: 'mock_access_token',
          tokenType: 'bearer',
          user: User(
            id: 'mock_user_id',
            appMetadata: {},
            userMetadata: {'role': 'Admin'},
            aud: 'authenticated',
            createdAt: DateTime.now().toIso8601String(),
          ),
        ),
        user: User(
          id: 'mock_user_id',
          appMetadata: {},
          userMetadata: {'role': 'Admin'},
          aud: 'authenticated',
          createdAt: DateTime.now().toIso8601String(),
        ),
      );

      when(mockGoTrueClient.signUp(
        email: anyNamed('email'),
        password: anyNamed('password'),
        data: anyNamed('data'),
      )).thenAnswer((_) async => authResponse);

      final user = await authService.signUp('test@example.com', 'password', 'Admin');
      expect(user, isNotNull);
      expect(user!.id, 'mock_user_id');
      expect(user.userMetadata!['role'], 'Admin');
    });

    test('signIn authenticates an existing user', () async {
      final authResponse = AuthResponse(
        session: Session(
          accessToken: 'mock_access_token',
          tokenType: 'bearer',
          user: User(
            id: 'mock_user_id',
            appMetadata: {},
            userMetadata: {'role': 'Admin'},
            aud: 'authenticated',
            createdAt: DateTime.now().toIso8601String(),
          ),
        ),
        user: User(
          id: 'mock_user_id',
          appMetadata: {},
          userMetadata: {'role': 'Admin'},
          aud: 'authenticated',
          createdAt: DateTime.now().toIso8601String(),
        ),
      );

      when(mockGoTrueClient.signInWithPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => authResponse);

      final user = await authService.signIn('test@example.com', 'password');
      expect(user, isNotNull);
      expect(user!.id, 'mock_user_id');
    });

    test('signOut logs out the current user', () async {
      when(mockGoTrueClient.signOut()).thenAnswer((_) async => AuthResponse());
      when(mockSharedPreferences.remove(any)).thenAnswer((_) async => true);
      await authService.signOut();
      verify(mockGoTrueClient.signOut()).called(1);
    });

    test('getCurrentUser returns the current user', () {
      final mockUser = User(
        id: 'mock_user_id',
        appMetadata: {},
        userMetadata: {'role': 'Admin'},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
      );
      when(mockGoTrueClient.currentUser).thenReturn(mockUser);
      final user = authService.getCurrentUser();
      expect(user, isNotNull);
      expect(user!.id, 'mock_user_id');
    });

    test('getUserRole returns the role of the current user', () async {
      final mockUser = User(
        id: 'mock_user_id',
        appMetadata: {},
        userMetadata: {'role': 'Admin'},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
      );
      when(mockGoTrueClient.currentUser).thenReturn(mockUser);
      when(mockSharedPreferences.getString(any)).thenReturn('Admin');

      final role = await authService.getUserRole();
      expect(role, 'Admin');
    });
  });
}
