import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lboard/tabs/carrierprofile_tab.dart';
import 'package:lboard/models/user.dart';
import 'package:lboard/providers/auth_provider.dart';
import 'package:lboard/providers/theme_provider.dart';

void main() {
  group('CarrierProfile Integration Tests', () {
    late Widget testWidget;

    setUp(() {
      final User user = User(
        id: 'test_carrier',
        name: 'Test Carrier',
        email: 'test@example.com',
        phoneNumber: '123-456-7890',
        companyName: 'Test Company',
        companyAddress: '123 Test St',
        role: 'carrier',
        password: 'password123',
        usDotMcNumber: 'MC123456',
        distanceRadiusLimit: 250,
        equipment: const [],
        lanePreferences: const [],
        loadPosts: const [],
      );

      testWidget = MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>(
              create: (_) => AuthProvider()..setUser(user),
            ),
            ChangeNotifierProvider<ThemeProvider>(
              create: (_) => ThemeProvider(),
            ),
          ],
          child: const Scaffold(
            body: CarrierProfileTab(),
          ),
        ),
      );
    });

    testWidgets('Distance radius limit input validation', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      // Find the TextField for distance radius
      final Finder textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      // Test invalid input
      await tester.enterText(textField, '0');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter a valid distance between 1 and 500 miles'), findsOneWidget);

      // Test valid input
      await tester.enterText(textField, '300');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Distance radius updated successfully'), findsOneWidget);
    });

    testWidgets('Profile information display', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      // Verify user information is displayed
      expect(find.text('Test Carrier - Carrier'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('Test Company'), findsOneWidget);
      expect(find.text('123-456-7890'), findsOneWidget);
    });

    testWidgets('Theme toggle functionality', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      // Find and tap the dark mode switch
      final Finder darkModeSwitch = find.byType(SwitchListTile).at(2);
      await tester.tap(darkModeSwitch);
      await tester.pumpAndSettle();

      // Verify theme was updated by checking if the switch state changed
      final SwitchListTile switchTile = tester.widget<SwitchListTile>(darkModeSwitch);
      expect(switchTile.value, isTrue);
    });
  });
}
