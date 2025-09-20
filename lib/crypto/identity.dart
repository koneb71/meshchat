import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

class IdentityKeys {
  final SimpleKeyPair ed25519;
  final SimpleKeyPair x25519;
  final SimplePublicKey ed25519Pub;
  final SimplePublicKey x25519Pub;
  final String displayName;
  final String safetyNumber;

  IdentityKeys({
    required this.ed25519,
    required this.x25519,
    required this.ed25519Pub,
    required this.x25519Pub,
    required this.displayName,
    required this.safetyNumber,
  });
}

class IdentityService {
  final Ed25519 _ed = Ed25519();
  final X25519 _x = X25519();
  final Sha256 _sha256 = Sha256();

  Future<IdentityKeys> generate(String displayName) async {
    final SimpleKeyPair ed = await _ed.newKeyPair();
    final SimplePublicKey edPub = await ed.extractPublicKey();
    final SimpleKeyPair xk = await _x.newKeyPair();
    final SimplePublicKey xPub = await xk.extractPublicKey();
    final String safety = await _deriveSafety(edPub);
    return IdentityKeys(
      ed25519: ed,
      x25519: xk,
      ed25519Pub: edPub,
      x25519Pub: xPub,
      displayName: displayName,
      safetyNumber: safety,
    );
  }

  Future<String> _deriveSafety(SimplePublicKey edPub) async {
    final Hash h = await _sha256.hash(edPub.bytes);
    // Return as groups of digits (base10) from the hash bytes
    final Uint8List bytes = Uint8List.fromList(h.bytes);
    final String hexStr = bytes.map((int b) => b.toRadixString(16).padLeft(2, '0')).join();
    // Keep compact but human-verifiable (e.g., 60 bits -> 15 hex chars)
    final String shortHex = hexStr.substring(0, 20);
    final String formatted = shortHex
        .toUpperCase()
        .replaceAllMapped(RegExp(r'(.{4})'), (Match m) => '${m.group(1)} ')
        .trim();
    return formatted;
  }
}


