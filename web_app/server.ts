import dotenv from 'dotenv';
dotenv.config({ path: '.env.local' });

import express from 'express';
import path from 'path';
import { createServer as createViteServer } from 'vite';
import { GoogleGenAI } from '@google/genai';
import { createClient } from '@supabase/supabase-js';

// Initialize Supabase Client
const supabase = createClient(
  'https://vibqxmlkgahdxwyecwxm.supabase.co',
  process.env.SUPABASE_SERVICE_KEY!
);

// Initialize Gemini Client Lazily
let ai: GoogleGenAI | null = null;
function getAI() {
  if (!ai) {
    if (!process.env.GEMINI_API_KEY) {
      throw new Error("GEMINI_API_KEY is not set.");
    }
    ai = new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY });
  }
  return ai;
}

const app = express();
app.use(express.json());

const CATEGORIES = ['Yemek', 'İçecek', 'Giyim', 'Eğlence', 'Ulaşım', 'Kişisel Bakım', 'Teknoloji', 'Diğer'];

// skipped_items/savings_goals, user_id'ye FK ile bağlı; gerçek auth kullanıcıları
// için public.users satırı otomatik oluşmadığından burada garanti ediyoruz.
async function ensureUserRow(userId: string) {
  await supabase.from('users').upsert({ user_id: userId }, { onConflict: 'user_id', ignoreDuplicates: true });
}

// --- API Routes ---

