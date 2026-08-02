import React, { useState, useEffect } from 'react';
import { Layout } from './components/Layout';
import { Home } from './components/Home';
import { Stats } from './components/Stats';
import { Insights } from './components/Insights';
import { Profile } from './components/Profile';
import { Login } from './components/Login';
import { Register } from './components/Register';
import { AddModal } from './components/AddModal';
import { Entry, InsightData, SavingsGoal } from './types';

export default function App() {
  const [activeTab, setActiveTab] = useState<'home' | 'stats' | 'insights' | 'profile'>('home');
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);
  const [entries, setEntries] = useState<Entry[]>([]);
  const [insightData, setInsightData] = useState<InsightData | null>(null);
  const [goal, setGoal] = useState<SavingsGoal | null>(null);
  const [motivationQuote, setMotivationQuote] = useState<string>('');
  const [loading, setLoading] = useState(true);
  const [insightsLoading, setInsightsLoading] = useState(false);

  // --- Kimlik Doğrulama ---
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [authScreen, setAuthScreen] = useState<'login' | 'register'>('login');
  const [userName, setUserName] = useState('Kullanıcı');
  const [userEmail, setUserEmail] = useState('kullanici@example.com');
  const [userId, setUserId] = useState<string>('');

  // Initial load
  useEffect(() => {
    if (isAuthenticated && userId) {
      fetchData();
    }
  }, [isAuthenticated, userId]);

  const fetchData = async () => {
    if (!userId) return;
    try {
      setLoading(true);
      const entriesRes = await fetch('/api/entries', {
        headers: { 'x-user-id': userId }
      });
      
      const entriesData = await entriesRes.json();
      setEntries(Array.isArray(entriesData) ? entriesData : []);
      await Promise.all([fetchGoals(), fetchMotivation()]);
    } catch (err) {
      console.error("Failed to load data", err);
    } finally {
      setLoading(false);
    }
  };

  const fetchGoals = async () => {
    if (!userId) return;
    try {
      const res = await fetch('/api/goals', { headers: { 'x-user-id': userId } });
      const data = await res.json();
      // Backend hata objesi dönerse (ör. beklenmedik hata) tek bir hedef olarak ele almayalım.
      setGoal(data && typeof data === 'object' && !data.error ? data : null);
    } catch (err) {
      console.error("Failed to load goals", err);
    }
  };

  const fetchMotivation = async () => {
    if (!userId) return;
    try {
      const res = await fetch('/api/motivation', { headers: { 'x-user-id': userId } });
      const data = await res.json();
      setMotivationQuote(data.quote);
    } catch (err) {
      console.error("Failed to load motivation quote", err);
    }
  };

  const addGoal = async (title: string, targetAmount: number) => {
    if (!userId) return;
    const res = await fetch('/api/goals', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-user-id': userId
      },
      body: JSON.stringify({ title, targetAmount })
    });
    const data = await res.json();
    if (!res.ok) {
      throw new Error(data.error || 'Hedef eklenemedi.');
    }
    setGoal(data);
  };

  const refreshInsights = async () => {
    if (!userId) return;
    try {
      setInsightsLoading(true);
      const res = await fetch('/api/insights/refresh', {
        method: 'POST',
        headers: { 'x-user-id': userId }
      });
      
      const data = await res.json();
      setInsightData(data);
    } catch (err) {
      console.error("Failed to refresh insights", err);
    } finally {
      setInsightsLoading(false);
    }
  };

  const handleAddEntry = async (title: string, amount: number, category: string) => {
    if (!userId) return;
    try {
      const res = await fetch('/api/entries', {
        method: 'POST',
        headers: { 
          'Content-Type': 'application/json',
          'x-user-id': userId
        },
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

  const handleLogin = (email: string, uid: string) => {
    setUserEmail(email);
    setUserId(uid);
    setIsAuthenticated(true);
    setActiveTab('home');
  };

  const handleRegister = (name: string, email: string, uid: string) => {
    setUserName(name || 'Kullanıcı');
    setUserEmail(email);
    setUserId(uid);
    setIsAuthenticated(true);
    setActiveTab('home');
  };

  const handleLogout = () => {
    setIsAuthenticated(false);
    setAuthScreen('login');
    setUserId('');
    setEntries([]);
    setInsightData(null);
    setGoal(null);
    setMotivationQuote('');
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
              activeGoal={goal && !goal.is_completed ? goal : null}
              motivationQuote={motivationQuote}
              onAddClick={() => setIsAddModalOpen(true)}
              onNavigateInsights={() => setActiveTab('insights')}
              onRefreshInsights={refreshInsights}
              insightsLoading={insightsLoading}
            />
          )}
          {activeTab === 'stats' && <Stats entries={entries} />}
          {activeTab === 'profile' && (
            <Profile entries={entries} userName={userName} userEmail={userEmail} onLogout={handleLogout} />
          )}
          {activeTab === 'insights' && (
            <Insights 
              entries={entries} 
              insightData={insightData}
              goal={goal}
              onAddGoal={addGoal}
              onRefreshInsights={refreshInsights}
              insightsLoading={insightsLoading}
            />
          )}
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
