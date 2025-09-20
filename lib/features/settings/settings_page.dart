import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/identity_provider.dart';
import '../../app/providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ref.watch(identityProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: const Text('Display Name'),
            subtitle: Text(id?.displayName ?? 'Not set'),
            onTap: () async {
              final String? name = await showDialog<String>(
                context: context,
                builder: (BuildContext ctx) {
                  final TextEditingController c = TextEditingController(text: id?.displayName ?? '');
                  return AlertDialog(
                    title: const Text('Edit Display Name'),
                    content: TextField(controller: c, decoration: const InputDecoration(labelText: 'Name')),
                    actions: <Widget>[
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                      FilledButton(onPressed: () => Navigator.pop(ctx, c.text.trim()), child: const Text('Save')),
                    ],
                  );
                },
              );
              if (name != null && name.isNotEmpty) {
                await ref.read(identityProvider.notifier).setDisplayName(name);
              }
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Theme'),
            subtitle: Consumer(builder: (BuildContext context, WidgetRef r, _) {
              final String mode = r.watch(themeModeProvider);
              return DropdownButton<String>(
                value: mode,
                items: const <DropdownMenuItem<String>>[
                  DropdownMenuItem<String>(value: 'system', child: Text('System')),
                  DropdownMenuItem<String>(value: 'light', child: Text('Light')),
                  DropdownMenuItem<String>(value: 'dark', child: Text('Dark')),
                ],
                onChanged: (String? v) {
                  if (v != null) r.read(themeModeProvider.notifier).state = v;
                },
              );
            }),
          ),
          ListTile(
            title: const Text('Safety Number'),
            subtitle: Text(id?.safetyNumber ?? '—'),
          ),
        ],
      ),
    );
  }
}
