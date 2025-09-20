import 'dart:typed_data';
import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'constants.dart';

class MeshGattClientLink {
  final BluetoothDevice device;
  BluetoothCharacteristic? _dataChar;
  BluetoothCharacteristic? _controlChar;
  int _mtu = 185; // conservative default
  StreamSubscription<List<int>>? _dataSub;
  final StreamController<Uint8List> _onData = StreamController<Uint8List>.broadcast();
  Stream<Uint8List> get onData => _onData.stream;

  MeshGattClientLink(this.device);

  Future<void> connect() async {
    await device.connect(autoConnect: false);
    try {
      // Request a higher MTU where possible (Android). iOS ignores.
      await device.requestMtu(247);
    } catch (_) {}
    try {
      _mtu = device.mtuNow;
      if (_mtu <= 0) _mtu = 185;
    } catch (_) {
      _mtu = 185;
    }
    final List<BluetoothService> services = await device.discoverServices();
    for (final BluetoothService s in services) {
      if (s.uuid.str128.toUpperCase() == MeshUuids.service) {
        for (final BluetoothCharacteristic c in s.characteristics) {
          final String uuid = c.uuid.str128.toUpperCase();
          if (uuid == MeshUuids.data) _dataChar = c;
          if (uuid == MeshUuids.control) _controlChar = c;
        }
      }
    }
    // Subscribe to data notifications if supported
    try {
      final BluetoothCharacteristic? dc = _dataChar;
      if (dc != null) {
        await dc.setNotifyValue(true);
        _dataSub = dc.lastValueStream.listen((List<int> v) {
          if (v.isNotEmpty) {
            _onData.add(Uint8List.fromList(v));
          }
        });
      }
    } catch (_) {}
  }

  Future<void> disconnect() async {
    try { await _dataSub?.cancel(); } catch (_) {}
    try { await _onData.close(); } catch (_) {}
    await device.disconnect();
  }

  Future<void> sendData(Uint8List frame) async {
    final BluetoothCharacteristic? c = _dataChar;
    if (c == null) throw StateError('data characteristic not found');
    await c.write(frame, withoutResponse: true);
  }

  Future<void> sendDataChunks(Uint8List data) async {
    // Subtract 3 bytes ATT overhead conservatively
    final int maxChunk = (_mtu - 3).clamp(20, 200);
    int offset = 0;
    while (offset < data.length) {
      final int end = (offset + maxChunk > data.length) ? data.length : offset + maxChunk;
      final Uint8List chunk = Uint8List.sublistView(data, offset, end);
      await sendData(chunk);
      offset = end;
    }
  }
}


