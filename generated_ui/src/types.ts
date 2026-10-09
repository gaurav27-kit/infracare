export type TabType = 'dashboard' | 'report' | 'issues' | 'settings';

export type PriorityType = 'Low' | 'Medium' | 'High' | 'Critical';

export type StatusType = 'Open' | 'In Progress' | 'Resolved' | 'Critical' | 'Closed';

export interface IssueItem {
  id: string;
  title: string;
  location: string;
  date: string;
  status: StatusType;
  priority: PriorityType;
  campus?: string;
  building?: string;
  floor?: string;
  space?: string;
  asset?: string;
  description?: string;
  reportedBy?: string;
}
