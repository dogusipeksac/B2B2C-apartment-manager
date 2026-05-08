// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_exception.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppException {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppException);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AppException()';
}


}

/// @nodoc
class $AppExceptionCopyWith<$Res>  {
$AppExceptionCopyWith(AppException _, $Res Function(AppException) __);
}


/// Adds pattern-matching-related methods to [AppException].
extension AppExceptionPatterns on AppException {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Network value)?  network,TResult Function( _Auth value)?  auth,TResult Function( _Validation value)?  validation,TResult Function( _Server value)?  server,TResult Function( _Unknown value)?  unknown,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Network() when network != null:
return network(_that);case _Auth() when auth != null:
return auth(_that);case _Validation() when validation != null:
return validation(_that);case _Server() when server != null:
return server(_that);case _Unknown() when unknown != null:
return unknown(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Network value)  network,required TResult Function( _Auth value)  auth,required TResult Function( _Validation value)  validation,required TResult Function( _Server value)  server,required TResult Function( _Unknown value)  unknown,}){
final _that = this;
switch (_that) {
case _Network():
return network(_that);case _Auth():
return auth(_that);case _Validation():
return validation(_that);case _Server():
return server(_that);case _Unknown():
return unknown(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Network value)?  network,TResult? Function( _Auth value)?  auth,TResult? Function( _Validation value)?  validation,TResult? Function( _Server value)?  server,TResult? Function( _Unknown value)?  unknown,}){
final _that = this;
switch (_that) {
case _Network() when network != null:
return network(_that);case _Auth() when auth != null:
return auth(_that);case _Validation() when validation != null:
return validation(_that);case _Server() when server != null:
return server(_that);case _Unknown() when unknown != null:
return unknown(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  network,TResult Function( String? code,  String? messageKey)?  auth,TResult Function( String? code,  String? messageKey)?  validation,TResult Function( String? code,  String? messageKey)?  server,TResult Function()?  unknown,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Network() when network != null:
return network();case _Auth() when auth != null:
return auth(_that.code,_that.messageKey);case _Validation() when validation != null:
return validation(_that.code,_that.messageKey);case _Server() when server != null:
return server(_that.code,_that.messageKey);case _Unknown() when unknown != null:
return unknown();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  network,required TResult Function( String? code,  String? messageKey)  auth,required TResult Function( String? code,  String? messageKey)  validation,required TResult Function( String? code,  String? messageKey)  server,required TResult Function()  unknown,}) {final _that = this;
switch (_that) {
case _Network():
return network();case _Auth():
return auth(_that.code,_that.messageKey);case _Validation():
return validation(_that.code,_that.messageKey);case _Server():
return server(_that.code,_that.messageKey);case _Unknown():
return unknown();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  network,TResult? Function( String? code,  String? messageKey)?  auth,TResult? Function( String? code,  String? messageKey)?  validation,TResult? Function( String? code,  String? messageKey)?  server,TResult? Function()?  unknown,}) {final _that = this;
switch (_that) {
case _Network() when network != null:
return network();case _Auth() when auth != null:
return auth(_that.code,_that.messageKey);case _Validation() when validation != null:
return validation(_that.code,_that.messageKey);case _Server() when server != null:
return server(_that.code,_that.messageKey);case _Unknown() when unknown != null:
return unknown();case _:
  return null;

}
}

}

/// @nodoc


class _Network extends AppException {
  const _Network(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Network);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AppException.network()';
}


}




/// @nodoc


class _Auth extends AppException {
  const _Auth({this.code, this.messageKey}): super._();
  

 final  String? code;
 final  String? messageKey;

/// Create a copy of AppException
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthCopyWith<_Auth> get copyWith => __$AuthCopyWithImpl<_Auth>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Auth&&(identical(other.code, code) || other.code == code)&&(identical(other.messageKey, messageKey) || other.messageKey == messageKey));
}


@override
int get hashCode => Object.hash(runtimeType,code,messageKey);

@override
String toString() {
  return 'AppException.auth(code: $code, messageKey: $messageKey)';
}


}

/// @nodoc
abstract mixin class _$AuthCopyWith<$Res> implements $AppExceptionCopyWith<$Res> {
  factory _$AuthCopyWith(_Auth value, $Res Function(_Auth) _then) = __$AuthCopyWithImpl;
@useResult
$Res call({
 String? code, String? messageKey
});




}
/// @nodoc
class __$AuthCopyWithImpl<$Res>
    implements _$AuthCopyWith<$Res> {
  __$AuthCopyWithImpl(this._self, this._then);

  final _Auth _self;
  final $Res Function(_Auth) _then;

/// Create a copy of AppException
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? code = freezed,Object? messageKey = freezed,}) {
  return _then(_Auth(
code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,messageKey: freezed == messageKey ? _self.messageKey : messageKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _Validation extends AppException {
  const _Validation({this.code, this.messageKey}): super._();
  

 final  String? code;
 final  String? messageKey;

/// Create a copy of AppException
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ValidationCopyWith<_Validation> get copyWith => __$ValidationCopyWithImpl<_Validation>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Validation&&(identical(other.code, code) || other.code == code)&&(identical(other.messageKey, messageKey) || other.messageKey == messageKey));
}


@override
int get hashCode => Object.hash(runtimeType,code,messageKey);

@override
String toString() {
  return 'AppException.validation(code: $code, messageKey: $messageKey)';
}


}

/// @nodoc
abstract mixin class _$ValidationCopyWith<$Res> implements $AppExceptionCopyWith<$Res> {
  factory _$ValidationCopyWith(_Validation value, $Res Function(_Validation) _then) = __$ValidationCopyWithImpl;
@useResult
$Res call({
 String? code, String? messageKey
});




}
/// @nodoc
class __$ValidationCopyWithImpl<$Res>
    implements _$ValidationCopyWith<$Res> {
  __$ValidationCopyWithImpl(this._self, this._then);

  final _Validation _self;
  final $Res Function(_Validation) _then;

/// Create a copy of AppException
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? code = freezed,Object? messageKey = freezed,}) {
  return _then(_Validation(
code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,messageKey: freezed == messageKey ? _self.messageKey : messageKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _Server extends AppException {
  const _Server({this.code, this.messageKey}): super._();
  

 final  String? code;
 final  String? messageKey;

/// Create a copy of AppException
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ServerCopyWith<_Server> get copyWith => __$ServerCopyWithImpl<_Server>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Server&&(identical(other.code, code) || other.code == code)&&(identical(other.messageKey, messageKey) || other.messageKey == messageKey));
}


@override
int get hashCode => Object.hash(runtimeType,code,messageKey);

@override
String toString() {
  return 'AppException.server(code: $code, messageKey: $messageKey)';
}


}

/// @nodoc
abstract mixin class _$ServerCopyWith<$Res> implements $AppExceptionCopyWith<$Res> {
  factory _$ServerCopyWith(_Server value, $Res Function(_Server) _then) = __$ServerCopyWithImpl;
@useResult
$Res call({
 String? code, String? messageKey
});




}
/// @nodoc
class __$ServerCopyWithImpl<$Res>
    implements _$ServerCopyWith<$Res> {
  __$ServerCopyWithImpl(this._self, this._then);

  final _Server _self;
  final $Res Function(_Server) _then;

/// Create a copy of AppException
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? code = freezed,Object? messageKey = freezed,}) {
  return _then(_Server(
code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,messageKey: freezed == messageKey ? _self.messageKey : messageKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _Unknown extends AppException {
  const _Unknown(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Unknown);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AppException.unknown()';
}


}




// dart format on
