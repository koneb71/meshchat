// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Identity _$IdentityFromJson(Map<String, dynamic> json) {
  return _Identity.fromJson(json);
}

/// @nodoc
mixin _$Identity {
  String get pubEd25519 => throw _privateConstructorUsedError;
  String get privEd25519Ref => throw _privateConstructorUsedError;
  String get pubX25519 => throw _privateConstructorUsedError;
  String get privX25519Ref => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;
  String get safetyNumber => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $IdentityCopyWith<Identity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IdentityCopyWith<$Res> {
  factory $IdentityCopyWith(Identity value, $Res Function(Identity) then) =
      _$IdentityCopyWithImpl<$Res, Identity>;
  @useResult
  $Res call(
      {String pubEd25519,
      String privEd25519Ref,
      String pubX25519,
      String privX25519Ref,
      String displayName,
      String safetyNumber});
}

/// @nodoc
class _$IdentityCopyWithImpl<$Res, $Val extends Identity>
    implements $IdentityCopyWith<$Res> {
  _$IdentityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pubEd25519 = null,
    Object? privEd25519Ref = null,
    Object? pubX25519 = null,
    Object? privX25519Ref = null,
    Object? displayName = null,
    Object? safetyNumber = null,
  }) {
    return _then(_value.copyWith(
      pubEd25519: null == pubEd25519
          ? _value.pubEd25519
          : pubEd25519 // ignore: cast_nullable_to_non_nullable
              as String,
      privEd25519Ref: null == privEd25519Ref
          ? _value.privEd25519Ref
          : privEd25519Ref // ignore: cast_nullable_to_non_nullable
              as String,
      pubX25519: null == pubX25519
          ? _value.pubX25519
          : pubX25519 // ignore: cast_nullable_to_non_nullable
              as String,
      privX25519Ref: null == privX25519Ref
          ? _value.privX25519Ref
          : privX25519Ref // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      safetyNumber: null == safetyNumber
          ? _value.safetyNumber
          : safetyNumber // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$IdentityImplCopyWith<$Res>
    implements $IdentityCopyWith<$Res> {
  factory _$$IdentityImplCopyWith(
          _$IdentityImpl value, $Res Function(_$IdentityImpl) then) =
      __$$IdentityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String pubEd25519,
      String privEd25519Ref,
      String pubX25519,
      String privX25519Ref,
      String displayName,
      String safetyNumber});
}

/// @nodoc
class __$$IdentityImplCopyWithImpl<$Res>
    extends _$IdentityCopyWithImpl<$Res, _$IdentityImpl>
    implements _$$IdentityImplCopyWith<$Res> {
  __$$IdentityImplCopyWithImpl(
      _$IdentityImpl _value, $Res Function(_$IdentityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pubEd25519 = null,
    Object? privEd25519Ref = null,
    Object? pubX25519 = null,
    Object? privX25519Ref = null,
    Object? displayName = null,
    Object? safetyNumber = null,
  }) {
    return _then(_$IdentityImpl(
      pubEd25519: null == pubEd25519
          ? _value.pubEd25519
          : pubEd25519 // ignore: cast_nullable_to_non_nullable
              as String,
      privEd25519Ref: null == privEd25519Ref
          ? _value.privEd25519Ref
          : privEd25519Ref // ignore: cast_nullable_to_non_nullable
              as String,
      pubX25519: null == pubX25519
          ? _value.pubX25519
          : pubX25519 // ignore: cast_nullable_to_non_nullable
              as String,
      privX25519Ref: null == privX25519Ref
          ? _value.privX25519Ref
          : privX25519Ref // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      safetyNumber: null == safetyNumber
          ? _value.safetyNumber
          : safetyNumber // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$IdentityImpl implements _Identity {
  const _$IdentityImpl(
      {required this.pubEd25519,
      required this.privEd25519Ref,
      required this.pubX25519,
      required this.privX25519Ref,
      required this.displayName,
      required this.safetyNumber});

  factory _$IdentityImpl.fromJson(Map<String, dynamic> json) =>
      _$$IdentityImplFromJson(json);

  @override
  final String pubEd25519;
  @override
  final String privEd25519Ref;
  @override
  final String pubX25519;
  @override
  final String privX25519Ref;
  @override
  final String displayName;
  @override
  final String safetyNumber;

  @override
  String toString() {
    return 'Identity(pubEd25519: $pubEd25519, privEd25519Ref: $privEd25519Ref, pubX25519: $pubX25519, privX25519Ref: $privX25519Ref, displayName: $displayName, safetyNumber: $safetyNumber)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IdentityImpl &&
            (identical(other.pubEd25519, pubEd25519) ||
                other.pubEd25519 == pubEd25519) &&
            (identical(other.privEd25519Ref, privEd25519Ref) ||
                other.privEd25519Ref == privEd25519Ref) &&
            (identical(other.pubX25519, pubX25519) ||
                other.pubX25519 == pubX25519) &&
            (identical(other.privX25519Ref, privX25519Ref) ||
                other.privX25519Ref == privX25519Ref) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.safetyNumber, safetyNumber) ||
                other.safetyNumber == safetyNumber));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, pubEd25519, privEd25519Ref,
      pubX25519, privX25519Ref, displayName, safetyNumber);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$IdentityImplCopyWith<_$IdentityImpl> get copyWith =>
      __$$IdentityImplCopyWithImpl<_$IdentityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$IdentityImplToJson(
      this,
    );
  }
}

