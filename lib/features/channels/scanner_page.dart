import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final MobileScannerController _controller = MobileScannerController();
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Invite')),
      body: MobileScanner(
        controller: _controller,
        onDetect: (BarcodeCapture cap) async {
          if (_handled) return;
          if (cap.barcodes.isNotEmpty) {
            final String? raw = cap.barcodes.first.rawValue;
            if (raw != null && raw.isNotEmpty) {
              _handled = true;
              try {
                await _controller.stop();
              } catch (_) {}
              if (!mounted) return;
              Navigator.of(context).pop<String>(raw);
            }
          }
        },
      ),
    );
  }
}


