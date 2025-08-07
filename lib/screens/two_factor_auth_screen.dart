import 'package:flutter/material.dart';
import '../core/services/two_factor_auth_service.dart';

class TwoFactorAuthScreen extends StatefulWidget {
  final String username;
  final String method; // 'sms', 'email', 'authenticator'

  const TwoFactorAuthScreen({super.key, required this.username, required this.method});

  @override
  _TwoFactorAuthScreenState createState() => _TwoFactorAuthScreenState();
}

class _TwoFactorAuthScreenState extends State<TwoFactorAuthScreen> {
  final TextEditingController _codeController = TextEditingController();
  late TwoFactorAuthService _twoFactorAuthService;
  String? _generatedCode;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _twoFactorAuthService = TwoFactorAuthService();
    _sendCode();
  }

  Future<void> _sendCode() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    _generatedCode = _twoFactorAuthService.generateCode();

    bool sent = false;
    if (widget.method == 'sms') {
      String phoneNumber = 'user-phone-number'; // placeholder
      sent = await _twoFactorAuthService.sendCodeViaSMS(phoneNumber, _generatedCode!);
    } else if (widget.method == 'email') {
      String email = 'user-email@example.com'; // placeholder
      sent = await _twoFactorAuthService.sendCodeViaEmail(email, _generatedCode!);
    } else if (widget.method == 'authenticator') {
      // For authenticator app, code is generated on user device, so no sending needed
      sent = true;
    }

    if (!sent) {
      setState(() {
        _errorMessage = 'Failed to send code. Please try again.';
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _verifyCode() {
    final inputCode = _codeController.text.trim();
    if (_twoFactorAuthService.verifyCode(inputCode, _generatedCode ?? '')) {
      // Verification success, proceed to login or next step
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _errorMessage = 'Invalid code. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Two-Factor Authentication'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('A verification code has been sent via ${widget.method.toUpperCase()}.'),
            const SizedBox(height: 16),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter verification code',
                border: OutlineInputBorder(),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
            const SizedBox(height: 16),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _verifyCode,
                    child: const Text('Verify'),
                  ),
            TextButton(
              onPressed: _sendCode,
              child: const Text('Resend Code'),
            ),
          ],
        ),
      ),
    );
  }
}
