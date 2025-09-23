import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import '../mesh/advertiser.dart';
import '../mesh/scanner.dart';
import '../mesh/link_manager.dart';
import '../mesh/link_service.dart';
import '../mesh/link_info.dart';
import '../mesh/gatt_server.dart';
import '../mesh/packet.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../mesh/constants.dart';
import '../features/channels/channel_control_service.dart';

final Provider<MeshAdvertiser> advertiserProvider = Provider<MeshAdvertiser>((ProviderRef<MeshAdvertiser> ref) {
  return MeshAdvertiser();
});

final Provider<MeshScanner> scannerProvider = Provider<MeshScanner>((ProviderRef<MeshScanner> ref) {
  return MeshScanner();
});

final StateProvider<bool> verboseLogProvider = StateProvider<bool>((StateProviderRef<bool> ref) => false);

final Provider<LinkManager> linkManagerProvider = Provider<LinkManager>((ProviderRef<LinkManager> ref) {
  return LinkManager();
});

final Provider<LinkService> linkServiceProvider = Provider<LinkService>((ProviderRef<LinkService> ref) {
  return LinkService(scanner: ref.read(scannerProvider), linkManager: ref.read(linkManagerProvider));
});

final Provider<MeshGattServer> gattServerProvider = Provider<MeshGattServer>((ProviderRef<MeshGattServer> ref) {
  return MeshGattServer();
});

final Provider<StreamController<MeshPacket>> messagesControllerProvider = Provider<StreamController<MeshPacket>>((ProviderRef<StreamController<MeshPacket>> ref) {
  final StreamController<MeshPacket> controller = StreamController<MeshPacket>.broadcast();
  ref.onDispose(controller.close);
  // Hook link manager events into this controller
  ref.read(linkManagerProvider).onPacket = (MeshPacket pkt) {
    controller.add(pkt);
  };
  ref.read(linkManagerProvider).onAck = (MeshPacket ack) {
    controller.add(ack);
  };
  return controller;
});

final Provider<Stream<MeshPacket>> messagesStreamProvider = Provider<Stream<MeshPacket>>((ProviderRef<Stream<MeshPacket>> ref) {
  return ref.read(messagesControllerProvider).stream;
});

final Provider<StreamController<Map<String, String>>> invitesControllerProvider = Provider<StreamController<Map<String, String>>>((ProviderRef<StreamController<Map<String, String>>> ref) {
  final StreamController<Map<String, String>> controller = StreamController<Map<String, String>>.broadcast();
  ref.onDispose(controller.close);
  return controller;
});

final Provider<Stream<Map<String, String>>> invitesStreamProvider = Provider<Stream<Map<String, String>>>((ProviderRef<Stream<Map<String, String>>> ref) {
  return ref.read(invitesControllerProvider).stream;
});

final StreamProvider<Map<String, String>> invitesEventsProvider = StreamProvider<Map<String, String>>((StreamProviderRef<Map<String, String>> ref) {
  return ref.read(invitesControllerProvider).stream;
});

final StateProvider<String> themeModeProvider = StateProvider<String>((StateProviderRef<String> ref) => 'system');

final StreamProvider<List<BluetoothDevice>> nearbyPeersProvider = StreamProvider<List<BluetoothDevice>>((StreamProviderRef<List<BluetoothDevice>> ref) {
  final Stream<List<ScanResult>> base = FlutterBluePlus.scanResults;
  return base.map((List<ScanResult> results) {
    final List<BluetoothDevice> devices = <BluetoothDevice>[];
    for (final ScanResult r in results) {
      final bool matchesService = r.advertisementData.serviceUuids.contains(Guid(MeshUuids.service));
      final String advName = r.advertisementData.advName;
      final bool matchesName = advName.isNotEmpty && advName.toLowerCase().contains('mesh');
      if (matchesService || matchesName) {
        if (!devices.any((BluetoothDevice d) => d.remoteId == r.device.remoteId)) {
          devices.add(r.device);
        }
      }
    }
    return devices;
  });
});

final StateProvider<int> lastScanCountProvider = StateProvider<int>((StateProviderRef<int> ref) => 0);

final StreamProvider<int> scanCountStreamProvider = StreamProvider<int>((StreamProviderRef<int> ref) {
  return FlutterBluePlus.scanResults.map((List<ScanResult> results) => results.length);
});

final StreamProvider<List<LinkInfo>> linksStreamProvider = StreamProvider<List<LinkInfo>>((StreamProviderRef<List<LinkInfo>> ref) {
  return ref.read(linkServiceProvider).linksStream;
});

final Provider<ChannelControlService> channelControlProvider = Provider<ChannelControlService>((ProviderRef<ChannelControlService> ref) {
  return ChannelControlService(ref);
});

final Provider<StreamController<Map<String, String>>> channelEventsControllerProvider = Provider<StreamController<Map<String, String>>>((ProviderRef<StreamController<Map<String, String>>> ref) {
  final StreamController<Map<String, String>> controller = StreamController<Map<String, String>>.broadcast();
  ref.onDispose(controller.close);
  return controller;
});

final StreamProvider<Map<String, String>> channelEventsProvider = StreamProvider<Map<String, String>>((StreamProviderRef<Map<String, String>> ref) {
  return ref.read(channelEventsControllerProvider).stream;
});


