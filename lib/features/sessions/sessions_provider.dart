import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptography/cryptography.dart';

import '../../crypto/x3dh.dart';
import '../../crypto/double_ratchet.dart';
import '../../app/providers.dart';
import '../../mesh/packet.dart';
import '../../mesh/codec.dart';
import '../../data/identity_provider.dart';
import '../../data/persistence.dart';

class SessionState {
  final String peerId;
  final RatchetState? ratchet;
  const SessionState({required this.peerId, this.ratchet});

  SessionState copyWith({RatchetState? ratchet}) => SessionState(peerId: peerId, ratchet: ratchet ?? this.ratchet);
}

class SessionsNotifier extends StateNotifier<List<SessionState>> {
  SessionsNotifier(this.ref) : super(const <SessionState>[]) {
    _load();
    _listenForControl();
  }

  final Ref ref;
  final X3DHService _x3dh = X3DHService();
  final DoubleRatchetService _dr = DoubleRatchetService();
  final FileStore _store = FileStore();
  static const String _file = 'sessions.json';

  static int get dmControlChannelId64 => _hash64('DM_CONTROL');
  int _counter = 0;

  void addPeer(String peerId) {
    if (state.any((SessionState s) => s.peerId == peerId)) return;
    state = <SessionState>[...state, SessionState(peerId: peerId)];
    _save();
  }

  Future<void> initiateSession(String peerId, PreKeyBundle bundle, SimpleKeyPair ourIdentityX25519) async {
    final X3DHResult r = await _x3dh.initiate(ourIdentityX25519: ourIdentityX25519, theirBundle: bundle);
    final RatchetState rs = await _dr.initialize(sharedSecret: r.sharedSecret, isInitiator: true, theirRatchetKey: r.ephPublicKey);
    _setRatchet(peerId, rs);
    // Send handshake over control channel with eph key
    final Map<String, dynamic> msg = <String, dynamic>{
      'type': 'x3dh_init',
      'peer': peerId,
      'eph': base64Url.encode(r.ephPublicKey.bytes),
    };
    await _sendControl(jsonEncode(msg));
  }

  RatchetState? ratchetFor(String peerId) {
    try {
      return state.firstWhere((SessionState s) => s.peerId == peerId).ratchet;
    } catch (_) {
      return null;
    }
  }

  void updateRatchet(String peerId, RatchetState rs) {
    _setRatchet(peerId, rs);
  }

  Future<void> handleInitiate(Map<String, dynamic> m, SimpleKeyPair ourIdentityX25519, SimpleKeyPair spk, SimpleKeyPair? opk) async {
    final String peerId = m['peer'] as String;
    final SimplePublicKey theirEph = SimplePublicKey(base64Url.decode(m['eph'] as String), type: KeyPairType.x25519);
    final SecretKey shared = await _x3dh.respond(
      ourIdentityX25519: ourIdentityX25519,
      ourSignedPreKey: spk,
      ourOneTimePreKey: opk,
      theirIdentityX25519: await ourIdentityX25519.extractPublicKey(), // placeholder; normally from their prekey bundle
      theirEphKey: theirEph,
    );
    final RatchetState rs = await _dr.initialize(sharedSecret: shared, isInitiator: false, theirRatchetKey: theirEph);
    _setRatchet(peerId, rs);
    // Acknowledge
    await _sendControl(jsonEncode(<String, dynamic>{'type': 'x3dh_ack', 'peer': peerId}));
  }

  void _setRatchet(String peerId, RatchetState rs) {
    state = state.map((SessionState s) => s.peerId == peerId ? s.copyWith(ratchet: rs) : s).toList();
    _save();
  }

  void _listenForControl() {
    ref.read(messagesStreamProvider).listen((MeshPacket pkt) async {
      if (pkt.type == 3 && pkt.channelId64 == dmControlChannelId64 && pkt.payload != null) {
        try {
          final Map<String, dynamic> m = jsonDecode(utf8.decode(pkt.payload!)) as Map<String, dynamic>;
          if (m['type'] == 'prekey_request') {
            await _sendPreKeyBundle(m['peer'] as String?);
          } else if (m['type'] == 'prekey_bundle') {
            final String peerId = m['peer'] as String? ?? '';
            final SimplePublicKey idEd = SimplePublicKey(base64Url.decode(m['idEd'] as String), type: KeyPairType.ed25519);
            final SimplePublicKey idX = SimplePublicKey(base64Url.decode(m['idX'] as String), type: KeyPairType.x25519);
            final SimplePublicKey spk = SimplePublicKey(base64Url.decode(m['spk'] as String), type: KeyPairType.x25519);
            final Signature sig = Signature(base64Url.decode(m['sig'] as String), publicKey: idEd);
            final PreKeyBundle bundle = PreKeyBundle(identityEd25519: idEd, identityX25519: idX, signedPreKey: spk, oneTimePreKeys: const <SimplePublicKey>[], signedPreKeySignature: sig);
            final bool ok = await _x3dh.verifySignedPreKey(spk: spk, signature: sig, identityEd25519: idEd);
            if (!ok) return;
            final SimpleKeyPair ourIdX = await ref.read(identityProvider.notifier).getX25519KeyPair();
            await initiateSession(peerId, bundle, ourIdX);
          } else if (m['type'] == 'x3dh_init') {
            final SimpleKeyPair ik = await ref.read(identityProvider.notifier).getX25519KeyPair();
            // For demo, generate ephemeral signed prekey and respond
            final (SimpleKeyPair spk, _) = await _x3dh.generateSignedPreKey(await ref.read(identityProvider.notifier).getEd25519KeyPair());
            await handleInitiate(m, ik, spk, null);
          } else if (m['type'] == 'x3dh_ack') {
            // Session acknowledged; nothing else for now
          }
        } catch (_) {}
      }
    });
  }

