import React from 'react';
import { StatusType } from '../../types';

interface StatusChipProps {
  status: StatusType;
  size?: 'sm' | 'md';
}

export const StatusChip: React.FC<StatusChipProps> = ({ status, size = 'sm' }) => {
  const styles: Record<StatusType, string> = {
    Open: 'bg-blue-500/20 text-blue-400 border-blue-500/30',
    'In Progress': 'bg-amber-500/20 text-amber-400 border-amber-500/30',
    Resolved: 'bg-green-500/20 text-green-400 border-green-500/30',
    Critical: 'bg-red-500/20 text-red-400 border-red-500/30',
    Closed: 'bg-slate-500/20 text-slate-400 border-slate-500/30',
  };

  const sizeClasses = size === 'sm' ? 'px-2.5 py-0.5 text-[10px]' : 'px-3 py-1 text-xs';

  return (
    <span
      className={`inline-flex items-center font-bold uppercase tracking-wider rounded-full border ${styles[status] || styles.Open} ${sizeClasses}`}
    >
      {status}
    </span>
  );
};
