import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../mesh/packet.dart';
import '../../mesh/codec.dart';
import 'channel_state.dart';

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
          // Confirm channel id matches
          if (pkt.channelId64 == _hash64(name)) {
            ref.read(channelsProvider.notifier).updateChannelKey(name, kc, ctr);
            // Notify UI to verify sender key hash
            ref.read(channelEventsControllerProvider).add(<String, String>{'type': 'rekey', 'channel': name});
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
    final Map<String, dynamic> m = <String, dynamic>{
      'type': 'rekey',
      'name': ch.name,
      'kc': ch.senderKey,
      'ctr': ch.messageCounter,
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


