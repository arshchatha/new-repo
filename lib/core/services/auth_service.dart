import 'package:flutter/foundation.dart';
import '../core/database/database_helper.dart';
import '../../models/user.dart';
import '../../models/user_role.dart';

class AuthService with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  User? _currentUser;

  User? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;

  /// Check authentication status
  Future<bool> checkAuthentication() async {
    // For now, just return false. In a real app, you might check stored tokens
    return false;
  }

  /// Login using database
  Future<bool> login(String username, String password, UserRole role) async {
    // Assuming username is unique identifier for login
    final user = await _dbHelper.getUser(username);
    if (user != null && user.role == role.name && user.password == password) {
      _currentUser = user;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Register a new user using database
  Future<bool> register(String username, String password, UserRole role) async {
    final existingUser = await _dbHelper.getUser(username);
    if (existingUser != null) {
      return false; // registration failed due to duplicate username
    }
    final newUser = User(
      id: username,
      name: username,
      role: role.name,
      password: password,
      isLoggedIn: false,
      email: '',
      phoneNumber: '',
      companyName: '',
      companyAddress: '',
      usDotMcNumber: '',
      equipment: const [],
      lanePreferences: const [], loadPosts: [],
    );
    await _dbHelper.insertUser(newUser);
    notifyListeners();
    return true;
  }

  /// Register a new user with extended information
  Future<bool> registerExtended({
    required String username,
    required String password,
    required UserRole role,
    String? usDotMcNumber,
    String? firstName,
    String? lastName,
    String? addressLine1,
    String? addressLine2,
    String? country,
    String? stateProvince,
    String? city,
    String? postalZipCode,
    String? companyName,
    String? website,
    String? portOfEntry,
    String? currency,
    String? factoringCompany,
    String? paymentMethod,
    String? account,
    String? syncToQB,
    String? remarks,
    String? phoneNumber,
    String? phoneExt,
    String? altPhoneNumber,
    String? altPhoneExt,
    String? faxNumber,
    String? email,
    String? referenceNumber,
    String? type,
    String? expenseType, required String name, required String companyAddress, required String roleString,
  }) async {
    final existingUser = await _dbHelper.getUser(username);
    if (existingUser != null) {
      return false; // registration failed due to duplicate username
    }
    
    final newUser = User(
      id: username,
      name: '$firstName $lastName'.trim(),
      role: role.name,
      password: password,
      isLoggedIn: false,
      email: email ?? '',
      phoneNumber: phoneNumber ?? '',
      companyName: companyName ?? '',
      companyAddress: companyAddress,
      usDotMcNumber: usDotMcNumber ?? '',
      equipment: const [],
      lanePreferences: const [], loadPosts: [],
    );
    
    await _dbHelper.insertUser(newUser);
    notifyListeners();
    return true;
  }

  /// Logout
  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