  Future<void> requestPreKey(String peerId) async {
    await _sendControl(jsonEncode(<String, dynamic>{'type': 'prekey_request', 'peer': peerId}));
  }

  Future<void> _sendPreKeyBundle(String? targetPeer) async {
    final ed = await ref.read(identityProvider.notifier).getEd25519KeyPair();
    final x = await ref.read(identityProvider.notifier).getX25519KeyPair();
    final (SimpleKeyPair spk, Signature sig) = await _x3dh.generateSignedPreKey(ed);
    final SimplePublicKey edPub = await ed.extractPublicKey();
    final SimplePublicKey xPub = await x.extractPublicKey();
    final SimplePublicKey spkPub = await spk.extractPublicKey();
    final Map<String, dynamic> m = <String, dynamic>{
      'type': 'prekey_bundle',
      if (targetPeer != null) 'peer': targetPeer,
      'idEd': base64Url.encode(edPub.bytes),
      'idX': base64Url.encode(xPub.bytes),
      'spk': base64Url.encode(spkPub.bytes),
      'sig': base64Url.encode(sig.bytes),
    };
    await _sendControl(jsonEncode(m));
  }

  Future<void> _sendControl(String json) async {
    final Uint8List payload = Uint8List.fromList(utf8.encode(json));
    final Uint8List msgId = _nextMsgId();
    final MeshPacket pkt = MeshPacket(version: 1, type: 3, ttl: 8, hop: 0, channelId64: dmControlChannelId64, msgId: msgId, headerAd: null, payload: payload);
    MeshCodec.encodeFrame(pkt);
    await ref.read(linkManagerProvider).broadcast(pkt);
  }

  Uint8List _nextMsgId() {
    final Uint8List id = Uint8List(12);
    _counter++;
    final ByteData bd = ByteData(8)..setUint64(0, _counter);
    id.setAll(5, bd.buffer.asUint8List().sublist(1));
    return id;
  }

  Future<void> _load() async {
    final Map<String, dynamic> json = await _store.readJsonMap(SessionsNotifier._file);
    final List<SessionState> list = <SessionState>[];
    json.forEach((String peerId, dynamic v) {
      final Map<String, dynamic> m = v as Map<String, dynamic>;
      final RatchetState? rs = _decodeRatchet(m);
      list.add(SessionState(peerId: peerId, ratchet: rs));
    });
    if (list.isNotEmpty) state = list;
  }

  Future<void> _save() async {
    final Map<String, dynamic> json = <String, dynamic>{};
    for (final SessionState s in state) {
      json[s.peerId] = await _encodeRatchet(s.ratchet);
    }
    await _store.writeJson(SessionsNotifier._file, json);
  }

  Future<Map<String, dynamic>?> _encodeRatchet(RatchetState? st) async {
    if (st == null) return null;
    return <String, dynamic>{
      'rk': base64Url.encode(await st.rootKey.extractBytes()),
      'sk': base64Url.encode(await st.sendingChainKey.extractBytes()),
      'rk2': base64Url.encode(await st.receivingChainKey.extractBytes()),
      'their': st.theirCurrentRatchetKey != null ? base64Url.encode(st.theirCurrentRatchetKey!.bytes) : null,
      'ourPriv': base64Url.encode(await st.ourCurrentRatchetKey.extractPrivateKeyBytes()),
      'ourPub': base64Url.encode((await st.ourCurrentRatchetKey.extractPublicKey()).bytes),
    };
  }

  RatchetState? _decodeRatchet(Map<String, dynamic>? m) {
    if (m == null) return null;
    try {
      final SecretKey rk = SecretKey(base64Url.decode(m['rk'] as String));
      final SecretKey sk = SecretKey(base64Url.decode(m['sk'] as String));
      final SecretKey rk2 = SecretKey(base64Url.decode(m['rk2'] as String));
      final SimplePublicKey? their = (m['their'] as String?) != null ? SimplePublicKey(base64Url.decode(m['their'] as String), type: KeyPairType.x25519) : null;
      final SimpleKeyPair our = SimpleKeyPairData(
        base64Url.decode(m['ourPriv'] as String),
        publicKey: SimplePublicKey(base64Url.decode(m['ourPub'] as String), type: KeyPairType.x25519),
        type: KeyPairType.x25519,
      );
      return RatchetState(rootKey: rk, sendingChainKey: sk, receivingChainKey: rk2, theirCurrentRatchetKey: their, ourCurrentRatchetKey: our);
    } catch (_) {
      return null;
    }
  }
}

final StateNotifierProvider<SessionsNotifier, List<SessionState>> sessionsProvider =
    StateNotifierProvider<SessionsNotifier, List<SessionState>>((StateNotifierProviderRef<SessionsNotifier, List<SessionState>> ref) {
  return SessionsNotifier(ref);
});

int _hash64(String s) {
  int hash = 1125899906842597;
  for (final int code in s.codeUnits) { hash = (hash * 1099511628211) ^ code; }
  return hash & 0x7FFFFFFFFFFFFFFF;
}

 


