// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'AptKeeper';

  @override
  String get splashTagline => 'Apartman ve site yönetimi';

  @override
  String get emailEntryTitle => 'Giriş yap';

  @override
  String get emailLoginHeadline => 'E-posta adresin';

  @override
  String get emailLoginSubtitle => 'Sana tek kullanımlık bir kod göndereceğiz.';

  @override
  String get emailFieldLabel => 'E-POSTA';

  @override
  String get kvkkEmailNotice =>
      'KVKK uyumluyuz. E-posta sadece giriş için kullanılır.';

  @override
  String get loginLegalPrefix => 'Devam ederek ';

  @override
  String get loginLegalTerms => 'Kullanım Şartları';

  @override
  String get loginLegalMiddle => ' ve ';

  @override
  String get loginLegalPrivacy => 'Gizlilik Politikası';

  @override
  String get loginLegalSuffix => '\'nı kabul ediyorsun.';

  @override
  String get legalLinkPlaceholder => 'Bu içerik yakında eklenecek.';

  @override
  String get emailHint => 'E-posta adresi';

  @override
  String get continueButton => 'Devam et';

  @override
  String get otpAppBarTitle => 'Doğrulama';

  @override
  String get otpHeadline => 'Kodu gir';

  @override
  String otpSentParagraph(Object identifier) {
    return '$identifier adresine 6 haneli kod gönderdik.';
  }

  @override
  String get otpResendPrompt => 'Kodu almadın mı?';

  @override
  String otpResendLineCooldown(Object time) {
    return 'Kodu almadın mı? Yeniden gönder ($time)';
  }

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
  String get profileSetupTitle => 'Profil oluştur';

  @override
  String get profileHeadline => 'Seni nasıl tanıtalım?';

  @override
  String get profileSubtitle => 'Komşuların ve yöneticin bu ismi görür.';

  @override
  String get profileAvatarTitle => 'Avatar';

  @override
  String get profileAvatarSubtitle => 'İleride ekleyebilirsin';

  @override
  String get fullNameFieldLabel => 'AD SOYAD';

  @override
  String get fullNameHint => 'Ad Soyad';

  @override
  String get phoneFieldLabel => 'TELEFON (OPSİYONEL)';

  @override
  String get phoneHint => '+90 5__ ___ __ __';

  @override
  String get saveButton => 'Kaydet';

  @override
  String welcomeMessage(Object fullName) {
    return 'Hoş geldin $fullName';
  }

  @override
  String get signOut => 'Çıkış yap';

  @override
  String get rememberMeLabel => 'Beni hatırla';

  @override
  String get rememberMeHint => 'Uygulamayı her açtığımda oturumum açık kalsın';

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

  @override
  String get demoHubTitle => 'Demo — Ekran kataloğu';

  @override
  String get demoHubSubtitle =>
      'HTML mockup ve analiz raporuna göre tüm ekranlar. Veriler örnektir.';

  @override
  String get demoBadge => 'DEMO';

  @override
  String get demoBackToHub => 'Kataloga dön';

  @override
  String get demoSectionAuth => '1 · Giriş ve tanıtım';

  @override
  String get demoSectionHome => '2 · Ana sayfalar';

  @override
  String get demoSectionSetup => '3 · Bina kurulumu';

  @override
  String get demoSectionResident => '4 · Sakin (aidat, duyuru, profil)';

  @override
  String get demoSectionIssues => '5 · Arızalar';

  @override
  String get demoSectionAdmin => '6 · Yönetici';

  @override
  String get demoSectionReports => '7 · Raporlar';

  @override
  String get demoSectionDocs => '8 · Belge ve oylama';

  @override
  String get demoSectionSubscription => '9 · Abonelik ve ayarlar';

  @override
  String get demoTileSplashPreview => '1.1 Splash';

  @override
  String get demoTileWelcome => '1.2 Tanıtım (onboarding)';

  @override
  String get demoTileLoginReal => '1.3 Gerçek giriş ekranı';

  @override
  String get demoTileOtpReal => '1.4 OTP doğrulama';

  @override
  String get demoTileProfileReal => '1.5 Profil oluşturma';

  @override
  String get demoTileResidentHome => '2.1 Sakin ana sayfa';

  @override
  String get demoTileAdminHome => '2.2 Yönetici ana sayfa';

  @override
  String get demoTileRoleSelect => '3.1 Rol seçimi';

  @override
  String get demoTileInviteCode => '3.2 Davet kodu';

  @override
  String get demoTileSetupBuilding => '3.3 Kurulum · Bina';

  @override
  String get demoTileSetupStructure => '3.4 Kurulum · Yapı';

  @override
  String get demoTileSetupUnits => '3.5 Kurulum · Daireler';

  @override
  String get demoTileSetupDues => '3.6 Kurulum · Aidat';

  @override
  String get demoTileDuesHistory => '4.1 Aidat geçmişi';

  @override
  String get demoTileDuesDetail => '4.2 Aidat detay';

  @override
  String get demoTilePaymentCheckout => '4.3 Ödeme (iyzico)';

  @override
  String get demoTilePaymentSuccess => '4.4 Ödeme başarılı';

  @override
  String get demoTileAnnouncements => '4.5 Duyuru akışı';

  @override
  String get demoTileAnnouncementDetail => '4.6 Duyuru detay';

  @override
  String get demoTileProfileResident => '4.7 Profil';

  @override
  String get demoTileIssuesList => '5.1 Arıza listesi';

  @override
  String get demoTileIssueNew => '5.2 Yeni arıza';

  @override
  String get demoTileIssueDetail => '5.3 Arıza detay';

  @override
  String get demoTileIssuesKanban => '5.4 Yönetici kanban';

  @override
  String get demoTileUnitsGrid => '6.1 Daireler';

  @override
  String get demoTileInviteResidents => '6.2 Sakin daveti';

  @override
  String get demoTilePeriods => '6.3 Dönemler';

  @override
  String get demoTileExpenseNew => '6.4 Yeni gider';

  @override
  String get demoTileReportsOverview => '7.1 Mali özet raporu';

  @override
  String get demoTileDocuments => '8.1 Belgeler';

  @override
  String get demoTilePolls => '8.2 Oylamalar';

  @override
  String get demoTileSubscription => '9.1 Abonelik';

  @override
  String get demoTileBuildingSettings => '9.2 Bina ayarları';

  @override
  String get demoSplashTagline => 'Apartman ve site yönetimi';

  @override
  String get demoWelcomeSlide1Title => 'Apartmanını yönet, sakinler haberdar';

  @override
  String get demoWelcomeSlide1Body =>
      'Aidat takibi, duyurular, arıza bildirim ve oylamalar — hepsi tek bir uygulamada.';

  @override
  String get demoWelcomeSlide2Title => 'Aidat ve ödemeler şeffaf';

  @override
  String get demoWelcomeSlide2Body =>
      'Borç durumunu anında gör, ödemeni güvenle tamamla.';

  @override
  String get demoWelcomeSlide3Title => 'Topluluk tek yerde';

  @override
  String get demoWelcomeSlide3Body =>
      'Duyurular, belgeler ve oylamalarla komşularınla bağlantıda kal.';

  @override
  String get demoSkip => 'Atla';

  @override
  String get demoBuildingHeaderLine => 'YEŞİL VADİ APT. · 3A';

  @override
  String get residentBuildingHeaderFallback => 'SAKİN · Apartman';

  @override
  String demoHelloName(Object name) {
    return 'Merhaba $name 👋';
  }

  @override
  String get demoOpenDebt => 'AÇIK BORÇ';

  @override
  String demoDueLabel(Object date, Object status) {
    return 'Vade: $date · $status';
  }

  @override
  String get demoPayNow => 'Şimdi öde';

  @override
  String get demoAnnouncementsSection => 'Duyurular';

  @override
  String get demoIssuesSection => 'Arızalar';

  @override
  String get demoPinAnnouncement => 'Sabitlenmiş';

  @override
  String get demoAnnouncementSampleTitle => 'Asansör bakımı yarın 10:00–12:00';

  @override
  String get demoAnnouncementSampleMeta => 'Yönetim · 124 görüntüleme';

  @override
  String get demoIssueSampleTitle => 'Çatı sızdırması — merdiven sonu';

  @override
  String get demoIssueSampleMeta => 'Açık · Yüksek öncelik';

  @override
  String get demoNavHome => 'Ana sayfa';

  @override
  String get demoNavAnnouncements => 'Duyuru';

  @override
  String get demoNavFinance => 'Aidat';

  @override
  String get demoNavIssues => 'Arıza';

  @override
  String get demoNavProfile => 'Profil';

  @override
  String get demoAdminSummaryTitle => 'Bu ay özeti';

  @override
  String get demoCollected => 'Tahsil edilen';

  @override
  String get demoExpected => 'Beklenen';

  @override
  String get demoExpenseTotal => 'Gider';

  @override
  String get demoQuickActions => 'Hızlı işlemler';

  @override
  String get demoActionInvite => 'Davet kodu';

  @override
  String get demoActionExpense => 'Yeni gider';

  @override
  String get demoActionIssues => 'Arızalar';

  @override
  String get demoChartPlaceholder => 'Tahsilat grafiği (demo)';

  @override
  String get demoRoleTitle => 'Nasıl devam edelim?';

  @override
  String get demoRoleSubtitle =>
      'Sakin davet koduyla katılır; yönetici yeni bina kurulumunu başlatır.';

  @override
  String get demoRoleResident => 'Sakin — davet kodum var';

  @override
  String get demoRoleAdmin => 'Yönetici — bina oluştur';

  @override
  String get demoInviteTitle => 'Davet kodu';

  @override
  String get demoInviteSubtitle =>
      '8 haneli kodu girin; doğrulayınca apartman önizlemesi gösterilir.';

  @override
  String get demoInviteHint => 'KOD';

  @override
  String get demoInviteVerify => 'Doğrula ve katıl';

  @override
  String get demoInvitePreviewTitle => 'Yeşil Vadi Apartmanı';

  @override
  String get demoInvitePreviewSubtitle => 'Üsküdar · İstanbul';

  @override
  String get demoSetupBuildingTitle => 'Bina bilgileri';

  @override
  String get demoSetupBuildingName => 'Apartman adı';

  @override
  String get demoSetupAddress => 'Açık adres';

  @override
  String get demoSetupCity => 'İl / ilçe';

  @override
  String demoSetupStep(Object current, Object total) {
    return 'Adım $current / $total';
  }

  @override
  String get demoSetupStructureTitle => 'Yapı';

  @override
  String get demoSetupFloors => 'Kat sayısı';

  @override
  String get demoSetupUnitsPerFloor => 'Kat başı daire';

  @override
  String demoSetupUnitsPreview(Object count) {
    return 'Önizleme: ~$count daire';
  }

  @override
  String get demoSetupUnitsTitle => 'Daireler';

  @override
  String get demoSetupNamingAuto => 'Otomatik adlandırma';

  @override
  String get demoSetupDuesTitle => 'Aidat şablonu';

  @override
  String get demoSetupDuesAmount => 'Aylık tutar';

  @override
  String get demoSetupDueDay => 'Vade günü';

  @override
  String get demoSetupSmsReminder => 'SMS hatırlatma';

  @override
  String get demoSetupLateFee => 'Gecikme uyarısı';

  @override
  String get demoFilterAll => 'Tümü';

  @override
  String get demoFilterPaid => 'Ödendi';

  @override
  String get demoFilterDebt => 'Borçlu';

  @override
  String get demoMonthMarch2026 => 'Mart 2026';

  @override
  String get demoMonthFebruary2026 => 'Şubat 2026';

  @override
  String get demoDuesDetailTitle => 'Aidat detayı';

  @override
  String get demoBreakdownBase => 'Aidat tutarı';

  @override
  String get demoBreakdownLate => 'Gecikme';

  @override
  String demoInvoiceRef(Object ref) {
    return 'Fatura no: $ref';
  }

  @override
  String get demoPaymentTitle => 'Ödeme';

  @override
  String get demoPaymentSavedCard => 'Kayıtlı kart';

  @override
  String get demoPaymentCvv => 'CVV';

  @override
  String get demoPaymentSecure => '3D Secure ile güvenli ödeme';

  @override
  String get demoPaymentSubmit => 'Ödemeyi tamamla';

  @override
  String get demoPaymentSuccessTitle => 'Ödeme alındı';

  @override
  String get demoPaymentSuccessBody =>
      'İşlem başarıyla tamamlandı. Makbuzu indirebilirsiniz.';

  @override
  String get demoDownloadReceipt => 'Makbuzu indir';

  @override
  String get demoAnnouncementDetailHint => 'Yorum yazın…';

  @override
  String get demoAnnouncementSampleBody =>
      'Elektrik kesintisi olabileceğinden asansör kullanımında dikkatli olun.';

  @override
  String get demoAttachmentPdf => 'toplanti_notlari.pdf';

  @override
  String get demoProfileBuildingCard => 'Apartman kartı';

  @override
  String get demoProfileSettings => 'Ayarlar';

  @override
  String get demoProfileNotifications => 'Bildirimler';

  @override
  String get demoProfilePrivacy => 'Gizlilik ve KVKK';

  @override
  String get demoIssueCategory => 'Kategori';

  @override
  String get demoIssueLocation => 'Konum';

  @override
  String get demoIssuePriority => 'Öncelik';

  @override
  String get demoIssueAddPhoto => 'Fotoğraf ekle';

  @override
  String get demoIssueSubmit => 'Arızayı bildir';

  @override
  String get demoIssueTimelineLogged => 'Kayıt oluşturuldu';

  @override
  String get demoIssueTimelineAssigned => 'Teknik ekibe atandı';

  @override
  String get demoIssueAdminNote =>
      'Yönetici notu: Yarın sabah kontrol edilecek.';

  @override
  String get demoKanbanOpen => 'Açık';

  @override
  String get demoKanbanProgress => 'İşlemde';

  @override
  String get demoKanbanDone => 'Tamamlandı';

  @override
  String demoUnitsFloor(Object floor) {
    return '$floor. kat';
  }

  @override
  String demoUnitDebt(Object amount) {
    return 'Borç $amount';
  }

  @override
  String get demoUnitPaid => 'Ödendi';

  @override
  String get demoUnitEmpty => 'Boş';

  @override
  String get demoInviteQrHelp => 'QR kodu paylaş veya kodu kopyala.';

  @override
  String get demoInviteShare => 'Daveti paylaş';

  @override
  String get demoInviteBulk => 'Toplu davet (CSV)';

  @override
  String get demoPeriodActive => 'Aktif dönem';

  @override
  String get demoPeriodCollectionRate => 'Tahsilat oranı';

  @override
  String get demoExpenseNotifyResidents => 'Sakinlere bildir';

  @override
  String get demoExpenseSave => 'Gideri kaydet';

  @override
  String get demoExpenseCategoryWater => 'Su';

  @override
  String get demoExpenseCategoryElectric => 'Elektrik';

  @override
  String get demoExpenseCategoryElevator => 'Asansör';

  @override
  String get demoExpenseCategoryOther => 'Diğer';

  @override
  String get demoReportsTitle => 'Raporlar';

  @override
  String get demoReportsCashflow => 'Nakit akışı';

  @override
  String get demoReportsExpenseSplit => 'Gider dağılımı';

  @override
  String get demoDocumentsTitle => 'Belgeler';

  @override
  String get demoDocumentsFolderMeeting => 'Toplantı';

  @override
  String get demoDocumentsFolderContracts => 'Sözleşmeler';

  @override
  String get demoPollsTitle => 'Oylamalar';

  @override
  String get demoPollsActive => 'Devam eden';

  @override
  String get demoPollsClosed => 'Tamamlanan';

  @override
  String get demoPollSampleTitle => 'Çatı yenileme önerisi';

  @override
  String get demoSubscriptionTitle => 'Abonelik';

  @override
  String get demoSubscriptionPlan => 'Profesyonel plan';

  @override
  String get demoSubscriptionPrice => '₺299 / ay · bir bina';

  @override
  String get demoSubscriptionCta => 'Planı seç';

  @override
  String get demoSettingsTitle => 'Bina ayarları';

  @override
  String get demoSettingsDues => 'Aidat kuralları';

  @override
  String get demoSettingsRoles => 'Yönetici rolleri';

  @override
  String get demoLegendPaid => 'Ödendi';

  @override
  String get demoLegendDebt => 'Borçlu';

  @override
  String get demoLegendVacant => 'Boş';

  @override
  String get demoSampleDelay => '3 gün gecikti';

  @override
  String get demoSampleDateShort => '5 Mart 2026';

  @override
  String get demoPriorityHigh => 'Yüksek öncelik';

  @override
  String get homeRecentAnnouncements => 'Son duyurular';

  @override
  String get homeSeeAll => 'Tümü';

  @override
  String get homeAnnouncementTagPin => 'PIN';

  @override
  String get homeAnnouncementTagInfo => 'Bilgi';

  @override
  String get homeOpenIssuesSection => 'Açık arızalar';

  @override
  String get homeIssueStatusInProgress => 'İşlemde';

  @override
  String homeIssueUpdatedAgo(Object time) {
    return '$time önce güncellendi';
  }

  @override
  String get homeManagerBuildingLine => 'YÖNETİCİ · YEŞİL VADİ APT.';

  @override
  String get homeManagerMonthYear => 'Mart 2026';

  @override
  String get homeManagerCollectionLabel => 'TAHSİLAT';

  @override
  String get homeManagerIncomeLabel => 'BU AY GELİR';

  @override
  String get homeManagerOpenDebtLabel => 'AÇIK BORÇ';

  @override
  String get homeManagerOpenIssuesLabel => 'AÇIK ARIZA';

  @override
  String homeManagerUnitsSuffix(Object count) {
    return '$count daire';
  }

  @override
  String homeManagerHighPrioritySuffix(Object count) {
    return '$count yüksek öncelik';
  }

  @override
  String homeManagerIncomeDelta(Object percent) {
    return '↑ $percent önceki ay';
  }

  @override
  String get homeIssueStatsTitle => 'Arıza özeti';

  @override
  String get homeIssueStatsOpened => 'Açılan';

  @override
  String get homeIssueStatsResolved => 'Çözülen';

  @override
  String get homeIssueStatsPending => 'Bekleyen';

  @override
  String get homeIssueStatsPrevMonth => 'Önceki ay';

  @override
  String get homeIssueStatsNextMonth => 'Sonraki ay';

  @override
  String get homeChartSixMonths => 'Son 6 ay · Gelir / Gider';

  @override
  String get homeChartLegendIncome => 'Gelir';

  @override
  String get homeChartLegendExpense => 'Gider';

  @override
  String get homeQuickNewPeriod => 'Yeni dönem';

  @override
  String get homeQuickSendAnnouncement => 'Duyuru gönder';

  @override
  String get homeQuickSendInvite => 'Davet gönder';

  @override
  String get homeQuickAddExpense => 'Gider ekle';

  @override
  String get homeQuickActionsSection => 'HIZLI AKSİYONLAR';

  @override
  String get homeDemoSwitchManager => 'Yönetici görünümü';

  @override
  String get homeDemoSwitchResident => 'Sakin görünümü';

  @override
  String get homeEmptyNoRecords => 'Henüz kayıt yok.';

  @override
  String get homeNoOutstandingDebt => 'Açık borcunuz yok.';

  @override
  String get homeAidatSectionTitle => 'Aidat özeti';

  @override
  String get homeDemoDuesMarchTitle => 'Mart 2026 aidatı';

  @override
  String get homeDemoDuesMarchSubtitle => 'Son ödeme tarihi geçti';

  @override
  String get homeDemoDuesFebTitle => 'Şubat 2026 aidatı';

  @override
  String get homeDemoDuesFebSubtitle => 'Ödendi · 28 Şubat 2026';

  @override
  String get homeDemoElevatorAnnouncementTitle => 'Asansör bakımı · 12 Mart';

  @override
  String get homeDemoElevatorAnnouncementAuthor => 'Ayşe Demir';

  @override
  String get homeDemoHotWaterTitle => 'Sıcak su kesintisi 14:00–16:00';

  @override
  String get homeDemoHotWaterAuthor => 'Ali Kaya';

  @override
  String get homeDemoRoofLeakTitle => 'Çatı su sızıntısı';

  @override
  String get homeDemoIssueUpdatedHours => '2 saat';

  @override
  String homeNotificationsBadge(Object count) {
    return '$count bildirim';
  }

  @override
  String get homeFeatureSoon => 'Bu bölüm yakında.';

  @override
  String get demoPersonaScreenTitle => 'Hesap türü';

  @override
  String get demoPersonaScreenSubtitle =>
      'Apartmanına nasıl katılıyorsun? Bunu demo içinde istediğin zaman profilden değiştirebilirsin.';

  @override
  String get demoPersonaResidentTitle => 'Sakin olarak devam et';

  @override
  String get demoPersonaResidentBody =>
      'Yöneticinden aldığın davet kodu ile dairene bağlan.';

  @override
  String get demoPersonaManagerTitle => 'Yönetici olarak devam et';

  @override
  String get demoPersonaManagerBody =>
      'Apartmanını sıfırdan kur, sakinleri davet et.';

  @override
  String get demoPersonaTrialBanner =>
      'İlk 30 gün ücretsiz. Kart bilgisi gerekmez.';

  @override
  String get catalogEmptyTitle => 'Henüz kayıt yok';

  @override
  String get catalogLoadError => 'Veriler yüklenemedi';

  @override
  String get duesMyTitle => 'Aidatlarım';

  @override
  String get duesOpenDebt => 'AÇIK BORÇ';

  @override
  String duesUnpaidSummary(Object unpaid, Object late) {
    return '$unpaid ödenmemiş · $late';
  }

  @override
  String get duesFilterAll => 'Tümü';

  @override
  String get duesFilterOpen => 'Açık';

  @override
  String get duesFilterPaid => 'Ödendi';

  @override
  String get duesFilterLate => 'Gecikmiş';

  @override
  String get duesPayNow => 'Şimdi öde';

  @override
  String get duesDetailTitle => 'Aidat detayı';

  @override
  String get duesAmountDue => 'ÖDENECEK TUTAR';

  @override
  String get duesLineBase => 'Aidat';

  @override
  String duesLineLateFee(Object days) {
    return 'Gecikme faizi ($days gün)';
  }

  @override
  String duesPayCta(Object amount) {
    return '$amount öde';
  }

  @override
  String get paymentTitle => 'Ödeme';

  @override
  String get paymentSecurePay => 'Güvenli öde';

  @override
  String get paymentSuccessTitle => 'Ödeme başarılı';

  @override
  String get paymentSuccessBody =>
      'Aidatın ödendi. Makbuzu e-posta ile gönderdik.';

  @override
  String get announcementsTitle => 'Duyurular';

  @override
  String get announcementDetailTitle => 'Duyuru';

  @override
  String announcementsChipAll(Object count) {
    return 'Tümü · $count';
  }

  @override
  String announcementsChipPinned(Object count) {
    return '📌 Sabit · $count';
  }

  @override
  String get announcementsChipUrgent => '⚠️ Acil';

  @override
  String get announcementsChipInfo => 'Bilgi';

  @override
  String get announcementsChipMaintenance => 'Bakım';

  @override
  String get announcementsReadLabel => 'Okundu';

  @override
  String announcementCommentPlaceholder(Object count) {
    return 'Yorum yaz... ($count yorum)';
  }

  @override
  String get announcementDetailTagPinnedMaintenance => '⭐ SABİT · BAKIM';

  @override
  String get announcementDownloadComingSoon => 'İndirme yakında';

  @override
  String announcementViewsFallback(Object count) {
    return '$count görüntülenme';
  }

  @override
  String get issuesTitle => 'Arızalar';

  @override
  String get issueNewTitle => 'Yeni arıza';

  @override
  String get issueDetailTitle => 'Arıza detayı';

  @override
  String get issueSubmit => 'Bildirimi gönder';

  @override
  String get issuesKanbanTitle => 'Arıza panosu';

  @override
  String issuesChipAll(Object count) {
    return 'Tümü · $count';
  }

  @override
  String issuesChipOpen(Object count) {
    return 'Açık · $count';
  }

  @override
  String issuesChipInProgress(Object count) {
    return 'İşlemde · $count';
  }

  @override
  String issuesChipResolved(Object count) {
    return 'Çözüldü · $count';
  }

  @override
  String get issuesBadgeOpen => 'Açık';

  @override
  String get issuesBadgeInProgress => 'İşlemde';

  @override
  String get issuesBadgeResolved => 'Çözüldü';

  @override
  String get issuesFooterOwnReport => 'Senin bildirim';

  @override
  String issuesFooterTracking(Object name) {
    return '$name takipte';
  }

  @override
  String get profileMenuTitle => 'Profil';

  @override
  String get profileSwitchToManager => 'Yönetici görünümüne geç';

  @override
  String get profileSwitchToResident => 'Sakin görünümüne geç';

  @override
  String get setupInviteTitle => 'Davet kodu';

  @override
  String get setupInviteJoin => 'Apartmana katıl';

  @override
  String get setupWizardTitle => 'Bina kurulumu';

  @override
  String get setupWizardStepUnitsPlaceholder => 'Daireler · özet';

  @override
  String get setupWizardStepDuesPlaceholder => 'Aidat planı';

  @override
  String get managerUnitsTitle => 'Daireler';

  @override
  String managerFloorHeading(Object floor) {
    return 'KAT $floor';
  }

  @override
  String managerFloorUnitCount(Object count) {
    return '$count daire';
  }

  @override
  String get managerInviteTitle => 'Sakin daveti';

  @override
  String get managerPeriodsTitle => 'Aidat dönemleri';

  @override
  String get managerExpenseTitle => 'Yeni gider';

  @override
  String get commonClose => 'Kapat';

  @override
  String get duesDetailApartmentTitle => 'Daire';

  @override
  String get duesDetailApartmentValue => '3A · Mehmet Yılmaz';

  @override
  String get duesDetailPeriodTitle => 'Dönem';

  @override
  String get duesDetailDueTitle => 'Vade';

  @override
  String get duesDetailInvoiceTitle => 'Fatura no';

  @override
  String get payment3dInfo =>
      '3D Secure ile güvenli ödeme. SMS doğrulama gelecek.';

  @override
  String get paymentNewCard => 'Yeni kart ekle';

  @override
  String paymentTotal(Object amount) {
    return 'Toplam $amount';
  }

  @override
  String get paymentReceiptAmountLabel => 'TUTAR';

  @override
  String get paymentReceiptPeriodLabel => 'DÖNEM';

  @override
  String get paymentReceiptTxnLabel => 'İŞLEM NO';

  @override
  String get paymentReceiptMethodLabel => 'YÖNTEM';

  @override
  String get paymentReceiptAmountValue => '₺1.530,00';

  @override
  String get paymentReceiptPeriodValue => 'Mart 2026 · 3A';

  @override
  String get paymentReceiptTxnValue => 'İZ-9F4A2-26';

  @override
  String get paymentReceiptMethodValue => 'VISA **** 4729';

  @override
  String get announcementCatPinned => 'SABİT';

  @override
  String get announcementCatMaintenance => 'Bakım';

  @override
  String get announcementCatUrgent => 'Acil';

  @override
  String get profileBadgeResident => 'Sakin';

  @override
  String get profileBadgeManager => 'Yönetici';

  @override
  String get profileBadgeSuperAdmin => 'Sistem yöneticisi';

  @override
  String get profileCardSubtitleManager =>
      'Bu cihaz apartman yönetimi için bağlı.';

  @override
  String get profileCardSubtitleResident =>
      'Bu cihaz davet kodu ile bir daireye bağlı.';

  @override
  String get profileCardNoBuildingTitle => 'Apartman bilgisi yok';

  @override
  String get profileCardNoBuildingBody =>
      'Kurulum veya davet tamamlanınca burada görünür.';

  @override
  String get profileCardFetchingBuildingTitle =>
      'Apartman bilgisi getiriliyor…';

  @override
  String get profileCardFetchingBuildingBody =>
      'Sunucudan apartman adı alınıyor.';

  @override
  String get profileDemoCardTitle => 'Demo ortamı';

  @override
  String get profileDemoCardSubtitle =>
      'Gerçek apartman verisi için DEMO_MODE kapalı çalıştırın.';

  @override
  String get profileSectionAccount => 'HESAP';

  @override
  String get profileSectionSupport => 'DESTEK';

  @override
  String get profileMenuProfileInfo => 'Profil bilgileri';

  @override
  String get profileMenuNotifications => 'Bildirim ayarları';

  @override
  String get profileMenuSavedCards => 'Kayıtlı kartlar';

  @override
  String get profileMenuHelpCenter => 'Yardım merkezi';

  @override
  String get profileVersionFooter => 'Sürüm 1.0.0 · KVKK';

  @override
  String get issueFieldTitle => 'Başlık';

  @override
  String get issueFieldDescription => 'Açıklama';

  @override
  String get issueCreateAppBarTitle => 'Yeni arıza bildirimi';

  @override
  String get issueCategorySection => 'KATEGORİ';

  @override
  String get issueCategoryWater => 'Su';

  @override
  String get issueCategoryElectric => 'Elektrik';

  @override
  String get issueCategoryMechanical => 'Mekanik';

  @override
  String get issueCategoryOther => 'Diğer';

  @override
  String get issueLocationSection => 'KONUM';

  @override
  String get issueLocationApartment => 'Daire içi';

  @override
  String get issueLocationParking => 'Otopark';

  @override
  String get issueLocationRoof => 'Çatı';

  @override
  String get issueLocationGarden => 'Bahçe';

  @override
  String get issueLocationElevator => 'Asansör';

  @override
  String get issuePrioritySection => 'ÖNCELİK';

  @override
  String get issuePriorityLow => 'Düşük';

  @override
  String get issuePriorityMedium => 'Orta';

  @override
  String get issuePriorityHigh => 'Yüksek';

  @override
  String get issueDescriptionPlaceholder => 'Sorunu detaylı açıkla...';

  @override
  String get issuePhotoAdd => 'Foto';

  @override
  String get issuePhotoComingSoon => 'Foto ekleme yakında';

  @override
  String get issueSubmittedDemo => 'Demo: bildirim kaydedildi.';

  @override
  String get issueSubmittedSuccess => 'Arıza bildiriminiz alındı.';

  @override
  String get issueStatusUpdated => 'Durum güncellendi.';

  @override
  String get issueManagerUpdateStatus => 'Durumu güncelle';

  @override
  String get issueStatusSheetTitle => 'Durumu güncelle';

  @override
  String get issueStatusSheetSubtitle => 'Sakinler süreç notlarını görebilir.';

  @override
  String get issueStatusPickLabel => 'YENİ DURUM';

  @override
  String get issueStatusNoteLabel => 'NOT (İSTEĞE BAĞLI)';

  @override
  String get issueStatusNoteHint => 'Örn. Usta çağırdım, yarın gelecek…';

  @override
  String get issueStatusSave => 'Kaydet';

  @override
  String get issueStatusQuickNoteTechnician => 'Usta çağırdım';

  @override
  String get issueStatusQuickNoteMaterial => 'Malzeme bekleniyor';

  @override
  String get issueStatusQuickNoteResident => 'Sakinle görüşüldü';

  @override
  String get issueStatusQuickNoteDone => 'İşlem tamamlandı';

  @override
  String get issueTimelineManagerNote => 'Yönetim notu';

  @override
  String get issueTimelineEmpty => 'Henüz süreç notu yok.';

  @override
  String issueListLatestComment(Object text) {
    return 'Son not: $text';
  }

  @override
  String get issueTimelineSection => 'SÜREÇ';

  @override
  String get issueTimelineReported => 'Bildirildi';

  @override
  String get issueTimelineSeen => 'Görüldü';

  @override
  String get issueTimelineInProgress => 'İşlemde';

  @override
  String get issueTimelineResolved => 'Çözüldü';

  @override
  String get issueTimelinePending => '—';

  @override
  String get issueDemoReportedBy => 'Mehmet Y. (3A) tarafından bildirildi';

  @override
  String issueTimelineSeenBody(Object assignee) {
    return '$assignee (yönetici) görevi aldı';
  }

  @override
  String get issueDemoInProgressNote =>
      'Tesisatçı çağrıldı, yarın 10:00\'da gelecek.';

  @override
  String get issueDemoManagerName => 'Ayşe Demir';

  @override
  String get navBack => 'Geri';

  @override
  String get setupInviteHeadline => 'Apartmanına bağlan';

  @override
  String get setupFloorCountLabel => 'Kat sayısı';

  @override
  String get setupWizardPerFloorLabel => 'Her katta daire';

  @override
  String get setupBuildingNameLabel => 'Bina adı';

  @override
  String get setupAddressLabel => 'Açık adres';

  @override
  String get setupProvinceLabel => 'İl';

  @override
  String get setupDistrictLabel => 'İlçe';

  @override
  String get setupFieldRequired => 'Bu alan zorunludur.';

  @override
  String get setupProvincesLoadError =>
      'İl listesi yüklenemedi. Bağlantını kontrol edip tekrar dene.';

  @override
  String get setupProvincesRetry => 'Yeniden dene';

  @override
  String get setupAddressRequired => 'Açık adres zorunludur.';

  @override
  String get setupProvinceRequired => 'İl seçimi zorunludur.';

  @override
  String get setupDistrictRequired => 'İlçe seçimi zorunludur.';

  @override
  String get accountRoleHeadline => 'Apartmanına nasıl katılıyorsun?';

  @override
  String get accountRoleSubtitle => 'Bunu sonradan da değiştirebilirsin.';

  @override
  String get accountRoleResidentShortTitle => 'Sakinim';

  @override
  String get accountRoleManagerShortTitle => 'Yöneticiyim';

  @override
  String get accountRoleResidentShortBody =>
      'Davet kodunla giriş yap veya dairene ilk kez katıl.';

  @override
  String get accountRoleManagerShortBody =>
      'Davet kodunla giriş yap veya yeni apartman kurulumunu başlat.';

  @override
  String get residentInvitePlaceholderTitle => 'Davet kodu';

  @override
  String get residentInvitePlaceholderBody =>
      'Bu akış bir sonraki adımda bağlanacak. Şimdilik yönetici kurulumunu tamamlayabilirsin.';

  @override
  String get residentInviteBackToRole => 'Hesap türüne dön';

  @override
  String setupWizardStepProgress(Object step, Object total) {
    return 'ADIM $step / $total';
  }

  @override
  String get setupWizardStep1AppBar => 'Bina bilgileri';

  @override
  String get setupWizardStep2AppBar => 'Yapı';

  @override
  String get setupWizardStep3AppBar => 'Daireler';

  @override
  String setupWizardUnitsCountLabel(Object count) {
    return 'Daireler · $count adet';
  }

  @override
  String get setupWizardStep4AppBar => 'Aidat planı';

  @override
  String get setupWizardSkip => 'Atla';

  @override
  String get setupWizardLetsMeetBuilding => 'Apartmanını tanıyalım';

  @override
  String get setupWizardChangeLaterShort =>
      'Sonradan ayarlardan değiştirebilirsin.';

  @override
  String get setupYearBuiltOptional => 'YAPIM YILI (OPS.)';

  @override
  String get setupYearBuiltHint => 'Örn. 2008';

  @override
  String get setupAddressHint => 'Mahalle, sokak, no';

  @override
  String get setupWizardStructureHeadline => 'Apartmanın yapısı';

  @override
  String get setupWizardStructureSubtitle =>
      'Blok ve kat sayısı — bir sonraki adımda daireler otomatik oluşur.';

  @override
  String get setupBlockCountLabel => 'Blok sayısı';

  @override
  String get setupSingleBlock => 'Tek blok';

  @override
  String get setupMultipleBlocks => 'Çok blok';

  @override
  String setupBlockHeading(Object block) {
    return 'Blok $block';
  }

  @override
  String setupStructureSummaryTailMulti(
    Object floors,
    Object perFloor,
    Object blocks,
  ) {
    return 'oluşturulacak ($floors kat × $perFloor daire/blok × $blocks blok). Sonraki adımda düzenleyebilirsin.';
  }

  @override
  String setupStructureCountBold(Object count) {
    return '$count daire';
  }

  @override
  String setupStructureSummaryTail(Object floors, Object perFloor) {
    return 'oluşturulacak ($floors kat × $perFloor daire). Sonraki adımda düzenleyebilirsin.';
  }

  @override
  String get setupWizardUnitsInstruction =>
      'Otomatik oluşturulan listeyi gözden geçir, gerekirse daire ekle/çıkar.';

  @override
  String get setupWizardUnitsEdit => 'Düzenle';

  @override
  String setupShowMoreFloorsDetail(Object floors) {
    return '+ Daha fazla göster (kat $floors)';
  }

  @override
  String get setupWizardCollapseFloors => 'Daha az göster';

  @override
  String get setupNamingAutomatic => 'Otomatik (1A–6C)';

  @override
  String get setupNamingCustom => 'Özel adlandır';

  @override
  String get setupWizardUnitsInstructionCustom =>
      'Her daire için görünecek adı yazın. Aynı blokta tekrar eden ad olamaz.';

  @override
  String get setupCustomNameHint => 'Daire adı';

  @override
  String get setupCustomNameEmpty => 'Tüm daire adları dolu olmalı.';

  @override
  String get setupCustomNameDuplicate =>
      'Aynı blokta aynı daire adı iki kez kullanılamaz.';

  @override
  String get setupCustomNameTooLong =>
      'Daire adı en fazla 40 karakter olabilir.';

  @override
  String get setupWizardProceed => 'İlerle';

  @override
  String get setupDuesHeadline => 'Aidat ayarla';

  @override
  String get setupDuesSubtitle => 'Sakinlerin görüp ödeyebileceği aylık tutar.';

  @override
  String get setupDueDayLabel => 'VADE GÜNÜ';

  @override
  String get setupDuesMonthlyPerUnitLabel => 'DAİRE BAŞINA AYLIK';

  @override
  String get setupLateFeeTitle => 'Otomatik gecikme faizi';

  @override
  String get setupLateFeeSubtitle => '%2 / ay';

  @override
  String get setupSmsReminderTitle => 'Hatırlatma SMS gönder';

  @override
  String get setupSmsReminderSubtitle => 'Vade öncesi 3 gün';

  @override
  String get setupTotalMonthlyCollection => 'Toplam aylık tahsilat';

  @override
  String get setupCompleteWizard => 'Kurulumu tamamla';

  @override
  String get setupPerApartmentSuffix => 'aylık / daire';

  @override
  String get profileSetupDemoResident => 'Sakin ile devam et';

  @override
  String get profileSetupDemoManager => 'Yönetici ile devam et';

  @override
  String get adminInviteTitle => 'Yönetici davet kodu';

  @override
  String get adminInviteSubtitle =>
      'Supabase’te oluşturduğun admin (yönetici) davet kodunu gir. Kod doğrulanınca apartman kurulumuna geçersin; tamamlayınca bina ve daireler sunucuya kaydedilir.';

  @override
  String get adminInviteHeadline => 'Apartman kurulumu';

  @override
  String get adminInviteEightCharHint =>
      'Yöneticinden veya panelde tanımlı 8 haneli kodu gir.';

  @override
  String get adminInviteChecking => 'Kod kontrol ediliyor…';

  @override
  String get adminInviteVerifiedBadge => 'KOD DOĞRULANDI';

  @override
  String get adminInviteVerifiedCardTitle => 'Yönetici kodu hazır';

  @override
  String get adminInviteVerifiedCardBody =>
      'Bu kod ile apartman kaydına başlayabilirsin. Aşağıdan devam et.';

  @override
  String get adminInvitePrimaryButton => 'Apartman kurulumuna geç';

  @override
  String get adminInviteResumeHeadline => 'Tekrar hoş geldiniz';

  @override
  String get adminInviteResumeSubtitle =>
      'Bu apartman kaydını daha önce yapmıştık. Giriş yapalım.';

  @override
  String get adminInviteResumeCardBadge => 'KAYIT ZATEN VAR';

  @override
  String get adminInviteResumeCardBody =>
      'Bu kod ile apartman kurulumu tamamlanmış. Ana sayfadan yönetime devam edebilirsiniz.';

  @override
  String get adminInviteResumeSignIn => 'Giriş yap';

  @override
  String get inviteFooterNoCode => 'Kodum yok';

  @override
  String get inviteFooterScanQr => 'QR kod tara';

  @override
  String get inviteFooterNoCodeNotice =>
      'Yönetici kodunu Supabase veya destek kanalından alman gerekir.';

  @override
  String get inviteFooterQrSoon => 'QR ile giriş yakında.';

  @override
  String get adminInviteCodeLabel => 'Davet kodu';

  @override
  String get adminInviteCodeHint => 'Örn. DOGUS001';

  @override
  String get adminInviteContinue => 'Devam et';

  @override
  String get adminInviteCodeTooShort => 'Kod en az 4 karakter olmalıdır.';

  @override
  String get adminInviteCodeNotFound => 'Kod bulunamadı veya süresi dolmuş.';

  @override
  String get adminInviteNotAdminCode =>
      'Bu kod yönetici kodu değil. Sakin kodu için başta «Sakinim» seç.';

  @override
  String get adminInviteUnexpectedError =>
      'Bir sorun oluştu. Lütfen tekrar deneyin.';

  @override
  String get setupFinalizeFailed =>
      'Kurulum kaydedilemedi. Bağlantını kontrol edip tekrar dene.';

  @override
  String get setupFinalizeBuildingNameRequired =>
      'Kurulumu tamamlamak için bina adı gerekli.';

  @override
  String get homeManagerLockedPlaceholder =>
      'Özet ve grafik verisi yakında burada olacak.';

  @override
  String get homeQuickLockedHint => 'Bu özellik yakında açılacak.';

  @override
  String get managerInviteSubtitle =>
      'Seçtiğin daire için kalıcı bir davet kodu üretilir; iptal edilene kadar tekrar giriş için kullanılabilir.';

  @override
  String get managerInviteGenerate => 'Davet kodu oluştur';

  @override
  String get managerInviteYourCode => 'Davet kodu';

  @override
  String get managerInviteCopy => 'Panoya kopyala';

  @override
  String get managerInviteCopied => 'Kod panoya kopyalandı.';

  @override
  String get managerInviteFailed =>
      'Kod oluşturulamadı. Oturumu kontrol edip tekrar dene.';

  @override
  String get managerInviteCodeCreated => 'Yeni davet kodu hazır.';

  @override
  String get managerInviteShareHint =>
      'Bu kodu sakine güvenli kanaldan ilet; iptal edilene kadar tekrar giriş için kullanılabilir.';

  @override
  String get managerInviteDemoBanner =>
      'Demo modda kod yerelde üretilir; gerçek davet için DEMO_MODE=false kullan.';

  @override
  String get managerInviteSelectUnit => 'Daire';

  @override
  String get residentInviteScreenTitle => 'Davet kodun';

  @override
  String get residentInviteHeadline => 'Apartmana katıl';

  @override
  String get residentInviteJoinHint =>
      'Yöneticinin verdiği 5 haneli daire kodunu girin.';

  @override
  String get residentInviteCodeSection => 'DAVET KODU';

  @override
  String get residentInviteAccountSection => 'HESABINIZ';

  @override
  String get residentInviteVerifiedBadge => 'KOD DOĞRULANDI';

  @override
  String get residentInviteCodeLabel => 'Davet kodu';

  @override
  String get residentInviteCodeHint => 'Örn. A3XY2';

  @override
  String get residentInviteFullNameLabel => 'Ad soyad';

  @override
  String get residentInviteSubmit => 'Apartmana katıl';

  @override
  String get residentInviteCodeTooShort => 'Kod 5 karakter olmalıdır.';

  @override
  String get residentInviteNameTooShort =>
      'Ad soyad en az 3 karakter olmalıdır.';

  @override
  String get residentInviteUnexpected =>
      'Bir sorun oluştu. Kodu kontrol edip tekrar dene.';

  @override
  String get managerInviteRetry => 'Tekrar dene';

  @override
  String get managerInviteSelectedUnitHint =>
      'Üretilen kod bu daireye bağlanır; sakine ilettiğinizde bu daireye kayıt olur.';

  @override
  String get managerInviteNoSessionHint =>
      'Oturum bulunamadı. Önce kurulum veya giriş yapın.';

  @override
  String get managerInviteNoUnits =>
      'Bu bina için kayıtlı daire yok. Apartman kurulumunda daireler oluşturulmalı.';

  @override
  String get managerInviteFilterAll => 'Tümü';

  @override
  String get managerInviteFilterWithCode => 'Kodu var';

  @override
  String get managerInviteFilterWithoutCode => 'Kodu yok';

  @override
  String get managerInviteFilterEmpty => 'Bu filtreye uygun daire yok.';

  @override
  String managerInviteDetailHeadline(Object unit) {
    return 'Daire $unit için davet';
  }

  @override
  String get managerInviteDetailSubtitle =>
      'Yeni sakin bu kodla apartmana ve bu daireye bağlanır.';

  @override
  String get managerInviteDavetCodeCaps => 'DAVET KODU';

  @override
  String managerInviteValidDays(Object days) {
    return '$days gün geçerli';
  }

  @override
  String managerInviteValidUntilDate(Object date) {
    return '$date tarihine kadar';
  }

  @override
  String get managerInviteGenerateAction => 'Davet kodu oluştur';

  @override
  String get managerInviteBulkTitle => 'Toplu davet gönder';

  @override
  String get managerInviteBulkSubtitle =>
      'Boş daireler için tek seferde kod üret (yakında).';

  @override
  String managerInviteShareBody(Object code) {
    return 'Apartmana katılım kodum: $code';
  }

  @override
  String get managerInviteShareWhatsapp => 'WhatsApp';

  @override
  String get managerInviteShareEmail => 'E-posta';

  @override
  String get managerInviteShareSms => 'SMS';

  @override
  String get managerInviteShareMore => 'Daha fazla';

  @override
  String get residentInviteScreenBody =>
      'Yöneticinin verdiği 5 karakterlik kod hangi daireye tanımlandıysa kayıt o daireye yapılır. «Apartmana katıl» için ad soyadınızı girin.';

  @override
  String get residentInvitePreviewTitle => 'Kod ile bağlantı';

  @override
  String get residentInviteWrongCodeType =>
      'Bu bir yönetici davet kodu. Sakin olarak girmek için yöneticiden daire kodu isteyin.';

  @override
  String get residentInvitePreviewDemo =>
      'Demo modda sunucu doğrulaması yok; gerçek akış için DEMO_MODE kapalı çalıştırın.';

  @override
  String get residentInviteResumeHeadline => 'Kaydınız bulunmaktadır';

  @override
  String get residentInviteResumeSubtitle =>
      'Bu kod ile daha önce kayıt olunmuş. Giriş yaparak devam edebilirsiniz.';

  @override
  String get residentInviteResumeCardBadge => 'KAYIT MEVCUT';

  @override
  String get residentInviteResumeCardBody =>
      'Bu daire kodu daha önce kullanılmış. Aynı apartmana tekrar bağlanırsınız.';

  @override
  String get residentInviteResumeSignIn => 'Giriş yap';

  @override
  String get residentInviteChecking => 'Kod kontrol ediliyor…';

  @override
  String get homeManagerRolePrefix => 'YÖNETİCİ';

  @override
  String get homeManagerBuildingFallback => 'YÖNETİCİ · Apartman';

  @override
  String get residentRolePrefix => 'SAKİN';

  @override
  String get demoModuleLockedBody =>
      'Gerçek veriler bağlanınca burası açılacak.';

  @override
  String get accountRoleSuperAdminShortTitle => 'Sistem yöneticisiyim';

  @override
  String get accountRoleSuperAdminShortBody =>
      'Tüm apartmanları gör, yönetici ve daire kodları üret.';

  @override
  String get demoPersonaSuperAdminTitle => 'Sistem yöneticisi';

  @override
  String get demoPersonaSuperAdminBody =>
      'Demo: platform genelinde kod ve bina yönetimi.';

  @override
  String get superadminAccessTitle => 'Sistem erişimi';

  @override
  String get superadminAccessHeadline => 'Özel erişim kodun';

  @override
  String get superadminAccessBody =>
      'Sunucuda tanımlı süper yönetici kodunu girin. Bu kod uygulamada saklanmaz; yalnızca Edge doğrulaması yapılır.';

  @override
  String get superadminAccessFieldLabel => 'ERİŞİM KODU';

  @override
  String get superadminAccessContinue => 'Giriş yap';

  @override
  String get superadminAccessCodeTooShort => 'Kod en az 4 karakter olmalı.';

  @override
  String get superadminAccessWrongRole =>
      'Bu kod sistem yöneticisi oturumu vermedi.';

  @override
  String get superadminAccessUnexpectedError =>
      'Giriş yapılamadı. Kodu ve bağlantını kontrol edin.';

  @override
  String get superadminDashboardTitle => 'Sistem paneli';

  @override
  String get superadminNavHome => 'Ana sayfa';

  @override
  String get superadminNavManagerCodes => 'Kodlar';

  @override
  String get superadminNavBuildings => 'Apartmanlar';

  @override
  String get superadminHomeComingSoon => 'Bu bölüm geliştiriliyor.';

  @override
  String get superadminRefresh => 'Yenile';

  @override
  String get superadminDemoBanner =>
      'Demo modda yerel örnek veriler gösterilir.';

  @override
  String get superadminDemoSwitch => 'Demo: rol değiştir';

  @override
  String get superadminSectionManagerCodes => 'Yönetici davet kodları';

  @override
  String get superadminCreateManagerCode => 'Yeni yönetici kodu oluştur';

  @override
  String get superadminManagerCodeCreated => 'Yönetici kodu panoya kopyalandı.';

  @override
  String get superadminNoAdminCodesYet =>
      'Henüz liste için kod yok; yeni kod oluşturabilirsiniz.';

  @override
  String get superadminSectionBuildings => 'Apartmanlar';

  @override
  String get superadminNoBuildings => 'Kayıtlı apartman yok.';

  @override
  String get superadminCopied => 'Kopyalandı';

  @override
  String get superadminBuildingInviteTitle => 'Sakin daveti';

  @override
  String get superadminDeleteBuildingTitle => 'Apartmanı sil';

  @override
  String get superadminDeleteBuildingBody =>
      'Bu apartman ve bağlı tüm kayıtlar (daireler, üyelikler, aidatlar, duyurular vb.) kalıcı olarak silinir. Bu işlem geri alınamaz.';

  @override
  String get superadminDeleteBuildingConfirm => 'Sil';

  @override
  String get superadminBuildingDeleted => 'Apartman silindi.';

  @override
  String get superadminDeleteBuildingFailed => 'Apartman silinemedi.';

  @override
  String get superadminAdminCodeMultiBadge => 'Çoklu kurulum';

  @override
  String get superadminAdminCodePolicyHint =>
      'Aynı kod süresi dolana kadar farklı cihazlarda veya uygulama yeniden kurulunca tekrar yönetici girişi için kullanılabilir.';

  @override
  String get superadminAdminCodeStatusActive => 'Aktif';

  @override
  String get superadminAdminCodeStatusRevoked => 'İptal edildi';

  @override
  String get superadminAdminCodeExpires => 'Son kullanma';

  @override
  String get superadminAdminCodeCreated => 'Oluşturulma';

  @override
  String get superadminRevokeAdminCode => 'Kodu iptal et';

  @override
  String get superadminRevokeAdminCodeTitle => 'Yönetici kodunu iptal et';

  @override
  String get superadminRevokeAdminCodeBody =>
      'Bu kod artık kullanılamaz. Emin misiniz?';

  @override
  String get superadminRevokeAdminCodeConfirm => 'İptal et';

  @override
  String get superadminCodeRevoked => 'Kod iptal edildi.';

  @override
  String get inviteCodeNotesCreate => 'Oluştur';

  @override
  String get inviteCodeNotesAdminTitle => 'Yönetici kodu notu';

  @override
  String get inviteCodeNotesAdminHint =>
      'İsteğe bağlı: hangi yönetici veya apartman için (ör. Ahmet Bey – Site A)';

  @override
  String get inviteCodeNotesUnitTitle => 'Sakin / daire notu';

  @override
  String get inviteCodeNotesUnitHint =>
      'İsteğe bağlı: sakin veya daire hakkında (ör. 6A – Yeni kiracı)';

  @override
  String get inviteCodeNotesLabel => 'Not';

  @override
  String get managerInviteRevokeAction => 'Kodu iptal et';

  @override
  String get managerInviteRevokeTitle => 'Davet kodunu iptal et';

  @override
  String get managerInviteRevokeBody =>
      'Bu kod artık giriş için kullanılamaz. Yeni kod oluşturabilirsiniz.';

  @override
  String get managerInviteRevokeConfirm => 'İptal et';

  @override
  String get managerInviteRevoked => 'Davet kodu iptal edildi.';

  @override
  String get managerInviteActiveUntilRevoked => 'İptal edilene kadar geçerli';

  @override
  String get managerUnitJoinedViaCode => 'Kod ile katıldı';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get settingsSectionAppearance => 'Görünüm';

  @override
  String get settingsThemeLabel => 'Tema';

  @override
  String get settingsThemeLight => 'Açık';

  @override
  String get settingsThemeLightHint => 'Açık renkli arayüz';

  @override
  String get settingsThemeDark => 'Koyu';

  @override
  String get settingsThemeDarkHint => 'Koyu renkli arayüz';

  @override
  String get settingsThemeSystem => 'Sistem';

  @override
  String get settingsThemeSystemHint => 'Cihaz ayarını kullan';

  @override
  String get settingsSectionLanguage => 'Dil';

  @override
  String get settingsLanguageTurkish => 'Türkçe';

  @override
  String get settingsLanguageEnglish => 'İngilizce';

  @override
  String get settingsApplyHint => 'Dil ve tema tercihleriniz kaydedilir.';

  @override
  String get settingsLoadFailed => 'Ayarlar yüklenemedi.';
}
