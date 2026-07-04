# Vazgeçtim — API Kontratı

Frontend (Flutter) ↔ n8n ↔ Supabase arasındaki HTTP kontratı.
Tüm tutarlar `numeric(12,2)` → JSON'da `number`; para birimi `TRY` (₺).

---

## 1. POST `/webhook/vazgec-ekle` (n8n Workflow 1)

Yeni bir "vazgeçiş" kaydeder; doğrular, LLM ile kategorize eder, DB'ye yazar
ve güncel `total_saved` döndürür.

### Request

```
POST {N8N_WEBHOOK_URL}
Content-Type: application/json
```

```jsonc
{
  "user_id": "00000000-0000-0000-0000-000000000000",  // zorunlu, UUID
  "item_name": "Starbucks Latte",                      // zorunlu, boş değil
  "price": 120.50,                                     // zorunlu, > 0
  "raw_category": "İçecek",                            // opsiyonel
  "client_timestamp": "2026-07-04T14:30:00.000+03:00", // Steering: yerel saat
  "timezone": "GMT+3"                                  // Steering: timezone
}
```

| Alan              | Tip      | Zorunlu | Açıklama                                   |
| ----------------- | -------- | ------- | ------------------------------------------ |
| `user_id`         | string   | ✅       | UUID. demo: `00000000-...0000`             |
| `item_name`       | string   | ✅       | Boş olamaz.                                |
| `price`           | number   | ✅       | `> 0`.                                     |
| `raw_category`    | string   | ❌       | Boşsa LLM atar.                            |
| `client_timestamp`| string   | ❌       | ISO 8601 + offset. Sunucu saati yerine bu. |
| `timezone`        | string   | ❌       |örn. `GMT+3`.                              |

### Response — 200 OK

```jsonc
{
  "success": true,
  "item_id": "550e8400-e29b-41d4-a716-446655440000",
  "ai_category": "İçecek",           // raw boşsa LLM atanır, boşsa ham değer
  "total_saved": 12571.25             // güncel toplam (trigger sonrası)
}
```

### Response — 400 Bad Request

```jsonc
{
  "success": false,
  "error": "item_name boş olamaz; price 0'dan büyük olmalı",
  "code": "VALIDATION_FAILED"
}
```

### Hata kodları

| HTTP | `code`                | Anlamı                                  |
| ---- | --------------------- | --------------------------------------- |
| 400  | `VALIDATION_FAILED`   | Alan doğrulaması başarısız.             |
| 500  | (yok)                 | n8n/DB beklenmedik hatası.              |

> **Fallback davranışı** (Steering → Hata Yönetimi): LLM başarısız olursa
> `ai_category = "Diğer"` ile devam edilir; istek **başarısız sayılmaz**.

---

## 2. GET `/rest/v1/users` (Supabase REST — frontend read-only)

Frontend `RemoteSavingsRepository` doğrudan Supabase REST'e okumaya gider.

```
GET {SUPABASE_URL}/rest/v1/users?user_id=eq.{USER_ID}&select=*
Headers:
  apikey: {SUPABASE_ANON_KEY}
  Authorization: Bearer {SUPABASE_ANON_KEY}
```

```jsonc
{
  "data": [
    {
      "user_id": "00000000-0000-0000-0000-000000000000",
      "created_at": "2026-06-01T00:00:00+00:00",
      "total_saved": 12571.25,
      "display_name": "Yagiz",
      "email": "yagiz@example.com"
    }
  ]
}
```

---

## 3. GET `/rest/v1/skipped_items` (Supabase REST)

```
GET {SUPABASE_URL}/rest/v1/skipped_items
  ?user_id=eq.{USER_ID}
  &order=created_at.desc
  &limit=20
  &select=*
```

```jsonc
{
  "data": [
    {
      "item_id": "...",
      "user_id": "...",
      "item_name": "Starbucks Latte",
      "price": 120.00,
      "raw_category": null,
      "ai_category": "İçecek",
      "created_at": "2026-07-04T12:05:33.123+00:00"
    }
  ]
}
```

---

## 4. GET `/rest/v1/ai_insights` (Supabase REST)

```
GET {SUPABASE_URL}/rest/v1/ai_insights
  ?user_id=eq.{USER_ID}
  &order=generated_at.desc
  &limit=10
  &select=*
```

```jsonc
{
  "data": [
    {
      "insight_id": "...",
      "user_id": "...",
      "insight_text": "Bu hafta giyimden 900₺ vazgeçtin!",
      "amount": 900.00,
      "generated_at": "2026-07-03T20:59:00+00:00"
    }
  ]
}
```

---

## Kategori Seti (LLM + Frontend hizalı)

`Yemek`, `İçecek`, `Giyim`, `Eğlence`, `Ulaşım`, `Teknoloji`, `Kişisel Bakım`,
`Diğer`. LLM bunlardan birini döner; format dışı yanıt → `Diğer` (fallback).

---

## Timezone Kuralı (Backend Steering → Zaman Damgaları)

- Frontend, webhook çağrısında `client_timestamp` (ISO 8601 + offset) ve
  `timezone` alanlarını payload'a dahil eder.
- n8n "tetikleyici an analizi" için sunucu saati yerine bu değeri kullanır.
- Supabase `created_at` sütunu `timestamptz` → offset otomatik saklanır.
