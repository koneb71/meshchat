import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/providers.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:convert';
import '../dm/dm_page.dart';
import '../channels/channel_state.dart';
import '../invite/invite_service.dart';

class PeersPage extends ConsumerWidget {
  const PeersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool verbose = ref.watch(verboseLogProvider);
    final peersAsync = ref.watch(nearbyPeersProvider);
    final scanner = ref.read(scannerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Diagnostics')),
      body: Column(
        children: <Widget>[
          Consumer(builder: (BuildContext _, WidgetRef r, __) {
            final scanCount = r.watch(scanCountStreamProvider).maybeWhen(data: (v) => v, orElse: () => 0);
            return ListTile(
              leading: const Icon(Icons.radar),
              title: const Text('Scan results (raw)'),
              subtitle: Text('$scanCount recent devices'),
            );
          }),
          Consumer(builder: (BuildContext _, WidgetRef r, __) {
            final links = r.watch(linksStreamProvider).maybeWhen(data: (v) => v, orElse: () => const <dynamic>[]);
            return ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Active links'),
              subtitle: Text(links.isEmpty ? 'None' : links.map((e) => '${e.id} (MTU ${e.mtu})').join('\n')),
            );
          }),
          Consumer(builder: (BuildContext _, WidgetRef r, __) {
            return StreamBuilder<Map<String, num>>(
              stream: ref.read(linkManagerProvider).metricsStream,
              builder: (BuildContext _, AsyncSnapshot<Map<String, num>> snap) {
                final Map<String, num>? v = snap.data;
                return ListTile(
                  leading: const Icon(Icons.speed),
                  title: const Text('Throughput / Loss'),
                  subtitle: Text(v == null
                      ? 'Measuring...'
                      : 'In: ${v['kbpsIn']?.toStringAsFixed(1)} kbps  Out: ${v['kbpsOut']?.toStringAsFixed(1)} kbps\n' +
                          'Recv: ${v['framesReceived']}  Sent: ${v['framesSent']}  Relayed: ${v['framesRelayed']}\n' +
                          'Acks: ${v['acksReceived']} / ${v['acksSent']}  Duplicates: ${v['duplicatesDropped']}'),
                );
              },
            );
          }),
          FutureBuilder<Map<dynamic, dynamic>>(
            future: ref.read(gattServerProvider).capabilities(),
            builder: (BuildContext _, AsyncSnapshot<Map<dynamic, dynamic>> snap) {
              final Map<dynamic, dynamic>? c = snap.data;
              return ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('BLE Capabilities'),
                subtitle: Text(c == null
                    ? 'Checking...'
                    : 'Adapter: ${c['adapterEnabled']}  BLE: ${c['hasBle']}  Adv: ${c['advertiseSupported']}'),
              );
            },
          ),
          ListTile(
            leading: Icon(scanner.isRunning ? Icons.play_circle_fill : Icons.pause_circle_filled),
            title: const Text('Scan state'),
            subtitle: Text(scanner.isRunning ? 'Running' : 'Idle'),
            trailing: TextButton(
              onPressed: () async {
                if (scanner.isRunning) {
                  await scanner.stop();
                } else {
                  await scanner.start();
                }
              },
              child: Text(scanner.isRunning ? 'Stop' : 'Start'),
            ),
          ),
          SwitchListTile(
            title: const Text('Verbose logging'),
            value: verbose,
            onChanged: (bool v) => ref.read(verboseLogProvider.notifier).state = v,
          ),
          Expanded(child: peersAsync.when(
            data: (List<BluetoothDevice> peers) {
              final rssiMap = ref.watch(rssiMapProvider).maybeWhen(data: (v) => v, orElse: () => const <String, int>{});
              return ListView.builder(
                itemCount: peers.length,
                itemBuilder: (BuildContext c, int i) {
                  final BluetoothDevice d = peers[i];
                  final int? rssi = rssiMap[d.remoteId.str];
                  return ListTile(
                    title: Text(d.platformName.isNotEmpty ? d.platformName : d.remoteId.str),
                    subtitle: Text(rssi != null ? '${d.remoteId.str}  •  RSSI $rssi dBm' : d.remoteId.str),
                    leading: IconButton(
                      icon: const Icon(Icons.link),
                      tooltip: 'Connect',
                      onPressed: () async {
                        final ok = await ref.read(linkServiceProvider).connectDevice(d);
                        final snack = SnackBar(content: Text(ok ? 'Connected to ${d.remoteId.str}' : 'Connect failed'));
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(snack);
                      },
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (String sel) async {
                        if (sel == 'dm') {
                          // Open DM demo
                          // ignore: use_build_context_synchronously
                          Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => DmPage(peerId: d.remoteId.str)));
                        } else if (sel == 'invite') {
                          // Send private channel invite code for first private channel (demo)
                          final channels = ref.read(channelsProvider);
                          final private = channels.where((c) => c.encrypted).toList();
                          if (private.isEmpty) return;
                          final bundle = ref.read(channelsProvider.notifier).generateInviteBundle(private.first);
                          await ref.read(inviteServiceProvider).sendInvite(bundle);
                        } else if (sel == 'invite_code') {
                          final channels = ref.read(channelsProvider);
                          final private = channels.where((c) => c.encrypted).toList();
                          if (private.isEmpty) return;
                          final code = ref.read(channelsProvider.notifier).generateInviteCode(private.first);
                          await ref.read(inviteServiceProvider).sendInvite(jsonEncode(<String, String>{'code': code}));
                        }
                      },
                      itemBuilder: (_) => const <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(value: 'dm', child: Text('Direct Message')),
                        PopupMenuItem<String>(value: 'invite', child: Text('Send Channel Invite')),
                        PopupMenuItem<String>(value: 'invite_code', child: Text('Send Channel Invite (Code)')),
                      ],
                    ),
                  );
                },
              );
            },
            error: (Object e, StackTrace st) => Center(child: Text('Error: $e')),
            loading: () => const Center(child: CircularProgressIndicator()),
          )),
        ],
      ),
    );
  }
}
