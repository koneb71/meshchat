import 'dart:convert';
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models.dart';
import '../../data/persistence.dart';
import 'package:cryptography/cryptography.dart';

class ChannelsNotifier extends StateNotifier<List<Channel>> {
  final FileStore _store = FileStore();
  static const String _file = 'channels.json';
  static const Duration _rekeyPeriod = Duration(days: 7);

  ChannelsNotifier() : super(const <Channel>[]) {
    _load();
  }

  void createChannel({required String name, required bool encrypted}) {
    final Channel ch = Channel(
      id: _deriveId64(name),
      name: name,
      encrypted: encrypted,
      senderKey: null,
      messageCounter: 0,
      createdAt: DateTime.now(),
      members: <Member>[],
      pinned: false,
    );
    state = <Channel>[...state, ch];
    _save();
    if (encrypted) {
      // Generate sender key asynchronously so UI can show hash immediately after creation
      // ignore: discarded_futures
      _ensureSenderKeyAsync(name);
    }
  }

  void togglePinned(String name) {
    state = state.map((Channel c) => c.name == name ? c.copyWith(pinned: !c.pinned) : c).toList();
    _save();
  }

  void addMember(String channelName, Member m) {
    state = state.map((Channel c) => c.name == channelName ? c.copyWith(members: <Member>[...c.members, m]) : c).toList();
    _save();
  }

  void removeMember(String channelName, String userId) {
    state = state.map((Channel c) => c.name == channelName ? c.copyWith(members: c.members.where((Member x) => x.userId != userId).toList()) : c).toList();
    _save();
  }

  void setRole(String channelName, String userId, String role) {
    state = state.map((Channel c) {
      if (c.name != channelName) return c;
      final List<Member> next = c.members.map((Member x) => x.userId == userId ? x.copyWith(role: role) : x).toList();
      return c.copyWith(members: next);
    }).toList();
    _save();
  }

  void joinPublicByName(String name) {
    if (state.any((Channel c) => c.name == name)) return;
    createChannel(name: name, encrypted: false);
  }

  String generateInviteBundle(Channel ch) {
    final Map<String, dynamic> bundle = <String, dynamic>{
      'v': 1,
      'name': ch.name,
      'enc': ch.encrypted,
    };
    if (ch.encrypted && ch.senderKey != null && ch.senderKey!.isNotEmpty) {
      bundle['kc'] = ch.senderKey;
    }
    return jsonEncode(bundle);
  }

  Map<String, dynamic>? previewFromInvite(String bundleOrCode) {
    try {
      String jsonStr;
      try {
        jsonStr = utf8.decode(base64Url.decode(bundleOrCode));
      } catch (_) {
        jsonStr = bundleOrCode;
      }
      final Map<String, dynamic> b = jsonDecode(jsonStr) as Map<String, dynamic>;
      final String name = b['name'] as String;
      final bool enc = (b['enc'] as bool?) ?? false;
      final bool hasKey = (b['kc'] as String?) != null;
      return <String, dynamic>{'name': name, 'enc': enc, 'hasKey': hasKey};
    } catch (_) {
      return null;
    }
  }

  String generateInviteCode(Channel ch) {
    final String json = generateInviteBundle(ch);
    return base64Url.encode(utf8.encode(json));
  }

  Future<String?> senderKeyHash(Channel ch) async {
    if (ch.senderKey == null || ch.senderKey!.isEmpty) return null;
    final List<int> kc = base64Url.decode(ch.senderKey!);
    final Hash h = await Sha256().hash(kc);
    final String hex = h.bytes.map((int b) => b.toRadixString(16).padLeft(2, '0')).join().toUpperCase();
    final String short = hex.substring(0, 20);
    return short.replaceAllMapped(RegExp(r'(.{4})'), (Match m) => '${m.group(1)} ').trim();
  }

