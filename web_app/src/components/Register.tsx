import React, { useState } from 'react';
import { User, Mail, Lock, Eye, EyeOff, UserPlus } from 'lucide-react';
import { GoogleIcon } from './icons/GoogleIcon';

interface RegisterProps {
  onRegister: (name: string, email: string) => void;
  onNavigateLogin: () => void;
}

export function Register({ onRegister, onNavigateLogin }: RegisterProps) {
  const [firstName, setFirstName] = useState('');
  const [lastName, setLastName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState('');

  const isValid = Boolean(firstName && lastName && email && password.length >= 6 && password === confirmPassword);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();

    if (password.length < 6) {
      setError('Şifre en az 6 karakter olmalı.');
      return;
    }
    if (password !== confirmPassword) {
      setError('Şifreler eşleşmiyor.');
      return;
    }

    setError('');
    setIsSubmitting(true);

    window.setTimeout(() => {
      setIsSubmitting(false);
      onRegister(`${firstName} ${lastName}`.trim(), email);
    }, 400);
  };

  return (
    <div className="h-screen bg-slate-50 flex overflow-hidden">
      {/* Marka Paneli - Masaüstü */}
      <div className="hidden lg:flex lg:w-1/2 bg-gradient-to-br from-blue-600 to-emerald-500 text-white flex-col justify-between p-12 relative overflow-hidden">
        <div className="flex items-center gap-3 relative z-10">
          <div className="w-11 h-11 bg-white/15 rounded-xl flex items-center justify-center font-bold text-xl">V</div>
          <span className="text-xl font-bold">Vazgeçtim</span>
        </div>
        <div className="max-w-md relative z-10">
          <h2 className="text-3xl font-extrabold leading-tight mb-4">Bir adım at, geleceğine yatırım yap.</h2>
          <p className="text-white/80 leading-relaxed">
            Ücretsiz hesabını oluştur, vazgeçtiklerini kaydet ve tasarruflarının büyüdüğünü gör.
          </p>
        </div>
        <p className="text-xs text-white/60 relative z-10">© 2026 Vazgeçtim</p>
        <div className="absolute -right-24 -bottom-24 w-96 h-96 bg-white/10 rounded-full blur-3xl" />
        <div className="absolute -left-16 -top-16 w-64 h-64 bg-white/10 rounded-full blur-3xl" />
      </div>

      {/* Form Paneli */}
      <div className="flex-1 flex items-center justify-center px-6 py-6 overflow-y-auto">
        <div className="w-full max-w-md animate-in fade-in slide-in-from-bottom-4 duration-500">
        <div className="mb-5">
          <h1 className="text-2xl font-extrabold text-slate-800 mb-1">Hesap Oluştur</h1>
          <p className="text-slate-400 text-sm">Vazgeçtiklerin birikime dönüşsün.</p>
        </div>

        <form onSubmit={handleSubmit} className="flex flex-col gap-3.5">
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-medium text-slate-400 mb-1.5">Ad</label>
              <div className="relative">
                <div className="absolute inset-y-0 left-3 flex items-center pointer-events-none text-slate-400">
                  <User size={18} />
                </div>
                <input
                  type="text"
                  value={firstName}
                  onChange={(e) => setFirstName(e.target.value)}
                  placeholder="Adın"
                  className="w-full pl-10 pr-3 py-2 rounded-xl border border-slate-200 bg-white focus:border-emerald-500 focus:ring-2 focus:ring-emerald-200 outline-none transition-all text-slate-800 placeholder-slate-300"
                  required
                />
              </div>
            </div>
            <div>
              <label className="block text-xs font-medium text-slate-400 mb-1.5">Soyad</label>
              <div className="relative">
                <div className="absolute inset-y-0 left-3 flex items-center pointer-events-none text-slate-400">
                  <User size={18} />
                </div>
                <input
                  type="text"
                  value={lastName}
                  onChange={(e) => setLastName(e.target.value)}
                  placeholder="Soyadın"
                  className="w-full pl-10 pr-3 py-2 rounded-xl border border-slate-200 bg-white focus:border-emerald-500 focus:ring-2 focus:ring-emerald-200 outline-none transition-all text-slate-800 placeholder-slate-300"
                  required
                />
              </div>
            </div>
          </div>

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
                placeholder="ornek@email.com"
                className="w-full pl-10 pr-4 py-2 rounded-xl border border-slate-200 bg-white focus:border-emerald-500 focus:ring-2 focus:ring-emerald-200 outline-none transition-all text-slate-800 placeholder-slate-300"
                required
              />
            </div>
          </div>

          <div>
            <label className="block text-xs font-medium text-slate-400 mb-1.5">Şifre</label>
            <div className="relative">
              <div className="absolute inset-y-0 left-3 flex items-center pointer-events-none text-slate-400">
                <Lock size={18} />
              </div>
              <input
                type={showPassword ? 'text' : 'password'}
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="En az 6 karakter"
                className="w-full pl-10 pr-11 py-2 rounded-xl border border-slate-200 bg-white focus:border-emerald-500 focus:ring-2 focus:ring-emerald-200 outline-none transition-all text-slate-800 placeholder-slate-300"
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

          <div>
            <label className="block text-xs font-medium text-slate-400 mb-1.5">Şifre (Tekrar)</label>
            <div className="relative">
              <div className="absolute inset-y-0 left-3 flex items-center pointer-events-none text-slate-400">
                <Lock size={18} />
              </div>
              <input
                type={showConfirmPassword ? 'text' : 'password'}
                value={confirmPassword}
                onChange={(e) => setConfirmPassword(e.target.value)}
                placeholder="Şifreni tekrar gir"
                className="w-full pl-10 pr-11 py-2 rounded-xl border border-slate-200 bg-white focus:border-emerald-500 focus:ring-2 focus:ring-emerald-200 outline-none transition-all text-slate-800 placeholder-slate-300"
                required
                minLength={6}
              />
              <button
                type="button"
                onClick={() => setShowConfirmPassword((s) => !s)}
                className="absolute inset-y-0 right-3 flex items-center text-slate-400 hover:text-slate-600"
                aria-label={showConfirmPassword ? 'Şifreyi gizle' : 'Şifreyi göster'}
              >
                {showConfirmPassword ? <EyeOff size={18} /> : <Eye size={18} />}
              </button>
            </div>
          </div>

          {error && <p className="text-sm text-red-500 -mt-2">{error}</p>}

          <p className="text-center text-xs text-slate-400">
            Kayıt olarak <span className="font-bold text-blue-600">Kullanım Şartları</span>'nı kabul etmiş olursun.
          </p>

          <button
            type="submit"
            disabled={isSubmitting || !isValid}
            className="w-full bg-gradient-to-r from-blue-600 to-emerald-500 disabled:opacity-50 text-white font-bold py-2.5 rounded-xl flex items-center justify-center gap-2 transition-all active:scale-[0.98] shadow-sm"
          >
            {isSubmitting ? (
              <div className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin" />
            ) : (
              <>
                <UserPlus size={18} />
                Kayıt Ol
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
            className="w-full bg-white border border-slate-200 text-slate-700 font-semibold py-2.5 rounded-xl flex items-center justify-center gap-2 hover:bg-slate-50 transition-colors"
          >
            <GoogleIcon />
            Google ile Kayıt Ol
          </button>

          <p className="text-center text-sm text-slate-500 mt-2">
            Zaten hesabın var mı?{' '}
            <button type="button" onClick={onNavigateLogin} className="font-bold text-blue-600 hover:text-blue-700">
              Giriş Yap
            </button>
          </p>
        </form>
        </div>
      </div>
    </div>
  );
}
