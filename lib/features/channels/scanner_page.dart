import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerPage extends StatelessWidget {
  const ScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Invite')),
      body: MobileScanner(
        onDetect: (BarcodeCapture cap) {
          if (cap.barcodes.isNotEmpty) {
            final String? raw = cap.barcodes.first.rawValue;
            if (raw != null && raw.isNotEmpty) {
              Navigator.of(context).pop<String>(raw);
            }
          }
        },
      ),
    );
  }
}


