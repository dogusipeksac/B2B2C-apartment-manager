// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Profile _$ProfileFromJson(Map<String, dynamic> json) => _Profile(
  id: json['id'] as String,
  fullName: json['fullName'] as String,
  phone: json['phone'] as String?,
  email: json['email'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  language: json['language'] as String,
);

Map<String, dynamic> _$ProfileToJson(_Profile instance) => <String, dynamic>{
  'id': instance.id,
  'fullName': instance.fullName,
  'phone': instance.phone,
  'email': instance.email,
  'avatarUrl': instance.avatarUrl,
  'language': instance.language,
};
