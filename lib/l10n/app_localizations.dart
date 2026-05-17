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
  /// **'AptKeeper'**
  String get appTitle;

  /// No description provided for @splashTagline.
  ///
  /// In tr, this message translates to:
  /// **'Apartman ve site yönetimi'**
  String get splashTagline;

  /// No description provided for @emailEntryTitle.
  ///
  /// In tr, this message translates to:
  /// **'Giriş yap'**
  String get emailEntryTitle;

  /// No description provided for @emailLoginHeadline.
  ///
  /// In tr, this message translates to:
  /// **'E-posta adresin'**
  String get emailLoginHeadline;

  /// No description provided for @emailLoginSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Sana tek kullanımlık bir kod göndereceğiz.'**
  String get emailLoginSubtitle;

  /// No description provided for @emailFieldLabel.
  ///
  /// In tr, this message translates to:
  /// **'E-POSTA'**
  String get emailFieldLabel;

  /// No description provided for @kvkkEmailNotice.
  ///
  /// In tr, this message translates to:
  /// **'KVKK uyumluyuz. E-posta sadece giriş için kullanılır.'**
  String get kvkkEmailNotice;

  /// No description provided for @loginLegalPrefix.
  ///
  /// In tr, this message translates to:
  /// **'Devam ederek '**
  String get loginLegalPrefix;

  /// No description provided for @loginLegalTerms.
  ///
  /// In tr, this message translates to:
  /// **'Kullanım Şartları'**
  String get loginLegalTerms;

  /// No description provided for @loginLegalMiddle.
  ///
  /// In tr, this message translates to:
  /// **' ve '**
  String get loginLegalMiddle;

  /// No description provided for @loginLegalPrivacy.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik Politikası'**
  String get loginLegalPrivacy;

  /// No description provided for @loginLegalSuffix.
  ///
  /// In tr, this message translates to:
  /// **'\'nı kabul ediyorsun.'**
  String get loginLegalSuffix;

  /// No description provided for @legalLinkPlaceholder.
  ///
  /// In tr, this message translates to:
  /// **'Bu içerik yakında eklenecek.'**
  String get legalLinkPlaceholder;

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

  /// No description provided for @otpAppBarTitle.
  ///
  /// In tr, this message translates to:
  /// **'Doğrulama'**
  String get otpAppBarTitle;

  /// No description provided for @otpHeadline.
  ///
  /// In tr, this message translates to:
  /// **'Kodu gir'**
  String get otpHeadline;

  /// No description provided for @otpSentParagraph.
  ///
  /// In tr, this message translates to:
  /// **'{identifier} adresine 6 haneli kod gönderdik.'**
  String otpSentParagraph(Object identifier);

  /// No description provided for @otpResendPrompt.
  ///
  /// In tr, this message translates to:
  /// **'Kodu almadın mı?'**
  String get otpResendPrompt;

  /// No description provided for @otpResendLineCooldown.
  ///
  /// In tr, this message translates to:
  /// **'Kodu almadın mı? Yeniden gönder ({time})'**
  String otpResendLineCooldown(Object time);

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
  /// **'Profil oluştur'**
  String get profileSetupTitle;

  /// No description provided for @profileHeadline.
  ///
  /// In tr, this message translates to:
  /// **'Seni nasıl tanıtalım?'**
  String get profileHeadline;

  /// No description provided for @profileSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Komşuların ve yöneticin bu ismi görür.'**
  String get profileSubtitle;

  /// No description provided for @profileAvatarTitle.
  ///
  /// In tr, this message translates to:
  /// **'Avatar'**
  String get profileAvatarTitle;

  /// No description provided for @profileAvatarSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'İleride ekleyebilirsin'**
  String get profileAvatarSubtitle;

  /// No description provided for @fullNameFieldLabel.
  ///
  /// In tr, this message translates to:
  /// **'AD SOYAD'**
  String get fullNameFieldLabel;

  /// No description provided for @fullNameHint.
  ///
  /// In tr, this message translates to:
  /// **'Ad Soyad'**
  String get fullNameHint;

  /// No description provided for @phoneFieldLabel.
  ///
  /// In tr, this message translates to:
  /// **'TELEFON (OPSİYONEL)'**
  String get phoneFieldLabel;

  /// No description provided for @phoneHint.
  ///
  /// In tr, this message translates to:
  /// **'+90 5__ ___ __ __'**
  String get phoneHint;

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

  /// No description provided for @rememberMeLabel.
  ///
  /// In tr, this message translates to:
  /// **'Beni hatırla'**
  String get rememberMeLabel;

  /// No description provided for @rememberMeHint.
  ///
  /// In tr, this message translates to:
  /// **'Uygulamayı her açtığımda oturumum açık kalsın'**
  String get rememberMeHint;

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

  /// No description provided for @demoHubTitle.
  ///
  /// In tr, this message translates to:
  /// **'Demo — Ekran kataloğu'**
  String get demoHubTitle;

  /// No description provided for @demoHubSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'HTML mockup ve analiz raporuna göre tüm ekranlar. Veriler örnektir.'**
  String get demoHubSubtitle;

  /// No description provided for @demoBadge.
  ///
  /// In tr, this message translates to:
  /// **'DEMO'**
  String get demoBadge;

  /// No description provided for @demoBackToHub.
  ///
  /// In tr, this message translates to:
  /// **'Kataloga dön'**
  String get demoBackToHub;

  /// No description provided for @demoSectionAuth.
  ///
  /// In tr, this message translates to:
  /// **'1 · Giriş ve tanıtım'**
  String get demoSectionAuth;

  /// No description provided for @demoSectionHome.
  ///
  /// In tr, this message translates to:
  /// **'2 · Ana sayfalar'**
  String get demoSectionHome;

  /// No description provided for @demoSectionSetup.
  ///
  /// In tr, this message translates to:
  /// **'3 · Bina kurulumu'**
  String get demoSectionSetup;

  /// No description provided for @demoSectionResident.
  ///
  /// In tr, this message translates to:
  /// **'4 · Sakin (aidat, duyuru, profil)'**
  String get demoSectionResident;

  /// No description provided for @demoSectionIssues.
  ///
  /// In tr, this message translates to:
  /// **'5 · Arızalar'**
  String get demoSectionIssues;

  /// No description provided for @demoSectionAdmin.
  ///
  /// In tr, this message translates to:
  /// **'6 · Yönetici'**
  String get demoSectionAdmin;

  /// No description provided for @demoSectionReports.
  ///
  /// In tr, this message translates to:
  /// **'7 · Raporlar'**
  String get demoSectionReports;

  /// No description provided for @demoSectionDocs.
  ///
  /// In tr, this message translates to:
  /// **'8 · Belge ve oylama'**
  String get demoSectionDocs;

  /// No description provided for @demoSectionSubscription.
  ///
  /// In tr, this message translates to:
  /// **'9 · Abonelik ve ayarlar'**
  String get demoSectionSubscription;

  /// No description provided for @demoTileSplashPreview.
  ///
  /// In tr, this message translates to:
  /// **'1.1 Splash'**
  String get demoTileSplashPreview;

  /// No description provided for @demoTileWelcome.
  ///
  /// In tr, this message translates to:
  /// **'1.2 Tanıtım (onboarding)'**
  String get demoTileWelcome;

  /// No description provided for @demoTileLoginReal.
  ///
  /// In tr, this message translates to:
  /// **'1.3 Gerçek giriş ekranı'**
  String get demoTileLoginReal;

  /// No description provided for @demoTileOtpReal.
  ///
  /// In tr, this message translates to:
  /// **'1.4 OTP doğrulama'**
  String get demoTileOtpReal;

  /// No description provided for @demoTileProfileReal.
  ///
  /// In tr, this message translates to:
  /// **'1.5 Profil oluşturma'**
  String get demoTileProfileReal;

  /// No description provided for @demoTileResidentHome.
  ///
  /// In tr, this message translates to:
  /// **'2.1 Sakin ana sayfa'**
  String get demoTileResidentHome;

  /// No description provided for @demoTileAdminHome.
  ///
  /// In tr, this message translates to:
  /// **'2.2 Yönetici ana sayfa'**
  String get demoTileAdminHome;

  /// No description provided for @demoTileRoleSelect.
  ///
  /// In tr, this message translates to:
  /// **'3.1 Rol seçimi'**
  String get demoTileRoleSelect;

  /// No description provided for @demoTileInviteCode.
  ///
  /// In tr, this message translates to:
  /// **'3.2 Davet kodu'**
  String get demoTileInviteCode;

  /// No description provided for @demoTileSetupBuilding.
  ///
  /// In tr, this message translates to:
  /// **'3.3 Kurulum · Bina'**
  String get demoTileSetupBuilding;

  /// No description provided for @demoTileSetupStructure.
  ///
  /// In tr, this message translates to:
  /// **'3.4 Kurulum · Yapı'**
  String get demoTileSetupStructure;

  /// No description provided for @demoTileSetupUnits.
  ///
  /// In tr, this message translates to:
  /// **'3.5 Kurulum · Daireler'**
  String get demoTileSetupUnits;

  /// No description provided for @demoTileSetupDues.
  ///
  /// In tr, this message translates to:
  /// **'3.6 Kurulum · Aidat'**
  String get demoTileSetupDues;

  /// No description provided for @demoTileDuesHistory.
  ///
  /// In tr, this message translates to:
  /// **'4.1 Aidat geçmişi'**
  String get demoTileDuesHistory;

  /// No description provided for @demoTileDuesDetail.
  ///
  /// In tr, this message translates to:
  /// **'4.2 Aidat detay'**
  String get demoTileDuesDetail;

  /// No description provided for @demoTilePaymentCheckout.
  ///
  /// In tr, this message translates to:
  /// **'4.3 Ödeme (iyzico)'**
  String get demoTilePaymentCheckout;

  /// No description provided for @demoTilePaymentSuccess.
  ///
  /// In tr, this message translates to:
  /// **'4.4 Ödeme başarılı'**
  String get demoTilePaymentSuccess;

  /// No description provided for @demoTileAnnouncements.
  ///
  /// In tr, this message translates to:
  /// **'4.5 Duyuru akışı'**
  String get demoTileAnnouncements;

  /// No description provided for @demoTileAnnouncementDetail.
  ///
  /// In tr, this message translates to:
  /// **'4.6 Duyuru detay'**
  String get demoTileAnnouncementDetail;

  /// No description provided for @demoTileProfileResident.
  ///
  /// In tr, this message translates to:
  /// **'4.7 Profil'**
  String get demoTileProfileResident;

  /// No description provided for @demoTileIssuesList.
  ///
  /// In tr, this message translates to:
  /// **'5.1 Arıza listesi'**
  String get demoTileIssuesList;

  /// No description provided for @demoTileIssueNew.
  ///
  /// In tr, this message translates to:
  /// **'5.2 Yeni arıza'**
  String get demoTileIssueNew;

  /// No description provided for @demoTileIssueDetail.
  ///
  /// In tr, this message translates to:
  /// **'5.3 Arıza detay'**
  String get demoTileIssueDetail;

  /// No description provided for @demoTileIssuesKanban.
  ///
  /// In tr, this message translates to:
  /// **'5.4 Yönetici kanban'**
  String get demoTileIssuesKanban;

  /// No description provided for @demoTileUnitsGrid.
  ///
  /// In tr, this message translates to:
  /// **'6.1 Daireler'**
  String get demoTileUnitsGrid;

  /// No description provided for @demoTileInviteResidents.
  ///
  /// In tr, this message translates to:
  /// **'6.2 Sakin daveti'**
  String get demoTileInviteResidents;

  /// No description provided for @demoTilePeriods.
  ///
  /// In tr, this message translates to:
  /// **'6.3 Dönemler'**
  String get demoTilePeriods;

  /// No description provided for @demoTileExpenseNew.
  ///
  /// In tr, this message translates to:
  /// **'6.4 Yeni gider'**
  String get demoTileExpenseNew;

  /// No description provided for @demoTileReportsOverview.
  ///
  /// In tr, this message translates to:
  /// **'7.1 Mali özet raporu'**
  String get demoTileReportsOverview;

  /// No description provided for @demoTileDocuments.
  ///
  /// In tr, this message translates to:
  /// **'8.1 Belgeler'**
  String get demoTileDocuments;

  /// No description provided for @demoTilePolls.
  ///
  /// In tr, this message translates to:
  /// **'8.2 Oylamalar'**
  String get demoTilePolls;

  /// No description provided for @demoTileSubscription.
  ///
  /// In tr, this message translates to:
  /// **'9.1 Abonelik'**
  String get demoTileSubscription;

  /// No description provided for @demoTileBuildingSettings.
  ///
  /// In tr, this message translates to:
  /// **'9.2 Bina ayarları'**
  String get demoTileBuildingSettings;

  /// No description provided for @demoSplashTagline.
  ///
  /// In tr, this message translates to:
  /// **'Apartman ve site yönetimi'**
  String get demoSplashTagline;

  /// No description provided for @demoWelcomeSlide1Title.
  ///
  /// In tr, this message translates to:
  /// **'Apartmanını yönet, sakinler haberdar'**
  String get demoWelcomeSlide1Title;

  /// No description provided for @demoWelcomeSlide1Body.
  ///
  /// In tr, this message translates to:
  /// **'Aidat takibi, duyurular, arıza bildirim ve oylamalar — hepsi tek bir uygulamada.'**
  String get demoWelcomeSlide1Body;

  /// No description provided for @demoWelcomeSlide2Title.
  ///
  /// In tr, this message translates to:
  /// **'Aidat ve ödemeler şeffaf'**
  String get demoWelcomeSlide2Title;

  /// No description provided for @demoWelcomeSlide2Body.
  ///
  /// In tr, this message translates to:
  /// **'Borç durumunu anında gör, ödemeni güvenle tamamla.'**
  String get demoWelcomeSlide2Body;

  /// No description provided for @demoWelcomeSlide3Title.
  ///
  /// In tr, this message translates to:
  /// **'Topluluk tek yerde'**
  String get demoWelcomeSlide3Title;

  /// No description provided for @demoWelcomeSlide3Body.
  ///
  /// In tr, this message translates to:
  /// **'Duyurular, belgeler ve oylamalarla komşularınla bağlantıda kal.'**
  String get demoWelcomeSlide3Body;

  /// No description provided for @demoSkip.
  ///
  /// In tr, this message translates to:
  /// **'Atla'**
  String get demoSkip;

  /// No description provided for @demoBuildingHeaderLine.
  ///
  /// In tr, this message translates to:
  /// **'YEŞİL VADİ APT. · 3A'**
  String get demoBuildingHeaderLine;

  /// No description provided for @residentBuildingHeaderFallback.
  ///
  /// In tr, this message translates to:
  /// **'SAKİN · Apartman'**
  String get residentBuildingHeaderFallback;

  /// No description provided for @demoHelloName.
  ///
  /// In tr, this message translates to:
  /// **'Merhaba {name} 👋'**
  String demoHelloName(Object name);

  /// No description provided for @demoOpenDebt.
  ///
  /// In tr, this message translates to:
  /// **'AÇIK BORÇ'**
  String get demoOpenDebt;

  /// No description provided for @demoDueLabel.
  ///
  /// In tr, this message translates to:
  /// **'Vade: {date} · {status}'**
  String demoDueLabel(Object date, Object status);

  /// No description provided for @demoPayNow.
  ///
  /// In tr, this message translates to:
  /// **'Şimdi öde'**
  String get demoPayNow;

  /// No description provided for @demoAnnouncementsSection.
  ///
  /// In tr, this message translates to:
  /// **'Duyurular'**
  String get demoAnnouncementsSection;

  /// No description provided for @demoIssuesSection.
  ///
  /// In tr, this message translates to:
  /// **'Arızalar'**
  String get demoIssuesSection;

  /// No description provided for @demoPinAnnouncement.
  ///
  /// In tr, this message translates to:
  /// **'Sabitlenmiş'**
  String get demoPinAnnouncement;

  /// No description provided for @demoAnnouncementSampleTitle.
  ///
  /// In tr, this message translates to:
  /// **'Asansör bakımı yarın 10:00–12:00'**
  String get demoAnnouncementSampleTitle;

  /// No description provided for @demoAnnouncementSampleMeta.
  ///
  /// In tr, this message translates to:
  /// **'Yönetim · 124 görüntüleme'**
  String get demoAnnouncementSampleMeta;

  /// No description provided for @demoIssueSampleTitle.
  ///
  /// In tr, this message translates to:
  /// **'Çatı sızdırması — merdiven sonu'**
  String get demoIssueSampleTitle;

  /// No description provided for @demoIssueSampleMeta.
  ///
  /// In tr, this message translates to:
  /// **'Açık · Yüksek öncelik'**
  String get demoIssueSampleMeta;

  /// No description provided for @demoNavHome.
  ///
  /// In tr, this message translates to:
  /// **'Ana sayfa'**
  String get demoNavHome;

  /// No description provided for @demoNavAnnouncements.
  ///
  /// In tr, this message translates to:
  /// **'Duyuru'**
  String get demoNavAnnouncements;

  /// No description provided for @demoNavFinance.
  ///
  /// In tr, this message translates to:
  /// **'Aidat'**
  String get demoNavFinance;

  /// No description provided for @demoNavIssues.
  ///
  /// In tr, this message translates to:
  /// **'Arıza'**
  String get demoNavIssues;

  /// No description provided for @demoNavProfile.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get demoNavProfile;

  /// No description provided for @demoAdminSummaryTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bu ay özeti'**
  String get demoAdminSummaryTitle;

  /// No description provided for @demoCollected.
  ///
  /// In tr, this message translates to:
  /// **'Tahsil edilen'**
  String get demoCollected;

  /// No description provided for @demoExpected.
  ///
  /// In tr, this message translates to:
  /// **'Beklenen'**
  String get demoExpected;

  /// No description provided for @demoExpenseTotal.
  ///
  /// In tr, this message translates to:
  /// **'Gider'**
  String get demoExpenseTotal;

  /// No description provided for @demoQuickActions.
  ///
  /// In tr, this message translates to:
  /// **'Hızlı işlemler'**
  String get demoQuickActions;

  /// No description provided for @demoActionInvite.
  ///
  /// In tr, this message translates to:
  /// **'Davet kodu'**
  String get demoActionInvite;

  /// No description provided for @demoActionExpense.
  ///
  /// In tr, this message translates to:
  /// **'Yeni gider'**
  String get demoActionExpense;

  /// No description provided for @demoActionIssues.
  ///
  /// In tr, this message translates to:
  /// **'Arızalar'**
  String get demoActionIssues;

  /// No description provided for @demoChartPlaceholder.
  ///
  /// In tr, this message translates to:
  /// **'Tahsilat grafiği (demo)'**
  String get demoChartPlaceholder;

  /// No description provided for @demoRoleTitle.
  ///
  /// In tr, this message translates to:
  /// **'Nasıl devam edelim?'**
  String get demoRoleTitle;

  /// No description provided for @demoRoleSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Sakin davet koduyla katılır; yönetici yeni bina kurulumunu başlatır.'**
  String get demoRoleSubtitle;

  /// No description provided for @demoRoleResident.
  ///
  /// In tr, this message translates to:
  /// **'Sakin — davet kodum var'**
  String get demoRoleResident;

  /// No description provided for @demoRoleAdmin.
  ///
  /// In tr, this message translates to:
  /// **'Yönetici — bina oluştur'**
  String get demoRoleAdmin;

  /// No description provided for @demoInviteTitle.
  ///
  /// In tr, this message translates to:
  /// **'Davet kodu'**
  String get demoInviteTitle;

  /// No description provided for @demoInviteSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'8 haneli kodu girin; doğrulayınca apartman önizlemesi gösterilir.'**
  String get demoInviteSubtitle;

  /// No description provided for @demoInviteHint.
  ///
  /// In tr, this message translates to:
  /// **'KOD'**
  String get demoInviteHint;

  /// No description provided for @demoInviteVerify.
  ///
  /// In tr, this message translates to:
  /// **'Doğrula ve katıl'**
  String get demoInviteVerify;

  /// No description provided for @demoInvitePreviewTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yeşil Vadi Apartmanı'**
  String get demoInvitePreviewTitle;

  /// No description provided for @demoInvitePreviewSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Üsküdar · İstanbul'**
  String get demoInvitePreviewSubtitle;

  /// No description provided for @demoSetupBuildingTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bina bilgileri'**
  String get demoSetupBuildingTitle;

  /// No description provided for @demoSetupBuildingName.
  ///
  /// In tr, this message translates to:
  /// **'Apartman adı'**
  String get demoSetupBuildingName;

  /// No description provided for @demoSetupAddress.
  ///
  /// In tr, this message translates to:
  /// **'Açık adres'**
  String get demoSetupAddress;

  /// No description provided for @demoSetupCity.
  ///
  /// In tr, this message translates to:
  /// **'İl / ilçe'**
  String get demoSetupCity;

  /// No description provided for @demoSetupStep.
  ///
  /// In tr, this message translates to:
  /// **'Adım {current} / {total}'**
  String demoSetupStep(Object current, Object total);

  /// No description provided for @demoSetupStructureTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yapı'**
  String get demoSetupStructureTitle;

  /// No description provided for @demoSetupFloors.
  ///
  /// In tr, this message translates to:
  /// **'Kat sayısı'**
  String get demoSetupFloors;

  /// No description provided for @demoSetupUnitsPerFloor.
  ///
  /// In tr, this message translates to:
  /// **'Kat başı daire'**
  String get demoSetupUnitsPerFloor;

  /// No description provided for @demoSetupUnitsPreview.
  ///
  /// In tr, this message translates to:
  /// **'Önizleme: ~{count} daire'**
  String demoSetupUnitsPreview(Object count);

  /// No description provided for @demoSetupUnitsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Daireler'**
  String get demoSetupUnitsTitle;

  /// No description provided for @demoSetupNamingAuto.
  ///
  /// In tr, this message translates to:
  /// **'Otomatik adlandırma'**
  String get demoSetupNamingAuto;

  /// No description provided for @demoSetupDuesTitle.
  ///
  /// In tr, this message translates to:
  /// **'Aidat şablonu'**
  String get demoSetupDuesTitle;

  /// No description provided for @demoSetupDuesAmount.
  ///
  /// In tr, this message translates to:
  /// **'Aylık tutar'**
  String get demoSetupDuesAmount;

  /// No description provided for @demoSetupDueDay.
  ///
  /// In tr, this message translates to:
  /// **'Vade günü'**
  String get demoSetupDueDay;

  /// No description provided for @demoSetupSmsReminder.
  ///
  /// In tr, this message translates to:
  /// **'SMS hatırlatma'**
  String get demoSetupSmsReminder;

  /// No description provided for @demoSetupLateFee.
  ///
  /// In tr, this message translates to:
  /// **'Gecikme uyarısı'**
  String get demoSetupLateFee;

  /// No description provided for @demoFilterAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get demoFilterAll;

  /// No description provided for @demoFilterPaid.
  ///
  /// In tr, this message translates to:
  /// **'Ödendi'**
  String get demoFilterPaid;

  /// No description provided for @demoFilterDebt.
  ///
  /// In tr, this message translates to:
  /// **'Borçlu'**
  String get demoFilterDebt;

  /// No description provided for @demoMonthMarch2026.
  ///
  /// In tr, this message translates to:
  /// **'Mart 2026'**
  String get demoMonthMarch2026;

  /// No description provided for @demoMonthFebruary2026.
  ///
  /// In tr, this message translates to:
  /// **'Şubat 2026'**
  String get demoMonthFebruary2026;

  /// No description provided for @demoDuesDetailTitle.
  ///
  /// In tr, this message translates to:
  /// **'Aidat detayı'**
  String get demoDuesDetailTitle;

  /// No description provided for @demoBreakdownBase.
  ///
  /// In tr, this message translates to:
  /// **'Aidat tutarı'**
  String get demoBreakdownBase;

  /// No description provided for @demoBreakdownLate.
  ///
  /// In tr, this message translates to:
  /// **'Gecikme'**
  String get demoBreakdownLate;

  /// No description provided for @demoInvoiceRef.
  ///
  /// In tr, this message translates to:
  /// **'Fatura no: {ref}'**
  String demoInvoiceRef(Object ref);

  /// No description provided for @demoPaymentTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ödeme'**
  String get demoPaymentTitle;

  /// No description provided for @demoPaymentSavedCard.
  ///
  /// In tr, this message translates to:
  /// **'Kayıtlı kart'**
  String get demoPaymentSavedCard;

  /// No description provided for @demoPaymentCvv.
  ///
  /// In tr, this message translates to:
  /// **'CVV'**
  String get demoPaymentCvv;

  /// No description provided for @demoPaymentSecure.
  ///
  /// In tr, this message translates to:
  /// **'3D Secure ile güvenli ödeme'**
  String get demoPaymentSecure;

  /// No description provided for @demoPaymentSubmit.
  ///
  /// In tr, this message translates to:
  /// **'Ödemeyi tamamla'**
  String get demoPaymentSubmit;

  /// No description provided for @demoPaymentSuccessTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ödeme alındı'**
  String get demoPaymentSuccessTitle;

  /// No description provided for @demoPaymentSuccessBody.
  ///
  /// In tr, this message translates to:
  /// **'İşlem başarıyla tamamlandı. Makbuzu indirebilirsiniz.'**
  String get demoPaymentSuccessBody;

  /// No description provided for @demoDownloadReceipt.
  ///
  /// In tr, this message translates to:
  /// **'Makbuzu indir'**
  String get demoDownloadReceipt;

  /// No description provided for @demoAnnouncementDetailHint.
  ///
  /// In tr, this message translates to:
  /// **'Yorum yazın…'**
  String get demoAnnouncementDetailHint;

  /// No description provided for @demoAnnouncementSampleBody.
  ///
  /// In tr, this message translates to:
  /// **'Elektrik kesintisi olabileceğinden asansör kullanımında dikkatli olun.'**
  String get demoAnnouncementSampleBody;

  /// No description provided for @demoAttachmentPdf.
  ///
  /// In tr, this message translates to:
  /// **'toplanti_notlari.pdf'**
  String get demoAttachmentPdf;

  /// No description provided for @demoProfileBuildingCard.
  ///
  /// In tr, this message translates to:
  /// **'Apartman kartı'**
  String get demoProfileBuildingCard;

  /// No description provided for @demoProfileSettings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get demoProfileSettings;

  /// No description provided for @demoProfileNotifications.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get demoProfileNotifications;

  /// No description provided for @demoProfilePrivacy.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik ve KVKK'**
  String get demoProfilePrivacy;

  /// No description provided for @demoIssueCategory.
  ///
  /// In tr, this message translates to:
  /// **'Kategori'**
  String get demoIssueCategory;

  /// No description provided for @demoIssueLocation.
  ///
  /// In tr, this message translates to:
  /// **'Konum'**
  String get demoIssueLocation;

  /// No description provided for @demoIssuePriority.
  ///
  /// In tr, this message translates to:
  /// **'Öncelik'**
  String get demoIssuePriority;

  /// No description provided for @demoIssueAddPhoto.
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraf ekle'**
  String get demoIssueAddPhoto;

  /// No description provided for @demoIssueSubmit.
  ///
  /// In tr, this message translates to:
  /// **'Arızayı bildir'**
  String get demoIssueSubmit;

  /// No description provided for @demoIssueTimelineLogged.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt oluşturuldu'**
  String get demoIssueTimelineLogged;

  /// No description provided for @demoIssueTimelineAssigned.
  ///
  /// In tr, this message translates to:
  /// **'Teknik ekibe atandı'**
  String get demoIssueTimelineAssigned;

  /// No description provided for @demoIssueAdminNote.
  ///
  /// In tr, this message translates to:
  /// **'Yönetici notu: Yarın sabah kontrol edilecek.'**
  String get demoIssueAdminNote;

  /// No description provided for @demoKanbanOpen.
  ///
  /// In tr, this message translates to:
  /// **'Açık'**
  String get demoKanbanOpen;

  /// No description provided for @demoKanbanProgress.
  ///
  /// In tr, this message translates to:
  /// **'İşlemde'**
  String get demoKanbanProgress;

  /// No description provided for @demoKanbanDone.
  ///
  /// In tr, this message translates to:
  /// **'Tamamlandı'**
  String get demoKanbanDone;

  /// No description provided for @demoUnitsFloor.
  ///
  /// In tr, this message translates to:
  /// **'{floor}. kat'**
  String demoUnitsFloor(Object floor);

  /// No description provided for @demoUnitDebt.
  ///
  /// In tr, this message translates to:
  /// **'Borç {amount}'**
  String demoUnitDebt(Object amount);

  /// No description provided for @demoUnitPaid.
  ///
  /// In tr, this message translates to:
  /// **'Ödendi'**
  String get demoUnitPaid;

  /// No description provided for @demoUnitEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Boş'**
  String get demoUnitEmpty;

  /// No description provided for @demoInviteQrHelp.
  ///
  /// In tr, this message translates to:
  /// **'QR kodu paylaş veya kodu kopyala.'**
  String get demoInviteQrHelp;

  /// No description provided for @demoInviteShare.
  ///
  /// In tr, this message translates to:
  /// **'Daveti paylaş'**
  String get demoInviteShare;

  /// No description provided for @demoInviteBulk.
  ///
  /// In tr, this message translates to:
  /// **'Toplu davet (CSV)'**
  String get demoInviteBulk;

  /// No description provided for @demoPeriodActive.
  ///
  /// In tr, this message translates to:
  /// **'Aktif dönem'**
  String get demoPeriodActive;

  /// No description provided for @demoPeriodCollectionRate.
  ///
  /// In tr, this message translates to:
  /// **'Tahsilat oranı'**
  String get demoPeriodCollectionRate;

  /// No description provided for @demoExpenseNotifyResidents.
  ///
  /// In tr, this message translates to:
  /// **'Sakinlere bildir'**
  String get demoExpenseNotifyResidents;

  /// No description provided for @demoExpenseSave.
  ///
  /// In tr, this message translates to:
  /// **'Gideri kaydet'**
  String get demoExpenseSave;

  /// No description provided for @demoExpenseCategoryWater.
  ///
  /// In tr, this message translates to:
  /// **'Su'**
  String get demoExpenseCategoryWater;

  /// No description provided for @demoExpenseCategoryElectric.
  ///
  /// In tr, this message translates to:
  /// **'Elektrik'**
  String get demoExpenseCategoryElectric;

  /// No description provided for @demoExpenseCategoryElevator.
  ///
  /// In tr, this message translates to:
  /// **'Asansör'**
  String get demoExpenseCategoryElevator;

  /// No description provided for @demoExpenseCategoryOther.
  ///
  /// In tr, this message translates to:
  /// **'Diğer'**
  String get demoExpenseCategoryOther;

  /// No description provided for @demoReportsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Raporlar'**
  String get demoReportsTitle;

  /// No description provided for @demoReportsCashflow.
  ///
  /// In tr, this message translates to:
  /// **'Nakit akışı'**
  String get demoReportsCashflow;

  /// No description provided for @demoReportsExpenseSplit.
  ///
  /// In tr, this message translates to:
  /// **'Gider dağılımı'**
  String get demoReportsExpenseSplit;

  /// No description provided for @demoDocumentsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Belgeler'**
  String get demoDocumentsTitle;

  /// No description provided for @demoDocumentsFolderMeeting.
  ///
  /// In tr, this message translates to:
  /// **'Toplantı'**
  String get demoDocumentsFolderMeeting;

  /// No description provided for @demoDocumentsFolderContracts.
  ///
  /// In tr, this message translates to:
  /// **'Sözleşmeler'**
  String get demoDocumentsFolderContracts;

  /// No description provided for @demoPollsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Oylamalar'**
  String get demoPollsTitle;

  /// No description provided for @demoPollsActive.
  ///
  /// In tr, this message translates to:
  /// **'Devam eden'**
  String get demoPollsActive;

  /// No description provided for @demoPollsClosed.
  ///
  /// In tr, this message translates to:
  /// **'Tamamlanan'**
  String get demoPollsClosed;

  /// No description provided for @demoPollSampleTitle.
  ///
  /// In tr, this message translates to:
  /// **'Çatı yenileme önerisi'**
  String get demoPollSampleTitle;

  /// No description provided for @demoSubscriptionTitle.
  ///
  /// In tr, this message translates to:
  /// **'Abonelik'**
  String get demoSubscriptionTitle;

  /// No description provided for @demoSubscriptionPlan.
  ///
  /// In tr, this message translates to:
  /// **'Profesyonel plan'**
  String get demoSubscriptionPlan;

  /// No description provided for @demoSubscriptionPrice.
  ///
  /// In tr, this message translates to:
  /// **'₺299 / ay · bir bina'**
  String get demoSubscriptionPrice;

  /// No description provided for @demoSubscriptionCta.
  ///
  /// In tr, this message translates to:
  /// **'Planı seç'**
  String get demoSubscriptionCta;

  /// No description provided for @demoSettingsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bina ayarları'**
  String get demoSettingsTitle;

  /// No description provided for @demoSettingsDues.
  ///
  /// In tr, this message translates to:
  /// **'Aidat kuralları'**
  String get demoSettingsDues;

  /// No description provided for @demoSettingsRoles.
  ///
  /// In tr, this message translates to:
  /// **'Yönetici rolleri'**
  String get demoSettingsRoles;

  /// No description provided for @demoLegendPaid.
  ///
  /// In tr, this message translates to:
  /// **'Ödendi'**
  String get demoLegendPaid;

  /// No description provided for @demoLegendDebt.
  ///
  /// In tr, this message translates to:
  /// **'Borçlu'**
  String get demoLegendDebt;

  /// No description provided for @demoLegendVacant.
  ///
  /// In tr, this message translates to:
  /// **'Boş'**
  String get demoLegendVacant;

  /// No description provided for @demoSampleDelay.
  ///
  /// In tr, this message translates to:
  /// **'3 gün gecikti'**
  String get demoSampleDelay;

  /// No description provided for @demoSampleDateShort.
  ///
  /// In tr, this message translates to:
  /// **'5 Mart 2026'**
  String get demoSampleDateShort;

  /// No description provided for @demoPriorityHigh.
  ///
  /// In tr, this message translates to:
  /// **'Yüksek öncelik'**
  String get demoPriorityHigh;

  /// No description provided for @homeRecentAnnouncements.
  ///
  /// In tr, this message translates to:
  /// **'Son duyurular'**
  String get homeRecentAnnouncements;

  /// No description provided for @homeSeeAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get homeSeeAll;

  /// No description provided for @homeAnnouncementTagPin.
  ///
  /// In tr, this message translates to:
  /// **'PIN'**
  String get homeAnnouncementTagPin;

  /// No description provided for @homeAnnouncementTagInfo.
  ///
  /// In tr, this message translates to:
  /// **'Bilgi'**
  String get homeAnnouncementTagInfo;

  /// No description provided for @homeOpenIssuesSection.
  ///
  /// In tr, this message translates to:
  /// **'Açık arızalar'**
  String get homeOpenIssuesSection;

  /// No description provided for @homeIssueStatusInProgress.
  ///
  /// In tr, this message translates to:
  /// **'İşlemde'**
  String get homeIssueStatusInProgress;

  /// No description provided for @homeIssueUpdatedAgo.
  ///
  /// In tr, this message translates to:
  /// **'{time} önce güncellendi'**
  String homeIssueUpdatedAgo(Object time);

  /// No description provided for @homeManagerBuildingLine.
  ///
  /// In tr, this message translates to:
  /// **'YÖNETİCİ · YEŞİL VADİ APT.'**
  String get homeManagerBuildingLine;

  /// No description provided for @homeManagerMonthYear.
  ///
  /// In tr, this message translates to:
  /// **'Mart 2026'**
  String get homeManagerMonthYear;

  /// No description provided for @homeManagerCollectionLabel.
  ///
  /// In tr, this message translates to:
  /// **'TAHSİLAT'**
  String get homeManagerCollectionLabel;

  /// No description provided for @homeManagerIncomeLabel.
  ///
  /// In tr, this message translates to:
  /// **'BU AY GELİR'**
  String get homeManagerIncomeLabel;

  /// No description provided for @homeManagerOpenDebtLabel.
  ///
  /// In tr, this message translates to:
  /// **'AÇIK BORÇ'**
  String get homeManagerOpenDebtLabel;

  /// No description provided for @homeManagerOpenIssuesLabel.
  ///
  /// In tr, this message translates to:
  /// **'AÇIK ARIZA'**
  String get homeManagerOpenIssuesLabel;

  /// No description provided for @homeManagerUnitsSuffix.
  ///
  /// In tr, this message translates to:
  /// **'{count} daire'**
  String homeManagerUnitsSuffix(Object count);

  /// No description provided for @homeManagerHighPrioritySuffix.
  ///
  /// In tr, this message translates to:
  /// **'{count} yüksek öncelik'**
  String homeManagerHighPrioritySuffix(Object count);

  /// No description provided for @homeManagerIncomeDelta.
  ///
  /// In tr, this message translates to:
  /// **'↑ {percent} önceki ay'**
  String homeManagerIncomeDelta(Object percent);

  /// No description provided for @homeChartSixMonths.
  ///
  /// In tr, this message translates to:
  /// **'Son 6 ay · Gelir / Gider'**
  String get homeChartSixMonths;

  /// No description provided for @homeChartLegendIncome.
  ///
  /// In tr, this message translates to:
  /// **'Gelir'**
  String get homeChartLegendIncome;

  /// No description provided for @homeChartLegendExpense.
  ///
  /// In tr, this message translates to:
  /// **'Gider'**
  String get homeChartLegendExpense;

  /// No description provided for @homeQuickNewPeriod.
  ///
  /// In tr, this message translates to:
  /// **'Yeni dönem'**
  String get homeQuickNewPeriod;

  /// No description provided for @homeQuickSendAnnouncement.
  ///
  /// In tr, this message translates to:
  /// **'Duyuru gönder'**
  String get homeQuickSendAnnouncement;

  /// No description provided for @homeQuickSendInvite.
  ///
  /// In tr, this message translates to:
  /// **'Davet gönder'**
  String get homeQuickSendInvite;

  /// No description provided for @homeQuickAddExpense.
  ///
  /// In tr, this message translates to:
  /// **'Gider ekle'**
  String get homeQuickAddExpense;

  /// No description provided for @homeQuickActionsSection.
  ///
  /// In tr, this message translates to:
  /// **'HIZLI AKSİYONLAR'**
  String get homeQuickActionsSection;

  /// No description provided for @homeDemoSwitchManager.
  ///
  /// In tr, this message translates to:
  /// **'Yönetici görünümü'**
  String get homeDemoSwitchManager;

  /// No description provided for @homeDemoSwitchResident.
  ///
  /// In tr, this message translates to:
  /// **'Sakin görünümü'**
  String get homeDemoSwitchResident;

  /// No description provided for @homeEmptyNoRecords.
  ///
  /// In tr, this message translates to:
  /// **'Henüz kayıt yok.'**
  String get homeEmptyNoRecords;

  /// No description provided for @homeNoOutstandingDebt.
  ///
  /// In tr, this message translates to:
  /// **'Açık borcunuz yok.'**
  String get homeNoOutstandingDebt;

  /// No description provided for @homeAidatSectionTitle.
  ///
  /// In tr, this message translates to:
  /// **'Aidat özeti'**
  String get homeAidatSectionTitle;

  /// No description provided for @homeDemoDuesMarchTitle.
  ///
  /// In tr, this message translates to:
  /// **'Mart 2026 aidatı'**
  String get homeDemoDuesMarchTitle;

  /// No description provided for @homeDemoDuesMarchSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Son ödeme tarihi geçti'**
  String get homeDemoDuesMarchSubtitle;

  /// No description provided for @homeDemoDuesFebTitle.
  ///
  /// In tr, this message translates to:
  /// **'Şubat 2026 aidatı'**
  String get homeDemoDuesFebTitle;

  /// No description provided for @homeDemoDuesFebSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Ödendi · 28 Şubat 2026'**
  String get homeDemoDuesFebSubtitle;

  /// No description provided for @homeDemoElevatorAnnouncementTitle.
  ///
  /// In tr, this message translates to:
  /// **'Asansör bakımı · 12 Mart'**
  String get homeDemoElevatorAnnouncementTitle;

  /// No description provided for @homeDemoElevatorAnnouncementAuthor.
  ///
  /// In tr, this message translates to:
  /// **'Ayşe Demir'**
  String get homeDemoElevatorAnnouncementAuthor;

  /// No description provided for @homeDemoHotWaterTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sıcak su kesintisi 14:00–16:00'**
  String get homeDemoHotWaterTitle;

  /// No description provided for @homeDemoHotWaterAuthor.
  ///
  /// In tr, this message translates to:
  /// **'Ali Kaya'**
  String get homeDemoHotWaterAuthor;

  /// No description provided for @homeDemoRoofLeakTitle.
  ///
  /// In tr, this message translates to:
  /// **'Çatı su sızıntısı'**
  String get homeDemoRoofLeakTitle;

  /// No description provided for @homeDemoIssueUpdatedHours.
  ///
  /// In tr, this message translates to:
  /// **'2 saat'**
  String get homeDemoIssueUpdatedHours;

  /// No description provided for @homeNotificationsBadge.
  ///
  /// In tr, this message translates to:
  /// **'{count} bildirim'**
  String homeNotificationsBadge(Object count);

  /// No description provided for @homeFeatureSoon.
  ///
  /// In tr, this message translates to:
  /// **'Bu bölüm yakında.'**
  String get homeFeatureSoon;

  /// No description provided for @demoPersonaScreenTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hesap türü'**
  String get demoPersonaScreenTitle;

  /// No description provided for @demoPersonaScreenSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Apartmanına nasıl katılıyorsun? Bunu demo içinde istediğin zaman profilden değiştirebilirsin.'**
  String get demoPersonaScreenSubtitle;

  /// No description provided for @demoPersonaResidentTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sakin olarak devam et'**
  String get demoPersonaResidentTitle;

  /// No description provided for @demoPersonaResidentBody.
  ///
  /// In tr, this message translates to:
  /// **'Yöneticinden aldığın davet kodu ile dairene bağlan.'**
  String get demoPersonaResidentBody;

  /// No description provided for @demoPersonaManagerTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yönetici olarak devam et'**
  String get demoPersonaManagerTitle;

  /// No description provided for @demoPersonaManagerBody.
  ///
  /// In tr, this message translates to:
  /// **'Apartmanını sıfırdan kur, sakinleri davet et.'**
  String get demoPersonaManagerBody;

  /// No description provided for @demoPersonaTrialBanner.
  ///
  /// In tr, this message translates to:
  /// **'İlk 30 gün ücretsiz. Kart bilgisi gerekmez.'**
  String get demoPersonaTrialBanner;

  /// No description provided for @catalogEmptyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Henüz kayıt yok'**
  String get catalogEmptyTitle;

  /// No description provided for @catalogLoadError.
  ///
  /// In tr, this message translates to:
  /// **'Veriler yüklenemedi'**
  String get catalogLoadError;

  /// No description provided for @duesMyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Aidatlarım'**
  String get duesMyTitle;

  /// No description provided for @duesOpenDebt.
  ///
  /// In tr, this message translates to:
  /// **'AÇIK BORÇ'**
  String get duesOpenDebt;

  /// No description provided for @duesUnpaidSummary.
  ///
  /// In tr, this message translates to:
  /// **'{unpaid} ödenmemiş · {late}'**
  String duesUnpaidSummary(Object unpaid, Object late);

  /// No description provided for @duesFilterAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get duesFilterAll;

  /// No description provided for @duesFilterOpen.
  ///
  /// In tr, this message translates to:
  /// **'Açık'**
  String get duesFilterOpen;

  /// No description provided for @duesFilterPaid.
  ///
  /// In tr, this message translates to:
  /// **'Ödendi'**
  String get duesFilterPaid;

  /// No description provided for @duesFilterLate.
  ///
  /// In tr, this message translates to:
  /// **'Gecikmiş'**
  String get duesFilterLate;

  /// No description provided for @duesPayNow.
  ///
  /// In tr, this message translates to:
  /// **'Şimdi öde'**
  String get duesPayNow;

  /// No description provided for @duesDetailTitle.
  ///
  /// In tr, this message translates to:
  /// **'Aidat detayı'**
  String get duesDetailTitle;

  /// No description provided for @duesAmountDue.
  ///
  /// In tr, this message translates to:
  /// **'ÖDENECEK TUTAR'**
  String get duesAmountDue;

  /// No description provided for @duesLineBase.
  ///
  /// In tr, this message translates to:
  /// **'Aidat'**
  String get duesLineBase;

  /// No description provided for @duesLineLateFee.
  ///
  /// In tr, this message translates to:
  /// **'Gecikme faizi ({days} gün)'**
  String duesLineLateFee(Object days);

  /// No description provided for @duesPayCta.
  ///
  /// In tr, this message translates to:
  /// **'{amount} öde'**
  String duesPayCta(Object amount);

  /// No description provided for @paymentTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ödeme'**
  String get paymentTitle;

  /// No description provided for @paymentSecurePay.
  ///
  /// In tr, this message translates to:
  /// **'Güvenli öde'**
  String get paymentSecurePay;

  /// No description provided for @paymentSuccessTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ödeme başarılı'**
  String get paymentSuccessTitle;

  /// No description provided for @paymentSuccessBody.
  ///
  /// In tr, this message translates to:
  /// **'Aidatın ödendi. Makbuzu e-posta ile gönderdik.'**
  String get paymentSuccessBody;

  /// No description provided for @announcementsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Duyurular'**
  String get announcementsTitle;

  /// No description provided for @announcementDetailTitle.
  ///
  /// In tr, this message translates to:
  /// **'Duyuru'**
  String get announcementDetailTitle;

  /// No description provided for @announcementsChipAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümü · {count}'**
  String announcementsChipAll(Object count);

  /// No description provided for @announcementsChipPinned.
  ///
  /// In tr, this message translates to:
  /// **'📌 Sabit · {count}'**
  String announcementsChipPinned(Object count);

  /// No description provided for @announcementsChipUrgent.
  ///
  /// In tr, this message translates to:
  /// **'⚠️ Acil'**
  String get announcementsChipUrgent;

  /// No description provided for @announcementsChipInfo.
  ///
  /// In tr, this message translates to:
  /// **'Bilgi'**
  String get announcementsChipInfo;

  /// No description provided for @announcementsChipMaintenance.
  ///
  /// In tr, this message translates to:
  /// **'Bakım'**
  String get announcementsChipMaintenance;

  /// No description provided for @announcementsReadLabel.
  ///
  /// In tr, this message translates to:
  /// **'Okundu'**
  String get announcementsReadLabel;

  /// No description provided for @announcementCommentPlaceholder.
  ///
  /// In tr, this message translates to:
  /// **'Yorum yaz... ({count} yorum)'**
  String announcementCommentPlaceholder(Object count);

  /// No description provided for @announcementDetailTagPinnedMaintenance.
  ///
  /// In tr, this message translates to:
  /// **'⭐ SABİT · BAKIM'**
  String get announcementDetailTagPinnedMaintenance;

  /// No description provided for @announcementDownloadComingSoon.
  ///
  /// In tr, this message translates to:
  /// **'İndirme yakında'**
  String get announcementDownloadComingSoon;

  /// No description provided for @announcementViewsFallback.
  ///
  /// In tr, this message translates to:
  /// **'{count} görüntülenme'**
  String announcementViewsFallback(Object count);

  /// No description provided for @issuesTitle.
  ///
  /// In tr, this message translates to:
  /// **'Arızalar'**
  String get issuesTitle;

  /// No description provided for @issueNewTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yeni arıza'**
  String get issueNewTitle;

  /// No description provided for @issueDetailTitle.
  ///
  /// In tr, this message translates to:
  /// **'Arıza detayı'**
  String get issueDetailTitle;

  /// No description provided for @issueSubmit.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimi gönder'**
  String get issueSubmit;

  /// No description provided for @issuesKanbanTitle.
  ///
  /// In tr, this message translates to:
  /// **'Arıza panosu'**
  String get issuesKanbanTitle;

  /// No description provided for @issuesChipAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümü · {count}'**
  String issuesChipAll(Object count);

  /// No description provided for @issuesChipOpen.
  ///
  /// In tr, this message translates to:
  /// **'Açık · {count}'**
  String issuesChipOpen(Object count);

  /// No description provided for @issuesChipInProgress.
  ///
  /// In tr, this message translates to:
  /// **'İşlemde · {count}'**
  String issuesChipInProgress(Object count);

  /// No description provided for @issuesChipResolved.
  ///
  /// In tr, this message translates to:
  /// **'Çözüldü · {count}'**
  String issuesChipResolved(Object count);

  /// No description provided for @issuesBadgeOpen.
  ///
  /// In tr, this message translates to:
  /// **'Açık'**
  String get issuesBadgeOpen;

  /// No description provided for @issuesBadgeInProgress.
  ///
  /// In tr, this message translates to:
  /// **'İşlemde'**
  String get issuesBadgeInProgress;

  /// No description provided for @issuesBadgeResolved.
  ///
  /// In tr, this message translates to:
  /// **'Çözüldü'**
  String get issuesBadgeResolved;

  /// No description provided for @issuesFooterOwnReport.
  ///
  /// In tr, this message translates to:
  /// **'Senin bildirim'**
  String get issuesFooterOwnReport;

  /// No description provided for @issuesFooterTracking.
  ///
  /// In tr, this message translates to:
  /// **'{name} takipte'**
  String issuesFooterTracking(Object name);

  /// No description provided for @profileMenuTitle.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get profileMenuTitle;

  /// No description provided for @profileSwitchToManager.
  ///
  /// In tr, this message translates to:
  /// **'Yönetici görünümüne geç'**
  String get profileSwitchToManager;

  /// No description provided for @profileSwitchToResident.
  ///
  /// In tr, this message translates to:
  /// **'Sakin görünümüne geç'**
  String get profileSwitchToResident;

  /// No description provided for @setupInviteTitle.
  ///
  /// In tr, this message translates to:
  /// **'Davet kodu'**
  String get setupInviteTitle;

  /// No description provided for @setupInviteJoin.
  ///
  /// In tr, this message translates to:
  /// **'Apartmana katıl'**
  String get setupInviteJoin;

  /// No description provided for @setupWizardTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bina kurulumu'**
  String get setupWizardTitle;

  /// No description provided for @setupWizardStepUnitsPlaceholder.
  ///
  /// In tr, this message translates to:
  /// **'Daireler · özet'**
  String get setupWizardStepUnitsPlaceholder;

  /// No description provided for @setupWizardStepDuesPlaceholder.
  ///
  /// In tr, this message translates to:
  /// **'Aidat planı'**
  String get setupWizardStepDuesPlaceholder;

  /// No description provided for @managerUnitsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Daireler'**
  String get managerUnitsTitle;

  /// No description provided for @managerFloorHeading.
  ///
  /// In tr, this message translates to:
  /// **'KAT {floor}'**
  String managerFloorHeading(Object floor);

  /// No description provided for @managerFloorUnitCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} daire'**
  String managerFloorUnitCount(Object count);

  /// No description provided for @managerInviteTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sakin daveti'**
  String get managerInviteTitle;

  /// No description provided for @managerPeriodsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Aidat dönemleri'**
  String get managerPeriodsTitle;

  /// No description provided for @managerExpenseTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yeni gider'**
  String get managerExpenseTitle;

  /// No description provided for @commonClose.
  ///
  /// In tr, this message translates to:
  /// **'Kapat'**
  String get commonClose;

  /// No description provided for @duesDetailApartmentTitle.
  ///
  /// In tr, this message translates to:
  /// **'Daire'**
  String get duesDetailApartmentTitle;

  /// No description provided for @duesDetailApartmentValue.
  ///
  /// In tr, this message translates to:
  /// **'3A · Mehmet Yılmaz'**
  String get duesDetailApartmentValue;

  /// No description provided for @duesDetailPeriodTitle.
  ///
  /// In tr, this message translates to:
  /// **'Dönem'**
  String get duesDetailPeriodTitle;

  /// No description provided for @duesDetailDueTitle.
  ///
  /// In tr, this message translates to:
  /// **'Vade'**
  String get duesDetailDueTitle;

  /// No description provided for @duesDetailInvoiceTitle.
  ///
  /// In tr, this message translates to:
  /// **'Fatura no'**
  String get duesDetailInvoiceTitle;

  /// No description provided for @payment3dInfo.
  ///
  /// In tr, this message translates to:
  /// **'3D Secure ile güvenli ödeme. SMS doğrulama gelecek.'**
  String get payment3dInfo;

  /// No description provided for @paymentNewCard.
  ///
  /// In tr, this message translates to:
  /// **'Yeni kart ekle'**
  String get paymentNewCard;

  /// No description provided for @paymentTotal.
  ///
  /// In tr, this message translates to:
  /// **'Toplam {amount}'**
  String paymentTotal(Object amount);

  /// No description provided for @paymentReceiptAmountLabel.
  ///
  /// In tr, this message translates to:
  /// **'TUTAR'**
  String get paymentReceiptAmountLabel;

  /// No description provided for @paymentReceiptPeriodLabel.
  ///
  /// In tr, this message translates to:
  /// **'DÖNEM'**
  String get paymentReceiptPeriodLabel;

  /// No description provided for @paymentReceiptTxnLabel.
  ///
  /// In tr, this message translates to:
  /// **'İŞLEM NO'**
  String get paymentReceiptTxnLabel;

  /// No description provided for @paymentReceiptMethodLabel.
  ///
  /// In tr, this message translates to:
  /// **'YÖNTEM'**
  String get paymentReceiptMethodLabel;

  /// No description provided for @paymentReceiptAmountValue.
  ///
  /// In tr, this message translates to:
  /// **'₺1.530,00'**
  String get paymentReceiptAmountValue;

  /// No description provided for @paymentReceiptPeriodValue.
  ///
  /// In tr, this message translates to:
  /// **'Mart 2026 · 3A'**
  String get paymentReceiptPeriodValue;

  /// No description provided for @paymentReceiptTxnValue.
  ///
  /// In tr, this message translates to:
  /// **'İZ-9F4A2-26'**
  String get paymentReceiptTxnValue;

  /// No description provided for @paymentReceiptMethodValue.
  ///
  /// In tr, this message translates to:
  /// **'VISA **** 4729'**
  String get paymentReceiptMethodValue;

  /// No description provided for @announcementCatPinned.
  ///
  /// In tr, this message translates to:
  /// **'SABİT'**
  String get announcementCatPinned;

  /// No description provided for @announcementCatMaintenance.
  ///
  /// In tr, this message translates to:
  /// **'Bakım'**
  String get announcementCatMaintenance;

  /// No description provided for @announcementCatUrgent.
  ///
  /// In tr, this message translates to:
  /// **'Acil'**
  String get announcementCatUrgent;

  /// No description provided for @profileBadgeResident.
  ///
  /// In tr, this message translates to:
  /// **'Sakin'**
  String get profileBadgeResident;

  /// No description provided for @profileBadgeManager.
  ///
  /// In tr, this message translates to:
  /// **'Yönetici'**
  String get profileBadgeManager;

  /// No description provided for @profileBadgeSuperAdmin.
  ///
  /// In tr, this message translates to:
  /// **'Sistem yöneticisi'**
  String get profileBadgeSuperAdmin;

  /// No description provided for @profileCardSubtitleManager.
  ///
  /// In tr, this message translates to:
  /// **'Bu cihaz apartman yönetimi için bağlı.'**
  String get profileCardSubtitleManager;

  /// No description provided for @profileCardSubtitleResident.
  ///
  /// In tr, this message translates to:
  /// **'Bu cihaz davet kodu ile bir daireye bağlı.'**
  String get profileCardSubtitleResident;

  /// No description provided for @profileCardNoBuildingTitle.
  ///
  /// In tr, this message translates to:
  /// **'Apartman bilgisi yok'**
  String get profileCardNoBuildingTitle;

  /// No description provided for @profileCardNoBuildingBody.
  ///
  /// In tr, this message translates to:
  /// **'Kurulum veya davet tamamlanınca burada görünür.'**
  String get profileCardNoBuildingBody;

  /// No description provided for @profileCardFetchingBuildingTitle.
  ///
  /// In tr, this message translates to:
  /// **'Apartman bilgisi getiriliyor…'**
  String get profileCardFetchingBuildingTitle;

  /// No description provided for @profileCardFetchingBuildingBody.
  ///
  /// In tr, this message translates to:
  /// **'Sunucudan apartman adı alınıyor.'**
  String get profileCardFetchingBuildingBody;

  /// No description provided for @profileDemoCardTitle.
  ///
  /// In tr, this message translates to:
  /// **'Demo ortamı'**
  String get profileDemoCardTitle;

  /// No description provided for @profileDemoCardSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Gerçek apartman verisi için DEMO_MODE kapalı çalıştırın.'**
  String get profileDemoCardSubtitle;

  /// No description provided for @profileSectionAccount.
  ///
  /// In tr, this message translates to:
  /// **'HESAP'**
  String get profileSectionAccount;

  /// No description provided for @profileSectionSupport.
  ///
  /// In tr, this message translates to:
  /// **'DESTEK'**
  String get profileSectionSupport;

  /// No description provided for @profileMenuProfileInfo.
  ///
  /// In tr, this message translates to:
  /// **'Profil bilgileri'**
  String get profileMenuProfileInfo;

  /// No description provided for @profileMenuNotifications.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim ayarları'**
  String get profileMenuNotifications;

  /// No description provided for @profileMenuSavedCards.
  ///
  /// In tr, this message translates to:
  /// **'Kayıtlı kartlar'**
  String get profileMenuSavedCards;

  /// No description provided for @profileMenuHelpCenter.
  ///
  /// In tr, this message translates to:
  /// **'Yardım merkezi'**
  String get profileMenuHelpCenter;

  /// No description provided for @profileVersionFooter.
  ///
  /// In tr, this message translates to:
  /// **'Sürüm 1.0.0 · KVKK'**
  String get profileVersionFooter;

  /// No description provided for @issueFieldTitle.
  ///
  /// In tr, this message translates to:
  /// **'Başlık'**
  String get issueFieldTitle;

  /// No description provided for @issueFieldDescription.
  ///
  /// In tr, this message translates to:
  /// **'Açıklama'**
  String get issueFieldDescription;

  /// No description provided for @issueCreateAppBarTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yeni arıza bildirimi'**
  String get issueCreateAppBarTitle;

  /// No description provided for @issueCategorySection.
  ///
  /// In tr, this message translates to:
  /// **'KATEGORİ'**
  String get issueCategorySection;

  /// No description provided for @issueCategoryWater.
  ///
  /// In tr, this message translates to:
  /// **'Su'**
  String get issueCategoryWater;

  /// No description provided for @issueCategoryElectric.
  ///
  /// In tr, this message translates to:
  /// **'Elektrik'**
  String get issueCategoryElectric;

  /// No description provided for @issueCategoryMechanical.
  ///
  /// In tr, this message translates to:
  /// **'Mekanik'**
  String get issueCategoryMechanical;

  /// No description provided for @issueCategoryOther.
  ///
  /// In tr, this message translates to:
  /// **'Diğer'**
  String get issueCategoryOther;

  /// No description provided for @issueLocationSection.
  ///
  /// In tr, this message translates to:
  /// **'KONUM'**
  String get issueLocationSection;

  /// No description provided for @issueLocationApartment.
  ///
  /// In tr, this message translates to:
  /// **'Daire içi'**
  String get issueLocationApartment;

  /// No description provided for @issueLocationParking.
  ///
  /// In tr, this message translates to:
  /// **'Otopark'**
  String get issueLocationParking;

  /// No description provided for @issueLocationRoof.
  ///
  /// In tr, this message translates to:
  /// **'Çatı'**
  String get issueLocationRoof;

  /// No description provided for @issueLocationGarden.
  ///
  /// In tr, this message translates to:
  /// **'Bahçe'**
  String get issueLocationGarden;

  /// No description provided for @issueLocationElevator.
  ///
  /// In tr, this message translates to:
  /// **'Asansör'**
  String get issueLocationElevator;

  /// No description provided for @issuePrioritySection.
  ///
  /// In tr, this message translates to:
  /// **'ÖNCELİK'**
  String get issuePrioritySection;

  /// No description provided for @issuePriorityLow.
  ///
  /// In tr, this message translates to:
  /// **'Düşük'**
  String get issuePriorityLow;

  /// No description provided for @issuePriorityMedium.
  ///
  /// In tr, this message translates to:
  /// **'Orta'**
  String get issuePriorityMedium;

  /// No description provided for @issuePriorityHigh.
  ///
  /// In tr, this message translates to:
  /// **'Yüksek'**
  String get issuePriorityHigh;

  /// No description provided for @issueDescriptionPlaceholder.
  ///
  /// In tr, this message translates to:
  /// **'Sorunu detaylı açıkla...'**
  String get issueDescriptionPlaceholder;

  /// No description provided for @issuePhotoAdd.
  ///
  /// In tr, this message translates to:
  /// **'Foto'**
  String get issuePhotoAdd;

  /// No description provided for @issuePhotoComingSoon.
  ///
  /// In tr, this message translates to:
  /// **'Foto ekleme yakında'**
  String get issuePhotoComingSoon;

  /// No description provided for @issueSubmittedDemo.
  ///
  /// In tr, this message translates to:
  /// **'Demo: bildirim kaydedildi.'**
  String get issueSubmittedDemo;

  /// No description provided for @issueTimelineSection.
  ///
  /// In tr, this message translates to:
  /// **'SÜREÇ'**
  String get issueTimelineSection;

  /// No description provided for @issueTimelineReported.
  ///
  /// In tr, this message translates to:
  /// **'Bildirildi'**
  String get issueTimelineReported;

  /// No description provided for @issueTimelineSeen.
  ///
  /// In tr, this message translates to:
  /// **'Görüldü'**
  String get issueTimelineSeen;

  /// No description provided for @issueTimelineInProgress.
  ///
  /// In tr, this message translates to:
  /// **'İşlemde'**
  String get issueTimelineInProgress;

  /// No description provided for @issueTimelineResolved.
  ///
  /// In tr, this message translates to:
  /// **'Çözüldü'**
  String get issueTimelineResolved;

  /// No description provided for @issueTimelinePending.
  ///
  /// In tr, this message translates to:
  /// **'—'**
  String get issueTimelinePending;

  /// No description provided for @issueDemoReportedBy.
  ///
  /// In tr, this message translates to:
  /// **'Mehmet Y. (3A) tarafından bildirildi'**
  String get issueDemoReportedBy;

  /// No description provided for @issueTimelineSeenBody.
  ///
  /// In tr, this message translates to:
  /// **'{assignee} (yönetici) görevi aldı'**
  String issueTimelineSeenBody(Object assignee);

  /// No description provided for @issueDemoInProgressNote.
  ///
  /// In tr, this message translates to:
  /// **'Tesisatçı çağrıldı, yarın 10:00\'da gelecek.'**
  String get issueDemoInProgressNote;

  /// No description provided for @issueDemoManagerName.
  ///
  /// In tr, this message translates to:
  /// **'Ayşe Demir'**
  String get issueDemoManagerName;

  /// No description provided for @navBack.
  ///
  /// In tr, this message translates to:
  /// **'Geri'**
  String get navBack;

  /// No description provided for @setupInviteHeadline.
  ///
  /// In tr, this message translates to:
  /// **'Apartmanına bağlan'**
  String get setupInviteHeadline;

  /// No description provided for @setupFloorCountLabel.
  ///
  /// In tr, this message translates to:
  /// **'Kat sayısı'**
  String get setupFloorCountLabel;

  /// No description provided for @setupWizardPerFloorLabel.
  ///
  /// In tr, this message translates to:
  /// **'Her katta daire'**
  String get setupWizardPerFloorLabel;

  /// No description provided for @setupBuildingNameLabel.
  ///
  /// In tr, this message translates to:
  /// **'Bina adı'**
  String get setupBuildingNameLabel;

  /// No description provided for @setupAddressLabel.
  ///
  /// In tr, this message translates to:
  /// **'Açık adres'**
  String get setupAddressLabel;

  /// No description provided for @setupProvinceLabel.
  ///
  /// In tr, this message translates to:
  /// **'İl'**
  String get setupProvinceLabel;

  /// No description provided for @setupDistrictLabel.
  ///
  /// In tr, this message translates to:
  /// **'İlçe'**
  String get setupDistrictLabel;

  /// No description provided for @setupFieldRequired.
  ///
  /// In tr, this message translates to:
  /// **'Bu alan zorunludur.'**
  String get setupFieldRequired;

  /// No description provided for @setupProvincesLoadError.
  ///
  /// In tr, this message translates to:
  /// **'İl listesi yüklenemedi. Bağlantını kontrol edip tekrar dene.'**
  String get setupProvincesLoadError;

  /// No description provided for @setupProvincesRetry.
  ///
  /// In tr, this message translates to:
  /// **'Yeniden dene'**
  String get setupProvincesRetry;

  /// No description provided for @setupAddressRequired.
  ///
  /// In tr, this message translates to:
  /// **'Açık adres zorunludur.'**
  String get setupAddressRequired;

  /// No description provided for @setupProvinceRequired.
  ///
  /// In tr, this message translates to:
  /// **'İl seçimi zorunludur.'**
  String get setupProvinceRequired;

  /// No description provided for @setupDistrictRequired.
  ///
  /// In tr, this message translates to:
  /// **'İlçe seçimi zorunludur.'**
  String get setupDistrictRequired;

  /// No description provided for @accountRoleHeadline.
  ///
  /// In tr, this message translates to:
  /// **'Apartmanına nasıl katılıyorsun?'**
  String get accountRoleHeadline;

  /// No description provided for @accountRoleSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Bunu sonradan da değiştirebilirsin.'**
  String get accountRoleSubtitle;

  /// No description provided for @accountRoleResidentShortTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sakinim'**
  String get accountRoleResidentShortTitle;

  /// No description provided for @accountRoleManagerShortTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yöneticiyim'**
  String get accountRoleManagerShortTitle;

  /// No description provided for @accountRoleResidentShortBody.
  ///
  /// In tr, this message translates to:
  /// **'Yöneticiden aldığın davet kodu ile dairene bağlan.'**
  String get accountRoleResidentShortBody;

  /// No description provided for @accountRoleManagerShortBody.
  ///
  /// In tr, this message translates to:
  /// **'Apartmanını sıfırdan kur, sakinleri davet et.'**
  String get accountRoleManagerShortBody;

  /// No description provided for @residentInvitePlaceholderTitle.
  ///
  /// In tr, this message translates to:
  /// **'Davet kodu'**
  String get residentInvitePlaceholderTitle;

  /// No description provided for @residentInvitePlaceholderBody.
  ///
  /// In tr, this message translates to:
  /// **'Bu akış bir sonraki adımda bağlanacak. Şimdilik yönetici kurulumunu tamamlayabilirsin.'**
  String get residentInvitePlaceholderBody;

  /// No description provided for @residentInviteBackToRole.
  ///
  /// In tr, this message translates to:
  /// **'Hesap türüne dön'**
  String get residentInviteBackToRole;

  /// No description provided for @setupWizardStepProgress.
  ///
  /// In tr, this message translates to:
  /// **'ADIM {step} / {total}'**
  String setupWizardStepProgress(Object step, Object total);

  /// No description provided for @setupWizardStep1AppBar.
  ///
  /// In tr, this message translates to:
  /// **'Bina bilgileri'**
  String get setupWizardStep1AppBar;

  /// No description provided for @setupWizardStep2AppBar.
  ///
  /// In tr, this message translates to:
  /// **'Yapı'**
  String get setupWizardStep2AppBar;

  /// No description provided for @setupWizardStep3AppBar.
  ///
  /// In tr, this message translates to:
  /// **'Daireler'**
  String get setupWizardStep3AppBar;

  /// No description provided for @setupWizardUnitsCountLabel.
  ///
  /// In tr, this message translates to:
  /// **'Daireler · {count} adet'**
  String setupWizardUnitsCountLabel(Object count);

  /// No description provided for @setupWizardStep4AppBar.
  ///
  /// In tr, this message translates to:
  /// **'Aidat planı'**
  String get setupWizardStep4AppBar;

  /// No description provided for @setupWizardSkip.
  ///
  /// In tr, this message translates to:
  /// **'Atla'**
  String get setupWizardSkip;

  /// No description provided for @setupWizardLetsMeetBuilding.
  ///
  /// In tr, this message translates to:
  /// **'Apartmanını tanıyalım'**
  String get setupWizardLetsMeetBuilding;

  /// No description provided for @setupWizardChangeLaterShort.
  ///
  /// In tr, this message translates to:
  /// **'Sonradan ayarlardan değiştirebilirsin.'**
  String get setupWizardChangeLaterShort;

  /// No description provided for @setupYearBuiltOptional.
  ///
  /// In tr, this message translates to:
  /// **'YAPIM YILI (OPS.)'**
  String get setupYearBuiltOptional;

  /// No description provided for @setupYearBuiltHint.
  ///
  /// In tr, this message translates to:
  /// **'Örn. 2008'**
  String get setupYearBuiltHint;

  /// No description provided for @setupAddressHint.
  ///
  /// In tr, this message translates to:
  /// **'Mahalle, sokak, no'**
  String get setupAddressHint;

  /// No description provided for @setupWizardStructureHeadline.
  ///
  /// In tr, this message translates to:
  /// **'Apartmanın yapısı'**
  String get setupWizardStructureHeadline;

  /// No description provided for @setupWizardStructureSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Blok ve kat sayısı — bir sonraki adımda daireler otomatik oluşur.'**
  String get setupWizardStructureSubtitle;

  /// No description provided for @setupBlockCountLabel.
  ///
  /// In tr, this message translates to:
  /// **'Blok sayısı'**
  String get setupBlockCountLabel;

  /// No description provided for @setupSingleBlock.
  ///
  /// In tr, this message translates to:
  /// **'Tek blok'**
  String get setupSingleBlock;

  /// No description provided for @setupMultipleBlocks.
  ///
  /// In tr, this message translates to:
  /// **'Çok blok'**
  String get setupMultipleBlocks;

  /// No description provided for @setupBlockHeading.
  ///
  /// In tr, this message translates to:
  /// **'Blok {block}'**
  String setupBlockHeading(Object block);

  /// No description provided for @setupStructureSummaryTailMulti.
  ///
  /// In tr, this message translates to:
  /// **'oluşturulacak ({floors} kat × {perFloor} daire/blok × {blocks} blok). Sonraki adımda düzenleyebilirsin.'**
  String setupStructureSummaryTailMulti(
    Object floors,
    Object perFloor,
    Object blocks,
  );

  /// No description provided for @setupStructureCountBold.
  ///
  /// In tr, this message translates to:
  /// **'{count} daire'**
  String setupStructureCountBold(Object count);

  /// No description provided for @setupStructureSummaryTail.
  ///
  /// In tr, this message translates to:
  /// **'oluşturulacak ({floors} kat × {perFloor} daire). Sonraki adımda düzenleyebilirsin.'**
  String setupStructureSummaryTail(Object floors, Object perFloor);

  /// No description provided for @setupWizardUnitsInstruction.
  ///
  /// In tr, this message translates to:
  /// **'Otomatik oluşturulan listeyi gözden geçir, gerekirse daire ekle/çıkar.'**
  String get setupWizardUnitsInstruction;

  /// No description provided for @setupWizardUnitsEdit.
  ///
  /// In tr, this message translates to:
  /// **'Düzenle'**
  String get setupWizardUnitsEdit;

  /// No description provided for @setupShowMoreFloorsDetail.
  ///
  /// In tr, this message translates to:
  /// **'+ Daha fazla göster (kat {floors})'**
  String setupShowMoreFloorsDetail(Object floors);

  /// No description provided for @setupWizardCollapseFloors.
  ///
  /// In tr, this message translates to:
  /// **'Daha az göster'**
  String get setupWizardCollapseFloors;

  /// No description provided for @setupNamingAutomatic.
  ///
  /// In tr, this message translates to:
  /// **'Otomatik (1A–6C)'**
  String get setupNamingAutomatic;

  /// No description provided for @setupNamingCustom.
  ///
  /// In tr, this message translates to:
  /// **'Özel adlandır'**
  String get setupNamingCustom;

  /// No description provided for @setupWizardUnitsInstructionCustom.
  ///
  /// In tr, this message translates to:
  /// **'Her daire için görünecek adı yazın. Aynı blokta tekrar eden ad olamaz.'**
  String get setupWizardUnitsInstructionCustom;

  /// No description provided for @setupCustomNameHint.
  ///
  /// In tr, this message translates to:
  /// **'Daire adı'**
  String get setupCustomNameHint;

  /// No description provided for @setupCustomNameEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Tüm daire adları dolu olmalı.'**
  String get setupCustomNameEmpty;

  /// No description provided for @setupCustomNameDuplicate.
  ///
  /// In tr, this message translates to:
  /// **'Aynı blokta aynı daire adı iki kez kullanılamaz.'**
  String get setupCustomNameDuplicate;

  /// No description provided for @setupCustomNameTooLong.
  ///
  /// In tr, this message translates to:
  /// **'Daire adı en fazla 40 karakter olabilir.'**
  String get setupCustomNameTooLong;

  /// No description provided for @setupWizardProceed.
  ///
  /// In tr, this message translates to:
  /// **'İlerle'**
  String get setupWizardProceed;

  /// No description provided for @setupDuesHeadline.
  ///
  /// In tr, this message translates to:
  /// **'Aidat ayarla'**
  String get setupDuesHeadline;

  /// No description provided for @setupDuesSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Sakinlerin görüp ödeyebileceği aylık tutar.'**
  String get setupDuesSubtitle;

  /// No description provided for @setupDueDayLabel.
  ///
  /// In tr, this message translates to:
  /// **'VADE GÜNÜ'**
  String get setupDueDayLabel;

  /// No description provided for @setupDuesMonthlyPerUnitLabel.
  ///
  /// In tr, this message translates to:
  /// **'DAİRE BAŞINA AYLIK'**
  String get setupDuesMonthlyPerUnitLabel;

  /// No description provided for @setupLateFeeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Otomatik gecikme faizi'**
  String get setupLateFeeTitle;

  /// No description provided for @setupLateFeeSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'%2 / ay'**
  String get setupLateFeeSubtitle;

  /// No description provided for @setupSmsReminderTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hatırlatma SMS gönder'**
  String get setupSmsReminderTitle;

  /// No description provided for @setupSmsReminderSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Vade öncesi 3 gün'**
  String get setupSmsReminderSubtitle;

  /// No description provided for @setupTotalMonthlyCollection.
  ///
  /// In tr, this message translates to:
  /// **'Toplam aylık tahsilat'**
  String get setupTotalMonthlyCollection;

  /// No description provided for @setupCompleteWizard.
  ///
  /// In tr, this message translates to:
  /// **'Kurulumu tamamla'**
  String get setupCompleteWizard;

  /// No description provided for @setupPerApartmentSuffix.
  ///
  /// In tr, this message translates to:
  /// **'aylık / daire'**
  String get setupPerApartmentSuffix;

  /// No description provided for @profileSetupDemoResident.
  ///
  /// In tr, this message translates to:
  /// **'Sakin ile devam et'**
  String get profileSetupDemoResident;

  /// No description provided for @profileSetupDemoManager.
  ///
  /// In tr, this message translates to:
  /// **'Yönetici ile devam et'**
  String get profileSetupDemoManager;

  /// No description provided for @adminInviteTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yönetici davet kodu'**
  String get adminInviteTitle;

  /// No description provided for @adminInviteSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Supabase’te oluşturduğun admin (yönetici) davet kodunu gir. Kod doğrulanınca apartman kurulumuna geçersin; tamamlayınca bina ve daireler sunucuya kaydedilir.'**
  String get adminInviteSubtitle;

  /// No description provided for @adminInviteHeadline.
  ///
  /// In tr, this message translates to:
  /// **'Apartman kurulumu'**
  String get adminInviteHeadline;

  /// No description provided for @adminInviteEightCharHint.
  ///
  /// In tr, this message translates to:
  /// **'Yöneticinden veya panelde tanımlı 8 haneli kodu gir.'**
  String get adminInviteEightCharHint;

  /// No description provided for @adminInviteChecking.
  ///
  /// In tr, this message translates to:
  /// **'Kod kontrol ediliyor…'**
  String get adminInviteChecking;

  /// No description provided for @adminInviteVerifiedBadge.
  ///
  /// In tr, this message translates to:
  /// **'KOD DOĞRULANDI'**
  String get adminInviteVerifiedBadge;

  /// No description provided for @adminInviteVerifiedCardTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yönetici kodu hazır'**
  String get adminInviteVerifiedCardTitle;

  /// No description provided for @adminInviteVerifiedCardBody.
  ///
  /// In tr, this message translates to:
  /// **'Bu kod ile apartman kaydına başlayabilirsin. Aşağıdan devam et.'**
  String get adminInviteVerifiedCardBody;

  /// No description provided for @adminInvitePrimaryButton.
  ///
  /// In tr, this message translates to:
  /// **'Apartman kurulumuna geç'**
  String get adminInvitePrimaryButton;

  /// No description provided for @adminInviteResumeHeadline.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar hoş geldiniz'**
  String get adminInviteResumeHeadline;

  /// No description provided for @adminInviteResumeSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Bu apartman kaydını daha önce yapmıştık. Giriş yapalım.'**
  String get adminInviteResumeSubtitle;

  /// No description provided for @adminInviteResumeCardBadge.
  ///
  /// In tr, this message translates to:
  /// **'KAYIT ZATEN VAR'**
  String get adminInviteResumeCardBadge;

  /// No description provided for @adminInviteResumeCardBody.
  ///
  /// In tr, this message translates to:
  /// **'Bu kod ile apartman kurulumu tamamlanmış. Ana sayfadan yönetime devam edebilirsiniz.'**
  String get adminInviteResumeCardBody;

  /// No description provided for @adminInviteResumeSignIn.
  ///
  /// In tr, this message translates to:
  /// **'Giriş yap'**
  String get adminInviteResumeSignIn;

  /// No description provided for @inviteFooterNoCode.
  ///
  /// In tr, this message translates to:
  /// **'Kodum yok'**
  String get inviteFooterNoCode;

  /// No description provided for @inviteFooterScanQr.
  ///
  /// In tr, this message translates to:
  /// **'QR kod tara'**
  String get inviteFooterScanQr;

  /// No description provided for @inviteFooterNoCodeNotice.
  ///
  /// In tr, this message translates to:
  /// **'Yönetici kodunu Supabase veya destek kanalından alman gerekir.'**
  String get inviteFooterNoCodeNotice;

  /// No description provided for @inviteFooterQrSoon.
  ///
  /// In tr, this message translates to:
  /// **'QR ile giriş yakında.'**
  String get inviteFooterQrSoon;

  /// No description provided for @adminInviteCodeLabel.
  ///
  /// In tr, this message translates to:
  /// **'Davet kodu'**
  String get adminInviteCodeLabel;

  /// No description provided for @adminInviteCodeHint.
  ///
  /// In tr, this message translates to:
  /// **'Örn. DOGUS001'**
  String get adminInviteCodeHint;

  /// No description provided for @adminInviteContinue.
  ///
  /// In tr, this message translates to:
  /// **'Devam et'**
  String get adminInviteContinue;

  /// No description provided for @adminInviteCodeTooShort.
  ///
  /// In tr, this message translates to:
  /// **'Kod en az 4 karakter olmalıdır.'**
  String get adminInviteCodeTooShort;

  /// No description provided for @adminInviteCodeNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Kod bulunamadı veya süresi dolmuş.'**
  String get adminInviteCodeNotFound;

  /// No description provided for @adminInviteNotAdminCode.
  ///
  /// In tr, this message translates to:
  /// **'Bu kod yönetici kodu değil. Sakin kodu için başta «Sakinim» seç.'**
  String get adminInviteNotAdminCode;

  /// No description provided for @adminInviteUnexpectedError.
  ///
  /// In tr, this message translates to:
  /// **'Bir sorun oluştu. Lütfen tekrar deneyin.'**
  String get adminInviteUnexpectedError;

  /// No description provided for @setupFinalizeFailed.
  ///
  /// In tr, this message translates to:
  /// **'Kurulum kaydedilemedi. Bağlantını kontrol edip tekrar dene.'**
  String get setupFinalizeFailed;

  /// No description provided for @setupFinalizeBuildingNameRequired.
  ///
  /// In tr, this message translates to:
  /// **'Kurulumu tamamlamak için bina adı gerekli.'**
  String get setupFinalizeBuildingNameRequired;

  /// No description provided for @homeManagerLockedPlaceholder.
  ///
  /// In tr, this message translates to:
  /// **'Özet ve grafik verisi yakında burada olacak.'**
  String get homeManagerLockedPlaceholder;

  /// No description provided for @homeQuickLockedHint.
  ///
  /// In tr, this message translates to:
  /// **'Bu özellik yakında açılacak.'**
  String get homeQuickLockedHint;

  /// No description provided for @managerInviteSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Seçtiğin daire için kalıcı bir davet kodu üretilir; iptal edilene kadar tekrar giriş için kullanılabilir.'**
  String get managerInviteSubtitle;

  /// No description provided for @managerInviteGenerate.
  ///
  /// In tr, this message translates to:
  /// **'Davet kodu oluştur'**
  String get managerInviteGenerate;

  /// No description provided for @managerInviteYourCode.
  ///
  /// In tr, this message translates to:
  /// **'Davet kodu'**
  String get managerInviteYourCode;

  /// No description provided for @managerInviteCopy.
  ///
  /// In tr, this message translates to:
  /// **'Panoya kopyala'**
  String get managerInviteCopy;

  /// No description provided for @managerInviteCopied.
  ///
  /// In tr, this message translates to:
  /// **'Kod panoya kopyalandı.'**
  String get managerInviteCopied;

  /// No description provided for @managerInviteFailed.
  ///
  /// In tr, this message translates to:
  /// **'Kod oluşturulamadı. Oturumu kontrol edip tekrar dene.'**
  String get managerInviteFailed;

  /// No description provided for @managerInviteCodeCreated.
  ///
  /// In tr, this message translates to:
  /// **'Yeni davet kodu hazır.'**
  String get managerInviteCodeCreated;

  /// No description provided for @managerInviteShareHint.
  ///
  /// In tr, this message translates to:
  /// **'Bu kodu sakine güvenli kanaldan ilet; iptal edilene kadar tekrar giriş için kullanılabilir.'**
  String get managerInviteShareHint;

  /// No description provided for @managerInviteDemoBanner.
  ///
  /// In tr, this message translates to:
  /// **'Demo modda kod yerelde üretilir; gerçek davet için DEMO_MODE=false kullan.'**
  String get managerInviteDemoBanner;

  /// No description provided for @managerInviteSelectUnit.
  ///
  /// In tr, this message translates to:
  /// **'Daire'**
  String get managerInviteSelectUnit;

  /// No description provided for @residentInviteScreenTitle.
  ///
  /// In tr, this message translates to:
  /// **'Davet kodun'**
  String get residentInviteScreenTitle;

  /// No description provided for @residentInviteHeadline.
  ///
  /// In tr, this message translates to:
  /// **'Apartmana katıl'**
  String get residentInviteHeadline;

  /// No description provided for @residentInviteJoinHint.
  ///
  /// In tr, this message translates to:
  /// **'Yöneticinin verdiği 5 haneli daire kodunu girin.'**
  String get residentInviteJoinHint;

  /// No description provided for @residentInviteCodeSection.
  ///
  /// In tr, this message translates to:
  /// **'DAVET KODU'**
  String get residentInviteCodeSection;

  /// No description provided for @residentInviteAccountSection.
  ///
  /// In tr, this message translates to:
  /// **'HESABINIZ'**
  String get residentInviteAccountSection;

  /// No description provided for @residentInviteVerifiedBadge.
  ///
  /// In tr, this message translates to:
  /// **'KOD DOĞRULANDI'**
  String get residentInviteVerifiedBadge;

  /// No description provided for @residentInviteCodeLabel.
  ///
  /// In tr, this message translates to:
  /// **'Davet kodu'**
  String get residentInviteCodeLabel;

  /// No description provided for @residentInviteCodeHint.
  ///
  /// In tr, this message translates to:
  /// **'Örn. A3XY2'**
  String get residentInviteCodeHint;

  /// No description provided for @residentInviteFullNameLabel.
  ///
  /// In tr, this message translates to:
  /// **'Ad soyad'**
  String get residentInviteFullNameLabel;

  /// No description provided for @residentInviteSubmit.
  ///
  /// In tr, this message translates to:
  /// **'Apartmana katıl'**
  String get residentInviteSubmit;

  /// No description provided for @residentInviteCodeTooShort.
  ///
  /// In tr, this message translates to:
  /// **'Kod 5 karakter olmalıdır.'**
  String get residentInviteCodeTooShort;

  /// No description provided for @residentInviteNameTooShort.
  ///
  /// In tr, this message translates to:
  /// **'Ad soyad en az 3 karakter olmalıdır.'**
  String get residentInviteNameTooShort;

  /// No description provided for @residentInviteUnexpected.
  ///
  /// In tr, this message translates to:
  /// **'Bir sorun oluştu. Kodu kontrol edip tekrar dene.'**
  String get residentInviteUnexpected;

  /// No description provided for @managerInviteRetry.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar dene'**
  String get managerInviteRetry;

  /// No description provided for @managerInviteSelectedUnitHint.
  ///
  /// In tr, this message translates to:
  /// **'Üretilen kod bu daireye bağlanır; sakine ilettiğinizde bu daireye kayıt olur.'**
  String get managerInviteSelectedUnitHint;

  /// No description provided for @managerInviteNoSessionHint.
  ///
  /// In tr, this message translates to:
  /// **'Oturum bulunamadı. Önce kurulum veya giriş yapın.'**
  String get managerInviteNoSessionHint;

  /// No description provided for @managerInviteNoUnits.
  ///
  /// In tr, this message translates to:
  /// **'Bu bina için kayıtlı daire yok. Apartman kurulumunda daireler oluşturulmalı.'**
  String get managerInviteNoUnits;

  /// No description provided for @managerInviteFilterAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get managerInviteFilterAll;

  /// No description provided for @managerInviteFilterWithCode.
  ///
  /// In tr, this message translates to:
  /// **'Kodu var'**
  String get managerInviteFilterWithCode;

  /// No description provided for @managerInviteFilterWithoutCode.
  ///
  /// In tr, this message translates to:
  /// **'Kodu yok'**
  String get managerInviteFilterWithoutCode;

  /// No description provided for @managerInviteFilterEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Bu filtreye uygun daire yok.'**
  String get managerInviteFilterEmpty;

  /// No description provided for @managerInviteDetailHeadline.
  ///
  /// In tr, this message translates to:
  /// **'Daire {unit} için davet'**
  String managerInviteDetailHeadline(Object unit);

  /// No description provided for @managerInviteDetailSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Yeni sakin bu kodla apartmana ve bu daireye bağlanır.'**
  String get managerInviteDetailSubtitle;

  /// No description provided for @managerInviteDavetCodeCaps.
  ///
  /// In tr, this message translates to:
  /// **'DAVET KODU'**
  String get managerInviteDavetCodeCaps;

  /// No description provided for @managerInviteValidDays.
  ///
  /// In tr, this message translates to:
  /// **'{days} gün geçerli'**
  String managerInviteValidDays(Object days);

  /// No description provided for @managerInviteValidUntilDate.
  ///
  /// In tr, this message translates to:
  /// **'{date} tarihine kadar'**
  String managerInviteValidUntilDate(Object date);

  /// No description provided for @managerInviteGenerateAction.
  ///
  /// In tr, this message translates to:
  /// **'Davet kodu oluştur'**
  String get managerInviteGenerateAction;

  /// No description provided for @managerInviteBulkTitle.
  ///
  /// In tr, this message translates to:
  /// **'Toplu davet gönder'**
  String get managerInviteBulkTitle;

  /// No description provided for @managerInviteBulkSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Boş daireler için tek seferde kod üret (yakında).'**
  String get managerInviteBulkSubtitle;

  /// No description provided for @managerInviteShareBody.
  ///
  /// In tr, this message translates to:
  /// **'Apartmana katılım kodum: {code}'**
  String managerInviteShareBody(Object code);

  /// No description provided for @managerInviteShareWhatsapp.
  ///
  /// In tr, this message translates to:
  /// **'WhatsApp'**
  String get managerInviteShareWhatsapp;

  /// No description provided for @managerInviteShareEmail.
  ///
  /// In tr, this message translates to:
  /// **'E-posta'**
  String get managerInviteShareEmail;

  /// No description provided for @managerInviteShareSms.
  ///
  /// In tr, this message translates to:
  /// **'SMS'**
  String get managerInviteShareSms;

  /// No description provided for @managerInviteShareMore.
  ///
  /// In tr, this message translates to:
  /// **'Daha fazla'**
  String get managerInviteShareMore;

  /// No description provided for @residentInviteScreenBody.
  ///
  /// In tr, this message translates to:
  /// **'Yöneticinin verdiği 5 karakterlik kod hangi daireye tanımlandıysa kayıt o daireye yapılır. «Apartmana katıl» için ad soyadınızı girin.'**
  String get residentInviteScreenBody;

  /// No description provided for @residentInvitePreviewTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kod ile bağlantı'**
  String get residentInvitePreviewTitle;

  /// No description provided for @residentInviteWrongCodeType.
  ///
  /// In tr, this message translates to:
  /// **'Bu bir yönetici davet kodu. Sakin olarak girmek için yöneticiden daire kodu isteyin.'**
  String get residentInviteWrongCodeType;

  /// No description provided for @residentInvitePreviewDemo.
  ///
  /// In tr, this message translates to:
  /// **'Demo modda sunucu doğrulaması yok; gerçek akış için DEMO_MODE kapalı çalıştırın.'**
  String get residentInvitePreviewDemo;

  /// No description provided for @residentInviteResumeHeadline.
  ///
  /// In tr, this message translates to:
  /// **'Kaydınız bulunmaktadır'**
  String get residentInviteResumeHeadline;

  /// No description provided for @residentInviteResumeSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Bu kod ile daha önce kayıt olunmuş. Giriş yaparak devam edebilirsiniz.'**
  String get residentInviteResumeSubtitle;

  /// No description provided for @residentInviteResumeCardBadge.
  ///
  /// In tr, this message translates to:
  /// **'KAYIT MEVCUT'**
  String get residentInviteResumeCardBadge;

  /// No description provided for @residentInviteResumeCardBody.
  ///
  /// In tr, this message translates to:
  /// **'Bu daire kodu daha önce kullanılmış. Aynı apartmana tekrar bağlanırsınız.'**
  String get residentInviteResumeCardBody;

  /// No description provided for @residentInviteResumeSignIn.
  ///
  /// In tr, this message translates to:
  /// **'Giriş yap'**
  String get residentInviteResumeSignIn;

  /// No description provided for @residentInviteChecking.
  ///
  /// In tr, this message translates to:
  /// **'Kod kontrol ediliyor…'**
  String get residentInviteChecking;

  /// No description provided for @homeManagerRolePrefix.
  ///
  /// In tr, this message translates to:
  /// **'YÖNETİCİ'**
  String get homeManagerRolePrefix;

  /// No description provided for @homeManagerBuildingFallback.
  ///
  /// In tr, this message translates to:
  /// **'YÖNETİCİ · Apartman'**
  String get homeManagerBuildingFallback;

  /// No description provided for @residentRolePrefix.
  ///
  /// In tr, this message translates to:
  /// **'SAKİN'**
  String get residentRolePrefix;

  /// No description provided for @demoModuleLockedBody.
  ///
  /// In tr, this message translates to:
  /// **'Gerçek veriler bağlanınca burası açılacak.'**
  String get demoModuleLockedBody;

  /// No description provided for @accountRoleSuperAdminShortTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sistem yöneticisiyim'**
  String get accountRoleSuperAdminShortTitle;

  /// No description provided for @accountRoleSuperAdminShortBody.
  ///
  /// In tr, this message translates to:
  /// **'Tüm apartmanları gör, yönetici ve daire kodları üret.'**
  String get accountRoleSuperAdminShortBody;

  /// No description provided for @demoPersonaSuperAdminTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sistem yöneticisi'**
  String get demoPersonaSuperAdminTitle;

  /// No description provided for @demoPersonaSuperAdminBody.
  ///
  /// In tr, this message translates to:
  /// **'Demo: platform genelinde kod ve bina yönetimi.'**
  String get demoPersonaSuperAdminBody;

  /// No description provided for @superadminAccessTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sistem erişimi'**
  String get superadminAccessTitle;

  /// No description provided for @superadminAccessHeadline.
  ///
  /// In tr, this message translates to:
  /// **'Özel erişim kodun'**
  String get superadminAccessHeadline;

  /// No description provided for @superadminAccessBody.
  ///
  /// In tr, this message translates to:
  /// **'Sunucuda tanımlı süper yönetici kodunu girin. Bu kod uygulamada saklanmaz; yalnızca Edge doğrulaması yapılır.'**
  String get superadminAccessBody;

  /// No description provided for @superadminAccessFieldLabel.
  ///
  /// In tr, this message translates to:
  /// **'ERİŞİM KODU'**
  String get superadminAccessFieldLabel;

  /// No description provided for @superadminAccessContinue.
  ///
  /// In tr, this message translates to:
  /// **'Giriş yap'**
  String get superadminAccessContinue;

  /// No description provided for @superadminAccessCodeTooShort.
  ///
  /// In tr, this message translates to:
  /// **'Kod en az 4 karakter olmalı.'**
  String get superadminAccessCodeTooShort;

  /// No description provided for @superadminAccessWrongRole.
  ///
  /// In tr, this message translates to:
  /// **'Bu kod sistem yöneticisi oturumu vermedi.'**
  String get superadminAccessWrongRole;

  /// No description provided for @superadminAccessUnexpectedError.
  ///
  /// In tr, this message translates to:
  /// **'Giriş yapılamadı. Kodu ve bağlantını kontrol edin.'**
  String get superadminAccessUnexpectedError;

  /// No description provided for @superadminDashboardTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sistem paneli'**
  String get superadminDashboardTitle;

  /// No description provided for @superadminNavHome.
  ///
  /// In tr, this message translates to:
  /// **'Ana sayfa'**
  String get superadminNavHome;

  /// No description provided for @superadminNavManagerCodes.
  ///
  /// In tr, this message translates to:
  /// **'Kodlar'**
  String get superadminNavManagerCodes;

  /// No description provided for @superadminNavBuildings.
  ///
  /// In tr, this message translates to:
  /// **'Apartmanlar'**
  String get superadminNavBuildings;

  /// No description provided for @superadminHomeComingSoon.
  ///
  /// In tr, this message translates to:
  /// **'Bu bölüm geliştiriliyor.'**
  String get superadminHomeComingSoon;

  /// No description provided for @superadminRefresh.
  ///
  /// In tr, this message translates to:
  /// **'Yenile'**
  String get superadminRefresh;

  /// No description provided for @superadminDemoBanner.
  ///
  /// In tr, this message translates to:
  /// **'Demo modda yerel örnek veriler gösterilir.'**
  String get superadminDemoBanner;

  /// No description provided for @superadminDemoSwitch.
  ///
  /// In tr, this message translates to:
  /// **'Demo: rol değiştir'**
  String get superadminDemoSwitch;

  /// No description provided for @superadminSectionManagerCodes.
  ///
  /// In tr, this message translates to:
  /// **'Yönetici davet kodları'**
  String get superadminSectionManagerCodes;

  /// No description provided for @superadminCreateManagerCode.
  ///
  /// In tr, this message translates to:
  /// **'Yeni yönetici kodu oluştur'**
  String get superadminCreateManagerCode;

  /// No description provided for @superadminManagerCodeCreated.
  ///
  /// In tr, this message translates to:
  /// **'Yönetici kodu panoya kopyalandı.'**
  String get superadminManagerCodeCreated;

  /// No description provided for @superadminNoAdminCodesYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz liste için kod yok; yeni kod oluşturabilirsiniz.'**
  String get superadminNoAdminCodesYet;

  /// No description provided for @superadminSectionBuildings.
  ///
  /// In tr, this message translates to:
  /// **'Apartmanlar'**
  String get superadminSectionBuildings;

  /// No description provided for @superadminNoBuildings.
  ///
  /// In tr, this message translates to:
  /// **'Kayıtlı apartman yok.'**
  String get superadminNoBuildings;

  /// No description provided for @superadminCopied.
  ///
  /// In tr, this message translates to:
  /// **'Kopyalandı'**
  String get superadminCopied;

  /// No description provided for @superadminBuildingInviteTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sakin daveti'**
  String get superadminBuildingInviteTitle;

  /// No description provided for @superadminDeleteBuildingTitle.
  ///
  /// In tr, this message translates to:
  /// **'Apartmanı sil'**
  String get superadminDeleteBuildingTitle;

  /// No description provided for @superadminDeleteBuildingBody.
  ///
  /// In tr, this message translates to:
  /// **'Bu apartman ve bağlı tüm kayıtlar (daireler, üyelikler, aidatlar, duyurular vb.) kalıcı olarak silinir. Bu işlem geri alınamaz.'**
  String get superadminDeleteBuildingBody;

  /// No description provided for @superadminDeleteBuildingConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get superadminDeleteBuildingConfirm;

  /// No description provided for @superadminBuildingDeleted.
  ///
  /// In tr, this message translates to:
  /// **'Apartman silindi.'**
  String get superadminBuildingDeleted;

  /// No description provided for @superadminDeleteBuildingFailed.
  ///
  /// In tr, this message translates to:
  /// **'Apartman silinemedi.'**
  String get superadminDeleteBuildingFailed;

  /// No description provided for @superadminAdminCodeMultiBadge.
  ///
  /// In tr, this message translates to:
  /// **'Çoklu kurulum'**
  String get superadminAdminCodeMultiBadge;

  /// No description provided for @superadminAdminCodePolicyHint.
  ///
  /// In tr, this message translates to:
  /// **'Aynı kod süresi dolana kadar farklı cihazlarda veya uygulama yeniden kurulunca tekrar yönetici girişi için kullanılabilir.'**
  String get superadminAdminCodePolicyHint;

  /// No description provided for @superadminAdminCodeStatusActive.
  ///
  /// In tr, this message translates to:
  /// **'Aktif'**
  String get superadminAdminCodeStatusActive;

  /// No description provided for @superadminAdminCodeStatusRevoked.
  ///
  /// In tr, this message translates to:
  /// **'İptal edildi'**
  String get superadminAdminCodeStatusRevoked;

  /// No description provided for @superadminAdminCodeExpires.
  ///
  /// In tr, this message translates to:
  /// **'Son kullanma'**
  String get superadminAdminCodeExpires;

  /// No description provided for @superadminAdminCodeCreated.
  ///
  /// In tr, this message translates to:
  /// **'Oluşturulma'**
  String get superadminAdminCodeCreated;

  /// No description provided for @superadminRevokeAdminCode.
  ///
  /// In tr, this message translates to:
  /// **'Kodu iptal et'**
  String get superadminRevokeAdminCode;

  /// No description provided for @superadminRevokeAdminCodeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yönetici kodunu iptal et'**
  String get superadminRevokeAdminCodeTitle;

  /// No description provided for @superadminRevokeAdminCodeBody.
  ///
  /// In tr, this message translates to:
  /// **'Bu kod artık kullanılamaz. Emin misiniz?'**
  String get superadminRevokeAdminCodeBody;

  /// No description provided for @superadminRevokeAdminCodeConfirm.
  ///
  /// In tr, this message translates to:
  /// **'İptal et'**
  String get superadminRevokeAdminCodeConfirm;

  /// No description provided for @superadminCodeRevoked.
  ///
  /// In tr, this message translates to:
  /// **'Kod iptal edildi.'**
  String get superadminCodeRevoked;

  /// No description provided for @inviteCodeNotesCreate.
  ///
  /// In tr, this message translates to:
  /// **'Oluştur'**
  String get inviteCodeNotesCreate;

  /// No description provided for @inviteCodeNotesAdminTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yönetici kodu notu'**
  String get inviteCodeNotesAdminTitle;

  /// No description provided for @inviteCodeNotesAdminHint.
  ///
  /// In tr, this message translates to:
  /// **'İsteğe bağlı: hangi yönetici veya apartman için (ör. Ahmet Bey – Site A)'**
  String get inviteCodeNotesAdminHint;

  /// No description provided for @inviteCodeNotesUnitTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sakin / daire notu'**
  String get inviteCodeNotesUnitTitle;

  /// No description provided for @inviteCodeNotesUnitHint.
  ///
  /// In tr, this message translates to:
  /// **'İsteğe bağlı: sakin veya daire hakkında (ör. 6A – Yeni kiracı)'**
  String get inviteCodeNotesUnitHint;

  /// No description provided for @inviteCodeNotesLabel.
  ///
  /// In tr, this message translates to:
  /// **'Not'**
  String get inviteCodeNotesLabel;

  /// No description provided for @managerInviteRevokeAction.
  ///
  /// In tr, this message translates to:
  /// **'Kodu iptal et'**
  String get managerInviteRevokeAction;

  /// No description provided for @managerInviteRevokeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Davet kodunu iptal et'**
  String get managerInviteRevokeTitle;

  /// No description provided for @managerInviteRevokeBody.
  ///
  /// In tr, this message translates to:
  /// **'Bu kod artık giriş için kullanılamaz. Yeni kod oluşturabilirsiniz.'**
  String get managerInviteRevokeBody;

  /// No description provided for @managerInviteRevokeConfirm.
  ///
  /// In tr, this message translates to:
  /// **'İptal et'**
  String get managerInviteRevokeConfirm;

  /// No description provided for @managerInviteRevoked.
  ///
  /// In tr, this message translates to:
  /// **'Davet kodu iptal edildi.'**
  String get managerInviteRevoked;

  /// No description provided for @managerInviteActiveUntilRevoked.
  ///
  /// In tr, this message translates to:
  /// **'İptal edilene kadar geçerli'**
  String get managerInviteActiveUntilRevoked;

  /// No description provided for @managerUnitJoinedViaCode.
  ///
  /// In tr, this message translates to:
  /// **'Kod ile katıldı'**
  String get managerUnitJoinedViaCode;

  /// No description provided for @settingsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settingsTitle;

  /// No description provided for @settingsSectionAppearance.
  ///
  /// In tr, this message translates to:
  /// **'Görünüm'**
  String get settingsSectionAppearance;

  /// No description provided for @settingsThemeLabel.
  ///
  /// In tr, this message translates to:
  /// **'Tema'**
  String get settingsThemeLabel;

  /// No description provided for @settingsThemeLight.
  ///
  /// In tr, this message translates to:
  /// **'Açık'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeLightHint.
  ///
  /// In tr, this message translates to:
  /// **'Açık renkli arayüz'**
  String get settingsThemeLightHint;

  /// No description provided for @settingsThemeDark.
  ///
  /// In tr, this message translates to:
  /// **'Koyu'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeDarkHint.
  ///
  /// In tr, this message translates to:
  /// **'Koyu renkli arayüz'**
  String get settingsThemeDarkHint;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In tr, this message translates to:
  /// **'Sistem'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeSystemHint.
  ///
  /// In tr, this message translates to:
  /// **'Cihaz ayarını kullan'**
  String get settingsThemeSystemHint;

  /// No description provided for @settingsSectionLanguage.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get settingsSectionLanguage;

  /// No description provided for @settingsLanguageTurkish.
  ///
  /// In tr, this message translates to:
  /// **'Türkçe'**
  String get settingsLanguageTurkish;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In tr, this message translates to:
  /// **'İngilizce'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsApplyHint.
  ///
  /// In tr, this message translates to:
  /// **'Dil ve tema tercihleriniz kaydedilir.'**
  String get settingsApplyHint;

  /// No description provided for @settingsLoadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar yüklenemedi.'**
  String get settingsLoadFailed;
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
