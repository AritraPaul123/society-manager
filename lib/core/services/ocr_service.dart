import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:io';

class OCRService {
  static final TextRecognizer _textRecognizer = GoogleMlKit.vision
      .textRecognizer();

  /// Scans Emirates ID using OCR to extract text information
  static Future<Map<String, String>?> scanEmiratesIdOCR() async {
    try {
      final cameras = await availableCameras();
      final firstCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        firstCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await controller.initialize();

      // Take a picture
      final XFile photo = await controller.takePicture();
      await controller.dispose();

      // Process the image for text recognition
      final inputImage = InputImage.fromFilePath(photo.path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(
        inputImage,
      );

      // Extract relevant information from the text
      final extractedData = _parseEmiratesIdText(recognizedText.text);

      return extractedData;
    } catch (e) {
      print('OCR Error: $e');
      return null;
    }
  }

  /// Parses the recognized text to extract Emirates ID information
  static Map<String, String> _parseEmiratesIdText(String rawText) {
    final data = <String, String>{};

    // Look for common Emirates ID patterns
    final lines = rawText.split('\n');

    for (String line in lines) {
      line = line.trim();

      // Extract ID number (usually starts with 784)
      if (line.contains('784') && line.length >= 12) {
        // Remove non-alphanumeric characters except spaces
        final idMatch = RegExp(r'784[0-9\s\-]{8,}').firstMatch(line);
        if (idMatch != null) {
          data['idNumber'] = idMatch.group(0)!.replaceAll(RegExp(r'[^\d]'), '');
        }
      }

      // Look for name (usually contains alphabetic characters)
      if (RegExp(r'[A-Z]{2,}').hasMatch(line) && !line.contains('784')) {
        // Filter out common non-name words
        if (!line.contains('UAE') &&
            !line.contains('EMIRATES') &&
            !line.contains('CARD') &&
            !line.contains('ID') &&
            !line.contains('DOB') &&
            !line.contains('NATIONALITY')) {
          data['fullName'] = line.trim();
        }
      }

      // Extract nationality
      if (line.toLowerCase().contains('nationality') ||
          line.toLowerCase().contains('domicile')) {
        data['nationality'] = line
            .replaceAll(RegExp(r'nationality|domicile|:|\s+'), '')
            .trim();
      }

      // Extract date of birth
      if (line.toLowerCase().contains('birth') ||
          line.contains(RegExp(r'\d{2}/\d{2}/\d{4}')) ||
          line.contains(RegExp(r'\d{4}-\d{2}-\d{2}'))) {
        final dateMatch = RegExp(
          r'\d{2}/\d{2}/\d{4}|\d{4}-\d{2}-\d{2}|\d{2}-\d{2}-\d{4}',
        ).firstMatch(line);
        if (dateMatch != null) {
          data['dateOfBirth'] = dateMatch.group(0)!;
        }
      }

      // Extract gender
      if (line.toLowerCase().contains('male') ||
          line.toLowerCase().contains('female')) {
        data['gender'] = line.toLowerCase().contains('male')
            ? 'Male'
            : 'Female';
      }
    }

    return data;
  }

  /// Extracts information from checkpoint QR codes
  static Map<String, String> parseCheckpointQRCode(String qrCodeData) {
    // Checkpoint QR codes typically contain a simple identifier
    // Format could be: "CHECKPOINT_001", "PATROL_CP_002", "MAIN_GATE_001", etc.
    return {'checkpointId': qrCodeData, 'rawData': qrCodeData};
  }

  /// Disposes of the text recognizer
  static Future<void> dispose() async {
    await _textRecognizer.close();
  }
}
