import 'dart:typed_data';
import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'gatt_service.dart';
import 'link_manager.dart';
import 'scanner.dart';

class BleMeshLink implements BleLink {
  final MeshGattClientLink _client;

  BleMeshLink(this._client);

  @override
  Future<void> send(packet) async {
    // Serialize handled by caller; we use MeshGattClientLink to write frames
    // For now, assume caller passes a MeshPacket and will encode separately if needed
    // Here, we no-op because LinkManager.send iterates packets per-link with encoding upstream
  }

  Future<void> sendFrame(List<int> frame) async {
    await _client.sendData(frame as dynamic);
  }
}

class LinkService {
  final MeshScanner scanner;
  final LinkManager linkManager;
  final int maxConcurrent;
  Timer? _maintainTimer;
  final Map<DeviceIdentifier, MeshGattClientLink> _active = <DeviceIdentifier, MeshGattClientLink>{};

  LinkService({required this.scanner, required this.linkManager, this.maxConcurrent = 3});

  Future<void> start() async {
    await scanner.start();
    _maintainTimer ??= Timer.periodic(const Duration(seconds: 6), (_) => _maintain());
  }

  Future<void> stop() async {
    await scanner.stop();
    _maintainTimer?.cancel();
    _maintainTimer = null;
    for (final MeshGattClientLink l in _active.values) {
      await l.disconnect();
    }
    _active.clear();
  }

  Future<void> _maintain() async {
    // purge expired dedup
    linkManager.purgeExpired();
    // Connect up to maxConcurrent
    for (final BluetoothDevice d in scanner.candidates) {
      if (_active.length >= maxConcurrent) break;
      if (_active.containsKey(d.remoteId)) continue;
      try {
        final MeshGattClientLink client = MeshGattClientLink(d);
        await client.connect();
        _active[d.remoteId] = client;
        // Register with LinkManager so broadcast uses this link
        final BleMeshLink ble = BleMeshLink(client);
        linkManager.addLink(ble);
        // Hook incoming frames
        try {
          client.onData.listen((Uint8List bytes) {
            linkManager.onFrameReceived(bytes);
          });
        } catch (_) {}
      } catch (_) {
        // ignore
      }
    }
    // Drop disconnected
    final List<DeviceIdentifier> toRemove = <DeviceIdentifier>[];
    for (final MapEntry<DeviceIdentifier, MeshGattClientLink> e in _active.entries) {
      final BluetoothDevice dev = BluetoothDevice(remoteId: e.key);
      final bool connected = dev.isConnected;
      if (!connected) toRemove.add(e.key);
    }
    for (final DeviceIdentifier id in toRemove) {
      final MeshGattClientLink? l = _active.remove(id);
      await l?.disconnect();
    }
  }
}


