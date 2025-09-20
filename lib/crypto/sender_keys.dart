import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

class SenderKeyState {
  final SecretKey currentKey;
  final int counter;
  final DateTime createdAt;
  final DateTime? rotatedAt;

  const SenderKeyState({
    required this.currentKey,
    required this.counter,
    required this.createdAt,
    this.rotatedAt,
  });
}

class SenderKeysService {
  Future<List<int>> _random32() async {
    final SecretKey k = await Chacha20.poly1305Aead().newSecretKey();
    return k.extractBytes();
  }

  Future<SenderKeyState> create() async {
    final SecretKey key = SecretKey(await _random32());
    return SenderKeyState(currentKey: key, counter: 0, createdAt: DateTime.now());
  }

  Future<(SenderKeyState, SecretKey, List<int>)> nextMessageKey(SenderKeyState st) async {
    final int nextCounter = st.counter + 1;
    final SecretKey key = st.currentKey;
    // Nonce: 12 bytes, derived from counter
    final ByteData bd = ByteData(12);
    bd.setUint64(4, nextCounter);
    final List<int> nonce12 = bd.buffer.asUint8List();
    return (
      SenderKeyState(currentKey: key, counter: nextCounter, createdAt: st.createdAt, rotatedAt: st.rotatedAt),
      key,
      nonce12,
    );
  }

  Future<SenderKeyState> rotate(SenderKeyState st) async {
    final SecretKey newKey = SecretKey(await _random32());
    return SenderKeyState(currentKey: newKey, counter: 0, createdAt: st.createdAt, rotatedAt: DateTime.now());
  }
}


