import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/invoice.dart';
import '../providers/invoice_provider.dart';

class BrokerInvoiceValidationScreen extends StatefulWidget {
  final String invoiceId;

  const BrokerInvoiceValidationScreen({super.key, required this.invoiceId, required String invoiceText});

  @override
  _BrokerInvoiceValidationScreenState createState() => _BrokerInvoiceValidationScreenState();
}

class _BrokerInvoiceValidationScreenState extends State<BrokerInvoiceValidationScreen> {
  late InvoiceProvider _invoiceProvider;
  Invoice? _invoice;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _invoiceProvider = Provider.of<InvoiceProvider>(context);
    _invoice = _invoiceProvider.invoices.firstWhere((inv) => inv.id == widget.invoiceId, orElse: () => throw Exception('Invoice not found'));
  }

  void _markAsPaid() async {
    if (_invoice != null) {
      await _invoiceProvider.markInvoiceAsPaid(_invoice!.id);
      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }

  void _flagInvoice() {
    if (_invoice != null) {
      _invoiceProvider.updateInvoiceStatus(_invoice!.id, 'Flagged');
      Navigator.of(context).pop();
    }
  }

  void _approveInvoice() {
    if (_invoice != null) {
      _invoiceProvider.updateInvoiceStatus(_invoice!.id, 'Approved');
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_invoice == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Invoice Validation')),
        body: const Center(child: Text('Invoice not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Invoice Validation')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Invoice ID: ${_invoice!.id}'),
              Text('Load ID: ${_invoice!.loadId}'),
              Text('Billed To: ${_invoice!.billedTo}'),
              Text('Amount: \$${_invoice!.amount.toStringAsFixed(2)}'),
              Text('Status: ${_invoice!.status}'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _approveInvoice,
                child: const Text('Approve Invoice'),
              ),
              ElevatedButton(
                onPressed: _flagInvoice,
                child: const Text('Flag Invoice'),
              ),
              ElevatedButton(
                onPressed: _markAsPaid,
                child: const Text('Mark as Paid'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
