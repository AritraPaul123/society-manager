import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class OCRService {
  final TextRecognizer _textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  Future<Map<String, String>> scanEmiratesId(XFile imageFile) async {
    final inputImage = InputImage.fromFilePath(imageFile.path);
    final RecognizedText recognizedText = await _textRecognizer.processImage(
      inputImage,
    );

    String name = "";
    String idNumber = "";
    String nationality = "";
    String expiryDate = "";

    // Emirates ID pattern: 784-YEAR-ID-CHECK
    RegExp idPattern = RegExp(r'784-\d{4}-\d{7}-\d{1}');

    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        String text = line.text.trim();

        // Try to find ID number
        if (idPattern.hasMatch(text)) {
          idNumber = idPattern.stringMatch(text) ?? "";
        }

        // Simple logic to find name - usually after "Name" or "Name:"
        if (text.toLowerCase().contains("name")) {
          // Name is often on the next line or after a colon
          // This is a naive implementation, real OCR needs better filtering
        }
      }
    }

    return {
      'idNumber': idNumber,
      'name': name,
      'nationality': nationality,
      'expiryDate': expiryDate,
      'rawText': recognizedText.text,
    };
  }

  void dispose() {
    _textRecognizer.close();
  }
}
