import React from 'react';
import { Home, BarChart2, Plus, Sparkles, User } from 'lucide-react';

interface LayoutProps {
  children: React.ReactNode;
  activeTab: 'home' | 'stats' | 'insights' | 'profile';
  onTabChange: (tab: 'home' | 'stats' | 'insights' | 'profile') => void;
  onAddClick: () => void;
}

export function Layout({ children, activeTab, onTabChange, onAddClick }: LayoutProps) {
  return (
    <div className="min-h-screen bg-slate-50 font-sans pb-20 md:pb-0 flex flex-col relative z-0">
      {/* Mobile Header */}
      <header className="md:hidden px-6 py-4 flex justify-between items-center bg-white border-b border-slate-200 sticky top-0 z-[100] shadow-sm">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-emerald-600 rounded-xl flex items-center justify-center text-white font-bold text-xl shadow-sm">
            V
          </div>
          <div>
            <p className="text-xs font-semibold text-slate-400 uppercase tracking-wider leading-none mb-1">Hoş Geldin</p>
            <h1 className="text-sm font-bold text-slate-700">Kullanıcı</h1>
          </div>
        </div>
        <button className="w-10 h-10 rounded-full bg-slate-200 border-2 border-white shadow-sm flex items-center justify-center overflow-hidden">
           <div className="w-full h-full bg-slate-400"></div>
        </button>
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
            <button onClick={() => onTabChange('insights')} className={`transition-colors ${activeTab === 'insights' ? 'text-emerald-600 font-bold' : 'text-slate-600 hover:text-emerald-600'}`}>Yapay Zeka</button>
          </div>
          
          <div className="h-6 w-px bg-slate-200"></div>
          
          <button 
            onClick={onAddClick}
            className="bg-emerald-600 hover:bg-emerald-700 text-white px-4 py-2 rounded-lg font-semibold flex items-center gap-2 transition-all shadow-sm active:scale-95"
          >
            <Plus size={18} />
            <span>Vazgeçiş Ekle</span>
          </button>

          <div className="flex items-center gap-3 border-l border-slate-200 pl-6 cursor-pointer" onClick={() => onTabChange('profile')}>
            <div className="text-right">
              <p className="text-xs font-semibold text-slate-400 uppercase tracking-wider leading-none mb-1">Hoş Geldin</p>
              <p className="text-sm font-bold text-slate-700">Kullanıcı</p>
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
