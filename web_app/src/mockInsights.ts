import {
  AppNotification,
  PeriodInsightReport,
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

export const MOCK_NOTIFICATIONS: AppNotification[] = [
  { id: 'n1', title: 'Tebrikler! 🎉', message: '5 gün üst üste vazgeçiş serisi yakaladın.', time: '2 saat önce', read: false },
  { id: 'n2', title: 'Haftalık İçgörü Hazır', message: 'Bu haftaki AI analizini görüntüle.', time: '1 gün önce', read: false },
  { id: 'n3', title: 'Hedefe Yaklaşıyorsun', message: "İtalya Tatili hedefinin %32'sine ulaştın.", time: '3 gün önce', read: true },
];
