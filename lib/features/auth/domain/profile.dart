// JsonKey on factory parameters targets generated fields (factory ctor lint).
// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

@freezed
abstract class Profile with _$Profile {
  const factory Profile({
    required String id,
    @JsonKey(name: 'full_name') required String fullName,
    required String language,
    String? phone,
    String? email,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'notification_token') String? notificationToken,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
}
