import React from 'react';

export const LoadingSkeleton: React.FC = () => {
  return (
    <div className="space-y-3 animate-pulse">
      <div className="h-20 bg-slate-800/60 rounded-2xl border border-slate-700/40" />
      <div className="h-20 bg-slate-800/60 rounded-2xl border border-slate-700/40" />
      <div className="h-20 bg-slate-800/60 rounded-2xl border border-slate-700/40" />
    </div>
  );
};
