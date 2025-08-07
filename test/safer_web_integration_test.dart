import 'package:flutter_test/flutter_test.dart';
import 'package:lboard/services/safer_web_api_service.dart';
import 'package:lboard/providers/safer_web_provider.dart';
import 'package:lboard/models/safer_web_snapshot.dart';

void main() {
  group('SaferWeb Integration Tests', () {
    late SaferWebApiService service;
    late SaferWebProvider provider;

    setUp(() {
      service = SaferWebApiService();
      provider = SaferWebProvider();
    });

    group('SaferWebApiService', () {
      test('validates USDOT numbers correctly', () {
        expect(service.isValidIdentifier('123456'), isTrue);
        expect(service.isValidIdentifier('12345678'), isTrue);
        expect(service.isValidIdentifier('123456789'), isFalse);
        expect(service.isValidIdentifier('ABC123'), isFalse);
        expect(service.isValidIdentifier(''), isFalse);
      });

      test('validates MC numbers correctly', () {
        expect(service.isValidIdentifier('MC123456'), isTrue);
        expect(service.isValidIdentifier('MC12345'), isTrue);
        expect(service.isValidIdentifier('mc123456'), isTrue); // case insensitive
        expect(service.isValidIdentifier('XX123456'), isFalse);
        expect(service.isValidIdentifier('MC'), isFalse);
      });

      test('validates MX numbers correctly', () {
        expect(service.isValidIdentifier('MX123456'), isTrue);
        expect(service.isValidIdentifier('mx123456'), isTrue);
        expect(service.isValidIdentifier('MX'), isFalse);
      });

      test('validates FF numbers correctly', () {
        expect(service.isValidIdentifier('FF123456'), isTrue);
        expect(service.isValidIdentifier('ff123456'), isTrue);
        expect(service.isValidIdentifier('FF'), isFalse);
      });

      test('identifies USDOT type correctly', () {
        expect(service.getIdentifierType('123456'), equals('USDOT'));
        expect(service.getIdentifierType('12345678'), equals('USDOT'));
      });

      test('identifies MC type correctly', () {
        expect(service.getIdentifierType('MC123456'), equals('MC'));
        expect(service.getIdentifierType('mc123456'), equals('MC'));
      });

      test('identifies MX type correctly', () {
        expect(service.getIdentifierType('MX123456'), equals('MX'));
        expect(service.getIdentifierType('mx123456'), equals('MX'));
      });

      test('identifies FF type correctly', () {
        expect(service.getIdentifierType('FF123456'), equals('FF'));
        expect(service.getIdentifierType('ff123456'), equals('FF'));
      });

      test('identifies unknown type correctly', () {
        expect(service.getIdentifierType('XX123456'), equals('UNKNOWN'));
        expect(service.getIdentifierType('ABC'), equals('UNKNOWN'));
        expect(service.getIdentifierType(''), equals('UNKNOWN'));
      });

      // Live API test (commented out to avoid hitting API during regular tests)
      /*
      test('fetches real data from API', () async {
        // Test with a known USDOT number
        final result = await service.fetchSnapshot('2121685');
        expect(result, isNotNull);
        expect(result?.legalName, isNotEmpty);
        expect(result?.status, isNotEmpty);
      }, timeout: const Timeout(Duration(seconds: 30)));
      */
    });

    group('SaferWebProvider', () {
      test('initializes with empty state', () {
        expect(provider.isLoading('123456'), isFalse);
        expect(provider.getError('123456'), isNull);
        expect(provider.getSnapshot('123456'), isNull);
      });

      test('validates identifiers correctly', () {
        expect(provider.isValidIdentifier('123456'), isTrue);
        expect(provider.isValidIdentifier('MC123456'), isTrue);
        expect(provider.isValidIdentifier('invalid'), isFalse);
      });

      test('gets identifier type correctly', () {
        expect(provider.getIdentifierType('123456'), equals('USDOT'));
        expect(provider.getIdentifierType('MC123456'), equals('MC'));
        expect(provider.getIdentifierType('MX123456'), equals('MX'));
        expect(provider.getIdentifierType('FF123456'), equals('FF'));
      });

      test('clears cache correctly', () {
        const identifier = '123456';
        
        // Clear specific cache
        provider.clearCache(identifier);
        expect(provider.getSnapshot(identifier), isNull);
        expect(provider.isLoading(identifier), isFalse);
        expect(provider.getError(identifier), isNull);

        // Clear all cache
        provider.clearAllCache();
        expect(provider.getSnapshot(identifier), isNull);
        expect(provider.isLoading(identifier), isFalse);
        expect(provider.getError(identifier), isNull);
      });
    });

    group('SaferWebSnapshot Model', () {
      test('creates snapshot with required fields', () {
        final snapshot = SaferWebSnapshot(
          legalName: 'Test Company',
          entityType: 'CARRIER',
          status: 'ACTIVE',
          address: '123 Test St',
        );

        expect(snapshot.legalName, equals('Test Company'));
        expect(snapshot.entityType, equals('CARRIER'));
        expect(snapshot.status, equals('ACTIVE'));
        expect(snapshot.address, equals('123 Test St'));
      });

      test('creates snapshot with optional fields', () {
        final snapshot = SaferWebSnapshot(
          legalName: 'Test Company',
          entityType: 'CARRIER',
          status: 'ACTIVE',
          address: '123 Test St',
          powerUnits: 10,
          drivers: 15,
          inspectionSummary: {'total': 5, 'oos': 1},
          crashSummary: {'total': 2, 'fatal': 0},
        );

        expect(snapshot.powerUnits, equals(10));
        expect(snapshot.drivers, equals(15));
        expect(snapshot.inspectionSummary?['total'], equals(5));
        expect(snapshot.crashSummary?['total'], equals(2));
      });

      test('creates snapshot from JSON', () {
        final json = {
          'legalName': 'Test Company',
          'entityType': 'CARRIER',
          'status': 'ACTIVE',
          'address': '123 Test St',
          'powerUnits': 10,
          'drivers': 15,
        };

        final snapshot = SaferWebSnapshot.fromJson(json);

        expect(snapshot.legalName, equals('Test Company'));
        expect(snapshot.entityType, equals('CARRIER'));
        expect(snapshot.status, equals('ACTIVE'));
        expect(snapshot.address, equals('123 Test St'));
        expect(snapshot.powerUnits, equals(10));
        expect(snapshot.drivers, equals(15));
      });

      test('converts snapshot to JSON', () {
        final snapshot = SaferWebSnapshot(
          legalName: 'Test Company',
          entityType: 'CARRIER',
          status: 'ACTIVE',
          address: '123 Test St',
          powerUnits: 10,
          drivers: 15,
        );

        final json = snapshot.toJson();

        expect(json['legalName'], equals('Test Company'));
        expect(json['entityType'], equals('CARRIER'));
        expect(json['status'], equals('ACTIVE'));
        expect(json['address'], equals('123 Test St'));
        expect(json['powerUnits'], equals(10));
        expect(json['drivers'], equals(15));
      });
    });

    group('Edge Cases', () {
      test('handles empty and null inputs', () {
        expect(service.isValidIdentifier(''), isFalse);
        expect(service.isValidIdentifier('   '), isFalse);
        expect(service.getIdentifierType(''), equals('UNKNOWN'));
        expect(service.getIdentifierType('   '), equals('UNKNOWN'));
      });

      test('handles case sensitivity', () {
        expect(service.isValidIdentifier('mc123456'), isTrue);
        expect(service.isValidIdentifier('MC123456'), isTrue);
        expect(service.getIdentifierType('mc123456'), equals('MC'));
        expect(service.getIdentifierType('MC123456'), equals('MC'));
      });

      test('handles whitespace in identifiers', () {
        expect(service.isValidIdentifier(' 123456 '), isTrue);
        expect(service.isValidIdentifier(' MC123456 '), isTrue);
        expect(service.getIdentifierType(' 123456 '), equals('USDOT'));
        expect(service.getIdentifierType(' MC123456 '), equals('MC'));
      });

      test('handles boundary values for USDOT', () {
        expect(service.isValidIdentifier('1'), isTrue);
        expect(service.isValidIdentifier('12345678'), isTrue);
        expect(service.isValidIdentifier('123456789'), isFalse);
        expect(service.isValidIdentifier('0'), isFalse);
      });
    });
  });
}
