import 'dart:async';
import 'dart:typed_data';

import 'package:nearby_connections/nearby_connections.dart';

class NearbyMeshService {
  final Strategy _strategy = Strategy.P2P_CLUSTER;
  final String serviceId;
  final Set<String> _connected = <String>{};
  final StreamController<Uint8List> _inbound = StreamController<Uint8List>.broadcast();
  bool _running = false;

  NearbyMeshService({required this.serviceId});

  Stream<Uint8List> get inbound => _inbound.stream;

  Future<void> start() async {
    if (_running) return;
    _running = true;
    // Start advertising
    try {
      await Nearby().startAdvertising(
        serviceId,
        _strategy,
        onConnectionInitiated: _onConnInitiated,
        onConnectionResult: _onConnResult,
        onDisconnected: _onDisconnected,
        serviceId: serviceId,
      );
    } catch (_) {}
    // Start discovery
    try {
      await Nearby().startDiscovery(
        serviceId,
        _strategy,
        onEndpointFound: (String id, String name, String serviceId) async {
          try {
            await Nearby().requestConnection('MeshChat', id, onConnectionInitiated: _onConnInitiated, onConnectionResult: _onConnResult, onDisconnected: _onDisconnected);
          } catch (_) {}
        },
        onEndpointLost: (String? id) {
          if (id != null) _connected.remove(id);
        },
        serviceId: serviceId,
      );
    } catch (_) {}
  }

  Future<void> stop() async {
    _running = false;
    try { await Nearby().stopAllEndpoints(); } catch (_) {}
    try { await Nearby().stopAdvertising(); } catch (_) {}
    try { await Nearby().stopDiscovery(); } catch (_) {}
    _connected.clear();
  }

  Future<void> sendFrame(Uint8List frame) async {
    for (final String id in _connected) {
      try {
        await Nearby().sendBytesPayload(id, frame);
      } catch (_) {}
    }
  }

  void _onConnInitiated(String id, ConnectionInfo info) {
    Nearby().acceptConnection(id, onPayLoadRecieved: (String eid, Payload payload) async {
      if (payload.type == PayloadType.BYTES && payload.bytes != null) {
        _inbound.add(payload.bytes!);
      }
    });
  }

  void _onConnResult(String id, Status status) {
    if (status == Status.CONNECTED) {
      _connected.add(id);
    } else {
      _connected.remove(id);
    }
  }

  void _onDisconnected(String id) {
    _connected.remove(id);
  }
}


