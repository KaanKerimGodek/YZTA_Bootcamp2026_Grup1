import React, { useState } from 'react';
import { Mail, Lock, Eye, EyeOff, LogIn, Zap } from 'lucide-react';
import { GoogleIcon } from './icons/GoogleIcon';

interface LoginProps {
  onLogin: (email: string) => void;
  onNavigateRegister: () => void;
}

export function Login({ onLogin, onNavigateRegister }: LoginProps) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!email || !password) return;

    setIsSubmitting(true);
    // NOT: Gerçek kimlik doğrulama (Supabase/Auth API) entegrasyonu sonraki
    // sprintte eklenecek. Şimdilik giriş, girilen e-posta ile mock olarak kabul edilir.
    window.setTimeout(() => {
      setIsSubmitting(false);
      onLogin(email);
    }, 400);
  };

  return (
    <div className="min-h-screen bg-slate-50 flex">
      {/* Marka Paneli - Masaütü */}
      <div className="hidden lg:flex lg:w-1/2 bg-gradient-to-br from-blue-600 to-emerald-500 text-white flex-col justify-between p-12 relative overflow-hidden">
        <div className="flex items-center gap-3 relative z-10">
          <div className="w-11 h-11 bg-white/15 rounded-xl flex items-center justify-center font-bold text-xl">V</div>
          <span className="text-xl font-bold">Vazgeçtim</span>
        </div>
        <div className="max-w-md relative z-10">
          <h2 className="text-3xl font-extrabold leading-tight mb-4">Vazgeçtiklerin, geleceğine yatırım olsun.</h2>
          <p className="text-white/80 leading-relaxed">
            Almaktan vazgeçtiğin her şeyi kaydet, tasarruflarını büyüt ve hedeflerine daha hızlı ulaş.
          </p>
        </div>
        <p className="text-xs text-white/60 relative z-10">© 2026 Vazgeçtim</p>
        <div className="absolute -right-24 -bottom-24 w-96 h-96 bg-white/10 rounded-full blur-3xl" />
        <div className="absolute -left-16 -top-16 w-64 h-64 bg-white/10 rounded-full blur-3xl" />
      </div>

      {/* Form Paneli */}
      <div className="flex-1 flex items-center justify-center px-6 py-10">
        <div className="w-full max-w-sm animate-in fade-in slide-in-from-bottom-4 duration-500">
          {/* Mobil-only marka başlığı */}
          <div className="lg:hidden flex items-center gap-3 mb-8">
            <div className="w-11 h-11 bg-emerald-600 rounded-xl flex items-center justify-center text-white font-bold text-xl shadow-sm">
              V
            </div>
            <span className="text-xl font-bold tracking-tight text-slate-800">Vazgeçtim</span>
          </div>

          <div className="mb-8">
            <h1 className="text-3xl font-extrabold text-slate-800 mb-1">Hoş geldin!</h1>
            <p className="text-slate-400">Hesabına giriş yap</p>
          </div>

          <form onSubmit={handleSubmit} className="flex flex-col gap-5">
          <div>
            <label className="block text-xs font-medium text-slate-400 mb-1.5">E-posta</label>
            <div className="relative">
              <div className="absolute inset-y-0 left-3 flex items-center pointer-events-none text-slate-400">
                <Mail size={18} />
              </div>
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="ornek@gmail.com"
                className="w-full pl-10 pr-4 py-3 rounded-xl border border-slate-200 bg-white focus:border-emerald-500 focus:ring-2 focus:ring-emerald-200 outline-none transition-all text-slate-800 placeholder-slate-300"
                required
              />
            </div>
          </div>

          <div>
            <div className="flex items-center justify-between mb-1.5">
              <label className="block text-xs font-medium text-slate-400">Şifre</label>
              <button type="button" className="text-xs font-semibold text-blue-600 hover:text-blue-700">
                Şifremi mi unuttun?
              </button>
            </div>
            <div className="relative">
              <div className="absolute inset-y-0 left-3 flex items-center pointer-events-none text-slate-400">
                <Lock size={18} />
              </div>
              <input
                type={showPassword ? 'text' : 'password'}
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="••••••••"
                className="w-full pl-10 pr-11 py-3 rounded-xl border border-slate-200 bg-white focus:border-emerald-500 focus:ring-2 focus:ring-emerald-200 outline-none transition-all text-slate-800 placeholder-slate-300"
                required
                minLength={6}
              />
              <button
                type="button"
                onClick={() => setShowPassword((s) => !s)}
                className="absolute inset-y-0 right-3 flex items-center text-slate-400 hover:text-slate-600"
                aria-label={showPassword ? 'Şifreyi gizle' : 'Şifreyi göster'}
              >
                {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
              </button>
            </div>
          </div>

          <button
            type="submit"
            disabled={isSubmitting || !email || !password}
            className="w-full mt-2 bg-gradient-to-r from-blue-600 to-emerald-500 disabled:opacity-50 text-white font-bold py-3.5 rounded-xl flex items-center justify-center gap-2 transition-all active:scale-[0.98] shadow-sm"
          >
            {isSubmitting ? (
              <div className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin" />
            ) : (
              <>
                <LogIn size={18} />
                Giriş Yap
              </>
            )}
          </button>

          <div className="flex items-center gap-3 my-1">
            <div className="flex-1 h-px bg-slate-200" />
            <span className="text-xs font-semibold text-slate-400">VEYA</span>
            <div className="flex-1 h-px bg-slate-200" />
          </div>

          <button
            type="button"
            className="w-full bg-white border border-slate-200 text-slate-700 font-semibold py-3 rounded-xl flex items-center justify-center gap-2 hover:bg-slate-50 transition-colors"
          >
            <GoogleIcon />
            Google ile Giriş Yap
          </button>

          <button
            type="button"
            onClick={() => onLogin('test@vazgectim.app')}
            className="w-full bg-blue-50 border border-blue-200 text-blue-700 font-semibold py-3 rounded-xl flex items-center justify-center gap-2 hover:bg-blue-100 transition-colors"
          >
            <Zap size={16} />
            Hızlı Giriş (Test Kullanıcısı)
          </button>

          <p className="text-center text-sm text-slate-500 mt-2">
            Hesabın yok mu?{' '}
            <button type="button" onClick={onNavigateRegister} className="font-bold text-blue-600 hover:text-blue-700">
              Kayıt Ol
            </button>
          </p>
          </form>
        </div>
      </div>
    </div>
  );
}