abstract class _Identity implements Identity {
  const factory _Identity(
      {required final String pubEd25519,
      required final String privEd25519Ref,
      required final String pubX25519,
      required final String privX25519Ref,
      required final String displayName,
      required final String safetyNumber}) = _$IdentityImpl;

  factory _Identity.fromJson(Map<String, dynamic> json) =
      _$IdentityImpl.fromJson;

  @override
  String get pubEd25519;
  @override
  String get privEd25519Ref;
  @override
  String get pubX25519;
  @override
  String get privX25519Ref;
  @override
  String get displayName;
  @override
  String get safetyNumber;
  @override
  @JsonKey(ignore: true)
  _$$IdentityImplCopyWith<_$IdentityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Channel _$ChannelFromJson(Map<String, dynamic> json) {
  return _Channel.fromJson(json);
}

/// @nodoc
mixin _$Channel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  bool get encrypted => throw _privateConstructorUsedError;
  String? get senderKey => throw _privateConstructorUsedError;
  int get messageCounter => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get rotatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ChannelCopyWith<Channel> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChannelCopyWith<$Res> {
  factory $ChannelCopyWith(Channel value, $Res Function(Channel) then) =
      _$ChannelCopyWithImpl<$Res, Channel>;
  @useResult
  $Res call(
      {String id,
      String name,
      bool encrypted,
      String? senderKey,
      int messageCounter,
      DateTime createdAt,
      DateTime? rotatedAt});
}

/// @nodoc
class _$ChannelCopyWithImpl<$Res, $Val extends Channel>
    implements $ChannelCopyWith<$Res> {
  _$ChannelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? encrypted = null,
    Object? senderKey = freezed,
    Object? messageCounter = null,
    Object? createdAt = null,
    Object? rotatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      encrypted: null == encrypted
          ? _value.encrypted
          : encrypted // ignore: cast_nullable_to_non_nullable
              as bool,
      senderKey: freezed == senderKey
          ? _value.senderKey
          : senderKey // ignore: cast_nullable_to_non_nullable
              as String?,
      messageCounter: null == messageCounter
          ? _value.messageCounter
          : messageCounter // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      rotatedAt: freezed == rotatedAt
          ? _value.rotatedAt
          : rotatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChannelImplCopyWith<$Res> implements $ChannelCopyWith<$Res> {
  factory _$$ChannelImplCopyWith(
          _$ChannelImpl value, $Res Function(_$ChannelImpl) then) =
      __$$ChannelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      bool encrypted,
      String? senderKey,
      int messageCounter,
      DateTime createdAt,
      DateTime? rotatedAt});
}

