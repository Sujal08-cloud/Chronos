import 'package:chronos/features/todo/domain/reccurrence_type.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/date_time_helper.dart';
import '../../domain/todo_model.dart';

class TodoTile extends StatelessWidget {
  final TodoModel todo;
  final VoidCallback onTap;
  final ValueChanged<bool?> onToggle;

  const TodoTile({
    super.key,
    required this.todo,
    required this.onTap,
    required this.onToggle,
  });

  Color get _priorityColor {
    switch (todo.priority) {
      case TaskPriority.low:
        return AppColors.priorityLow;
      case TaskPriority.medium:
        return AppColors.priorityMedium;
      case TaskPriority.high:
        return AppColors.priorityHigh;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingSm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMd),
          child: Row(
            children: [
              Container(width: 4, height: 40, color: _priorityColor),
              const SizedBox(width: AppSizes.paddingMd),
              Checkbox(value: todo.isCompleted, onChanged: onToggle),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      todo.title,
                      style: TextStyle(
                        fontSize: AppSizes.fontMd,
                        fontWeight: FontWeight.w600,
                        decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                        color: todo.isCompleted
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
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
                        if (todo.hasAlarm) ...[
                          const SizedBox(width: AppSizes.paddingSm),
                          const Icon(Icons.alarm_rounded,
                              size: AppSizes.iconSm, color: AppColors.warning),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
