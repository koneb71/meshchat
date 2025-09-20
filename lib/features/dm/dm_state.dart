import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/persistence.dart';

class DmSession {
  final String peerId;
  final String? sharedSecretBase64;
  final int counter;
  const DmSession({required this.peerId, this.sharedSecretBase64, this.counter = 0});

  DmSession copyWith({String? sharedSecretBase64, int? counter}) => DmSession(
        peerId: peerId,
        sharedSecretBase64: sharedSecretBase64 ?? this.sharedSecretBase64,
        counter: counter ?? this.counter,
      );
}

class DmNotifier extends StateNotifier<Map<String, DmSession>> {
  final FileStore _store = FileStore();
  static const String _file = 'dm_sessions.json';
  DmNotifier() : super(const <String, DmSession>{}) {
    _load();
  }

  void setPreSharedSecret(String peerId, String base64) {
    final Map<String, DmSession> next = Map<String, DmSession>.from(state);
    next[peerId] = (state[peerId] ?? DmSession(peerId: peerId)).copyWith(sharedSecretBase64: base64, counter: 0);
    state = next;
    _save();
  }

  (SecretKey?, int) takeNextKey(String peerId) {
    final DmSession? s = state[peerId];
    if (s == null || s.sharedSecretBase64 == null || s.sharedSecretBase64!.isEmpty) return (null, 0);
    final List<int> secret = base64Decode(s.sharedSecretBase64!);
    final SecretKey key = SecretKey(secret);
    final int next = s.counter + 1;
    state = {
      ...state,
      peerId: s.copyWith(counter: next),
    };
    _save();
    return (key, next);
  }

  List<int> nonceFromCounter(int counter) {
    final ByteData bd = ByteData(12);
    bd.setUint64(4, counter);
    return bd.buffer.asUint8List();
  }

  Future<void> _load() async {
    final Map<String, dynamic> json = await _store.readJsonMap(_file);
    final Map<String, DmSession> loaded = <String, DmSession>{};
    json.forEach((String k, dynamic v) {
      final Map<String, dynamic> m = v as Map<String, dynamic>;
      loaded[k] = DmSession(peerId: k, sharedSecretBase64: m['sk'] as String?, counter: (m['ctr'] as int?) ?? 0);
    });
    if (loaded.isNotEmpty) state = loaded;
  }

  Future<void> _save() async {
    final Map<String, dynamic> json = <String, dynamic>{};
    state.forEach((String k, DmSession v) {
      json[k] = <String, dynamic>{'sk': v.sharedSecretBase64, 'ctr': v.counter};
    });
    await _store.writeJson(_file, json);
  }
}

final StateNotifierProvider<DmNotifier, Map<String, DmSession>> dmProvider =
    StateNotifierProvider<DmNotifier, Map<String, DmSession>>((StateNotifierProviderRef<DmNotifier, Map<String, DmSession>> ref) {
  return DmNotifier();
});


