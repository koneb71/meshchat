import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

class PreKeyBundle {
  final SimplePublicKey identityEd25519;
  final SimplePublicKey identityX25519;
  final SimplePublicKey signedPreKey;
  final List<SimplePublicKey> oneTimePreKeys;
  final Signature signedPreKeySignature;

  const PreKeyBundle({
    required this.identityEd25519,
    required this.identityX25519,
    required this.signedPreKey,
    required this.oneTimePreKeys,
    required this.signedPreKeySignature,
  });
}

class X3DHResult {
  final SecretKey sharedSecret;
  final SimplePublicKey ephPublicKey;
  final SimplePublicKey? usedOneTimePreKey;

  const X3DHResult({
    required this.sharedSecret,
    required this.ephPublicKey,
    this.usedOneTimePreKey,
  });
}

class X3DHService {
  final X25519 _x = X25519();
  final Ed25519 _ed = Ed25519();
  final Hkdf _hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);

  Future<(SimpleKeyPair, Signature)> generateSignedPreKey(SimpleKeyPair identityEd25519) async {
    final SimpleKeyPair spk = await _x.newKeyPair();
    final SimplePublicKey spkPub = await spk.extractPublicKey();
    final Signature sig = await _ed.sign(spkPub.bytes, keyPair: identityEd25519);
    return (spk, sig);
  }

  Future<bool> verifySignedPreKey({
    required SimplePublicKey spk,
    required Signature signature,
    required SimplePublicKey identityEd25519,
  }) async {
    try {
      // cryptography 2.x verify uses Signature (which may contain publicKey).
      // We verify the signed prekey bytes using the identity public key present in Signature.
      await _ed.verify(spk.bytes, signature: Signature(signature.bytes, publicKey: identityEd25519));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<X3DHResult> initiate({
    required SimpleKeyPair ourIdentityX25519,
    required PreKeyBundle theirBundle,
    SimplePublicKey? chosenOneTimePreKey,
  }) async {
    final SimpleKeyPair eph = await _x.newKeyPair();
    final SimplePublicKey ephPub = await eph.extractPublicKey();

    final SecretKey dh1 = await _x.sharedSecretKey(keyPair: ourIdentityX25519, remotePublicKey: theirBundle.signedPreKey);
    final SecretKey dh2 = await _x.sharedSecretKey(keyPair: eph, remotePublicKey: theirBundle.identityX25519);
    final SecretKey dh3 = await _x.sharedSecretKey(keyPair: eph, remotePublicKey: theirBundle.signedPreKey);
    SecretKey? dh4;
    if (chosenOneTimePreKey != null) {
      dh4 = await _x.sharedSecretKey(keyPair: eph, remotePublicKey: chosenOneTimePreKey);
    }

    final Uint8List ikm = await _concatSecrets(<SecretKey>[dh1, dh2, dh3, if (dh4 != null) dh4]);
    final SecretKey sk = await _hkdf.deriveKey(secretKey: SecretKey(ikm));
    return X3DHResult(sharedSecret: sk, ephPublicKey: ephPub, usedOneTimePreKey: chosenOneTimePreKey);
  }

  Future<SecretKey> respond({
    required SimpleKeyPair ourIdentityX25519,
    required SimpleKeyPair ourSignedPreKey,
    required SimpleKeyPair? ourOneTimePreKey,
    required SimplePublicKey theirIdentityX25519,
    required SimplePublicKey theirEphKey,
  }) async {
    final SecretKey dh1 = await _x.sharedSecretKey(keyPair: ourSignedPreKey, remotePublicKey: theirIdentityX25519);
    final SecretKey dh2 = await _x.sharedSecretKey(keyPair: ourIdentityX25519, remotePublicKey: theirEphKey);
    final SecretKey dh3 = await _x.sharedSecretKey(keyPair: ourSignedPreKey, remotePublicKey: theirEphKey);
    SecretKey? dh4;
    if (ourOneTimePreKey != null) {
      dh4 = await _x.sharedSecretKey(keyPair: ourOneTimePreKey, remotePublicKey: theirEphKey);
    }
    final Uint8List ikm = await _concatSecrets(<SecretKey>[dh1, dh2, dh3, if (dh4 != null) dh4]);
    return _hkdf.deriveKey(secretKey: SecretKey(ikm));
  }

  Future<Uint8List> _concatSecrets(List<SecretKey> keys) async {
    int total = 0;
    final List<Uint8List> parts = <Uint8List>[];
    for (final SecretKey k in keys) {
      final List<int> bytes = await k.extractBytes();
      final Uint8List b = Uint8List.fromList(bytes);
      parts.add(b); total += b.length;
    }
    final Uint8List out = Uint8List(total);
    int off = 0;
    for (final Uint8List p in parts) { out.setRange(off, off + p.length, p); off += p.length; }
    return out;
  }
}


