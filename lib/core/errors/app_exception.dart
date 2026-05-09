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
        auth: (code, messageKey) {
          if (code == 'invalid_session') {
            return 'Cihaz oturumu sunucu ile eşleşmiyor. Davet kodu ekranına '
                'dönüp kodu yeniden girin.';
          }
          if (code == 'no_session_token') {
            return 'Oturum bilgisi bulunamadı. Davet kodunu tekrar girin.';
          }
          return 'Oturumunuzla ilgili bir sorun oluştu. Lütfen tekrar giriş '
              'yapın.';
        },
        validation: (code, messageKey) {
          switch (code) {
            case 'device_not_found':
              return 'Bu cihaz sunucuda bulunamadı. Davet kodunu tekrar girin.';
            case 'building_fields_invalid':
              return 'Bina adı ve il / ilçe bilgilerini kontrol edin.';
            case 'building_numeric_invalid':
              return 'Kat, daire sayısı ve aidat ayarlarını kontrol edin.';
            case 'building_already_created_inconsistent':
              return 'Bu cihaz için kayıt yarım kalmış. Destek ile iletişime '
                  'geçin veya yeni davet kodu isteyin.';
            case 'demo_mode':
              return 'Bu işlem demo modda kullanılamaz.';
            default:
              return 'Lütfen bilgileri kontrol edin ve tekrar deneyin.';
          }
        },
        server: (code, messageKey) =>
            'Sunucu hatası oluştu. Lütfen daha sonra tekrar deneyin.',
        unknown: () => 'Beklenmeyen bir hata oluştu.',
      );
}
