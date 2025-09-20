import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:meshchat/mesh/packet.dart';

void main() {
  test('Packet header encode/decode', () {
    final Uint8List msgId = Uint8List(12);
    final Uint8List bloom = Uint8List(8);
    final Uint8List hdr = PacketCodec.encodeHeader(
      version: 1,
      type: 3,
      ttl: 8,
      hop: 0,
      channelId64: 0x1122334455667788,
      msgId: msgId,
      seenBloom: bloom,
    );
    final (MeshPacket pkt, int len) = PacketCodec.decode(hdr);
    expect(len, hdr.length);
    expect(pkt.version, 1);
    expect(pkt.type, 3);
    expect(pkt.ttl, 8);
    expect(pkt.hop, 0);
    expect(pkt.channelId64, 0x1122334455667788);
    expect(pkt.msgId.length, 12);
    expect(pkt.seenBloom!.length, 8);
  });
}


