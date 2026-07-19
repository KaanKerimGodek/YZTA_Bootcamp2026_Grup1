import express from 'express';
import path from 'path';
import { createServer as createViteServer } from 'vite';
import { GoogleGenAI } from '@google/genai';

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

// --- In-Memory DB ---
export interface Entry {
  id: string;
  title: string;
  amount: number;
  category: string;
  date: string; // ISO date
}

let entries: Entry[] = [
  { id: '1', title: 'Vazgeçilen Getir Büyük Siparişi', amount: 350, category: 'Yemek', date: new Date().toISOString() },
  { id: '2', title: 'Taksi Yerine Yürüyerek Dönüş', amount: 220, category: 'Ulaşım', date: new Date(Date.now() - 2 * 3600000).toISOString() },
  { id: '3', title: 'İptal Edilen Netflix Aboneliği', amount: 149, category: 'Eğlence', date: new Date(Date.now() - 24 * 3600000).toISOString() },
  { id: '4', title: 'Trendyol\'da Sepette Bırakılan Tişört', amount: 450, category: 'Giyim', date: new Date(Date.now() - 2 * 86400000).toISOString() },
  { id: '5', title: 'Dışarıdan Kahve Söylemekten Vazgeçiş', amount: 120, category: 'İçecek', date: new Date(Date.now() - 4 * 86400000).toISOString() },
  { id: '6', title: 'Alınmayan Amazon Prime Aboneliği', amount: 39, category: 'Teknoloji', date: new Date(Date.now() - 5 * 86400000).toISOString() },
  { id: '7', title: 'Yemeksepeti Siparişi Yerine Evde Yemek', amount: 280, category: 'Yemek', date: new Date(Date.now() - 6 * 86400000).toISOString() },
  { id: '8', title: 'Steam İndiriminde Alınmayan Oyunlar', amount: 650, category: 'Eğlence', date: new Date(Date.now() - 7 * 86400000).toISOString() },
  { id: '9', title: 'Pahalı Yüz Kremi Almaktan Vazgeçiş', amount: 850, category: 'Kişisel Bakım', date: new Date(Date.now() - 8 * 86400000).toISOString() }
];

const CATEGORIES = ['Yemek', 'İçecek', 'Giyim', 'Eğlence', 'Ulaşım', 'Kişisel Bakım', 'Teknoloji', 'Diğer'];

// --- API Routes ---

app.get('/api/entries', (req, res) => {
  res.json(entries.sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime()));
});

app.post('/api/entries', async (req, res) => {
  try {
    const { title, amount, category } = req.body;
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

    const newEntry: Entry = {
      id: Math.random().toString(36).substring(7),
      title,
      amount: Number(amount),
      category: finalCategory,
      date: new Date().toISOString()
    };

    entries.push(newEntry);
    res.status(201).json(newEntry);
  } catch (error) {
    console.error('Error adding entry:', error);
    res.status(500).json({ error: 'Failed to add entry' });
  }
});

app.get('/api/insights', async (req, res) => {
    try {
       const totalSavings = entries.reduce((sum, e) => sum + e.amount, 0);

       if (entries.length === 0) {
           return res.json({ insight: "İlk vazgeçişini ekle ve tasarruf etmeye başla!", savings: totalSavings, insightValue: 0 });
       }
       
       const aiClient = getAI();
       const recentEntries = entries.slice(0, 10); // get newest 10 (sorted newest first in UI but array is push based, so let's just send all)
       
       const prompt = `Bir tasarruf uygulamasındayız. Kullanıcı satın almaktan vazgeçtiği ürünleri buraya kaydediyor.
Son vazgeçişleri şunlar:
${JSON.stringify(recentEntries, null, 2)}

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
           insightValue: entries[entries.length - 1].amount // Just showing the last saved amount for UI flair
       });
    } catch (error) {
        console.error('Error generating insight:', error);
        
        // Fallback for AI Quota/Rate Limit Errors
        const totalSavings = entries.reduce((sum, e) => sum + e.amount, 0);
        res.json({ 
           insight: "Geçen aya göre harcamaların azaldı. Bu hızla devam edersen hedeflerine çok daha erken ulaşabilirsin!",
           savings: totalSavings,
           insightValue: entries.length > 0 ? entries[entries.length - 1].amount : 0
        });
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
