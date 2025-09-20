import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

class RatchetState {
  final SecretKey rootKey;
  final SecretKey sendingChainKey;
  final SecretKey receivingChainKey;
  final SimplePublicKey? theirCurrentRatchetKey;
  final SimpleKeyPair ourCurrentRatchetKey;

  const RatchetState({
    required this.rootKey,
    required this.sendingChainKey,
    required this.receivingChainKey,
    required this.theirCurrentRatchetKey,
    required this.ourCurrentRatchetKey,
  });
}

class DoubleRatchetService {
  final X25519 _x = X25519();
  final Hkdf _hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);

  Future<RatchetState> initialize({
    required SecretKey sharedSecret,
    required bool isInitiator,
    required SimplePublicKey theirRatchetKey,
  }) async {
    final SimpleKeyPair ourKey = await _x.newKeyPair();
    final SecretKey rk = await _hkdf.deriveKey(secretKey: sharedSecret);
    final SecretKey ck = await _hkdf.deriveKey(secretKey: sharedSecret);
    return RatchetState(
      rootKey: rk,
      sendingChainKey: isInitiator ? ck : SecretKey(Uint8List(32)),
      receivingChainKey: isInitiator ? SecretKey(Uint8List(32)) : ck,
      theirCurrentRatchetKey: theirRatchetKey,
      ourCurrentRatchetKey: ourKey,
    );
  }

  Future<(RatchetState, SecretKey)> nextSendingKey(RatchetState st) async {
    final List<int> ckBytes = await st.sendingChainKey.extractBytes();
    final SecretKey msgKey = await _hkdf.deriveKey(secretKey: SecretKey(ckBytes));
    final SecretKey nextCk = await _hkdf.deriveKey(secretKey: SecretKey(<int>[...ckBytes, 0x01]));
    return (
      RatchetState(
        rootKey: st.rootKey,
        sendingChainKey: nextCk,
        receivingChainKey: st.receivingChainKey,
        theirCurrentRatchetKey: st.theirCurrentRatchetKey,
        ourCurrentRatchetKey: st.ourCurrentRatchetKey,
      ),
      msgKey,
    );
  }

  Future<(RatchetState, SecretKey)> nextReceivingKey(RatchetState st) async {
    final List<int> ckBytes = await st.receivingChainKey.extractBytes();
    final SecretKey msgKey = await _hkdf.deriveKey(secretKey: SecretKey(ckBytes));
    final SecretKey nextCk = await _hkdf.deriveKey(secretKey: SecretKey(<int>[...ckBytes, 0x01]));
    return (
      RatchetState(
        rootKey: st.rootKey,
        sendingChainKey: st.sendingChainKey,
        receivingChainKey: nextCk,
        theirCurrentRatchetKey: st.theirCurrentRatchetKey,
        ourCurrentRatchetKey: st.ourCurrentRatchetKey,
      ),
      msgKey,
    );
  }

  Future<(RatchetState, SecretKey)> dhRatchet(RatchetState st, SimplePublicKey newTheirKey) async {
    final SecretKey dh = await _x.sharedSecretKey(keyPair: st.ourCurrentRatchetKey, remotePublicKey: newTheirKey);
    final List<int> rkBytes = await st.rootKey.extractBytes();
    final Uint8List ikm = Uint8List.fromList(<int>[...rkBytes, ...await dh.extractBytes()]);
    final SecretKey newRk = await _hkdf.deriveKey(secretKey: SecretKey(ikm));
    final SecretKey sendingCk = await _hkdf.deriveKey(secretKey: newRk);
    final SecretKey receivingCk = await _hkdf.deriveKey(secretKey: newRk);
    final SimpleKeyPair ourKey = await _x.newKeyPair();
    return (
      RatchetState(
        rootKey: newRk,
        sendingChainKey: sendingCk,
        receivingChainKey: receivingCk,
        theirCurrentRatchetKey: newTheirKey,
        ourCurrentRatchetKey: ourKey,
      ),
      sendingCk,
    );
  }
}


