import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edu_sync/main.dart'; // Assuming MyApp is in main.dart
import 'package:edu_sync/widgets/language_toggle.dart';
import 'package:edu_sync/widgets/profile_photo_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:edu_sync/screens/splash_screen.dart'; // Import SplashScreen

// Mock SupabaseClient for testing
class MockSupabaseClient extends SupabaseClient {
  MockSupabaseClient(super.supabaseUrl, super.supabaseKey);

  @override
  GoTrueClient get auth => MockGoTrueClient(); // Use the mock GoTrueClient from auth_service_test
}

class MockGoTrueClient extends GoTrueClient {
 // Basic mock, expand as needed for tests
  @override
  User? get currentUser => User(
        id: 'mock_user_id',
        appMetadata: {},
        userMetadata: {'role': 'Admin'},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
      );
}


void main() {
  // It's good practice to ensure Supabase is initialized for tests that might involve it,
  // even if indirectly through widgets that use services depending on Supabase.
  setUpAll(() async {
    // Initialize Supabase with a mock client for all widget tests in this file.
    // This prevents errors if any widget tries to access Supabase.instance.client.
    // Use placeholder URL and key as they won't be used for actual network requests.
    await Supabase.initialize(
      url: 'https://mock.supabase.co',
      anonKey: 'mockanonkey',
      // If your tests need a specific SupabaseClient behavior, provide a mock here.
      // For general widget tests not focusing on Supabase interactions, this basic init is often enough.
    );
  });

  testWidgets('MyApp builds and shows default home page', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that MyHomePage is shown (or whatever your initial screen is).
    // This test is very basic and assumes MyHomePage is part of your initial UI.
    // You might need to adjust this depending on your app's routing and initial state.
    expect(find.byType(SplashScreen), findsOneWidget); // Check for SplashScreen
    // expect(find.text('EduSync Myanmar'), findsOneWidget); // Check for SplashScreen title (optional)
  });

  testWidgets('LanguageToggle widget toggles language text', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: LanguageToggle())));

    // Initial state
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Myanmar'), findsNothing);

    // Tap to toggle
    await tester.tap(find.byType(TextButton));
    await tester.pump();

    // After toggle
    expect(find.text('English'), findsNothing);
    expect(find.text('Myanmar'), findsOneWidget);

    // Tap again to toggle back
    await tester.tap(find.byType(TextButton));
    await tester.pump();

    // Back to initial state
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Myanmar'), findsNothing);
  });

  testWidgets('ProfilePhotoView displays an image', (WidgetTester tester) async {
    const String testImageUrl = 'https://via.placeholder.com/150'; // Use a placeholder image URL
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: ProfilePhotoView(profilePhotoUrl: testImageUrl))));

    // Verify that CircleAvatar is present
    expect(find.byType(CircleAvatar), findsOneWidget);

    // More specific checks could involve verifying the NetworkImage,
    // but that might require more complex mocking of image loading.
    // For a basic test, finding the CircleAvatar is a good start.
  });

  // Example of a more complex test that might involve navigation or state,
  // which would require setting up mock navigation, providers, etc.
  // testWidgets('AdminPanelScreen shows navigation options', (WidgetTester tester) async {
  //   // This test would require a MaterialApp wrapper and potentially mock navigation.
  //   // await tester.pumpWidget(MaterialApp(home: AdminPanelScreen()));
  //   // expect(find.text('School Registration'), findsOneWidget);
  //   // ... more assertions for other ListTiles
  // });
}
