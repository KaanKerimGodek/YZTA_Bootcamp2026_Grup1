import React, { useMemo, useState } from 'react';
import {
  Sparkles,
  Clock,
  Tag,
  PiggyBank,
  Target,
  Trophy,
  Bell,
  CheckCircle2,
  Brain,
  CalendarClock,
  TrendingUp,
  Flag,
} from 'lucide-react';
import { Entry, InsightData, InsightPeriod } from '../types';
import {
  MOCK_ACHIEVEMENTS,
  MOCK_BEHAVIORAL_GROWTH,
  MOCK_GOALS,
  MOCK_INSIGHT_REPORTS,
  MOCK_MONTHLY_TREND,
  MOCK_SAVINGS_PATTERN,
  MOCK_TRIGGER_SLOTS,
} from '../mockInsights';

interface InsightsProps {
  entries: Entry[];
  insightData: InsightData | null;
}

const goalTypeLabel: Record<string, string> = {
  tasarruf: 'Tasarruf Hedefi',
  birikim: 'Birikim Hedefi',
  aliskanlik: 'Alışkanlık Hedefi',
};

export function Insights({ entries, insightData }: InsightsProps) {
  const [period, setPeriod] = useState<InsightPeriod>('weekly');
  const report = MOCK_INSIGHT_REPORTS[period];

  const formatMoney = (amount: number) => {
    return new Intl.NumberFormat('tr-TR', { style: 'currency', currency: 'TRY', maximumFractionDigits: 0 }).format(amount);
  };

  const maxTriggerCount = useMemo(
    () => Math.max(...MOCK_TRIGGER_SLOTS.map((t) => t.count), 1),
    []
  );

  return (
    <div className="flex flex-col gap-8 animate-in fade-in slide-in-from-bottom-4 duration-500">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-end sm:justify-between gap-4">
        <div>
          <h2 className="text-2xl font-bold text-slate-800 flex items-center gap-2">
            <Sparkles className="text-amber-400" size={22} />
            İçgörü
          </h2>
          <p className="text-sm text-slate-400 mt-1">
            Vazgeçiş alışkanlıklarına dair kişiselleştirilmiş analiz ve öneriler.
          </p>
        </div>

        {/* Period Toggle */}
        <div className="inline-flex bg-slate-100 rounded-xl p-1 self-start sm:self-auto">
          <button
            onClick={() => setPeriod('weekly')}
            className={`px-4 py-2 text-sm font-semibold rounded-lg transition-colors ${
              period === 'weekly' ? 'bg-white text-emerald-600 shadow-sm' : 'text-slate-500 hover:text-slate-700'
            }`}
          >
            Haftalık
          </button>
          <button
            onClick={() => setPeriod('monthly')}
            className={`px-4 py-2 text-sm font-semibold rounded-lg transition-colors ${
              period === 'monthly' ? 'bg-white text-emerald-600 shadow-sm' : 'text-slate-500 hover:text-slate-700'
            }`}
          >
            Aylık
          </button>
        </div>
      </div>

      {/* Kişiselleştirilmiş İçgörü Raporu */}
      <div className="bg-slate-800 rounded-3xl p-6 md:p-8 text-slate-200 shadow-sm relative overflow-hidden">
        <div className="relative z-10">
          <div className="flex items-center gap-2 mb-4">
            <span className="text-amber-400 font-bold flex items-center gap-1">
              <Brain size={16} /> AI
            </span>
            <h3 className="font-semibold">Kişiselleştirilmiş İçgörü Raporu · {report.periodLabel}</h3>
          </div>
          <p className="text-slate-100 leading-relaxed italic mb-6">"{report.summaryText}"</p>

          {/* Örnek Analiz kutusu */}
          <div className="bg-white/5 border border-white/10 rounded-2xl p-5 grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div className="flex items-center gap-3">
              <CheckCircle2 size={18} className="text-emerald-400 shrink-0" />
              <span className="text-sm text-slate-200">
                En çok vazgeçilen kategori: <strong className="text-white">{report.topCategory}</strong>{' '}
                <span className="text-emerald-400">(+{report.topCategoryChangePercent}%)</span>
              </span>
            </div>
            <div className="flex items-center gap-3">
              <CheckCircle2 size={18} className="text-emerald-400 shrink-0" />
              <span className="text-sm text-slate-200">
                En aktif saat: <strong className="text-white">{report.mostActiveTimeRange}</strong>
              </span>
            </div>
            <div className="flex items-center gap-3">
              <CheckCircle2 size={18} className="text-emerald-400 shrink-0" />
              <span className="text-sm text-slate-200">
                Vazgeçme oranı: <strong className="text-white">%{report.giveUpRateChangePercent} artış</strong>
              </span>
            </div>
            <div className="flex items-center gap-3">
              <CheckCircle2 size={18} className="text-emerald-400 shrink-0" />
              <span className="text-sm text-slate-200">
                Tahmini birikim: <strong className="text-white">{formatMoney(report.estimatedSavings)}</strong>
              </span>
            </div>
          </div>

          {insightData?.insight && (
            <p className="text-xs text-slate-400 mt-4">
              Son AI tavsiyesi: <span className="italic">"{insightData.insight}"</span>
            </p>
          )}
        </div>
        <div className="absolute -right-10 -bottom-10 w-40 h-40 bg-white/5 rounded-full blur-3xl z-0"></div>
      </div>

      {/* Davranışsal Gelişim & Tasarruf Kalıpları */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6 items-stretch">
        <div className="flex flex-col">
          <h3 className="text-lg font-bold text-slate-800 mb-4">Davranışsal Gelişim</h3>
          <div className="bg-white border border-slate-200 rounded-3xl p-6 shadow-sm flex flex-col gap-3 flex-1">
            <div className="w-10 h-10 rounded-xl bg-emerald-50 text-emerald-600 flex items-center justify-center">
              <TrendingUp size={20} />
            </div>
            <p className="text-xl font-extrabold text-slate-800">
              %{MOCK_BEHAVIORAL_GROWTH.improvementPercent} daha başarılı
            </p>
            <p className="text-sm text-slate-400">
              {MOCK_BEHAVIORAL_GROWTH.periodLabel} {MOCK_BEHAVIORAL_GROWTH.giveUpCount} vazgeçiş ·{' '}
              {formatMoney(MOCK_BEHAVIORAL_GROWTH.savings)} tasarruf
            </p>
          </div>
        </div>
        <div className="flex flex-col">
          <h3 className="text-lg font-bold text-slate-800 mb-4">Tasarruf Kalıpları</h3>
          <div className="bg-white border border-slate-200 rounded-3xl p-6 shadow-sm flex flex-col gap-3 flex-1">
            <div className="w-10 h-10 rounded-xl bg-blue-50 text-blue-600 flex items-center justify-center">
              <Clock size={20} />
            </div>
            <p className="text-xl font-extrabold text-slate-800">{MOCK_SAVINGS_PATTERN.timeRange}</p>
            <p className="text-sm text-slate-400">{MOCK_SAVINGS_PATTERN.description}</p>
          </div>
        </div>
      </div>

      {/* Aylık Trend */}
      <div className="relative">
        <h3 className="text-lg font-bold text-slate-800 mb-4">Aylık Trend</h3>
        <div className="bg-white border border-slate-200 rounded-3xl p-6 md:p-8 shadow-sm flex flex-col gap-4">
          <div className="flex items-start gap-4">
            <div className="w-10 h-10 rounded-xl bg-emerald-50 text-emerald-600 flex items-center justify-center shrink-0">
              <Flag size={20} />
            </div>
            <div>
              <h4 className="font-bold text-slate-800">{MOCK_MONTHLY_TREND.title}</h4>
              <p className="text-sm text-slate-500 mt-1">{MOCK_MONTHLY_TREND.description}</p>
            </div>
          </div>
          <div className="h-3 w-full bg-slate-100 rounded-full overflow-hidden">
            <div
              className="h-full bg-emerald-500 rounded-full transition-all duration-700"
              style={{ width: `${Math.min(100, (MOCK_MONTHLY_TREND.current / MOCK_MONTHLY_TREND.target) * 100)}%` }}
            />
          </div>
          <div className="flex justify-between text-sm">
            <span className="font-bold text-emerald-600">{formatMoney(MOCK_MONTHLY_TREND.current)} tasarruf</span>
            <span className="text-slate-400">{formatMoney(MOCK_MONTHLY_TREND.target)} hedef</span>
          </div>
        </div>
      </div>

      {/* AI Analiz Pipeline (mock) */}
      <div>
        <h3 className="text-lg font-bold text-slate-800 mb-4">AI Analiz Adımları</h3>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
          {[
            { icon: Tag, label: 'Kategori Sınıflandırma', desc: 'Otomatik kategori ataması' },
            { icon: CalendarClock, label: 'Zaman Analizi', desc: 'Saat & gün bazlı davranış' },
            { icon: Clock, label: 'Tetikleyici Analizi', desc: 'Zayıf anların tespiti' },
            { icon: Sparkles, label: 'Insights Üretimi', desc: 'Doğal dilde özet metin' },
          ].map((step) => (
            <div key={step.label} className="bg-white border border-slate-200 rounded-2xl p-4 flex flex-col gap-2 shadow-sm">
              <div className="w-9 h-9 rounded-lg bg-emerald-50 text-emerald-600 flex items-center justify-center">
                <step.icon size={18} />
              </div>
              <span className="text-sm font-bold text-slate-700">{step.label}</span>
              <span className="text-xs text-slate-400">{step.desc}</span>
            </div>
          ))}
        </div>
      </div>

      {/* Tetikleyici Analizi Detayı */}
      <div>
        <h3 className="text-lg font-bold text-slate-800 mb-4">Zayıf Anların — Tetikleyici Analizi</h3>
        <div className="bg-white border border-slate-200 rounded-3xl p-6 md:p-8 shadow-sm flex flex-col gap-4">
          {MOCK_TRIGGER_SLOTS.map((slot) => (
            <div key={slot.label}>
              <div className="flex justify-between items-center mb-1.5">
                <span className="text-sm font-medium text-slate-600 flex items-center gap-2">
                  <Clock size={14} className="text-slate-400" />
                  {slot.label}
                </span>
                <span className="text-sm font-bold text-slate-800">{slot.count} kez</span>
              </div>
              <div className="h-2 w-full bg-slate-100 rounded-full overflow-hidden">
                <div
                  className="h-full bg-amber-400 rounded-full"
                  style={{ width: `${Math.max(8, (slot.count / maxTriggerCount) * 100)}%` }}
                />
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Hedef Belirleme */}
      <div>
        <h3 className="text-lg font-bold text-slate-800 mb-4">Hedef Belirleme</h3>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {MOCK_GOALS.map((goal) => {
            const progress = Math.min(100, (goal.current / goal.target) * 100);
            const reached = goal.current >= goal.target;
            const unit = goal.unit ?? '₺';
            return (
              <div key={goal.id} className="bg-white border border-slate-200 rounded-3xl p-6 shadow-sm flex flex-col gap-3">
                <div className="flex items-center gap-2">
                  <div className="w-9 h-9 rounded-lg bg-blue-50 text-blue-600 flex items-center justify-center">
                    <Target size={16} />
                  </div>
                  <div>
                    <p className="text-xs font-bold text-slate-400 uppercase">{goalTypeLabel[goal.type]}</p>
                    <h4 className="text-sm font-bold text-slate-800">{goal.title}</h4>
                  </div>
                </div>
                <div className="flex justify-between items-end">
                  <span className="text-xl font-extrabold text-slate-800">
                    {unit === '₺' ? formatMoney(goal.current) : `${goal.current} ${unit}`}
                  </span>
                  <span className="text-xs text-slate-400">
                    / {unit === '₺' ? formatMoney(goal.target) : `${goal.target} ${unit}`}
                  </span>
                </div>
                <div className="h-2.5 w-full bg-slate-100 rounded-full overflow-hidden">
                  <div
                    className={`h-full rounded-full transition-all duration-700 ${reached ? 'bg-emerald-500' : 'bg-blue-500'}`}
                    style={{ width: `${progress}%` }}
                  />
                </div>
                <span className={`text-xs font-semibold ${reached ? 'text-emerald-600' : 'text-slate-400'}`}>
                  {reached ? 'Hedefe ulaşıldı! 🎉' : `Hedefe %${Math.round(progress)} yakınsın, devam et!`}
                </span>
              </div>
            );
          })}
        </div>
      </div>

      {/* Başarı & Bildirim */}
      <div>
        <h3 className="text-lg font-bold text-slate-800 mb-4 flex items-center gap-2">
          <Trophy size={18} className="text-amber-500" />
          Başarı &amp; Rozetler
        </h3>
        <div className="bg-white border border-slate-200 rounded-3xl p-6 md:p-8 shadow-sm">
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
            {MOCK_ACHIEVEMENTS.map((ach) => (
              <div
                key={ach.id}
                className={`rounded-2xl p-4 flex flex-col items-center text-center gap-2 border ${
                  ach.unlocked ? 'bg-emerald-50 border-emerald-200' : 'bg-slate-50 border-slate-200 opacity-60'
                }`}
              >
                <span className="text-3xl">{ach.emoji}</span>
                <span className="text-sm font-bold text-slate-700">{ach.title}</span>
                <span className="text-xs text-slate-400 leading-tight">{ach.description}</span>
              </div>
            ))}
          </div>
          <div className="flex items-center gap-3 bg-emerald-50 border border-emerald-200 rounded-2xl px-4 py-3">
            <Bell size={18} className="text-emerald-600 shrink-0" />
            <p className="text-sm text-emerald-700">
              <strong>Tebrikler! 🎉</strong> 3 gün üst üste vazgeçtin ve "🌙 Gece Bekçisi" rozetini kazandın. Küçük
              adımların büyük bir tasarrufa dönüşüyor, bu hızla devam et!
            </p>
          </div>
        </div>
      </div>

      {/* Alt bilgi: cüzdan bağlantısı */}
      <div className="flex items-center gap-3 text-sm text-slate-400">
        <PiggyBank size={16} />
        <span>
          Toplam kayıtlı vazgeçiş: <strong className="text-slate-600">{entries.length}</strong> · Bu içgörüler
          Tasarruf Cüzdanı verileriyle birlikte güncellenir.
        </span>
      </div>
    </div>
  );
}
