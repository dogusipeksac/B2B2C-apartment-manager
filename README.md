# Apartman Yöneticisi

Türkiye pazarına yönelik Flutter tabanlı apartman/site yönetim uygulaması.

## Kurulum

Gereksinimler:
- Flutter (stable)
- Dart (Flutter ile birlikte gelir)

Komutlar:

```bash
flutter pub get
flutter gen-l10n
flutter analyze
flutter run
```

## Proje Yapısı

- `lib/core/`: tema, ortak widgetlar, utils, hata tipleri
- `lib/features/`: feature-first yapı (`<feature>/{data,domain,presentation}`)
- `lib/router/`: `go_router` yapılandırması
- `lib/l10n/`: çeviri dosyaları

## Supabase

Davet kodu şeması (`schema_v2.sql`) ve `redeem_code` Edge Function deploy adımları için bkz. **[supabase/README.md](supabase/README.md)**.

## Phase 1

- Spec’e göre bağımlılıklar eklendi
- Lint kuralları (very_good_analysis + flutter_lints) aktif
- Feature-first klasör yapısı kuruldu
- Material 3 light/dark tema + Inter font
- Splash ekranı (2sn) eklendi

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
# B2B2C-apartment-manager
