# Supabase — şema ve Edge Functions

Bu klasör veritabanı tanımları ve `redeem_code` Edge Function kaynağını içerir.

## Dosyalar

| Dosya | Açıklama |
|--------|-----------|
| `schema.sql` | İlk kurulum (enum’lar, çekirdek tablolar, tetikleyiciler) |
| `schema_v2.sql` | Davet kodu modeli: `invite_codes`, `devices`, `profiles` gevşetme |
| `schema_v5_votes_unit_fk.sql` | `votes.unit_id` → `ON DELETE SET NULL` (bina silinirken FK hatası önleme) |
| `schema_v6_invite_admin_redeem_policy.sql` | `invite_codes.admin_redeem_policy` — yönetici kodu tek kullanımlı / yeniden kullanılabilir |
| `schema_after_v2_bundle.sql` | **Tek çalıştırmada** `schema_v3` + `schema_v6` — sıfır DB’de süper yönetici panelinden kod üretimi için önerilir |
| `rls.sql` | Row Level Security politikaları (`schema.sql` sonrası uygulanır) |
| `functions/redeem_code/index.ts` | Kod kullanımı (admin / unit) — **service role**; opsiyonel `SUPERADMIN_ACCESS_CODE` ile süper yönetici oturumu |
| `functions/superadmin_ops/index.ts` | Süper yönetici: tüm binalar, yönetici/daire davet kodları — **service role** |
| `functions/manager_invite/index.ts` | Yönetici: daire listesi + sakin davet kodu üretimi — **service role** |
| `functions/finalize_building_setup/index.ts` | Kurulum sonrası bina/daire kaydı |

## Yönetici — `manager_invite` (sakin daveti)

Uygulama **Sakin daveti** ekranında `list_units` ve `create_invite` için bu fonksiyona POST atar. Sunucuda **deploy edilmediyse** istek 404 olur veya anlamsız gövde döner.

### Deploy

```bash
supabase login
supabase link --project-ref <PROJECT_REF>
supabase functions deploy manager_invite --project-ref <PROJECT_REF>
supabase functions deploy redeem_code --project-ref <PROJECT_REF>
supabase functions deploy superadmin_ops --project-ref <PROJECT_REF>
```

### Süper yönetici

1. Supabase Dashboard → Edge Functions → **Secrets**: `SUPERADMIN_ACCESS_CODE` değerini ayarlayın (ör. `DOGUSADMIN`; harf büyüklüğü önemli değil, normalize edilir).
2. `redeem_code` yeniden deploy edilir; uygulama **Hesap türü → Sistem yöneticisiyim → Erişim kodu** ekranından aynı kodu gönderir ve `devices.role = super_admin` oturumu alır.
3. `superadmin_ops` deploy edilmezse panel istekleri başarısız olur.

**Apartman silme:** `superadmin_ops` içinde `delete_building` aksiyonu, önce `devices` ve `audit_logs` üzerindeki bina referanslarını temizler, sonra `buildings` satırını siler; şemada `ON DELETE CASCADE` olan tablolar (birimler, üyelikler, aidat dönemleri vb.) otomatik temizlenir. Storage’daki dosyalar silinmez — gerekirse ayrıca temizlenmelidir.

`config.toml` içinde `[functions.manager_invite] verify_jwt = false` ile anon key üzerinden çağrıya izin verilir (Dashboard’da da function için JWT kapalı olmalı).

### Ön koşullar

1. SQL: `schema_v2.sql` (ve gerekiyorsa `schema.sql`) uygulanmış olmalı — `invite_codes`, `units`, `devices` tabloları.
2. Yönetici cihazı `finalize_building_setup` ile tamamlanmış olmalı — `devices.building_id` dolu; aksi halde Edge **`building_not_ready`** döner.
3. Projede en az bir **aktif daire** (`units`) kaydı olmalı.

### `list_units` yanıtı

Her daire için sunucu, o birime bağlı **en güncel aktif** `invite_codes` satırını ekler (varsa):

- `invite_code`: string veya `null`
- `invite_expires_at`: ISO tarih veya `null`

Birden fazla aktif kod varsa **en son oluşturulan** seçilir.

**`create_invite`**: Aynı daire için süresi dolmamış aktif bir birim kodu zaten varsa **yeni satır eklenmez**; mevcut kod ve `expires_at` aynen döner (`reused: true`).

## Veritabanını güncelleme sırası

Yeni bir projede:

