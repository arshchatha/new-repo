import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../core/services/platform_database_service.dart';

class AuthProvider extends ChangeNotifier {
  final PlatformDatabaseService _dbService = PlatformDatabaseService.instance;
  User? _user;

  User? get user => _user;
  set user(User? value) {
    _user = value;
    notifyListeners();
  }

  bool get isLoggedIn => _user != null;
  String get userId => _user?.id ?? '';
  String get userName => _user?.name ?? '';
  String get userRole => _user?.role ?? '';
  bool get isBroker => _user?.role == 'broker';
  bool get isCarrier => _user?.role == 'carrier';
  bool get isAdmin => _user?.role == 'admin';
  String get userPassword => _user?.password ?? '';
  String get userEmail => _user?.email ?? '';
  bool get isAuthenticated => isLoggedIn;

  AuthProvider() {
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    // Initialize database service
    await _dbService.init();
  }

  Future<bool> login(String username, String role, {String password = ''}) async {
    try {
      // Check if user exists in database
      final existingUser = await _dbService.getUser(username);
      if (existingUser != null) {
        // In a real app, you would verify the password here
        _user = existingUser;
      } else {
        // Create new user if not exists
        _user = User(
          id: username,
          name: username,
          email: '${username.toLowerCase()}@example.com',
          phoneNumber: '',
          companyName: '',
          companyAddress: '',
          usDotMcNumber: '',
          password: password,
          role: role,
          isLoggedIn: true,
          equipment: const [],
          lanePreferences: const [], loadPosts: [],
        );
        await _dbService.insertUser(_user!);
      }
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error during login: $e');
      return false;
    }
  }

  Future<void> register(User user) async {
    try {
      // Check if user with same ID already exists
      final existingUser = await _dbService.getUser(user.id);
      if (existingUser != null) {
        throw Exception('User ID already exists');
      }

      // Insert new user
      await _dbService.insertUser(user);

      // Set as current user
      _user = user;
      notifyListeners();
    } catch (e) {
      debugPrint('Error during registration: $e');
      rethrow;
    }
  }

  void logout() {
    _user = null;
    notifyListeners();
  }

  Future<bool> checkAuthentication() async {
    if (_user != null) {
      // Verify user exists in database
      final dbUser = await _dbService.getUser(_user!.id);
      return dbUser != null;
    }
    return false;
  }

  static AuthProvider of(BuildContext context) {
    return Provider.of<AuthProvider>(context, listen: false);
  }

  Future<void> updateUser(User updatedUser) async {
    try {
      await _dbService.updateUser(updatedUser);
      _user = updatedUser;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating user: $e');
      rethrow;
    }
  }

  Future uploadProfileImage(File file) async {}

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }
}
