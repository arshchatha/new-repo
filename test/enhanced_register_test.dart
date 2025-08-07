import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:lboard/models/user.dart';
import 'package:lboard/providers/auth_provider.dart';
import 'package:lboard/services/fmcsa_verification_service.dart' as fmcsa;
import 'package:lboard/screens/enhanced_register_screen.dart';
import 'package:lboard/core/config/app_routes.dart';

class MockAuthProvider extends Mock implements AuthProvider {}
class MockFmcsaVerificationService extends Mock implements fmcsa.FmcsaVerificationService {}
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

// Create a mock MaterialPageRoute for verification
class MockRoute extends Mock implements MaterialPageRoute {}

void main() {
  late MockAuthProvider mockAuthProvider;
  late MockFmcsaVerificationService mockVerificationService;
  late MockNavigatorObserver mockNavigatorObserver;
  late MockRoute mockRoute;

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    mockVerificationService = MockFmcsaVerificationService();
    mockNavigatorObserver = MockNavigatorObserver();
    mockRoute = MockRoute();
  });

  User createTestUser() {
    return User(
      id: 'test-id',
      name: 'Test User',
      email: 'test@example.com',
      password: 'password123',
      phoneNumber: '1234567890',
      companyName: 'Test Company',
      companyAddress: '123 Test St',
      usDotMcNumber: '12345',
      role: 'carrier',
      isLoggedIn: false, loadPosts: [],
    );
  }

  Widget createTestWidget() {
    return MaterialApp(
      navigatorObservers: [mockNavigatorObserver],
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
          Provider<fmcsa.FmcsaVerificationService>.value(value: mockVerificationService),
        ],
        child: const EnhancedRegisterScreen(),
      ),
    );
  }

  group('EnhancedRegisterScreen', () {
    testWidgets('validates required fields', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Try to submit without filling any fields
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      // Verify error messages are shown
      expect(find.text('Name is required'), findsOneWidget);
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
      expect(find.text('Phone number is required'), findsOneWidget);
      expect(find.text('Company name is required'), findsOneWidget);
      expect(find.text('USDOT/MC number is required'), findsOneWidget);
    });

    testWidgets('validates email format', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter invalid email
      await tester.enterText(find.byKey(const Key('email_field')), 'invalid-email');
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('validates USDOT/MC number format', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter invalid USDOT/MC number
      await tester.enterText(find.byKey(const Key('usdot_mc_field')), 'abc');
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid USDOT/MC number'), findsOneWidget);
    });

    testWidgets('shows loading indicator during verification', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Fill in valid data
      await tester.enterText(find.byKey(const Key('name_field')), 'Test User');
      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.enterText(find.byKey(const Key('phone_field')), '1234567890');
      await tester.enterText(find.byKey(const Key('company_name_field')), 'Test Company');
      await tester.enterText(find.byKey(const Key('usdot_mc_field')), '12345');

      final testUser = createTestUser();

      // Mock verification in progress
      when(mockVerificationService.verifyAndUpdateUser(testUser))
          .thenAnswer((_) => Future.delayed(const Duration(seconds: 1)));

      // Submit form
      await tester.tap(find.text('Register'));
      await tester.pump();

      // Verify loading indicator is shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('handles verification success', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Fill in valid data
      await tester.enterText(find.byKey(const Key('name_field')), 'Test User');
      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.enterText(find.byKey(const Key('phone_field')), '1234567890');
      await tester.enterText(find.byKey(const Key('company_name_field')), 'Test Company');
      await tester.enterText(find.byKey(const Key('usdot_mc_field')), '12345');

      final testUser = createTestUser();

      // Mock successful verification
      when(mockVerificationService.verifyAndUpdateUser(testUser))
          .thenAnswer((_) => Future.value(fmcsa.VerificationResult(
            success: true,
            message: 'Verification successful',
          )));

      // Mock successful registration
      when(mockAuthProvider.register(testUser)).thenAnswer((_) => Future.value());

      // Mock route for navigation verification
      when(mockRoute.settings).thenReturn(const RouteSettings(name: AppRoutes.carrierDashboard));

      // Submit form
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      // Verify navigation to dashboard
      verify(mockNavigatorObserver.didPush(mockRoute, any));
    });

    testWidgets('handles verification failure', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Fill in valid data
      await tester.enterText(find.byKey(const Key('name_field')), 'Test User');
      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.enterText(find.byKey(const Key('phone_field')), '1234567890');
      await tester.enterText(find.byKey(const Key('company_name_field')), 'Test Company');
      await tester.enterText(find.byKey(const Key('usdot_mc_field')), '12345');

      final testUser = createTestUser();

      // Mock failed verification
      when(mockVerificationService.verifyAndUpdateUser(testUser))
          .thenThrow(Exception('Verification failed'));

      // Submit form
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      // Verify error message is shown
      expect(find.text('Verification error: Exception: Verification failed'), findsOneWidget);
    });

    testWidgets('handles network errors', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Fill in valid data
      await tester.enterText(find.byKey(const Key('name_field')), 'Test User');
      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.enterText(find.byKey(const Key('phone_field')), '1234567890');
      await tester.enterText(find.byKey(const Key('company_name_field')), 'Test Company');
      await tester.enterText(find.byKey(const Key('usdot_mc_field')), '12345');

      final testUser = createTestUser();

      // Mock network error
      when(mockVerificationService.verifyAndUpdateUser(testUser))
          .thenThrow(Exception('Network error'));

      // Submit form
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      // Verify error message is shown
      expect(find.text('Verification error: Exception: Network error'), findsOneWidget);
    });

    testWidgets('preserves state during screen rotation', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Fill in data
      await tester.enterText(find.byKey(const Key('name_field')), 'Test User');
      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');

      // Simulate screen rotation
      await tester.binding.setSurfaceSize(const Size(1018, 800));
      await tester.pumpAndSettle();

      // Verify data is preserved
      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
    });
  });
}
