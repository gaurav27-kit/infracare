import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/image_picker_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_dialog.dart';
import '../../core/widgets/loading_skeleton.dart';
import '../../core/widgets/priority_chip.dart';
import '../../models/asset_model.dart';
import '../../models/building_model.dart';
import '../../models/floor_model.dart';
import '../../models/issue_model.dart';
import '../../models/space_model.dart';
import '../../providers/admin_provider.dart';
import '../../providers/attachment_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/issue_provider.dart';
import '../../providers/lookup_provider.dart';

/// Multi-step wizard for submitting a new infrastructure issue report.
class ReportIssueScreen extends ConsumerStatefulWidget {
  final VoidCallback? onSubmitSuccess;

  const ReportIssueScreen({super.key, this.onSubmitSuccess});

  @override
  ConsumerState<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends ConsumerState<ReportIssueScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _customAssetController = TextEditingController();
  static const List<String> _priorityOptions = ['Low', 'Medium', 'High', 'Critical'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _customAssetController.dispose();
    super.dispose();
  }

  void _onTitleChanged(String value) {
    ref.read(issueFormProvider.notifier).setTitle(value);
  }

  void _onDescriptionChanged(String value) {
    ref.read(issueFormProvider.notifier).setDescription(value);
  }

  Future<void> _pickImageFromGallery() async {
    final image = await ImagePickerService.instance.pickFromGallery();
    if (image != null) {
      await ref.read(attachmentProvider.notifier).addFile(image);
      ref.read(issueFormProvider.notifier).incrementPhotoCount();
    }
  }

