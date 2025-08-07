import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:lboard/models/user.dart';
import 'package:lboard/providers/auth_provider.dart';
import 'package:lboard/providers/safer_web_provider.dart';
import 'package:lboard/services/fmcsa_verification_service.dart' as fmcsa;
import 'package:lboard/screens/enhanced_register_screen.dart';
import 'package:lboard/screens/fmcsa_profile_screen.dart';
import 'package:lboard/models/safer_web_snapshot.dart';
import 'package:lboard/core/config/app_routes.dart';

// Create mock classes with explicit type parameters
class MockAuthProvider extends Mock implements AuthProvider {
  @override
  Future<void> register(User user) async => super.noSuchMethod(
        Invocation.method(#register, [user]),
        returnValue: Future<void>.value(),
      );
}

class MockSaferWebProvider extends Mock implements SaferWebProvider {}

class MockFmcsaVerificationService extends Mock implements fmcsa.FmcsaVerificationService {
  @override
  Future<fmcsa.VerificationResult> verifyAndUpdateUser(User user) async => super.noSuchMethod(
        Invocation.method(#verifyAndUpdateUser, [user]),
        returnValue: Future.value(fmcsa.VerificationResult(
          success: true,
          message: 'Verification successful',
        )),
      );
}

void main() {
  late MockAuthProvider mockAuthProvider;
  late MockSaferWebProvider mockSaferWebProvider;
  late MockFmcsaVerificationService mockVerificationService;
  late User testUser;

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    mockSaferWebProvider = MockSaferWebProvider();
    mockVerificationService = MockFmcsaVerificationService();

    testUser = User(
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
  });

