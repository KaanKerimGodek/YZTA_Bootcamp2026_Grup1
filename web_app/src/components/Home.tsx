import React from 'react';
import { PiggyBank, Sparkles, Coffee, Plus, Shirt, Utensils, Gamepad2, Car, Laptop, Heart, Clock, Tag } from 'lucide-react';
import { Entry, InsightData } from '../types';
import { MOCK_INSIGHT_REPORTS, MOCK_STREAK_DAYS } from '../mockInsights';

interface HomeProps {
  entries: Entry[];
  insightData: InsightData | null;
  onAddClick?: () => void;
  onNavigateInsights?: () => void;
}

export const getCategoryStyle = (category: string) => {
  switch (category) {
    case 'İçecek': return { icon: Coffee, bg: 'bg-orange-100', text: 'text-orange-500', barBg: 'bg-orange-500' };
    case 'Teknoloji': return { icon: Laptop, bg: 'bg-cyan-100', text: 'text-cyan-500', barBg: 'bg-cyan-500' };
    case 'Giyim': return { icon: Shirt, bg: 'bg-purple-100', text: 'text-purple-500', barBg: 'bg-purple-500' };
    case 'Kişisel Bakım': return { icon: Heart, bg: 'bg-emerald-100', text: 'text-emerald-500', barBg: 'bg-emerald-500' };
    case 'Yemek': return { icon: Utensils, bg: 'bg-red-100', text: 'text-red-500', barBg: 'bg-red-500' };
    case 'Eğlence': return { icon: Gamepad2, bg: 'bg-pink-100', text: 'text-pink-500', barBg: 'bg-pink-500' };
    case 'Ulaşım': return { icon: Car, bg: 'bg-blue-100', text: 'text-blue-500', barBg: 'bg-blue-500' };
    default: return { icon: PiggyBank, bg: 'bg-slate-100', text: 'text-slate-500', barBg: 'bg-slate-500' };
  }
};

