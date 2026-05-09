// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'code_preview.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CodePreview {

 InviteCodeType get codeType; String? get buildingName; String? get unitLabel; String? get address;
/// Create a copy of CodePreview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CodePreviewCopyWith<CodePreview> get copyWith => _$CodePreviewCopyWithImpl<CodePreview>(this as CodePreview, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CodePreview&&(identical(other.codeType, codeType) || other.codeType == codeType)&&(identical(other.buildingName, buildingName) || other.buildingName == buildingName)&&(identical(other.unitLabel, unitLabel) || other.unitLabel == unitLabel)&&(identical(other.address, address) || other.address == address));
}


@override
int get hashCode => Object.hash(runtimeType,codeType,buildingName,unitLabel,address);

@override
String toString() {
  return 'CodePreview(codeType: $codeType, buildingName: $buildingName, unitLabel: $unitLabel, address: $address)';
}


}

/// @nodoc
abstract mixin class $CodePreviewCopyWith<$Res>  {
  factory $CodePreviewCopyWith(CodePreview value, $Res Function(CodePreview) _then) = _$CodePreviewCopyWithImpl;
@useResult
$Res call({
 InviteCodeType codeType, String? buildingName, String? unitLabel, String? address
});




}
/// @nodoc
class _$CodePreviewCopyWithImpl<$Res>
    implements $CodePreviewCopyWith<$Res> {
  _$CodePreviewCopyWithImpl(this._self, this._then);

  final CodePreview _self;
  final $Res Function(CodePreview) _then;

/// Create a copy of CodePreview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? codeType = null,Object? buildingName = freezed,Object? unitLabel = freezed,Object? address = freezed,}) {
  return _then(_self.copyWith(
codeType: null == codeType ? _self.codeType : codeType // ignore: cast_nullable_to_non_nullable
as InviteCodeType,buildingName: freezed == buildingName ? _self.buildingName : buildingName // ignore: cast_nullable_to_non_nullable
as String?,unitLabel: freezed == unitLabel ? _self.unitLabel : unitLabel // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CodePreview].
extension CodePreviewPatterns on CodePreview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CodePreview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CodePreview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CodePreview value)  $default,){
final _that = this;
switch (_that) {
case _CodePreview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CodePreview value)?  $default,){
final _that = this;
switch (_that) {
case _CodePreview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( InviteCodeType codeType,  String? buildingName,  String? unitLabel,  String? address)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CodePreview() when $default != null:
return $default(_that.codeType,_that.buildingName,_that.unitLabel,_that.address);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( InviteCodeType codeType,  String? buildingName,  String? unitLabel,  String? address)  $default,) {final _that = this;
switch (_that) {
case _CodePreview():
return $default(_that.codeType,_that.buildingName,_that.unitLabel,_that.address);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( InviteCodeType codeType,  String? buildingName,  String? unitLabel,  String? address)?  $default,) {final _that = this;
switch (_that) {
case _CodePreview() when $default != null:
return $default(_that.codeType,_that.buildingName,_that.unitLabel,_that.address);case _:
  return null;

}
}

}

/// @nodoc


class _CodePreview implements CodePreview {
  const _CodePreview({required this.codeType, this.buildingName, this.unitLabel, this.address});
  

@override final  InviteCodeType codeType;
@override final  String? buildingName;
@override final  String? unitLabel;
@override final  String? address;

/// Create a copy of CodePreview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CodePreviewCopyWith<_CodePreview> get copyWith => __$CodePreviewCopyWithImpl<_CodePreview>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CodePreview&&(identical(other.codeType, codeType) || other.codeType == codeType)&&(identical(other.buildingName, buildingName) || other.buildingName == buildingName)&&(identical(other.unitLabel, unitLabel) || other.unitLabel == unitLabel)&&(identical(other.address, address) || other.address == address));
}


@override
int get hashCode => Object.hash(runtimeType,codeType,buildingName,unitLabel,address);

@override
String toString() {
  return 'CodePreview(codeType: $codeType, buildingName: $buildingName, unitLabel: $unitLabel, address: $address)';
}


}

/// @nodoc
abstract mixin class _$CodePreviewCopyWith<$Res> implements $CodePreviewCopyWith<$Res> {
  factory _$CodePreviewCopyWith(_CodePreview value, $Res Function(_CodePreview) _then) = __$CodePreviewCopyWithImpl;
@override @useResult
$Res call({
 InviteCodeType codeType, String? buildingName, String? unitLabel, String? address
});




}
/// @nodoc
class __$CodePreviewCopyWithImpl<$Res>
    implements _$CodePreviewCopyWith<$Res> {
  __$CodePreviewCopyWithImpl(this._self, this._then);

  final _CodePreview _self;
  final $Res Function(_CodePreview) _then;

/// Create a copy of CodePreview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? codeType = null,Object? buildingName = freezed,Object? unitLabel = freezed,Object? address = freezed,}) {
  return _then(_CodePreview(
codeType: null == codeType ? _self.codeType : codeType // ignore: cast_nullable_to_non_nullable
as InviteCodeType,buildingName: freezed == buildingName ? _self.buildingName : buildingName // ignore: cast_nullable_to_non_nullable
as String?,unitLabel: freezed == unitLabel ? _self.unitLabel : unitLabel // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
