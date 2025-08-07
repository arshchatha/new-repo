import 'package:flutter_test/flutter_test.dart';
import 'package:lboard/models/user.dart';

void main() {
  group('Distance Radius Limit Tests', () {
    test('User model should handle distanceRadiusLimit field', () {
      final user = User(
        id: 'test_carrier',
        name: 'Test Carrier',
        email: 'test@example.com',
        phoneNumber: '123-456-7890',
        companyName: 'Test Company',
        companyAddress: '123 Test St',
        role: 'carrier',
        password: 'password123',
        usDotMcNumber: 'MC123456',
        distanceRadiusLimit: 250, loadPosts: [],
      );

      expect(user.distanceRadiusLimit, equals(250));
    });

    test('User copyWith should update distanceRadiusLimit', () {
      final user = User(
        id: 'test_carrier',
        name: 'Test Carrier',
        email: 'test@example.com',
        phoneNumber: '123-456-7890',
        companyName: 'Test Company',
        companyAddress: '123 Test St',
        role: 'carrier',
        password: 'password123',
        usDotMcNumber: 'MC123456', loadPosts: [],
      );

      final updatedUser = user.copyWith(distanceRadiusLimit: 300);
      expect(updatedUser.distanceRadiusLimit, equals(300));
      expect(user.distanceRadiusLimit, isNull);
    });

    test('User toJson and fromJson should handle distanceRadiusLimit', () {
      final user = User(
        id: 'test_carrier',
        name: 'Test Carrier',
        email: 'test@example.com',
        phoneNumber: '123-456-7890',
        companyName: 'Test Company',
        companyAddress: '123 Test St',
        role: 'carrier',
        password: 'password123',
        usDotMcNumber: 'MC123456',
        distanceRadiusLimit: 400, loadPosts: [],
      );

      final json = user.toJson();
      expect(json['distanceRadiusLimit'], equals(400));

      final userFromJson = User.fromJson(json);
      expect(userFromJson.distanceRadiusLimit, equals(400));
    });

    test('User toMap and fromMap should handle distanceRadiusLimit', () {
      final user = User(
        id: 'test_carrier',
        name: 'Test Carrier',
        email: 'test@example.com',
        phoneNumber: '123-456-7890',
        companyName: 'Test Company',
        companyAddress: '123 Test St',
        role: 'carrier',
        password: 'password123',
        usDotMcNumber: 'MC123456',
        distanceRadiusLimit: 500, loadPosts: [],
      );

      final map = user.toMap();
      expect(map['distanceRadiusLimit'], equals(500));

      final userFromMap = User.fromMap(map);
      expect(userFromMap.distanceRadiusLimit, equals(500));
    });

    test('Distance radius limit should be nullable', () {
      final user = User(
        id: 'test_carrier',
        name: 'Test Carrier',
        email: 'test@example.com',
        phoneNumber: '123-456-7890',
        companyName: 'Test Company',
        companyAddress: '123 Test St',
        role: 'carrier',
        password: 'password123',
        usDotMcNumber: 'MC123456', loadPosts: [],
        // No distance radius limit set
      );

      expect(user.distanceRadiusLimit, isNull);
    });
  });
}
