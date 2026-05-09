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
  String get splashTagline => 'Apartmanın için hepsi tek yerde';

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
  String get demoSplashTagline => 'Apartmanın için hepsi tek yerde';

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
  String demoHelloName(Object name) {
    return 'Merhaba $name';
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
  String get demoNavAnnouncements => 'Duyurular';

  @override
  String get demoNavFinance => 'Aidat';

  @override
  String get demoNavIssues => 'Arızalar';

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
  String get homeManagerCollectionLabel => 'Tahsilat';

  @override
  String get homeManagerIncomeLabel => 'Bu ay gelir';

  @override
  String get homeManagerOpenDebtLabel => 'Açık borç';

  @override
  String get homeManagerOpenIssuesLabel => 'Açık arıza';

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
  String get homeQuickActionsSection => 'Hızlı aksiyonlar';

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
  String get managerUnitsTitle => 'Daireler';

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
  String get profileVersionFooter => 'Sürüm 1.0.0 · KVKK';

  @override
  String get issueFieldTitle => 'Başlık';

  @override
  String get issueFieldDescription => 'Açıklama';

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
  String get profileSetupDemoResident => 'Sakin ile devam et';

  @override
  String get profileSetupDemoManager => 'Yönetici ile devam et';
}
