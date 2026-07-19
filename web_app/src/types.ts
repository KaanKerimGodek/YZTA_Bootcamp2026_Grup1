export interface Entry {
  id: string;
  title: string;
  amount: number;
  category: string;
  date: string;
}

export const CATEGORIES = [
  'Yemek',
  'İçecek',
  'Giyim',
  'Eğlence',
  'Ulaşım',
  'Kişisel Bakım',
  'Teknoloji',
  'Diğer',
];

export interface InsightData {
  insight: string;
  savings: number;
  insightValue: number;
}

// --- İçgörü (Insights) Sayfası Tipleri ---
// Sprint 2 - Task 12/13/14: Tetikleyici an analizi, haftalık içgörü metni üretimi
// ve içgörü ekranı için kullanılan veri modelleri.

export type InsightPeriod = 'weekly' | 'monthly';

export interface PeriodInsightReport {
  periodLabel: string;
  summaryText: string;
  topCategory: string;
  topCategoryChangePercent: number;
  mostActiveTimeRange: string;
  giveUpRateChangePercent: number;
  estimatedSavings: number;
}

export interface TriggerSlot {
  label: string;
  count: number;
}

export type GoalType = 'tasarruf' | 'birikim' | 'aliskanlik';

export interface SavingsGoal {
  id: string;
  title: string;
  type: GoalType;
  target: number;
  current: number;
  unit?: string;
}

export interface Achievement {
  id: string;
  title: string;
  description: string;
  emoji: string;
  unlocked: boolean;
}

export interface AppNotification {
  id: string;
  title: string;
  message: string;
  time: string;
  read: boolean;
}

// Sprint 2 - Task 12/13: "AI Davranış Analizi" için davranışsal gelişim,
// tasarruf kalıpları ve aylık trend veri modelleri (İçgörü sayfası).

export interface BehavioralGrowth {
  improvementPercent: number;
  periodLabel: string;
  giveUpCount: number;
  savings: number;
}

export interface SavingsPattern {
  timeRange: string;
  description: string;
}

export interface MonthlyTrend {
  title: string;
  description: string;
  current: number;
  target: number;
}
