// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'local_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LocalSession {

 String get deviceId;@UserRoleConverter() UserRole get role; DateTime get savedAt; String? get buildingId; String? get unitId; String? get profileId; String? get fullName; String? get sessionToken;/// Cached from finalize or invite APIs for dashboard titles.
 String? get buildingName;
/// Create a copy of LocalSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocalSessionCopyWith<LocalSession> get copyWith => _$LocalSessionCopyWithImpl<LocalSession>(this as LocalSession, _$identity);

  /// Serializes this LocalSession to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocalSession&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.role, role) || other.role == role)&&(identical(other.savedAt, savedAt) || other.savedAt == savedAt)&&(identical(other.buildingId, buildingId) || other.buildingId == buildingId)&&(identical(other.unitId, unitId) || other.unitId == unitId)&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.sessionToken, sessionToken) || other.sessionToken == sessionToken)&&(identical(other.buildingName, buildingName) || other.buildingName == buildingName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,deviceId,role,savedAt,buildingId,unitId,profileId,fullName,sessionToken,buildingName);

@override
String toString() {
  return 'LocalSession(deviceId: $deviceId, role: $role, savedAt: $savedAt, buildingId: $buildingId, unitId: $unitId, profileId: $profileId, fullName: $fullName, sessionToken: $sessionToken, buildingName: $buildingName)';
}


}