app.get('/api/entries', async (req, res) => {
  try {
    const userId = req.headers['x-user-id'] as string || '00000000-0000-0000-0000-000000000000';
    const { data, error } = await supabase
      .from('skipped_items')
      .select('*')
      .eq('user_id', userId)
      .order('created_at', { ascending: false });
    
    if (error) return res.status(500).json({ error: error.message });
    
    res.json(data.map(d => ({
      id: d.item_id,
      title: d.item_name,
      amount: d.price,
      category: d.ai_category,
      date: d.created_at
    })));
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/entries', async (req, res) => {
  try {
    const { title, amount, category } = req.body;
    const userId = req.headers['x-user-id'] as string || '00000000-0000-0000-0000-000000000000';
    await ensureUserRow(userId);
    let finalCategory = category;

    if (!finalCategory || finalCategory.trim() === '') {
       try {
         const aiClient = getAI();
         const prompt = `Kullanıcı şu ürünü/hizmeti almaktan vazgeçti: "${title}".
Lütfen bu ürünü aşağıdaki kategorilerden EN UYGUN olanına ata:
${CATEGORIES.map(c => `- ${c}`).join('\n')}

Sadece kategori adını döndür (başka hiçbir kelime veya noktalama işareti ekleme). Bulamazsan "Diğer" döndür.`;

         const response = await aiClient.models.generateContent({
           model: 'gemini-2.5-flash',
           contents: prompt,
         });
         
         let aiCat = response.text?.trim() || 'Diğer';
         aiCat = aiCat.replace(/['"]/g, ''); // Clean quotes
         
         if (CATEGORIES.includes(aiCat)) {
           finalCategory = aiCat;
         } else {
           finalCategory = 'Diğer';
         }
       } catch (aiError) {
         console.error('AI Categorization Error:', aiError);
         finalCategory = 'Diğer';
       }
    }

    // Supabase'e kaydet
    const { data, error } = await supabase
      .from('skipped_items')
      .insert({
        user_id: userId,
        item_name: title,
        price: Number(amount),
        raw_category: category || '',
        ai_category: finalCategory
      })
      .select()
      .single();

    if (error) throw error;
    
    res.status(201).json({
      id: data.item_id,
      title: data.item_name,
      amount: data.price,
      category: data.ai_category,
      date: data.created_at
    });
  } catch (error: any) {
    console.error('Error adding entry:', error);
    res.status(500).json({ error: error.message || 'Failed to add entry' });
  }
});

app.get('/api/insights', async (req, res) => {
    try {
       const userId = req.headers['x-user-id'] as string || '00000000-0000-0000-0000-000000000000';
       
       // Supabase'den kullanıcının verilerini çek
       const { data: entries, error } = await supabase
         .from('skipped_items')
         .select('*')
         .eq('user_id', userId)
         .order('created_at', { ascending: false });
       
       if (error) throw error;
       
       const totalSavings = entries.reduce((sum, e) => sum + e.price, 0);

       if (entries.length === 0) {
           return res.json({ insight: "İlk vazgeçişini ekle ve tasarruf etmeye başla!", savings: totalSavings, insightValue: 0 });
       }
       
       const aiClient = getAI();
       const recentEntries = entries.slice(0, 10);
       
       const prompt = `Bir tasarruf uygulamasındayız. Kullanıcı satın almaktan vazgeçtiği ürünleri buraya kaydediyor.
Son vazgeçişleri şunlar:
${JSON.stringify(recentEntries.map(e => ({ item_name: e.item_name, price: e.price, category: e.ai_category })), null, 2)}

Sen kullanıcının kişisel finans koçusun. Bu verilere dayanarak kullanıcıya motive edici, kısa (1-2 cümlelik) ve Türkçe bir içgörü/bildirim mesajı üret. 
Örnek: "Yürüyerek eve dönmek yerine tercih ettiğin her adım, gece vardiyası taksi ücretlerini cüzdanına geri kazandırdı. Harika gidiyorsun!"
Sadece mesajı döndür.`;

       const response = await aiClient.models.generateContent({
         model: 'gemini-2.5-flash',
         contents: prompt,
       });

       res.json({ 
           insight: response.text?.trim() || "Harika gidiyorsun, tasarruf etmeye devam et!",
           savings: totalSavings,
           insightValue: entries.length > 0 ? entries[0].price : 0
       });
    } catch (error) {
        console.error('Error generating insight:', error);
        
        // Fallback
        res.json({ 
           insight: "Geçen aya göre harcamaların azaldı. Bu hızla devam edersen hedeflerine çok daha erken ulaşabilirsin!",
           savings: 0,
           insightValue: 0
        });
    }
});

// Manuel AI İçgörü Yenileme - Detaylı analiz üretir
app.post('/api/insights/refresh', async (req, res) => {
    try {
       const userId = req.headers['x-user-id'] as string || '00000000-0000-0000-0000-000000000000';
       
       // Supabase'den kullanıcının verilerini çek
       const { data: entries, error } = await supabase
         .from('skipped_items')
         .select('*')
         .eq('user_id', userId)
         .order('created_at', { ascending: false });
       
       if (error) throw error;
       
       const totalSavings = entries.reduce((sum, e) => sum + e.price, 0);

       if (entries.length === 0) {
           return res.json({ 
             insight: "İlk vazgeçişini ekle ve tasarruf etmeye başla!", 
             savings: totalSavings, 
             insightValue: 0 
           });
       }
       
       const aiClient = getAI();
       const recentEntries = entries.slice(0, 15);
       
       // Kategori analizi
       const categoryCount: Record<string, number> = {};
       recentEntries.forEach(e => {
         categoryCount[e.ai_category] = (categoryCount[e.ai_category] || 0) + 1;
       });
       const topCategory = Object.entries(categoryCount).sort((a, b) => b[1] - a[1])[0]?.[0] || 'Diğer';
       
       // Saat analizi (basit - sadece örnek)
       const mostActiveTimeRange = '19:00 - 23:00'; // Gerçek uygulamada created_at'tan hesaplanır
       
       // Detaylı AI Raporu
       const detailedPrompt = `Bir tasarruf uygulamasında kullanıcı satın almaktan vazgeçtiği ürünleri kaydediyor.

Kullanıcının son ${recentEntries.length} vazgeçişi:
${JSON.stringify(recentEntries.map(e => ({ 
  ürün: e.item_name, 
  fiyat: e.price, 
  kategori: e.ai_category,
  tarih: e.created_at
})), null, 2)}

Toplam tasarruf: ${totalSavings} TL
En çok vazgeçilen kategori: ${topCategory}
En aktif zaman: ${mostActiveTimeRange}

Sen bir kişisel finans koçusun. Lütfen 3 farklı içgörü üret ve JSON formatında döndür:

{
  "weeklyInsight": "Haftalık içgörü metni (1-2 cümle, motive edici)",
  "budgetAdvice": "Bütçe tavsiyesi (2-3 cümle, pratik öneriler içeren)",
  "personalizedReport": "Kişiselleştirilmiş analiz raporu (2-3 cümle, davranış kalıplarına odaklı)"
}

SADECE JSON döndür, başka metin ekleme.`;

       const response = await aiClient.models.generateContent({
         model: 'gemini-2.5-flash',
         contents: detailedPrompt,
       });

       // JSON parse
       let aiResponse;
       try {
         const text = response.text?.trim() || '{}';
         // JSON'u çıkar (``` işaretlerini temizle)
         const jsonText = text.replace(/```json\n?/g, '').replace(/```\n?/g, '');
         aiResponse = JSON.parse(jsonText);
       } catch (e) {
         console.error('JSON parse error:', e);
         aiResponse = {
           weeklyInsight: response.text?.trim() || "Harika gidiyorsun!",
           budgetAdvice: "Vazgeçiş alışkanlığını sürdürerek hedeflerine ulaşabilirsin.",
           personalizedReport: "Tasarruf davranışların gelişiyor."
         };
       }

       res.json({ 
           insight: aiResponse.weeklyInsight || "Harika gidiyorsun, tasarruf etmeye devam et!",
           savings: totalSavings,
           insightValue: entries.length > 0 ? entries[0].price : 0,
           weeklyReport: {
             summaryText: aiResponse.weeklyInsight || "Bu hafta harika gidiyorsun!",
             topCategory: topCategory,
             mostActiveTimeRange: mostActiveTimeRange
           },
           budgetAdvice: aiResponse.budgetAdvice || "Vazgeçiş alışkanlığını sürdürerek hedeflerine ulaşabilirsin.",
           personalizedReport: {
             summaryText: aiResponse.personalizedReport || "Tasarruf davranışların gelişiyor.",
             topCategory: topCategory,
             topCategoryChangePercent: 15,
             mostActiveTimeRange: mostActiveTimeRange,
             giveUpRateChangePercent: 20,
             estimatedSavings: Math.round(totalSavings * 1.3)
           }
       });
    } catch (error: any) {
        console.error('Error generating detailed insights:', error);
        res.status(500).json({ error: error.message || 'Failed to generate insights' });
    }
});

// Günün Motivasyonu — kullanıcı başına günde bir kez AI ile üretilip önbelleklenir.
const motivationCache = new Map<string, { date: string; quote: string }>();
const MOTIVATION_THEMES = [
  'sabırlı olmak', 'küçük adımlar', 'özgürlük', 'gelecek', 'disiplin',
  'anlık zevklerden vazgeçmek', 'hayaller', 'bilinçli tüketim', 'irade gücü', 'birikim',
];

app.get('/api/motivation', async (req, res) => {
  try {
    const userId = req.headers['x-user-id'] as string || '00000000-0000-0000-0000-000000000000';
    const today = new Date().toISOString().slice(0, 10);
    const cached = motivationCache.get(userId);
    if (cached && cached.date === today) {
      return res.json({ quote: cached.quote });
    }

    const theme = MOTIVATION_THEMES[Math.floor(Math.random() * MOTIVATION_THEMES.length)];
    const aiClient = getAI();
    const prompt = `Bir tasarruf/birikim uygulaması için "${theme}" temasına dokunan, Türkçe, ilham verici, tek cümlelik bir "günün sözü" üret. Tırnak işareti veya başka açıklama ekleme, sadece sözü döndür.`;

    const response = await aiClient.models.generateContent({
      model: 'gemini-2.5-flash',
      contents: prompt,
    });

    const quote = response.text?.trim().replace(/^["']|["']$/g, '') ||
      'Küçük tasarruflar, büyük özgürlüklerin temelidir.';

    motivationCache.set(userId, { date: today, quote });
    res.json({ quote });
  } catch (error) {
    console.error('Error generating motivation quote:', error);
    res.json({
      quote: 'Küçük tasarruflar, büyük özgürlüklerin temelidir. Bugün vazgeçtiğin her şey, yarınki hayaline bir adım daha yaklaştırır.',
    });
  }
});

// --- Hedef Belirleme (Savings Goal) ---
// Ayrı bir tablo yok; hedef bilgisi doğrudan public.users satırında tutulur
// (savings_goal, goal_title, goal_notified, completed_goals). Yeni hedef
// eklerken eski hedef tamamlanmışsa onu completed_goals geçmişine ekliyoruz
// ve goal_notified'ı false'a resetliyoruz (n8n otomasyonu tekrar mail
// atabilsin diye). Not: Supabase tarafındaki set_new_goal(...) RPC'si
// "column \"id\" does not exist" hatası veriyordu (fonksiyon users tablosuna
// olmayan "id" kolonuyla erişmeye çalışıyordu — asıl PK "user_id"), bu yüzden
// mantık doğrudan burada (supabase-js ile) uygulanıyor.
app.get('/api/goals', async (req, res) => {
  try {
    const userId = req.headers['x-user-id'] as string || '00000000-0000-0000-0000-000000000000';
    await ensureUserRow(userId);

    const { data: userRow, error: userErr } = await supabase
      .from('users')
      .select('total_saved, savings_goal, goal_title')
      .eq('user_id', userId)
      .single();
    if (userErr) throw userErr;

    const totalSaved = Number(userRow?.total_saved || 0);
    const targetAmount = userRow?.savings_goal != null ? Number(userRow.savings_goal) : null;

    if (!targetAmount) {
      return res.json(null);
    }

    res.json({
      title: userRow?.goal_title || 'Hedefim',
      target_amount: targetAmount,
      is_completed: totalSaved >= targetAmount,
    });
  } catch (error: any) {
    console.error('Error fetching goals:', error);
    res.status(500).json({ error: error.message || 'Hedefler alınamadı' });
  }
});

app.post('/api/goals', async (req, res) => {
  try {
    const userId = req.headers['x-user-id'] as string || '00000000-0000-0000-0000-000000000000';
    await ensureUserRow(userId);

    const title = typeof req.body.title === 'string' ? req.body.title.trim() : '';
    const targetAmount = Number(req.body.targetAmount);

    if (!title) {
      return res.status(400).json({ error: 'Hedef başlığı gerekli.' });
    }
    if (!targetAmount || targetAmount <= 0) {
      return res.status(400).json({ error: 'Geçerli bir hedef tutarı girilmeli.' });
    }

    const { data: userRow, error: userErr } = await supabase
      .from('users')
      .select('total_saved, savings_goal, goal_title, completed_goals')
      .eq('user_id', userId)
      .single();
    if (userErr) throw userErr;

    const totalSaved = Number(userRow?.total_saved || 0);
    const currentTarget = userRow?.savings_goal != null ? Number(userRow.savings_goal) : null;

    if (currentTarget && totalSaved < currentTarget) {
      return res.status(400).json({ error: 'Yeni bir hedef eklemeden önce mevcut hedefi tamamlamalısın.' });
    }

    // Eski hedef varsa (tamamlanmış olmalı, aksi halde yukarıda engellenir) geçmişe ekle.
    const completedGoals = Array.isArray(userRow?.completed_goals) ? userRow.completed_goals : [];
    if (currentTarget) {
      completedGoals.push({
        title: userRow?.goal_title || 'Hedefim',
        target_amount: currentTarget,
        completed_at: new Date().toISOString(),
      });
    }

    const { data, error } = await supabase
      .from('users')
      .update({
        goal_title: title,
        savings_goal: targetAmount,
        goal_notified: false,
        completed_goals: completedGoals,
      })
      .eq('user_id', userId)
      .select('savings_goal, goal_title, total_saved')
      .single();
    if (error) throw error;

    res.status(201).json({
      title: data.goal_title,
      target_amount: Number(data.savings_goal),
      is_completed: Number(data.total_saved || 0) >= Number(data.savings_goal),
    });
  } catch (error: any) {
    console.error('Error adding goal:', error);
    res.status(500).json({ error: error.message || 'Hedef eklenemedi' });
  }
});

// --- Vite Middleware (Development) / Static Serving (Production) ---
async function startServer() {
  const PORT = 3000;

  if (process.env.NODE_ENV !== 'production') {
    const vite = await createViteServer({
      server: { middlewareMode: true },
      appType: 'spa',
    });
    app.use(vite.middlewares);
  } else {
    const distPath = path.join(process.cwd(), 'dist');
    app.use(express.static(distPath));
    // Support for both Express 4 and 5 catch-all
    app.get('*', (req, res) => {
      res.sendFile(path.join(distPath, 'index.html'));
    });
  }

  app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server running on http://localhost:${PORT}`);
  });
}

startServer();
