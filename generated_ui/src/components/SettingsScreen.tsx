import React, { useState } from 'react';
import { Building2, Info, HelpCircle, Shield, FileText, ChevronRight, CheckCircle2 } from 'lucide-react';

export const SettingsScreen: React.FC = () => {
  const [activeDialog, setActiveDialog] = useState<string | null>(null);

  return (
    <div className="space-y-5 pb-20">
      <div>
        <h1 className="text-2xl font-bold text-[#F8FAFC]">Settings</h1>
        <p className="text-[#94A3B8] text-sm mt-1">Manage application info and preferences.</p>
      </div>

      {/* App Information Header */}
      <div className="bg-[#1E293B] border border-[#334155] p-5 rounded-2xl flex items-center gap-4 shadow-sm">
        <div className="w-12 h-12 rounded-xl bg-[#2563EB]/15 text-[#2563EB] flex items-center justify-center shrink-0">
          <Building2 className="w-6 h-6" />
        </div>
        <div>
          <h3 className="font-bold text-[#F8FAFC] text-base">InfraCare Mobile</h3>
          <p className="text-xs text-[#94A3B8]">Campus Infrastructure Management</p>
          <span className="inline-block mt-1 text-[10px] font-semibold bg-[#334155] text-[#94A3B8] px-2 py-0.5 rounded">
            v1.0.0 (Build 2026.1)
          </span>
        </div>
      </div>

      {/* About Section */}
      <div className="space-y-2">
        <h2 className="text-xs font-bold text-[#64748B] uppercase tracking-wider px-1">App Information</h2>

        <div className="bg-[#1E293B] border border-[#334155] rounded-2xl divide-y divide-[#334155]/60 overflow-hidden shadow-sm">
          <button
            onClick={() => setActiveDialog('about')}
            className="w-full p-4 text-left flex items-center justify-between hover:bg-[#334155]/40 transition-colors"
          >
            <div className="flex items-center gap-3">
              <Info className="w-5 h-5 text-[#2563EB]" />
              <div>
                <p className="text-sm font-semibold text-[#F8FAFC]">About InfraCare</p>
                <p className="text-xs text-[#94A3B8]">Final year engineering project overview</p>
              </div>
            </div>
            <ChevronRight className="w-4 h-4 text-[#64748B]" />
          </button>

          <button
            onClick={() => setActiveDialog('help')}
            className="w-full p-4 text-left flex items-center justify-between hover:bg-[#334155]/40 transition-colors"
          >
            <div className="flex items-center gap-3">
              <HelpCircle className="w-5 h-5 text-[#2563EB]" />
              <div>
                <p className="text-sm font-semibold text-[#F8FAFC]">Help & FAQ</p>
                <p className="text-xs text-[#94A3B8]">Usage guides & support info</p>
              </div>
            </div>
            <ChevronRight className="w-4 h-4 text-[#64748B]" />
          </button>

          <button
            onClick={() => setActiveDialog('privacy')}
            className="w-full p-4 text-left flex items-center justify-between hover:bg-[#334155]/40 transition-colors"
          >
            <div className="flex items-center gap-3">
              <Shield className="w-5 h-5 text-[#2563EB]" />
              <div>
                <p className="text-sm font-semibold text-[#F8FAFC]">Privacy Policy</p>
                <p className="text-xs text-[#94A3B8]">Data protection guidelines</p>
              </div>
            </div>
            <ChevronRight className="w-4 h-4 text-[#64748B]" />
          </button>

          <button
            onClick={() => setActiveDialog('terms')}
            className="w-full p-4 text-left flex items-center justify-between hover:bg-[#334155]/40 transition-colors"
          >
            <div className="flex items-center gap-3">
              <FileText className="w-5 h-5 text-[#2563EB]" />
              <div>
                <p className="text-sm font-semibold text-[#F8FAFC]">Terms & Conditions</p>
                <p className="text-xs text-[#94A3B8]">Legal terms and usage policies</p>
              </div>
            </div>
            <ChevronRight className="w-4 h-4 text-[#64748B]" />
          </button>
        </div>
      </div>

      {/* Preferences */}
      <div className="space-y-2">
        <h2 className="text-xs font-bold text-[#64748B] uppercase tracking-wider px-1">Preferences</h2>

        <div className="bg-[#1E293B] border border-[#334155] rounded-2xl p-4 flex items-center justify-between shadow-sm">
          <div>
            <p className="text-sm font-semibold text-[#F8FAFC]">Material 3 Dark Theme</p>
            <p className="text-xs text-[#94A3B8]">Always enabled (#0F172A / #1E293B)</p>
          </div>
          <div className="w-5 h-5 rounded-full bg-[#22C55E] text-white flex items-center justify-center">
            <CheckCircle2 className="w-3.5 h-3.5" />
          </div>
        </div>
      </div>

      {/* Modal Dialogs */}
      {activeDialog && (
        <div className="fixed inset-0 z-50 bg-black/70 flex items-center justify-center p-4">
          <div className="bg-[#1E293B] border border-[#334155] p-6 rounded-2xl max-w-sm w-full space-y-4 shadow-2xl">
            <h3 className="text-base font-bold text-[#F8FAFC] capitalize">
              {activeDialog === 'about'
                ? 'About InfraCare'
                : activeDialog === 'help'
                ? 'Help & Support'
                : activeDialog === 'privacy'
                ? 'Privacy Policy'
                : 'Terms & Conditions'}
            </h3>

            <p className="text-xs text-[#94A3B8] leading-relaxed">
              {activeDialog === 'about'
                ? 'InfraCare is an engineering project designed to provide mobile-first campus infrastructure management, incident reporting, and real-time dispatch tracking.'
                : activeDialog === 'help'
                ? 'To report a fault, go to the Report tab, select your location, describe the issue, and tap Submit. Tickets are dispatched immediately to facilities staff.'
                : activeDialog === 'privacy'
                ? 'Your location telemetry and report details are stored securely and used exclusively for maintenance operations and safety audits.'
                : 'Users agree to submit authentic reports. Misuse or false emergency reports may lead to suspension of access.'}
            </p>

            <button
              onClick={() => setActiveDialog(null)}
              className="w-full bg-[#2563EB] hover:bg-[#1D4ED8] text-white py-2.5 rounded-xl font-semibold text-xs mt-2"
            >
              Close
            </button>
          </div>
        </div>
      )}
    </div>
  );
};
