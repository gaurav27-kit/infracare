import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/attachment_model.dart';
import '../../../models/issue_model.dart';
import '../../../providers/admin_provider.dart';
import '../../../providers/attachment_provider.dart';
import '../../../providers/issue_provider.dart';

/// Admin Issue Details Screen matching Stitch Design.
class AdminIssueDetailsScreen extends ConsumerStatefulWidget {
  final String issueId;
  final VoidCallback? onBack;

  const AdminIssueDetailsScreen({
    super.key,
    required this.issueId,
    this.onBack,
  });

  @override
  ConsumerState<AdminIssueDetailsScreen> createState() =>
      _AdminIssueDetailsScreenState();
}

class _AdminIssueDetailsScreenState
    extends ConsumerState<AdminIssueDetailsScreen> {
  bool _isUpdating = false;

  static const List<Map<String, String>> _statusSteps = [
    {'key': 'OPEN', 'label': 'REPORTED'},
    {'key': 'ASSIGNED', 'label': 'ASSIGNED'},
    {'key': 'IN_PROGRESS', 'label': 'IN PROGRESS'},
    {'key': 'RESOLVED', 'label': 'RESOLVED'},
    {'key': 'CLOSED', 'label': 'CLOSED'},
  ];

  int _getStatusIndex(String status) {
    final s = status.toUpperCase().replaceAll(' ', '_');
    if (s == 'REPORTED' || s == 'OPEN') return 0;
    if (s == 'ASSIGNED') return 1;
    if (s == 'IN_PROGRESS') return 2;
    if (s == 'RESOLVED') return 3;
    if (s == 'CLOSED') return 4;
    return 0;
  }

  String _inferCategory(IssueModel issue) {
    final text = '${issue.asset ?? ''} ${issue.title} ${issue.description}'.toLowerCase();
    if (text.contains('electric') || text.contains('light') || text.contains('power') || text.contains('projector')) {
      return 'Electrical';
    } else if (text.contains('ac') || text.contains('air') || text.contains('hvac') || text.contains('cool')) {
      return 'HVAC';
    } else if (text.contains('water') || text.contains('pipe') || text.contains('leak') || text.contains('restroom')) {
      return 'Plumbing';
    } else if (text.contains('door') || text.contains('window') || text.contains('wall') || text.contains('elevator')) {
      return 'Structural';
    }
    return 'General Infrastructure';
  }

  void _showUpdateStatusSheet(BuildContext context, IssueModel issue) {
    final currentStatusUpper =
        issue.status.toUpperCase().replaceAll(' ', '_');

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Update Issue Status',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textMuted),
                      onPressed: () => Navigator.pop(bottomSheetContext),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Select the new status for ${issue.id}. Changes will be updated on the server.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),

                // Status Options
                ..._statusSteps.map((step) {
                  final statusKey = step['key']!;
                  final statusLabel = step['label']!;
                  final isSelected = currentStatusUpper == statusKey;

                  Color dotColor = AppColors.primaryLight;
                  if (statusKey == 'OPEN') dotColor = AppColors.warning;
                  if (statusKey == 'ASSIGNED') dotColor = AppColors.primaryLight;
                  if (statusKey == 'IN_PROGRESS') dotColor = const Color(0xFF60A5FA);
                  if (statusKey == 'RESOLVED') dotColor = AppColors.success;
                  if (statusKey == 'CLOSED') dotColor = AppColors.textMuted;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : AppColors.surfaceVariant.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryLight
                            : AppColors.cardBorder,
                      ),
                    ),
                    child: ListTile(
                      dense: true,
                      leading: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: dotColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      title: Text(
                        statusLabel,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.primaryLight
                              : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.primaryLight,
                              size: 20,
                            )
                          : null,
                      onTap: () async {
                        Navigator.pop(bottomSheetContext);
                        if (statusKey == currentStatusUpper) return;

                        setState(() => _isUpdating = true);
                        final success = await ref
                            .read(adminIssuesProvider.notifier)
                            .updateIssueStatus(issue.id, statusKey);
                        setState(() => _isUpdating = false);

                        if (context.mounted) {
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Status updated to $statusLabel successfully.'),
                                backgroundColor: AppColors.success,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to update status. Please try again.'),
                                backgroundColor: AppColors.danger,
                              ),
                            );
                          }
                        }
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final issueAsync = ref.watch(issueDetailProvider(widget.issueId));
    final attachmentsAsync = ref.watch(issueAttachmentsProvider(widget.issueId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryLight),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(
          'Issue Details',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryLight,
          ),
        ),
      ),
      body: issueAsync.when(
        data: (issue) => _buildDetailContent(issue, attachmentsAsync),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryLight),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
                const SizedBox(height: 16),
                Text(
                  'Failed to load issue details',
                  style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  '$error',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => ref.invalidate(issueDetailProvider(widget.issueId)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: issueAsync.hasValue
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: const Border(top: BorderSide(color: AppColors.cardBorder)),
              ),
              child: SafeArea(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _isUpdating
                        ? null
                        : () => _showUpdateStatusSheet(context, issueAsync.value!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 2,
                    ),
                    icon: _isUpdating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.update_rounded, size: 20),
                    label: Text(
                      _isUpdating ? 'Updating Status...' : 'Update Status',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildDetailContent(IssueModel issue, AsyncValue<List<AttachmentModel>> attachmentsAsync) {
    final isCritical = issue.priority.toUpperCase() == 'CRITICAL';
    final isHigh = issue.priority.toUpperCase() == 'HIGH';
    final category = _inferCategory(issue);
    final statusIndex = _getStatusIndex(issue.status);

    // Merge API-fetched attachments with any embedded in the issue model
    final fetchedAttachments = attachmentsAsync.valueOrNull ?? const [];
    final allAttachments = <AttachmentModel>[
      ...fetchedAttachments,
      ...issue.attachments.where(
        (a) => !fetchedAttachments.any((f) => f.id == a.id),
      ),
    ];

    Color priorityColor = AppColors.primaryLight;
    if (isCritical) {
      priorityColor = AppColors.danger;
    } else if (isHigh) {
      priorityColor = const Color(0xFFF97316);
    } else if (issue.priority.toUpperCase() == 'MEDIUM') {
      priorityColor = AppColors.warning;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card with Issue Number & Priority
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Text(
                        issue.id,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: priorityColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: priorityColor.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning_amber_rounded, size: 14, color: priorityColor),
                          const SizedBox(width: 4),
                          Text(
                            '${issue.priority.toUpperCase()} PRIORITY',
                            style: TextStyle(
                              color: priorityColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Issue Title
                Text(
                  issue.title,
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 16),

                // Location Hierarchy: Building, Floor, Space / Room, Asset
                _buildInfoTile(
                  icon: Icons.business_outlined,
                  label: 'BUILDING',
                  value: issue.building ?? 'AIML Building',
                ),
                const SizedBox(height: 10),
                _buildInfoTile(
                  icon: Icons.layers_outlined,
                  label: 'FLOOR',
                  value: issue.floor ?? '—',
                ),
                const SizedBox(height: 10),
                _buildInfoTile(
                  icon: Icons.meeting_room_outlined,
                  label: 'SPACE / ROOM',
                  value: issue.space ?? '—',
                ),
                const SizedBox(height: 10),
                _buildInfoTile(
                  icon: Icons.precision_manufacturing_outlined,
                  label: 'ASSET',
                  value: (issue.asset != null && issue.asset!.isNotEmpty)
                      ? issue.asset!
                      : ((issue.customAssetName != null && issue.customAssetName!.isNotEmpty)
                          ? 'Other / Custom Asset'
                          : 'None Specified'),
                ),
                if (issue.customAssetName != null && issue.customAssetName!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _buildInfoTile(
                    icon: Icons.build_circle_outlined,
                    label: 'CUSTOM ASSET',
                    value: issue.customAssetName!,
                  ),
                ],
                const SizedBox(height: 10),
                _buildInfoTile(
                  icon: Icons.person_outline_rounded,
                  label: 'REPORTER',
                  value: issue.reportedBy.isNotEmpty ? issue.reportedBy : 'AIML User',
                ),
                const SizedBox(height: 10),
                _buildInfoTile(
                  icon: Icons.build_outlined,
                  label: 'CATEGORY',
                  value: category,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Description Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.description_outlined,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Description',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Text(
                    issue.description.isNotEmpty
                        ? issue.description
                        : 'No description provided.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Attached Visuals Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.image_outlined,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Attached Visuals',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Loading shimmer while fetching
                if (attachmentsAsync.isLoading)
                  SizedBox(
                    height: 140,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 2,
                      itemBuilder: (_, _) => Container(
                        width: 180,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryLight,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    ),
                  )
                else if (allAttachments.isNotEmpty)
                  SizedBox(
                    height: 140,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: allAttachments.length,
                      separatorBuilder: (_, i) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final att = allAttachments[index];
                        final url = (att.uploadedUrl != null && att.uploadedUrl!.isNotEmpty)
                            ? att.uploadedUrl!
                            : att.localPath;
                        final isHttp = url.startsWith('http');
                        return GestureDetector(
                          onTap: () => _showFullScreenImage(context, url, bytes: att.bytes),
                          child: Container(
                            width: 180,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                if (isHttp)
                                  Image.network(
                                    url,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (_, child, progress) {
                                      if (progress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: progress.expectedTotalBytes != null
                                              ? progress.cumulativeBytesLoaded /
                                                  progress.expectedTotalBytes!
                                              : null,
                                          color: AppColors.primaryLight,
                                          strokeWidth: 2,
                                        ),
                                      );
                                    },
                                    errorBuilder: (_, err, trace) => const Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.broken_image_rounded,
                                              color: AppColors.textMuted, size: 28),
                                          SizedBox(height: 4),
                                          Text('Failed to load',
                                              style: TextStyle(
                                                  color: AppColors.textMuted, fontSize: 10)),
                                        ],
                                      ),
                                    ),
                                  )
                                else if (att.bytes != null && att.bytes!.isNotEmpty)
                                  Image.memory(
                                    Uint8List.fromList(att.bytes!),
                                    fit: BoxFit.cover,
                                  )
                                else
                                  const Center(
                                    child: Icon(Icons.image,
                                        color: AppColors.textMuted, size: 32),
                                  ),
                                // Expand icon overlay
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Icon(
                                      Icons.open_in_full_rounded,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    height: 110,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.photo_library_outlined,
                            size: 28,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'No photo attachments provided',
                            style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Status Timeline Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.timeline_rounded,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Status Timeline',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Vertical Timeline Flow: Reported -> Assigned -> In Progress -> Resolved -> Closed
                ...List.generate(_statusSteps.length, (idx) {
                  final step = _statusSteps[idx];
                  final isDone = idx < statusIndex;
                  final isCurrent = idx == statusIndex;
                  final isLast = idx == _statusSteps.length - 1;

                  Color dotColor = AppColors.textMuted;
                  if (isDone) dotColor = AppColors.success;
                  if (isCurrent) dotColor = AppColors.primaryLight;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Node & Connector Line
                      Column(
                        children: [
                          Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: isDone || isCurrent
                                  ? dotColor
                                  : AppColors.surfaceVariant,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isCurrent
                                    ? Colors.white
                                    : AppColors.cardBorder,
                                width: 2,
                              ),
                            ),
                            child: isDone
                                ? const Icon(
                                    Icons.check,
                                    size: 11,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          if (!isLast)
                            Container(
                              width: 2,
                              height: 36,
                              color: isDone
                                  ? AppColors.success
                                  : AppColors.cardBorder,
                            ),
                        ],
                      ),
                      const SizedBox(width: 14),

                      // Label & Description
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 1),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                step['label']!,
                                style: TextStyle(
                                  color: isCurrent
                                      ? AppColors.primaryLight
                                      : isDone
                                          ? AppColors.success
                                          : AppColors.textMuted,
                                  fontWeight: isCurrent || isDone
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 13,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              if (isCurrent)
                                Text(
                                  'Current status',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primaryLight, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String url, {List<int>? bytes}) {
    final isHttp = url.startsWith('http');
    final hasBytes = bytes != null && bytes.isNotEmpty;
    if (!isHttp && !hasBytes) return;

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: isHttp
                    ? Image.network(
                        url,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const Center(
                          child: Icon(Icons.broken_image_rounded,
                              color: Colors.white54, size: 64),
                        ),
                      )
                    : Image.memory(
                        Uint8List.fromList(bytes!),
                        fit: BoxFit.contain,
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
