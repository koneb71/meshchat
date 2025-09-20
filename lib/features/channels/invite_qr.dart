import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class InviteQrPage extends StatelessWidget {
  final String bundle;
  const InviteQrPage({super.key, required this.bundle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Invite')),
      body: Center(
        child: QrImageView(data: bundle, size: 240),
      ),
    );
  }
}


