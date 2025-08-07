import 'package:logger/logger.dart';
import '../models/user.dart';
import '../models/safer_web_snapshot.dart';
import '../services/safer_web_api_service.dart';

class FmcsaVerificationService {
  final SaferWebApiService _saferWebService = SaferWebApiService();
  final Logger _logger = Logger();

  /// Verifies a user's FMCSA information and updates their profile
  Future<VerificationResult> verifyAndUpdateUser(User user) async {
    try {
      final identifier = _extractIdentifier(user);
      if (identifier.isEmpty) {
        return VerificationResult(
          success: false,
          message: 'No USDOT, MC, MX, or FF number found in user profile',
        );
      }

      _logger.i('Verifying FMCSA data for identifier: $identifier');

      final snapshot = await _saferWebService.fetchSnapshot(identifier);
      if (snapshot == null) {
        return VerificationResult(
          success: false,
          message: 'No FMCSA data found for identifier: $identifier',
        );
      }

      // Remove company name match check to allow user confirmation instead
      // final nameMatch = _checkNameMatch(user.companyName, snapshot.legalName);
      // if (!nameMatch) {
      //   return VerificationResult(
      //     success: false,
      //     message: 'Company name does not match FMCSA records',
      //     snapshot: snapshot,
      //   );
      // }

      // Check if status is active
      if (snapshot.status.toUpperCase() != 'ACTIVE') {
        return VerificationResult(
          success: false,
          message: 'FMCSA status is not active: ${snapshot.status}',
          snapshot: snapshot,
        );
      }

      return VerificationResult(
        success: true,
        message: 'FMCSA verification successful',
        snapshot: snapshot,
      );
    } catch (e) {
      _logger.e('Error during FMCSA verification: $e');
      return VerificationResult(
        success: false,
        message: 'Verification failed: $e',
      );
    }
  }

  /// Extracts the primary identifier from user data
  String _extractIdentifier(User user) {
    // Check usDotMcNumber field first
    if (user.usDotMcNumber.isNotEmpty) {
      return user.usDotMcNumber;
    }


    return '';
  }

  /// Checks if company names match with some tolerance for variations
  bool checkNameMatch(String userCompanyName, String fmcsaLegalName) {
    if (fmcsaLegalName.isEmpty) return false;
    if (userCompanyName.isEmpty) return true; // Allow match if user company name is empty

    // Normalize names for comparison
    final normalizedUser = _normalizeName(userCompanyName);
    final normalizedFmcsa = _normalizeName(fmcsaLegalName);

    // Exact match
    if (normalizedUser == normalizedFmcsa) return true;

    // Check if one contains the other
    if (normalizedUser.contains(normalizedFmcsa) || normalizedFmcsa.contains(normalizedUser)) {
      return true;
    }

    // Check similarity (simple word matching)
    final userWords = normalizedUser.split(' ').where((w) => w.length > 2).toSet();
    final fmcsaWords = normalizedFmcsa.split(' ').where((w) => w.length > 2).toSet();
    
    final commonWords = userWords.intersection(fmcsaWords);
    final totalWords = userWords.union(fmcsaWords);
    
    // If more than 60% of words match, consider it a match
    return commonWords.length / totalWords.length > 0.6;
  }

  /// Normalizes a company name for comparison
  String _normalizeName(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '') // Remove punctuation
        .replaceAll(RegExp(r'\s+'), ' ') // Normalize whitespace
        .replaceAll(' inc', '')
        .replaceAll(' llc', '')
        .replaceAll(' ltd', '')
        .replaceAll(' corp', '')
        .replaceAll(' company', '')
        .replaceAll(' co', '')
        .trim();
  }

  /// Creates an updated user with FMCSA data
  User updateUserWithFmcsaData(User user, SaferWebSnapshot snapshot) {
    return user.copyWith(
      companyName: snapshot.legalName.isNotEmpty ? snapshot.legalName : user.companyName,
      companyAddress: snapshot.address.isNotEmpty ? snapshot.address : user.companyAddress,
      // Add new fields through a custom method since copyWith doesn't have them yet
    );
  }

  /// Schedules the next biweekly screenshot
  DateTime calculateNextScreenshotDate([DateTime? lastDate]) {
    final base = lastDate ?? DateTime.now();
    return base.add(const Duration(days: 14));
  }

  /// Checks if a screenshot is due
  bool isScreenshotDue(DateTime? nextScreenshotDue) {
    if (nextScreenshotDue == null) return true;
    return DateTime.now().isAfter(nextScreenshotDue);
  }

  /// Gets verification status message
  String getVerificationStatusMessage(User user) {
    if (user.usDotMcNumber.isEmpty) {
      return 'No FMCSA identifier provided';
    }

    // This would need to be implemented with actual verification status
    // For now, return a placeholder
    return 'Verification pending';
  }
}

class VerificationResult {
  final bool success;
  final String message;
  final SaferWebSnapshot? snapshot;

  VerificationResult({
    required this.success,
    required this.message,
    this.snapshot,
  });
}
