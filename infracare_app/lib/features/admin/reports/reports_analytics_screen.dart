import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/admin_provider.dart';

/// Reports & Analytics Screen matching Stitch Design.
class ReportsAnalyticsScreen extends ConsumerStatefulWidget {
  final Function(int)? onNavigateToTab;

  const ReportsAnalyticsScreen({
    super.key,
    this.onNavigateToTab,
  });

  @override
  ConsumerState<ReportsAnalyticsScreen> createState() =>
      _ReportsAnalyticsScreenState();
}

class _ReportsAnalyticsScreenState extends ConsumerState<ReportsAnalyticsScreen> {
  String _selectedRange = 'Last 7 Days';

  @override
  Widget build(BuildContext context) {
    final analytics = ref.watch(adminAnalyticsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Reports & Analytics',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryLight,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () =>
                ref.read(adminIssuesProvider.notifier).fetchIssues(),
          ),
          IconButton(
            icon: const CircleAvatar(
              radius: 15,
              backgroundColor: AppColors.surfaceVariant,
              child: Icon(
                Icons.person,
                size: 18,
                color: AppColors.primaryLight,
              ),
            ),
            tooltip: 'Admin Profile',
            onPressed: () => widget.onNavigateToTab?.call(3),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Context & Range Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Performance Metrics',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Incident resolution and volume insights',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedRange,
                      isDense: true,
                      dropdownColor: AppColors.surface,
                      style: const TextStyle(
                        color: AppColors.primaryLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      icon: const Icon(
                        Icons.expand_more_rounded,
                        size: 18,
                        color: AppColors.primaryLight,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Last 7 Days',
                          child: Text('Last 7 Days'),
                        ),
                        DropdownMenuItem(
                          value: 'Last 30 Days',
                          child: Text('Last 30 Days'),
                        ),
                        DropdownMenuItem(
                          value: 'This Term',
                          child: Text('This Term'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedRange = val);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Card 1: Issue Volume Trend (Line Chart)
            _buildVolumeTrendCard(analytics),
            const SizedBox(height: 16),

            // Card 2: Issues by Status
            _buildIssuesByStatusCard(analytics),
            const SizedBox(height: 16),

            // Card 3: Issues by Priority
            _buildIssuesByPriorityCard(analytics),
            const SizedBox(height: 16),

            // Card 4: Issues by Category
            _buildIssuesByCategoryCard(analytics),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildVolumeTrendCard(AdminAnalyticsData data) {
    return Container(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'System Issue Volume Trend',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Daily reported incidents across campus nodes',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Monitored',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Custom Painter for Trend Curve
          SizedBox(
            height: 120,
            width: double.infinity,
            child: CustomPaint(
              painter: _TrendChartPainter(data.weeklyTrend),
            ),
          ),
          const SizedBox(height: 8),

          // X-Axis Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Mon', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
              Text('Tue', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
              Text('Wed', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
              Text('Thu', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
              Text('Fri', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
              Text('Sat', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
              Text('Sun', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIssuesByStatusCard(AdminAnalyticsData data) {
    final total = data.totalIssues > 0 ? data.totalIssues : 1;

    return Container(
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
              Text(
                'Issues by Status',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${data.totalIssues} Total',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          _buildProgressBarRow(
            label: 'Open',
            count: data.openCount,
            total: total,
            color: AppColors.warning,
          ),
          const SizedBox(height: 12),
          _buildProgressBarRow(
            label: 'In Progress',
            count: data.inProgressCount,
            total: total,
            color: const Color(0xFF60A5FA),
          ),
          const SizedBox(height: 12),
          _buildProgressBarRow(
            label: 'Resolved',
            count: data.resolvedCount,
            total: total,
            color: AppColors.success,
          ),
          const SizedBox(height: 12),
          _buildProgressBarRow(
            label: 'Closed',
            count: data.closedCount,
            total: total,
            color: AppColors.textMuted,
          ),
        ],
      ),
    );
  }

  Widget _buildIssuesByPriorityCard(AdminAnalyticsData data) {
    final total = data.totalIssues > 0 ? data.totalIssues : 1;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Issues by Priority',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),

          _buildProgressBarRow(
            label: 'Critical Priority',
            count: data.criticalPriorityCount,
            total: total,
            color: AppColors.danger,
          ),
          const SizedBox(height: 12),
          _buildProgressBarRow(
            label: 'High Priority',
            count: data.highPriorityCount,
            total: total,
            color: const Color(0xFFF97316),
          ),
          const SizedBox(height: 12),
          _buildProgressBarRow(
            label: 'Medium Priority',
            count: data.mediumPriorityCount,
            total: total,
            color: AppColors.warning,
          ),
          const SizedBox(height: 12),
          _buildProgressBarRow(
            label: 'Low Priority',
            count: data.lowPriorityCount,
            total: total,
            color: AppColors.primaryLight,
          ),
        ],
      ),
    );
  }

  Widget _buildIssuesByCategoryCard(AdminAnalyticsData data) {
    final categories = data.issuesByCategory.entries.toList();
    int maxVal = 1;
    for (final e in categories) {
      if (e.value > maxVal) maxVal = e.value;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Issues by Category',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Vertical Bar chart
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: categories.map((cat) {
                final ratio = (cat.value / maxVal).clamp(0.1, 1.0);
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${cat.value}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 28,
                      height: 80 * ratio,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withValues(alpha: 0.8),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 52,
                      child: Text(
                        cat.key,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBarRow({
    required String label,
    required int count,
    required int total,
    required Color color,
  }) {
    final percent = (count / total).clamp(0.0, 1.0);
    final percentStr = (percent * 100).toStringAsFixed(0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$count ($percentStr%)',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 6,
            backgroundColor: AppColors.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _TrendChartPainter extends CustomPainter {
  final List<double> values;

  _TrendChartPainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final linePaint = Paint()
      ..color = AppColors.primaryLight
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primary.withValues(alpha: 0.35),
          AppColors.primary.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = AppColors.cardBorder.withValues(alpha: 0.5)
      ..strokeWidth = 1;

    // Draw horizontal grid lines
    canvas.drawLine(Offset(0, size.height * 0.25), Offset(size.width, size.height * 0.25), gridPaint);
    canvas.drawLine(Offset(0, size.height * 0.5), Offset(size.width, size.height * 0.5), gridPaint);
    canvas.drawLine(Offset(0, size.height * 0.75), Offset(size.width, size.height * 0.75), gridPaint);

    final path = Path();
    final fillPath = Path();

    final dx = size.width / (values.length - 1);
    double maxVal = 1;
    for (final v in values) {
      if (v > maxVal) maxVal = v;
    }

    final points = <Offset>[];
    for (int i = 0; i < values.length; i++) {
      final x = i * dx;
      final y = size.height - (values[i] / maxVal * (size.height - 16)) - 8;
      points.add(Offset(x, y));
    }

    path.moveTo(points.first.dx, points.first.dy);
    fillPath.moveTo(points.first.dx, size.height);
    fillPath.lineTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final cx = (p0.dx + p1.dx) / 2;
      path.cubicTo(cx, p0.dy, cx, p1.dy, p1.dx, p1.dy);
      fillPath.cubicTo(cx, p0.dy, cx, p1.dy, p1.dx, p1.dy);
    }

    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    // Draw data points
    final dotPaint = Paint()..color = AppColors.primaryLight;
    final dotInner = Paint()..color = AppColors.surface;
    for (final pt in points) {
      canvas.drawCircle(pt, 4, dotPaint);
      canvas.drawCircle(pt, 2, dotInner);
    }
  }

  @override
  bool shouldRepaint(covariant _TrendChartPainter oldDelegate) => true;
}
