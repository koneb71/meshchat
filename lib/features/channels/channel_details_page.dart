import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'channel_state.dart';
import '../../app/providers.dart';
import '../../data/models.dart';

class ChannelDetailsPage extends ConsumerWidget {
  final String channelName;
  const ChannelDetailsPage({super.key, required this.channelName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ch = ref.watch(channelsProvider).firstWhere((c) => c.name == channelName);
    return Scaffold(
      appBar: AppBar(title: Text('Channel: ${ch.name}')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: <Widget>[
          ListTile(title: const Text('Type'), subtitle: Text(ch.encrypted ? 'Private' : 'Public')),
          const SizedBox(height: 8),
          ListTile(
            title: const Text('Members'),
            subtitle: Text('${ch.members.length}'),
            trailing: IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: () async {
                final TextEditingController id = TextEditingController();
                final TextEditingController name = TextEditingController();
                final String? ok = await showDialog<String>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Add member'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextField(controller: id, decoration: const InputDecoration(labelText: 'User ID')),
                        TextField(controller: name, decoration: const InputDecoration(labelText: 'Display Name')),
                      ],
                    ),
                    actions: <Widget>[
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                      FilledButton(onPressed: () => Navigator.pop(context, 'ok'), child: const Text('Add')),
                    ],
                  ),
                );
                if (ok == 'ok') {
                  await ref.read(channelControlProvider).sendAddMember(channelName, userId: id.text.trim(), displayName: name.text.trim());
                }
              },
            ),
          ),
          const Divider(),
          for (final Member m in ch.members)
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(m.displayName.isNotEmpty ? m.displayName : m.userId),
              subtitle: Text('Role: ${m.role}'),
              trailing: PopupMenuButton<String>(
                onSelected: (String sel) async {
                  if (sel == 'remove') {
                    await ref.read(channelControlProvider).sendRemoveMember(channelName, userId: m.userId);
                  } else if (sel == 'admin') {
                    await ref.read(channelControlProvider).sendSetRole(channelName, userId: m.userId, role: 'admin');
                  } else if (sel == 'member') {
                    await ref.read(channelControlProvider).sendSetRole(channelName, userId: m.userId, role: 'member');
                  }
                },
                itemBuilder: (_) => const <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(value: 'admin', child: Text('Make Admin')),
                  PopupMenuItem<String>(value: 'member', child: Text('Make Member')),
                  PopupMenuItem<String>(value: 'remove', child: Text('Remove')),
                ],
              ),
            ),
        ],
      ),
    );
  }
}


