import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'channel_state.dart';
import '../../app/providers.dart';
import 'scanner_page.dart';
import '../chat/chat_page.dart';
import 'invite_qr.dart';
import '../dm/dm_page.dart';
import '../../data/identity_provider.dart' as idp;
import '../invite/inbox_page.dart';
import 'channel_details_page.dart';

class ChannelListPage extends ConsumerWidget {
  const ChannelListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List channels = ref.watch(channelsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Channels'), actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.inbox),
          tooltip: 'Invite Inbox',
          onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const InviteInboxPage())),
        ),
        Consumer(builder: (BuildContext context, WidgetRef r, _) {
          final inv = r.watch(invitesEventsProvider);
          return inv.when(
            data: (Map<String, String> evt) {
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                final Map<String, dynamic>? prev = ref.read(channelsProvider.notifier).previewFromInvite(evt['bundle'] ?? evt['code'] ?? '');
                final bool? ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Channel Invite'),
                    content: prev != null
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('Name: ${prev['name']}'),
                              Text('Type: ${(prev['enc'] as bool) ? 'Private' : 'Public'}'),
                              if (prev['enc'] == true) Text('Includes Key: ${(prev['hasKey'] as bool) ? 'Yes' : 'No'}'),
                            ],
                          )
                        : Text(evt.containsKey('bundle') ? 'Accept channel invite?' : 'Accept invite code?'),
                    actions: <Widget>[
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Decline')),
                      FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Accept')),
                    ],
                  ),
                );
                if (ok == true) {
                  if (evt['bundle'] != null) {
                    r.read(channelsProvider.notifier).joinFromInvite(evt['bundle']!);
                  } else if (evt['code'] != null) {
                    r.read(channelsProvider.notifier).joinFromCode(evt['code']!);
                  }
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Joined channel via invite')));
                }
              });
              return const SizedBox.shrink();
            },
            error: (_, __) => const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
          );
        }),
        Consumer(builder: (BuildContext context, WidgetRef r, _) {
          final chEvt = r.watch(channelEventsProvider);
          return chEvt.when(
            data: (Map<String, String> evt) {
              if (evt['type'] == 'rekey') {
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  final String name = evt['channel'] ?? '';
                  final String? hash = await r.read(channelsProvider.notifier).senderKeyHash(r.read(channelsProvider).firstWhere((c) => c.name == name));
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Channel "$name" re-keyed. Verify: ${hash ?? 'N/A'}')));
                });
              }
              return const SizedBox.shrink();
            },
            error: (_, __) => const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
          );
        }),
        IconButton(
          icon: const Icon(Icons.link),
          tooltip: 'Join via invite code',
          onPressed: () async {
            final TextEditingController c = TextEditingController();
            final String? code = await showDialog<String>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Enter Invite Code'),
                content: TextField(controller: c, decoration: const InputDecoration(hintText: 'paste code here')),
                actions: <Widget>[
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                  FilledButton(onPressed: () => Navigator.pop(context, c.text.trim()), child: const Text('Join')),
                ],
              ),
            );
            if (code != null && code.isNotEmpty) {
              final bool ok = ref.read(channelsProvider.notifier).joinFromCode(code);
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Joined from code' : 'Invalid invite code')));
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.qr_code_scanner),
          onPressed: () async {
            final String? bundle = await Navigator.of(context).push<String>(
              MaterialPageRoute<String>(builder: (_) => const ScannerPage()),
            );
            if (bundle != null) {
              ref.read(channelsProvider.notifier).joinFromInvite(bundle);
            }
          },
        ),
      ]),
      body: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 88),
        itemCount: (() {
          final pinned = channels.where((c) => c.pinned).toList();
          final others = channels.where((c) => !c.pinned).toList();
          int count = 0;
          if (pinned.isNotEmpty) count += 1 + pinned.length; // header + items
          if (others.isNotEmpty) count += 1 + others.length;
          return count;
        })(),
        itemBuilder: (BuildContext c, int i) {
          final pinned = channels.where((c) => c.pinned).toList();
          final others = channels.where((c) => !c.pinned).toList();
          final List<Object> items = <Object>[];
          if (pinned.isNotEmpty) { items.add('__PINNED__'); items.addAll(pinned.cast<Object>()); }
          if (others.isNotEmpty) { items.add('__ALL__'); items.addAll(others.cast<Object>()); }
          final Object it = items[i];
          if (it is String) {
            final String title = it == '__PINNED__' ? 'Pinned' : 'All Channels';
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
              child: Text(title, style: Theme.of(context).textTheme.labelLarge),
            );
          }
          final ch = it as dynamic;
          return Dismissible(
            key: ValueKey<String>(ch.name),
            direction: DismissDirection.startToEnd,
            onDismissed: (_) {
              ref.read(channelsProvider.notifier).togglePinned(ch.name);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ch.pinned ? 'Unpinned' : 'Pinned')));
            },
            background: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: Icon(Icons.push_pin, color: Theme.of(context).colorScheme.onSecondaryContainer),
            ),
            child: Card(
              child: ListTile(
                title: Row(children: <Widget>[
                  Expanded(child: Text(ch.name, style: const TextStyle(fontWeight: FontWeight.w700))),
                  if (ch.pinned) const Icon(Icons.push_pin, size: 18),
                ]),
                subtitle: Text(ch.encrypted ? 'Private' : 'Public'),
                trailing: PopupMenuButton<String>(
                onSelected: (String sel) async {
                  if (sel == 'qr') {
                    final String bundle = ref.read(channelsProvider.notifier).generateInviteBundle(ch);
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => InviteQrPage(bundle: bundle)));
                  } else if (sel == 'code') {
                    final String code = ref.read(channelsProvider.notifier).generateInviteCode(ch);
                    await showDialog<void>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Invite Code'),
                        content: SelectableText(code),
                        actions: <Widget>[TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
                      ),
                    );
                  } else if (sel == 'hash') {
                    final String? hash = await ref.read(channelsProvider.notifier).senderKeyHash(ch);
                    await showDialog<void>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Sender Key Hash (verify)'),
                        content: SelectableText(hash ?? 'N/A'),
                        actions: <Widget>[TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
                      ),
                    );
                  } else if (sel == 'rotate') {
                      await ref.read(channelsProvider.notifier).rotateSenderKeyNow(ch.name);
                      await ref.read(channelControlProvider).sendRekey(ch.name);
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sender key rotated')));
                  } else if (sel == 'members') {
                    showModalBottomSheet<void>(
                      context: context,
                      showDragHandle: true,
                      isScrollControlled: true,
                      builder: (BuildContext ctx) {
                        return Consumer(builder: (BuildContext context, WidgetRef r, _) {
                          final id = r.watch(idp.identityProvider);
                          final peers = r.watch(nearbyPeersProvider);
                          return SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text('Members: ${ch.name}', style: Theme.of(context).textTheme.titleMedium),
                                  const SizedBox(height: 12),
                                  if (id != null)
                                    ListTile(
                                      leading: const Icon(Icons.person),
                                      title: Text(id.displayName.isNotEmpty ? id.displayName : 'You'),
                                      subtitle: Text('Safety: ${id.safetyNumber}'),
                                    ),
                                  peers.when(
                                    data: (list) => Flexible(
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: list.length,
                                        itemBuilder: (BuildContext _, int i) {
                                          final d = list[i];
                                          return ListTile(
                                            leading: const Icon(Icons.devices_other),
                                            title: Text(d.platformName.isNotEmpty ? d.platformName : 'Unknown device'),
                                            subtitle: Text('ID: ${d.remoteId.str}'),
                                          );
                                        },
                                      ),
                                    ),
                                    loading: () => const Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator()),
                                    error: (_, __) => const SizedBox.shrink(),
                                  ),
                                  const SizedBox(height: 8),
                                  Text('This list shows nearby peers. Full membership sync is planned.', style: Theme.of(context).textTheme.bodySmall),
                                ],
                              ),
                            ),
                          );
                        });
                      },
                    );
                  } else if (sel == 'details') {
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ChannelDetailsPage(channelName: ch.name)));
                  } else if (sel == 'pin') {
                    ref.read(channelsProvider.notifier).togglePinned(ch.name);
                  }
                },
                itemBuilder: (_) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(value: 'qr', child: Text('Show QR Invite')),
                  const PopupMenuItem<String>(value: 'code', child: Text('Show Invite Code')),
                  const PopupMenuItem<String>(value: 'hash', child: Text('Show Sender Key Hash')),
                  const PopupMenuItem<String>(value: 'rotate', child: Text('Rotate Sender Key Now')),
                  const PopupMenuItem<String>(value: 'members', child: Text('View Members')),
                  const PopupMenuItem<String>(value: 'details', child: Text('Channel Details')),
                  PopupMenuItem<String>(value: 'pin', child: Text(ch.pinned ? 'Unpin' : 'Pin')),
                ],
              ),
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ChatPage(channelName: ch.name))),
            ),
          ));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final _NewChannel? nc = await showDialog<_NewChannel>(
            context: context,
            builder: (_) => const _CreateJoinDialog(),
          );
          if (nc != null) {
            if (nc.joinExisting) {
              ref.read(channelsProvider.notifier).joinPublicByName(nc.name);
            } else {
              ref.read(channelsProvider.notifier).createChannel(name: nc.name, encrypted: nc.encrypted);
            }
          }
        },
        child: const Icon(Icons.add),
      ),
      persistentFooterButtons: <Widget>[
        IconButton(
          icon: const Icon(Icons.person_outline),
          tooltip: 'Direct Message (demo) ',
          onPressed: () async {
            final String? peer = await showDialog<String>(
              context: context,
              builder: (_) {
                final TextEditingController c = TextEditingController();
                return AlertDialog(
                  title: const Text('Peer ID'),
                  content: TextField(controller: c, decoration: const InputDecoration(hintText: 'peer-short-id')),
                  actions: <Widget>[
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    FilledButton(onPressed: () => Navigator.pop(context, c.text.trim()), child: const Text('Open')),
                  ],
                );
              },
            );
            if (peer != null && peer.isNotEmpty) {
              // ignore: use_build_context_synchronously
              Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => DmPage(peerId: peer)));
            }
          },
        ),
      ],
    );
  }
}

class _CreateJoinDialog extends StatefulWidget {
  const _CreateJoinDialog();

  @override
  State<_CreateJoinDialog> createState() => _CreateJoinDialogState();
}

class _CreateJoinDialogState extends State<_CreateJoinDialog> {
  final TextEditingController _name = TextEditingController();
  bool _encrypted = false;
  bool _joinExisting = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New channel / Join'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Name')),
          CheckboxListTile(value: _encrypted, onChanged: (bool? v) => setState(() => _encrypted = v ?? false), title: const Text('Private (sender keys)')),
          CheckboxListTile(value: _joinExisting, onChanged: (bool? v) => setState(() => _joinExisting = v ?? false), title: const Text('Join public by name')),
        ],
      ),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () => Navigator.pop(context, _NewChannel(_name.text.trim(), _encrypted, _joinExisting)),
          child: const Text('OK'),
        ),
      ],
    );
  }
}

class _NewChannel {
  final String name; final bool encrypted; final bool joinExisting;
  _NewChannel(this.name, this.encrypted, this.joinExisting);
}

// scanner implemented in scanner_page.dart


