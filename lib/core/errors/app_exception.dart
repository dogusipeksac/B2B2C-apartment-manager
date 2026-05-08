import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_exception.freezed.dart';

@freezed
sealed class AppException with _$AppException implements Exception {
  const AppException._();

  const factory AppException.network() = _Network;
  const factory AppException.auth({
    String? code,
    String? messageKey,
  }) = _Auth;
  const factory AppException.validation({
    String? code,
    String? messageKey,
  }) = _Validation;
  const factory AppException.server({
    String? code,
    String? messageKey,
  }) = _Server;
  const factory AppException.unknown() = _Unknown;

  String get userMessage => when(
        network: () => 'İnternet bağlantınızı kontrol edip tekrar deneyin.',
        auth: (code, messageKey) =>
            'Oturumunuzla ilgili bir sorun oluştu. Lütfen tekrar giriş yapın.',
        validation: (code, messageKey) =>
            'Lütfen bilgileri kontrol edin ve tekrar deneyin.',
        server: (code, messageKey) =>
            'Sunucu hatası oluştu. Lütfen daha sonra tekrar deneyin.',
        unknown: () => 'Beklenmeyen bir hata oluştu.',
      );
}
