import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'ocr_service.dart';

class EmiratesIdData {
  final String idNumber;
  final String fullName;
  final String nationality;
  final String dateOfBirth;
  final String gender;
  final String expiryDate;
  final String rawData;

  EmiratesIdData({
    required this.idNumber,
    required this.fullName,
    required this.nationality,
    required this.dateOfBirth,
    required this.gender,
    required this.expiryDate,
    required this.rawData,
  });

  factory EmiratesIdData.fromQRCode(String qrData) {
    // Emirates ID QR code format varies, but commonly contains pipe-separated values
    // Format example: IDN|784XXXXXXXXXX|NAME|DOB|NATIONALITY|GENDER|EXPIRY
    try {
      final parts = qrData.split('|');

      // Try to extract fields based on common Emirates ID QR format
      String idNumber = '';
      String fullName = '';
      String nationality = '';
      String dateOfBirth = '';
      String gender = '';
      String expiryDate = '';

      // Look for ID number pattern (784-XXXX-XXXXXXX-X or 784XXXXXXXXXX)
      for (var part in parts) {
        if (part.startsWith('784') && part.length >= 12) {
          idNumber = part;
        }
      }

      // If we have enough parts, try to map them
      if (parts.length >= 2) {
        // Common format has name at index 1 or 2
        fullName = parts.length > 2 ? parts[2] : parts[1];
      }

      if (parts.length >= 4) {
        dateOfBirth = parts[3];
      }

      if (parts.length >= 5) {
        nationality = parts[4];
      }

      if (parts.length >= 6) {
        gender = parts[5];
      }

      if (parts.length >= 7) {
        expiryDate = parts[6];
      }

      return EmiratesIdData(
        idNumber: idNumber,
        fullName: fullName,
        nationality: nationality,
        dateOfBirth: dateOfBirth,
        gender: gender,
        expiryDate: expiryDate,
        rawData: qrData,
      );
    } catch (e) {
      // If parsing fails, return raw data in idNumber field
      return EmiratesIdData(
        idNumber: qrData,
        fullName: '',
        nationality: '',
        dateOfBirth: '',
        gender: '',
        expiryDate: '',
        rawData: qrData,
      );
    }
  }

  Map<String, String> toMap() {
    return {
      'idNumber': idNumber,
      'fullName': fullName,
      'nationality': nationality,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'expiryDate': expiryDate,
      'rawData': rawData,
    };
  }
}

class QRScannerService {
  // Scan regular QR codes (for checkpoints)
  static Future<String?> scanQRCode(BuildContext context) async {
    return await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerScreen()),
    );
  }

  // Scan Emirates ID using OCR to extract data from the physical ID
  static Future<EmiratesIdData?> scanEmiratesId(BuildContext context) async {
    try {
      // Use OCR service to scan the Emirates ID
      final Map<String, String>? ocrData = await OCRService.scanEmiratesIdOCR();
      if (ocrData != null) {
        // Create EmiratesIdData from OCR results
        return EmiratesIdData(
          idNumber: ocrData['idNumber'] ?? '',
          fullName: ocrData['fullName'] ?? '',
          nationality: ocrData['nationality'] ?? '',
          dateOfBirth: ocrData['dateOfBirth'] ?? '',
          gender: ocrData['gender'] ?? '',
          expiryDate: ocrData['expiryDate'] ?? '',
          rawData: ocrData.toString(),
        );
      }
      return null;
    } catch (e) {
      print('Error scanning Emirates ID: \$e');
      return null;
    }
  }

  // Scan checkpoint QR codes specifically
  static Future<String?> scanCheckpointQR(BuildContext context) async {
    return await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const QRScannerScreen(title: 'Scan Checkpoint'),
      ),
    );
  }
}

class QRScannerScreen extends StatefulWidget {
  final String title;

  const QRScannerScreen({super.key, this.title = 'Scan QR Code'});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isScanned = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isScanned) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final barcode = barcodes.first;
      if (barcode.rawValue != null) {
        setState(() {
          _isScanned = true;
        });
        Navigator.pop(context, barcode.rawValue);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              cameraController.torchEnabled ? Icons.flash_on : Icons.flash_off,
            ),
            onPressed: () => cameraController.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(controller: cameraController, onDetect: _onDetect),
          // Scanning overlay
          CustomPaint(
            painter: ScannerOverlay(),
            child: const SizedBox.expand(),
          ),
          // Instructions
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Align QR code within the frame',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScannerOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double scanAreaSize = size.width * 0.7;
    final double left = (size.width - scanAreaSize) / 2;
    final double top = (size.height - scanAreaSize) / 2;
    final Rect scanArea = Rect.fromLTWH(left, top, scanAreaSize, scanAreaSize);

    // Draw semi-transparent overlay
    final Paint backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5);

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()
          ..addRRect(
            RRect.fromRectAndRadius(scanArea, const Radius.circular(16)),
          )
          ..close(),
      ),
      backgroundPaint,
    );

    // Draw border
    final Paint borderPaint = Paint()
      ..color = const Color(0xFF8063FC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawRRect(
      RRect.fromRectAndRadius(scanArea, const Radius.circular(16)),
      borderPaint,
    );

    // Draw corner indicators
    final Paint cornerPaint = Paint()
      ..color = const Color(0xFF8063FC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final double cornerLength = 30;

    // Top-left
    canvas.drawLine(
      Offset(left, top),
      Offset(left + cornerLength, top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left, top),
      Offset(left, top + cornerLength),
      cornerPaint,
    );

    // Top-right
    canvas.drawLine(
      Offset(left + scanAreaSize, top),
      Offset(left + scanAreaSize - cornerLength, top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left + scanAreaSize, top),
      Offset(left + scanAreaSize, top + cornerLength),
      cornerPaint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(left, top + scanAreaSize),
      Offset(left + cornerLength, top + scanAreaSize),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left, top + scanAreaSize),
      Offset(left, top + scanAreaSize - cornerLength),
      cornerPaint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(left + scanAreaSize, top + scanAreaSize),
      Offset(left + scanAreaSize - cornerLength, top + scanAreaSize),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left + scanAreaSize, top + scanAreaSize),
      Offset(left + scanAreaSize, top + scanAreaSize - cornerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
