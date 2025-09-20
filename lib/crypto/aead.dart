import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

Future<Uint8List> aeadSeal({
  required SecretKey key, required List<int> nonce12,
  required Uint8List plaintext, required Uint8List ad,
}) async {
  final Cipher algo = Chacha20.poly1305Aead();
  final SecretBox res = await algo.encrypt(
    plaintext,
    secretKey: key,
    nonce: nonce12,
    aad: ad,
  );
  return Uint8List.fromList(<int>[...res.cipherText, ...res.mac.bytes]);
}

Future<Uint8List> aeadOpen({
  required SecretKey key, required List<int> nonce12,
  required Uint8List cipherAndTag, required Uint8List ad,
}) async {
  final Cipher algo = Chacha20.poly1305Aead();
  if (cipherAndTag.length < 16) {
    throw const FormatException('cipher too short');
  }
  final int split = cipherAndTag.length - 16;
  final Uint8List ct = Uint8List.sublistView(cipherAndTag, 0, split);
  final Mac tag = Mac(Uint8List.sublistView(cipherAndTag, split));
  final List<int> res = await algo.decrypt(
    SecretBox(ct, nonce: nonce12, mac: tag),
    secretKey: key,
    aad: ad,
  );
  return Uint8List.fromList(res);
}