  Future<void> _submitReport() async {
    final formState = ref.read(issueFormProvider);

    if (formState.title.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an issue title.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    if (formState.description.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a description for the issue.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    ref.read(issueFormProvider.notifier).setSubmitting(true);

    try {
      final currentAttachments = ref.read(attachmentProvider);
      final draft = IssueModel(
        id: '',
        title: formState.title.trim(),
        description: formState.description.trim(),
        location: [
          if (formState.building != null) formState.building,
          if (formState.floor != null) formState.floor,
          if (formState.space != null) formState.space,
        ].join(', '),
        status: 'Open',
        priority: formState.priority,
        reportedBy: 'Mobile App User',
        reportedAt: 'Just now',
        building: formState.building,
        buildingId: formState.buildingId,
        floor: formState.floor,
        floorId: formState.floorId,
        space: formState.space,
        spaceId: formState.spaceId,
        asset: formState.asset,
        assetId: formState.assetId,
        customAssetName: formState.isCustomAsset
            ? formState.customAssetName?.trim()
            : null,
        attachments: currentAttachments,
      );

      final createdIssue = await ref
          .read(myIssuesProvider.notifier)
          .submitIssue(draft);

      // Upload attachments if any were selected
      await ref
          .read(attachmentProvider.notifier)
          .uploadAttachmentsForIssue(createdIssue.id);

      // Refresh dashboards and issue detail providers
      ref.read(recentIssuesProvider.notifier).refresh();
      ref.read(dashboardStatsProvider.notifier).refresh();
      ref.read(adminIssuesProvider.notifier).fetchIssues();
      ref.invalidate(issueDetailProvider(createdIssue.id));
      ref.invalidate(issueAttachmentsProvider(createdIssue.id));

      ref.read(issueFormProvider.notifier).setSubmitting(false);

      if (mounted) {
        CustomDialog.show(
          context: context,
          title: 'Issue #${createdIssue.id.isNotEmpty ? createdIssue.id : 'Created'}',
          message:
              'Your report has been successfully dispatched to the facility team.',
          primaryButtonText: 'View Dashboard',
          icon: Icons.check_circle_rounded,
          iconColor: AppColors.success,
          onPrimaryPressed: () {
            ref.read(issueFormProvider.notifier).reset();
            ref.read(attachmentProvider.notifier).clear();
            _titleController.clear();
            _descriptionController.clear();
            _customAssetController.clear();
            widget.onSubmitSuccess?.call();
          },
        );
      }
    } catch (e) {
      ref.read(issueFormProvider.notifier).setSubmitting(false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit issue: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  void _showSubmitConfirmation() {
    CustomDialog.show(
      context: context,
      title: 'Submit Issue Report?',
      message:
          'Your report will be assigned a ticket ID and dispatched to the facility team.',
      primaryButtonText: 'Submit Report',
      secondaryButtonText: 'Review Again',
      icon: Icons.send_rounded,
      iconColor: AppColors.primary,
      onPrimaryPressed: _submitReport,
    );
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(issueFormProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Report New Issue')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepperHeader(formState.currentStep),
            const SizedBox(height: 24),
            if (formState.currentStep == 0) _buildStep1Location(formState),
            if (formState.currentStep == 1) _buildStep2Details(formState),
            if (formState.currentStep == 2) _buildStep3Review(formState),
            const SizedBox(height: 32),
            Row(
              children: [
                if (formState.currentStep > 0) ...[
                  Expanded(
                    child: CustomButton(
                      label: 'Back',
                      type: ButtonType.secondary,
                      onPressed: formState.isSubmitting
                          ? null
                          : () => ref.read(issueFormProvider.notifier).previousStep(),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: CustomButton(
                    label: formState.currentStep == 2
                        ? 'Submit Issue'
                        : 'Continue',
                    icon: formState.currentStep == 2
                        ? Icons.check
                        : Icons.arrow_forward,
                    isLoading: formState.isSubmitting,
                    onPressed: formState.isSubmitting
                        ? null
                        : () {
                            if (formState.currentStep == 0) {
                              if (formState.buildingId == null || formState.buildingId!.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please select a building.'),
                                    backgroundColor: AppColors.warning,
                                  ),
                                );
                                return;
                              }
                              if (formState.floorId == null || formState.floorId!.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please select a floor.'),
                                    backgroundColor: AppColors.warning,
                                  ),
                                );
                                return;
                              }
                              if (formState.spaceId == null || formState.spaceId!.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please select a space/room.'),
                                    backgroundColor: AppColors.warning,
                                  ),
                                );
                                return;
                              }
                              if (formState.isCustomAsset &&
                                  (formState.customAssetName == null ||
                                      formState.customAssetName!.trim().isEmpty)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please enter a custom asset name.'),
                                    backgroundColor: AppColors.warning,
                                  ),
                                );
                                return;
                              }
                              ref.read(issueFormProvider.notifier).nextStep();
                            } else if (formState.currentStep == 1) {
                              if (formState.title.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please enter an issue title.'),
                                    backgroundColor: AppColors.warning,
                                  ),
                                );
                                return;
                              }
                              if (formState.description.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please enter a description for the issue.'),
                                    backgroundColor: AppColors.warning,
                                  ),
                                );
                                return;
                              }
                              ref.read(issueFormProvider.notifier).nextStep();
                            } else {
                              _showSubmitConfirmation();
                            }
                          },
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

  Widget _buildStepperHeader(int currentStep) {
    return Row(
      children: [
        _buildStepCircle(0, 'Location', currentStep),
        _buildStepLine(0, currentStep),
        _buildStepCircle(1, 'Details', currentStep),
        _buildStepLine(1, currentStep),
        _buildStepCircle(2, 'Review', currentStep),
      ],
    );
  }

  Widget _buildStepCircle(int step, String label, int currentStep) {
    final isActive = currentStep == step;
    final isDone = currentStep > step;
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
                        color: isActive || isDone
                            ? Colors.white
                            : AppColors.textMuted,
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
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
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

  Widget _buildStepLine(int afterStep, int currentStep) {
    final isDone = currentStep > afterStep;
    return Container(
      width: 30,
      height: 2,
      color: isDone ? AppColors.success : AppColors.surfaceVariant,
    );
  }

  // ---------------------------------------------------------------------------
  // Step 1: Location
  // ---------------------------------------------------------------------------
  Widget _buildStep1Location(IssueFormState formState) {
    final buildingsAsync = ref.watch(buildingsProvider);
    final floorsAsync = ref.watch(floorsProvider(formState.buildingId ?? ''));
    final spacesAsync = ref.watch(spacesProvider(formState.floorId ?? ''));
    final assetsAsync = ref.watch(assetsProvider(formState.spaceId ?? ''));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Step 1: Select Location',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Specify where the infrastructure fault is located.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),

            // Building Dropdown
            buildingsAsync.when(
              data: (buildings) {
                if (buildings.isNotEmpty && formState.buildingId == null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted && ref.read(issueFormProvider).buildingId == null) {
                      ref.read(issueFormProvider.notifier).setBuilding(
                            buildings.first.name,
                            buildings.first.id,
                          );
                    }
                  });
                }
                return _buildTypedDropdown<BuildingModel>(
                  label: 'Building',
                  valueId: formState.buildingId,
                  items: buildings,
                  getId: (b) => b.id,
                  getName: (b) => b.name,
                  hint: 'Select building...',
                  onChanged: (item) {
                    ref.read(issueFormProvider.notifier).setBuilding(item?.name, item?.id);
                  },
                );
              },
              loading: () => const LoadingSkeleton(height: 50, borderRadius: 12),
              error: (err, stack) => _buildTypedDropdown<BuildingModel>(
                label: 'Building',
                valueId: null,
                items: const [],
                getId: (b) => b.id,
                getName: (b) => b.name,
                hint: 'Failed to load buildings',
                onChanged: (_) {},
              ),
            ),
            const SizedBox(height: 16),

