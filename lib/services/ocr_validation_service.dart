import 'dart:async';
import '../models/invoice.dart';

class OcrValidationService {
  // Simulate OCR processing delay for multiple documents
  Future<List<Map<String, dynamic>>> performOcrOnDocuments(List<String> documentPaths) async {
    await Future.delayed(const Duration(seconds: 2));
    // Stub: Return parsed data from OCR for each document
    return documentPaths.map((path) => {
      'documentPath': path,
      'signature': 'John Doe',
      'date': '2023-07-05',
      'total': 1500.00,
      'origin': 'New York, NY',
      'destination': 'Los Angeles, CA',
      'weight': 10000,
      'documentType': _detectDocumentType(path),
    }).toList();
  }

  // Detect document type based on file path or content (stub)
  String _detectDocumentType(String path) {
    if (path.toLowerCase().contains('pod')) return 'POD';
    if (path.toLowerCase().contains('lumper')) return 'Lumper';
    if (path.toLowerCase().contains('bol')) return 'BOL';
    return 'Unknown';
  }

  // Validate OCR data against invoice and load details
  bool validateOcrData(List<Map<String, dynamic>> ocrDataList, Invoice invoice) {
    bool allValid = true;
    for (var ocrData in ocrDataList) {
      if (ocrData['documentType'] == 'POD') {
        if (ocrData['origin'] != invoice.origin || ocrData['destination'] != invoice.destination) {
          allValid = false;
          break;
        }
      }
      if (ocrData['documentType'] == 'Lumper') {
        if (ocrData['total'] > invoice.amount) {
          allValid = false;
          break;
        }
      }
      if (ocrData['documentType'] == 'BOL') {
        if (ocrData['weight'] <= 0) {
          allValid = false;
          break;
        }
      }
    }
    return allValid;
  }
}