  Widget createTestApp() {
    return MaterialApp(
      routes: {
        '/': (context) => const EnhancedRegisterScreen(),
        AppRoutes.fmcsaProfile: (context) => const FmcsaProfileScreen(),
      },
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
          ChangeNotifierProvider<SaferWebProvider>.value(value: mockSaferWebProvider),
          Provider<fmcsa.FmcsaVerificationService>.value(value: mockVerificationService),
        ],
        child: const EnhancedRegisterScreen(),
      ),
    );
  }

  group('FMCSA Integration Flow', () {
    testWidgets('complete registration and verification flow', (WidgetTester tester) async {
      final saferWebSnapshot = SaferWebSnapshot(
        legalName: 'Test Company LLC',
        entityType: 'Carrier',
        status: 'ACTIVE',
        address: '123 Test Street, Test City, TS 12345',
        usdotNumber: '12345',
        mcNumber: 'MC-123456',
        powerUnits: 10,
        drivers: 5,
      );

      // Setup mock behaviors with typed matchers
      when(mockVerificationService.verifyAndUpdateUser(testUser))
          .thenAnswer((_) => Future.value(fmcsa.VerificationResult(
            success: true,
            message: 'Verification successful',
          )));

      when(mockAuthProvider.register(testUser)).thenAnswer((_) => Future.value());
      when(mockSaferWebProvider.getSnapshot('12345')).thenReturn(saferWebSnapshot);
      when(mockSaferWebProvider.isLoading('12345')).thenReturn(false);
      when(mockSaferWebProvider.getError('12345')).thenReturn(null);

      // Start test
      await tester.pumpWidget(createTestApp());

      // Fill registration form
      await tester.enterText(find.byKey(const Key('name_field')), testUser.name);
      await tester.enterText(find.byKey(const Key('email_field')), testUser.email);
      await tester.enterText(find.byKey(const Key('password_field')), testUser.password);
      await tester.enterText(find.byKey(const Key('phone_field')), testUser.phoneNumber);
      await tester.enterText(find.byKey(const Key('company_name_field')), testUser.companyName);
      await tester.enterText(find.byKey(const Key('usdot_mc_field')), testUser.usDotMcNumber);

      // Submit form
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      // Verify FMCSA verification was called with the test user
      verify(mockVerificationService.verifyAndUpdateUser(testUser)).called(1);

      // Verify registration was called with the test user
      verify(mockAuthProvider.register(testUser)).called(1);
    });

    testWidgets('handles verification failure during registration', (WidgetTester tester) async {
      // Setup mock behaviors for failure case with typed matcher
      when(mockVerificationService.verifyAndUpdateUser(testUser))
          .thenThrow(Exception('Invalid USDOT number'));

      await tester.pumpWidget(createTestApp());

      // Fill form with test user data
      await tester.enterText(find.byKey(const Key('name_field')), testUser.name);
      await tester.enterText(find.byKey(const Key('email_field')), testUser.email);
      await tester.enterText(find.byKey(const Key('password_field')), testUser.password);
      await tester.enterText(find.byKey(const Key('phone_field')), testUser.phoneNumber);
      await tester.enterText(find.byKey(const Key('company_name_field')), testUser.companyName);
      await tester.enterText(find.byKey(const Key('usdot_mc_field')), testUser.usDotMcNumber);
      
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      // Verify error message is shown
      expect(find.text('Verification error: Exception: Invalid USDOT number'), findsOneWidget);

      // Verify registration was not called
      verifyNever(mockAuthProvider.register(testUser));
    });

    testWidgets('handles network errors during verification', (WidgetTester tester) async {
      // Setup mock behaviors for network error with typed matcher
      when(mockVerificationService.verifyAndUpdateUser(testUser))
          .thenThrow(Exception('Network error'));

      await tester.pumpWidget(createTestApp());

      // Fill form with test user data
      await tester.enterText(find.byKey(const Key('name_field')), testUser.name);
      await tester.enterText(find.byKey(const Key('email_field')), testUser.email);
      await tester.enterText(find.byKey(const Key('password_field')), testUser.password);
      await tester.enterText(find.byKey(const Key('phone_field')), testUser.phoneNumber);
      await tester.enterText(find.byKey(const Key('company_name_field')), testUser.companyName);
      await tester.enterText(find.byKey(const Key('usdot_mc_field')), testUser.usDotMcNumber);
      
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      // Verify error message is shown
      expect(find.text('Verification error: Exception: Network error'), findsOneWidget);

      // Verify registration was not called
      verifyNever(mockAuthProvider.register(testUser));
    });

    testWidgets('screenshot reminder system works correctly', (WidgetTester tester) async {
      when(mockAuthProvider.user).thenReturn(testUser);

      // Test overdue screenshot
      final overdueDate = DateTime.now().subtract(const Duration(days: 3));
      when(mockVerificationService.calculateNextScreenshotDate())
          .thenReturn(overdueDate);
      when(mockVerificationService.isScreenshotDue(overdueDate))
          .thenReturn(true);

      await tester.pumpWidget(MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
            ChangeNotifierProvider<SaferWebProvider>.value(value: mockSaferWebProvider),
            Provider<fmcsa.FmcsaVerificationService>.value(value: mockVerificationService),
          ],
          child: const FmcsaProfileScreen(),
        ),
      ));

      await tester.pumpAndSettle();

      // Verify overdue warning is shown
      expect(find.byIcon(Icons.error), findsOneWidget);
      expect(find.textContaining('overdue'), findsOneWidget);

      // Test due soon screenshot
      final dueSoonDate = DateTime.now().add(const Duration(days: 2));
      when(mockVerificationService.calculateNextScreenshotDate())
          .thenReturn(dueSoonDate);
      when(mockVerificationService.isScreenshotDue(dueSoonDate))
          .thenReturn(false);

      await tester.pumpWidget(MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
            ChangeNotifierProvider<SaferWebProvider>.value(value: mockSaferWebProvider),
            Provider<fmcsa.FmcsaVerificationService>.value(value: mockVerificationService),
          ],
          child: const FmcsaProfileScreen(),
        ),
      ));

      await tester.pumpAndSettle();

      // Verify due soon warning is shown
      expect(find.byIcon(Icons.warning), findsOneWidget);
      expect(find.textContaining('due in'), findsOneWidget);
    });
  });
}
