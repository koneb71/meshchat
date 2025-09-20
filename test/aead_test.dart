import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meshchat/crypto/aead.dart';

void main() {
  test('AEAD seal/open roundtrip', () async {
    final SecretKey key = SecretKey(Uint8List(32));
    final List<int> nonce = Uint8List(12);
    final Uint8List pt = Uint8List.fromList(<int>[1, 2, 3]);
    final Uint8List ad = Uint8List.fromList(<int>[9, 9]);
    final Uint8List ct = await aeadSeal(key: key, nonce12: nonce, plaintext: pt, ad: ad);
    final Uint8List rt = await aeadOpen(key: key, nonce12: nonce, cipherAndTag: ct, ad: ad);
    expect(rt, pt);
  });
}


