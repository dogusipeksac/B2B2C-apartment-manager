import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In tr, this message translates to:
  /// **'Apartman Yöneticisi'**
  String get appTitle;

  /// No description provided for @emailEntryTitle.
  ///
  /// In tr, this message translates to:
  /// **'Giriş'**
  String get emailEntryTitle;

  /// No description provided for @emailHint.
  ///
  /// In tr, this message translates to:
  /// **'E-posta adresi'**
  String get emailHint;

  /// No description provided for @continueButton.
  ///
  /// In tr, this message translates to:
  /// **'Devam et'**
  String get continueButton;

  /// No description provided for @otpTitle.
  ///
  /// In tr, this message translates to:
  /// **'Doğrulama Kodu'**
  String get otpTitle;

  /// No description provided for @otpSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'{identifier} adresine gönderilen 6 haneli kodu girin.'**
  String otpSubtitle(Object identifier);

  /// No description provided for @resendIn.
  ///
  /// In tr, this message translates to:
  /// **'{seconds} sn sonra yeniden gönder'**
  String resendIn(Object seconds);

  /// No description provided for @resendOtp.
  ///
  /// In tr, this message translates to:
  /// **'Yeniden gönder'**
  String get resendOtp;

  /// No description provided for @verifyButton.
  ///
  /// In tr, this message translates to:
  /// **'Doğrula'**
  String get verifyButton;

  /// No description provided for @profileSetupTitle.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get profileSetupTitle;

  /// No description provided for @fullNameHint.
  ///
  /// In tr, this message translates to:
  /// **'Ad Soyad'**
  String get fullNameHint;

  /// No description provided for @saveButton.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get saveButton;

  /// No description provided for @welcomeMessage.
  ///
  /// In tr, this message translates to:
  /// **'Hoş geldin {fullName}'**
  String welcomeMessage(Object fullName);

  /// No description provided for @signOut.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış yap'**
  String get signOut;

  /// No description provided for @errorGeneric.
  ///
  /// In tr, this message translates to:
  /// **'Bir hata oluştu. Lütfen tekrar deneyin.'**
  String get errorGeneric;

  /// No description provided for @errorNetwork.
  ///
  /// In tr, this message translates to:
  /// **'İnternet bağlantınızı kontrol edin ve tekrar deneyin.'**
  String get errorNetwork;

  /// No description provided for @errorInvalidOtp.
  ///
  /// In tr, this message translates to:
  /// **'Kod geçersiz. Lütfen tekrar deneyin.'**
  String get errorInvalidOtp;

  /// No description provided for @errorRateLimit.
  ///
  /// In tr, this message translates to:
  /// **'Çok fazla deneme yaptınız, lütfen biraz bekleyip tekrar deneyin.'**
  String get errorRateLimit;

  /// No description provided for @errorOtpExpired.
  ///
  /// In tr, this message translates to:
  /// **'Doğrulama kodunun süresi doldu, yeniden gönderin.'**
  String get errorOtpExpired;

  /// No description provided for @errorEmailInvalid.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir e-posta adresi girin.'**
  String get errorEmailInvalid;

  /// No description provided for @otpSentToEmail.
  ///
  /// In tr, this message translates to:
  /// **'{email} adresine doğrulama kodu gönderildi.'**
  String otpSentToEmail(Object email);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
