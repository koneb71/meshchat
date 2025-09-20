import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models.dart' as models;
import 'persistence.dart';

class IdentityNotifier extends StateNotifier<models.Identity?> {
  final FileStore _store = FileStore();
  static const String _file = 'identity.json';
  final Sha256 _sha256 = Sha256();

  IdentityNotifier() : super(null) {
    _load();
  }

  Future<void> setDisplayName(String name) async {
    await ensureKeys();
    state = state!.copyWith(
      displayName: name,
      safetyNumber: await _safetyFromPublicKey(state!.pubEd25519),
    );
    await _save();
  }

  Future<String> _safetyFromPublicKey(String pubKeyBase64) async {
    final List<int> bytes = base64Decode(pubKeyBase64);
    final Hash h = await _sha256.hash(bytes);
    final String hex = h.bytes.map((int b) => b.toRadixString(16).padLeft(2, '0')).join().toUpperCase();
    final String short = hex.substring(0, 20);
    return short.replaceAllMapped(RegExp(r'(.{4})'), (Match m) => '${m.group(1)} ').trim();
  }

  Future<void> _load() async {
    final Map<String, dynamic> json = await _store.readJsonMap(_file);
    if (json.isEmpty) return;
    state = models.Identity.fromJson(json);
  }

  Future<void> _save() async {
    final models.Identity? s = state;
    if (s == null) return;
    await _store.writeJson(_file, s.toJson());
  }

  Future<void> ensureKeys() async {
    final models.Identity? cur = state;
    if (cur != null && cur.pubEd25519.isNotEmpty && cur.pubX25519.isNotEmpty) return;
    final SimpleKeyPair ed = await Ed25519().newKeyPair();
    final SimpleKeyPair xk = await X25519().newKeyPair();
    final SimplePublicKey edPub = await ed.extractPublicKey();
    final SimplePublicKey xPub = await xk.extractPublicKey();
    state = models.Identity(
      pubEd25519: base64Encode(edPub.bytes),
      privEd25519Ref: base64Encode(await ed.extractPrivateKeyBytes()),
      pubX25519: base64Encode(xPub.bytes),
      privX25519Ref: base64Encode(await xk.extractPrivateKeyBytes()),
      displayName: cur?.displayName ?? '',
      safetyNumber: await _safetyFromPublicKey(base64Encode(edPub.bytes)),
    );
    await _save();
  }

  Future<SimpleKeyPair> getEd25519KeyPair() async {
    await ensureKeys();
    final models.Identity s = state!;
    final List<int> priv = base64Decode(s.privEd25519Ref);
    final List<int> pub = base64Decode(s.pubEd25519);
    return SimpleKeyPairData(
      priv,
      publicKey: SimplePublicKey(pub, type: KeyPairType.ed25519),
      type: KeyPairType.ed25519,
    );
  }

  Future<SimpleKeyPair> getX25519KeyPair() async {
    await ensureKeys();
    final models.Identity s = state!;
    final List<int> priv = base64Decode(s.privX25519Ref);
    final List<int> pub = base64Decode(s.pubX25519);
    return SimpleKeyPairData(
      priv,
      publicKey: SimplePublicKey(pub, type: KeyPairType.x25519),
      type: KeyPairType.x25519,
    );
  }
}

final StateNotifierProvider<IdentityNotifier, models.Identity?> identityProvider =
    StateNotifierProvider<IdentityNotifier, models.Identity?>((StateNotifierProviderRef<IdentityNotifier, models.Identity?> ref) {
  return IdentityNotifier();
});


