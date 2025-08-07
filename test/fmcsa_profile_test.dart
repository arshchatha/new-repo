import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:lboard/models/user.dart';
import 'package:lboard/providers/auth_provider.dart';
import 'package:lboard/providers/safer_web_provider.dart';
import 'package:lboard/services/fmcsa_verification_service.dart' as fmcsa;
import 'package:lboard/screens/fmcsa_profile_screen.dart';
import 'package:lboard/models/safer_web_snapshot.dart';

class MockAuthProvider extends Mock implements AuthProvider {}
class MockSaferWebProvider extends Mock implements SaferWebProvider {}
class MockFmcsaVerificationService extends Mock implements fmcsa.FmcsaVerificationService {}

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
      isLoggedIn: true, loadPosts: [],
    );

    // Setup default mock behaviors
    when(mockAuthProvider.user).thenReturn(testUser);
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
          ChangeNotifierProvider<SaferWebProvider>.value(value: mockSaferWebProvider),
          Provider<fmcsa.FmcsaVerificationService>.value(value: mockVerificationService),
        ],
        child: const FmcsaProfileScreen(),
      ),
    );
  }

  group('FmcsaProfileScreen', () {
    testWidgets('displays user USDOT/MC number', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      expect(find.text('USDOT/MC Number: 12345'), findsOneWidget);
    });

    testWidgets('shows verification status', (WidgetTester tester) async {
      when(mockVerificationService.verifyAndUpdateUser(testUser))
          .thenAnswer((_) => Future.value(fmcsa.VerificationResult(
            success: true,
            message: 'Verification successful',
          )));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Verification successful'), findsOneWidget);
      expect(find.byIcon(Icons.verified), findsOneWidget);
    });

    testWidgets('shows loading indicator during verification', (WidgetTester tester) async {
      when(mockVerificationService.verifyAndUpdateUser(testUser))
          .thenAnswer((_) => Future.delayed(
            const Duration(seconds: 1),
            () => fmcsa.VerificationResult(
              success: true,
              message: 'Verification successful',
            ),
          ));

      await tester.pumpWidget(createTestWidget());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('handles verification failure', (WidgetTester tester) async {
      when(mockVerificationService.verifyAndUpdateUser(testUser))
          .thenThrow(Exception('Verification failed'));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Error loading FMCSA data: Exception: Verification failed'), findsOneWidget);
    });

    testWidgets('displays screenshot reminder', (WidgetTester tester) async {
      final nextScreenshot = DateTime.now().add(const Duration(days: 2));
      when(mockVerificationService.calculateNextScreenshotDate())
          .thenReturn(nextScreenshot);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Screenshot due in 2 days'), findsOneWidget);
      expect(find.byIcon(Icons.warning), findsOneWidget);
    });

    testWidgets('displays overdue screenshot warning', (WidgetTester tester) async {
      final overdueDate = DateTime.now().subtract(const Duration(days: 3));
      when(mockVerificationService.calculateNextScreenshotDate())
          .thenReturn(overdueDate);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Screenshot is overdue by 3 days!'), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('displays SaferWeb data', (WidgetTester tester) async {
      final snapshot = SaferWebSnapshot(
        legalName: 'Test Company LLC',
        entityType: 'Carrier',
        status: 'ACTIVE',
        address: '123 Test Street, Test City, TS 12345',
        usdotNumber: '12345',
        mcNumber: 'MC-123456',
        powerUnits: 10,
        drivers: 5,
      );

      when(mockSaferWebProvider.getSnapshot('12345')).thenReturn(snapshot);
      when(mockSaferWebProvider.isLoading('12345')).thenReturn(false);
      when(mockSaferWebProvider.getError('12345')).thenReturn(null);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Test Company LLC'), findsOneWidget);
      expect(find.text('ACTIVE'), findsOneWidget);
    });

    testWidgets('handles SaferWeb data loading error', (WidgetTester tester) async {
      when(mockSaferWebProvider.getSnapshot('12345')).thenReturn(null);
      when(mockSaferWebProvider.isLoading('12345')).thenReturn(false);
      when(mockSaferWebProvider.getError('12345')).thenReturn('API Error');

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Error loading FMCSA data: API Error'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      // Test retry functionality
      await tester.tap(find.text('Retry'));
      verify(mockSaferWebProvider.fetchSnapshot('12345')).called(1);
    });

    testWidgets('navigates to SaferWeb search on screenshot button tap', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Take Screenshot'));
      await tester.pumpAndSettle();

      // Verify navigation (you'll need to implement navigation testing based on your routing setup)
      expect(find.byType(FmcsaProfileScreen), findsNothing);
    });
  });
}
