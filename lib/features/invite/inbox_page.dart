import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../channels/channel_state.dart';

class InviteInboxPage extends ConsumerStatefulWidget {
  const InviteInboxPage({super.key});

  @override
  ConsumerState<InviteInboxPage> createState() => _InviteInboxPageState();
}

class _InviteInboxPageState extends ConsumerState<InviteInboxPage> {
  final List<Map<String, String>> _pending = <Map<String, String>>[];
  StreamSubscription? _sub;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _ensureSubscribed();
    return Scaffold(
      appBar: AppBar(title: const Text('Invite Inbox')),
      body: _pending.isEmpty
          ? const Center(child: Text('No invites yet'))
          : ListView.builder(
              itemCount: _pending.length,
              itemBuilder: (BuildContext _, int i) {
                final Map<String, String> evt = _pending[i];
                final String? bundle = evt['bundle'];
                final String? code = evt['code'];
                final Map<String, dynamic>? prev = ref.read(channelsProvider.notifier).previewFromInvite(bundle ?? code ?? '');
                final String title = prev != null ? prev['name'] as String : (bundle != null ? 'Channel Invite' : 'Invite Code');
                final String subtitle = prev != null
                    ? ((prev['enc'] as bool) ? 'Private' : 'Public') + (prev['enc'] == true ? ((prev['hasKey'] as bool) ? ' • includes key' : ' • no key') : '')
                    : '';
                return Card(
                  child: ListTile(
                    title: Text(title),
                    subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextButton(
                          onPressed: () {
                            setState(() => _pending.removeAt(i));
                          },
                          child: const Text('Decline'),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: () async {
                            bool ok = false;
                            if (bundle != null) {
                              ok = ref.read(channelsProvider.notifier).joinFromInvite(bundle);
                            } else if (code != null) {
                              ok = ref.read(channelsProvider.notifier).joinFromCode(code);
                            }
                            if (ok && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Joined channel')));
                            }
                            if (mounted) setState(() => _pending.removeAt(i));
                          },
                          child: const Text('Accept'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _ensureSubscribed() {
    if (_sub != null) return;
    _sub = ref.read(invitesStreamProvider).listen((Map<String, String> evt) {
      setState(() => _pending.add(evt));
    });
  }
}


