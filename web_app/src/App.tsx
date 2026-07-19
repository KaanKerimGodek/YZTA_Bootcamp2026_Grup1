import React, { useState, useEffect } from 'react';
import { Layout } from './components/Layout';
import { Home } from './components/Home';
import { Stats } from './components/Stats';
import { Insights } from './components/Insights';
import { Profile } from './components/Profile';
import { Login } from './components/Login';
import { Register } from './components/Register';
import { AddModal } from './components/AddModal';
import { Entry, InsightData } from './types';

export default function App() {
  const [activeTab, setActiveTab] = useState<'home' | 'stats' | 'insights' | 'profile'>('home');
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);
  const [entries, setEntries] = useState<Entry[]>([]);
  const [insightData, setInsightData] = useState<InsightData | null>(null);
  const [loading, setLoading] = useState(true);

  // --- Kimlik Doğrulama (mock) ---
  // NOT: Gerçek kimlik doğrulama backend/Supabase entegrasyonu tamamlandığında
  // bu state'ler gerçek oturum bilgileriyle değiştirilecektir.
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [authScreen, setAuthScreen] = useState<'login' | 'register'>('login');
  const [userName, setUserName] = useState('Kullanıcı');
  const [userEmail, setUserEmail] = useState('kullanici@example.com');

  // Initial load
  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    try {
      setLoading(true);
      const [entriesRes, insightsRes] = await Promise.all([
        fetch('/api/entries'),
        fetch('/api/insights')
      ]);
      
      const entriesData = await entriesRes.json();
      const insightsData = await insightsRes.json();
      
      setEntries(entriesData);
      setInsightData(insightsData);
    } catch (err) {
      console.error("Failed to load data", err);
    } finally {
      setLoading(false);
    }
  };

  const handleAddEntry = async (title: string, amount: number, category: string) => {
    try {
      const res = await fetch('/api/entries', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ title, amount, category })
      });
      
      if (res.ok) {
        // Refresh data to get new AI insights and the full sorted list
        await fetchData();
      }
    } catch (err) {
      console.error("Failed to add entry", err);
    }
  };

  const handleLogin = (email: string) => {
    setUserEmail(email);
    setIsAuthenticated(true);
    setActiveTab('home');
  };

  const handleRegister = (name: string, email: string) => {
    setUserName(name || 'Kullanıcı');
    setUserEmail(email);
    setIsAuthenticated(true);
    setActiveTab('home');
  };

  const handleLogout = () => {
    setIsAuthenticated(false);
    setAuthScreen('login');
  };

  if (!isAuthenticated) {
    return authScreen === 'login' ? (
      <Login onLogin={handleLogin} onNavigateRegister={() => setAuthScreen('register')} />
    ) : (
      <Register onRegister={handleRegister} onNavigateLogin={() => setAuthScreen('login')} />
    );
  }

  return (
    <Layout 
      activeTab={activeTab} 
      onTabChange={setActiveTab}
      onAddClick={() => setIsAddModalOpen(true)}
      userName={userName}
    >
      {loading && entries.length === 0 ? (
        <div className="flex justify-center py-20">
           <div className="w-8 h-8 border-4 border-teal-500/30 border-t-teal-500 rounded-full animate-spin" />
        </div>
      ) : (
        <>
          {activeTab === 'home' && (
            <Home
              entries={entries}
              insightData={insightData}
              onAddClick={() => setIsAddModalOpen(true)}
              onNavigateInsights={() => setActiveTab('insights')}
            />
          )}
          {activeTab === 'stats' && <Stats entries={entries} />}
          {activeTab === 'profile' && (
            <Profile entries={entries} userName={userName} userEmail={userEmail} onLogout={handleLogout} />
          )}
          {activeTab === 'insights' && <Insights entries={entries} insightData={insightData} />}
        </>
      )}

      {isAddModalOpen && (
        <AddModal 
          onClose={() => setIsAddModalOpen(false)} 
          onAdd={handleAddEntry} 
        />
      )}
    </Layout>
  );
}
