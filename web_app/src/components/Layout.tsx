import React, { useState } from 'react';
import { Home, BarChart2, Plus, Sparkles, User, Bell } from 'lucide-react';
import { MOCK_NOTIFICATIONS } from '../mockInsights';

interface LayoutProps {
  children: React.ReactNode;
  activeTab: 'home' | 'stats' | 'insights' | 'profile';
  onTabChange: (tab: 'home' | 'stats' | 'insights' | 'profile') => void;
  onAddClick: () => void;
  userName: string;
}

function getGreeting() {
  const hour = new Date().getHours();
  if (hour < 6) return 'İyi geceler';
  if (hour < 12) return 'Günaydın';
  if (hour < 18) return 'İyi günler';
  return 'İyi akşamlar';
}

export function Layout({ children, activeTab, onTabChange, onAddClick, userName }: LayoutProps) {
  const [isNotifOpen, setIsNotifOpen] = useState(false);
  const unreadCount = MOCK_NOTIFICATIONS.filter((n) => !n.read).length;

  return (
    <div className="min-h-screen bg-slate-50 font-sans pb-20 md:pb-0 flex flex-col relative z-0">
      {/* Mobile Header */}
      <header className="md:hidden px-6 py-4 flex justify-between items-center bg-white border-b border-slate-200 sticky top-0 z-[100] shadow-sm">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-emerald-600 rounded-xl flex items-center justify-center text-white font-bold text-xl shadow-sm">
            V
          </div>
          <div>
            <p className="text-xs font-semibold text-slate-400 uppercase tracking-wider leading-none mb-1">{getGreeting()} 👋</p>
            <h1 className="text-sm font-bold text-slate-700">{userName}</h1>
          </div>
        </div>
        <div className="flex items-center gap-2">
          <NotificationBell isOpen={isNotifOpen} onToggle={() => setIsNotifOpen((v) => !v)} unreadCount={unreadCount} />
          <button
            onClick={() => onTabChange('profile')}
            className="w-10 h-10 rounded-full bg-slate-200 border-2 border-white shadow-sm flex items-center justify-center overflow-hidden"
          >
             <div className="w-full h-full bg-slate-400"></div>
          </button>
        </div>
      </header>

      {/* Desktop Top Navigation */}
      <nav className="hidden md:flex bg-white border-b border-slate-200 px-8 py-4 justify-between items-center sticky top-0 z-[100] shadow-sm shrink-0">
        <div className="flex items-center gap-3 cursor-pointer" onClick={() => onTabChange('home')}>
          <div className="w-10 h-10 bg-emerald-600 rounded-xl flex items-center justify-center text-white font-bold text-xl shadow-sm">
            V
          </div>
          <span className="text-xl font-bold tracking-tight text-slate-800">Vazgeçtim</span>
        </div>
        
        <div className="flex items-center gap-8">
          <div className="flex gap-6 text-sm font-medium">
            <button onClick={() => onTabChange('home')} className={`transition-colors ${activeTab === 'home' ? 'text-emerald-600 font-bold' : 'text-slate-600 hover:text-emerald-600'}`}>Anasayfa</button>
            <button onClick={() => onTabChange('stats')} className={`transition-colors ${activeTab === 'stats' ? 'text-emerald-600 font-bold' : 'text-slate-600 hover:text-emerald-600'}`}>İstatistik</button>
            <button onClick={() => onTabChange('insights')} className={`transition-colors ${activeTab === 'insights' ? 'text-emerald-600 font-bold' : 'text-slate-600 hover:text-emerald-600'}`}>İçgörü</button>
          </div>
          
          <div className="h-6 w-px bg-slate-200"></div>
          
          <button 
            onClick={onAddClick}
            className="bg-emerald-600 hover:bg-emerald-700 text-white px-4 py-2 rounded-lg font-semibold flex items-center gap-2 transition-all shadow-sm active:scale-95"
          >
            <Plus size={18} />
            <span>Vazgeçiş Ekle</span>
          </button>

          <NotificationBell isOpen={isNotifOpen} onToggle={() => setIsNotifOpen((v) => !v)} unreadCount={unreadCount} />

          <div className="flex items-center gap-3 border-l border-slate-200 pl-6 cursor-pointer" onClick={() => onTabChange('profile')}>
            <div className="text-right">
              <p className="text-xs font-semibold text-slate-400 uppercase tracking-wider leading-none mb-1">{getGreeting()}</p>
              <p className="text-sm font-bold text-slate-700">{userName}</p>
            </div>
            <div className="w-10 h-10 rounded-full bg-slate-200 border-2 border-white shadow-sm flex items-center justify-center overflow-hidden">
              <div className="w-full h-full bg-slate-400"></div>
            </div>
          </div>
        </div>
      </nav>

      {/* Main Content Area */}
      <main className="flex-1 w-full max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-6 md:py-8">
        {children}
      </main>

      {/* Mobile Bottom Navigation */}
      <nav className="md:hidden fixed bottom-0 w-full bg-white border-t border-slate-200 px-6 py-3 pb-safe flex justify-between items-center z-[100] shadow-[0_-4px_20px_-10px_rgba(0,0,0,0.1)]">
        <button 
          onClick={() => onTabChange('home')}
          className={`flex flex-col items-center gap-1 min-w-[64px] ${activeTab === 'home' ? 'text-emerald-600' : 'text-slate-400'}`}
        >
          <Home size={24} className={activeTab === 'home' ? 'fill-emerald-100' : ''} />
          <span className="text-[10px] font-medium">Ana Sayfa</span>
        </button>

        <button 
          onClick={() => onTabChange('stats')}
          className={`flex flex-col items-center gap-1 min-w-[64px] ${activeTab === 'stats' ? 'text-emerald-600' : 'text-slate-400'}`}
        >
          <BarChart2 size={24} />
          <span className="text-[10px] font-medium">İstatistik</span>
        </button>

        {/* Center FAB */}
        <div className="relative -top-8 flex justify-center">
          <button 
            onClick={onAddClick}
            className="w-14 h-14 rounded-full bg-emerald-600 flex items-center justify-center text-white shadow-lg shadow-emerald-200/50 hover:bg-emerald-700 hover:scale-105 active:scale-95 transition-all"
          >
            <Plus size={32} />
          </button>
        </div>

        <button 
           onClick={() => onTabChange('insights')}
           className={`flex flex-col items-center gap-1 min-w-[64px] ${activeTab === 'insights' ? 'text-emerald-600' : 'text-slate-400'}`}
        >
          <Sparkles size={24} />
          <span className="text-[10px] font-medium">İçgörüler</span>
        </button>

        <button 
          onClick={() => onTabChange('profile')}
          className={`flex flex-col items-center gap-1 min-w-[64px] ${activeTab === 'profile' ? 'text-emerald-600' : 'text-slate-400'}`}
        >
          <User size={24} />
          <span className="text-[10px] font-medium">Profil</span>
        </button>
      </nav>
    </div>
  );
}

