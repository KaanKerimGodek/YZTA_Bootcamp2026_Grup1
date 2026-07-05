import React, { useState, useEffect } from 'react';
import { Layout } from './components/Layout';
import { Home } from './components/Home';
import { Stats } from './components/Stats';
import { AddModal } from './components/AddModal';
import { Entry, InsightData } from './types';

export default function App() {
  const [activeTab, setActiveTab] = useState<'home' | 'stats' | 'insights' | 'profile'>('home');
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);
  const [entries, setEntries] = useState<Entry[]>([]);
  const [insightData, setInsightData] = useState<InsightData | null>(null);
  const [loading, setLoading] = useState(true);

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

  return (
    <Layout 
      activeTab={activeTab} 
      onTabChange={setActiveTab}
      onAddClick={() => setIsAddModalOpen(true)}
    >
      {loading && entries.length === 0 ? (
        <div className="flex justify-center py-20">
           <div className="w-8 h-8 border-4 border-teal-500/30 border-t-teal-500 rounded-full animate-spin" />
        </div>
      ) : (
        <>
          {activeTab === 'home' && <Home entries={entries} insightData={insightData} onAddClick={() => setIsAddModalOpen(true)} />}
          {activeTab === 'stats' && <Stats entries={entries} />}
          {activeTab === 'profile' && (
             <div className="py-20 text-center text-slate-500">
                Profil sayfası henüz yapım aşamasında.
             </div>
          )}
          {activeTab === 'insights' && (
             <div className="py-20 text-center text-slate-500">
                Detaylı yapay zeka analizleri sayfası yapım aşamasında.
             </div>
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
