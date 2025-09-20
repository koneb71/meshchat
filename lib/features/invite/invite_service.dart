import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../mesh/packet.dart';
import '../../mesh/codec.dart';
import '../../app/providers.dart';
import '../../app/providers.dart' as app;

class InviteService {
  final Ref ref;
  InviteService(this.ref) {
    _ensureWatch();
  }

  static int get inviteChannelId64 => _hash64('INVITE');
  int _counter = 0;
  StreamSubscription? _sub;

  void _ensureWatch() {
    _sub ??= ref.read(messagesStreamProvider).listen((MeshPacket pkt) {
      if (pkt.type == 3 && pkt.channelId64 == inviteChannelId64 && pkt.payload != null) {
        _handleInvite(pkt.payload!);
      }
    });
  }

  Future<void> dispose() async {
    await _sub?.cancel();
  }

  Future<void> sendInvite(String bundleJsonOrCode) async {
    final bool looksBase64 = RegExp(r'^[A-Za-z0-9_\-]+=*$').hasMatch(bundleJsonOrCode);
    final Map<String, dynamic> obj = looksBase64
        ? <String, dynamic>{'type': 'invite_code', 'code': bundleJsonOrCode}
        : <String, dynamic>{'type': 'invite', 'bundle': bundleJsonOrCode};
    final Uint8List payload = Uint8List.fromList(utf8.encode(jsonEncode(obj)));
    final Uint8List msgId = _nextMsgId();
    final MeshPacket pkt = MeshPacket(
      version: 1,
      type: 3,
      ttl: 8,
      hop: 0,
      channelId64: inviteChannelId64,
      msgId: msgId,
      headerAd: null,
      payload: payload,
    );
    MeshCodec.encodeFrame(pkt);
    await ref.read(linkManagerProvider).broadcast(pkt);
  }

  Future<void> _handleInvite(Uint8List payload) async {
    try {
      final Map<String, dynamic> m = jsonDecode(utf8.decode(payload)) as Map<String, dynamic>;
      final String? bundle = m['bundle'] as String?;
      final String? code = m['code'] as String?;
      // Push to invites stream for UI accept/decline
      final Map<String, String> evt = <String, String>{
        if (bundle != null) 'bundle': bundle,
        if (code != null) 'code': code,
      };
      ref.read(app.invitesControllerProvider).add(evt);
    } catch (_) {
      // ignore
    }
  }

  Uint8List _nextMsgId() {
    final Uint8List id = Uint8List(12);
    _counter++;
    final ByteData bd = ByteData(8)..setUint64(0, _counter);
    id.setAll(5, bd.buffer.asUint8List().sublist(1));
    return id;
  }

  static int _hash64(String s) {
    int hash = 1125899906842597; // FNV-like
    for (final int code in s.codeUnits) {
      hash = (hash * 1099511628211) ^ code;
    }
    return hash & 0x7FFFFFFFFFFFFFFF;
  }
}

final Provider<InviteService> inviteServiceProvider = Provider<InviteService>((ProviderRef<InviteService> ref) {
  final InviteService svc = InviteService(ref);
  ref.onDispose(svc.dispose);
  return svc;
});


