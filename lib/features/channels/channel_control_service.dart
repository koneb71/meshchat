import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptography/cryptography.dart';

import '../../app/providers.dart';
import '../../mesh/packet.dart';
import '../../mesh/codec.dart';
import 'channel_state.dart';
import '../../data/models.dart';
import '../../data/identity_provider.dart';

class ChannelControlService {
  final Ref ref;
  ChannelControlService(this.ref) {
    _listen();
  }

  StreamSubscription? _sub;

  void _listen() {
    _sub ??= ref.read(messagesStreamProvider).listen((MeshPacket pkt) async {
      if (pkt.type != 3 || pkt.payload == null) return;
      try {
        final Map<String, dynamic> m = jsonDecode(utf8.decode(pkt.payload!)) as Map<String, dynamic>;
        if (m['type'] == 'rekey') {
          final String name = m['name'] as String;
          final String kc = m['kc'] as String;
          final int ctr = (m['ctr'] as num).toInt();
          final String sigB64 = (m['sig'] as String?) ?? '';
          final String signerB64 = (m['signer'] as String?) ?? '';
          if (pkt.channelId64 == _hash64(name) && sigB64.isNotEmpty && signerB64.isNotEmpty) {
            try {
              final Uint8List msg = Uint8List.fromList(utf8.encode('$name|$kc|$ctr'));
              final SimplePublicKey pk = SimplePublicKey(base64Url.decode(signerB64), type: KeyPairType.ed25519);
              final Signature sig = Signature(base64Url.decode(sigB64), publicKey: pk);
              final bool ok = await Ed25519().verify(msg, signature: sig);
              if (ok) {
                ref.read(channelsProvider.notifier).updateChannelKey(name, kc, ctr);
                ref.read(channelEventsControllerProvider).add(<String, String>{'type': 'rekey', 'channel': name});
              }
            } catch (_) {}
          }
        }
        if (m['type'] == 'member') {
          final String name = m['name'] as String;
          final String action = m['action'] as String;
          final String signerB64 = (m['signer'] as String?) ?? '';
          final String sigB64 = (m['sig'] as String?) ?? '';
          if (pkt.channelId64 == _hash64(name) && signerB64.isNotEmpty && sigB64.isNotEmpty) {
            try {
              final String userId = (m['userId'] as String?) ?? '';
              final String displayName = (m['displayName'] as String?) ?? '';
              final String role = (m['role'] as String?) ?? 'member';
              final int ts = (m['ts'] as num).toInt();
              final Uint8List msg = Uint8List.fromList(utf8.encode('$name|$action|$userId|$displayName|$role|$ts'));
              final SimplePublicKey pk = SimplePublicKey(base64Url.decode(signerB64), type: KeyPairType.ed25519);
              final Signature sig = Signature(base64Url.decode(sigB64), publicKey: pk);
              final bool ok = await Ed25519().verify(msg, signature: sig);
              if (ok) {
                if (action == 'add') {
                  ref.read(channelsProvider.notifier).addMember(name, Member(userId: userId, displayName: displayName, role: role, addedAt: DateTime.now()));
                } else if (action == 'remove') {
                  ref.read(channelsProvider.notifier).removeMember(name, userId);
                } else if (action == 'role') {
                  ref.read(channelsProvider.notifier).setRole(name, userId, role);
                }
                ref.read(channelEventsControllerProvider).add(<String, String>{'type': 'member', 'action': action, 'channel': name, 'userId': userId});
              }
            } catch (_) {}
          }
        }
      } catch (_) {
        // ignore non-json payloads
      }
    });
  }

  Future<void> dispose() async {
    await _sub?.cancel();
  }