interface NotificationBellProps {
  isOpen: boolean;
  onToggle: () => void;
  unreadCount: number;
}

function NotificationBell({ isOpen, onToggle, unreadCount }: NotificationBellProps) {
  return (
    <div className="relative">
      <button
        onClick={onToggle}
        className="relative w-10 h-10 rounded-full flex items-center justify-center text-slate-500 hover:bg-slate-100 transition-colors"
        aria-label="Bildirimler"
      >
        <Bell size={20} />
        {unreadCount > 0 && (
          <span className="absolute top-1.5 right-1.5 w-2.5 h-2.5 bg-red-500 rounded-full border-2 border-white" />
        )}
      </button>

      {isOpen && (
        <>
          <div className="fixed inset-0 z-[105]" onClick={onToggle} />
          <div className="absolute right-0 mt-2 w-80 max-w-[90vw] bg-white rounded-2xl border border-slate-200 shadow-xl z-[110] overflow-hidden">
            <div className="px-4 py-3 border-b border-slate-100 font-bold text-slate-700 text-sm">Bildirimler</div>
            <div className="max-h-80 overflow-y-auto custom-scrollbar">
              {MOCK_NOTIFICATIONS.map((n) => (
                <div key={n.id} className={`px-4 py-3 border-b border-slate-50 last:border-0 ${!n.read ? 'bg-emerald-50/40' : ''}`}>
                  <p className="text-sm font-semibold text-slate-700">{n.title}</p>
                  <p className="text-xs text-slate-500 mt-0.5">{n.message}</p>
                  <p className="text-[11px] text-slate-400 mt-1">{n.time}</p>
                </div>
              ))}
            </div>
          </div>
        </>
      )}
    </div>
  );
}
