# Vazgeçtim — Backend

n8n orkestrasyonu + Supabase (Postgres) üzerine kurulu No-Code/Low-Code backend.
Kaynak: `Vazgectim_Backend_Steering.md`.

## Mimari Özet

```
Flutter ──POST──▶ n8n Webhook (Workflow 1)
                      │
                      ├─ Validation (400 on fail)
                      ├─ LLM Kategorizasyon (Gemini Flash)
                      │     └─ Catch/Fallback → "Diğer"
                      ├─ Supabase insert (skipped_items)
                      │     └─ Trigger → users.total_saved güncellenir
                      └─ Response { success, item_id, ai_category, total_saved }

           n8n Cron (Workflow 2, her Pazar 23:59)
                      │
                      ├─ Son 7 günü çek + agregasyon
                      ├─ LLM → motive edici içgörü metni
                      ├─ Supabase insert (ai_insights)
                      └─ (opsiyonel) Push notification

Flutter ──GET──▶ Supabase REST (users / skipped_items / ai_insights)  [read-only]
```

## Bileşenler

| Dosya | Açıklama |
|-------|----------|
| `supabase/schema.sql` | 3 tablo + RLS + trigger + demo kullanıcı |
| `n8n/workflow1_kayit_ve_kategorizasyon.json` | Real-time webhook (vazgeçiş kaydı) |
| `n8n/workflow2_davranis_analizi.json` | Haftalık cron (AI içgörü üretimi) |
| `API_CONTRACT.md` | Frontend ↔ backend HTTP kontratı |

---

## Kurulum

### 1. Supabase

1. https://supabase.com üzerinde yeni proje oluştur.
2. **SQL Editor** → `supabase/schema.sql` içeriğini yapıştır → **Run**.
3. **Project Settings → API**:
   - `Project URL` → frontend `.env` → `SUPABASE_URL`
   - `anon public` key → `SUPABASE_ANON_KEY`
4. (Opsiyonel) demo kullanıcı hazır gelir: `00000000-...0000`.

### 2. n8n

1. https://n8n.cloud veya self-hosted n8n aç.
2. **Workflows → Import from File** ile `n8n/workflow1_*.json` ve
   `n8n/workflow2_*.json` dosyalarını içe aktar.
3. **Credentials** ekle:
   - `Supabase API`: host + `service_role` key (RLS bypass için yazma işlemleri).
   - `Google Gemini Api`: API key (Steering → maliyet için Gemini Flash önerilir).
4. Workflow 1 içindeki **Webhook** node'unu aç → **Production URL** kopyala
   → frontend `.env` → `N8N_WEBHOOK_URL` yapıştır.
5. Her iki workflow'u **Active** yap.

### 3. LLM Maliyet Optimizasyonu (Steering → Maliyet Yönetimi)

- `modelId: gemini-1.5-flash` tercih edildi (hızlı + ucuz).
- Kategorizasyon prompt'u `maxOutputTokens: 10` (yalnızca kategori adı).
- n8n ücretsiz limitlerinde kalmak için caching/ batching ileride eklenebilir.

---

## Hata Yönetimi (Steering → Hata Yönetimi)

- **LLM başarısız/format dışı**: Workflow 1'deki `LLM Fallback (Catch)` node'u
  `ai_category = "Diğer"` atar, akış kesintisiz devam eder. İstek başarısız sayılmaz.
- **Doğrulama hatası**: `VALIDATION_FAILED` koduyla `400 Bad Request` dönülür.
- **DB/Network**: n8n execution log'undan izlenebilir; frontend'de `ApiException`.

## Timezone (Steering → Zaman Damgaları)

Frontend her webhook çağrısında `client_timestamp` (ISO 8601 + offset) ve
`timezone` alanlarını gönderir. n8n "tetikleyici an analizi" için sunucu saati
yerine bu değeri kullanır. Supabase `created_at` `timestamptz` türündedir.

## Test

Webhook'u elle test:

```bash
curl -X POST "{N8N_WEBHOOK_URL}" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "00000000-0000-0000-0000-000000000000",
    "item_name": "Test Kahve",
    "price": 95,
    "client_timestamp": "2026-07-04T14:30:00.000+03:00",
    "timezone": "GMT+3"
  }'
```

Başarılı yanıt:

```json
{ "success": true, "item_id": "...", "ai_category": "İçecek", "total_saved": 95.00 }
```
