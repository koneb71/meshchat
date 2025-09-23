import 'dart:collection';
import 'dart:typed_data';
import 'dart:async';

import '../core/utils.dart';
import 'packet.dart';
import 'codec.dart';
import 'link_service.dart';
import 'gatt_server.dart';
import 'nearby_service.dart';

abstract class BleLink {
  Future<void> send(MeshPacket packet);
}

class LinkManager {
  final LinkedHashMap<String, DateTime> _dedup = LinkedHashMap<String, DateTime>();
  final List<BleLink> _links = <BleLink>[];
  Duration dedupTtl = const Duration(minutes: 30);
  void Function(MeshPacket pkt)? onPacket;
  void Function(MeshPacket ack)? onAck;
  void Function(String transport)? onTransport;
  // Metrics
  int framesSent = 0;
  int bytesSent = 0;
  int framesReceived = 0;
  int bytesReceived = 0;
  int duplicatesDropped = 0;
  int framesRelayed = 0;
  int acksSent = 0;
  int acksReceived = 0;
  final List<(int tsMs, int bytes)> _inLog = <(int, int)>[];
  final List<(int tsMs, int bytes)> _outLog = <(int, int)>[];
  final StreamController<Map<String, num>> _metrics = StreamController<Map<String, num>>.broadcast();
  Stream<Map<String, num>> get metricsStream => _metrics.stream;

  bool _seen(Uint8List id) => _dedup.containsKey(hex(id));

  void _remember(Uint8List id) {
    _dedup[hex(id)] = DateTime.now();
    if (_dedup.length > 4096) {
      _dedup.remove(_dedup.keys.first);
    }
  }

  void addLink(BleLink link) => _links.add(link);
  NearbyMeshService? nearby;

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
      framesSent += 1;
      bytesSent += frame.length;
      _outLog.add((DateTime.now().millisecondsSinceEpoch, frame.length));
    }
    // Also emit over local GATT server control characteristic as a relay for connected centrals
    try {
      await MeshGattServer().sendControl(frame);
      framesSent += 1;
      bytesSent += frame.length;
      _outLog.add((DateTime.now().millisecondsSinceEpoch, frame.length));
    } catch (_) {}
    // And via Nearby if available
    try {
      await nearby?.sendFrame(frame);
      framesSent += 1;
      bytesSent += frame.length;
      _outLog.add((DateTime.now().millisecondsSinceEpoch, frame.length));
    } catch (_) {}
    _emitMetrics();
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
      if (_seen(pkt.msgId)) { duplicatesDropped += 1; _emitMetrics(); return; }
      _remember(pkt.msgId);
      // Deliver to subscriber
      onPacket?.call(pkt);
      onTransport?.call('BLE');
      framesReceived += 1;
      bytesReceived += frame.length;
      _inLog.add((DateTime.now().millisecondsSinceEpoch, frame.length));
      // Send ACK for messages
      if (pkt.type == 3) {
        final MeshPacket ack = buildAckFor(pkt);
        await broadcast(ack);
        acksSent += 1;
      }
      if (pkt.type == 4) {
        onAck?.call(pkt);
        acksReceived += 1;
      }
      // Relay if TTL permits
      await relay(pkt);
      framesRelayed += 1;
      _emitMetrics();
    } catch (_) {
      // ignore malformed frames
    }
  }

  Future<void> onFrameReceivedNearby(Uint8List frame) async {
    try {
      final MeshPacket pkt = MeshCodec.decodeFrame(frame);
      if (_seen(pkt.msgId)) { duplicatesDropped += 1; _emitMetrics(); return; }
      _remember(pkt.msgId);
      onPacket?.call(pkt);
      onTransport?.call('Nearby');
      framesReceived += 1;
      bytesReceived += frame.length;
      _inLog.add((DateTime.now().millisecondsSinceEpoch, frame.length));
      if (pkt.type == 3) {
        final MeshPacket ack = buildAckFor(pkt);
        await broadcast(ack);
        acksSent += 1;
      }
      if (pkt.type == 4) {
        onAck?.call(pkt);
        acksReceived += 1;
      }
      await relay(pkt);
      framesRelayed += 1;
      _emitMetrics();
    } catch (_) {}
  }

  void _emitMetrics() {
    final int now = DateTime.now().millisecondsSinceEpoch;
    // prune >10s
    while (_inLog.isNotEmpty && now - _inLog.first.$1 > 10000) { _inLog.removeAt(0); }
    while (_outLog.isNotEmpty && now - _outLog.first.$1 > 10000) { _outLog.removeAt(0); }
    final int inBytes10s = _inLog.fold(0, (int a, (int, int) b) => a + b.$2);
    final int outBytes10s = _outLog.fold(0, (int a, (int, int) b) => a + b.$2);
    final double kbpsIn = inBytes10s * 0.8; // bytes/10s *8 /1000
    final double kbpsOut = outBytes10s * 0.8;
    _metrics.add(<String, num>{
      'framesSent': framesSent,
      'bytesSent': bytesSent,
      'framesReceived': framesReceived,
      'bytesReceived': bytesReceived,
      'duplicatesDropped': duplicatesDropped,
      'framesRelayed': framesRelayed,
      'acksSent': acksSent,
      'acksReceived': acksReceived,
      'kbpsIn': kbpsIn,
      'kbpsOut': kbpsOut,
    });
  }
}


