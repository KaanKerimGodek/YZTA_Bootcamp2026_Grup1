import React, { useMemo } from 'react';
import { PiggyBank, Target, TrendingUp } from 'lucide-react';
import { Entry } from '../types';
import { getCategoryStyle } from './Home';
import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer } from 'recharts';

interface StatsProps {
  entries: Entry[];
}

export function Stats({ entries }: StatsProps) {
  
  const formatMoney = (amount: number) => {
    return new Intl.NumberFormat('tr-TR', { style: 'currency', currency: 'TRY', maximumFractionDigits: 0 }).format(amount);
  };

  const totalSaved = useMemo(() => entries.reduce((sum, e) => sum + e.amount, 0), [entries]);
  const averageSaved = useMemo(() => entries.length > 0 ? totalSaved / entries.length : 0, [totalSaved, entries.length]);
  
  const categoryStats = useMemo(() => {
    const stats: Record<string, number> = {};
    entries.forEach(e => {
      stats[e.category] = (stats[e.category] || 0) + e.amount;
    });
    
    return Object.entries(stats).sort((a, b) => b[1] - a[1]);
  }, [entries]);

  const maxCategoryAmount = categoryStats.length > 0 ? categoryStats[0][1] : 1;

  // New Data Computations
  const top3Entries = useMemo(() => {
    return [...entries].sort((a, b) => b.amount - a.amount).slice(0, 3);
  }, [entries]);

  const top3CategoriesByCount = useMemo(() => {
    const counts: Record<string, number> = {};
    entries.forEach(e => {
      counts[e.category] = (counts[e.category] || 0) + 1;
    });
    return Object.entries(counts).sort((a, b) => b[1] - a[1]).slice(0, 3);
  }, [entries]);

  const dailyData = useMemo(() => {
    const days: Record<string, { dayName: string; total: number; timestamp: number }> = {};
    entries.forEach(e => {
      const date = new Date(e.date);
      const dayName = date.toLocaleDateString('tr-TR', { weekday: 'short' });
      const dateKey = date.toISOString().split('T')[0];
      
      if (!days[dateKey]) {
        days[dateKey] = { dayName, total: 0, timestamp: date.getTime() };
      }
      days[dateKey].total += e.amount;
    });
    
    // Get last 7 days of data
    return Object.values(days)
      .sort((a, b) => a.timestamp - b.timestamp)
      .slice(-7)
      .map(d => ({
        name: d.dayName,
        toplam: d.total
      }));
  }, [entries]);

  return (
    <div className="flex flex-col gap-8 animate-in fade-in slide-in-from-bottom-4 duration-500">
      <h2 className="text-2xl font-bold text-slate-800">İstatistikler</h2>
      
      {/* Detailed Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        
        {/* Toplam Card */}
        <div className="bg-white border border-slate-200 rounded-3xl p-6 shadow-sm flex flex-col gap-4">
           <div className="flex flex-col gap-2">
             <div className="w-10 h-10 rounded-full bg-blue-50 text-blue-600 flex items-center justify-center">
               <PiggyBank size={20} />
             </div>
             <div className="font-extrabold text-3xl text-slate-800 mt-2">{formatMoney(totalSaved)}</div>
             <div className="text-sm font-medium text-slate-400">Toplam</div>
           </div>
           
           <div className="mt-2 pt-4 border-t border-slate-100 flex flex-col gap-3">
             <h4 className="text-xs font-bold text-slate-400 uppercase">En Yüksek Vazgeçişler</h4>
             {top3Entries.length > 0 ? top3Entries.map(entry => (
               <div key={entry.id} className="flex justify-between items-center text-sm">
                 <span className="text-slate-600 truncate mr-2">{entry.title}</span>
                 <span className="font-bold text-slate-800 shrink-0">{formatMoney(entry.amount)}</span>
               </div>
             )) : <span className="text-sm text-slate-400">Veri yok</span>}
           </div>
        </div>
        
        {/* Vazgeçiş Count Card */}
        <div className="bg-white border border-slate-200 rounded-3xl p-6 shadow-sm flex flex-col gap-4">
           <div className="flex flex-col gap-2">
             <div className="w-10 h-10 rounded-full bg-emerald-50 text-emerald-600 flex items-center justify-center">
               <Target size={20} />
             </div>
             <div className="font-extrabold text-3xl text-slate-800 mt-2">{entries.length}</div>
             <div className="text-sm font-medium text-slate-400">Vazgeçiş</div>
           </div>
           
           <div className="mt-2 pt-4 border-t border-slate-100 flex flex-col gap-3">
             <h4 className="text-xs font-bold text-slate-400 uppercase">En Çok Vazgeçilenler</h4>
             {top3CategoriesByCount.length > 0 ? top3CategoriesByCount.map(([cat, count]) => {
                const style = getCategoryStyle(cat);
                const Icon = style.icon;
                return (
                 <div key={cat} className="flex justify-between items-center text-sm">
                   <div className="flex items-center gap-2 text-slate-600">
                     <Icon size={14} className={style.text} />
                     <span>{cat}</span>
                   </div>
                   <span className="font-bold text-slate-800">{count} kez</span>
                 </div>
               )
             }) : <span className="text-sm text-slate-400">Veri yok</span>}
           </div>
        </div>
        
        {/* Ortalama Card with Chart */}
        <div className="bg-white border border-slate-200 rounded-3xl p-6 shadow-sm flex flex-col gap-4">
           <div className="flex flex-col gap-2">
             <div className="w-10 h-10 rounded-full bg-orange-50 text-orange-600 flex items-center justify-center">
               <TrendingUp size={20} />
             </div>
             <div className="font-extrabold text-3xl text-slate-800 mt-2">{formatMoney(averageSaved)}</div>
             <div className="text-sm font-medium text-slate-400">Ortalama</div>
           </div>
           
           <div className="mt-2 pt-4 border-t border-slate-100 flex flex-col gap-2 h-full justify-end">
              <div className="h-24 w-full">
                {dailyData.length > 0 ? (
                  <ResponsiveContainer width="100%" height="100%">
                    <BarChart data={dailyData} margin={{ top: 0, right: 0, left: -25, bottom: 0 }}>
                      <XAxis dataKey="name" tick={{ fontSize: 10, fill: '#94a3b8' }} axisLine={false} tickLine={false} />
                      <YAxis tick={{ fontSize: 10, fill: '#94a3b8' }} axisLine={false} tickLine={false} tickFormatter={(val) => `₺${val}`} />
                      <Tooltip 
                        cursor={{ fill: '#f1f5f9' }}
                        contentStyle={{ borderRadius: '8px', border: 'none', boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1)' }}
                        formatter={(value: number) => [formatMoney(value), 'Toplam']}
                      />
                      <Bar dataKey="toplam" fill="#f97316" radius={[4, 4, 0, 0]} />
                    </BarChart>
                  </ResponsiveContainer>
                ) : (
                  <div className="h-full flex items-center justify-center text-sm text-slate-400">Grafik için veri bekleniyor</div>
                )}
              </div>
           </div>
        </div>

      </div>

      {/* Category Breakdown */}
      <div>
        <h3 className="text-xl font-bold text-slate-800 mb-4">Kategoriye Göre</h3>
        <div className="bg-white border border-slate-200 rounded-3xl p-6 md:p-8 shadow-sm flex flex-col gap-6">
          {categoryStats.length === 0 ? (
            <p className="text-slate-500 text-center py-4">Henüz veri yok.</p>
          ) : (
            categoryStats.map(([category, amount]) => {
              const style = getCategoryStyle(category);
              const percentage = Math.max(5, (amount / maxCategoryAmount) * 100);
              
              return (
                <div key={category}>
                  <div className="flex justify-between items-center mb-2">
                     <div className="flex items-center gap-3">
                        <div className={`w-10 h-10 rounded-full flex items-center justify-center ${style.bg} ${style.text}`}>
                           <style.icon size={18} />
                        </div>
                        <span className="font-bold text-slate-700">{category}</span>
                     </div>
                     <span className="font-bold text-slate-800">{formatMoney(amount)}</span>
                  </div>
                  {/* Progress bar */}
                  <div className="h-2 w-full bg-slate-100 rounded-full overflow-hidden ml-[52px]" style={{ width: 'calc(100% - 52px)' }}>
                     <div 
                       className={`h-full rounded-full ${style.barBg || 'bg-slate-500'}`} 
                       style={{ width: `${percentage}%` }}
                     />
                  </div>
                </div>
              );
            })
          )}
        </div>
      </div>

    </div>
  );
}
