// İçgörü sayfasındaki (AI kişiselleştirilmiş rapor hariç) tüm kartların gerçek
// `entries` verisinden hesaplandığı yardımcı fonksiyonlar.
import { Achievement, BehavioralGrowth, Entry, MonthlyTrend, SavingsPattern, TriggerSlot } from './types';

const DAY_MS = 24 * 60 * 60 * 1000;

function startOfDay(d: Date) {
  return new Date(d.getFullYear(), d.getMonth(), d.getDate()).getTime();
}

export function computeStreakDays(entries: Entry[]): number {
  if (entries.length === 0) return 0;
  const daySet = new Set(entries.map((e) => startOfDay(new Date(e.date))));

  let cursor = startOfDay(new Date());
  if (!daySet.has(cursor)) {
    cursor -= DAY_MS;
  }

  let streak = 0;
  while (daySet.has(cursor)) {
    streak += 1;
    cursor -= DAY_MS;
  }
  return streak;
}

export function computeBehavioralGrowth(entries: Entry[]): BehavioralGrowth {
  const now = Date.now();
  const thisWeek = entries.filter((e) => now - new Date(e.date).getTime() <= 7 * DAY_MS);
  const prevWeek = entries.filter((e) => {
    const diff = now - new Date(e.date).getTime();
    return diff > 7 * DAY_MS && diff <= 14 * DAY_MS;
  });

  const thisSum = thisWeek.reduce((sum, e) => sum + e.amount, 0);
  const prevSum = prevWeek.reduce((sum, e) => sum + e.amount, 0);
  const improvementPercent = prevSum > 0
    ? Math.round(((thisSum - prevSum) / prevSum) * 100)
    : (thisSum > 0 ? 100 : 0);

  return {
    improvementPercent: Math.max(0, improvementPercent),
    periodLabel: 'Bu hafta',
    giveUpCount: thisWeek.length,
    savings: thisSum,
  };
}

const TIME_BUCKETS = [
  { label: 'Sabah 06 - 12', start: 6, end: 12 },
  { label: 'Öğlen 12 - 17', start: 12, end: 17 },
  { label: 'Akşam 17 - 22', start: 17, end: 22 },
  { label: 'Gece 22 - 06', start: 22, end: 6 },
];

function inBucket(hour: number, start: number, end: number) {
  return start < end ? hour >= start && hour < end : hour >= start || hour < end;
}

export function computeSavingsPattern(entries: Entry[]): SavingsPattern {
  if (entries.length === 0) {
    return { timeRange: 'Henüz veri yok', description: 'Vazgeçiş ekledikçe kalıpların burada görünecek.' };
  }

  const counts = TIME_BUCKETS.map((bucket) => ({
    ...bucket,
    count: entries.filter((e) => inBucket(new Date(e.date).getHours(), bucket.start, bucket.end)).length,
  }));
  const topBucket = [...counts].sort((a, b) => b.count - a.count)[0];

  const categoryCount: Record<string, number> = {};
  entries.forEach((e) => {
    categoryCount[e.category] = (categoryCount[e.category] || 0) + 1;
  });
  const topCategory = Object.entries(categoryCount).sort((a, b) => b[1] - a[1])[0]?.[0] || 'Diğer';

  return {
    timeRange: topBucket.label,
    description: `En çok ${topCategory} kategorisinde vazgeçtin`,
  };
}

export function computeMonthlyTrend(entries: Entry[], goalTarget?: number): MonthlyTrend {
  const now = new Date();
  const monthEntries = entries.filter((e) => {
    const d = new Date(e.date);
    return d.getFullYear() === now.getFullYear() && d.getMonth() === now.getMonth();
  });
  const current = monthEntries.reduce((sum, e) => sum + e.amount, 0);
  const target = goalTarget && goalTarget > 0 ? goalTarget : Math.max(1000, Math.round(current * 1.5) || 5000);
  const percent = target > 0 ? Math.min(100, Math.round((current / target) * 100)) : 0;

  return {
    title: 'Aylık Hedefine Yakınlık',
    description: `Bu ay düzenli vazgeçme eylemlerin sayesinde hedefine %${percent} yaklaşıyorsun.`,
    current,
    target,
  };
}

const DAY_NAMES = ['Pazar', 'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi'];

export function computeTriggerSlots(entries: Entry[]): TriggerSlot[] {
  const slotCounts = new Map<string, number>();
  entries.forEach((e) => {
    const d = new Date(e.date);
    const dayName = DAY_NAMES[d.getDay()];
    const bucketStart = Math.floor(d.getHours() / 3) * 3;
    const bucketEnd = (bucketStart + 3) % 24;
    const label = `${dayName} · ${String(bucketStart).padStart(2, '0')}:00 - ${String(bucketEnd).padStart(2, '0')}:00`;
    slotCounts.set(label, (slotCounts.get(label) || 0) + 1);
  });

  return Array.from(slotCounts.entries())
    .map(([label, count]) => ({ label, count }))
    .sort((a, b) => b.count - a.count)
    .slice(0, 4);
}

export function computeAchievements(entries: Entry[], totalSavings: number): Achievement[] {
  const nightCount = entries.filter((e) => {
    const h = new Date(e.date).getHours();
    return h >= 22 || h < 6;
  }).length;
  const monthly = computeMonthlyTrend(entries);

  return [
    { id: 'a1', title: 'İlk Adım', description: 'İlk vazgeçişini kaydettin.', emoji: '🎉', unlocked: entries.length >= 1 },
    { id: 'a2', title: 'Tasarruf Ustası', description: '₺1.000 birikim topladın.', emoji: '🏆', unlocked: totalSavings >= 1000 },
    { id: 'a3', title: 'Gece Bekçisi', description: 'Gece saatlerinde 5 kez vazgeçtin.', emoji: '🌙', unlocked: nightCount >= 5 },
    { id: 'a4', title: 'Aylık Şampiyon', description: 'Aylık tasarruf hedefine ulaş.', emoji: '🥇', unlocked: monthly.target > 0 && monthly.current >= monthly.target },
  ];
}
