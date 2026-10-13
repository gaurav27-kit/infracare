import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/loading_skeleton.dart';
import '../../core/widgets/priority_chip.dart';
import '../../core/widgets/status_chip.dart';
import '../../models/attachment_model.dart';
import '../../models/issue_model.dart';
import '../../providers/attachment_provider.dart';
import '../../providers/issue_provider.dart';

/// Detailed view for a single infrastructure issue.
class IssueDetailsScreen extends ConsumerWidget {
  final String issueId;
  final VoidCallback? onBack;

  const IssueDetailsScreen({
    super.key,
    this.issueId = '',
    this.onBack,
  });

  int _calculateDoneCount(String status) {
    switch (status.toLowerCase()) {
      case 'open':
      case 'reported':
        return 1;
      case 'assigned':
        return 2;
      case 'in progress':
      case 'inprogress':
        return 3;
      case 'resolved':
        return 4;
      case 'closed':
        return 5;
      default:
        return 1;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final issueAsync = ref.watch(issueDetailProvider(issueId));
    final attachmentsAsync = ref.watch(issueAttachmentsProvider(issueId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (onBack != null) {
              onBack!();
            } else {
              Navigator.of(context).maybePop();
            }
          },
        ),
        title: Text(issueId.isEmpty ? 'Issue Details' : 'Issue #$issueId'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(issueDetailProvider(issueId).notifier).refresh();
              ref.read(issueAttachmentsProvider(issueId).notifier).refresh();
            },
          ),
        ],
      ),
      body: issueAsync.when(
        data: (issue) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status & priority header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatusChip(status: issue.status.isEmpty ? 'Open' : issue.status),
                  PriorityChip(priority: issue.priority.isEmpty ? 'Medium' : issue.priority),
                ],
              ),
              const SizedBox(height: 14),

              // Title & reporter meta
              Text(
                issue.title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Reported by ${issue.reportedBy.isEmpty ? 'Staff' : issue.reportedBy} • ${issue.reportedAt}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 20),

              // 5-step progress tracker
              _buildProgressTracker(_calculateDoneCount(issue.status)),
              const SizedBox(height: 24),

              // Location card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.location_on,
                              color: AppColors.primary, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Location Details',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: AppColors.cardBorder, height: 20),
                      _buildDetailGrid([
                        {'label': 'BUILDING', 'value': issue.building ?? '—'},
                        {'label': 'FLOOR', 'value': issue.floor ?? '—'},
                        {'label': 'SPACE', 'value': issue.space ?? '—'},
                        {
                          'label': 'ASSET',
                          'value': (issue.asset != null && issue.asset!.isNotEmpty)
                              ? issue.asset!
                              : ((issue.customAssetName != null && issue.customAssetName!.isNotEmpty)
                                  ? 'Other / Custom Asset'
                                  : 'None Specified'),
                        },
                        if (issue.customAssetName != null && issue.customAssetName!.isNotEmpty)
                          {'label': 'CUSTOM ASSET', 'value': issue.customAssetName!},
                      ]),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Description card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.description,
                              color: AppColors.primary, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Description',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        issue.description.isEmpty
                            ? 'No description provided.'
                            : issue.description,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Photo gallery card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.photo_library,
                              color: AppColors.primary, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Photo Gallery',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      attachmentsAsync.when(
                        data: (attachments) => _buildPhotoGallery(attachments, issue),
                        loading: () => const LoadingSkeleton(height: 100, borderRadius: 12),
                        error: (err, stack) => _buildPhotoGallery(const [], issue),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
        loading: () => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              LoadingSkeleton(height: 30, borderRadius: 8),
              SizedBox(height: 14),
              LoadingSkeleton(height: 40, borderRadius: 8),
              SizedBox(height: 20),
              LoadingSkeleton(height: 100, borderRadius: 16),
              SizedBox(height: 24),
              LoadingSkeleton(height: 140, borderRadius: 16),
              SizedBox(height: 16),
              LoadingSkeleton(height: 120, borderRadius: 16),
            ],
          ),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.danger,
                    size: 36,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Failed to Load Issue Details',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$error',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(issueDetailProvider(issueId).notifier).refresh();
                      ref.read(issueAttachmentsProvider(issueId).notifier).refresh();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(140, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoGallery(List<AttachmentModel> attachments, IssueModel issue) {
    final allAttachments = <AttachmentModel>[
      ...attachments,
      ...issue.attachments.where((a) => !attachments.any((x) => x.id == a.id)),
    ];

    if (allAttachments.isEmpty) {
      return Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library_outlined, color: AppColors.textMuted, size: 28),
            SizedBox(height: 6),
            Text(
              'No photos attached',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: allAttachments.length,
        itemBuilder: (context, index) {
          final att = allAttachments[index];
          final url = (att.uploadedUrl != null && att.uploadedUrl!.isNotEmpty)
              ? att.uploadedUrl!
              : att.localPath;
          final isHttp = url.startsWith('http');
          return Container(
            margin: const EdgeInsets.only(right: 10),
            width: 110,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder),
              image: isHttp
                  ? DecorationImage(
                      image: NetworkImage(url),
                      fit: BoxFit.cover,
                    )
                  : (att.bytes != null && att.bytes!.isNotEmpty)
                      ? DecorationImage(
                          image: MemoryImage(Uint8List.fromList(att.bytes!)),
                          fit: BoxFit.cover,
                        )
                      : null,
            ),
            child: (!isHttp && (att.bytes == null || att.bytes!.isEmpty))
                ? const Center(
                    child: Icon(Icons.image, color: AppColors.textMuted),
                  )
                : null,
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 5-step progress tracker
  // ---------------------------------------------------------------------------
  Widget _buildProgressTracker(int doneCount) {
    const steps = ['Reported', 'Assigned', 'In Progress', 'Resolved', 'Closed'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PROGRESS STATUS',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (int i = 0; i < steps.length; i++) ...[
                _buildProgressStep(steps[i], i < doneCount),
                if (i < steps.length - 1)
                  _buildProgressLine(i < doneCount - 1),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStep(String label, bool isDone) {
    return Column(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: isDone ? AppColors.primary : AppColors.surfaceVariant,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              isDone ? Icons.check : Icons.circle,
              size: 12,
              color: isDone ? Colors.white : AppColors.textMuted,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isDone ? AppColors.textPrimary : AppColors.textMuted,
            fontSize: 9,
            fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressLine(bool isDone) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 14),
        color: isDone ? AppColors.primary : AppColors.surfaceVariant,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Location detail grid
  // ---------------------------------------------------------------------------
  Widget _buildDetailGrid(List<Map<String, String>> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.2,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              item['label'] ?? '',
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              item['value'] ?? '',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }
}
