import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../services/fmcsa_verification_service.dart';
import '../core/config/app_routes.dart';
import '../models/safer_web_snapshot.dart';
import '../services/safer_web_api_service.dart';

class EnhancedRegisterScreen extends StatefulWidget {
  const EnhancedRegisterScreen({super.key});

  @override
  State<EnhancedRegisterScreen> createState() =>
      _EnhancedRegisterScreenState();
}

class _EnhancedRegisterScreenState extends State<EnhancedRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _companyNameController = TextEditingController();
  final companyPhoneController = TextEditingController();
  final _companyAddressController = TextEditingController();
  final _usdotMcController = TextEditingController();
  final FmcsaVerificationService fmcsaVerificationService =
      FmcsaVerificationService();
  VerificationResult? _verificationResult;
  
  

  String _selectedRole = 'carrier';
  bool isLoading = false;
  bool _isVerifying = false;

  VerificationResult? verificationResult;
  SaferWebSnapshot? _fmcsaData;

  bool _fmcsaConfirmed = false;
  int _currentStep = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _companyNameController.dispose();
    _companyAddressController.dispose();
    _usdotMcController.dispose();
    super.dispose();
  }

  Future<void> _fetchFmcsaData() async {
    if (_usdotMcController.text.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter USDOT/MC number')),
      );
      return;
    }

    setState(() {
      _isVerifying = true;
      _fmcsaData = null;
    });

    try {
      final apiService = Provider.of<SaferWebApiService>(context, listen: false);
      final snapshot = await apiService.fetchSnapshot(_usdotMcController.text.trim());

      if (!mounted) return;

      setState(() {
        _fmcsaData = snapshot;
          if (_fmcsaData != null) {
            _companyNameController.text = _fmcsaData!.companyName;
            _companyAddressController.text = _fmcsaData!.companyAddress;
            // phone field is not present in SaferWebSnapshot, so leave phoneController unchanged or handle separately if needed
            _selectedRole = (_fmcsaData!.entityType.toLowerCase() == 'broker') ? 'broker' : 'carrier';
            // Auto select account type based on entityType from FMCSA data
            if (_fmcsaData!.entityType.toLowerCase() == 'broker') {
              _selectedRole = 'broker';
            } else if (_fmcsaData!.entityType.toLowerCase() == 'carrier') {
              _selectedRole = 'carrier';
            }
          }
      });

      if (snapshot == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No data found for the given USDOT/MC number'), backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fetch error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final nextRoute = _selectedRole == 'broker'
        ? AppRoutes.brokerDashboard
        : AppRoutes.carrierDashboard;

    setState(() {
      isLoading = true;
    });

    try {
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        phoneNumber: _phoneController.text,
        companyName: _companyNameController.text,
        companyAddress: _companyAddressController.text,
        usDotMcNumber: _usdotMcController.text.trim(),
        role: _selectedRole,
        isLoggedIn: true,
        equipment: const [],
        lanePreferences: const [], loadPosts: [],
      );

      await authProvider.register(user);

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, nextRoute);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget _buildUsdotMcStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Enter USDOT/MC Number',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _usdotMcController,
                decoration: const InputDecoration(
                  labelText: 'USDOT/MC Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.confirmation_number),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter USDOT/MC Number' : null,
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: _isVerifying ? null : _fetchFmcsaData,
              child: _isVerifying
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Fetch Info'),
            ),
          ],
        ),
        if (_verificationResult != null && !_verificationResult!.success)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(_verificationResult!.message,
                style: const TextStyle(color: Colors.red)),
          ),
            if (_fmcsaData != null && !_fmcsaConfirmed) ...[
              const SizedBox(height: 20),
              Text('Company Name: ${_fmcsaData!.companyName}'),
              Text('Company Address: ${_fmcsaData!.companyAddress}'),
              Text('Entity Type: ${_fmcsaData!.entityType}'),
              Text('Operating Status: ${_fmcsaData!.operatingStatus }'),
              Text('USDOT Status: ${_fmcsaData!.usdotStatus }'),
              Text('Power Units: ${_fmcsaData!.powerUnits }'),
              Text('Drivers: ${_fmcsaData!.drivers }'),

              Text('USDOT Number: ${_fmcsaData!.usdotNumber }'),
              Text('MC Number: ${_fmcsaData!.mcNumber }'),
              const SizedBox(height: 10),
              // New FMCSA info display
              if (_fmcsaData!.inspectionSummary != null) ...[
                const Text('Inspection Summary:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Total Inspections: ${_fmcsaData!.inspectionSummary!['total_inspections'] ?? 'N/A'}'),
                Text('Out of Service %: ${_fmcsaData!.inspectionSummary!['out_of_service_percent'] ?? 'N/A'}'),
              ],


              if (_fmcsaData!.usInspections != null) ...[
                const SizedBox(height: 10),
                const Text('US Inspections:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text('Driver - Out of Service: ${_fmcsaData!.usInspections!.driver.outOfService}'),
                Text('Driver - Out of Service %: ${_fmcsaData!.usInspections!.driver.outOfServicePercent}'),
                Text('Driver - National Average: ${_fmcsaData!.usInspections!.driver.nationalAverage}'),
                Text('Driver - Inspections: ${_fmcsaData!.usInspections!.driver.inspections}'),
                const SizedBox(height: 5),
                Text('Vehicle - Out of Service: ${_fmcsaData!.usInspections!.vehicle.outOfService}'),
                Text('Vehicle - Out of Service %: ${_fmcsaData!.usInspections!.vehicle.outOfServicePercent}'),
                Text('Vehicle - National Average: ${_fmcsaData!.usInspections!.vehicle.nationalAverage}'),
                Text('Vehicle - Inspections: ${_fmcsaData!.usInspections!.vehicle.inspections}'),
                const SizedBox(height: 5),
                Text('Hazmat - Out of Service: ${_fmcsaData!.usInspections!.hazmat.outOfService}'),
                Text('Hazmat - Out of Service %: ${_fmcsaData!.usInspections!.hazmat.outOfServicePercent}'),
                Text('Hazmat - National Average: ${_fmcsaData!.usInspections!.hazmat.nationalAverage}'),
                Text('Hazmat - Inspections: ${_fmcsaData!.usInspections!.hazmat.inspections}'),
                const SizedBox(height: 5),
                Text('IEP - Out of Service: ${_fmcsaData!.usInspections!.iep.outOfService}'),
                Text('IEP - Out of Service %: ${_fmcsaData!.usInspections!.iep.outOfServicePercent}'),
                Text('IEP - National Average: ${_fmcsaData!.usInspections!.iep.nationalAverage}'),
                Text('IEP - Inspections: ${_fmcsaData!.usInspections!.iep.inspections}'),
              ],
              if (_fmcsaData!.crashSummary != null) ...[
                const SizedBox(height: 10),
                const Text('Crash Summary:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text('Total Crashes: ${_fmcsaData!.crashSummary!['total_crashes'] ?? 'N/A'}'),
                Text('Fatal Crashes: ${_fmcsaData!.crashSummary!['fatal_crashes'] ?? 'N/A'}'),
                Text('Injury Crashes: ${_fmcsaData!.crashSummary!['injury_crashes'] ?? 'N/A'}'),
                Text('Tow Away Crashes: ${_fmcsaData!.crashSummary!['tow_away_crashes'] ?? 'N/A'}'),
              ],


            const SizedBox(height: 10),
            // New FMCSA info display
            if (_fmcsaData!.inspectionSummary != null) ...[
              const Text('Inspection Summary:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Total Inspections: ${_fmcsaData!.inspectionSummary!['total_inspections'] ?? 'N/A'}'),
              Text('Out of Service %: ${_fmcsaData!.inspectionSummary!['out_of_service_percent'] ?? 'N/A'}'),
            ],
            if (_fmcsaData!.crashSummary != null) ...[
              const SizedBox(height: 10),
              const Text('Crash Summary:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Total Crashes: ${_fmcsaData!.crashSummary!['total_crashes'] ?? 'N/A'}'),
              Text('Fatal Crashes: ${_fmcsaData!.crashSummary!['fatal_crashes'] ?? 'N/A'}'),
            ],
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _fmcsaConfirmed = true;
                  _companyNameController.text = _fmcsaData!.companyName;
                  _companyAddressController.text = _fmcsaData!.companyAddress;
                  _selectedRole = _fmcsaData!.entityType.toLowerCase() == 'broker'
                      ? 'broker'
                      : 'carrier';
                  _currentStep = 1;
                });
              },
              child: const Text('Confirm Company Info'),
            ),
          ]
      ],
    );
  }

  Widget _buildInfoStep() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_fmcsaData != null) ...[
              Text('Company Name: ${_fmcsaData!.companyName}'),
              Text('Company Address: ${_fmcsaData!.companyAddress}'),
              Text('Entity Type: ${_fmcsaData!.entityType}'),

              Text('USDOT Number: ${_fmcsaData!.usdotNumber }'),
              Text('MC Number: ${_fmcsaData!.mcNumber }'),
              const SizedBox(height: 20),
              // New FMCSA info display
              if (_fmcsaData!.inspectionSummary != null) ...[
                const Text('Inspection Summary:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Total Inspections: ${_fmcsaData!.inspectionSummary!['total_inspections'] ?? 'N/A'}'),
                Text('Out of Service %: ${_fmcsaData!.inspectionSummary!['out_of_service_percent'] ?? 'N/A'}'),
              ],
              if (_fmcsaData!.crashSummary != null) ...[
                const SizedBox(height: 10),
                const Text('Crash Summary:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Total Crashes: ${_fmcsaData!.crashSummary!['total_crashes'] ?? 'N/A'}'),
                Text('Fatal Crashes: ${_fmcsaData!.crashSummary!['fatal_crashes'] ?? 'N/A'}'),
              ],
            ],
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Enter your name' : null,
            ),
            TextFormField(
              controller:_usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Enter your username' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter your email';
                }
                if (!value.contains('@')) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) =>
                  value == null || value.isEmpty ? 'Enter phone number' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 chars';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_outline),
              ),
              obscureText: true,
              validator: (value) =>
                  value != _passwordController.text ? 'Passwords do not match' : null,
            ),
            const SizedBox(height: 20),
            const Text('Account Type',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Carrier'),
                    value: 'carrier',
                    groupValue: _selectedRole,
                    onChanged: (value) => setState(() => _selectedRole = value!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Broker'),
                    value: 'broker',
                    groupValue: _selectedRole,
                    onChanged: (value) => setState(() => _selectedRole = value!),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register'), centerTitle: true),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep == 0) {
            if (_usdotMcController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter USDOT/MC number')),
              );
              return;
            }
            _fetchFmcsaData().then((_) {
              if (_fmcsaData != null) {
                setState(() {
                  _currentStep += 1;
                });
              }
            });
          } else if (_currentStep == 1) {
            if (_formKey.currentState!.validate()) {
              _register();
            }
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() {
              _currentStep -= 1;
            });
          }
        },
        steps: [
          Step(
            title: const Text('USDOT/MC Number'),
            content: _buildUsdotMcStep(),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Registration Info'),
            content: _buildInfoStep(),
            isActive: _currentStep >= 1,
            state: _currentStep == 1 ? StepState.editing : StepState.indexed,
          ),
        ],
      ),
    );
  }
}
