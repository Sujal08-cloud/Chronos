import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/date_time_helper.dart';
import '../../domain/reccurrence_type.dart';
import '../../domain/todo_model.dart';

class TodoTile extends StatelessWidget {
  final TodoModel todo;
  final VoidCallback onTap;
  final ValueChanged<bool?> onToggle;
  final VoidCallback onViewDetail;

  const TodoTile({
    super.key,
    required this.todo,
    required this.onTap,
    required this.onToggle,
    required this.onViewDetail,
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

  bool get _isOverdue {
    final now = DateTime.now();
    final deadline = todo.scheduledTime ?? todo.scheduledDate;
    return deadline.isBefore(now);
  }

  Widget _buildStatusIcon() {
    if (todo.isCompleted) {
      return const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 26);
    }
    if (todo.incompleteReason != null && todo.incompleteReason!.isNotEmpty) {
      return const Icon(Icons.cancel_rounded, color: AppColors.error, size: 26);
    }
    if (_isOverdue) {
      return Container(
        width: 16,
        height: 16,
        decoration: const BoxDecoration(color: AppColors.warning, shape: BoxShape.circle),
      );
    }
    return const Icon(Icons.radio_button_unchecked_rounded, color: AppColors.divider, size: 26);
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
              _buildStatusIcon(),
              const SizedBox(width: AppSizes.paddingMd),
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
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
                onSelected: (value) {
                  if (value == 'detail') onViewDetail();
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'detail',
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded, size: 18),
                        SizedBox(width: 8),
                        Text('View Details'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}