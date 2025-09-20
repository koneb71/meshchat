// ignore_for_file: unused_import
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/persistence.dart';
import '../../mesh/packet.dart';
import '../../core/utils.dart';

class MessagesNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  final FileStore _store = FileStore();
  final String channelKey;
  MessagesNotifier(this.channelKey) : super(const <Map<String, dynamic>>[]) {
    _load();
  }

  void addLocal(String text, String msgIdHex) {
    final int ms = DateTime.now().millisecondsSinceEpoch;
    state = <Map<String, dynamic>>[
      ...state,
      <String, dynamic>{'me': true, 'text': text, 'ts': ms, 'id': msgIdHex, 'deliv': null},
    ];
    _save();
  }

  void addIncoming(MeshPacket pkt) {
    final String body = String.fromCharCodes(pkt.payload ?? <int>[]);
    final int ms = DateTime.now().millisecondsSinceEpoch;
    final String idHex = hex(pkt.msgId);
    state = <Map<String, dynamic>>[
      ...state,
      <String, dynamic>{'me': false, 'text': body, 'ts': ms, 'id': idHex},
    ];
    _save();
  }

  void markDelivered(String msgIdHex, {int? hops}) {
    final List<Map<String, dynamic>> next = List<Map<String, dynamic>>.from(state);
    for (int i = 0; i < next.length; i++) {
      final Map<String, dynamic> m = next[i];
      if (m['me'] == true && (m['id'] as String).toLowerCase() == msgIdHex.toLowerCase()) {
        next[i] = <String, dynamic>{...m, 'deliv': hops ?? 1};
        break;
      }
    }
    state = next;
    _save();
  }

  Future<void> _load() async {
    final Map<String, dynamic> map = await _store.readJsonMap('messages.json');
    final List<dynamic>? list = map[channelKey] as List<dynamic>?;
    if (list != null) {
      if (list.isNotEmpty && list.first is String) {
        // migrate from old string format
        final List<Map<String, dynamic>> migrated = <Map<String, dynamic>>[];
        for (final dynamic s in list) {
          final String line = s as String;
          final bool me = line.startsWith('Me:');
          final List<String> parts = line.replaceFirst(RegExp(r'^(Me:|Peer:)\\s*'), '').split('||');
          final String text = parts.isNotEmpty ? parts[0] : '';
          final int ts = parts.length > 1 ? int.tryParse(parts[1]) ?? DateTime.now().millisecondsSinceEpoch : DateTime.now().millisecondsSinceEpoch;
          String? id;
          int? deliv;
          for (final String p in parts.skip(2)) {
            if (p.startsWith('id:')) id = p.substring(3);
            if (p.startsWith('deliv:')) deliv = int.tryParse(p.substring(6));
          }
          migrated.add(<String, dynamic>{'me': me, 'text': text, 'ts': ts, if (id != null) 'id': id, if (deliv != null) 'deliv': deliv});
        }
        state = migrated;
      } else {
        state = list.cast<Map<String, dynamic>>();
      }
    }
  }

  Future<void> _save() async {
    final Map<String, dynamic> map = await _store.readJsonMap('messages.json');
    map[channelKey] = state;
    await _store.writeJson('messages.json', map);
  }
}

final StateNotifierProviderFamily<MessagesNotifier, List<Map<String, dynamic>>, String> messagesProvider =
    StateNotifierProviderFamily<MessagesNotifier, List<Map<String, dynamic>>, String>((ref, String channelKey) {
  return MessagesNotifier(channelKey);
});


