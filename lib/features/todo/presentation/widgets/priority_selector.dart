import 'package:chronos/features/todo/domain/reccurrence_type.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';


class PrioritySelector extends StatelessWidget {
  final TaskPriority selected;
  final ValueChanged<TaskPriority> onChanged;

  const PrioritySelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  Color _colorFor(TaskPriority priority) {
    switch (priority) {
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
    return Row(
      children: TaskPriority.values.map((priority) {
        final isSelected = priority == selected;
        final color = _colorFor(priority);
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(priority),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingXs),
              padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingSm),
              decoration: BoxDecoration(
                color: isSelected ? color.withValues(alpha: 0.15) : AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(color: isSelected ? color : AppColors.divider),
              ),
              child: Column(
                children: [
                  Icon(Icons.flag_rounded, size: AppSizes.iconSm, color: color),
                  const SizedBox(height: 2),
                  Text(
                    priority.label,
                    style: TextStyle(
                      fontSize: AppSizes.fontXs,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}