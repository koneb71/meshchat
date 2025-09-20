import 'package:freezed_annotation/freezed_annotation.dart';

part 'models.freezed.dart';
part 'models.g.dart';

@freezed
class Identity with _$Identity {
  const factory Identity({
    required String pubEd25519,
    required String privEd25519Ref,
    required String pubX25519,
    required String privX25519Ref,
    required String displayName,
    required String safetyNumber,
  }) = _Identity;

  factory Identity.fromJson(Map<String, dynamic> json) => _$IdentityFromJson(json);
}

@freezed
class Channel with _$Channel {
  const factory Channel({
    required String id,
    required String name,
    required bool encrypted,
    String? senderKey,
    @Default(0) int messageCounter,
    required DateTime createdAt,
    DateTime? rotatedAt,
  }) = _Channel;

  factory Channel.fromJson(Map<String, dynamic> json) => _$ChannelFromJson(json);
}

@freezed
class MeshPacketModel with _$MeshPacketModel {
  const factory MeshPacketModel({
    required int version,
    required int type,
    required int ttl,
    required int hop,
    required int channelId64,
    required String msgIdHex,
    String? headerAdBase64,
    String? payloadBase64,
  }) = _MeshPacketModel;

  factory MeshPacketModel.fromJson(Map<String, dynamic> json) => _$MeshPacketModelFromJson(json);
}

@freezed
class Message with _$Message {
  const factory Message({
    required String id,
    required String channelId,
    required String senderId,
    required DateTime ts,
    String? ciphertextBase64,
    String? plaintext,
    String? hopInfo,
    String? deliveredHint,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
}

@freezed
class Peer with _$Peer {
  const factory Peer({
    required String shortId,
    int? rssi,
    DateTime? lastSeen,
    String? services,
    int? approxHops,
  }) = _Peer;

  factory Peer.fromJson(Map<String, dynamic> json) => _$PeerFromJson(json);
}
