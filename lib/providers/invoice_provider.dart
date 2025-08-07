import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:lboard/services/google_ocr_service.dart';
import '../models/invoice.dart';
// Removed duplicate/conflicting import of google_ocr_service.dart

class InvoiceProvider extends ChangeNotifier {
  final List<Invoice> _invoices = [];
  final GoogleOcrService _ocrService = GoogleOcrService();

  List<Invoice> get invoices => List.unmodifiable(_invoices);

  Future<List<Invoice>> getInvoicesForUser(String userId) async {
    return _invoices.where((inv) => inv.createdBy == userId || inv.billedTo == userId).toList();
  }

  Future<void> createInvoice(Invoice invoice) async {
    _invoices.add(invoice);
    notifyListeners();
  }

  Future<void> uploadPOD(String invoiceId, File file) async {
    final index = _invoices.indexWhere((inv) => inv.id == invoiceId);
    if (index != -1) {
      // Simulate upload and update podUrl
      _invoices[index] = _invoices[index].copyWith(
        podUrl: 'uploaded_file_url', // Replace with actual URL or file path
      );
      notifyListeners();

      // Trigger OCR validation after upload
      await _validateInvoiceWithOcr(_invoices[index]);
    }
  }

  Future<void> _validateInvoiceWithOcr(Invoice invoice) async {
    final documentPaths = <String>[];
    if (invoice.podUrl != null) {
      documentPaths.add(invoice.podUrl!);
    }
    // Add other document URLs like lumper receipts, BOL, etc. if available

    final ocrDataList = await _ocrService.performOcrOnDocuments(documentPaths);
    final isValid = _ocrService.validateOcrData(ocrDataList, invoice);

    // Combine OCR text from all documents
    final combinedOcrText = ocrDataList.map((data) => data['text'] ?? '').join('\n');

    final updatedInvoice = invoice.copyWith(
      ocrVerified: isValid,
      ocrText: combinedOcrText,
      status: isValid ? 'Approved' : 'Flagged',
    );

    final index = _invoices.indexWhere((inv) => inv.id == invoice.id);
    if (index != -1) {
      _invoices[index] = updatedInvoice;
      notifyListeners();
    }
  }

  void updateInvoiceStatus(String invoiceId, String status) {
    final index = _invoices.indexWhere((inv) => inv.id == invoiceId);
    if (index != -1) {
      final inv = _invoices[index];
      _invoices[index] = inv.copyWith(status: status);
      notifyListeners();
    }
  }

  Future<void> markInvoiceAsPaid(String invoiceId) async {
    final index = _invoices.indexWhere((inv) => inv.id == invoiceId);
    if (index != -1) {
      final inv = _invoices[index];
      _invoices[index] = inv.copyWith(status: 'Paid');
      notifyListeners();
    }
  }

  Future<void> updateInvoice(Invoice invoice) async {
    final index = _invoices.indexWhere((inv) => inv.id == invoice.id);
    if (index != -1) {
      _invoices[index] = invoice;
      notifyListeners();
    }
  }

  Future<Uint8List> generatePDF(Invoice invoice) async {
    return Uint8List(0);
  }
}
