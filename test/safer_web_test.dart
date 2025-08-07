import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lboard/screens/safer_web_search_screen.dart';
import 'package:lboard/widgets/safer_web_info_card.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:lboard/services/safer_web_api_service.dart';
import 'package:lboard/providers/safer_web_provider.dart';
import 'package:lboard/models/safer_web_snapshot.dart';
import 'package:provider/provider.dart';

@GenerateMocks([http.Client])
void main() {
  group('SaferWebApiService Tests', () {
    late MockClient mockClient;
    late SaferWebApiService service;

    setUp(() {
      mockClient = MockClient((request) async => http.Response('{}', 200));
      service = SaferWebApiService();
    });

    test('fetchSnapshot returns data for valid USDOT number', () async {
      const usdot = '123456';
      final response = {
        'legalName': 'Test Carrier Inc',
        'entityType': 'CARRIER',
        'status': 'ACTIVE',
        'address': '123 Test St, Test City, TS 12345',
        'powerUnits': 10,
        'drivers': 15,
      };

      when(mockClient.get(
        Uri.parse('https://saferwebapi.com/v2/usdot/snapshot/$usdot'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(response.toString(), 200));

      final result = await service.fetchSnapshot(usdot);
      expect(result, isNotNull);
      expect(result?.legalName, equals('Test Carrier Inc'));
      expect(result?.status, equals('ACTIVE'));
    });

    test('fetchSnapshot returns null for invalid USDOT number', () async {
      const usdot = '999999';
      when(mockClient.get(
        Uri.parse('https://saferwebapi.com/v2/usdot/snapshot/$usdot'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response('Not found', 404));

      final result = await service.fetchSnapshot(usdot);
      expect(result, isNull);
    });

    test('fetchSnapshot handles network error', () async {
      const usdot = '123456';
      when(mockClient.get(
        Uri.parse('https://saferwebapi.com/v2/usdot/snapshot/$usdot'),
        headers: anyNamed('headers'),
      )).thenThrow(Exception('Network error'));

      expect(() => service.fetchSnapshot(usdot), throwsException);
    });

    test('isValidIdentifier validates USDOT numbers correctly', () {
      expect(service.isValidIdentifier('123456'), isTrue);
      expect(service.isValidIdentifier('12345678'), isTrue);
      expect(service.isValidIdentifier('0'), isFalse);
      expect(service.isValidIdentifier('123456789'), isFalse);
      expect(service.isValidIdentifier('ABC123'), isFalse);
    });

    test('isValidIdentifier validates MC numbers correctly', () {
      expect(service.isValidIdentifier('MC123456'), isTrue);
      expect(service.isValidIdentifier('MC12345'), isTrue);
      expect(service.isValidIdentifier('MC1234567'), isFalse);
      expect(service.isValidIdentifier('XX123456'), isFalse);
    });

    test('getIdentifierType returns correct type', () {
      expect(service.getIdentifierType('123456'), equals('USDOT'));
      expect(service.getIdentifierType('MC123456'), equals('MC'));
      expect(service.getIdentifierType('MX123456'), equals('MX'));
      expect(service.getIdentifierType('FF123456'), equals('FF'));
      expect(service.getIdentifierType('XX123456'), equals('UNKNOWN'));
    });
  });

  group('SaferWebProvider Tests', () {
    late SaferWebProvider provider;
    late MockSaferWebApiService mockService;

    setUp(() {
      mockService = MockSaferWebApiService();
      provider = SaferWebProvider();
    });

    test('fetchSnapshot updates loading state correctly', () async {
      const usdot = '123456';
      final snapshot = SaferWebSnapshot(
        legalName: 'Test Carrier',
        entityType: 'CARRIER',
        status: 'ACTIVE',
        address: '123 Test St',
      );

      when(mockService.fetchSnapshot(usdot))
          .thenAnswer((_) async => snapshot);

      expect(provider.isLoading(usdot), isFalse);
      
      final future = provider.fetchSnapshot(usdot);
      expect(provider.isLoading(usdot), isTrue);
      
      await future;
      expect(provider.isLoading(usdot), isFalse);
      expect(provider.getSnapshot(usdot), equals(snapshot));
    });

    test('fetchSnapshot handles error correctly', () async {
      const usdot = '123456';
      when(mockService.fetchSnapshot(usdot))
          .thenThrow(Exception('Test error'));

      expect(provider.getError(usdot), isNull);
      
      await provider.fetchSnapshot(usdot);
      
      expect(provider.isLoading(usdot), isFalse);
      expect(provider.getError(usdot), isNotNull);
      expect(provider.getSnapshot(usdot), isNull);
    });

    test('cache works correctly', () async {
      const usdot = '123456';
      final snapshot = SaferWebSnapshot(
        legalName: 'Test Carrier',
        entityType: 'CARRIER',
        status: 'ACTIVE',
        address: '123 Test St',
      );

      when(mockService.fetchSnapshot(usdot))
          .thenAnswer((_) async => snapshot);

      // First fetch should call the service
      await provider.fetchSnapshot(usdot);
      verify(mockService.fetchSnapshot(usdot)).called(1);

      // Second fetch should use cache
      await provider.fetchSnapshot(usdot);
      verifyNoMoreInteractions(mockService);

      // After clearing cache, service should be called again
      provider.clearCache(usdot);
      await provider.fetchSnapshot(usdot);
      verify(mockService.fetchSnapshot(usdot)).called(1);
    });

    test('clearAllCache works correctly', () {
      const usdot1 = '123456';
      const usdot2 = '789012';
      
      provider.clearAllCache();
      
      expect(provider.getSnapshot(usdot1), isNull);
      expect(provider.getSnapshot(usdot2), isNull);
      expect(provider.isLoading(usdot1), isFalse);
      expect(provider.isLoading(usdot2), isFalse);
      expect(provider.getError(usdot1), isNull);
      expect(provider.getError(usdot2), isNull);
    });
  });

  group('Widget Tests', () {
    testWidgets('SaferWebInfoCard displays data correctly', (tester) async {
      const usdot = '123456';
      final snapshot = SaferWebSnapshot(
        legalName: 'Test Carrier Inc',
        entityType: 'CARRIER',
        status: 'ACTIVE',
        address: '123 Test St, Test City, TS 12345',
        powerUnits: 10,
        drivers: 15,
      );

      final provider = SaferWebProvider();
      when(provider.getSnapshot(usdot)).thenReturn(snapshot);
      when(provider.isLoading(usdot)).thenReturn(false);

      await tester.pumpWidget(
        MaterialApp(
          home: SaferWebInfoCard(identifier: usdot),
        ),
      );

      expect(find.text('Test Carrier Inc'), findsOneWidget);
      expect(find.text('CARRIER - 123456'), findsOneWidget);
      expect(find.text('123 Test St, Test City, TS 12345'), findsOneWidget);
      expect(find.text('Power Units: 10'), findsOneWidget);
      expect(find.text('Drivers: 15'), findsOneWidget);
    });


    testWidgets('SaferWebSearchScreen handles search correctly', (tester) async {
      final provider = SaferWebProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SaferWebProvider>(
            create: (_) => provider,
            child: SaferWebSearchScreen(),
          ),
        ),
      );

      // Enter search text
      await tester.enterText(
        find.byType(TextField),
        '123456',
      );

      // Tap search button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Verify loading indicator appears
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for search to complete
      await tester.pumpAndSettle();

      // Verify results are displayed
      expect(find.byType(SaferWebInfoCard), findsOneWidget);
    });
  });
}

class MockSaferWebApiService {
  void fetchSnapshot(String usdot) {}
}
