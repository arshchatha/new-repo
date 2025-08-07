import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import '../models/invoice.dart';
import '../providers/invoice_provider.dart';
import 'broker_invoice_validation_screen.dart';

class BrokerInvoicingScreen extends StatefulWidget {
  const BrokerInvoicingScreen({super.key});

  @override
  _BrokerInvoicingScreenState createState() => _BrokerInvoicingScreenState();
}

class _BrokerInvoicingScreenState extends State<BrokerInvoicingScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Invoice> _receivedInvoices = [];
  List<Invoice> _pendingInvoices = [];
  List<Invoice> _paidInvoices = [];

  bool _isProcessingOcr = false;
  String? _ocrResultMessage;
  String? _googleOcrApiKey;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadInvoices();
    _googleOcrApiKey = 'AIzaSyCWht0kEJMXOEHaUjNlERQEz9iVUS6cN2o'; // Google Cloud API key provided by user
  }

  Future<void> _loadInvoices() async {
    final provider = Provider.of<InvoiceProvider>(context, listen: false);
    final userId = 'currentUserId'; // Replace with actual user id
    final invoices = await provider.getInvoicesForUser(userId);
    if (!mounted) return;
    setState(() {
      _receivedInvoices = invoices.where((inv) => inv.status.toLowerCase() == 'received').toList();
      _pendingInvoices = invoices.where((inv) => inv.status.toLowerCase() == 'pending').toList();
      _paidInvoices = invoices.where((inv) => inv.status.toLowerCase() == 'paid').toList();
    });
  }

  Widget _buildInvoiceList(List<Invoice> invoices) {
    if (invoices.isEmpty) {
      return const Center(child: Text('No invoices found.'));
    }
    return ListView.builder(
      itemCount: invoices.length,
      itemBuilder: (context, index) {
        final invoice = invoices[index];
        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            title: Text('Invoice #${invoice.id}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Amount: \$${invoice.amount.toStringAsFixed(2)}'),
                Text('Status: ${invoice.status}'),
                if (invoice.ocrVerified)
                  const Chip(
                    label: Text('OCR Verified'),
                    backgroundColor: Colors.green,
                    labelStyle: TextStyle(color: Colors.white),
                  ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.document_scanner),
                  tooltip: 'Process with OCR',
                  onPressed: () => _startOcrDetection(invoice),
                ),
                IconButton(
                  icon: const Icon(Icons.visibility),
                  tooltip: 'View Details',
                  onPressed: () => _navigateToValidationScreen(invoice),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _startOcrDetection(Invoice invoice) async {
    if (!mounted) return;
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
        final ocrText = await _processImageWithGoogleOCR(file);

        if (ocrText.isNotEmpty) {
          if (!mounted) return;
          final provider = Provider.of<InvoiceProvider>(context, listen: false);
          await provider.updateInvoice(
            invoice.copyWith(
              ocrText: ocrText,
              ocrVerified: true,
              status: 'verified',
            ),
          );

          await _loadInvoices();
          
          if (!mounted) return;
          setState(() {
            _ocrResultMessage = 'Invoice successfully processed with OCR.\n\nExtracted Text:\n$ocrText';
          });
        } else {
          if (!mounted) return;
          setState(() {
            _ocrResultMessage = 'No text detected in the document.';
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _ocrResultMessage = 'OCR processing failed: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingOcr = false;
        });
      }
    }

    if (!mounted) return;
    _showOcrResultDialog(invoice);
  }

  Future<String> _processImageWithGoogleOCR(File imageFile) async {
    final url = Uri.parse('https://vision.googleapis.com/v1/images:annotate?key=$_googleOcrApiKey');
    
    // Read the image file as bytes
    final imageBytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(imageBytes);

    final response = await http.post(
      url,
      body: jsonEncode({
        'requests': [
          {
            'image': {'content': base64Image},
            'features': [{'type': 'TEXT_DETECTION'}]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final textAnnotations = responseData['responses'][0]['textAnnotations'] ?? [];
      if (textAnnotations.isNotEmpty) {
        return textAnnotations[0]['description'] ?? '';
      }
      return '';
    } else {
      throw Exception('Google OCR API request failed with status ${response.statusCode}');
    }
  }

  void _navigateToValidationScreen(Invoice invoice) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BrokerInvoiceValidationScreen(
          invoiceId: invoice.id,
          invoiceText: invoice.ocrText,
        ),
      ),
    );
  }

  void _showOcrResultDialog(Invoice invoice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('OCR Result - Invoice #${invoice.id}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isProcessingOcr)
                const Center(child: CircularProgressIndicator()),
              if (_ocrResultMessage != null)
                Text(_ocrResultMessage!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (!_isProcessingOcr && _ocrResultMessage != null && _ocrResultMessage!.contains('successfully'))
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (!mounted) return;
                _navigateToValidationScreen(invoice);
              },
              child: const Text('View Details'),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Broker Invoicing'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.email), text: 'Received'),
            Tab(icon: Icon(Icons.pending), text: 'Pending'),
            Tab(icon: Icon(Icons.payment), text: 'Paid'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInvoiceList(_receivedInvoices),
          _buildInvoiceList(_pendingInvoices),
          _buildInvoiceList(_paidInvoices),
        ],
      ),
      // Remove the Create Invoice floating action button for broker invoicing screen
      // floatingActionButton: FloatingActionButton(
      //   tooltip: 'Create Invoice',
      //   child: const Icon(Icons.add),
      //   onPressed: () {
      //     Navigator.of(context).push(
      //       MaterialPageRoute(
      //         builder: (context) => const CreateInvoiceScreen(),
      //       ),
      //     );
      //   },
      // ),
    );
  }
}