  bool joinFromInvite(String bundle) {
    try {
      final Map<String, dynamic> b = jsonDecode(bundle) as Map<String, dynamic>;
      final String name = b['name'] as String;
      final bool enc = (b['enc'] as bool?) ?? false;
      if (state.any((Channel c) => c.name == name)) return true;
      createChannel(name: name, encrypted: enc);
      // If sender key was included, apply it
      final String? kc = b['kc'] as String?;
      if (enc && kc != null && kc.isNotEmpty) {
        updateChannelKey(name, kc, 0);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  bool joinFromCode(String code) {
    try {
      String jsonStr;
      try {
        jsonStr = utf8.decode(base64Url.decode(code));
      } catch (_) {
        jsonStr = code;
      }
      return joinFromInvite(jsonStr);
    } catch (_) {
      return false;
    }
  }

  String _deriveId64(String name) {
    // Simple hash64 from name for now
    int hash = 1125899906842597; // FNV-like
    for (final int code in name.codeUnits) {
      hash = (hash * 1099511628211) ^ code;
    }
    return hash.toUnsigned(64).toRadixString(16);
  }

  void updateChannelKey(String name, String keyBase64, int counter) {
    final List<Channel> next = state.map((Channel c) {
      if (c.name == name) {
        return c.copyWith(senderKey: keyBase64, messageCounter: counter);
      }
      return c;
    }).toList();
    state = next;
    _save();
  }

  void updateChannelCounter(String name, int counter) {
    final List<Channel> next = state.map((Channel c) {
      if (c.name == name) {
        return c.copyWith(messageCounter: counter);
      }
      return c;
    }).toList();
    state = next;
    _save();
  }

  Future<void> rotateSenderKeyNow(String name) async {
    final List<Channel> next = <Channel>[];
    for (final Channel c in state) {
      if (c.name == name && c.encrypted) {
        final List<int> newKey = await Chacha20.poly1305Aead().newSecretKey().then((SecretKey k) => k.extractBytes());
        next.add(c.copyWith(
          senderKey: base64Url.encode(newKey),
          messageCounter: 0,
          rotatedAt: DateTime.now(),
        ));
      } else {
        next.add(c);
      }
    }
    state = next;
    await _save();
  }

  Future<void> rotateDueKeys() async {
    final DateTime now = DateTime.now();
    bool changed = false;
    final List<Channel> next = <Channel>[];
    for (final Channel c in state) {
      if (c.encrypted) {
        final DateTime last = c.rotatedAt ?? c.createdAt;
        if (now.difference(last) >= _rekeyPeriod) {
          final List<int> newKey = await Chacha20.poly1305Aead().newSecretKey().then((SecretKey k) => k.extractBytes());
          next.add(c.copyWith(senderKey: base64Url.encode(newKey), messageCounter: 0, rotatedAt: now));
          changed = true;
          continue;
        }
      }
      next.add(c);
    }
    if (changed) {
      state = next;
      await _save();
    }
  }

  Future<void> _ensureSenderKeyAsync(String name) async {
    try {
      final List<Channel> list = state;
      Channel? ch;
      for (final Channel c in list) {
        if (c.name == name) { ch = c; break; }
      }
      if (ch == null || !ch.encrypted) return;
      if (ch.senderKey != null && ch.senderKey!.isNotEmpty) return;
      final List<int> newKey = await Chacha20.poly1305Aead().newSecretKey().then((SecretKey k) => k.extractBytes());
      updateChannelKey(name, base64Url.encode(newKey), 0);
    } catch (_) {}
  }

  Future<void> _load() async {
    final List<dynamic> list = await _store.readJsonList(ChannelsNotifier._file);
    final List<Channel> loaded = list.map((dynamic e) => Channel.fromJson(e as Map<String, dynamic>)).toList();
    if (loaded.isNotEmpty) {
      state = loaded;
      // Ensure any encrypted channels without a key get initialized
      for (final Channel c in state) {
        if (c.encrypted && (c.senderKey == null || c.senderKey!.isEmpty)) {
          // ignore: discarded_futures
          _ensureSenderKeyAsync(c.name);
        }
      }
    }
  }

  Future<void> _save() async {
    await _store.writeJson(ChannelsNotifier._file, state.map((Channel c) => c.toJson()).toList());
  }
}

final StateNotifierProvider<ChannelsNotifier, List<Channel>> channelsProvider =
    StateNotifierProvider<ChannelsNotifier, List<Channel>>((StateNotifierProviderRef<ChannelsNotifier, List<Channel>> ref) {
  return ChannelsNotifier();
});

