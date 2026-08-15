import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/date_time_helper.dart';
import '../../domain/todo_model.dart';

class AlarmTile extends StatelessWidget {
  final TodoModel todo;
  final ValueChanged<bool> onToggleAlarm;
  final VoidCallback onTap;

  const AlarmTile({
    super.key,
    required this.todo,
    required this.onToggleAlarm,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingSm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMd),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.alarm_rounded, color: AppColors.warning, size: 22),
              ),
              const SizedBox(width: AppSizes.paddingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      todo.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: AppSizes.fontMd,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            size: AppSizes.iconSm, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          DateTimeHelper.relativeDayLabel(todo.scheduledDate),
                          style: const TextStyle(
                              fontSize: AppSizes.fontXs, color: AppColors.textSecondary),
                        ),
                        if (todo.scheduledTime != null) ...[
                          const SizedBox(width: AppSizes.paddingSm),
                          Icon(Icons.access_time_rounded,
                              size: AppSizes.iconSm, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            DateTimeHelper.formatTime(todo.scheduledTime!),
                            style: const TextStyle(
                                fontSize: AppSizes.fontXs, color: AppColors.textSecondary),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Switch(
                value: todo.hasAlarm,
                activeColor: AppColors.primary,
                onChanged: onToggleAlarm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}