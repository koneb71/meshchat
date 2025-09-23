import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BlePermissions {
  static Future<void> ensureGranted() async {
    if (Platform.isAndroid) {
      // Android 12+ specific Bluetooth runtime permissions
      if ((await Permission.bluetoothScan.status).isDenied) {
        await Permission.bluetoothScan.request();
      }
      if ((await Permission.bluetoothConnect.status).isDenied) {
        await Permission.bluetoothConnect.request();
      }
      if ((await Permission.bluetoothAdvertise.status).isDenied) {
        await Permission.bluetoothAdvertise.request();
      }
      // Pre-Android 12 may still require location for discovery
      if ((await Permission.location.status).isDenied) {
        await Permission.location.request();
      }
    }
    if (Platform.isIOS) {
      // iOS will prompt on Bluetooth usage automatically; nothing explicit to request here
    }
    try {
      await FlutterBluePlus.turnOn();
      await FlutterBluePlus.adapterState.firstWhere((s) => s == BluetoothAdapterState.on);
    } catch (_) {}
  }
}


