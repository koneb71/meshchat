import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';

import 'constants.dart';

class MeshGattServer {
  static const MethodChannel _method = MethodChannel('meshchat/gatt_server');
  static const EventChannel _events = EventChannel('meshchat/gatt_events');

  Stream<Uint8List>? _inbound;

  Future<void> start() async {
    _inbound ??= _events.receiveBroadcastStream().map((dynamic e) => Uint8List.fromList(List<int>.from(e as List<dynamic>)));
    await _method.invokeMethod('startServer', <String, String>{
      'service': MeshUuids.service,
      'data': MeshUuids.data,
      'control': MeshUuids.control,
    });
  }

  Future<void> stop() async {
    await _method.invokeMethod('stopServer');
  }

  Stream<Uint8List> get inboundFrames => _inbound ?? const Stream<Uint8List>.empty();
}


