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
  RefreshCw,
} from 'lucide-react';
import { Entry, InsightData, InsightPeriod, SavingsGoal } from '../types';
import { MOCK_INSIGHT_REPORTS } from '../mockInsights';
import {
  computeAchievements,
  computeBehavioralGrowth,
  computeMonthlyTrend,
  computeSavingsPattern,
  computeStreakDays,
  computeTriggerSlots,
} from '../insightsAnalytics';

interface InsightsProps {
  entries: Entry[];
  insightData: InsightData | null;
  goal: SavingsGoal | null;
  onAddGoal: (title: string, targetAmount: number) => Promise<void>;
  onRefreshInsights?: () => void;
  insightsLoading?: boolean;
}

export function Insights({ entries, insightData, goal, onAddGoal, onRefreshInsights, insightsLoading }: InsightsProps) {
  const [period, setPeriod] = useState<InsightPeriod>('weekly');
  const report = insightData?.personalizedReport || MOCK_INSIGHT_REPORTS[period];

  const [isAddingGoal, setIsAddingGoal] = useState(false);
  const [newGoalTitle, setNewGoalTitle] = useState('');
  const [newGoalTarget, setNewGoalTarget] = useState('');
  const [goalSubmitting, setGoalSubmitting] = useState(false);
  const [goalError, setGoalError] = useState<string | null>(null);

  const formatMoney = (amount: number) => {
    return new Intl.NumberFormat('tr-TR', { style: 'currency', currency: 'TRY', maximumFractionDigits: 0 }).format(amount);
  };

  const totalSavings = entries.reduce((sum, e) => sum + e.amount, 0);
  const activeGoal = goal && !goal.is_completed ? goal : null;

  const streakDays = useMemo(() => computeStreakDays(entries), [entries]);
  const behavioralGrowth = useMemo(() => computeBehavioralGrowth(entries), [entries]);
  const savingsPattern = useMemo(() => computeSavingsPattern(entries), [entries]);
  const monthlyTrend = useMemo(
    () => computeMonthlyTrend(entries, activeGoal?.target_amount),
    [entries, activeGoal]
  );
  const triggerSlots = useMemo(() => computeTriggerSlots(entries), [entries]);
  const achievements = useMemo(() => computeAchievements(entries, totalSavings), [entries, totalSavings]);
  const latestUnlocked = [...achievements].reverse().find((a) => a.unlocked);

  const maxTriggerCount = useMemo(
    () => Math.max(...triggerSlots.map((t) => t.count), 1),
    [triggerSlots]
  );

  const handleAddGoal = async (e: React.FormEvent) => {
    e.preventDefault();
    setGoalSubmitting(true);
    setGoalError(null);
    try {
      await onAddGoal(newGoalTitle.trim(), Number(newGoalTarget));
      setNewGoalTitle('');
      setNewGoalTarget('');
      setIsAddingGoal(false);
    } catch (err: any) {
      setGoalError(err.message || 'Hedef eklenemedi.');
    } finally {
      setGoalSubmitting(false);
    }
  };

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

      {/* Kişiselleştirilmiş İçgörü Raporu (AI) */}
      <div className="bg-slate-800 rounded-3xl p-6 md:p-8 text-slate-200 shadow-sm relative overflow-hidden">
        <div className="relative z-10">
          <div className="flex items-center justify-between mb-4">
            <div className="flex items-center gap-2">
              <span className="text-amber-400 font-bold flex items-center gap-1">
                <Brain size={16} /> AI
              </span>
              <h3 className="font-semibold">Kişiselleştirilmiş İçgörü Raporu{insightData?.personalizedReport ? ` · ${period === 'weekly' ? 'Bu Hafta' : 'Bu Ay'}` : ''}</h3>
            </div>
            <button
              onClick={onRefreshInsights}
              disabled={insightsLoading}
              className="p-2 rounded-lg hover:bg-white/10 text-slate-400 hover:text-emerald-400 transition-colors disabled:opacity-50"
              title="AI Raporunu Yenile"
            >
              <RefreshCw size={16} className={insightsLoading ? 'animate-spin' : ''} />
            </button>
          </div>
          <p className="text-slate-100 leading-relaxed italic mb-6">"{report.summaryText}"</p>

          {/* Örnek Analiz kutusu */}
          <div className="bg-white/5 border border-white/10 rounded-2xl p-5 grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div className="flex items-center gap-3">
              <CheckCircle2 size={18} className="text-emerald-400 shrink-0" />
              <span className="text-sm text-slate-200">
                En çok vazgeçilen kategori: <strong className="text-white">{report.topCategory}</strong>{' '}
                {insightData?.personalizedReport && (
                  <span className="text-emerald-400">(+{report.topCategoryChangePercent}%)</span>
                )}
              </span>
            </div>
            <div className="flex items-center gap-3">
              <CheckCircle2 size={18} className="text-emerald-400 shrink-0" />
              <span className="text-sm text-slate-200">
                En aktif saat: <strong className="text-white">{report.mostActiveTimeRange}</strong>
              </span>
            </div>
            {insightData?.personalizedReport && (
              <>
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
              </>
            )}
          </div>

          {!insightData?.personalizedReport && entries.length > 0 && (
            <div className="mt-4">
              <button
                onClick={onRefreshInsights}
                disabled={insightsLoading}
                className="text-sm font-semibold text-emerald-400 hover:text-emerald-300 transition-colors disabled:opacity-50 flex items-center gap-2"
              >
                <RefreshCw size={14} className={insightsLoading ? 'animate-spin' : ''} />
                AI Raporunu Oluştur
              </button>
            </div>
          )}

          {insightData?.insight && insightData?.personalizedReport && (
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
              %{behavioralGrowth.improvementPercent} daha başarılı
            </p>
            <p className="text-sm text-slate-400">
              {behavioralGrowth.periodLabel} {behavioralGrowth.giveUpCount} vazgeçiş ·{' '}
              {formatMoney(behavioralGrowth.savings)} tasarruf
            </p>
          </div>
        </div>
        <div className="flex flex-col">
          <h3 className="text-lg font-bold text-slate-800 mb-4">Tasarruf Kalıpları</h3>
          <div className="bg-white border border-slate-200 rounded-3xl p-6 shadow-sm flex flex-col gap-3 flex-1">
            <div className="w-10 h-10 rounded-xl bg-blue-50 text-blue-600 flex items-center justify-center">
              <Clock size={20} />
            </div>
            <p className="text-xl font-extrabold text-slate-800">{savingsPattern.timeRange}</p>
            <p className="text-sm text-slate-400">{savingsPattern.description}</p>
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
              <h4 className="font-bold text-slate-800">{monthlyTrend.title}</h4>
              <p className="text-sm text-slate-500 mt-1">{monthlyTrend.description}</p>
            </div>
          </div>
          <div className="h-3 w-full bg-slate-100 rounded-full overflow-hidden">
            <div
              className="h-full bg-emerald-500 rounded-full transition-all duration-700"
              style={{ width: `${Math.min(100, (monthlyTrend.current / monthlyTrend.target) * 100)}%` }}
            />
          </div>
          <div className="flex justify-between text-sm">
            <span className="font-bold text-emerald-600">{formatMoney(monthlyTrend.current)} tasarruf</span>
            <span className="text-slate-400">{formatMoney(monthlyTrend.target)} hedef</span>
          </div>
        </div>
      </div>

      {/* AI Analiz Pipeline */}
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
          {triggerSlots.length === 0 ? (
            <p className="text-sm text-slate-400 text-center py-4">
              Henüz yeterli veri yok. Vazgeçiş ekledikçe zayıf anların burada belirecek.
            </p>
          ) : (
            triggerSlots.map((slot) => (
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
            ))
          )}
        </div>
      </div>

      {/* Hedef Belirleme */}
      <div>
        <h3 className="text-lg font-bold text-slate-800 mb-4">Hedef Belirleme</h3>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {goal && (() => {
            const progress = Math.min(100, (totalSavings / goal.target_amount) * 100);
            const reached = goal.is_completed;
            return (
              <div className="bg-white border border-slate-200 rounded-3xl p-6 shadow-sm flex flex-col gap-3">
                <div className="flex items-center gap-2">
                  <div className="w-9 h-9 rounded-lg bg-blue-50 text-blue-600 flex items-center justify-center">
                    <Target size={16} />
                  </div>
                  <div>
                    <p className="text-xs font-bold text-slate-400 uppercase">{reached ? 'Tamamlanan Hedef' : 'Aktif Hedef'}</p>
                    <h4 className="text-sm font-bold text-slate-800">{goal.title}</h4>
                  </div>
                </div>
                <div className="flex justify-between items-end">
                  <span className="text-xl font-extrabold text-slate-800">
                    {formatMoney(Math.min(totalSavings, goal.target_amount))}
                  </span>
                  <span className="text-xs text-slate-400">/ {formatMoney(goal.target_amount)}</span>
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
          })()}

          {/* Yeni Hedef Ekle kartı */}
          <div className="bg-white border border-dashed border-slate-300 rounded-3xl p-6 shadow-sm flex flex-col gap-3">
            {activeGoal ? (
              <>
                <p className="text-xs font-bold text-slate-400 uppercase">Yeni Hedef Ekle</p>
                <p className="text-sm text-slate-500">
                  Yeni bir hedef ekleyebilmek için önce "<strong>{activeGoal.title}</strong>" hedefini tamamlaman gerekiyor.
                </p>
              </>
            ) : isAddingGoal ? (
              <form onSubmit={handleAddGoal} className="flex flex-col gap-3">
                <input
                  type="text"
                  value={newGoalTitle}
                  onChange={(e) => setNewGoalTitle(e.target.value)}
                  placeholder="Hedef başlığı (örn. MacBook Air M3)"
                  className="px-3 py-2 rounded-lg border border-slate-200 text-sm outline-none focus:border-emerald-500"
                  required
                />
                <input
                  type="number"
                  value={newGoalTarget}
                  onChange={(e) => setNewGoalTarget(e.target.value)}
                  placeholder="Ulaşılacak tutar (₺)"
                  min="1"
                  className="px-3 py-2 rounded-lg border border-slate-200 text-sm outline-none focus:border-emerald-500"
                  required
                />
                {goalError && <p className="text-xs text-red-500">{goalError}</p>}
                <div className="flex gap-2">
                  <button
                    type="submit"
                    disabled={goalSubmitting}
                    className="flex-1 bg-emerald-600 hover:bg-emerald-700 disabled:bg-emerald-300 text-white text-sm font-bold py-2 rounded-lg transition-colors"
                  >
                    {goalSubmitting ? 'Ekleniyor...' : 'Hedefi Kaydet'}
                  </button>
                  <button
                    type="button"
                    onClick={() => setIsAddingGoal(false)}
                    className="px-3 py-2 text-sm text-slate-500 hover:text-slate-700"
                  >
                    Vazgeç
                  </button>
                </div>
              </form>
            ) : (
              <button
                onClick={() => setIsAddingGoal(true)}
                className="flex flex-col items-center justify-center gap-2 h-full text-emerald-600 font-semibold text-sm py-6"
              >
                <Target size={22} />
                Yeni Hedef Ekle
              </button>
            )}
          </div>
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
            {achievements.map((ach) => (
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
              {streakDays >= 3 && latestUnlocked ? (
                <>
                  <strong>Tebrikler! 🎉</strong> {streakDays} gün üst üste vazgeçtin ve "{latestUnlocked.emoji} {latestUnlocked.title}"
                  rozetini kazandın. Küçük adımların büyük bir tasarrufa dönüşüyor, bu hızla devam et!
                </>
              ) : (
                <>Vazgeçişlerine devam et, rozetlerini ve serini burada takip edeceksin!</>
              )}
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
