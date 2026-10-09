import React, { useState } from 'react';
import { IssueItem } from '../types';
import { IssueCard } from './widgets/IssueCard';
import { SearchBar } from './widgets/SearchBar';
import { EmptyState } from './widgets/EmptyState';

interface MyIssuesScreenProps {
  issues: IssueItem[];
  onSelectIssue: (id: string) => void;
}

export const MyIssuesScreen: React.FC<MyIssuesScreenProps> = ({ issues, onSelectIssue }) => {
  const [search, setSearch] = useState('');
  const [filter, setFilter] = useState<string>('All');

  const filtered = issues.filter((issue) => {
    const matchesSearch =
      issue.title.toLowerCase().includes(search.toLowerCase()) ||
      issue.id.toLowerCase().includes(search.toLowerCase()) ||
      issue.location.toLowerCase().includes(search.toLowerCase());

    if (filter === 'All') return matchesSearch;
    return matchesSearch && issue.status.toLowerCase() === filter.toLowerCase();
  });

  const filterChips = ['All', 'Open', 'In Progress', 'Resolved', 'Critical'];

  return (
    <div className="space-y-4 pb-20">
      <div>
        <h1 className="text-2xl font-bold text-white tracking-tight">My Reports</h1>
        <p className="text-slate-400 text-sm mt-1">Track and filter all reported campus issues.</p>
      </div>

      {/* Search Bar */}
      <SearchBar value={search} onChange={setSearch} />

      {/* Filter Chips */}
      <div className="flex gap-2 overflow-x-auto pb-1 no-scrollbar">
        {filterChips.map((chip) => {
          const isSelected = filter === chip;
          return (
            <button
              key={chip}
              onClick={() => setFilter(chip)}
              className={`px-4 py-1.5 rounded-full text-xs font-semibold whitespace-nowrap transition-all cursor-pointer ${
                isSelected
                  ? 'bg-blue-600 text-white shadow-md shadow-blue-500/20 font-bold'
                  : 'bg-[#1E293B] text-slate-400 border border-slate-700/60 hover:text-white'
              }`}
            >
              {chip}
            </button>
          );
        })}
      </div>

      {/* Issues List */}
      <div className="space-y-3 pt-1">
        {filtered.length === 0 ? (
          <EmptyState
            title="No Issues Found"
            description="Try adjusting your search criteria or filters."
            onReset={() => {
              setSearch('');
              setFilter('All');
            }}
          />
        ) : (
          filtered.map((issue) => (
            <IssueCard key={issue.id} issue={issue} onClick={() => onSelectIssue(issue.id)} />
          ))
        )}
      </div>
    </div>
  );
};

