import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  /// Extracts real recognized text from an image file using google_mlkit_text_recognition.
  /// Throws descriptive exceptions on file or recognition errors.
  static Future<String> extractTextFromImage(String imagePath) async {
    final file = File(imagePath);
    if (!await file.exists()) {
      throw Exception('Image file does not exist at path: $imagePath');
    }

    // Google ML Kit Text Recognition is supported on Android and iOS
    if (!kIsWeb && !(Platform.isAndroid || Platform.isIOS)) {
      debugPrint('[OcrService] ML Kit is only supported on Android and iOS. Platform: ${Platform.operatingSystem}');
      return '';
    }

    final inputImage = InputImage.fromFilePath(imagePath);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);
      return recognizedText.text;
    } on Exception catch (e) {
      final errStr = e.toString().toLowerCase();
      if (errStr.contains('download') || errStr.contains('waiting')) {
        debugPrint('[OcrService] ML Kit model is being downloaded by Google Play Services.');
      } else {
        debugPrint('[OcrService] ML Kit error: $e');
      }
      rethrow;
    } finally {
      await textRecognizer.close();
    }
  }
}
