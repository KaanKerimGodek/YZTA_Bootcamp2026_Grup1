import {
  Achievement,
  AppNotification,
  BehavioralGrowth,
  MonthlyTrend,
  PeriodInsightReport,
  SavingsGoal,
  SavingsPattern,
  TriggerSlot,
} from './types';


export const MOCK_INSIGHT_REPORTS: Record<'weekly' | 'monthly', PeriodInsightReport> = {
  weekly: {
    periodLabel: 'Bu Hafta',
    summaryText:
      'Bu hafta en çok gece saatlerinde ve eğlence kategorisinde vazgeçtin. Harika! Tasarruf alışkanlığın güçleniyor.',
    topCategory: 'Eğlence',
    topCategoryChangePercent: 24,
    mostActiveTimeRange: '21:00 - 00:00',
    giveUpRateChangePercent: 68,
    estimatedSavings: 1250,
  },
  monthly: {
    periodLabel: 'Bu Ay',
    summaryText:
      'Bu ay hafta sonu akşamlarında daha güçlüsün. Yemek siparişi vazgeçişlerin, toplam tasarrufunun en büyük kısmını oluşturuyor.',
    topCategory: 'Yemek',
    topCategoryChangePercent: 15,
    mostActiveTimeRange: 'Cumartesi 19:00 - 23:00',
    giveUpRateChangePercent: 42,
    estimatedSavings: 4820,
  },
};

export const MOCK_TRIGGER_SLOTS: TriggerSlot[] = [
  { label: 'Pazartesi · 21:00 - 00:00', count: 6 },
  { label: 'Cuma · 19:00 - 22:00', count: 5 },
  { label: 'Cumartesi · 14:00 - 17:00', count: 4 },
  { label: 'Pazar · 20:00 - 23:00', count: 3 },
];

export const MOCK_GOALS: SavingsGoal[] = [
  { id: 'g1', title: 'Aylık Tasarruf Hedefi', type: 'tasarruf', target: 5000, current: 3200 },
  { id: 'g2', title: 'İtalya Tatili Birikimi', type: 'birikim', target: 10000, current: 3200 },
  { id: 'g3', title: 'Haftada 3 Kez Vazgeç', type: 'aliskanlik', target: 3, current: 2, unit: 'kez' },
];

export const MOCK_ACHIEVEMENTS: Achievement[] = [
  { id: 'a1', title: 'İlk Adım', description: 'İlk vazgeçişini kaydettin.', emoji: '🎉', unlocked: true },
  { id: 'a2', title: 'Tasarruf Ustası', description: '₺1.000 birikim topladın.', emoji: '🏆', unlocked: true },
  { id: 'a3', title: 'Gece Bekçisi', description: 'Gece saatlerinde 5 kez vazgeçtin.', emoji: '🌙', unlocked: true },
  { id: 'a4', title: 'Aylık Şampiyon', description: 'Aylık tasarruf hedefine ulaş.', emoji: '🥇', unlocked: false },
];

// Mobil uygulamada bulunan "vazgeçiş serisi" (streak) göstergesi.
export const MOCK_STREAK_DAYS = 5;

export const MOCK_NOTIFICATIONS: AppNotification[] = [
  { id: 'n1', title: 'Tebrikler! 🎉', message: '5 gün üst üste vazgeçiş serisi yakaladın.', time: '2 saat önce', read: false },
  { id: 'n2', title: 'Haftalık İçgörü Hazır', message: 'Bu haftaki AI analizini görüntüle.', time: '1 gün önce', read: false },
  { id: 'n3', title: 'Hedefe Yaklaşıyorsun', message: "İtalya Tatili hedefinin %32'sine ulaştın.", time: '3 gün önce', read: true },
];

// Mobil "İçgörüler" sayfasındaki Davranışsal Gelişim / Tasarruf Kalıpları / Aylık Trend kartları.
export const MOCK_BEHAVIORAL_GROWTH: BehavioralGrowth = {
  improvementPercent: 100,
  periodLabel: 'Bu hafta',
  giveUpCount: 7,
  savings: 3674,
};

export const MOCK_SAVINGS_PATTERN: SavingsPattern = {
  timeRange: 'Sabah 06 - 12',
  description: 'En çok İçecek kategorisinde vazgeçtin',
};

export const MOCK_MONTHLY_TREND: MonthlyTrend = {
  title: 'Aylık Hedefine Yakınlık',
  description: 'Bu ay düzenli vazgeçme eylemlerin sayesinde hedefine %73 daha yaklaşıyorsun.',
  current: 3674,
  target: 5000,
};
