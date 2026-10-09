import React from 'react';
import { TabType } from '../types';
import { LayoutDashboard, PlusCircle, ListFilter, Settings } from 'lucide-react';

interface BottomNavProps {
  activeTab: TabType;
  onTabChange: (tab: TabType) => void;
}

export const BottomNav: React.FC<BottomNavProps> = ({ activeTab, onTabChange }) => {
  const tabs = [
    { id: 'dashboard' as TabType, label: 'Dashboard', icon: LayoutDashboard },
    { id: 'report' as TabType, label: 'Report', icon: PlusCircle },
    { id: 'issues' as TabType, label: 'My Issues', icon: ListFilter },
    { id: 'settings' as TabType, label: 'Settings', icon: Settings },
  ];

  return (
    <nav className="fixed bottom-0 left-0 right-0 z-50 bg-[#1E293B]/80 backdrop-blur-xl border-t border-slate-800 px-4 py-2 shadow-2xl flex justify-around items-center max-w-md mx-auto rounded-t-3xl">
      {tabs.map((tab) => {
        const Icon = tab.icon;
        const isActive = activeTab === tab.id;
        return (
          <button
            key={tab.id}
            onClick={() => onTabChange(tab.id)}
            className={`flex flex-col items-center py-1.5 px-3 rounded-2xl transition-all duration-200 ${
              isActive
                ? 'text-blue-400 bg-blue-600/15 font-bold scale-105 shadow-sm'
                : 'text-slate-400 hover:text-slate-200'
            }`}
          >
            <Icon className="w-5 h-5 mb-0.5" />
            <span className="text-[10px] tracking-wide font-medium">{tab.label}</span>
          </button>
        );
      })}
    </nav>
  );
};
