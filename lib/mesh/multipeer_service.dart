import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';

class MultipeerMeshService {
  static const MethodChannel _method = MethodChannel('meshchat/mc');
  static const EventChannel _events = EventChannel('meshchat/mc_events');

  Stream<Uint8List>? _inbound;

  Future<void> start({String service = 'meshchat'}) async {
    if (!Platform.isIOS) return;
    _inbound ??= _events.receiveBroadcastStream().map((dynamic e) => Uint8List.fromList(List<int>.from(e as List<dynamic>)));
    await _method.invokeMethod('start', <String, String>{'service': service});
  }

  Future<void> stop() async {
    if (!Platform.isIOS) return;
    await _method.invokeMethod('stop');
  }

  Stream<Uint8List> get inbound => _inbound ?? const Stream<Uint8List>.empty();

  Future<void> sendFrame(Uint8List frame) async {
    if (!Platform.isIOS) return;
    await _method.invokeMethod('send', <String, dynamic>{'data': frame});
  }
}


