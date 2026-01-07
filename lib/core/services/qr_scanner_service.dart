import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/material.dart';

class QRScannerService {
  static Future<String?> scanQRCode(BuildContext context) async {
    String? result;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            AppBar(
              title: const Text('Scan QR Code'),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Expanded(
              child: MobileScanner(
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty) {
                    result = barcodes.first.rawValue;
                    Navigator.pop(context);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
    return result;
  }
}
