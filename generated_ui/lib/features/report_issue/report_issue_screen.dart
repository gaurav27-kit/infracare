import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_dialog.dart';
import '../../widgets/priority_chip.dart';

class ReportIssueScreen extends StatefulWidget {
  final VoidCallback? onSubmitSuccess;

  const ReportIssueScreen({Key? key, this.onSubmitSuccess}) : super(key: key);

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  int _currentStep = 0;

  // Step 1 - Location Data
  String? _selectedCampus = AppConstants.campuses[0];
  String? _selectedBuilding = AppConstants.buildings[0];
  String? _selectedFloor = AppConstants.floors[1];
  String? _selectedSpace = AppConstants.spaces[0];
  String? _selectedAsset = AppConstants.assets[0];

  // Step 2 - Details Data
  final TextEditingController _titleController = TextEditingController(text: 'Water Leakage in Utility Room');
  final TextEditingController _descriptionController = TextEditingController(
    text: 'Significant water pooling observed near Chiller Unit C-02 in Utility Room. Requires urgent maintenance inspection.',
  );
  String _selectedPriority = 'High';
  final List<String> _attachedPhotos = ['photo_1.jpg'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    } else {
      _showSubmitConfirmation();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _showSubmitConfirmation() {
    CustomDialog.show(
      context: context,
      title: 'Submit Issue Report?',
      message: 'Your report will be assigned ticket ID #IC-205 and dispatched to the facility team.',
      primaryButtonText: 'Submit Report',
      secondaryButtonText: 'Review Again',
      icon: Icons.send_rounded,
      iconColor: AppColors.primary,
      onPrimaryPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Issue #IC-205 reported successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        if (widget.onSubmitSuccess != null) {
          widget.onSubmitSuccess!();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Report New Issue'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Wizard Stepper Indicator
            _buildStepperHeader(),
            const SizedBox(height: 24),

            // Step Content
            if (_currentStep == 0) _buildStep1Location(),
            if (_currentStep == 1) _buildStep2Details(),
            if (_currentStep == 2) _buildStep3Review(),

            const SizedBox(height: 32),

            // Navigation Action Buttons
            Row(
              children: [
                if (_currentStep > 0) ...[
                  Expanded(
                    child: CustomButton(
                      label: 'Back',
                      type: ButtonType.secondary,
                      onPressed: _previousStep,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: CustomButton(
                    label: _currentStep == 2 ? 'Submit Issue' : 'Continue',
                    icon: _currentStep == 2 ? Icons.check : Icons.arrow_forward,
                    onPressed: _nextStep,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStepperHeader() {
    return Row(
      children: [
        _buildStepCircle(0, 'Location'),
        _buildStepLine(0),
        _buildStepCircle(1, 'Details'),
        _buildStepLine(1),
        _buildStepCircle(2, 'Review'),
      ],
    );
  }

  Widget _buildStepCircle(int step, String label) {
    final isActive = _currentStep == step;
    final isDone = _currentStep > step;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: isDone
                  ? AppColors.success
                  : isActive
                      ? AppColors.primary
                      : AppColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isDone
                  ? const Icon(Icons.check, size: 18, color: Colors.white)
                  : Text(
                      '${step + 1}',
                      style: TextStyle(
                        color: isActive || isDone ? Colors.white : AppColors.textMuted,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive
                  ? AppColors.primary
                  : isDone
                      ? AppColors.success
                      : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine(int afterStep) {
    final isDone = _currentStep > afterStep;
    return Container(
      width: 30,
      height: 2,
      color: isDone ? AppColors.success : AppColors.surfaceVariant,
    );
  }

  // Step 1: Location Form
  Widget _buildStep1Location() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Step 1: Select Location',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Specify where the infrastructure fault is located.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),

            _buildDropdownField('Campus', _selectedCampus, AppConstants.campuses, (val) => setState(() => _selectedCampus = val)),
            const SizedBox(height: 16),
            _buildDropdownField('Building', _selectedBuilding, AppConstants.buildings, (val) => setState(() => _selectedBuilding = val)),
            const SizedBox(height: 16),
            _buildDropdownField('Floor', _selectedFloor, AppConstants.floors, (val) => setState(() => _selectedFloor = val)),
            const SizedBox(height: 16),
            _buildDropdownField('Space / Room', _selectedSpace, AppConstants.spaces, (val) => setState(() => _selectedSpace = val)),
            const SizedBox(height: 16),
            _buildDropdownField('Asset (Optional)', _selectedAsset, AppConstants.assets, (val) => setState(() => _selectedAsset = val)),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, String? selectedValue, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: selectedValue,
          dropdownColor: AppColors.surface,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
          decoration: InputDecoration(
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item, maxLines: 1, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  // Step 2: Issue Details Form
  Widget _buildStep2Details() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Step 2: Issue Details',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Describe the problem and attach photos.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),

            // Issue Title Input
            const Text('Issue Title', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Brief summary (e.g. Broken AC in Library)',
              ),
            ),
            const SizedBox(height: 16),

            // Priority Selection Chips
            const Text('Priority Level', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Row(
              children: AppConstants.priorityLevels.map((priority) {
                final isSelected = _selectedPriority == priority;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: InkWell(
                      onTap: () => setState(() => _selectedPriority = priority),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.cardBorder,
                          ),
                        ),
                        child: Text(
                          priority,
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Description Input
            const Text('Detailed Description', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Provide complete details regarding the fault...',
              ),
            ),
            const SizedBox(height: 20),

            // Photo Upload Placeholder Area
            const Text('Photo / Video Attachments', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder, style: BorderStyle.solid),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.cloud_upload_outlined, color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(height: 10),
                  const Text('Tap to upload photo or drag file here', style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  const Text('JPG, PNG, or MP4 up to 10MB', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primary),
                        ),
                        child: const Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(Icons.image, color: AppColors.primary, size: 24),
                            Positioned(
                              top: 2,
                              right: 2,
                              child: Icon(Icons.check_circle, color: AppColors.success, size: 14),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _attachedPhotos.add('photo_${_attachedPhotos.length + 1}.jpg');
                          });
                        },
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: const Icon(Icons.add_a_photo_outlined, color: AppColors.textSecondary, size: 22),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Step 3: Review & Submit
  Widget _buildStep3Review() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Step 3: Review & Confirm',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Please verify all information before sending the ticket.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),

            _buildReviewRow('Title', _titleController.text),
            const Divider(color: AppColors.cardBorder, height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Priority', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                PriorityChip(priority: _selectedPriority),
              ],
            ),
            const Divider(color: AppColors.cardBorder, height: 24),
            _buildReviewRow('Campus', _selectedCampus ?? '-'),
            const SizedBox(height: 8),
            _buildReviewRow('Building', _selectedBuilding ?? '-'),
            const SizedBox(height: 8),
            _buildReviewRow('Floor', _selectedFloor ?? '-'),
            const SizedBox(height: 8),
            _buildReviewRow('Space', _selectedSpace ?? '-'),
            const SizedBox(height: 8),
            _buildReviewRow('Asset', _selectedAsset ?? 'None Specified'),
            const Divider(color: AppColors.cardBorder, height: 24),
            _buildReviewRow('Description', _descriptionController.text),
            const SizedBox(height: 12),
            _buildReviewRow('Attached Files', '${_attachedPhotos.length} photo(s) attached'),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
