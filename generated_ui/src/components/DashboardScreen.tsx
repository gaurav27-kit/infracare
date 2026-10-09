import React from 'react';
import { TabType, IssueItem } from '../types';
import { Plus, ListFilter, AlertTriangle, Clock, CheckCircle2, ChevronRight, Activity, FileText, Wrench } from 'lucide-react';
import { IssueCard } from './widgets/IssueCard';

interface DashboardScreenProps {
  onNavigateTab: (tab: TabType) => void;
  onSelectIssue: (id: string) => void;
  recentIssues: IssueItem[];
}

export const DashboardScreen: React.FC<DashboardScreenProps> = ({
  onNavigateTab,
  onSelectIssue,
  recentIssues,
}) => {
  return (
    <div className="space-y-6 pb-20">
      {/* Good Morning Header */}
      <div className="space-y-1">
        <h1 className="text-2xl font-bold text-white tracking-tight">Good Morning, Alex</h1>
        <p className="text-slate-400 text-sm">Maintenance status for Engineering Wing Block-A</p>
      </div>

      {/* Quick Actions */}
      <div className="grid grid-cols-2 gap-3">
        <button
          onClick={() => onNavigateTab('report')}
          className="flex items-center justify-center gap-2 primary-gradient text-white py-3.5 px-4 rounded-2xl font-semibold text-sm shadow-lg shadow-blue-600/30 transition-all active:scale-95 hover:opacity-95 cursor-pointer"
        >
          <Plus className="w-5 h-5" />
          <span>Report Issue</span>
        </button>
        <button
          onClick={() => onNavigateTab('issues')}
          className="flex items-center justify-center gap-2 bg-[#1E293B] hover:bg-slate-800 border border-slate-700/60 text-slate-200 py-3.5 px-4 rounded-2xl font-semibold text-sm transition-all active:scale-95 cursor-pointer"
        >
          <FileText className="w-5 h-5 text-blue-400" />
          <span>My Reports</span>
        </button>
      </div>

      {/* Today's Summary Card */}
      <div className="bg-[#1E293B] border border-slate-700/50 rounded-3xl p-5 shadow-xl space-y-4">
        <div className="flex items-center justify-between border-b border-slate-700/60 pb-3">
          <div className="flex items-center gap-2">
            <div className="w-2.5 h-2.5 rounded-full bg-blue-500 animate-pulse" />
            <h3 className="text-sm font-bold text-white tracking-wide">Today's Summary</h3>
          </div>
          <span className="text-[11px] font-medium text-slate-400 bg-slate-800/80 px-2.5 py-0.5 rounded-full border border-slate-700/50">
            Aug 7, 2026
          </span>
        </div>

        <div className="grid grid-cols-2 gap-3">
          {/* Item 1: Reported Today */}
          <div className="bg-slate-900/50 border border-slate-800 p-3 rounded-2xl flex items-center gap-3">
            <div className="w-9 h-9 rounded-xl bg-blue-500/15 text-blue-400 flex items-center justify-center shrink-0">
              <FileText className="w-4 h-4" />
            </div>
            <div>
              <p className="text-lg font-bold text-white leading-none">8</p>
              <p className="text-[11px] font-medium text-slate-400 mt-0.5">Reported Today</p>
            </div>
          </div>

          {/* Item 2: In Progress */}
          <div className="bg-slate-900/50 border border-slate-800 p-3 rounded-2xl flex items-center gap-3">
            <div className="w-9 h-9 rounded-xl bg-amber-500/15 text-amber-400 flex items-center justify-center shrink-0">
              <Wrench className="w-4 h-4" />
            </div>
            <div>
              <p className="text-lg font-bold text-white leading-none">5</p>
              <p className="text-[11px] font-medium text-slate-400 mt-0.5">In Progress</p>
            </div>
          </div>

          {/* Item 3: Resolved Today */}
          <div className="bg-slate-900/50 border border-slate-800 p-3 rounded-2xl flex items-center gap-3">
            <div className="w-9 h-9 rounded-xl bg-green-500/15 text-green-400 flex items-center justify-center shrink-0">
              <CheckCircle2 className="w-4 h-4" />
            </div>
            <div>
              <p className="text-lg font-bold text-white leading-none">12</p>
              <p className="text-[11px] font-medium text-slate-400 mt-0.5">Resolved Today</p>
            </div>
          </div>

          {/* Item 4: Critical Issues */}
          <div className="bg-slate-900/50 border border-slate-800 p-3 rounded-2xl flex items-center gap-3">
            <div className="w-9 h-9 rounded-xl bg-red-500/15 text-red-400 flex items-center justify-center shrink-0">
              <AlertTriangle className="w-4 h-4" />
            </div>
            <div>
              <p className="text-lg font-bold text-red-400 leading-none">2</p>
              <p className="text-[11px] font-medium text-slate-400 mt-0.5">Critical Issues</p>
            </div>
          </div>
        </div>
      </div>

      {/* Summary Statistics Cards */}
      <div className="grid grid-cols-2 gap-3">
        <div className="bg-[#1E293B] p-4 rounded-3xl border border-slate-700/50 ring-1 ring-white/5 flex flex-col justify-between h-28 shadow-md">
          <div className="flex justify-between items-start">
            <span className="text-slate-400 text-xs font-medium">Open Issues</span>
            <Clock className="w-4 h-4 text-blue-400" />
          </div>
          <div className="flex items-end gap-2">
            <span className="text-3xl font-bold text-white">12</span>
            <span className="text-red-400 text-[10px] mb-1 font-medium">+2 today</span>
          </div>
        </div>

        <div className="bg-[#1E293B] p-4 rounded-3xl border border-slate-700/50 ring-1 ring-white/5 flex flex-col justify-between h-28 shadow-md">
          <div className="flex justify-between items-start">
            <span className="text-slate-400 text-xs font-medium">In Progress</span>
            <Activity className="w-4 h-4 text-amber-400" />
          </div>
          <div className="flex items-end gap-2">
            <span className="text-3xl font-bold text-white">05</span>
            <span className="text-amber-400 text-[10px] mb-1 font-medium">3 on schedule</span>
          </div>
        </div>

        <div className="bg-[#1E293B] p-4 rounded-3xl border border-slate-700/50 ring-1 ring-white/5 flex flex-col justify-between h-28 shadow-md">
          <div className="flex justify-between items-start">
            <span className="text-slate-400 text-xs font-medium">Resolved</span>
            <CheckCircle2 className="w-4 h-4 text-green-400" />
          </div>
          <div className="flex items-end gap-2">
            <span className="text-3xl font-bold text-white">124</span>
            <span className="text-green-400 text-[10px] mb-1 font-medium">98% uptime</span>
          </div>
        </div>

        <div className="bg-[#1E293B] p-4 rounded-3xl border border-red-500/30 ring-1 ring-white/5 flex flex-col justify-between h-28 shadow-md bg-gradient-to-br from-[#1E293B] to-red-500/10">
          <div className="flex justify-between items-start">
            <span className="text-red-400 text-xs font-medium">Critical Alerts</span>
            <AlertTriangle className="w-4 h-4 text-red-500" />
          </div>
          <div className="flex items-end gap-2">
            <span className="text-3xl font-bold text-red-500">02</span>
            <span className="text-slate-400 text-[10px] mb-1 font-medium">Needs attention</span>
          </div>
        </div>
      </div>

      {/* Recent Issues List */}
      <div>
        <div className="flex justify-between items-center mb-3">
          <h2 className="text-lg font-bold text-white tracking-tight">Recent Issues</h2>
          <button
            onClick={() => onNavigateTab('issues')}
            className="text-xs font-semibold text-blue-400 hover:text-blue-300 transition-colors flex items-center gap-1 cursor-pointer"
          >
            View All <ChevronRight className="w-3.5 h-3.5" />
          </button>
        </div>

        <div className="space-y-3">
          {recentIssues.slice(0, 3).map((issue) => (
            <IssueCard key={issue.id} issue={issue} onClick={() => onSelectIssue(issue.id)} />
          ))}
        </div>
      </div>
    </div>
  );
};

