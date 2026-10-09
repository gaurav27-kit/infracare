import React from 'react';
import { PriorityType } from '../../types';

interface PriorityChipProps {
  priority: PriorityType;
}

export const PriorityChip: React.FC<PriorityChipProps> = ({ priority }) => {
  const styles: Record<PriorityType, string> = {
    Low: 'bg-slate-500/20 text-slate-400 border-slate-500/30',
    Medium: 'bg-amber-500/20 text-amber-400 border-amber-500/30',
    High: 'bg-orange-500/20 text-orange-400 border-orange-500/30',
    Critical: 'bg-red-500/20 text-red-400 border-red-500/30',
  };

  return (
    <span
      className={`inline-flex items-center text-[10px] font-bold uppercase tracking-wider px-2 py-0.5 rounded border ${styles[priority] || styles.Low}`}
    >
      {priority}
    </span>
  );
};
