// BLE advertising for discovery
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'constants.dart';

class MeshAdvertiser {
  bool _running = false;
  final FlutterBlePeripheral _ble = FlutterBlePeripheral();

  Future<void> start() async {
    if (_running) return;
    _running = true;
    final AdvertiseData advertiseData = AdvertiseData(
      includeDeviceName: true,
      serviceUuid: MeshUuids.service,
    );
    final AdvertiseSettings settings = AdvertiseSettings(
      advertiseMode: AdvertiseMode.advertiseModeLowLatency,
      txPowerLevel: AdvertiseTxPower.advertiseTxPowerHigh,
      connectable: true,
      timeout: 0,
    );
    await _ble.start(advertiseData: advertiseData, advertiseSettings: settings);
  }

  Future<void> stop() async {
    _running = false;
    try {
      await _ble.stop();
    } catch (_) {}
  }

  bool get isRunning => _running;
}


