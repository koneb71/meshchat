import 'dart:collection';
import 'dart:typed_data';

import '../core/utils.dart';
import 'packet.dart';
import 'codec.dart';
import 'link_service.dart';
import 'gatt_server.dart';

abstract class BleLink {
  Future<void> send(MeshPacket packet);
}

class LinkManager {
  final LinkedHashMap<String, DateTime> _dedup = LinkedHashMap<String, DateTime>();
  final List<BleLink> _links = <BleLink>[];
  Duration dedupTtl = const Duration(minutes: 30);
  void Function(MeshPacket pkt)? onPacket;
  void Function(MeshPacket ack)? onAck;

  bool _seen(Uint8List id) => _dedup.containsKey(hex(id));

  void _remember(Uint8List id) {
    _dedup[hex(id)] = DateTime.now();
    if (_dedup.length > 4096) {
      _dedup.remove(_dedup.keys.first);
    }
  }

  void addLink(BleLink link) => _links.add(link);

  void purgeExpired() {
    final DateTime now = DateTime.now();
    final List<String> toRemove = <String>[];
    _dedup.forEach((String k, DateTime v) {
      if (now.difference(v) > dedupTtl) toRemove.add(k);
    });
    for (final String k in toRemove) {
      _dedup.remove(k);
    }
  }

  Future<void> broadcast(MeshPacket pkt) async {
    if (_seen(pkt.msgId)) return;
    _remember(pkt.msgId);
    final Uint8List frame = MeshCodec.encodeFrame(pkt);
    for (final BleLink l in _links) {
      if (l is BleMeshLink) {
        await l.sendFrame(frame);
      } else {
        await l.send(pkt);
      }
    }
    // Also emit over local GATT server control characteristic as a relay for connected centrals
    try {
      await MeshGattServer().sendControl(frame);
    } catch (_) {}
  }

  Future<void> relay(MeshPacket pkt) async {
    if (pkt.ttl <= 0) return;
    final MeshPacket forwarded = MeshPacket(
      version: pkt.version,
      type: pkt.type,
      ttl: pkt.ttl - 1,
      hop: pkt.hop + 1,
      channelId64: pkt.channelId64,
      msgId: pkt.msgId,
      seenBloom: pkt.seenBloom,
      headerAd: pkt.headerAd,
      payload: pkt.payload,
    );
    await broadcast(forwarded);
  }

  MeshPacket buildAckFor(MeshPacket msg) {
    return MeshPacket(
      version: msg.version,
      type: 4, // ACK
      ttl: 4,
      hop: 0,
      channelId64: msg.channelId64,
      msgId: msg.msgId,
      headerAd: null,
      payload: Uint8List(0),
    );
  }

  Future<void> onFrameReceived(Uint8List frame) async {
    try {
      final MeshPacket pkt = MeshCodec.decodeFrame(frame);
      if (_seen(pkt.msgId)) return;
      _remember(pkt.msgId);
      // Deliver to subscriber
      onPacket?.call(pkt);
      // Send ACK for messages
      if (pkt.type == 3) {
        final MeshPacket ack = buildAckFor(pkt);
        await broadcast(ack);
      }
      if (pkt.type == 4) {
        onAck?.call(pkt);
      }
      // Relay if TTL permits
      await relay(pkt);
    } catch (_) {
      // ignore malformed frames
    }
  }
}


