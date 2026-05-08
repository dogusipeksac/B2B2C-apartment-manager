# Apartman Yönetim App — Cursor Proje Spec

## 1. ÜRÜN
B2B2C SaaS apartman yönetimi. Yönetici öder, sakin ücretsiz kullanır.
- Free: 1 bina, ≤8 daire, reklamlı
- Standart: ₺149/ay/bina (sınırsız daire, online ödeme, raporlar)
- Pro: ₺349/ay (çoklu yönetici, KVKK şablonları)
- Site: özel fiyat
- Komisyon: online ödeme başına %1.5+KDV

## 2. ROLLER
super_admin / building_admin / building_co_admin / accountant / resident / owner
(bir kullanıcı çoklu binada çoklu rolde olabilir → memberships)

## 3. STACK
Flutter 3.24+ / Dart 3.5+ • Riverpod 2.5+ (manuel) • go_router 14+ • reactive_forms
dio 5+ • hive_ce • flutter_secure_storage • fl_chart • intl (tr_TR)
cached_network_image • image_picker • flutter_image_compress • pdf+printing
firebase_messaging • firebase_analytics • firebase_crashlytics • mixpanel_flutter
freezed • json_serializable • supabase_flutter
Backend: Supabase (Postgres+Auth+Storage+Edge+Realtime), RLS zorunlu
Ödeme: iyzico • SMS: Iletimerkezi • Email: Resend • Monitoring: Sentry

## 4. KLASÖR
lib/
core/{config,constants,errors,extensions,network,supabase,theme,utils,widgets}
features/{auth,onboarding,buildings,units,memberships,invitations,
dues,payments,announcements,issues,expenses,reports,
documents,polls,notifications,subscription,settings}/{data,domain,presentation}
l10n/ • router/ • shared/{models,providers}

## 5-6. DB ŞEMASI + RLS
Aşağıda ayrı SQL bloku — Supabase SQL Editor'a yapıştır.

## 7. ÖZELLİK SPEC
7.1 Auth: telefon OTP + profil setup → davet kodu / yeni bina seçimi
7.2 Bina sihirbazı: 4 adım (bilgi → yapı → daire üretimi → aidat ayarı → davet)
7.3 Aidat: dönem oluştur (her unit için invoice trigger), manuel/online ödeme, makbuz PDF
7.4 Duyuru: rich text + ek + öncelik + pin + okundu raporu + push
7.5 Arıza: kategori + foto×5 + kanban (drag-drop status), yorum thread
7.6 Rapor: aylık gelir/gider chart, daire bazlı tahsilat %, PDF export
7.7 Belge: kategori klasör (genel kurul, fatura, sözleşme), preview
7.8 Oylama: daire başına 1 oy (arsa payı ağırlık opsiyonel), canlı sonuç
7.9 Abonelik: 30 gün Pro trial → free fallback → upgrade flow → past_due readonly

## 8. UI
Material 3 • Primary #1B5E20 (yeşil), Secondary #FFA000, Error #C62828
Inter font • Sakin: bottom nav (Ana/Aidat/Duyuru/Arıza/Profil)
Yönetici: drawer + dashboard
Para: ₺1.234,56 • Tarih: 5 Mart 2025 • IBAN 4'lü grup • Tel +90 532 ...
Empty state ZORUNLU + skeleton loader + pull-to-refresh

## 11. TUZAKLAR
- KVKK + VERBİS kayıt zorunlu (aydınlatma metni, açık rıza)
- Para: integer kuruş veya Decimal — double ASLA
- Çoklu yönetici claim çakışması → transfer flow
- Telefon değişikliği → admin re-link onayı

## 13. İLK GÜN
[ ] Supabase project (eu-central) + SQL run
[ ] Storage buckets: building_files, issue_photos, receipts, documents
[ ] iyzico sandbox başvuru
[ ] Firebase: Android+iOS, FCM, Analytics, Crashlytics
[ ] Sentry • Domain
[ ] Phase 1 prompt çalıştır