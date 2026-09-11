import 'package:flutter/foundation.dart';

class OcrService {
  /// Deprecated mobile OCR service.
  /// Cross-platform FinPilot AI now utilizes byte-based Smart Receipt Expense and
  /// Universal Bank Statement Intelligence Center.
  static Future<String> extractTextFromImage(String imagePath) async {
    debugPrint('[OcrService] OCR is replaced with Smart Receipt Expense intelligence.');
    return '';
  }
}
