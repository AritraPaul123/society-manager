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

    // Emirates ID patterns - flexible to handle OCR errors
    RegExp idPattern = RegExp(r'[17]84[-\s]?\d{4}[-\s]?\d{7}[-\s]?\d{1}');
    RegExp datePattern = RegExp(r'\d{2}[/-]\d{2}[/-]\d{4}');
    
    // Get all text lines
    List<String> allLines = [];
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        String text = line.text.trim();
        if (text.isNotEmpty) {
          allLines.add(text);
        }
      }
    }

    // Extract ID number first - handle OCR misreading 7 as 1
    for (String line in allLines) {
      if (idPattern.hasMatch(line)) {
        String match = idPattern.stringMatch(line) ?? "";
        // Normalize: fix common OCR error (184 -> 784) and format
        idNumber = match.replaceAll(RegExp(r'[\s]'), '-');
        if (idNumber.startsWith('184-')) {
          idNumber = idNumber.replaceFirst('184-', '784-');
        }
        break;
      }
    }

    // Extract full name - handle various OCR formats
    for (int i = 0; i < allLines.length; i++) {
      String line = allLines[i];
      String lowerLine = line.toLowerCase();

      // Check if line contains "name:" or "name" followed by the actual name
      if (lowerLine.startsWith('name:') || lowerLine.startsWith('name')) {
        String extractedName = '';
        
        if (lowerLine.startsWith('name:')) {
          // Extract text after "name:"
          extractedName = line.substring(5).trim();
        } else if (lowerLine.startsWith('name')) {
          // Extract text after "name" (no colon)
          extractedName = line.substring(4).trim();
        }
        
        if (extractedName.isNotEmpty && 
            extractedName.length > 5 &&
            !datePattern.hasMatch(extractedName) &&
            !idPattern.hasMatch(extractedName) &&
            !extractedName.toLowerCase().contains('nationality')) {
          name = extractedName;
          break;
        }
      }
    }

    print('=== OCR EXTRACTION ===');
    print('ID Number: $idNumber');
    print('Full Name: $name');
    print('All text: ${allLines.join(" | ")}');
    print('=== END OCR ===');

    return {
      'idNumber': idNumber,
      'name': name,
      'rawText': recognizedText.text,
    };
  }

  void dispose() {
    _textRecognizer.close();
  }
}
