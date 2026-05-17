// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LocalSession _$LocalSessionFromJson(Map<String, dynamic> json) =>
    _LocalSession(
      deviceId: json['deviceId'] as String,
      role: const UserRoleConverter().fromJson(json['role'] as String),
      savedAt: DateTime.parse(json['savedAt'] as String),
      buildingId: json['buildingId'] as String?,
      unitId: json['unitId'] as String?,
      profileId: json['profileId'] as String?,
      fullName: json['fullName'] as String?,
      sessionToken: json['sessionToken'] as String?,
      buildingName: json['buildingName'] as String?,
      rememberMe: json['rememberMe'] as bool? ?? true,
    );

Map<String, dynamic> _$LocalSessionToJson(_LocalSession instance) =>
    <String, dynamic>{
      'deviceId': instance.deviceId,
      'role': const UserRoleConverter().toJson(instance.role),
      'savedAt': instance.savedAt.toIso8601String(),
      'buildingId': instance.buildingId,
      'unitId': instance.unitId,
      'profileId': instance.profileId,
      'fullName': instance.fullName,
      'sessionToken': instance.sessionToken,
      'buildingName': instance.buildingName,
      'rememberMe': instance.rememberMe,
    };
