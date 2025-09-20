import 'dart:typed_data';
import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../crypto/aead.dart';
import '../../crypto/sender_keys.dart';
import '../../mesh/packet.dart';
import 'channel_state.dart';

class ChannelCryptoService {
  final WidgetRef ref;
  final SenderKeysService _senderKeys = SenderKeysService();
  ChannelCryptoService(this.ref);

  Future<(Uint8List, List<int>)> sealForChannel(String channelName, MeshPacket headerPkt, Uint8List plaintext) async {
    final channels = ref.read(channelsProvider);
    final notifier = ref.read(channelsProvider.notifier);
    final ch = channels.firstWhere((c) => c.name == channelName);
    // Ensure sender key exists
    String? kcBase64 = ch.senderKey;
    SecretKey key;
    if (kcBase64 == null || kcBase64.isEmpty) {
      final SenderKeyState st = await _senderKeys.create();
      final List<int> extracted = await st.currentKey.extractBytes();
      kcBase64 = base64Encode(extracted);
      notifier.updateChannelKey(channelName, kcBase64, 0);
      key = st.currentKey;
    } else {
      key = SecretKey(base64Decode(kcBase64));
    }
    // Nonce and counter update
    final (int nextCounter, List<int> nonce12) = _nonceFromCounter(ch.messageCounter + 1);
    notifier.updateChannelCounter(channelName, nextCounter);
    final Uint8List ad = _adFromHeader(headerPkt);
    final Uint8List cipher = await aeadSeal(key: key, nonce12: nonce12, plaintext: plaintext, ad: ad);
    return (cipher, nonce12);
  }

  Future<Uint8List?> openForChannel(String channelName, MeshPacket headerPkt, Uint8List cipherAndTag) async {
    final channels = ref.read(channelsProvider);
    final ch = channels.firstWhere((c) => c.name == channelName, orElse: () => throw StateError('channel not found'));
    final String? kc = ch.senderKey;
    if (kc == null || kc.isEmpty) return null;
    final SecretKey key = SecretKey(base64Decode(kc));
    // Derive nonce from msgId counter
    final List<int> nonce12 = _nonceFromMsgId(headerPkt.msgId);
    final Uint8List ad = _adFromHeader(headerPkt);
    try {
      final Uint8List pt = await aeadOpen(key: key, nonce12: nonce12, cipherAndTag: cipherAndTag, ad: ad);
      return pt;
    } catch (_) {
      return null;
    }
  }

  Uint8List _adFromHeader(MeshPacket pkt) {
    return Uint8List.fromList(<int>[pkt.version, pkt.type, pkt.ttl, pkt.hop]);
  }

  (int, List<int>) _nonceFromCounter(int counter) {
    final ByteData bd = ByteData(12);
    bd.setUint64(4, counter);
    return (counter, bd.buffer.asUint8List());
  }

  List<int> _nonceFromMsgId(Uint8List msgId) {
    // last 7 bytes are counter
    final Uint8List ctr7 = Uint8List.sublistView(msgId, 5);
    final ByteData bd = ByteData(12);
    // place ctr7 into lower 7 bytes
    final Uint8List b = bd.buffer.asUint8List();
    b.setAll(5, ctr7);
    return b;
  }
}