1. SQL Editor’da `schema.sql` çalıştırın.
2. Ardından `schema_v2.sql` çalıştırın.
3. **`schema_after_v2_bundle.sql`** çalıştırın (`devices.session_token` + `invite_codes.admin_redeem_policy`). Süper yönetici panelinden yönetici kodu üretmek ve kodda **tek kullanımlı / çoklu kurulum** seçeneğinin veritabanına yazılması için gereklidir.
4. İsterseniz `schema_v5_votes_unit_fk.sql` (oylar tablosu varsa bina silme uyumu).
5. `rls.sql` çalıştırın (varsa mevcut politikalarla çakışma olursa önce yedek alın).

**Sıfır veritabanı — süper yönetici akışı:** Dashboard → Edge Secrets içinde `SUPERADMIN_ACCESS_CODE` tanımlı olsun → `redeem_code` deploy → uygulamada **Sistem yöneticisi** erişim kodu ile giriş → panelde **Tek kullanımlı** veya **Çoklu kurulum** seçip **Yeni yönetici kodu oluştur**. Edge fonksiyonları (`superadmin_ops`, `redeem_code`) güncel deploy edilmiş olmalı.

Mevcut projede sadece davet kodu eklemek için: **`schema_v2.sql`** yeterlidir (önceki şema ile uyumludur).

> **Not:** `schema_v2.sql`, `profiles.id` üzerindeki `auth.users` FK’sını kaldırır ve `full_name` alanını opsiyonel yapar. Mevcut `auth.users` ile eşleşen satırlar tabloda kalır; test kullanıcısına dokunmanız gerekmez.

## Edge Function: `redeem_code`

### Ne yapar?

- **POST** ile `{ "code", "device_id", "full_name?" }` alır.
- Aktif ve süresi dolmamış `invite_codes` satırını bulur; atomik olarak `used` yapar.
- **admin:** `devices` satırı (`role = building_admin`, bina henüz yok).
- **unit:** `profiles` + `memberships` + `devices` (`role = resident`).
- Yanıt: `{ success, role, building_id?, unit_id?, profile_id?, session_token }`.

Service role kullanıldığı için RLS bypass edilir; istemci **anon key** ile function URL’sine istek atabilir (Supabase Gateway JWT doğrulaması function için yapılandırmanıza bağlıdır — genelde `Authorization: Bearer <anon>` + `apikey`).

### Yerelde çalıştırma (Supabase CLI)

[Gerekli: Supabase CLI](https://supabase.com/docs/guides/cli)

```bash
# Proje kökünden
supabase login
supabase link --project-ref <PROJECT_REF>
supabase functions serve redeem_code --env-file supabase/.env.local
```

Örnek `.env.local` (yerel deneme; gerçek anahtarları repoya koymayın):

```env
SUPABASE_URL=https://xxxx.supabase.co
SUPABASE_SERVICE_ROLE_KEY=eyJ...
```

### Deploy (production)

```bash
supabase functions deploy redeem_code --project-ref <PROJECT_REF>
supabase functions deploy session_metadata --project-ref <PROJECT_REF>
```

**`session_metadata`** — cihaz oturumu geçerliyse `buildings.name` döner; sakin ana sayfada apartman adını yerelde saklamak için uygulama bir kez çağırır (RLS ile doğrudan tablo okumaya gerek kalmaz).

**`redeem_code`** birim kodu ile kayıtta artık **`building_name`** alanı da döner; istemci bunu `LocalSession.buildingName` olarak kaydeder.

Supabase Dashboard → **Edge Functions** altında `redeem_code` görünür. Aşağıdaki ortam değişkenleri deploy sırasında projeye bağlıdır (hosted Edge’de genelde otomatik):

- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`

Dashboard’dan da ekleyebilirsiniz: **Project Settings → Edge Functions → Secrets**.

### HTTP örneği

```bash
curl -s -X POST \
  'https://<PROJECT_REF>.supabase.co/functions/v1/redeem_code' \
  -H "Authorization: Bearer <SUPABASE_ANON_KEY>" \
  -H "apikey: <SUPABASE_ANON_KEY>" \
  -H "Content-Type: application/json" \
  -d '{"code":"A3F9K","device_id":"my-stable-device-uuid","full_name":"Ali Veli"}'
```

Admin kodu için `full_name` göndermeyebilirsiniz.

## Kodları elle üretme (beta)

`invite_codes` tablosuna satır ekleyin (`code` büyük harf önerilir):

- **Admin:** `code_type = 'admin'`, `building_id` / `unit_id` NULL.
- **Unit:** `code_type = 'unit'`, ilgili `building_id` ve istenirse `unit_id`.

`expires_at` ve `notes` alanlarını ihtiyaca göre doldurun.
