import React from 'react';
import { IssueItem } from '../../types';
import { StatusChip } from './StatusChip';
import { PriorityChip } from './PriorityChip';
import { Building2, Clock, Wrench } from 'lucide-react';

interface IssueCardProps {
  issue: IssueItem;
  onClick: () => void;
}

export const IssueCard: React.FC<IssueCardProps> = ({ issue, onClick }) => {
  return (
    <div
      onClick={onClick}
      className="bg-[#1E293B] p-4 rounded-2xl flex flex-col justify-between border border-slate-700/40 hover:border-blue-500/50 transition-all cursor-pointer shadow-sm active:scale-[0.99] group space-y-2.5"
    >
      {/* Top Header: Issue Number & Status */}
      <div className="flex justify-between items-center">
        <span className="font-mono text-xs font-bold text-blue-400 bg-blue-500/10 px-2.5 py-1 rounded-md border border-blue-500/20 tracking-wide">
          {issue.id}
        </span>
        <StatusChip status={issue.status} />
      </div>

      {/* Title */}
      <h3 className="font-bold text-white text-sm line-clamp-1 group-hover:text-blue-400 transition-colors">
        {issue.title}
      </h3>

      {/* Building & Category/Space */}
      <div className="space-y-1 text-xs text-slate-400">
        <p className="flex items-center gap-1.5">
          <Building2 className="w-3.5 h-3.5 text-slate-500 shrink-0" />
          <span className="truncate">{issue.building || issue.location}</span>
        </p>

        {issue.space && (
          <p className="flex items-center gap-1.5 text-slate-400 text-[11px]">
            <Wrench className="w-3.5 h-3.5 text-slate-500 shrink-0" />
            <span className="truncate">{issue.space}</span>
          </p>
        )}
      </div>

      {/* Bottom Footer: Time & Priority */}
      <div className="flex justify-between items-center pt-2.5 border-t border-slate-700/40 text-xs">
        <span className="text-slate-500 text-[11px] flex items-center gap-1">
          <Clock className="w-3 h-3 text-slate-500" />
          {issue.date}
        </span>
        <PriorityChip priority={issue.priority} />
      </div>
    </div>
  );
};