export function Home({ entries, insightData, onAddClick, onNavigateInsights }: HomeProps) {
  const formatMoney = (amount: number) => {
    return new Intl.NumberFormat('tr-TR', { style: 'currency', currency: 'TRY' }).format(amount);
  };

  // Calculate total locally so it doesn't wait for insights API to show up
  const totalSavings = entries.reduce((sum, e) => sum + e.amount, 0);
  const weeklyReport = MOCK_INSIGHT_REPORTS.weekly;

  return (
    <div className="grid grid-cols-1 md:grid-cols-12 gap-6 animate-in fade-in slide-in-from-bottom-4 duration-500 items-start">
      
      {/* Left Column: Total Savings & Actions */}
      <div className="md:col-span-5 lg:col-span-4 flex flex-col gap-6">
        
        {/* Wallet Card */}
        <div className="bg-emerald-600 rounded-3xl p-8 text-white shadow-lg shadow-emerald-200/50 relative overflow-hidden">
          <div className="relative z-10">
            <h3 className="text-emerald-100 text-sm font-medium mb-1">Toplam Tasarruf</h3>
            <div className="text-5xl font-extrabold mb-4 italic">
              {formatMoney(totalSavings)}
            </div>
            <div className="bg-white/10 rounded-xl p-3 flex items-center gap-3">
              <span className="text-2xl">🏆</span>
              <p className="text-xs leading-tight">Bu hafta harika gidiyorsun, hedeflerine yaklaşıyorsun!</p>
            </div>
          </div>
          {/* Decorative circle */}
          <div className="absolute -right-10 -bottom-10 w-40 h-40 bg-white/10 rounded-full blur-3xl z-0"></div>
        </div>

        {/* Vazgeçiş Serisi (Streak) */}
        {MOCK_STREAK_DAYS > 0 && (
          <div className="bg-orange-50 border border-orange-200 rounded-full px-4 py-2.5 text-center text-sm font-semibold text-orange-700">
            🔥🔥 {MOCK_STREAK_DAYS} gün üst üste vazgeçiş serisi!
          </div>
        )}

        {/* Haftalık İçgörü Kartı */}
        <div className="bg-white border border-slate-200 rounded-3xl p-6 shadow-sm">
          <div className="flex items-center gap-2 mb-3">
            <span className="text-amber-500 font-bold flex items-center gap-1">
              <Sparkles size={16} /> AI
            </span>
            <h4 className="font-semibold text-slate-800">Haftalık İçgörü</h4>
          </div>
          <p className="text-sm text-slate-500 leading-relaxed italic mb-4">
            "{weeklyReport.summaryText}"
          </p>
          <div className="flex flex-col gap-2 mb-4">
            <div className="flex items-center gap-2 text-sm text-slate-600">
              <Tag size={14} className="text-emerald-500" />
              En çok vazgeçilen kategori: <strong className="text-slate-800">{weeklyReport.topCategory}</strong>
            </div>
            <div className="flex items-center gap-2 text-sm text-slate-600">
              <Clock size={14} className="text-emerald-500" />
              En aktif saat: <strong className="text-slate-800">{weeklyReport.mostActiveTimeRange}</strong>
            </div>
          </div>
          <button
            onClick={onNavigateInsights}
            className="text-xs font-bold text-emerald-600 uppercase tracking-widest flex items-center justify-between w-full pt-3 border-t border-slate-100 hover:text-emerald-700 transition-colors"
          >
            <span>Tüm İçgörüleri Gör</span>
            <span>→</span>
          </button>
        </div>

        {/* AI Insights Section */}
        <div className="bg-slate-800 rounded-3xl p-6 text-slate-200 shadow-sm">
          <div className="flex items-center gap-2 mb-4">
            <span className="text-amber-400 font-bold flex items-center gap-1">
              <Sparkles size={16} /> AI
            </span>
            <h4 className="font-semibold">Kişisel Bütçe Tavsiyesi</h4>
          </div>
          <p className="text-sm text-slate-300 leading-relaxed italic">
            "{insightData?.insight || "Tasarruf verilerin yükleniyor. Senin için özel analizler hazırlıyorum..."}"
          </p>
          <div className="mt-6 pt-4 border-t border-slate-700">
            <button
              onClick={onNavigateInsights}
              className="text-xs font-bold text-emerald-400 uppercase tracking-widest flex items-center justify-between w-full hover:text-emerald-300 transition-colors"
            >
              <span>Detaylı Analizi Gör</span>
              <span>→</span>
            </button>
          </div>
        </div>
      </div>

      {/* Right Column: Recent Entries */}
      <div className="md:col-span-7 lg:col-span-8 flex flex-col gap-6">
        
        <div className="bg-white rounded-3xl p-6 md:p-8 border border-slate-200 shadow-sm">
          <div className="flex justify-between items-end mb-6">
            <div>
              <h2 className="text-xl font-bold text-slate-800">Son Vazgeçişlerin</h2>
              <p className="text-sm text-slate-400">Son 7 gün içindeki tasarrufların</p>
            </div>
            <button
              onClick={onAddClick}
              className="text-xs font-bold text-white bg-emerald-600 hover:bg-emerald-700 px-4 py-2.5 rounded-full flex items-center gap-1.5 transition-colors shrink-0"
            >
              <Plus size={14} />
              Yeni Vazgeçiş Ekle
            </button>
          </div>
          
          <div className="space-y-4 max-h-[420px] overflow-y-auto pr-2 custom-scrollbar">
            {entries.length === 0 ? (
              <p className="text-slate-500 text-center py-8 text-sm bg-slate-50 rounded-2xl border border-dashed border-slate-200">
                Henüz vazgeçiş kaydetmedin. İlk adımını şimdi at!
              </p>
            ) : (
              entries.map((entry) => {
                const style = getCategoryStyle(entry.category);
                const Icon = style.icon;
                return (
                  <div key={entry.id} className="flex items-center gap-4 p-4 rounded-2xl bg-slate-50 border border-transparent hover:border-emerald-200 hover:shadow-sm transition-all group">
                    <div className={`w-12 h-12 rounded-xl shadow-sm bg-white flex items-center justify-center group-hover:scale-105 transition-transform ${style.text}`}>
                      <Icon size={24} />
                    </div>
                    <div className="flex-1">
                      <h4 className="font-bold text-slate-700">{entry.title}</h4>
                      <p className="text-xs text-slate-400 mt-1">{entry.category}</p>
                    </div>
                    <div className="text-lg font-bold text-emerald-600">
                      + {formatMoney(entry.amount)}
                    </div>
                  </div>
                );
              })
            )}
          </div>
        </div>

        {/* Hedef Durumu & Günün Motivasyonu */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div className="bg-white rounded-3xl p-6 border border-slate-200 shadow-sm">
            <h4 className="text-xs font-bold text-slate-400 uppercase mb-4">Hedef Durumu: İtalya Tatili</h4>
            <div className="flex justify-between items-end mb-2">
              <span className="text-2xl font-bold text-slate-800">%32</span>
              <span className="text-sm text-slate-500">{formatMoney(totalSavings).replace(',00', '')} / ₺10.000</span>
            </div>
            <div className="w-full h-3 bg-slate-100 rounded-full overflow-hidden">
              <div className="h-full bg-emerald-500 transition-all duration-1000" style={{ width: `${Math.min(100, (totalSavings / 10000) * 100)}%` }}></div>
            </div>
          </div>
          <div className="bg-white rounded-3xl p-6 border border-slate-200 shadow-sm flex flex-col justify-between">
            <h4 className="text-xs font-bold text-slate-400 uppercase mb-2">Günün Motivasyonu</h4>
            <p className="text-sm font-medium text-slate-600 leading-snug italic">
              "Küçük tasarruflar, büyük özgürlüklerin temelidir. Bugün vazgeçtiğin her şey, yarınki hayaline bir adım daha yaklaştırır."
            </p>
          </div>
        </div>

      </div>
      
    </div>
  );
}
