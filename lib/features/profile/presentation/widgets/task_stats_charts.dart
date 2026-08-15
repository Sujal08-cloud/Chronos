import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

class TaskStatsChart extends StatelessWidget {
  final int completedCount;
  final int pendingCount;
  final int notCompletedCount;

  const TaskStatsChart({
    super.key,
    required this.completedCount,
    required this.pendingCount,
    required this.notCompletedCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = completedCount + pendingCount + notCompletedCount;
    final secondaryTextColor = theme.textTheme.bodySmall?.color ?? AppColors.textSecondary;

    if (total == 0) {
      return Container(
        padding: const EdgeInsets.all(AppSizes.paddingLg),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: Center(
          child: Text(
            'No tasks scheduled for today',
            style: TextStyle(color: secondaryTextColor),
          ),
        ),
      );
    }

    final completedPercent = (completedCount / total * 100).round();

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingLg),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.dark
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Today's Progress",
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: AppSizes.fontMd,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.paddingMd),
          SizedBox(
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 50,
                    sections: [
                      PieChartSectionData(
                        value: completedCount.toDouble(),
                        color: AppColors.success,
                        title: '',
                        radius: 22,
                      ),
                      PieChartSectionData(
                        value: pendingCount.toDouble(),
                        color: AppColors.warning,
                        title: '',
                        radius: 22,
                      ),
                      PieChartSectionData(
                        value: notCompletedCount.toDouble(),
                        color: AppColors.error,
                        title: '',
                        radius: 22,
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$completedPercent%',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: AppSizes.fontXl,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Completed',
                      style: TextStyle(fontSize: AppSizes.fontXs, color: secondaryTextColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.paddingMd),
          Wrap(
            spacing: AppSizes.paddingMd,
            runSpacing: AppSizes.paddingSm,
            alignment: WrapAlignment.center,
            children: [
              _legendItem(AppColors.success, 'Completed', completedCount, theme),
              _legendItem(AppColors.warning, 'Pending', pendingCount, theme),
              _legendItem(AppColors.error, 'Not Completed', notCompletedCount, theme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Color dotColor, String label, int count, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          '$label ($count)',
          style: theme.textTheme.bodyMedium?.copyWith(fontSize: AppSizes.fontSm),
        ),
      ],
    );
  }
}