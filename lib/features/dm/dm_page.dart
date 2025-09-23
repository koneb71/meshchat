import 'dart:typed_data';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptography/cryptography.dart';

import '../../mesh/packet.dart';
import '../../mesh/codec.dart';
import '../../app/providers.dart';
import '../sessions/sessions_provider.dart';
import '../../crypto/aead.dart';
import '../../crypto/double_ratchet.dart';

class DmPage extends ConsumerStatefulWidget {
  final String peerId;
  const DmPage({super.key, required this.peerId});

  @override
  ConsumerState<DmPage> createState() => _DmPageState();
}

class _DmPageState extends ConsumerState<DmPage> {
  final TextEditingController _text = TextEditingController();
  final TextEditingController _sk = TextEditingController();
  final List<String> _messages = <String>[];
  StreamSubscription? _sub;

  @override
  void dispose() {
    _text.dispose();
    _sk.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _ensureSubscribed();
    return Scaffold(
      appBar: AppBar(title: Text('DM: ${widget.peerId}')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (BuildContext context, int index) {
                  final String raw = _messages[index];
                  final bool mine = raw.startsWith('Me:');
                  final String text = raw.replaceFirst(RegExp(r'^(Me:|Peer:)\s*'), '');
                  return Align(
                    alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: mine ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(text, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                    ),
                  );
                },
              ),
            ),
            TextField(controller: _sk, decoration: const InputDecoration(labelText: 'Peer ID to request prekey'), minLines: 1, maxLines: 1),
            Row(children: <Widget>[
              FilledButton(
                onPressed: () {
                  final String pid = _sk.text.trim().isEmpty ? widget.peerId : _sk.text.trim();
                  ref.read(sessionsProvider.notifier).addPeer(pid);
                  ref.read(sessionsProvider.notifier).requestPreKey(pid);
                },
                child: const Text('Request PreKey'),
              ),
            ]),
            const SizedBox(height: 8),
            Row(children: <Widget>[
              Expanded(child: TextField(controller: _text, decoration: const InputDecoration(hintText: 'Message'))),
              IconButton(onPressed: _send, icon: const Icon(Icons.send)),
            ]),
          ],
        ),
      ),
    );
  }

  Future<void> _send() async {
    final String msg = _text.text.trim();
    if (msg.isEmpty) return;
    _text.clear();
    setState(() => _messages.add('Me: $msg'));
    final RatchetState? rs = ref.read(sessionsProvider.notifier).ratchetFor(widget.peerId);
    if (rs == null) return;
    final (RatchetState next, SecretKey mk) = await DoubleRatchetService().nextSendingKey(rs);
    ref.read(sessionsProvider.notifier).updateRatchet(widget.peerId, next);
    final List<int> nonce12 = List<int>.filled(12, 0);
    final Uint8List pt = Uint8List.fromList(msg.codeUnits);
    final Uint8List ad = Uint8List.fromList(<int>[1, 1, 8, 0]);
    final Uint8List cipher = await aeadSeal(key: mk, nonce12: nonce12, plaintext: pt, ad: ad);
    final Uint8List msgId = _msgIdFromCtr(DateTime.now().millisecondsSinceEpoch);
    final MeshPacket pkt = MeshPacket(
      version: 1,
      type: 3,
      ttl: 8,
      hop: 0,
      channelId64: _dmChannelId(widget.peerId),
      msgId: msgId,
      headerAd: null,
      payload: cipher,
    );
    MeshCodec.encodeFrame(pkt);
    await ref.read(linkManagerProvider).broadcast(pkt);
  }

  int _dmChannelId(String peerId) => peerId.hashCode & 0x7FFFFFFFFFFFFFFF;

  Uint8List _msgIdFromCtr(int ctr) {
    final Uint8List id = Uint8List(12);
    final ByteData bd = ByteData(8)..setUint64(0, ctr);
    id.setAll(5, bd.buffer.asUint8List().sublist(1));
    return id;
  }

  void _ensureSubscribed() {
    if (_sub != null) return;
    _sub = ref.read(messagesStreamProvider).listen((MeshPacket pkt) async {
      if (pkt.type == 3 && pkt.channelId64 == _dmChannelId(widget.peerId) && pkt.payload != null) {
        final RatchetState? rs = ref.read(sessionsProvider.notifier).ratchetFor(widget.peerId);
        if (rs == null) return;
        final (RatchetState next, SecretKey mk) = await DoubleRatchetService().nextReceivingKey(rs);
        ref.read(sessionsProvider.notifier).updateRatchet(widget.peerId, next);
        final List<int> nonce12 = List<int>.filled(12, 0);
        final Uint8List ad = Uint8List.fromList(<int>[1, 1, 8, 0]);
        try {
          final Uint8List pt = await aeadOpen(key: mk, nonce12: nonce12, cipherAndTag: pkt.payload!, ad: ad);
          final String text = String.fromCharCodes(pt);
          if (mounted) {
            setState(() => _messages.add('Peer: $text'));
          }
        } catch (_) {
          // ignore decrypt failures
        }
      }
    });
  }
}


