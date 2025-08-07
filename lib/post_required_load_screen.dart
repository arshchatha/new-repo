import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'models/load_post.dart';
import 'providers/auth_provider.dart';
import 'providers/load_provider.dart';

// Removed any import or usage of CommodityRow as it is not used here

class PostRequiredLoadScreen extends StatefulWidget {
  const PostRequiredLoadScreen({super.key});

  @override
  State<PostRequiredLoadScreen> createState() => _PostRequiredLoadScreenState();
}

class _PostRequiredLoadScreenState extends State<PostRequiredLoadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPage = 0;

  // List of North American countries
  final List<String> _countries = ['United States', 'Canada', 'Mexico'];

  String? _originCountry;
  String? _destinationCountry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Required Load'),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_currentPage + 1) / 3,
            backgroundColor: Colors.grey[300],
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: PageView(
          controller: _pageController,
          onPageChanged: (page) => setState(() => _currentPage = page),
          children: [
            _buildLocationPage(),
            _buildLoadDetailsPage(),
            _buildDatePage(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (_currentPage > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: const Text('Previous'),
                ),
              ),
            if (_currentPage > 0) const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (_currentPage < 2) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    _submitForm();
                  }
                },
                child: Text(_currentPage < 2 ? 'Next' : 'Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Origin fields
  final TextEditingController _originCityController = TextEditingController();
  String? _originState;
  final TextEditingController _originPostalCodeController = TextEditingController();

  // Destination fields
  final TextEditingController _destinationCityController = TextEditingController();
  String? _destinationState;
  final TextEditingController _destinationPostalCodeController = TextEditingController();

  // Load details
  final TextEditingController _weightController = TextEditingController();
  String? _selectedDimension;
  final TextEditingController _rateController = TextEditingController();
  String? _selectedLoadType;
  DateTime? _pickupDate;
  DateTime? _deliveryDate;
  
  // Distance radius limits
  int? _originRadius;
  int? _destinationRadius;

  // Equipment types
  final List<String> _equipmentTypes = [
    'Van', 'Flatbed', 'Reefer', 'Step Deck', 'Lowboy', 'Double Drop', 'Conestoga',
    'Extendable Flatbed', 'High Cube', 'Box Truck', 'Straight Truck', 'Cargo Van',
    'Sprinter Van', 'Pickup Truck', 'Heated Trailer', 'Tanker', 'Dump Truck',
    'Container Chassis', 'Other'
  ];
  List<String> selectedEquipment = [];

  @override
  void dispose() {
    _originCityController.dispose();
    _originPostalCodeController.dispose();
    _destinationCityController.dispose();
    _destinationPostalCodeController.dispose();
    _weightController.dispose();
    _rateController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isPickup) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        if (isPickup) {
          _pickupDate = date;
        } else {
          _deliveryDate = date;
        }
      });
    }
  }

  void _toggleEquipment(String equipment) {
    setState(() {
      if (selectedEquipment.contains(equipment)) {
        selectedEquipment.remove(equipment);
      } else {
        selectedEquipment.add(equipment);
      }
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;
      
      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please log in to post loads')),
          );
        }
        return;
      }

      // Default radius values if not set
      final defaultRadius = 100; // 100 miles default radius
      
      final loadPost = LoadPost(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Required Load: ${_originCityController.text} to ${_destinationCityController.text}',
        origin: '${_originCityController.text}, ${_originState ?? ''}, ${_originCountry ?? ''} ${_originPostalCodeController.text}',
        destination: '${_destinationCityController.text}, ${_destinationState ?? ''}, ${_destinationCountry ?? ''} ${_destinationPostalCodeController.text}',
        isBrokerPost: false,
        isCarrierPost: true,
        postedBy: user.name,
        weight: _weightController.text,
        dimensions: _selectedDimension ?? '',
        rate: _rateController.text,
        equipment: selectedEquipment,
        loadType: _selectedLoadType,
        pickupDate: _pickupDate != null ? DateFormat('yyyy-MM-dd').format(_pickupDate!) : '',
        deliveryDate: _deliveryDate != null ? DateFormat('yyyy-MM-dd').format(_deliveryDate!) : '',
        originRadius: _originRadius ?? defaultRadius,
        destinationRadius: _destinationRadius ?? defaultRadius,
        country: _originCountry,
        originCity: _originCityController.text,
        originCountry: _originCountry,
        originState: _originState,
        originPostalCode: _originPostalCodeController.text,
        originDescription: null,
        destinationCity: _destinationCityController.text,
        destinationCountry: _destinationCountry,
        destinationState: _destinationState,
        destinationPostalCode: _destinationPostalCodeController.text,
        destinationDescription: null,
        pickupTime: null,
        deliveryTime: null,
        appointment: false,
        isActive: true,
        volume: 0,
        status: 'available',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isbroken: false,
        isbooked: false,
      );

      try {
        await Provider.of<LoadProvider>(context, listen: false).addLoad(loadPost);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Load requirement posted successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error posting load requirement: $e')),
          );
        }
      }
    }
  }

  Widget _buildLocationPage() {
    final List<String> usStates = [
      'Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California', 'Colorado', 'Connecticut',
      'Delaware', 'Florida', 'Georgia', 'Hawaii', 'Idaho', 'Illinois', 'Indiana', 'Iowa',
      'Kansas', 'Kentucky', 'Louisiana', 'Maine', 'Maryland', 'Massachusetts', 'Michigan',
      'Minnesota', 'Mississippi', 'Missouri', 'Montana', 'Nebraska', 'Nevada', 'New Hampshire',
      'New Jersey', 'New Mexico', 'New York', 'North Carolina', 'North Dakota', 'Ohio',
      'Oklahoma', 'Oregon', 'Pennsylvania', 'Rhode Island', 'South Carolina', 'South Dakota',
      'Tennessee', 'Texas', 'Utah', 'Vermont', 'Virginia', 'Washington', 'West Virginia',
      'Wisconsin', 'Wyoming'
    ];
    final List<String> canadianProvinces = [
      'Alberta', 'British Columbia', 'Manitoba', 'New Brunswick', 'Newfoundland and Labrador',
      'Nova Scotia', 'Ontario', 'Prince Edward Island', 'Quebec', 'Saskatchewan'
    ];

    List<String> getStatesForCountry(String? country) {
      if (country == 'United States') {
        return usStates;
      } else if (country == 'Canada') {
        return canadianProvinces;
      } else {
        return [];
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Location Details',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Origin',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _originCityController,
                    decoration: const InputDecoration(
                      labelText: 'City *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _originState,
                    decoration: const InputDecoration(
                      labelText: 'State *',
                      border: OutlineInputBorder(),
                    ),
                    items: getStatesForCountry(_originCountry)
                        .map((state) => DropdownMenuItem(value: state, child: Text(state)))
                        .toList(),
                    onChanged: (val) => setState(() => _originState = val),
                    validator: (value) => value == null ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _originCountry,
                    decoration: const InputDecoration(
                      labelText: 'Country *',
                      border: OutlineInputBorder(),
                    ),
                    items: _countries
                        .map((country) => DropdownMenuItem(value: country, child: Text(country)))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        _originCountry = val;
                        _originState = null; // Reset state when country changes
                      });
                    },
                    validator: (value) => value == null ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _originPostalCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Postal Code *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Load Match Radius',
                      border: OutlineInputBorder(),
                      suffixText: 'miles',
                    ),
                    value: _originRadius,
                    items: const [
                      DropdownMenuItem(value: 50, child: Text('50 miles')),
                      DropdownMenuItem(value: 100, child: Text('100 miles')),
                      DropdownMenuItem(value: 150, child: Text('150 miles')),
                      DropdownMenuItem(value: 200, child: Text('200 miles')),
                      DropdownMenuItem(value: 250, child: Text('250 miles')),
                      DropdownMenuItem(value: 300, child: Text('300 miles')),
                      DropdownMenuItem(value: 400, child: Text('400 miles')),
                      DropdownMenuItem(value: 500, child: Text('500 miles')),
                    ],
                    onChanged: (value) => setState(() => _originRadius = value),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Destination',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _destinationCityController,
                    decoration: const InputDecoration(
                      labelText: 'City *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _destinationState,
                    decoration: const InputDecoration(
                      labelText: 'State *',
                      border: OutlineInputBorder(),
                    ),
                    items: getStatesForCountry(_destinationCountry)
                        .map((state) => DropdownMenuItem(value: state, child: Text(state)))
                        .toList(),
                    onChanged: (val) => setState(() => _destinationState = val),
                    validator: (value) => value == null ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _destinationCountry,
                    decoration: const InputDecoration(
                      labelText: 'Country *',
                      border: OutlineInputBorder(),
                    ),
                    items: _countries
                        .map((country) => DropdownMenuItem(value: country, child: Text(country)))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        _destinationCountry = val;
                        _destinationState = null; // Reset state when country changes
                      });
                    },
                    validator: (value) => value == null ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _destinationPostalCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Postal Code *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Load Match Radius',
                      border: OutlineInputBorder(),
                      suffixText: 'miles',
                    ),
                    value: _destinationRadius,
                    items: const [
                      DropdownMenuItem(value: 50, child: Text('50 miles')),
                      DropdownMenuItem(value: 100, child: Text('100 miles')),
                      DropdownMenuItem(value: 150, child: Text('150 miles')),
                      DropdownMenuItem(value: 200, child: Text('200 miles')),
                      DropdownMenuItem(value: 250, child: Text('250 miles')),
                      DropdownMenuItem(value: 300, child: Text('300 miles')),
                      DropdownMenuItem(value: 400, child: Text('400 miles')),
                      DropdownMenuItem(value: 500, child: Text('500 miles')),
                    ],
                    onChanged: (value) => setState(() => _destinationRadius = value),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadDetailsPage() {
    final List<String> dimensionOptions = [
      '48x102', '53x102', '48x96', '53x96', 'Other'
    ];
    final List<String> loadTypeOptions = [
      'Full Truckload', 'Less Than Truckload', 'Partial', 'Other'
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Load Details',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _weightController,
                    decoration: const InputDecoration(
                      labelText: 'Weight (lbs) *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedDimension,
                    decoration: const InputDecoration(
                      labelText: 'Dimensions',
                      border: OutlineInputBorder(),
                    ),
                    items: dimensionOptions
                        .map((dim) => DropdownMenuItem(value: dim, child: Text(dim)))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedDimension = val),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _rateController,
                    decoration: const InputDecoration(
                      labelText: 'Desired Rate (\$)',
                      border: OutlineInputBorder(),
                      prefixText: '\$ ',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedLoadType,
                    decoration: const InputDecoration(
                      labelText: 'Load Type',
                      border: OutlineInputBorder(),
                    ),
                    items: loadTypeOptions
                        .map((lt) => DropdownMenuItem(value: lt, child: Text(lt)))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedLoadType = val),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Required Equipment',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _equipmentTypes.map((equipment) {
                      final isSelected = selectedEquipment.contains(equipment);
                      return FilterChip(
                        label: Text(equipment),
                        selected: isSelected,
                        onSelected: (_) => _toggleEquipment(equipment),
                        // ignore: deprecated_member_use
                        backgroundColor: isSelected ? Color.fromRGBO(
                          (Theme.of(context).primaryColor.r * 255.0).round() & 0xff,
                          (Theme.of(context).primaryColor.g * 255.0).round() & 0xff,
                          (Theme.of(context).primaryColor.b * 255.0).round() & 0xff,
                          0.7
                        ) : null,
                        checkmarkColor: Theme.of(context).primaryColor,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Schedule',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: const Text('Pickup Date'),
                    subtitle: Text(
                      _pickupDate == null
                          ? 'Not selected'
                          : DateFormat('MM/dd/yyyy').format(_pickupDate!),
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () => _pickDate(true),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Delivery Date'),
                    subtitle: Text(
                      _deliveryDate == null
                          ? 'Not selected'
                          : DateFormat('MM/dd/yyyy').format(_deliveryDate!),
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () => _pickDate(false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}
