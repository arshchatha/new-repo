import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../models/invoice.dart';
import '../providers/invoice_provider.dart';
import '../services/google_ocr_service.dart';
import '../services/google_places_service.dart';

class CreateInvoiceScreen extends StatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _loadIdController = TextEditingController();
  final TextEditingController _billedToController = TextEditingController();
  final TextEditingController _billedToAddressController = TextEditingController();
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _originCompanyNameController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _destinationCompanyNameController = TextEditingController();
  final TextEditingController _pickupDateController = TextEditingController();
  final TextEditingController _deliveryDateController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _currencyController = TextEditingController(text: 'USD');
  final TextEditingController _taxController = TextEditingController();
  final TextEditingController _accountingEmailController = TextEditingController();
  final TextEditingController _contactInfoController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();
  final TextEditingController _paymentMethodController = TextEditingController();

  late GooglePlacesService _placesService;
  List<Map<String, dynamic>> _originPredictions = [];
  List<Map<String, dynamic>> _destinationPredictions = [];

  Timer? _debounceOrigin;
  Timer? _debounceDestination;

  bool _isProcessingOcr = false;
  bool _isSubmitting = false;
  String? _ocrResultMessage;
  File? _podFile;

  @override
  void initState() {
    super.initState();
    _placesService = GooglePlacesService('AIzaSyCWht0kEJMXOEHaUjNlERQEz9iVUS6cN2o'); // Your API key
  }

  @override
  void dispose() {
    _loadIdController.dispose();
    _billedToController.dispose();
    _originController.dispose();
    _destinationController.dispose();
    _pickupDateController.dispose();
    _deliveryDateController.dispose();
    _amountController.dispose();
    _currencyController.dispose();
    _taxController.dispose();
    _paymentMethodController.dispose();
    _dueDateController.dispose();
    _accountingEmailController.dispose();
    _contactInfoController.dispose();
    _debounceOrigin?.cancel();
    _debounceDestination?.cancel();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final invoice = Invoice(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      loadId: _loadIdController.text,
      createdBy: 'currentUserId',
      billedTo: _billedToController.text,
      origin: _originController.text,
      destination: _destinationController.text,
      pickupDate: _pickupDateController.text,
      deliveryDate: _deliveryDateController.text,
      amount: double.tryParse(_amountController.text) ?? 0.0,
      currency: _currencyController.text,
      tax: double.tryParse(_taxController.text) ?? 0.0,
      status: 'Draft',
      paymentMethod: _paymentMethodController.text,
      dueDate: _dueDateController.text,
      podUrl: null,
      createdAt: DateTime.now(),
    );

    final provider = Provider.of<InvoiceProvider>(context, listen: false);
    try {
      await provider.createInvoice(invoice);

      if (_podFile != null) {
        await provider.uploadPOD(invoice.id, _podFile!);
      }

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      _showSnackBar('Failed to create invoice: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _pickLoadConfirmationFile() async {
    setState(() {
      _isProcessingOcr = true;
      _ocrResultMessage = null;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);
        _podFile = file;

        final ocrService = GoogleOcrService();
        final ocrResults = await ocrService.performOcrOnDocuments([file.path]);

        if (ocrResults.isNotEmpty) {
          final ocrText = ocrResults.first['text'] ?? '';
          _parseOcrTextToFormFields(ocrText);

          setState(() {
            _ocrResultMessage = 'Invoice data extracted from attachment.';
          });
        } else {
          setState(() {
            _ocrResultMessage = 'No text detected in the document.';
          });
        }
      }
    } catch (e) {
      setState(() {
        _ocrResultMessage = 'OCR processing failed: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isProcessingOcr = false;
      });
    }
  }

  void _parseOcrTextToFormFields(String ocrText) {
    final loadIdMatch = RegExp(r'load\s*number\s*[:#]?\s*(\w+)', caseSensitive: false).firstMatch(ocrText);
    final billedToMatch = RegExp(r'(?:billed to|carrier|broker)\s*[:]?\s*([\w\s]+)', caseSensitive: false).firstMatch(ocrText);
    final billedToAddressMatch = RegExp(r'billed to address\s*[:]?\s*([\w\s,]+)', caseSensitive: false).firstMatch(ocrText);
    final originMatch = RegExp(r'origin\s*[:]?\s*([\w\s,]+)', caseSensitive: false).firstMatch(ocrText);
    final originCompanyNameMatch = RegExp(r'origin company name\s*[:]?\s*([\w\s]+)', caseSensitive: false).firstMatch(ocrText);
    final destinationMatch = RegExp(r'destination\s*[:]?\s*([\w\s,]+)', caseSensitive: false).firstMatch(ocrText);
    final destinationCompanyNameMatch = RegExp(r'destination company name\s*[:]?\s*([\w\s]+)', caseSensitive: false).firstMatch(ocrText);
    final pickupDateMatch = RegExp(r'pickup\s*date\s*[:]?\s*(\d{4}[-/]\d{2}[-/]\d{2})', caseSensitive: false).firstMatch(ocrText);
    final deliveryDateMatch = RegExp(r'delivery\s*date\s*[:]?\s*(\d{4}[-/]\d{2}[-/]\d{2})', caseSensitive: false).firstMatch(ocrText);
    final amountMatch = RegExp(r'total\s*amount\s*[:$]?\s*(\d+[.,]?\d*)', caseSensitive: false).firstMatch(ocrText);
    final taxMatch = RegExp(r'tax\s*[:$]?\s*(\d+[.,]?\d*)', caseSensitive: false).firstMatch(ocrText);
    final paymentMethodMatch = RegExp(r'payment\s*method\s*[:]?\s*([\w\s]+)', caseSensitive: false).firstMatch(ocrText);
    final dueDateMatch = RegExp(r'due\s*date\s*[:]?\s*(\d{4}[-/]\d{2}[-/]\d{2})', caseSensitive: false).firstMatch(ocrText);

    _loadIdController.text = loadIdMatch?.group(1)?.trim() ?? '';
    _billedToController.text = billedToMatch?.group(1)?.trim() ?? '';
    _billedToAddressController.text = billedToAddressMatch?.group(1)?.trim() ?? '';
    _originController.text = originMatch?.group(1)?.trim() ?? '';
    _originCompanyNameController.text = originCompanyNameMatch?.group(1)?.trim() ?? '';
    _destinationController.text = destinationMatch?.group(1)?.trim() ?? '';
    _destinationCompanyNameController.text = destinationCompanyNameMatch?.group(1)?.trim() ?? '';
    _pickupDateController.text = pickupDateMatch?.group(1)?.trim() ?? '';
    _deliveryDateController.text = deliveryDateMatch?.group(1)?.trim() ?? '';
    _amountController.text = amountMatch?.group(1)?.replaceAll(',', '') ?? '';
    _currencyController.text = 'USD';
    _taxController.text = taxMatch?.group(1)?.replaceAll(',', '') ?? '';
    _paymentMethodController.text = paymentMethodMatch?.group(1)?.trim() ?? '';
    _dueDateController.text = dueDateMatch?.group(1)?.trim() ?? '';
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime initialDate = DateTime.now();
    try {
      if (controller.text.isNotEmpty) {
        initialDate = DateTime.parse(controller.text);
      }
    } catch (_) {}

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      controller.text = picked.toIso8601String().split('T').first;
    }
  }

  void _onOriginChanged(String value) {
    if (_debounceOrigin?.isActive ?? false) _debounceOrigin!.cancel();
    _debounceOrigin = Timer(const Duration(milliseconds: 500), () async {
      if (value.isEmpty) {
        setState(() => _originPredictions.clear());
        return;
      }
      try {
        final results = await _placesService.getPlaceAutocomplete(value);
        setState(() => _originPredictions = results);
      } catch (_) {}
    });
  }

  void _onDestinationChanged(String value) {
    if (_debounceDestination?.isActive ?? false) _debounceDestination!.cancel();
    _debounceDestination = Timer(const Duration(milliseconds: 500), () async {
      if (value.isEmpty) {
        setState(() => _destinationPredictions.clear());
        return;
      }
      try {
        final results = await _placesService.getPlaceAutocomplete(value);
        setState(() => _destinationPredictions = results);
      } catch (_) {}
    });
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType type = TextInputType.text,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          suffixIcon: suffixIcon,
        ),
        validator: validator ?? (value) => value == null || value.isEmpty ? 'Required: $label' : null,
        onTap: onTap,
      ),
    );
  }

  Widget _buildPlaceAutocompleteField(
    String label,
    TextEditingController controller,
    List<Map<String, dynamic>> predictions,
    void Function(String) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: onChanged,
            validator: (value) => value == null || value.isEmpty ? 'Required: $label' : null,
          ),
          if (predictions.isNotEmpty)
            Container(
              height: 150,
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: ListView.builder(
                itemCount: predictions.length,
                itemBuilder: (context, index) {
                  final prediction = predictions[index];
                  return ListTile(
                    title: Text(prediction['description'] ?? ''),
                    onTap: () async {
                      final placeId = prediction['place_id'];
                      try {
                        final details = await _placesService.getPlaceDetails(placeId);
                        setState(() {
                          controller.text = details['formatted_address'] ?? details['name'] ?? '';
                          predictions.clear();
                        });
                      } catch (e) {
                        _showSnackBar('Failed to fetch place details.');
                      }
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Required: $label' : null,
        onTap: () => _selectDate(context, controller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Invoice')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildSectionHeader('Invoice Details'),
              _buildTextField('Load ID', _loadIdController),
              _buildTextField('Billed To', _billedToController),
              _buildTextField('Billed To Address', _billedToAddressController),
              _buildPlaceAutocompleteField('Origin', _originController, _originPredictions, _onOriginChanged),
              _buildTextField('Origin Company Name', _originCompanyNameController),
              _buildPlaceAutocompleteField('Destination', _destinationController, _destinationPredictions, _onDestinationChanged),
              _buildTextField('Destination Company Name', _destinationCompanyNameController),
              _buildDateField('Pickup Date', _pickupDateController),
              _buildDateField('Delivery Date', _deliveryDateController),

              _buildSectionHeader('Payment Details'),
              _buildTextField(
                'Amount',
                _amountController,
                type: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required: Amount';
                  if (double.tryParse(val) == null) return 'Enter a valid number';
                  return null;
                },
              ),
              _buildTextField('Currency', _currencyController),
              _buildTextField(
                'Tax',
                _taxController,
                type: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required: Tax';
                  if (double.tryParse(val) == null) return 'Enter a valid number';
                  return null;
                },
              ),
              _buildTextField('Payment Method', _paymentMethodController),
              _buildDateField('Due Date', _dueDateController),

              _buildSectionHeader('Additional Info'),
              _buildTextField(
                'Accounting Email',
                _accountingEmailController,
                type: TextInputType.emailAddress,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required: Accounting Email';
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(val)) return 'Enter a valid email';
                  return null;
                },
              ),
              _buildTextField('Contact Info', _contactInfoController),

              // POD File info and remove option
              if (_podFile != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Expanded(child: Text('Attached POD: ${_podFile!.path.split('/').last}')),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => setState(() => _podFile = null),
                      )
                    ],
                  ),
                ),

              ElevatedButton.icon(
                icon: _isProcessingOcr
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.attach_file),
                label: const Text('Attach Proof of Delivery (POD)'),
                onPressed: _isProcessingOcr ? null : _pickLoadConfirmationFile,
              ),

              if (_ocrResultMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 16),
                  child: Text(
                    _ocrResultMessage!,
                    style: TextStyle(color: _ocrResultMessage!.toLowerCase().contains('failed') ? Colors.red : Colors.green),
                  ),
                ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Create Invoice'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
