import React, { useState, useRef } from 'react';
import { PriorityType } from '../types';
import { Check, ArrowRight, ArrowLeft, Image as ImageIcon, Camera, CheckCircle2, Trash2, FolderPlus } from 'lucide-react';

interface ReportIssueScreenProps {
  onSubmitSuccess: () => void;
}

export const ReportIssueScreen: React.FC<ReportIssueScreenProps> = ({ onSubmitSuccess }) => {
  const [step, setStep] = useState<number>(1);
  const fileInputRef = useRef<HTMLInputElement>(null);

  // Form State - Removed Campus
  const [building, setBuilding] = useState('Engineering Block A');
  const [floor, setFloor] = useState('Ground Floor');
  const [space, setSpace] = useState('Utility Room 304');
  const [asset, setAsset] = useState('HVAC Chiller Unit C-02');

  const [title, setTitle] = useState('Water Leakage in Utility Room');
  const [priority, setPriority] = useState<PriorityType>('High');
  const [description, setDescription] = useState(
    'Significant water pooling observed near Chiller Unit C-02 in Utility Room. Requires urgent maintenance inspection.'
  );

  // Photos state with mock previews
  const [photos, setPhotos] = useState<string[]>([
    'https://images.unsplash.com/photo-1581092160607-ee22621dd758?auto=format&fit=crop&w=300&q=80',
  ]);
  const [isSubmitted, setIsSubmitted] = useState(false);

  const handleNext = () => {
    if (step < 3) {
      setStep(step + 1);
    } else {
      setIsSubmitted(true);
    }
  };

  const handleBack = () => {
    if (step > 1) {
      setStep(step - 1);
    }
  };

  const handleConfirmSubmit = () => {
    setIsSubmitted(false);
    onSubmitSuccess();
  };

  const handleTakePhoto = () => {
    // Add a photo preview
    const samplePhotos = [
      'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?auto=format&fit=crop&w=300&q=80',
      'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?auto=format&fit=crop&w=300&q=80',
    ];
    const newPhoto = samplePhotos[photos.length % samplePhotos.length];
    setPhotos([...photos, newPhoto]);
  };

  const handleFileUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
      const file = e.target.files[0];
      const url = URL.createObjectURL(file);
      setPhotos([...photos, url]);
    }
  };

  const handleRemovePhoto = (index: number) => {
    setPhotos(photos.filter((_, i) => i !== index));
  };

  return (
    <div className="space-y-6 pb-20">
      <div>
        <h1 className="text-2xl font-bold text-white tracking-tight">Report New Issue</h1>
        <p className="text-slate-400 text-sm mt-1">Follow the steps to submit an infrastructure ticket.</p>
      </div>

      {/* Stepper Header */}
      <div className="flex items-center justify-between px-2 relative">
        <div className="flex flex-col items-center z-10">
          <div
            className={`w-8 h-8 rounded-full flex items-center justify-center font-bold text-xs transition-colors ${
              step > 1
                ? 'bg-green-500 text-white'
                : step === 1
                ? 'bg-blue-600 text-white'
                : 'bg-slate-700 text-slate-400'
            }`}
          >
            {step > 1 ? <Check className="w-4 h-4" /> : '1'}
          </div>
          <span className={`text-[11px] mt-1.5 font-medium ${step === 1 ? 'text-blue-400' : 'text-slate-400'}`}>
            Location
          </span>
        </div>

        <div className={`flex-1 h-0.5 mx-2 ${step > 1 ? 'bg-green-500' : 'bg-slate-700'}`} />

        <div className="flex flex-col items-center z-10">
          <div
            className={`w-8 h-8 rounded-full flex items-center justify-center font-bold text-xs transition-colors ${
              step > 2
                ? 'bg-green-500 text-white'
                : step === 2
                ? 'bg-blue-600 text-white'
                : 'bg-slate-700 text-slate-400'
            }`}
          >
            {step > 2 ? <Check className="w-4 h-4" /> : '2'}
          </div>
          <span className={`text-[11px] mt-1.5 font-medium ${step === 2 ? 'text-blue-400' : 'text-slate-400'}`}>
            Details
          </span>
        </div>

        <div className={`flex-1 h-0.5 mx-2 ${step > 2 ? 'bg-green-500' : 'bg-slate-700'}`} />

        <div className="flex flex-col items-center z-10">
          <div
            className={`w-8 h-8 rounded-full flex items-center justify-center font-bold text-xs transition-colors ${
              step === 3 ? 'bg-blue-600 text-white' : 'bg-slate-700 text-slate-400'
            }`}
          >
            3
          </div>
          <span className={`text-[11px] mt-1.5 font-medium ${step === 3 ? 'text-blue-400' : 'text-slate-400'}`}>
            Review
          </span>
        </div>
      </div>

      {/* Step 1: Location (Sequence: Building -> Floor -> Room/Space -> Asset Optional) */}
      {step === 1 && (
        <div className="bg-[#1E293B] border border-slate-700/60 p-5 rounded-3xl space-y-4 shadow-sm">
          <h2 className="text-base font-bold text-white">Step 1: Select Location</h2>

          <div>
            <label className="block text-xs font-medium text-slate-400 mb-1.5">Building</label>
            <select
              value={building}
              onChange={(e) => setBuilding(e.target.value)}
              className="w-full bg-slate-900 border border-slate-700 text-white text-sm rounded-2xl p-3 focus:outline-none focus:border-blue-500"
            >
              <option>Engineering Block A</option>
              <option>Main Library Block A</option>
              <option>Science Hall Block B</option>
              <option>Campus Student Center</option>
            </select>
          </div>

          <div>
            <label className="block text-xs font-medium text-slate-400 mb-1.5">Floor</label>
            <select
              value={floor}
              onChange={(e) => setFloor(e.target.value)}
              className="w-full bg-slate-900 border border-slate-700 text-white text-sm rounded-2xl p-3 focus:outline-none focus:border-blue-500"
            >
              <option>Ground Floor</option>
              <option>Basement Level B1</option>
              <option>1st Floor</option>
              <option>2nd Floor (HVAC Sector)</option>
              <option>3rd Floor</option>
            </select>
          </div>

          <div>
            <label className="block text-xs font-medium text-slate-400 mb-1.5">Room / Space</label>
            <select
              value={space}
              onChange={(e) => setSpace(e.target.value)}
              className="w-full bg-slate-900 border border-slate-700 text-white text-sm rounded-2xl p-3 focus:outline-none focus:border-blue-500"
            >
              <option value="">-- Select Room / Space --</option>
              <option value="Utility Room 304">Utility Room 304</option>
              <option value="Server Room 204-B">Server Room 204-B</option>
              <option value="Auditorium Main Hall">Auditorium Main Hall</option>
              <option value="Cafeteria Central">Cafeteria Central</option>
            </select>
          </div>

          {/* Asset Dropdown appears ONLY after a Space is selected */}
          {space !== '' && (
            <div className="animate-in fade-in slide-in-from-top-2 duration-200">
              <label className="block text-xs font-medium text-blue-400 mb-1.5">
                Asset (Optional)
              </label>
              <select
                value={asset}
                onChange={(e) => setAsset(e.target.value)}
                className="w-full bg-slate-900 border border-blue-500/40 text-white text-sm rounded-2xl p-3 focus:outline-none focus:border-blue-500"
              >
                <option value="">None / Unspecified Asset</option>
                <option value="HVAC Chiller Unit C-02">HVAC Chiller Unit C-02</option>
                <option value="Network Switch Rack 04">Network Switch Rack 04</option>
                <option value="Primary Water Pump P-1">Primary Water Pump P-1</option>
                <option value="Elevator Shaft 2">Elevator Shaft 2</option>
              </select>
            </div>
          )}
        </div>
      )}

      {/* Step 2: Issue Details */}
      {step === 2 && (
        <div className="bg-[#1E293B] border border-slate-700/60 p-5 rounded-3xl space-y-4 shadow-sm">
          <h2 className="text-base font-bold text-white">Step 2: Issue Details</h2>

          <div>
            <label className="block text-xs font-medium text-slate-400 mb-1.5">Issue Title</label>
            <input
              type="text"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              className="w-full bg-slate-900 border border-slate-700 text-white text-sm rounded-2xl p-3 focus:outline-none focus:border-blue-500"
              placeholder="e.g. Broken AC Unit"
            />
          </div>

          <div>
            <label className="block text-xs font-medium text-slate-400 mb-1.5">Priority Level</label>
            <div className="grid grid-cols-4 gap-2">
              {(['Low', 'Medium', 'High', 'Critical'] as PriorityType[]).map((p) => (
                <button
                  key={p}
                  type="button"
                  onClick={() => setPriority(p)}
                  className={`py-2.5 rounded-2xl text-xs font-semibold border transition-all cursor-pointer ${
                    priority === p
                      ? 'bg-blue-600 text-white border-blue-500 shadow-md shadow-blue-500/20'
                      : 'bg-slate-900 text-slate-400 border-slate-700 hover:border-slate-500'
                  }`}
                >
                  {p}
                </button>
              ))}
            </div>
          </div>

          <div>
            <label className="block text-xs font-medium text-slate-400 mb-1.5">Detailed Description</label>
            <textarea
              rows={4}
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              className="w-full bg-slate-900 border border-slate-700 text-white text-sm rounded-2xl p-3 focus:outline-none focus:border-blue-500"
              placeholder="Provide complete context..."
            />
          </div>

          {/* Photo Upload Actions & Previews */}
          <div className="space-y-3">
            <label className="block text-xs font-medium text-slate-400">Photo Attachments</label>

            {/* Hidden File Input */}
            <input
              type="file"
              ref={fileInputRef}
              accept="image/*"
              className="hidden"
              onChange={handleFileUpload}
            />

            {/* Two Photo Action Buttons */}
            <div className="grid grid-cols-2 gap-3">
              <button
                type="button"
                onClick={handleTakePhoto}
                className="bg-slate-900 hover:bg-slate-800 border border-slate-700/80 hover:border-blue-500 text-white p-3.5 rounded-2xl flex items-center justify-center gap-2 text-xs font-semibold transition-all cursor-pointer group"
              >
                <Camera className="w-4 h-4 text-blue-400 group-hover:scale-110 transition-transform" />
                <span>Take Photo</span>
              </button>

              <button
                type="button"
                onClick={() => fileInputRef.current?.click()}
                className="bg-slate-900 hover:bg-slate-800 border border-slate-700/80 hover:border-blue-500 text-white p-3.5 rounded-2xl flex items-center justify-center gap-2 text-xs font-semibold transition-all cursor-pointer group"
              >
                <ImageIcon className="w-4 h-4 text-emerald-400 group-hover:scale-110 transition-transform" />
                <span>Choose From Gallery</span>
              </button>
            </div>

            {/* Uploaded Photos Preview Cards */}
            {photos.length > 0 && (
              <div className="pt-2">
                <p className="text-[11px] text-slate-400 mb-2 font-medium">
                  Uploaded Photos ({photos.length})
                </p>
                <div className="grid grid-cols-3 gap-2">
                  {photos.map((src, index) => (
                    <div
                      key={index}
                      className="relative rounded-2xl overflow-hidden border border-slate-700 bg-slate-900 aspect-square group shadow-md"
                    >
                      <img src={src} alt={`Preview ${index}`} className="w-full h-full object-cover" />
                      <button
                        type="button"
                        onClick={() => handleRemovePhoto(index)}
                        className="absolute top-1.5 right-1.5 w-6 h-6 rounded-full bg-red-600/90 hover:bg-red-600 text-white flex items-center justify-center shadow-lg transition-transform active:scale-90 cursor-pointer"
                        title="Remove photo"
                      >
                        <Trash2 className="w-3.5 h-3.5" />
                      </button>
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>
        </div>
      )}

      {/* Step 3: Review */}
      {step === 3 && (
        <div className="bg-[#1E293B] border border-slate-700/60 p-5 rounded-3xl space-y-4 shadow-sm">
          <h2 className="text-base font-bold text-white">Step 3: Review & Confirm</h2>

          <div className="divide-y divide-slate-700/60 text-sm space-y-3 pt-1">
            <div className="pt-2">
              <span className="text-xs text-slate-500">Title</span>
              <p className="font-semibold text-white">{title}</p>
            </div>

            <div className="pt-3 flex justify-between items-center">
              <span className="text-xs text-slate-500">Priority</span>
              <span className="text-xs font-bold bg-blue-500/20 text-blue-400 px-3 py-1 rounded-full uppercase">
                {priority} Priority
              </span>
            </div>

            <div className="pt-3 space-y-1">
              <span className="text-xs text-slate-500">Location Details</span>
              <p className="text-xs text-slate-300 font-medium">{building}</p>
              <p className="text-xs text-slate-400">{floor} • {space}</p>
              {asset && <p className="text-xs text-blue-400 font-semibold">Asset: {asset}</p>}
            </div>

            <div className="pt-3">
              <span className="text-xs text-slate-500">Description</span>
              <p className="text-xs text-slate-300 mt-1 leading-relaxed">{description}</p>
            </div>

            <div className="pt-3">
              <span className="text-xs text-slate-500">Attachments</span>
              <p className="text-xs text-white mt-0.5">{photos.length} Photo file(s) attached</p>
            </div>
          </div>
        </div>
      )}

      {/* Navigation Buttons */}
      <div className="flex gap-3">
        {step > 1 && (
          <button
            onClick={handleBack}
            className="flex-1 bg-[#1E293B] hover:bg-slate-800 border border-slate-700/60 text-slate-200 py-3.5 px-4 rounded-2xl font-semibold text-sm transition-all flex items-center justify-center gap-2 cursor-pointer"
          >
            <ArrowLeft className="w-4 h-4" />
            <span>Back</span>
          </button>
        )}
        <button
          onClick={handleNext}
          className="flex-1 primary-gradient text-white py-3.5 px-4 rounded-2xl font-semibold text-sm transition-all flex items-center justify-center gap-2 shadow-lg shadow-blue-600/30 active:scale-95 hover:opacity-95 cursor-pointer"
        >
          <span>{step === 3 ? 'Submit Issue' : 'Continue'}</span>
          {step === 3 ? <Check className="w-4 h-4" /> : <ArrowRight className="w-4 h-4" />}
        </button>
      </div>

      {/* Confirmation Modal */}
      {isSubmitted && (
        <div className="fixed inset-0 z-50 bg-black/75 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-[#1E293B] border border-slate-700 p-6 rounded-3xl max-w-xs w-full text-center space-y-4 shadow-2xl">
            <div className="w-14 h-14 rounded-full bg-green-500/15 text-green-400 mx-auto flex items-center justify-center">
              <CheckCircle2 className="w-8 h-8" />
            </div>
            <div>
              <h3 className="text-lg font-bold text-white">Submit Report?</h3>
              <p className="text-xs text-slate-400 mt-1">
                Your report will be assigned ticket ID <span className="text-blue-400 font-bold">ISS-0205</span> and sent to campus engineering.
              </p>
            </div>
            <div className="space-y-2 pt-2">
              <button
                onClick={handleConfirmSubmit}
                className="w-full primary-gradient text-white py-3 rounded-2xl font-semibold text-sm shadow-md cursor-pointer"
              >
                Confirm & Submit
              </button>
              <button
                onClick={() => setIsSubmitted(false)}
                className="w-full text-slate-400 hover:text-white py-2 text-xs font-medium cursor-pointer"
              >
                Review Again
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