            // Floor Dropdown
            floorsAsync.when(
              data: (floors) => _buildTypedDropdown<FloorModel>(
                label: 'Floor',
                valueId: formState.floorId,
                items: floors,
                getId: (f) => f.id,
                getName: (f) => f.name,
                hint: formState.buildingId == null ? 'Select building first' : 'Select floor...',
                onChanged: (item) {
                  ref.read(issueFormProvider.notifier).setFloor(item?.name, item?.id);
                },
              ),
              loading: () => const LoadingSkeleton(height: 50, borderRadius: 12),
              error: (err, stack) => _buildTypedDropdown<FloorModel>(
                label: 'Floor',
                valueId: null,
                items: const [],
                getId: (f) => f.id,
                getName: (f) => f.name,
                hint: 'Select building first',
                onChanged: (_) {},
              ),
            ),
            const SizedBox(height: 16),

            // Space Dropdown
            spacesAsync.when(
              data: (spaces) => _buildTypedDropdown<SpaceModel>(
                label: 'Space / Room',
                valueId: formState.spaceId,
                items: spaces,
                getId: (s) => s.id,
                getName: (s) => s.name,
                hint: formState.floorId == null ? 'Select floor first' : 'Select space...',
                onChanged: (item) {
                  ref.read(issueFormProvider.notifier).setSpace(item?.name, item?.id);
                },
              ),
              loading: () => const LoadingSkeleton(height: 50, borderRadius: 12),
              error: (err, stack) => _buildTypedDropdown<SpaceModel>(
                label: 'Space / Room',
                valueId: null,
                items: const [],
                getId: (s) => s.id,
                getName: (s) => s.name,
                hint: 'Select floor first',
                onChanged: (_) {},
              ),
            ),
            const SizedBox(height: 16),

            // Asset Dropdown
            assetsAsync.when(
              data: (assets) => _buildTypedDropdown<AssetModel>(
                label: 'Asset (Optional)',
                valueId: formState.assetId,
                items: assets,
                getId: (a) => a.id,
                getName: (a) => a.name,
                hint: formState.spaceId == null ? 'Select space first' : 'Select asset (optional)...',
                onChanged: (item) {
                  ref.read(issueFormProvider.notifier).setAsset(item?.name, item?.id);
                  if (item?.name != 'Other / Custom Asset') {
                    _customAssetController.clear();
                  }
                },
              ),
              loading: () => const LoadingSkeleton(height: 50, borderRadius: 12),
              error: (err, stack) => _buildTypedDropdown<AssetModel>(
                label: 'Asset (Optional)',
                valueId: formState.assetId,
                items: ref.read(masterDataRepositoryProvider).getAssetsLocal(spaceId: ''),
                getId: (a) => a.id,
                getName: (a) => a.name,
                hint: formState.spaceId == null ? 'Select space first' : 'Select asset (optional)...',
                onChanged: (item) {
                  ref.read(issueFormProvider.notifier).setAsset(item?.name, item?.id);
                  if (item?.name != 'Other / Custom Asset') {
                    _customAssetController.clear();
                  }
                },
              ),
            ),

