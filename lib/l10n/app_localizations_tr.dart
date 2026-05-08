// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Apartman Yöneticisi';

  @override
  String get emailEntryTitle => 'Giriş';

  @override
  String get emailHint => 'E-posta adresi';

  @override
  String get continueButton => 'Devam et';

  @override
  String get otpTitle => 'Doğrulama Kodu';

  @override
  String otpSubtitle(Object identifier) {
    return '$identifier adresine gönderilen 6 haneli kodu girin.';
  }

  @override
  String resendIn(Object seconds) {
    return '$seconds sn sonra yeniden gönder';
  }

  @override
  String get resendOtp => 'Yeniden gönder';

  @override
  String get verifyButton => 'Doğrula';

  @override
  String get profileSetupTitle => 'Profil';

  @override
  String get fullNameHint => 'Ad Soyad';

  @override
  String get saveButton => 'Kaydet';

  @override
  String welcomeMessage(Object fullName) {
    return 'Hoş geldin $fullName';
  }

  @override
  String get signOut => 'Çıkış yap';

  @override
  String get errorGeneric => 'Bir hata oluştu. Lütfen tekrar deneyin.';

  @override
  String get errorNetwork =>
      'İnternet bağlantınızı kontrol edin ve tekrar deneyin.';

  @override
  String get errorInvalidOtp => 'Kod geçersiz. Lütfen tekrar deneyin.';

  @override
  String get errorRateLimit =>
      'Çok fazla deneme yaptınız, lütfen biraz bekleyip tekrar deneyin.';

  @override
  String get errorOtpExpired =>
      'Doğrulama kodunun süresi doldu, yeniden gönderin.';

  @override
  String get errorEmailInvalid => 'Geçerli bir e-posta adresi girin.';

  @override
  String otpSentToEmail(Object email) {
    return '$email adresine doğrulama kodu gönderildi.';
  }
}
