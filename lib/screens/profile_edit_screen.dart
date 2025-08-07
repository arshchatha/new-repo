import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../services/safer_web_api_service.dart';
import '../models/safer_web_snapshot.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  SaferWebSnapshot? _saferWebSnapshot;
  Timer? _autoUpdateTimer;

  // Form fields controllers
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _companyController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    _fullNameController = TextEditingController(text: user?.fullName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    _companyController = TextEditingController(text: user?.companyName ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');


    _loadSaferWebInfo();
    _startAutoUpdateTimer();
  }

  @override
  void dispose() {
    _autoUpdateTimer?.cancel();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _startAutoUpdateTimer() {
    // Auto update every 2 weeks
    _autoUpdateTimer = Timer.periodic(const Duration(days: 14), (timer) {
      _loadSaferWebInfo();
    });
  }

  Future<void> _loadSaferWebInfo() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      final snapshot = await SaferWebApiService.fetchSaferWebSnapshot(authProvider.user!.id);
      setState(() {
        _saferWebSnapshot = snapshot;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source, maxWidth: 600);
    if (pickedFile != null) {
      if (!mounted) return;
      setState(() {
        _imageFile = pickedFile;
      });
      // Upload image and update user profile picture
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final imageUrl = await authProvider.uploadProfileImage(File(pickedFile.path));
      if (imageUrl != null) {
        final updatedUser = authProvider.user?.copyWith(companyLogoUrl: imageUrl);
        if (updatedUser != null) {
          await authProvider.updateUser(updatedUser);
        }
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user == null) return;

    final updatedUser = user.copyWith(
      name: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      companyName: _companyController.text.trim(),
      address: _addressController.text.trim(),
    );


    await authProvider.updateUser(updatedUser);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: () => _showImageSourceActionSheet(context),
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: _imageFile != null
                      ? FileImage(File(_imageFile!.path))
                      : (Provider.of<AuthProvider>(context).user?.companyLogoUrl != null
                          ? NetworkImage(Provider.of<AuthProvider>(context).user!.companyLogoUrl!)
                          : null) as ImageProvider<Object>?,
                  child: _imageFile == null && Provider.of<AuthProvider>(context).user?.companyLogoUrl == null
                      ? const Icon(Icons.person, size: 60)
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Please enter your full name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter your email';
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!emailRegex.hasMatch(value)) return 'Please enter a valid email';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _companyController,
                decoration: const InputDecoration(
                  labelText: 'Company Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
                if (_saferWebSnapshot != null) ...[
                Text('Safer Web Info:', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text('Status: ${_saferWebSnapshot!.status}'),
                Text('Last Updated: ${_saferWebSnapshot!.lastUpdated}'),
                // Add more fields as needed
              ] else
                const CircularProgressIndicator(),
              const SizedBox(height: 24),
              SwitchListTile(
                title: const Text('Dark Mode'),
                value: themeProvider.themeMode == ThemeMode.dark,
                onChanged: (val) {
                  themeProvider.setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}

