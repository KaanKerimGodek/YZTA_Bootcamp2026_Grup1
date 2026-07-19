import React from 'react';
import { Settings, User, Bell, ShieldCheck, HelpCircle, FileText, Info, ChevronRight, LogOut } from 'lucide-react';
import { Entry } from '../types';

interface ProfileProps {
  entries: Entry[];
  userName: string;
  userEmail: string;
  onLogout: () => void;
}

const MOCK_JOIN_DATE = '1 Haz 2026';
const APP_VERSION = 'v0.1.0';

export function Profile({ entries, userName, userEmail, onLogout }: ProfileProps) {
  const formatMoney = (amount: number) => {
    return new Intl.NumberFormat('tr-TR', { style: 'currency', currency: 'TRY', maximumFractionDigits: 0 }).format(amount);
  };

  const totalSavings = entries.reduce((sum, e) => sum + e.amount, 0);
  const biggestEntry = entries.reduce((max, e) => (e.amount > max ? e.amount : max), 0);
  const initial = userName.trim().charAt(0).toUpperCase() || 'K';

  return (
    <div className="flex flex-col gap-8 animate-in fade-in slide-in-from-bottom-4 duration-500 max-w-2xl mx-auto">
      <div className="flex items-center justify-between">
        <h2 className="text-2xl font-bold text-slate-800">Profil</h2>
        <button className="w-10 h-10 rounded-full flex items-center justify-center text-slate-500 hover:bg-slate-100 transition-colors">
          <Settings size={20} />
        </button>
      </div>

      {/* Profil Kartı */}
      <div className="bg-gradient-to-r from-blue-600 to-emerald-500 rounded-3xl p-6 md:p-8 text-white shadow-lg shadow-emerald-200/50 flex items-center gap-5">
        <div className="w-16 h-16 rounded-full bg-white/20 flex items-center justify-center text-2xl font-bold shrink-0">
          {initial}
        </div>
        <div>
          <h3 className="text-xl font-extrabold">{userName}</h3>
          <p className="text-white/80 text-sm">{userEmail}</p>
          <p className="text-white/70 text-xs mt-1">Üyelik: {MOCK_JOIN_DATE}</p>
        </div>
      </div>

      {/* İstatistik Satırı */}
      <div className="grid grid-cols-3 gap-4">
        <div className="bg-white border border-slate-200 rounded-2xl p-4 text-center shadow-sm">
          <p className="text-lg md:text-xl font-extrabold text-slate-800">{formatMoney(totalSavings)}</p>
          <p className="text-xs text-slate-400 mt-1">Toplam</p>
        </div>
        <div className="bg-white border border-slate-200 rounded-2xl p-4 text-center shadow-sm">
          <p className="text-lg md:text-xl font-extrabold text-slate-800">{entries.length} adet</p>
          <p className="text-xs text-slate-400 mt-1">Vazgeçiş</p>
        </div>
        <div className="bg-white border border-slate-200 rounded-2xl p-4 text-center shadow-sm">
          <p className="text-lg md:text-xl font-extrabold text-slate-800">{formatMoney(biggestEntry)}</p>
          <p className="text-xs text-slate-400 mt-1">En Büyük</p>
        </div>
      </div>

      {/* Hesap */}
      <div>
        <h4 className="text-xs font-bold text-slate-400 uppercase mb-3">Hesap</h4>
        <div className="bg-white border border-slate-200 rounded-3xl divide-y divide-slate-100 shadow-sm overflow-hidden">
          <ProfileRow icon={User} label="Kişisel Bilgiler" />
          <ProfileRow icon={Bell} label="Bildirimler" badge="Mock" />
          <ProfileRow icon={ShieldCheck} label="Gizlilik & Güvenlik" />
        </div>
      </div>

      {/* Destek */}
      <div>
        <h4 className="text-xs font-bold text-slate-400 uppercase mb-3">Destek</h4>
        <div className="bg-white border border-slate-200 rounded-3xl divide-y divide-slate-100 shadow-sm overflow-hidden">
          <ProfileRow icon={HelpCircle} label="Yardım Merkezi" />
          <ProfileRow icon={FileText} label="Kullanım Şartları" />
          <ProfileRow icon={Info} label="Hakkında" trailingText={APP_VERSION} />
        </div>
      </div>

      {/* Çıkış */}
      <button
        onClick={onLogout}
        className="flex items-center justify-center gap-2 w-full bg-red-50 text-red-600 font-semibold py-3.5 rounded-2xl hover:bg-red-100 transition-colors"
      >
        <LogOut size={18} />
        Çıkış Yap
      </button>
    </div>
  );
}

interface ProfileRowProps {
  icon: React.ComponentType<{ size?: number; className?: string }>;
  label: string;
  badge?: string;
  trailingText?: string;
}

function ProfileRow({ icon: Icon, label, badge, trailingText }: ProfileRowProps) {
  return (
    <button className="w-full flex items-center gap-4 px-5 py-4 hover:bg-slate-50 transition-colors text-left">
      <div className="w-9 h-9 rounded-lg bg-blue-50 text-blue-600 flex items-center justify-center shrink-0">
        <Icon size={18} />
      </div>
      <span className="flex-1 font-medium text-slate-700">{label}</span>
      {badge && <span className="text-xs font-bold text-amber-700 bg-amber-100 px-2.5 py-1 rounded-full">{badge}</span>}
      {trailingText && <span className="text-sm text-slate-400">{trailingText}</span>}
      {!badge && !trailingText && <ChevronRight size={18} className="text-slate-300" />}
    </button>
  );
}
