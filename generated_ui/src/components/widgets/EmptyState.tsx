import React from 'react';
import { Inbox } from 'lucide-react';

interface EmptyStateProps {
  title?: string;
  description?: string;
  onReset?: () => void;
}

export const EmptyState: React.FC<EmptyStateProps> = ({
  title = 'No Issues Found',
  description = 'Try adjusting your search criteria or filters.',
  onReset,
}) => {
  return (
    <div className="bg-[#1E293B] border border-slate-700/60 rounded-3xl p-8 text-center space-y-3">
      <div className="w-12 h-12 rounded-2xl bg-slate-800 text-slate-400 mx-auto flex items-center justify-center border border-slate-700/50">
        <Inbox className="w-6 h-6" />
      </div>
      <p className="text-base font-bold text-white">{title}</p>
      <p className="text-xs text-slate-400">{description}</p>
      {onReset && (
        <button
          onClick={onReset}
          className="mt-2 bg-blue-600 hover:bg-blue-700 text-white text-xs px-4 py-2 rounded-xl font-semibold transition-colors"
        >
          Reset Filters
        </button>
      )}
    </div>
  );
};
