import React, { useState } from 'react';
import { X, Check } from 'lucide-react';
import { CATEGORIES } from '../types';

interface AddModalProps {
  onClose: () => void;
  onAdd: (title: string, amount: number, category: string) => Promise<void>;
}

export function AddModal({ onClose, onAdd }: AddModalProps) {
  const [title, setTitle] = useState('');
  const [amount, setAmount] = useState('');
  const [category, setCategory] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!title || !amount) return;
    
    setIsSubmitting(true);
    await onAdd(title, Number(amount), category);
    setIsSubmitting(false);
    onClose();
  };

  return (
    <>
      {/* Backdrop */}
      <div 
        className="fixed inset-0 bg-slate-900/40 z-50 animate-in fade-in duration-300"
        onClick={onClose}
      />
      
      {/* Bottom Sheet */}
      <div className="fixed bottom-0 left-0 right-0 z-50 flex justify-center pointer-events-none">
        <div className="w-full max-w-md bg-white rounded-t-[32px] p-6 pb-safe pointer-events-auto shadow-2xl animate-in slide-in-from-bottom duration-300">
          
          {/* Handle */}
          <div className="w-12 h-1.5 bg-slate-200 rounded-full mx-auto mb-6" />
          
          <div className="flex justify-between items-center mb-6">
            <h2 className="text-2xl font-bold text-slate-800">Vazgeçiş Ekle</h2>
            <button 
              onClick={onClose}
              className="w-8 h-8 flex items-center justify-center text-slate-400 hover:bg-slate-100 rounded-full transition-colors"
            >
              <X size={20} />
            </button>
          </div>
          
          <p className="text-slate-500 mb-6 text-sm">
            Vazgeçtiğin harcamayı kaydet, geleceğine yatırım olsun.
          </p>

          <form onSubmit={handleSubmit} className="flex flex-col gap-5">
            {/* Title Input */}
            <div>
              <label className="block text-xs font-medium text-slate-400 mb-1.5">Ne vazgeçtin?</label>
              <div className="relative">
                <div className="absolute inset-y-0 left-3 flex items-center pointer-events-none text-slate-400">
                  <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"></path><line x1="3" y1="6" x2="21" y2="6"></line><path d="M16 10a4 4 0 0 1-8 0"></path></svg>
                </div>
                <input 
                  type="text" 
                  value={title}
                  onChange={e => setTitle(e.target.value)}
                  placeholder="Örn. Latte"
                  className="w-full pl-10 pr-4 py-3 rounded-xl border border-slate-200 focus:border-emerald-500 focus:ring-2 focus:ring-emerald-200 outline-none transition-all text-slate-800 placeholder-slate-300"
                  required
                />
              </div>
            </div>

            {/* Amount Input */}
            <div>
              <label className="block text-xs font-medium text-slate-400 mb-1.5">Tutar (₺)</label>
              <div className="relative">
                 <div className="absolute inset-y-0 left-3 flex items-center pointer-events-none text-slate-400">
                   <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><rect x="2" y="6" width="20" height="12" rx="2"></rect><circle cx="12" cy="12" r="2"></circle><path d="M6 12h.01M18 12h.01"></path></svg>
                 </div>
                 <div className="absolute inset-y-0 left-10 flex items-center pointer-events-none text-slate-400 font-medium">
                   ₺
                 </div>
                <input 
                  type="number" 
                  value={amount}
                  onChange={e => setAmount(e.target.value)}
                  placeholder="150"
                  className="w-full pl-14 pr-4 py-3 rounded-xl border border-slate-200 focus:border-emerald-500 focus:ring-2 focus:ring-emerald-200 outline-none transition-all text-slate-800 text-lg font-semibold placeholder-slate-300"
                  required
                  min="0"
                />
              </div>
            </div>

            {/* Category Pills */}
            <div>
              <label className="block text-xs font-medium text-slate-400 mb-2">Kategori (opsiyonel)</label>
              <div className="flex flex-wrap gap-2">
                {CATEGORIES.map(cat => (
                  <button
                    key={cat}
                    type="button"
                    onClick={() => setCategory(cat === category ? '' : cat)}
                    className={`px-4 py-1.5 rounded-full text-sm font-medium transition-colors flex items-center gap-1.5
                      ${category === cat 
                        ? 'bg-emerald-600 text-white' 
                        : 'bg-slate-100 text-slate-500 hover:bg-slate-200'}`}
                  >
                    {category === cat && <Check size={14} />}
                    {cat}
                  </button>
                ))}
              </div>
            </div>

            {/* Submit Button */}
            <button 
              type="submit"
              disabled={isSubmitting || !title || !amount}
              className="w-full mt-4 bg-emerald-600 hover:bg-emerald-700 disabled:bg-emerald-300 text-white font-bold py-4 rounded-xl flex items-center justify-center gap-2 transition-colors"
            >
              {isSubmitting ? (
                <div className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin" />
              ) : (
                <>
                  <Check size={20} />
                  Vazgeç ve Kaydet
                </>
              )}
            </button>
            <p className="text-center text-xs text-slate-400 mt-2">
              Boş bırakırsan kategoriyi AI otomatik atayacak.
            </p>
          </form>

        </div>
      </div>
    </>
  );
}