  Future<void> sendRekey(String channelName) async {
    final chs = ref.read(channelsProvider);
    final ch = chs.firstWhere((c) => c.name == channelName, orElse: () => chs.first);
    if (!ch.encrypted || ch.senderKey == null) return;
    // Sign name|kc|ctr with Ed25519 identity key
    final SimpleKeyPair ed = await ref.read(identityProvider.notifier).getEd25519KeyPair();
    final SimplePublicKey edPub = await ed.extractPublicKey();
    final String name = ch.name;
    final String kc = ch.senderKey!;
    final int ctr = ch.messageCounter;
    final Uint8List msg = Uint8List.fromList(utf8.encode('$name|$kc|$ctr'));
    final Signature sig = await Ed25519().sign(msg, keyPair: ed);
    final Map<String, dynamic> m = <String, dynamic>{
      'type': 'rekey',
      'name': name,
      'kc': kc,
      'ctr': ctr,
      'sig': base64Url.encode(sig.bytes),
      'signer': base64Url.encode(edPub.bytes),
    };
    final Uint8List payload = Uint8List.fromList(utf8.encode(jsonEncode(m)));
    final Uint8List msgId = _nextMsgId();
    final MeshPacket pkt = MeshPacket(
      version: 1,
      type: 3,
      ttl: 8,
      hop: 0,
      channelId64: _hash64(channelName),
      msgId: msgId,
      headerAd: null,
      payload: payload,
    );
    MeshCodec.encodeFrame(pkt);
    await ref.read(linkManagerProvider).broadcast(pkt);
  }

  Future<void> sendAddMember(String channelName, {required String userId, required String displayName, String role = 'member'}) async {
    await _sendMember(channelName, action: 'add', userId: userId, displayName: displayName, role: role);
  }

  Future<void> sendRemoveMember(String channelName, {required String userId}) async {
    await _sendMember(channelName, action: 'remove', userId: userId, displayName: '', role: 'member');
  }

  Future<void> sendSetRole(String channelName, {required String userId, required String role}) async {
    await _sendMember(channelName, action: 'role', userId: userId, displayName: '', role: role);
  }

  Future<void> _sendMember(String channelName, {required String action, required String userId, required String displayName, required String role}) async {
    final int ts = DateTime.now().millisecondsSinceEpoch;
    final SimpleKeyPair ed = await ref.read(identityProvider.notifier).getEd25519KeyPair();
    final SimplePublicKey edPub = await ed.extractPublicKey();
    final Uint8List toSign = Uint8List.fromList(utf8.encode('$channelName|$action|$userId|$displayName|$role|$ts'));
    final Signature sig = await Ed25519().sign(toSign, keyPair: ed);
    final Map<String, dynamic> m = <String, dynamic>{
      'type': 'member',
      'name': channelName,
      'action': action,
      'userId': userId,
      'displayName': displayName,
      'role': role,
      'ts': ts,
      'sig': base64Url.encode(sig.bytes),
      'signer': base64Url.encode(edPub.bytes),
    };
    final Uint8List payload = Uint8List.fromList(utf8.encode(jsonEncode(m)));
    final Uint8List msgId = _nextMsgId();
    final MeshPacket pkt = MeshPacket(
      version: 1,
      type: 3,
      ttl: 8,
      hop: 0,
      channelId64: _hash64(channelName),
      msgId: msgId,
      headerAd: null,
      payload: payload,
    );
    MeshCodec.encodeFrame(pkt);
    await ref.read(linkManagerProvider).broadcast(pkt);
  }

  int _ctr = 0;
  Uint8List _nextMsgId() {
    final Uint8List id = Uint8List(12);
    _ctr++;
    final ByteData bd = ByteData(8)..setUint64(0, _ctr);
    id.setAll(5, bd.buffer.asUint8List().sublist(1));
    return id;
  }

  int _hash64(String s) {
    int hash = 1125899906842597;
    for (final int code in s.codeUnits) {
      hash = (hash * 1099511628211) ^ code;
    }
    return hash & 0x7FFFFFFFFFFFFFFF;
  }
}

final Provider<ChannelControlService> channelControlServiceProvider = Provider<ChannelControlService>((ProviderRef<ChannelControlService> ref) {
  final svc = ChannelControlService(ref);
  ref.onDispose(svc.dispose);
  return svc;
});


