import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

@freezed
abstract class Profile with _$Profile {
  const factory Profile({
    required String id,
    // ignore: invalid_annotation_target -- JsonKey maps camelCase field to DB column.
    @JsonKey(name: 'full_name') required String fullName,
    required String language,
    String? phone,
    String? email,
    // ignore: invalid_annotation_target -- JsonKey maps camelCase field to DB column.
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    // ignore: invalid_annotation_target -- JsonKey maps camelCase field to DB column.
    @JsonKey(name: 'notification_token') String? notificationToken,
    // ignore: invalid_annotation_target -- JsonKey maps camelCase field to DB column.
    @JsonKey(name: 'created_at') DateTime? createdAt,
    // ignore: invalid_annotation_target -- JsonKey maps camelCase field to DB column.
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
}
