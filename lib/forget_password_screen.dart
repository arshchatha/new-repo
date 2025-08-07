import 'package:flutter/material.dart';
import '/core/config/app_routes.dart';


class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => ForgetPasswordScreenState();
}

class ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _emailController = TextEditingController();
  String _message = '';

  void _submit() async {
    // Simulate sending password reset email
    setState(() {
      _message = 'If an account with that email exists, a reset link has been sent.';
    });
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forget Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Send Reset Link'),
            ),
            if (_message.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(_message, style: const TextStyle(color: Colors.green)),
            ],
          ],
        ),
      ),
    );
  }
}