/// @nodoc
abstract mixin class $LocalSessionCopyWith<$Res>  {
  factory $LocalSessionCopyWith(LocalSession value, $Res Function(LocalSession) _then) = _$LocalSessionCopyWithImpl;
@useResult
$Res call({
 String deviceId,@UserRoleConverter() UserRole role, DateTime savedAt, String? buildingId, String? unitId, String? profileId, String? fullName, String? sessionToken, String? buildingName
});




}
/// @nodoc
class _$LocalSessionCopyWithImpl<$Res>
    implements $LocalSessionCopyWith<$Res> {
  _$LocalSessionCopyWithImpl(this._self, this._then);

  final LocalSession _self;
  final $Res Function(LocalSession) _then;

/// Create a copy of LocalSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? deviceId = null,Object? role = null,Object? savedAt = null,Object? buildingId = freezed,Object? unitId = freezed,Object? profileId = freezed,Object? fullName = freezed,Object? sessionToken = freezed,Object? buildingName = freezed,}) {
  return _then(_self.copyWith(
deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,savedAt: null == savedAt ? _self.savedAt : savedAt // ignore: cast_nullable_to_non_nullable
as DateTime,buildingId: freezed == buildingId ? _self.buildingId : buildingId // ignore: cast_nullable_to_non_nullable
as String?,unitId: freezed == unitId ? _self.unitId : unitId // ignore: cast_nullable_to_non_nullable
as String?,profileId: freezed == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String?,fullName: freezed == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String?,sessionToken: freezed == sessionToken ? _self.sessionToken : sessionToken // ignore: cast_nullable_to_non_nullable
as String?,buildingName: freezed == buildingName ? _self.buildingName : buildingName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LocalSession].
extension LocalSessionPatterns on LocalSession {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LocalSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LocalSession() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LocalSession value)  $default,){
final _that = this;
switch (_that) {
case _LocalSession():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LocalSession value)?  $default,){
final _that = this;
switch (_that) {
case _LocalSession() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String deviceId, @UserRoleConverter()  UserRole role,  DateTime savedAt,  String? buildingId,  String? unitId,  String? profileId,  String? fullName,  String? sessionToken,  String? buildingName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LocalSession() when $default != null:
return $default(_that.deviceId,_that.role,_that.savedAt,_that.buildingId,_that.unitId,_that.profileId,_that.fullName,_that.sessionToken,_that.buildingName);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String deviceId, @UserRoleConverter()  UserRole role,  DateTime savedAt,  String? buildingId,  String? unitId,  String? profileId,  String? fullName,  String? sessionToken,  String? buildingName)  $default,) {final _that = this;
switch (_that) {
case _LocalSession():
return $default(_that.deviceId,_that.role,_that.savedAt,_that.buildingId,_that.unitId,_that.profileId,_that.fullName,_that.sessionToken,_that.buildingName);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String deviceId, @UserRoleConverter()  UserRole role,  DateTime savedAt,  String? buildingId,  String? unitId,  String? profileId,  String? fullName,  String? sessionToken,  String? buildingName)?  $default,) {final _that = this;
switch (_that) {
case _LocalSession() when $default != null:
return $default(_that.deviceId,_that.role,_that.savedAt,_that.buildingId,_that.unitId,_that.profileId,_that.fullName,_that.sessionToken,_that.buildingName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LocalSession implements LocalSession {
  const _LocalSession({required this.deviceId, @UserRoleConverter() required this.role, required this.savedAt, this.buildingId, this.unitId, this.profileId, this.fullName, this.sessionToken, this.buildingName});
  factory _LocalSession.fromJson(Map<String, dynamic> json) => _$LocalSessionFromJson(json);

@override final  String deviceId;
@override@UserRoleConverter() final  UserRole role;
@override final  DateTime savedAt;
@override final  String? buildingId;
@override final  String? unitId;
@override final  String? profileId;
@override final  String? fullName;
@override final  String? sessionToken;
/// Cached from finalize or invite APIs for dashboard titles.
@override final  String? buildingName;

/// Create a copy of LocalSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LocalSessionCopyWith<_LocalSession> get copyWith => __$LocalSessionCopyWithImpl<_LocalSession>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LocalSessionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LocalSession&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.role, role) || other.role == role)&&(identical(other.savedAt, savedAt) || other.savedAt == savedAt)&&(identical(other.buildingId, buildingId) || other.buildingId == buildingId)&&(identical(other.unitId, unitId) || other.unitId == unitId)&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.sessionToken, sessionToken) || other.sessionToken == sessionToken)&&(identical(other.buildingName, buildingName) || other.buildingName == buildingName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,deviceId,role,savedAt,buildingId,unitId,profileId,fullName,sessionToken,buildingName);

@override
String toString() {
  return 'LocalSession(deviceId: $deviceId, role: $role, savedAt: $savedAt, buildingId: $buildingId, unitId: $unitId, profileId: $profileId, fullName: $fullName, sessionToken: $sessionToken, buildingName: $buildingName)';
}


}

/// @nodoc
abstract mixin class _$LocalSessionCopyWith<$Res> implements $LocalSessionCopyWith<$Res> {
  factory _$LocalSessionCopyWith(_LocalSession value, $Res Function(_LocalSession) _then) = __$LocalSessionCopyWithImpl;
@override @useResult
$Res call({
 String deviceId,@UserRoleConverter() UserRole role, DateTime savedAt, String? buildingId, String? unitId, String? profileId, String? fullName, String? sessionToken, String? buildingName
});




}
/// @nodoc
class __$LocalSessionCopyWithImpl<$Res>
    implements _$LocalSessionCopyWith<$Res> {
  __$LocalSessionCopyWithImpl(this._self, this._then);

  final _LocalSession _self;
  final $Res Function(_LocalSession) _then;

/// Create a copy of LocalSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? deviceId = null,Object? role = null,Object? savedAt = null,Object? buildingId = freezed,Object? unitId = freezed,Object? profileId = freezed,Object? fullName = freezed,Object? sessionToken = freezed,Object? buildingName = freezed,}) {
  return _then(_LocalSession(
deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,savedAt: null == savedAt ? _self.savedAt : savedAt // ignore: cast_nullable_to_non_nullable
as DateTime,buildingId: freezed == buildingId ? _self.buildingId : buildingId // ignore: cast_nullable_to_non_nullable
as String?,unitId: freezed == unitId ? _self.unitId : unitId // ignore: cast_nullable_to_non_nullable
as String?,profileId: freezed == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String?,fullName: freezed == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String?,sessionToken: freezed == sessionToken ? _self.sessionToken : sessionToken // ignore: cast_nullable_to_non_nullable
as String?,buildingName: freezed == buildingName ? _self.buildingName : buildingName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
