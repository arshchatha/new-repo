import 'dart:nativewrappers/_internal/vm/lib/developer.dart';
import 'package:flutter/material.dart';
import 'package:lboard/providers/provider.dart';
import 'package:lboard/providers/safer_web_provider.dart';
import 'package:path/path.dart';
import '/core/services/auth_service.dart';
import '/core/config/app_routes.dart';
import '/models/user_role.dart';
import '/core/widgets/input_field.dart';
import 'package:lboard/models/user.dart';
import 'package:lboard/services/fmcsa_verification_service.dart';
import 'package:lboard/models/safer_web_snapshot.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  
  // Basic Info Controllers
  final _usernameController = TextEditingController();
  final _usDotMcController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usdotStatusController = TextEditingController();

  // FMCSA fetch state
  bool _isFetchingFmcsa = false;
  String _fmCSAError = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: Scrollbar(
          controller: _scrollController,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: SizedBox(
                    width: 150,
                    height: 150,
                    child: Image.asset('assets/images/logo.png'),
                  ),
                ),
                const SizedBox(height: 24),
                _buildRoleSelection(
                  _selectedRole,
                ),
                buildBasicInfoSection(context),
                buildAddressSection(),
                _buildCompanySection(context, _companyNameController, _websiteController, _paymentMethodController, _accountController, _syncToQBController, _remarksController),
                _buildContactSection(
                  _phoneController,
                  _phoneExtController,
                  _altPhoneController,
                  _faxController,
                  _emailController,
                ),
                _buildAdditionalInfoSection(
                  context,
                  _typeController,
                  _expenseTypeController,
                ),
                _buildSecuritySection(
                  _passwordController,
                  _confirmPasswordController,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isFetchingFmcsa ? null : register,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: _isFetchingFmcsa
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Register',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                  },
                  child: const Text('Already have an account? Login'),
                ),
                if (_errorMessage.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      border: Border.all(color: Colors.red.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _fetchFmcsaData() async {
    setState(() {
      _isFetchingFmcsa = true;
      _fmCSAError = '';
    });

    try {
      final usDotMcNumber = _usDotMcController.text.trim();
      if (usDotMcNumber.isEmpty) {
        setState(() {
          _fmCSAError = 'Please enter a US DOT or MC number';
          _isFetchingFmcsa = false;
        });
        return;
      }

      final verificationService = FmcsaVerificationService();
      final user = User(
        id: '',
        name: '',
        password: '',
        usDotMcNumber: usDotMcNumber,
        companyName: _companyNameController.text.trim(),
        email: '',
        phoneNumber: '',
        companyAddress: '',
        role: '',
        equipment: const [],
        lanePreferences: const [], loadPosts: [],
      );
      final result = await verificationService.verifyAndUpdateUser(user);

      if (!result.success) {
        setState(() {
          _fmCSAError = result.message;
          _isFetchingFmcsa = false;
        });
        return;
      }

      final snapshot = result.snapshot;
      if (snapshot == null) {
        setState(() {
          _fmCSAError = 'No FMCSA data found';
          _isFetchingFmcsa = false;
        });
        return;
      }

      // Populate form fields with FMCSA data
      setState(() {
        _companyNameController.text = snapshot.legalName;
        _addressLine1Controller.text = snapshot.address;
        _usdotStatusController.text = snapshot.usdotStatus ?? '';
        
        // Additional parsing of address into lines, city, state, postal code can be added here
        _isFetchingFmcsa = false;
      });
    } catch (e) {
      setState(() {
        _fmCSAError = 'Failed to fetch FMCSA data: $e';
        _isFetchingFmcsa = false;
      });
    }
  }

  // Address Controllers
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _countryController = TextEditingController(text: 'Canada');
  final _stateProvinceController = TextEditingController(text: 'Alberta');
  final _cityController = TextEditingController();
  final _postalZipCodeController = TextEditingController();

  // Company Info Controllers
  final _companyNameController = TextEditingController();
  final _websiteController = TextEditingController();
  final _portOfEntryController = TextEditingController();
  final _currencyController = TextEditingController(text: 'CAD');
  final _factoringCompanyController = TextEditingController(text: 'Factoring');
  final _paymentMethodController = TextEditingController(text: 'Cash');
  final _accountController = TextEditingController(text: 'Alberta');
  final _syncToQBController = TextEditingController(text: 'YES');
  final _remarksController = TextEditingController();

  // Contact Info Controllers
  final _phoneController = TextEditingController();
  final _phoneExtController = TextEditingController();
  final _altPhoneController = TextEditingController();
  final _altPhoneExtController = TextEditingController();
  final _faxController = TextEditingController();
  final _emailController = TextEditingController();
  final _referenceNumberController = TextEditingController();
  final _typeController = TextEditingController();
  final _expenseTypeController = TextEditingController();

  // Authentication Controllers
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _errorMessage = '';
  UserRole? _selectedRole;
  bool isLoading = false;

  @override
  void dispose() {
    _usDotMcController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _countryController.dispose();
    _stateProvinceController.dispose();
    _cityController.dispose();
    _postalZipCodeController.dispose();
    _companyNameController.dispose();
    _websiteController.dispose();
    _portOfEntryController.dispose();
    _currencyController.dispose();
    _factoringCompanyController.dispose();
    _paymentMethodController.dispose();
    _accountController.dispose();
    _syncToQBController.dispose();
    _remarksController.dispose();
    _phoneController.dispose();
    _phoneExtController.dispose();
    _altPhoneController.dispose();
    _altPhoneExtController.dispose();
    _faxController.dispose();
    _emailController.dispose();
    _referenceNumberController.dispose();
    _typeController.dispose();
    _expenseTypeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedRole == null) {
      setState(() {
        _errorMessage = 'Please select a role';
      });
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match';
      });
      return;
    }

    setState(() {
      isLoading = true;
      _errorMessage = '';
    });

    try {
      final authService = Provider.of<AuthService>(context as BuildContext, listen: false);
      final saferWebProvider = Provider.of<SaferWebProvider>(context as BuildContext, listen: false);

      // Fetch saferweb snapshot to get entity type as role
      final snapshot = await saferWebProvider.fetchSnapshot(_usDotMcController.text.trim());
      String? roleString;
      if (snapshot != null && snapshot.entityType.isNotEmpty) {
        final fetchedRole = snapshot.entityType.toLowerCase();
        // Map possible entityType values to 'broker' or 'carrier'
        if (fetchedRole.contains('broker')) {
          roleString = 'broker';
        } else if (fetchedRole.contains('carrier')) {
          roleString = 'carrier';
        } else {
          // fallback to selected role if entityType is unexpected
          roleString = _selectedRole.toString().split('.').last;
        }
        // For debugging: print fetched entityType and assigned roleString
        log('Fetched entityType: \${snapshot.entityType}, assigned roleString: \$roleString');
      } else {
        roleString = _selectedRole.toString().split('.').last;
      }

      final success = await authService.registerExtended(
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
        role: roleString == 'broker' 'carrier' ? UserRole.broker : UserRole.carrier,
        usDotMcNumber: _usDotMcController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        addressLine1: _addressLine1Controller.text.trim(),
        addressLine2: _addressLine2Controller.text.trim(),
        country: _countryController.text.trim(),
        stateProvince: _stateProvinceController.text.trim(),
        city: _cityController.text.trim(),
        postalZipCode: _postalZipCodeController.text.trim(),
        companyName: _companyNameController.text.trim(),
        website: _websiteController.text.trim(),
        portOfEntry: _portOfEntryController.text.trim(),
        currency: _currencyController.text.trim(),
        factoringCompany: _factoringCompanyController.text.trim(),
        paymentMethod: _paymentMethodController.text.trim(),
        account: _accountController.text.trim(),
        syncToQB: _syncToQBController.text.trim(),
        remarks: _remarksController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        phoneExt: _phoneExtController.text.trim(),
        altPhoneNumber: _altPhoneController.text.trim(),
        altPhoneExt: _altPhoneExtController.text.trim(),
        faxNumber: _faxController.text.trim(),
        email: _emailController.text.trim(),
        referenceNumber: _referenceNumberController.text.trim(),
        type: _typeController.text.trim(),
        expenseType: _expenseTypeController.text.trim(),
        // Add missing required parameters for User class
        name: '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
        companyAddress: _addressLine1Controller.text.trim(),
        roleString: roleString,
      );

      if (!mounted) return;

      if (success) {
        if (roleString == 'broker') {
          Navigator.pushReplacementNamed(context as BuildContext, AppRoutes.brokerDashboard);
        } else {
          Navigator.pushReplacementNamed(context as BuildContext, AppRoutes.carrierDashboard);
        }
      } else {
        setState(() {
          _errorMessage = 'Registration failed. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Registration failed: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildBasicInfoSection(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            InputField(
              controller: _usernameController,
              labelText: 'Username',
              hintText: 'Enter Username',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Username is required';
                }
                if (value.contains(' ')) {
                  return 'Username should not contain spaces';
                }
                final fullName = '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'.toLowerCase();
                if (value.toLowerCase() == fullName) {
                  return 'Username should not be the same as full name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InputField(
                    controller: _usDotMcController,
                    labelText: _selectedRole == UserRole.broker ? 'MC Number' : 'US DOT Number',
                    hintText: _selectedRole == UserRole.broker ? 'Enter MC Number' : 'Enter US DOT Number',
                    validator: (value) => value?.isEmpty ?? true ? 'This field is required' : null,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isFetchingFmcsa ? null : _fetchFmcsaData,
                  child: _isFetchingFmcsa
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Fetch FMCSA Info'),
                ),
              ],
            ),
            if (_fmCSAError.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _fmCSAError,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InputField(
                    controller: _firstNameController,
                    labelText: 'First Name',
                    hintText: 'Enter First Name',
                    validator: (value) => value?.isEmpty ?? true ? 'First name is required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InputField(
                    controller: _lastNameController,
                    labelText: 'Last Name',
                    hintText: 'Enter Last Name',
                    validator: (value) => value?.isEmpty ?? true ? 'Last name is required' : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAddressSection() {
    final saferWebProvider = Provider.of<SaferWebProvider>(context as BuildContext);
    final snapshot = saferWebProvider.getSnapshot(_usDotMcController.text.trim());

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Address Information',
              style: Theme.of(context as BuildContext).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            InputField(
              controller: _addressLine1Controller,
              labelText: 'First Line of Address',
              hintText: 'Enter Address',
              validator: (value) => value?.isEmpty ?? true ? 'Address is required' : null,
            ),
            const SizedBox(height: 16),
            InputField(
              controller: _addressLine2Controller,
              labelText: 'Second Line of Address',
              hintText: 'Enter Address',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InputField(
                    controller: _countryController,
                    labelText: 'Country',
                    hintText: 'Enter Country',
                    validator: (value) => value?.isEmpty ?? true ? 'Country is required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InputField(
                    controller: _stateProvinceController,
                    labelText: 'State/Province',
                    hintText: 'Enter State/Province',
                    validator: (value) => value?.isEmpty ?? true ? 'State/Province is required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InputField(
                    controller: _cityController,
                    labelText: 'City',
                    hintText: 'Enter City',
                    validator: (value) => value?.isEmpty ?? true ? 'City is required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InputField(
                    controller: _postalZipCodeController,
                    labelText: 'Postal/Zip Code',
                    hintText: 'Enter Postal/Zip Code',
                    validator: (value) => value?.isEmpty ?? true ? 'Postal/Zip code is required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (snapshot != null) ...[
              Text(
                'USDOT Status: ${_getUsdotStatusDisplay(snapshot)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _isUsdotActive(snapshot) ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Entity Type: ${snapshot.entityType}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Operating Status: ${snapshot.status}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Operation Classification: ${snapshot.operationClassification?.join(', ') ?? 'N/A'}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Carrier Operation: ${snapshot.carrierOperation?.join(', ') ?? 'N/A'}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Cargo Carried: ${snapshot.cargoCarried?.join(', ') ?? 'N/A'}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String mapUsdotStatus(String? status) {
    if (status == null) return 'Unknown';
    final lowerStatus = status.toLowerCase();
    if (lowerStatus.contains('active')) {
      return 'Active';
    } else if (lowerStatus.contains('deactivate') || lowerStatus.contains('inactive')) {
      return 'Deactivated';
    }
    return status;
  }

  String _getUsdotStatusDisplay(SaferWebSnapshot snapshot) {
    return _isUsdotActive(snapshot) ? 'Active' : 'Inactive';
  }

  bool _isUsdotActive(SaferWebSnapshot snapshot) {
    // Check if operating status contains "Authorized"
    if (snapshot.status.toLowerCase().contains('authorized')) {
      return true;
    }
    
    // Otherwise, check if usdotStatus contains "Active"
    return snapshot.usdotStatus?.toLowerCase().contains('active') ?? false;
  }

  Widget _buildCompanySection(BuildContext context, dynamic companyNameController, dynamic websiteController, dynamic paymentMethodController, dynamic accountController, dynamic syncToQBController, dynamic remarksController) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Company Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            InputField(
              controller: companyNameController,
              labelText: 'Company Name',
              hintText: 'Enter Company Name',
              validator: (value) => value?.isEmpty ?? true ? 'Company name is required' : null,
            ),
            const SizedBox(height: 16),
            InputField(
              controller: websiteController,
              labelText: 'Website',
              hintText: 'Enter Website',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InputField(
                    controller: paymentMethodController,
                    labelText: 'Payment Method',
                    hintText: 'Enter Payment Method',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InputField(
                    controller: accountController,
                    labelText: 'Account',
                    hintText: 'Enter Account',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            InputField(
              controller: syncToQBController,
              labelText: 'Sync to QB',
              hintText: 'Enter Yes/No',
            ),
            const SizedBox(height: 16),
            InputField(
              controller: remarksController,
              labelText: 'Remarks',
              hintText: 'Enter Remarks',
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection(dynamic phoneController, dynamic phoneExtController, dynamic altPhoneController, dynamic faxController, dynamic emailController) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Information',
              style: Theme.of(context as BuildContext).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InputField(
                    controller: phoneController,
                    labelText: 'Phone Number',
                    hintText: 'Enter Phone Number',
                    validator: (value) => value?.isEmpty ?? true ? 'Phone number is required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InputField(  
                    controller: phoneExtController,
                    labelText: 'Phone Ext',
                    hintText: 'Enter Phone Ext',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InputField(
                    controller: altPhoneController,
                    labelText: 'Alternate Phone',
                    hintText: 'Enter Alternate Phone',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InputField(
                    controller: faxController,
                    labelText: 'Fax Number',
                    hintText: 'Enter Fax Number',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            InputField(
              controller: emailController,
              labelText: 'Email',
              hintText: 'Enter Email',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email is required';
                }
                final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                if (!emailRegex.hasMatch(value)) {
                  return 'Invalid email format';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildAdditionalInfoSection(BuildContext context, dynamic typeController, dynamic expenseTypeController) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Additional Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            InputField(
              controller: typeController,
              labelText: 'Type',
              hintText: 'Enter Type',
            ),
            const SizedBox(height: 16),
            InputField(
              controller: expenseTypeController,
              labelText: 'Expense Type',
              hintText: 'Enter Expense Type',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySection(dynamic passwordController, dynamic confirmPasswordController) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Security',
              style: Theme.of(context as BuildContext).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            InputField(
              controller: passwordController,
              labelText: 'Password',
              hintText: 'Enter Password',
              isPassword: true,
              validator: (value) => value?.isEmpty ?? true ? 'Password is required' : null,
            ),
            const SizedBox(height: 16),
            InputField(
              controller: confirmPasswordController,
              labelText: 'Confirm Password',
              hintText: 'Confirm Password',
              isPassword: true,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please confirm your password';
                }
                if (value != passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSelection(dynamic selectedRole) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Role',
              style: Theme.of(context as BuildContext).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            RadioListTile<UserRole>(
              title: const Text('Broker'),
              subtitle: const Text('Post loads and manage shipments'),
              value: UserRole.broker,
              groupValue: selectedRole,
              onChanged: (UserRole? value) {
                setState(() {
                  selectedRole = value;
                });
              },
            ),
            RadioListTile<UserRole>(
              title: const Text('Carrier'),
              subtitle: const Text('Find and bid on available loads'),
              value: UserRole.carrier,
              groupValue: selectedRole,
              onChanged: (UserRole? value) {
                setState(() {
                  selectedRole = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }
}

