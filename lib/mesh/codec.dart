import 'dart:typed_data';
import 'packet.dart';

class MeshCodec {
  static Uint8List encodeFrame(MeshPacket packet) {
    final Uint8List header = PacketCodec.encodeHeader(
      version: packet.version,
      type: packet.type,
      ttl: packet.ttl,
      hop: packet.hop,
      channelId64: packet.channelId64,
      msgId: packet.msgId,
      seenBloom: packet.seenBloom,
    );
    final Uint8List payload = packet.payload ?? Uint8List(0);
    final int totalLen = header.length + payload.length;
    final ByteData bd = ByteData(2)..setUint16(0, totalLen);
    final BytesBuilder builder = BytesBuilder();
    builder.add(bd.buffer.asUint8List());
    builder.add(header);
    builder.add(payload);
    return builder.toBytes();
  }

  static MeshPacket decodeFrame(Uint8List frame) {
    if (frame.length < 2) throw const FormatException('frame too short');
    final ByteData bd = ByteData.sublistView(frame, 0, 2);
    final int len = bd.getUint16(0);
    if (frame.length - 2 < len) throw const FormatException('length mismatch');
    final Uint8List buf = Uint8List.sublistView(frame, 2, 2 + len);
    final (MeshPacket base, int headerLen) = PacketCodec.decode(buf);
    final Uint8List payload = Uint8List.sublistView(buf, headerLen);
    return MeshPacket(
      version: base.version,
      type: base.type,
      ttl: base.ttl,
      hop: base.hop,
      channelId64: base.channelId64,
      msgId: base.msgId,
      seenBloom: base.seenBloom,
      headerAd: base.headerAd,
      payload: payload.isEmpty ? null : payload,
    );
  }
}
