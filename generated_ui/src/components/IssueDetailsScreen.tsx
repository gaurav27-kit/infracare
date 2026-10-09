import React from 'react';
import { IssueItem } from '../types';
import { ArrowLeft, Building2, Image as ImageIcon, MapPin, Share2, Check, ArrowDown } from 'lucide-react';
import { StatusChip } from './widgets/StatusChip';
import { PriorityChip } from './widgets/PriorityChip';

interface IssueDetailsScreenProps {
  issue: IssueItem;
  onBack: () => void;
}

export const IssueDetailsScreen: React.FC<IssueDetailsScreenProps> = ({ issue, onBack }) => {
  // Determine current active step index (0: Reported, 1: Assigned, 2: In Progress, 3: Resolved, 4: Closed)
  const steps = ['Reported', 'Assigned', 'In Progress', 'Resolved', 'Closed'];

  const getActiveStepIndex = (status: string) => {
    switch (status) {
      case 'Open':
        return 0; // Reported
      case 'In Progress':
      case 'Critical':
        return 2; // In Progress
      case 'Resolved':
        return 3; // Resolved
      case 'Closed':
        return 4; // Closed
      default:
        return 1; // Assigned
    }
  };

  const currentStepIdx = getActiveStepIndex(issue.status);

  return (
    <div className="space-y-5 pb-20">
      {/* Top Bar */}
      <div className="flex justify-between items-center">
        <button
          onClick={onBack}
          className="p-2 rounded-2xl bg-[#1E293B] border border-slate-700/60 text-white hover:bg-slate-800 transition-colors cursor-pointer"
        >
          <ArrowLeft className="w-5 h-5" />
        </button>
        <span className="font-mono text-sm font-bold text-blue-400 bg-blue-500/10 px-3 py-1 rounded-lg border border-blue-500/20">
          {issue.id}
        </span>
        <button className="p-2 rounded-2xl bg-[#1E293B] border border-slate-700/60 text-slate-400 hover:text-white transition-colors cursor-pointer">
          <Share2 className="w-5 h-5" />
        </button>
      </div>

      {/* Header Info */}
      <div className="space-y-2">
        <div className="flex items-center gap-2">
          <StatusChip status={issue.status} size="md" />
          <PriorityChip priority={issue.priority} />
        </div>

        <h1 className="text-xl font-bold text-white tracking-tight">{issue.title}</h1>
        <p className="text-xs text-slate-400">
          Reported by <span className="text-slate-200 font-medium">{issue.reportedBy || 'Sarah Jenkins'}</span> • {issue.date}
        </p>
      </div>

      {/* Simple Visual Progress Tracker */}
      <div className="bg-[#1E293B] border border-slate-700/60 p-5 rounded-3xl space-y-4 shadow-xl">
        <h2 className="text-xs font-bold text-slate-400 uppercase tracking-wider">Visual Progress Tracker</h2>

        <div className="flex flex-col items-center space-y-1 py-1">
          {steps.map((stepLabel, idx) => {
            const isCompleted = idx < currentStepIdx;
            const isCurrent = idx === currentStepIdx;

            return (
              <React.Fragment key={stepLabel}>
                <div
                  className={`w-full p-3 rounded-2xl border flex items-center justify-between transition-all ${
                    isCurrent
                      ? 'bg-blue-600/20 border-blue-500 text-white shadow-md shadow-blue-500/10'
                      : isCompleted
                      ? 'bg-slate-900/80 border-green-500/40 text-slate-300'
                      : 'bg-slate-900/40 border-slate-800 text-slate-500'
                  }`}
                >
                  <div className="flex items-center gap-3">
                    <div
                      className={`w-7 h-7 rounded-full flex items-center justify-center font-bold text-xs shrink-0 ${
                        isCompleted
                          ? 'bg-green-500 text-white'
                          : isCurrent
                          ? 'bg-blue-600 text-white animate-pulse'
                          : 'bg-slate-800 text-slate-500 border border-slate-700'
                      }`}
                    >
                      {isCompleted ? <Check className="w-4 h-4" /> : idx + 1}
                    </div>
                    <span className={`text-xs font-bold ${isCurrent ? 'text-blue-400' : isCompleted ? 'text-white' : 'text-slate-500'}`}>
                      {stepLabel}
                    </span>
                  </div>

                  {isCurrent && (
                    <span className="text-[10px] font-bold uppercase bg-blue-500/20 text-blue-400 px-2.5 py-0.5 rounded-full border border-blue-500/30">
                      Current Stage
                    </span>
                  )}
                  {isCompleted && (
                    <span className="text-[10px] font-semibold text-green-400">
                      Completed
                    </span>
                  )}
                </div>

                {idx < steps.length - 1 && (
                  <div className="py-0.5 text-slate-600">
                    <ArrowDown className="w-3.5 h-3.5" />
                  </div>
                )}
              </React.Fragment>
            );
          })}
        </div>
      </div>

      {/* Location Details Card (No Campus) */}
      <div className="bg-[#1E293B] border border-slate-700/60 p-5 rounded-3xl space-y-3 shadow-sm">
        <div className="flex items-center gap-2 text-blue-400">
          <MapPin className="w-4.5 h-4.5" />
          <h2 className="text-sm font-bold text-white">Location Details</h2>
        </div>
        <div className="grid grid-cols-2 gap-3 text-xs pt-1">
          <div className="bg-slate-900/50 p-2.5 rounded-2xl border border-slate-800">
            <span className="text-slate-500 block text-[10px] uppercase font-bold">Building</span>
            <span className="text-white font-medium truncate block mt-0.5">{issue.building || issue.location}</span>
          </div>
          <div className="bg-slate-900/50 p-2.5 rounded-2xl border border-slate-800">
            <span className="text-slate-500 block text-[10px] uppercase font-bold">Floor</span>
            <span className="text-white font-medium truncate block mt-0.5">{issue.floor || 'Ground Floor'}</span>
          </div>
          <div className="bg-slate-900/50 p-2.5 rounded-2xl border border-slate-800">
            <span className="text-slate-500 block text-[10px] uppercase font-bold">Room / Space</span>
            <span className="text-slate-200 font-medium truncate block mt-0.5">{issue.space || 'General Area'}</span>
          </div>
          <div className="bg-slate-900/50 p-2.5 rounded-2xl border border-slate-800">
            <span className="text-slate-500 block text-[10px] uppercase font-bold">Asset</span>
            <span className="text-blue-400 font-semibold truncate block mt-0.5">{issue.asset || 'None'}</span>
          </div>
        </div>
      </div>

      {/* Description Card */}
      <div className="bg-[#1E293B] border border-slate-700/60 p-5 rounded-3xl space-y-2 shadow-sm">
        <div className="flex items-center gap-2 text-blue-400">
          <Building2 className="w-4.5 h-4.5" />
          <h2 className="text-sm font-bold text-white">Description</h2>
        </div>
        <p className="text-xs text-slate-300 leading-relaxed pt-1">
          {issue.description ||
            'Significant water pooling observed around the base of Chiller Unit C-02 in Utility Room 304-B. The secondary containment tray appears to have overflowed.'}
        </p>
      </div>

      {/* Photos Gallery Card */}
      <div className="bg-[#1E293B] border border-slate-700/60 p-5 rounded-3xl space-y-3 shadow-sm">
        <div className="flex items-center gap-2 text-blue-400">
          <ImageIcon className="w-4.5 h-4.5" />
          <h2 className="text-sm font-bold text-white">Image Gallery (2)</h2>
        </div>
        <div className="grid grid-cols-2 gap-2.5">
          <div className="h-28 rounded-2xl overflow-hidden border border-slate-700 bg-slate-900 relative group">
            <img
              src="https://images.unsplash.com/photo-1581092160607-ee22621dd758?auto=format&fit=crop&w=400&q=80"
              alt="Site Photo 1"
              className="w-full h-full object-cover group-hover:scale-105 transition-transform"
            />
            <span className="absolute bottom-2 left-2 text-[10px] bg-slate-900/80 text-white px-2 py-0.5 rounded-md backdrop-blur-xs font-mono">
              Site_Photo_01.jpg
            </span>
          </div>

          <div className="h-28 rounded-2xl overflow-hidden border border-slate-700 bg-slate-900 relative group">
            <img
              src="https://images.unsplash.com/photo-1621905251189-08b45d6a269e?auto=format&fit=crop&w=400&q=80"
              alt="Site Photo 2"
              className="w-full h-full object-cover group-hover:scale-105 transition-transform"
            />
            <span className="absolute bottom-2 left-2 text-[10px] bg-slate-900/80 text-white px-2 py-0.5 rounded-md backdrop-blur-xs font-mono">
              Gauge_Readout.jpg
            </span>
          </div>
        </div>
      </div>
    </div>
  );
};

