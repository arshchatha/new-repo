import 'package:flutter/material.dart';
import 'package:lboard/providers/provider.dart';
import '/core/services/auth_service.dart';
import '/core/config/app_routes.dart';
import '/models/user_role.dart';
import '/widgets/posting_management_dialog.dart';
import 'widgets/logo_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';
  UserRole? _selectedRole;

  void _login() async {
    if (_selectedRole == null) {
      setState(() {
        _errorMessage = 'Please select a role';
      });
      return;
    }
    
    // Get providers before async operations
    final authService = Provider.of<AuthService>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final loadProvider = Provider.of<LoadProvider>(context, listen: false);
    
    final success = await authService.login(
      _usernameController.text.trim(),
      _passwordController.text.trim(),
      _selectedRole!,
    );
    
    if (!mounted) return; // ensures context is still valid

    if (success) {
      // Set the user in AuthProvider
      authProvider.user = authService.currentUser;

      // Fetch loads to check for existing posts
      await loadProvider.fetchLoads();
      if (!mounted) return;
      
      final userPosts = loadProvider.getMyPostedLoads(authService.currentUser!);
      
      if (userPosts.isNotEmpty && mounted) {
        // Show posting management dialog
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return PostingManagementDialog(
              user: authService.currentUser!,
              userPosts: userPosts,
              onDeletePosts: (postIds) async {
                for (final postId in postIds) {
                  await loadProvider.deleteLoad(postId);
                }
              },
            );
          },
        );
        
        if (!mounted) return;
      }

      // Navigate to appropriate dashboard
      if (!mounted) return;
      
      if (_selectedRole == UserRole.broker) {
        Navigator.pushReplacementNamed(context, AppRoutes.brokerDashboard);
      } else if (_selectedRole == UserRole.carrier) {
        Navigator.pushReplacementNamed(context, AppRoutes.carrierDashboard);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.splash);
      }
    } else {
      if (mounted) {
        setState(() {
          _errorMessage = 'Invalid username or password';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    SizedBox(
                      width: 159,
                      height: 159,
                      child: LogoWidget(
                        height: 150,
                        width: 150,
                        productNameFontSize: 42,
                        showProductName: false,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Isovia Load Board',
                      style: TextStyle(
                        fontSize: 49,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              Column(
                children: [
                  ListTile(
                    title: const Text('Broker'),
                    leading: Radio<UserRole>(
                      value: UserRole.broker,
                      groupValue: _selectedRole,
                      onChanged: (UserRole? value) {
                        setState(() {
                          _selectedRole = value;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text('Carrier'),
                    leading: Radio<UserRole>(
                      value: UserRole.carrier,
                      groupValue: _selectedRole,
                      onChanged: (UserRole? value) {
                        setState(() {
                          _selectedRole = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: _login,
                child: const Text('Login'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/forgetPassword');
                },
                child: const Text('Forget Password?'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text('Register New User'),
              ),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
