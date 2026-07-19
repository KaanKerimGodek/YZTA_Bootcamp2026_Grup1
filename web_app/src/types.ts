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
