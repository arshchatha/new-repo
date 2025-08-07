import 'dart:math';
import 'package:logging/logging.dart';

class TwoFactorAuthService {
  // Generate a 6-digit numeric code for 2FA
  String generateCode() {
    final random = Random.secure();
    final code = random.nextInt(900000) + 100000; // 100000 to 999999
    return code.toString();
  }

  // Simulate sending code via SMS
  Future<bool> sendCodeViaSMS(String phoneNumber, String code) async {
    Logger.root.info('Sending SMS to \$phoneNumber with code: \$code');
    await Future.delayed(Duration(seconds: 1));
    return true;
  }

  // Simulate sending code via Email
  Future<bool> sendCodeViaEmail(String email, String code) async {
    Logger.root.info('Sending Email to \$email with code: \$code');
    await Future.delayed(Duration(seconds: 1));
    return true;
  }

  // Simulate generating code for authenticator app (e.g., TOTP)
  String generateAuthenticatorCode() {
    // For simplicity, reuse generateCode
    return generateCode();
  }

  // Verify the provided code matches the expected code
  bool verifyCode(String inputCode, String expectedCode) {
    return inputCode == expectedCode;
  }
}
