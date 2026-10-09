import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/priority_chip.dart';
import '../../widgets/custom_button.dart';

class IssueDetailsScreen extends StatelessWidget {
  final String issueId;
  final VoidCallback? onBack;

  const IssueDetailsScreen({
    Key? key,
    this.issueId = '#IC-204',
    this.onBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        title: Text('Issue $issueId'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Status & Priority Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StatusChip(status: 'In Progress'),
                PriorityChip(priority: 'High'),
              ],
            ),
            const SizedBox(height: 14),

            // Title & Meta Info
            const Text(
              'Broken AC Unit in Library 2nd Floor',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Reported by Sarah Jenkins • Oct 24, 14:30 PM',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),

            // Progress Tracker Stepper
            _buildProgressTracker(),
            const SizedBox(height: 24),

            // Location Information Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.location_on, color: AppColors.primary, size: 20),
                        SizedBox(width: 8),
                        Text('Location Details', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(color: AppColors.cardBorder, height: 20),
                    _buildDetailGrid([
                      {'label': 'BUILDING', 'value': 'Main Library Block A'},
                      {'label': 'FLOOR', 'value': '2nd Floor (HVAC Sector)'},
                      {'label': 'SPACE', 'value': 'Utility Room 304-B'},
                      {'label': 'ASSET', 'value': 'Chiller Unit C-02'},
                    ]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Description Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Row(
                      children: [
                        Icon(Icons.description, color: AppColors.primary, size: 20),
                        SizedBox(width: 8),
                        Text('Description', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Significant water pooling observed around the base of Chiller Unit C-02 in Utility Room 304-B. The secondary containment tray appears to have overflowed. Pressure readings on the primary condenser line are fluctuating wildly, dropping below nominal operational limits. Immediate inspection required to prevent structural water damage to the floor below.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Photo Gallery Placeholder Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.photo_library, color: AppColors.primary, size: 20),
                        SizedBox(width: 8),
                        Text('Photo Gallery (2)', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 110,
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.ac_unit, color: AppColors.primary, size: 32),
                                SizedBox(height: 6),
                                Text('Chiller Leak.jpg', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            height: 110,
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.speed, color: AppColors.warning, size: 32),
                                SizedBox(height: 6),
                                Text('Gauge Reading.png', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Issue Timeline Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.history, color: AppColors.primary, size: 20),
                        SizedBox(width: 8),
                        Text('Audit Timeline', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTimelineItem(
                      title: 'Technician Dispatched',
                      subtitle: 'Marcus Chen assigned and en route to site',
                      time: 'Oct 24, 15:10',
                      isFirst: true,
                      isLast: false,
                      isDone: true,
                    ),
                    _buildTimelineItem(
                      title: 'Ticket Verified & Prioritized',
                      subtitle: 'Facility manager updated priority to High',
                      time: 'Oct 24, 14:45',
                      isFirst: false,
                      isLast: false,
                      isDone: true,
                    ),
                    _buildTimelineItem(
                      title: 'Report Submitted',
                      subtitle: 'Ticket created via InfraCare App',
                      time: 'Oct 24, 14:30',
                      isFirst: false,
                      isLast: true,
                      isDone: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Track Progress Action Button
            CustomButton(
              label: 'Track Dispatch Location',
              icon: Icons.map_outlined,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Technician Marcus Chen is currently at Building Block A.'),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressTracker() {
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
          const Text('Progress Status', style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildProgressStep('Reported', true),
              _buildProgressLine(true),
              _buildProgressStep('Assigned', true),
              _buildProgressLine(true),
              _buildProgressStep('In Repair', true),
              _buildProgressLine(false),
              _buildProgressStep('Resolved', false),
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
            fontSize: 10,
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
            Text(item['label']!, style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(item['value']!, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        );
      },
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String subtitle,
    required String time,
    required bool isFirst,
    required bool isLast,
    required bool isDone,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: isDone ? AppColors.primary : AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: AppColors.cardBorder,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                  Text(time, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                ],
              ),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}
