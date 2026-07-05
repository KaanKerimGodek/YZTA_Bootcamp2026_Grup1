# Vazgeçtim 🪙

> **Positive gain through intentional omission.**
> Harcama değil — *vazgeçiş* takip eden bir finansal wellness uygulaması.

Vazgeçilen her harcama bir tasarruf sayılır. Uygulama bu "kazançları" pozitif
bir psikolojiyle gösterir: gradyan Hero Cüzdan, AI içgörüleri ve aktivite akışı.

---

## Mimari — İki Parça

```
┌──────────────────────────┐        ┌──────────────────────────┐
│  FRONTEND (Flutter)      │        │  BACKEND (n8n+Supabase)  │
│  Riverpod + go_router    │  POST  │  Workflow 1: Kayıt &     │
│  Dio → n8n webhook        │ ────▶  │  kategorizasyon (LLM)    │
│  Mock / Live modu        │        │  Workflow 2: Haftalık AI │
│  4 ekran (DESIGN.md)     │  GET   │  içgörü (cron)           │
│                           │ ────▶  │  Supabase: 3 tablo + RLS │
└──────────────────────────┘        └──────────────────────────┘
```

- **Frontend**: [`/`](./) kök dizin — Flutter + Material 3 + Riverpod.
- **Backend**: [`backend/`](./backend) — n8n workflow JSON'ları, Supabase şema, API kontratı.

---

## Hızlı Başlangıç

### Önkoşullar

- **Flutter SDK** ≥ 3.19 (stable) — https://docs.flutter.dev/get-started/install
- Bir **Supabase** projesi (ücretsiz tier yeterli).
- **n8n** (cloud veya self-hosted) — yalnızca `live` modu için.
- **Google Gemini API key** — n8n içinde LLM kategorizasyon için.

### 1. Frontend (Flutter)

```bash
# Proje dizinine gir
cd vazgectim            # (repo köküyse: cd .)

# Bağımlılıkları yükle
flutter pub get

# Env dosyasını hazırla
copy .env.example .env    # Windows
cp .env.example .env      # macOS/Linux

# .env içini düzenle:
#   APP_MODE=mock         → backend olmadan demo verisiyle çalışır
#   APP_MODE=live         → n8n + Supabase ile konuşur

# Çalıştır
flutter run
```

> **Not:** `APP_MODE=mock` ile hiç backend kurmadan uygulamanın tüm
> ekranlarını demo verisiyle deneyebilirsin.

### 2. Backend (n8n + Supabase)

Ayrıntılı talimat için [`backend/README.md`](./backend/README.md).

Özet:
1. Supabase → SQL Editor → `backend/supabase/schema.sql` çalıştır.
2. n8n → Import from File → 2 workflow JSON'unu içe aktar.
3. n8n credentials: Supabase (service_role) + Google Gemini.
4. Webhook URL'i `.env` → `N8N_WEBHOOK_URL` yaz.

---

## Ekranlar (DESIGN.md → Flutter uygulaması)

| Ekran | Dosya | İçerik |
|-------|-------|--------|
| **Ana Sayfa** | `lib/features/home/home_screen.dart` | Hero Wallet + AI Insight Carousel + Son Vazgeçişler |
| **İstatistik** | `lib/features/stats/stats_screen.dart` | Özet kartları + kategori breakdown + haftalık bar grafik |
| **Profil** | `lib/features/profile/profile_screen.dart` | Kullanıcı kartı + hızlı istatistik + ayarlar |
| **Vazgeçiş Ekle** | `lib/features/add_transaction/add_transaction_sheet.dart` | Bottom sheet, kategori seçimi + AI fallback |

**Bottom Nav**: Ana Sayfa · İstatistik · **[FAB]** · Profil — FAB ortada
negatif margin ile yukarı taşmış, gradient + glow shadow.

---

## Proje Yapısı

```
vazgectim/
├── lib/
│   ├── main.dart, app.dart               # bootstrap + MaterialApp
│   ├── core/
│   │   ├── theme/                         # DESIGN.md tokenları (renk/tipografi/spacing/shape)
│   │   ├── constants/                     # kategoriler, para birimi
│   │   └── utils/                         # formatting (₺, tarih), responsive
│   ├── data/
│   │   ├── models/                        # SkippedItem, AppUser, AiInsight
│   │   ├── services/                      # api_client, n8n_webhook, mock_data
│   │   ├── repositories/                  # abstract + mock/remote impl
│   │   └── providers/                     # Riverpod DI + AsyncNotifier'lar
│   ├── features/                          # home, add_transaction, stats, profile
│   ├── shared/widgets/                    # gradient_button, hero_card, bottom_nav...
│   ├── shared/layouts/main_scaffold.dart
│   └── router/app_router.dart             # go_router (StatefulShellRoute)
├── backend/                               # n8n + Supabase
├── pubspec.yaml
├── .env.example
└── analysis_options.yaml
```

---

## Tasarım Sistemi (DESIGN.md)

- **Tek light mode**, Slate-50 (#F8FAFC) arka plan + saf beyaz kartlar.
- **Primary Gradient** 135° blue (#2563EB) → emerald (#10B981).
- **Inter** font, dramatik hiyerarşi (`display-wallet` 36px/800).
- **8pt grid**: spacing xs(4) · base(8) · sm(16) · md(24) · lg(32) · xl(48).
- **Shapes**: sm(4) · md(12) · lg(16) · xl(24) · full(9999) · sheet(32).
- **Semantic success** Emerald-500, vazgeçilen tutarlar `+₺` önekli.
- Hero Card tinted glow shadow `rgba(37,99,235,0.15)`.

---

## Mock vs Live Modu

`AppConfig` (`.env` → `APP_MODE`) tek anahtarla iki mod arasında geçiş yapar:

- **`mock`**: `MockDataService` demo verisi üretir — backend gerekmez.
  Tüm UI akışları (vazgeçiş ekleme, listelerin güncellenmesi) çalışır.
- **`live`**: `RemoteSavingsRepository` → n8n webhook + Supabase REST.

İki mod da aynı `SavingsRepository` soyutlamasını uyguladığı için UI katmanı
değişmeden çalışır.

---

## Bilinen Sınırlar

- **Flutter SDK bu ortamda kurulu değil** — kod yazıldı ama `flutter run`
  derlemesi SDK kurulana kadar doğrulanamadı. `flutter pub get` + `flutter run`
  sonrası kutudan çıktığı gibi derlenecek şekilde hazırlandı.
- **Auth**: demo `USER_ID` ile çalışır; üretimde Supabase Auth ile
  `users.user_id = auth.uid()` bağlanmalı.
- **Sprint Planı PDF**'ine erişim yoktu → scope bu README'deki gibidir.
