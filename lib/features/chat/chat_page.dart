import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/providers.dart';
import '../../mesh/packet.dart';
import '../../mesh/codec.dart';
import 'messages_state.dart';
import '../channels/channel_crypto.dart';
import '../channels/channel_state.dart';

class ChatPage extends ConsumerStatefulWidget {
  final String channelName;
  const ChatPage({super.key, required this.channelName});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController _text = TextEditingController();
  int _counter = 0;
  List<Map<String, dynamic>> _messages = <Map<String, dynamic>>[];
  StreamSubscription? _sub;
  String _transport = '';

  @override
  void dispose() {
    _sub?.cancel();
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _ensureSubscribed();
    _messages = ref.watch(messagesProvider(widget.channelName));
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.channelName),
        actions: <Widget>[
          if (_transport.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Chip(label: Text(_transport), visualDensity: VisualDensity.compact),
            ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Consumer(builder: (BuildContext context, WidgetRef r, _) {
            final chEvt = r.watch(channelEventsProvider);
            return chEvt.when(
              data: (Map<String, String> evt) {
                if (evt['type'] == 'rekey' && evt['channel'] == widget.channelName) {
                  return MaterialBanner(
                    content: const Text('Channel re-keyed. Verify sender key hash from channel menu.'),
                    actions: <Widget>[
                      TextButton(onPressed: () => ScaffoldMessenger.of(context).hideCurrentMaterialBanner(), child: const Text('Dismiss')),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
              error: (_, __) => const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
            );
          }),
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (BuildContext c, int i) {
                final Map<String, dynamic> m = _messages[i];
                final bool mine = (m['me'] as bool?) ?? false;
                final String text = (m['text'] as String?) ?? '';
                final int? tsMs = m['ts'] as int?;
                final int? deliv = m['deliv'] as int?;
                final DateTime? ts = tsMs != null ? DateTime.fromMillisecondsSinceEpoch(tsMs) : null;
                return Align(
                  alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Dismissible(
                    key: ValueKey<String>((m['id'] as String?) ?? '$i'),
                    direction: mine ? DismissDirection.endToStart : DismissDirection.none,
                    onDismissed: (_) {
                      final String? id = m['id'] as String?;
                      if (id != null) {
                        ref.read(messagesProvider(widget.channelName).notifier).removeById(id);
                      }
                    },
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      color: Theme.of(context).colorScheme.errorContainer,
                      child: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.onErrorContainer),
                    ),
                    child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: mine ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Tooltip(
                          message: ts != null ? '${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}' : '',
                          child: GestureDetector(
                            onLongPress: () async {
                              await showModalBottomSheet<void>(
                                context: context,
                                builder: (_) => SafeArea(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      ListTile(
                                        leading: const Icon(Icons.copy),
                                        title: const Text('Copy'),
                                        onTap: () async {
                                          await Clipboard.setData(ClipboardData(text: text));
                                          if (mounted) Navigator.pop(context);
                                        },
                                      ),
                                      if (mine)
                                        ListTile(
                                          leading: const Icon(Icons.delete_outline),
                                          title: const Text('Delete (local)'),
                                          onTap: () {
                                            setState(() => _messages.removeAt(i));
                                            Navigator.pop(context);
                                          },
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              text,
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                            ),
                          ),
                        ),
                        if (mine && deliv != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              'Delivered via $deliv hops',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                      ],
                    ),
                  ),
                ));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _text,
                    decoration: const InputDecoration(hintText: 'Message'),
                  ),
                ),
                IconButton(icon: const Icon(Icons.send), onPressed: _send),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _ensureSubscribed() {
    if (_sub != null) return;
    ref.read(linkManagerProvider).onTransport = (String t) { if (mounted) setState(() => _transport = t); };
    _sub = ref.read(messagesStreamProvider).listen((event) async {
      if (event.type == 3 && event.channelId64 == _hash64(widget.channelName)) {
        final channels = ref.read(channelsProvider);
        final bool isEncrypted = channels.firstWhere((c) => c.name == widget.channelName, orElse: () => channels.first).encrypted;
        MeshPacket deliver = event;
        if (isEncrypted && event.payload != null) {
          final ChannelCryptoService ccs = ChannelCryptoService(ref);
          final Uint8List? pt = await ccs.openForChannel(widget.channelName, event, event.payload!);
          if (pt == null) return;
          deliver = MeshPacket(
            version: event.version,
            type: event.type,
            ttl: event.ttl,
            hop: event.hop,
            channelId64: event.channelId64,
            msgId: event.msgId,
            headerAd: event.headerAd,
            payload: pt,
          );
        }
        ref.read(messagesProvider(widget.channelName).notifier).addIncoming(deliver);
      } else if (event.type == 4 && event.channelId64 == _hash64(widget.channelName)) {
        // ACK observed for this channel; annotate bubble by msgId
        ref.read(messagesProvider(widget.channelName).notifier).markDelivered(event.msgId.toString(), hops: event.hop);
      }
    });
  }

  Future<void> _send() async {
    final String msg = _text.text.trim();
    if (msg.isEmpty) return;
    _text.clear();
    final int channelId64 = _hash64(widget.channelName);
    final Uint8List msgId = _nextMsgId();
    final String msgIdHex = msgId.map((int b) => b.toRadixString(16).padLeft(2, '0')).join();
    ref.read(messagesProvider(widget.channelName).notifier).addLocal(msg, msgIdHex);
    MeshPacket pkt = MeshPacket(
      version: 1,
      type: 3, // MSG
      ttl: 8,
      hop: 0,
      channelId64: channelId64,
      msgId: msgId,
      headerAd: null,
      payload: Uint8List.fromList(msg.codeUnits),
    );
    final channels = ref.read(channelsProvider);
    final bool isEncrypted = channels.firstWhere((c) => c.name == widget.channelName, orElse: () => channels.first).encrypted;
    if (isEncrypted) {
      final ChannelCryptoService ccs = ChannelCryptoService(ref);
      final (Uint8List cipher, List<int> _) = await ccs.sealForChannel(widget.channelName, pkt, Uint8List.fromList(msg.codeUnits));
      pkt = MeshPacket(
        version: pkt.version,
        type: pkt.type,
        ttl: pkt.ttl,
        hop: pkt.hop,
        channelId64: pkt.channelId64,
        msgId: pkt.msgId,
        headerAd: pkt.headerAd,
        payload: cipher,
      );
    }
    // Encode to frame to ensure size
    MeshCodec.encodeFrame(pkt);
    // Broadcast via link manager (no actual BLE link in this scaffold)
    await ref.read(linkManagerProvider).broadcast(pkt);
  }

  int _hash64(String s) {
    int hash = 1125899906842597; // FNV-like
    for (final int code in s.codeUnits) {
      hash = (hash * 1099511628211) ^ code;
    }
    return hash & 0x7FFFFFFFFFFFFFFF; // keep positive
  }

  Uint8List _nextMsgId() {
    // 12-byte: 5 bytes sender short id (placeholder zeros) + 7 bytes counter
    final Uint8List id = Uint8List(12);
    _counter++;
    final ByteData bd = ByteData(8)..setUint64(0, _counter);
    id.setAll(5, bd.buffer.asUint8List().sublist(1));
    return id;
  }
}
