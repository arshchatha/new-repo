import 'dart:async';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../models/invoice.dart';

class GoogleOcrService {
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<List<Map<String, dynamic>>> performOcrOnDocuments(List<String> documentPaths) async {
    List<Map<String, dynamic>> ocrResults = [];

    for (String path in documentPaths) {
      final inputImage = InputImage.fromFilePath(path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      // Extract relevant fields from recognizedText
      // This is a simplified example, real extraction would require parsing text blocks
      String signature = '';
      String date = '';
      double total = 0.0;
      String origin = '';
      String destination = '';
      double weight = 0.0;
      String documentType = _detectDocumentType(path);

      for (TextBlock block in recognizedText.blocks) {
        final text = block.text.toLowerCase();
        if (text.contains('signature')) {
          signature = block.text;
        }
        if (text.contains('date')) {
          date = block.text;
        }
        if (text.contains('total')) {
          final match = RegExp(r'total\\s*[:\\$]?\\s*(\\d+[\\.,]?\\d*)').firstMatch(text);
          if (match != null) {
            total = double.tryParse(match.group(1)!.replaceAll(',', '')) ?? 0.0;
          }
        }
        if (text.contains('origin')) {
          origin = block.text;
        }
        if (text.contains('destination')) {
          destination = block.text;
        }
        if (text.contains('weight')) {
          final match = RegExp(r'weight\\s*[:\\$]?\\s*(\\d+[\\.,]?\\d*)').firstMatch(text);
          if (match != null) {
            weight = double.tryParse(match.group(1)!.replaceAll(',', '')) ?? 0.0;
          }
        }
      }

      ocrResults.add({
        'documentPath': path,
        'signature': signature,
        'date': date,
        'total': total,
        'origin': origin,
        'destination': destination,
        'weight': weight,
        'documentType': documentType,
      });
    }

    return ocrResults;
  }

  String _detectDocumentType(String path) {
    if (path.toLowerCase().contains('pod')) return 'POD';
    if (path.toLowerCase().contains('lumper')) return 'Lumper';
    if (path.toLowerCase().contains('bol')) return 'BOL';
    return 'Unknown';
  }

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

  void dispose() {
    _textRecognizer.close();
  }
}
