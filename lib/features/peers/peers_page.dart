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
    return Scaffold(
      appBar: AppBar(title: const Text('Diagnostics')),
      body: Column(
        children: <Widget>[
          SwitchListTile(
            title: const Text('Verbose logging'),
            value: verbose,
            onChanged: (bool v) => ref.read(verboseLogProvider.notifier).state = v,
          ),
          Expanded(child: peersAsync.when(
            data: (List<BluetoothDevice> peers) {
              return ListView.builder(
                itemCount: peers.length,
                itemBuilder: (BuildContext c, int i) {
                  final BluetoothDevice d = peers[i];
                  return ListTile(
                    title: Text(d.platformName.isNotEmpty ? d.platformName : d.remoteId.str),
                    subtitle: Text(d.remoteId.str),
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
