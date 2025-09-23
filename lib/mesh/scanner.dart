import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'constants.dart';

class MeshScanner {
  final Duration scanDuration = const Duration(seconds: 4);
  final Duration idleDuration = const Duration(seconds: 6);
  StreamSubscription<List<ScanResult>>? _sub;
  bool _running = false;

  final List<BluetoothDevice> candidates = <BluetoothDevice>[];

  Future<void> start() async {
    if (_running) return;
    _running = true;
    _loop();
  }

  Future<void> stop() async {
    _running = false;
    await FlutterBluePlus.stopScan();
    await _sub?.cancel();
    _sub = null;
  }

  Future<void> _loop() async {
    while (_running) {
      candidates.clear();
      _sub = FlutterBluePlus.scanResults.listen((List<ScanResult> results) {
        for (final ScanResult r in results) {
          final bool matchesService = r.advertisementData.serviceUuids.contains(Guid(MeshUuids.service));
          final String advName = r.advertisementData.advName;
          final bool matchesName = advName.isNotEmpty && advName.toLowerCase().contains('mesh');
          if (matchesService || matchesName) {
            if (!candidates.any((BluetoothDevice d) => d.remoteId == r.device.remoteId)) {
              candidates.add(r.device);
            }
          }
        }
      });
      await FlutterBluePlus.startScan(timeout: scanDuration);
      await Future<void>.delayed(scanDuration);
      await FlutterBluePlus.stopScan();
      await _sub?.cancel();
      _sub = null;
      if (!_running) break;
      await Future<void>.delayed(idleDuration);
    }
  }
}


