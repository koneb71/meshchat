import 'dart:typed_data';

class MeshPacket {
  final int version;
  final int type;
  final int ttl;
  final int hop;
  final int channelId64;
  final Uint8List msgId; // 12 bytes
  final Uint8List? seenBloom; // 8 bytes optional
  final Uint8List? headerAd; // additional data for AEAD
  final Uint8List? payload; // may be null for control frames

  const MeshPacket({
    required this.version,
    required this.type,
    required this.ttl,
    required this.hop,
    required this.channelId64,
    required this.msgId,
    this.seenBloom,
    this.headerAd,
    this.payload,
  });
}

class PacketCodec {
  static Uint8List encodeHeader({
    required int version, required int type,
    required int ttl, required int hop,
    required int channelId64, required Uint8List msgId,
    Uint8List? seenBloom,
  }) {
    final BytesBuilder b = BytesBuilder();
    b.addByte(version); b.addByte(type); b.addByte(ttl); b.addByte(hop);
    final ByteData bd = ByteData(8)..setUint64(0, channelId64);
    b.add(bd.buffer.asUint8List());
    b.add(msgId);
    if (seenBloom != null) b.add(seenBloom);
    return b.toBytes();
  }

  static (MeshPacket, int) decode(Uint8List data) {
    if (data.length < 1 + 1 + 1 + 1 + 8 + 12) {
      throw const FormatException('header too short');
    }
    int offset = 0;
    final int version = data[offset++];
    final int type = data[offset++];
    final int ttl = data[offset++];
    final int hop = data[offset++];
    final ByteData bd = ByteData.sublistView(data, offset, offset + 8);
    final int channelId64 = bd.getUint64(0);
    offset += 8;
    final Uint8List msgId = Uint8List.fromList(data.sublist(offset, offset + 12));
    offset += 12;
    Uint8List? seenBloom;
    // If remaining >= 8 and the caller expects optional bloom, consume 8
    if (data.length - offset >= 8) {
      seenBloom = Uint8List.fromList(data.sublist(offset, offset + 8));
      offset += 8;
    }
    final MeshPacket pkt = MeshPacket(
      version: version,
      type: type,
      ttl: ttl,
      hop: hop,
      channelId64: channelId64,
      msgId: msgId,
      seenBloom: seenBloom,
    );
    return (pkt, offset);
  }
}


