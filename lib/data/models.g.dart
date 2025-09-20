// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$IdentityImpl _$$IdentityImplFromJson(Map<String, dynamic> json) =>
    _$IdentityImpl(
      pubEd25519: json['pubEd25519'] as String,
      privEd25519Ref: json['privEd25519Ref'] as String,
      pubX25519: json['pubX25519'] as String,
      privX25519Ref: json['privX25519Ref'] as String,
      displayName: json['displayName'] as String,
      safetyNumber: json['safetyNumber'] as String,
    );

Map<String, dynamic> _$$IdentityImplToJson(_$IdentityImpl instance) =>
    <String, dynamic>{
      'pubEd25519': instance.pubEd25519,
      'privEd25519Ref': instance.privEd25519Ref,
      'pubX25519': instance.pubX25519,
      'privX25519Ref': instance.privX25519Ref,
      'displayName': instance.displayName,
      'safetyNumber': instance.safetyNumber,
    };

_$ChannelImpl _$$ChannelImplFromJson(Map<String, dynamic> json) =>
    _$ChannelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      encrypted: json['encrypted'] as bool,
      senderKey: json['senderKey'] as String?,
      messageCounter: (json['messageCounter'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      rotatedAt: json['rotatedAt'] == null
          ? null
          : DateTime.parse(json['rotatedAt'] as String),
    );

Map<String, dynamic> _$$ChannelImplToJson(_$ChannelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'encrypted': instance.encrypted,
      'senderKey': instance.senderKey,
      'messageCounter': instance.messageCounter,
      'createdAt': instance.createdAt.toIso8601String(),
      'rotatedAt': instance.rotatedAt?.toIso8601String(),
    };

_$MeshPacketModelImpl _$$MeshPacketModelImplFromJson(
        Map<String, dynamic> json) =>
    _$MeshPacketModelImpl(
      version: (json['version'] as num).toInt(),
      type: (json['type'] as num).toInt(),
      ttl: (json['ttl'] as num).toInt(),
      hop: (json['hop'] as num).toInt(),
      channelId64: (json['channelId64'] as num).toInt(),
      msgIdHex: json['msgIdHex'] as String,
      headerAdBase64: json['headerAdBase64'] as String?,
      payloadBase64: json['payloadBase64'] as String?,
    );

Map<String, dynamic> _$$MeshPacketModelImplToJson(
        _$MeshPacketModelImpl instance) =>
    <String, dynamic>{
      'version': instance.version,
      'type': instance.type,
      'ttl': instance.ttl,
      'hop': instance.hop,
      'channelId64': instance.channelId64,
      'msgIdHex': instance.msgIdHex,
      'headerAdBase64': instance.headerAdBase64,
      'payloadBase64': instance.payloadBase64,
    };

_$MessageImpl _$$MessageImplFromJson(Map<String, dynamic> json) =>
    _$MessageImpl(
      id: json['id'] as String,
      channelId: json['channelId'] as String,
      senderId: json['senderId'] as String,
      ts: DateTime.parse(json['ts'] as String),
      ciphertextBase64: json['ciphertextBase64'] as String?,
      plaintext: json['plaintext'] as String?,
      hopInfo: json['hopInfo'] as String?,
      deliveredHint: json['deliveredHint'] as String?,
    );

Map<String, dynamic> _$$MessageImplToJson(_$MessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'channelId': instance.channelId,
      'senderId': instance.senderId,
      'ts': instance.ts.toIso8601String(),
      'ciphertextBase64': instance.ciphertextBase64,
      'plaintext': instance.plaintext,
      'hopInfo': instance.hopInfo,
      'deliveredHint': instance.deliveredHint,
    };

_$PeerImpl _$$PeerImplFromJson(Map<String, dynamic> json) => _$PeerImpl(
      shortId: json['shortId'] as String,
      rssi: (json['rssi'] as num?)?.toInt(),
      lastSeen: json['lastSeen'] == null
          ? null
          : DateTime.parse(json['lastSeen'] as String),
      services: json['services'] as String?,
      approxHops: (json['approxHops'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$PeerImplToJson(_$PeerImpl instance) =>
    <String, dynamic>{
      'shortId': instance.shortId,
      'rssi': instance.rssi,
      'lastSeen': instance.lastSeen?.toIso8601String(),
      'services': instance.services,
      'approxHops': instance.approxHops,
    };
