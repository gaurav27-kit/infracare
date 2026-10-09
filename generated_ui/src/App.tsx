import React, { useState } from 'react';
import { TabType, IssueItem } from './types';
import { DashboardScreen } from './components/DashboardScreen';
import { ReportIssueScreen } from './components/ReportIssueScreen';
import { MyIssuesScreen } from './components/MyIssuesScreen';
import { IssueDetailsScreen } from './components/IssueDetailsScreen';
import { SettingsScreen } from './components/SettingsScreen';
import { BottomNav } from './components/BottomNav';
import { Building2 } from 'lucide-react';

export default function App() {
  const [activeTab, setActiveTab] = useState<TabType>('dashboard');
  const [selectedIssueId, setSelectedIssueId] = useState<string | null>(null);

  const [issues] = useState<IssueItem[]>([
    {
      id: 'ISS-0204',
      title: 'Broken AC Unit in Library 2nd Floor',
      location: 'Main Library Block A, 2nd Floor',
      date: 'Today, 14:30',
      status: 'In Progress',
      priority: 'High',
      building: 'Main Library Block A',
      floor: '2nd Floor (HVAC Sector)',
      space: 'Utility Room 304-B',
      asset: 'Chiller Unit C-02',
      reportedBy: 'Sarah Jenkins',
      description:
        'Significant water pooling observed around the base of Chiller Unit C-02 in Utility Room 304-B. The secondary containment tray appears to have overflowed. Pressure readings on the primary condenser line are fluctuating wildly.',
    },
    {
      id: 'ISS-0203',
      title: 'Network Switch Outage in Engineering',
      location: 'Engineering Block A, Server Room',
      date: 'Today, 10:15',
      status: 'Open',
      priority: 'Critical',
      building: 'Engineering Block A',
      floor: 'Ground Floor',
      space: 'Server Room 204-B',
      asset: 'Network Switch Rack 04',
      reportedBy: 'David Miller',
      description:
        'Core network switch rack 04 experienced a sudden hardware kernel fault. Multiple departmental subnets offline.',
    },
    {
      id: 'ISS-0202',
      title: 'Water Pipe Leakage near Cafeteria',
      location: 'Science Hall Block B, Basement',
      date: 'Yesterday, 16:45',
      status: 'Resolved',
      priority: 'Low',
      building: 'Science Hall Block B',
      floor: 'Basement Level B1',
      space: 'Cafeteria Central',
      asset: 'Primary Water Pump P-1',
      reportedBy: 'Elena Rostova',
      description: 'Minor joint leak repaired and pressure test completed successfully.',
    },
    {
      id: 'ISS-0201',
      title: 'Flickering Elevator Lights in Student Center',
      location: 'Campus Student Center, Elevator 2',
      date: 'Oct 22, 09:20',
      status: 'In Progress',
      priority: 'Medium',
      building: 'Campus Student Center',
      floor: 'Ground Floor',
      space: 'Elevator Shaft 2',
      asset: 'Elevator Shaft 2',
      reportedBy: 'Marcus Chen',
      description: 'Internal lighting ballast faulty.',
    },
  ]);

  const handleSelectIssue = (id: string) => {
    setSelectedIssueId(id);
  };

  const selectedIssue = issues.find((i) => i.id === selectedIssueId) || issues[0];

  return (
    <div className="min-h-screen bg-[#0F172A] text-[#F8FAFC] flex flex-col font-sans">
      {/* Top Header Bar */}
      <header className="sticky top-0 z-40 bg-[#0F172A]/90 backdrop-blur-md border-b border-[#334155]/60 px-4 py-3 flex items-center justify-between max-w-md mx-auto w-full">
        <div className="flex items-center gap-2">
          <div className="w-8 h-8 rounded-xl bg-[#2563EB]/20 border border-[#2563EB]/40 flex items-center justify-center text-[#2563EB]">
            <Building2 className="w-4 h-4" />
          </div>
          <div>
            <span className="font-bold text-base text-[#2563EB] tracking-tight">InfraCare</span>
            <span className="text-[10px] text-[#64748B] block -mt-1 font-medium">Campus Infrastructure</span>
          </div>
        </div>

        <div className="flex items-center gap-2">
          <span className="text-[10px] bg-[#22C55E]/15 text-[#22C55E] border border-[#22C55E]/30 font-semibold px-2 py-0.5 rounded-full">
            REST API Ready
          </span>
        </div>
      </header>

      {/* Main Screen Canvas Container (Mobile Frame) */}
      <main className="flex-1 max-w-md mx-auto w-full px-4 pt-4 pb-12">
        {selectedIssueId ? (
          <IssueDetailsScreen issue={selectedIssue} onBack={() => setSelectedIssueId(null)} />
        ) : (
          <>
            {activeTab === 'dashboard' && (
              <DashboardScreen
                onNavigateTab={(tab) => {
                  setActiveTab(tab);
                  setSelectedIssueId(null);
                }}
                onSelectIssue={handleSelectIssue}
                recentIssues={issues}
              />
            )}

            {activeTab === 'report' && (
              <ReportIssueScreen
                onSubmitSuccess={() => {
                  setActiveTab('issues');
                  setSelectedIssueId(null);
                }}
              />
            )}

            {activeTab === 'issues' && (
              <MyIssuesScreen issues={issues} onSelectIssue={handleSelectIssue} />
            )}

            {activeTab === 'settings' && <SettingsScreen />}
          </>
        )}
      </main>

      {/* Bottom Navigation */}
      {!selectedIssueId && (
        <BottomNav
          activeTab={activeTab}
          onTabChange={(tab) => {
            setActiveTab(tab);
            setSelectedIssueId(null);
          }}
        />
      )}
    </div>
  );
}