            // Custom Asset Name Field (only shown when 'Other / Custom Asset' is selected)
            if (formState.isCustomAsset) ...[
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Custom Asset Name',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _customAssetController,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Enter asset name...',
                      hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
                      fillColor: AppColors.background,
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    onChanged: (value) {
                      ref.read(issueFormProvider.notifier).setCustomAssetName(value);
                    },
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTypedDropdown<T>({
    required String label,
    required String? valueId,
    required List<T> items,
    required String Function(T) getId,
    required String Function(T) getName,
    required ValueChanged<T?> onChanged,
    String hint = 'Select...',
  }) {
    T? selectedItem;
    if (valueId != null) {
      for (final item in items) {
        if (getId(item) == valueId) {
          selectedItem = item;
          break;
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          key: ValueKey('$label-$valueId'),
          initialValue: items.any((item) => getId(item) == valueId) ? selectedItem : null,
          dropdownColor: AppColors.surface,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
          hint: Text(hint, style: const TextStyle(color: AppColors.textMuted, fontSize: 14)),
          decoration: const InputDecoration(
            fillColor: AppColors.background,
            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          items: items
              .map((item) => DropdownMenuItem<T>(
                    value: item,
                    child: Text(getName(item), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ))
              .toList(),
          onChanged: items.isEmpty ? null : onChanged,
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Step 2: Details
  // ---------------------------------------------------------------------------
  Widget _buildStep2Details(IssueFormState formState) {
    final attachments = ref.watch(attachmentProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Step 2: Issue Details',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Describe the problem and attach photos.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),

            // Title
            const Text(
              'Issue Title',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              onChanged: _onTitleChanged,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Brief summary (e.g. Broken AC in Room 204)',
              ),
            ),
            const SizedBox(height: 16),

            // Priority
            const Text(
              'Priority Level',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: _priorityOptions.map((priority) {
                final isSelected = formState.priority == priority;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: InkWell(
                      onTap: () => ref
                          .read(issueFormProvider.notifier)
                          .setPriority(priority),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.cardBorder,
                          ),
                        ),
                        child: Text(
                          priority,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
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

            // Description
            const Text(
              'Detailed Description',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _descriptionController,
              onChanged: _onDescriptionChanged,
              maxLines: 4,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Provide complete details regarding the fault...',
              ),
            ),
            const SizedBox(height: 20),

            // Photo attachment
            const Text(
              'Photo Attachments',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickImageFromGallery,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceVariant,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.cloud_upload_outlined,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Tap to upload photo from gallery',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'JPG or PNG image',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                    if (attachments.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        '${attachments.length} photo(s) selected',
                        style: const TextStyle(
                          color: AppColors.success,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (attachments.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 84,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: attachments.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, idx) {
                    final item = attachments[idx];
                    return Stack(
                      children: [
                        Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: item.bytes != null
                              ? Image.memory(
                                  Uint8List.fromList(item.bytes!),
                                  fit: BoxFit.cover,
                                )
                              : const Center(
                                  child: Icon(Icons.photo, color: AppColors.primary),
                                ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              ref.read(attachmentProvider.notifier).removeFile(item.id);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Step 3: Review
  // ---------------------------------------------------------------------------
  Widget _buildStep3Review(IssueFormState formState) {
    final attachments = ref.watch(attachmentProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Step 3: Review & Confirm',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Please verify all information before sending the ticket.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            _buildReviewRow(
              'Title',
              formState.title.isEmpty ? '(not filled)' : formState.title,
            ),
            const Divider(color: AppColors.cardBorder, height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Priority',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
                PriorityChip(priority: formState.priority),
              ],
            ),
            const Divider(color: AppColors.cardBorder, height: 24),
            _buildReviewRow('Building', formState.building ?? '—'),
            const SizedBox(height: 8),
            _buildReviewRow('Floor', formState.floor ?? '—'),
            const SizedBox(height: 8),
            _buildReviewRow('Space', formState.space ?? '—'),
            const SizedBox(height: 8),
            _buildReviewRow('Asset', formState.asset ?? 'None Specified'),
            if (formState.isCustomAsset &&
                formState.customAssetName != null &&
                formState.customAssetName!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildReviewRow('Custom Asset', formState.customAssetName!.trim()),
            ],
            const Divider(color: AppColors.cardBorder, height: 24),
            _buildReviewRow(
              'Description',
              formState.description.isEmpty
                  ? '(not filled)'
                  : formState.description,
            ),
            const SizedBox(height: 8),
            _buildReviewRow(
              'Attached Files',
              attachments.isEmpty
                  ? 'No files attached'
                  : '${attachments.length} photo(s) attached',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
