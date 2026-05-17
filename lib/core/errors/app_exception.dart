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
        return 'Cihaz oturumu sunucu ile eşleşmiyor. Çıkış yapıp davet '
            'kodunuzu tekrar girin.';
      }
      if (code == 'residents_only_create') {
        return 'Yalnızca sakinler arıza bildirebilir.';
      }
      if (code == 'no_session_token') {
        return 'Oturum bilgisi bulunamadı. Davet kodunu tekrar girin.';
      }
      if (code == 'not_building_admin') {
        return 'Bu işlem yalnızca apartman yöneticisi içindir.';
      }
      if (code == 'not_super_admin') {
        return 'Bu işlem yalnızca sistem yöneticisi oturumu ile yapılabilir.';
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
        case 'custom_naming_not_supported':
          return 'Özel adlandırma sunucuda henüz etkin değil. '
              'Yönetici: `supabase functions deploy finalize_building_setup` '
              'çalıştırın veya kurulumda Otomatik adlandırma seçin.';
        case 'custom_units_invalid':
        case 'custom_units_count_mismatch':
          return 'Daire listesi yapı ile uyuşmuyor. Daireler adımına dönüp '
              'isimleri kontrol edin.';
        case 'custom_units_duplicate':
          return 'Aynı blokta aynı daire adı iki kez kullanılamaz.';
        case 'invalid_units':
          return 'Daire listesi geçersiz. Daireler adımını kontrol edin.';
        case 'building_required':
          return 'Bina bilgileri eksik. Kurulumu baştan tamamlayın.';
        case 'building_already_created_inconsistent':
          return 'Bu cihaz için kayıt yarım kalmış. Destek ile iletişime '
              'geçin veya yeni davet kodu isteyin.';
        case 'building_not_ready':
          return 'Önce apartman kurulumunu tamamlayın.';
        case 'manager_invite_not_deployed':
          return 'Sunucuda davet fonksiyonu bulunamadı. '
              'Terminalde `supabase functions deploy manager_invite` '
              'çalıştırın.';
        case 'issue_ops_not_deployed':
          return 'Arıza servisi bulunamadı. Terminalde '
              '`supabase functions deploy issue_ops` çalıştırın.';
        case 'election_ops_not_deployed':
          return 'Seçim servisi bulunamadı. Terminalde '
              '`supabase functions deploy election_ops` çalıştırın.';
        case 'election_title_required':
          return 'Seçim başlığı en az 3 karakter olmalıdır.';
        case 'election_not_found':
          return 'Seçim bulunamadı.';
        case 'election_active_exists':
          return 'Zaten devam eden bir seçim var. Önce onu kapatın.';
        case 'election_not_draft':
          return 'Bu seçim taslak durumunda değil.';
        case 'election_not_active':
          return 'Seçim şu an aktif değil.';
        case 'election_not_nominating':
          return 'Seçim adaylık aşamasında değil.';
        case 'election_nomination_closed':
          return 'Adaylık süresi sona erdi.';
        case 'already_voted':
          return 'Bu seçim için zaten oy kullandınız.';
        case 'already_candidate':
          return 'Zaten aday olarak kayıtlısınız.';
        case 'unit_required':
          return 'Oy kullanmak için daire kaydınız olmalı.';
        case 'profile_required':
          return 'Profil veya daire bilgisi eksik. Profilden «Dairemi kur» ile dairenizi seçin.';
        case 'manager_unit_required':
          return 'Kurulumda yönetici dairesi seçilmeli.';
        case 'manager_unit_invalid':
          return 'Seçilen yönetici dairesi listede bulunamadı.';
        case 'unit_id_required':
          return 'Lütfen bir daire seçin.';
        case 'full_name_too_short':
          return 'Ad soyad en az 2 karakter olmalı.';
        case 'full_name_too_long':
          return 'Ad soyad en fazla 80 karakter olabilir.';
        case 'profile_ops_not_deployed':
          return 'Profil servisi henüz yayında değil. Lütfen daha sonra deneyin.';
        case 'vote_payload_invalid':
          return 'Oy bilgisi geçersiz.';
        case 'candidate_not_found':
          return 'Aday bulunamadı.';
        case 'election_closed':
          return 'Seçim süresi dolmuş.';
        case 'issue_title_required':
          return 'Başlık en az 3 karakter olmalıdır.';
        case 'issue_not_found':
          return 'Arıza kaydı bulunamadı.';
        case 'issue_status_invalid':
          return 'Geçersiz durum seçildi.';
        case 'residents_only_create':
          return 'Yalnızca sakinler arıza bildirebilir.';
        case 'not_building_member':
          return 'Bu apartman için yetkiniz yok.';
        case 'no_units_for_building':
          return 'Bu bina için kayıtlı daire bulunamadı.';
        case 'invalid_unit':
          return 'Seçilen daire geçersiz.';
        case 'demo_mode':
          return 'Bu işlem demo modda kullanılamaz.';
        case 'device_or_token_required':
          return 'Oturum bilgisi eksik. Uygulamayı yeniden başlatıp tekrar '
              'deneyin.';
        case 'unknown_action':
          return 'Sunucu bu işlemi tanımıyor. Supabase’te '
              '`superadmin_ops` Edge fonksiyonunun güncel sürümünü '
              'deploy ettiğinizden emin olun '
              '(ör. silme için delete_building desteği).';
        case 'invalid_json':
          return 'İstek geçersiz. Uygulamayı güncelleyin.';
        case 'method_not_allowed':
          return 'Sunucu bu işlemi kabul etmedi.';
        case 'code_generation_failed':
          return 'Kod üretilemedi. Biraz sonra tekrar deneyin.';
        case 'server_misconfigured':
          return 'Sunucu yapılandırması eksik. Yönetici ile iletişime '
              'geçin.';
        case 'database_error':
          return 'Veritabanı hatası. Biraz sonra tekrar deneyin.';
        case 'delete_failed':
          return 'Apartman silinemedi. Bağlı kayıtlar veya veritabanı '
              'kısıtı olabilir; biraz sonra tekrar deneyin.';
        case 'building_id_required':
          return 'Bina bilgisi eksik. Sayfayı yenileyip tekrar deneyin.';
        case 'code_not_found_or_expired':
          return 'Kod bulunamadı veya süresi dolmuş.';
        case 'code_not_found_or_revoked':
          return 'Kod bulunamadı veya zaten iptal edilmiş.';
        case 'unit_invite_not_found':
          return 'Aktif davet kodu bulunamadı.';
        case 'code_already_used':
          return 'Bu kod daha önce kullanılmış.';
        case 'device_id_conflict':
          return 'Bu cihazda eski bir oturum kaydı var. Uygulamayı kapatıp '
              'tekrar deneyin veya verileri temizleyin.';
        case 'full_name_required':
          return 'Ad soyad en az 3 karakter olmalıdır.';
        case 'resident_registration_not_found':
          return 'Bu kodla kayıt bulunamadı. Apartman yöneticinize başvurun.';
        case 'code_required':
        case 'code_invalid_length':
          return 'Davet kodunu kontrol edin.';
        case 'device_id_required':
          return 'Cihaz kimliği alınamadı. Uygulamayı yeniden başlatın.';
        case 'invite_data_invalid':
        case 'unknown_code_type':
          return 'Bu davet kodu geçersiz veya sunucu kaydı eksik.';
        case 'unknown_backend_response':
          return 'Sunucu yanıtı okunamadı veya Edge fonksiyonu eksik. '
              'Supabase’te `manager_invite` ve `redeem_code` '
              'fonksiyonlarını deploy edin; şema için schema_v2.sql '
              'uygulandığından emin olun.';
        default:
          return 'Lütfen bilgileri kontrol edin ve tekrar deneyin.';
      }
    },
    server: (code, messageKey) =>
        'Sunucu hatası oluştu. Lütfen daha sonra tekrar deneyin.',
    unknown: () => 'Beklenmeyen bir hata oluştu.',
  );
}