/// @nodoc
class __$$ChannelImplCopyWithImpl<$Res>
    extends _$ChannelCopyWithImpl<$Res, _$ChannelImpl>
    implements _$$ChannelImplCopyWith<$Res> {
  __$$ChannelImplCopyWithImpl(
      _$ChannelImpl _value, $Res Function(_$ChannelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? encrypted = null,
    Object? senderKey = freezed,
    Object? messageCounter = null,
    Object? createdAt = null,
    Object? rotatedAt = freezed,
  }) {
    return _then(_$ChannelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      encrypted: null == encrypted
          ? _value.encrypted
          : encrypted // ignore: cast_nullable_to_non_nullable
              as bool,
      senderKey: freezed == senderKey
          ? _value.senderKey
          : senderKey // ignore: cast_nullable_to_non_nullable
              as String?,
      messageCounter: null == messageCounter
          ? _value.messageCounter
          : messageCounter // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      rotatedAt: freezed == rotatedAt
          ? _value.rotatedAt
          : rotatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChannelImpl implements _Channel {
  const _$ChannelImpl(
      {required this.id,
      required this.name,
      required this.encrypted,
      this.senderKey,
      this.messageCounter = 0,
      required this.createdAt,
      this.rotatedAt});

  factory _$ChannelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChannelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final bool encrypted;
  @override
  final String? senderKey;
  @override
  @JsonKey()
  final int messageCounter;
  @override
  final DateTime createdAt;
  @override
  final DateTime? rotatedAt;

  @override
  String toString() {
    return 'Channel(id: $id, name: $name, encrypted: $encrypted, senderKey: $senderKey, messageCounter: $messageCounter, createdAt: $createdAt, rotatedAt: $rotatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChannelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.encrypted, encrypted) ||
                other.encrypted == encrypted) &&
            (identical(other.senderKey, senderKey) ||
                other.senderKey == senderKey) &&
            (identical(other.messageCounter, messageCounter) ||
                other.messageCounter == messageCounter) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.rotatedAt, rotatedAt) ||
                other.rotatedAt == rotatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, encrypted, senderKey,
      messageCounter, createdAt, rotatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ChannelImplCopyWith<_$ChannelImpl> get copyWith =>
      __$$ChannelImplCopyWithImpl<_$ChannelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChannelImplToJson(
      this,
    );
  }
}

abstract class _Channel implements Channel {
  const factory _Channel(
      {required final String id,
      required final String name,
      required final bool encrypted,
      final String? senderKey,
      final int messageCounter,
      required final DateTime createdAt,
      final DateTime? rotatedAt}) = _$ChannelImpl;

  factory _Channel.fromJson(Map<String, dynamic> json) = _$ChannelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  bool get encrypted;
  @override
  String? get senderKey;
  @override
  int get messageCounter;
  @override
  DateTime get createdAt;
  @override
  DateTime? get rotatedAt;
  @override
  @JsonKey(ignore: true)
  _$$ChannelImplCopyWith<_$ChannelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MeshPacketModel _$MeshPacketModelFromJson(Map<String, dynamic> json) {
  return _MeshPacketModel.fromJson(json);
}

/// @nodoc
mixin _$MeshPacketModel {
  int get version => throw _privateConstructorUsedError;
  int get type => throw _privateConstructorUsedError;
  int get ttl => throw _privateConstructorUsedError;
  int get hop => throw _privateConstructorUsedError;
  int get channelId64 => throw _privateConstructorUsedError;
  String get msgIdHex => throw _privateConstructorUsedError;
  String? get headerAdBase64 => throw _privateConstructorUsedError;
  String? get payloadBase64 => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MeshPacketModelCopyWith<MeshPacketModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MeshPacketModelCopyWith<$Res> {
  factory $MeshPacketModelCopyWith(
          MeshPacketModel value, $Res Function(MeshPacketModel) then) =
      _$MeshPacketModelCopyWithImpl<$Res, MeshPacketModel>;
  @useResult
  $Res call(
      {int version,
      int type,
      int ttl,
      int hop,
      int channelId64,
      String msgIdHex,
      String? headerAdBase64,
      String? payloadBase64});
}

/// @nodoc
class _$MeshPacketModelCopyWithImpl<$Res, $Val extends MeshPacketModel>
    implements $MeshPacketModelCopyWith<$Res> {
  _$MeshPacketModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? version = null,
    Object? type = null,
    Object? ttl = null,
    Object? hop = null,
    Object? channelId64 = null,
    Object? msgIdHex = null,
    Object? headerAdBase64 = freezed,
    Object? payloadBase64 = freezed,
  }) {
    return _then(_value.copyWith(
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as int,
      ttl: null == ttl
          ? _value.ttl
          : ttl // ignore: cast_nullable_to_non_nullable
              as int,
      hop: null == hop
          ? _value.hop
          : hop // ignore: cast_nullable_to_non_nullable
              as int,
      channelId64: null == channelId64
          ? _value.channelId64
          : channelId64 // ignore: cast_nullable_to_non_nullable
              as int,
      msgIdHex: null == msgIdHex
          ? _value.msgIdHex
          : msgIdHex // ignore: cast_nullable_to_non_nullable
              as String,
      headerAdBase64: freezed == headerAdBase64
          ? _value.headerAdBase64
          : headerAdBase64 // ignore: cast_nullable_to_non_nullable
              as String?,
      payloadBase64: freezed == payloadBase64
          ? _value.payloadBase64
          : payloadBase64 // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MeshPacketModelImplCopyWith<$Res>
    implements $MeshPacketModelCopyWith<$Res> {
  factory _$$MeshPacketModelImplCopyWith(_$MeshPacketModelImpl value,
          $Res Function(_$MeshPacketModelImpl) then) =
      __$$MeshPacketModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int version,
      int type,
      int ttl,
      int hop,
      int channelId64,
      String msgIdHex,
      String? headerAdBase64,
      String? payloadBase64});
}

/// @nodoc
class __$$MeshPacketModelImplCopyWithImpl<$Res>
    extends _$MeshPacketModelCopyWithImpl<$Res, _$MeshPacketModelImpl>
    implements _$$MeshPacketModelImplCopyWith<$Res> {
  __$$MeshPacketModelImplCopyWithImpl(
      _$MeshPacketModelImpl _value, $Res Function(_$MeshPacketModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? version = null,
    Object? type = null,
    Object? ttl = null,
    Object? hop = null,
    Object? channelId64 = null,
    Object? msgIdHex = null,
    Object? headerAdBase64 = freezed,
    Object? payloadBase64 = freezed,
  }) {
    return _then(_$MeshPacketModelImpl(
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as int,
      ttl: null == ttl
          ? _value.ttl
          : ttl // ignore: cast_nullable_to_non_nullable
              as int,
      hop: null == hop
          ? _value.hop
          : hop // ignore: cast_nullable_to_non_nullable
              as int,
      channelId64: null == channelId64
          ? _value.channelId64
          : channelId64 // ignore: cast_nullable_to_non_nullable
              as int,
      msgIdHex: null == msgIdHex
          ? _value.msgIdHex
          : msgIdHex // ignore: cast_nullable_to_non_nullable
              as String,
      headerAdBase64: freezed == headerAdBase64
          ? _value.headerAdBase64
          : headerAdBase64 // ignore: cast_nullable_to_non_nullable
              as String?,
      payloadBase64: freezed == payloadBase64
          ? _value.payloadBase64
          : payloadBase64 // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MeshPacketModelImpl implements _MeshPacketModel {
  const _$MeshPacketModelImpl(
      {required this.version,
      required this.type,
      required this.ttl,
      required this.hop,
      required this.channelId64,
      required this.msgIdHex,
      this.headerAdBase64,
      this.payloadBase64});

  factory _$MeshPacketModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MeshPacketModelImplFromJson(json);

  @override
  final int version;
  @override
  final int type;
  @override
  final int ttl;
  @override
  final int hop;
  @override
  final int channelId64;
  @override
  final String msgIdHex;
  @override
  final String? headerAdBase64;
  @override
  final String? payloadBase64;

  @override
  String toString() {
    return 'MeshPacketModel(version: $version, type: $type, ttl: $ttl, hop: $hop, channelId64: $channelId64, msgIdHex: $msgIdHex, headerAdBase64: $headerAdBase64, payloadBase64: $payloadBase64)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MeshPacketModelImpl &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.ttl, ttl) || other.ttl == ttl) &&
            (identical(other.hop, hop) || other.hop == hop) &&
            (identical(other.channelId64, channelId64) ||
                other.channelId64 == channelId64) &&
            (identical(other.msgIdHex, msgIdHex) ||
                other.msgIdHex == msgIdHex) &&
            (identical(other.headerAdBase64, headerAdBase64) ||
                other.headerAdBase64 == headerAdBase64) &&
            (identical(other.payloadBase64, payloadBase64) ||
                other.payloadBase64 == payloadBase64));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, version, type, ttl, hop,
      channelId64, msgIdHex, headerAdBase64, payloadBase64);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MeshPacketModelImplCopyWith<_$MeshPacketModelImpl> get copyWith =>
      __$$MeshPacketModelImplCopyWithImpl<_$MeshPacketModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MeshPacketModelImplToJson(
      this,
    );
  }
}

abstract class _MeshPacketModel implements MeshPacketModel {
  const factory _MeshPacketModel(
      {required final int version,
      required final int type,
      required final int ttl,
      required final int hop,
      required final int channelId64,
      required final String msgIdHex,
      final String? headerAdBase64,
      final String? payloadBase64}) = _$MeshPacketModelImpl;

  factory _MeshPacketModel.fromJson(Map<String, dynamic> json) =
      _$MeshPacketModelImpl.fromJson;

  @override
  int get version;
  @override
  int get type;
  @override
  int get ttl;
  @override
  int get hop;
  @override
  int get channelId64;
  @override
  String get msgIdHex;
  @override
  String? get headerAdBase64;
  @override
  String? get payloadBase64;
  @override
  @JsonKey(ignore: true)
  _$$MeshPacketModelImplCopyWith<_$MeshPacketModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Message _$MessageFromJson(Map<String, dynamic> json) {
  return _Message.fromJson(json);
}

/// @nodoc
mixin _$Message {
  String get id => throw _privateConstructorUsedError;
  String get channelId => throw _privateConstructorUsedError;
  String get senderId => throw _privateConstructorUsedError;
  DateTime get ts => throw _privateConstructorUsedError;
  String? get ciphertextBase64 => throw _privateConstructorUsedError;
  String? get plaintext => throw _privateConstructorUsedError;
  String? get hopInfo => throw _privateConstructorUsedError;
  String? get deliveredHint => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MessageCopyWith<Message> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageCopyWith<$Res> {
  factory $MessageCopyWith(Message value, $Res Function(Message) then) =
      _$MessageCopyWithImpl<$Res, Message>;
  @useResult
  $Res call(
      {String id,
      String channelId,
      String senderId,
      DateTime ts,
      String? ciphertextBase64,
      String? plaintext,
      String? hopInfo,
      String? deliveredHint});
}

/// @nodoc
class _$MessageCopyWithImpl<$Res, $Val extends Message>
    implements $MessageCopyWith<$Res> {
  _$MessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? channelId = null,
    Object? senderId = null,
    Object? ts = null,
    Object? ciphertextBase64 = freezed,
    Object? plaintext = freezed,
    Object? hopInfo = freezed,
    Object? deliveredHint = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      channelId: null == channelId
          ? _value.channelId
          : channelId // ignore: cast_nullable_to_non_nullable
              as String,
      senderId: null == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String,
      ts: null == ts
          ? _value.ts
          : ts // ignore: cast_nullable_to_non_nullable
              as DateTime,
      ciphertextBase64: freezed == ciphertextBase64
          ? _value.ciphertextBase64
          : ciphertextBase64 // ignore: cast_nullable_to_non_nullable
              as String?,
      plaintext: freezed == plaintext
          ? _value.plaintext
          : plaintext // ignore: cast_nullable_to_non_nullable
              as String?,
      hopInfo: freezed == hopInfo
          ? _value.hopInfo
          : hopInfo // ignore: cast_nullable_to_non_nullable
              as String?,
      deliveredHint: freezed == deliveredHint
          ? _value.deliveredHint
          : deliveredHint // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MessageImplCopyWith<$Res> implements $MessageCopyWith<$Res> {
  factory _$$MessageImplCopyWith(
          _$MessageImpl value, $Res Function(_$MessageImpl) then) =
      __$$MessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String channelId,
      String senderId,
      DateTime ts,
      String? ciphertextBase64,
      String? plaintext,
      String? hopInfo,
      String? deliveredHint});
}

/// @nodoc
class __$$MessageImplCopyWithImpl<$Res>
    extends _$MessageCopyWithImpl<$Res, _$MessageImpl>
    implements _$$MessageImplCopyWith<$Res> {
  __$$MessageImplCopyWithImpl(
      _$MessageImpl _value, $Res Function(_$MessageImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? channelId = null,
    Object? senderId = null,
    Object? ts = null,
    Object? ciphertextBase64 = freezed,
    Object? plaintext = freezed,
    Object? hopInfo = freezed,
    Object? deliveredHint = freezed,
  }) {
    return _then(_$MessageImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      channelId: null == channelId
          ? _value.channelId
          : channelId // ignore: cast_nullable_to_non_nullable
              as String,
      senderId: null == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String,
      ts: null == ts
          ? _value.ts
          : ts // ignore: cast_nullable_to_non_nullable
              as DateTime,
      ciphertextBase64: freezed == ciphertextBase64
          ? _value.ciphertextBase64
          : ciphertextBase64 // ignore: cast_nullable_to_non_nullable
              as String?,
      plaintext: freezed == plaintext
          ? _value.plaintext
          : plaintext // ignore: cast_nullable_to_non_nullable
              as String?,
      hopInfo: freezed == hopInfo
          ? _value.hopInfo
          : hopInfo // ignore: cast_nullable_to_non_nullable
              as String?,
      deliveredHint: freezed == deliveredHint
          ? _value.deliveredHint
          : deliveredHint // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MessageImpl implements _Message {
  const _$MessageImpl(
      {required this.id,
      required this.channelId,
      required this.senderId,
      required this.ts,
      this.ciphertextBase64,
      this.plaintext,
      this.hopInfo,
      this.deliveredHint});

  factory _$MessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$MessageImplFromJson(json);

  @override
  final String id;
  @override
  final String channelId;
  @override
  final String senderId;
  @override
  final DateTime ts;
  @override
  final String? ciphertextBase64;
  @override
  final String? plaintext;
  @override
  final String? hopInfo;
  @override
  final String? deliveredHint;

  @override
  String toString() {
    return 'Message(id: $id, channelId: $channelId, senderId: $senderId, ts: $ts, ciphertextBase64: $ciphertextBase64, plaintext: $plaintext, hopInfo: $hopInfo, deliveredHint: $deliveredHint)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.channelId, channelId) ||
                other.channelId == channelId) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.ts, ts) || other.ts == ts) &&
            (identical(other.ciphertextBase64, ciphertextBase64) ||
                other.ciphertextBase64 == ciphertextBase64) &&
            (identical(other.plaintext, plaintext) ||
                other.plaintext == plaintext) &&
            (identical(other.hopInfo, hopInfo) || other.hopInfo == hopInfo) &&
            (identical(other.deliveredHint, deliveredHint) ||
                other.deliveredHint == deliveredHint));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, channelId, senderId, ts,
      ciphertextBase64, plaintext, hopInfo, deliveredHint);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageImplCopyWith<_$MessageImpl> get copyWith =>
      __$$MessageImplCopyWithImpl<_$MessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MessageImplToJson(
      this,
    );
  }
}

abstract class _Message implements Message {
  const factory _Message(
      {required final String id,
      required final String channelId,
      required final String senderId,
      required final DateTime ts,
      final String? ciphertextBase64,
      final String? plaintext,
      final String? hopInfo,
      final String? deliveredHint}) = _$MessageImpl;

  factory _Message.fromJson(Map<String, dynamic> json) = _$MessageImpl.fromJson;

  @override
  String get id;
  @override
  String get channelId;
  @override
  String get senderId;
  @override
  DateTime get ts;
  @override
  String? get ciphertextBase64;
  @override
  String? get plaintext;
  @override
  String? get hopInfo;
  @override
  String? get deliveredHint;
  @override
  @JsonKey(ignore: true)
  _$$MessageImplCopyWith<_$MessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Peer _$PeerFromJson(Map<String, dynamic> json) {
  return _Peer.fromJson(json);
}

/// @nodoc
mixin _$Peer {
  String get shortId => throw _privateConstructorUsedError;
  int? get rssi => throw _privateConstructorUsedError;
  DateTime? get lastSeen => throw _privateConstructorUsedError;
  String? get services => throw _privateConstructorUsedError;
  int? get approxHops => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PeerCopyWith<Peer> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PeerCopyWith<$Res> {
  factory $PeerCopyWith(Peer value, $Res Function(Peer) then) =
      _$PeerCopyWithImpl<$Res, Peer>;
  @useResult
  $Res call(
      {String shortId,
      int? rssi,
      DateTime? lastSeen,
      String? services,
      int? approxHops});
}

/// @nodoc
class _$PeerCopyWithImpl<$Res, $Val extends Peer>
    implements $PeerCopyWith<$Res> {
  _$PeerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? shortId = null,
    Object? rssi = freezed,
    Object? lastSeen = freezed,
    Object? services = freezed,
    Object? approxHops = freezed,
  }) {
    return _then(_value.copyWith(
      shortId: null == shortId
          ? _value.shortId
          : shortId // ignore: cast_nullable_to_non_nullable
              as String,
      rssi: freezed == rssi
          ? _value.rssi
          : rssi // ignore: cast_nullable_to_non_nullable
              as int?,
      lastSeen: freezed == lastSeen
          ? _value.lastSeen
          : lastSeen // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      services: freezed == services
          ? _value.services
          : services // ignore: cast_nullable_to_non_nullable
              as String?,
      approxHops: freezed == approxHops
          ? _value.approxHops
          : approxHops // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PeerImplCopyWith<$Res> implements $PeerCopyWith<$Res> {
  factory _$$PeerImplCopyWith(
          _$PeerImpl value, $Res Function(_$PeerImpl) then) =
      __$$PeerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String shortId,
      int? rssi,
      DateTime? lastSeen,
      String? services,
      int? approxHops});
}

/// @nodoc
class __$$PeerImplCopyWithImpl<$Res>
    extends _$PeerCopyWithImpl<$Res, _$PeerImpl>
    implements _$$PeerImplCopyWith<$Res> {
  __$$PeerImplCopyWithImpl(_$PeerImpl _value, $Res Function(_$PeerImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? shortId = null,
    Object? rssi = freezed,
    Object? lastSeen = freezed,
    Object? services = freezed,
    Object? approxHops = freezed,
  }) {
    return _then(_$PeerImpl(
      shortId: null == shortId
          ? _value.shortId
          : shortId // ignore: cast_nullable_to_non_nullable
              as String,
      rssi: freezed == rssi
          ? _value.rssi
          : rssi // ignore: cast_nullable_to_non_nullable
              as int?,
      lastSeen: freezed == lastSeen
          ? _value.lastSeen
          : lastSeen // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      services: freezed == services
          ? _value.services
          : services // ignore: cast_nullable_to_non_nullable
              as String?,
      approxHops: freezed == approxHops
          ? _value.approxHops
          : approxHops // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PeerImpl implements _Peer {
  const _$PeerImpl(
      {required this.shortId,
      this.rssi,
      this.lastSeen,
      this.services,
      this.approxHops});

  factory _$PeerImpl.fromJson(Map<String, dynamic> json) =>
      _$$PeerImplFromJson(json);

  @override
  final String shortId;
  @override
  final int? rssi;
  @override
  final DateTime? lastSeen;
  @override
  final String? services;
  @override
  final int? approxHops;

  @override
  String toString() {
    return 'Peer(shortId: $shortId, rssi: $rssi, lastSeen: $lastSeen, services: $services, approxHops: $approxHops)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PeerImpl &&
            (identical(other.shortId, shortId) || other.shortId == shortId) &&
            (identical(other.rssi, rssi) || other.rssi == rssi) &&
            (identical(other.lastSeen, lastSeen) ||
                other.lastSeen == lastSeen) &&
            (identical(other.services, services) ||
                other.services == services) &&
            (identical(other.approxHops, approxHops) ||
                other.approxHops == approxHops));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, shortId, rssi, lastSeen, services, approxHops);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PeerImplCopyWith<_$PeerImpl> get copyWith =>
      __$$PeerImplCopyWithImpl<_$PeerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PeerImplToJson(
      this,
    );
  }
}

abstract class _Peer implements Peer {
  const factory _Peer(
      {required final String shortId,
      final int? rssi,
      final DateTime? lastSeen,
      final String? services,
      final int? approxHops}) = _$PeerImpl;

  factory _Peer.fromJson(Map<String, dynamic> json) = _$PeerImpl.fromJson;

  @override
  String get shortId;
  @override
  int? get rssi;
  @override
  DateTime? get lastSeen;
  @override
  String? get services;
  @override
  int? get approxHops;
  @override
  @JsonKey(ignore: true)
  _$$PeerImplCopyWith<_$PeerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
