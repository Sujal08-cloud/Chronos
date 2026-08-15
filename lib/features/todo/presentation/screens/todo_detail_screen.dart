import 'package:chronos/features/todo/domain/reccurrence_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/utils/date_time_helper.dart';
import '../../../auth/data/auth_provider.dart';
import '../../data/todo_provider.dart';
import '../../domain/todo_model.dart';

class TodoDetailScreen extends ConsumerWidget {
  final TodoModel todo;

  const TodoDetailScreen({super.key, required this.todo});

  Color _priorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return AppColors.priorityLow;
      case TaskPriority.medium:
        return AppColors.priorityMedium;
      case TaskPriority.high:
        return AppColors.priorityHigh;
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(AppStrings.delete, style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final user = ref.read(authStateChangesProvider).value;
      if (user == null) return;
      await ref.read(todoControllerProvider.notifier).deleteTodo(user.uid, todo.id);
      await NotificationService().cancelNotification(todo.id.hashCode);
      if (context.mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/add-edit-todo', extra: todo),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.paddingLg),
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingSm, vertical: 4),
                decoration: BoxDecoration(
                  color: _priorityColor(todo.priority).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                ),
                child: Text(
                  todo.priority.label,
                  style: TextStyle(
                    color: _priorityColor(todo.priority),
                    fontWeight: FontWeight.w600,
                    fontSize: AppSizes.fontXs,
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.paddingSm),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingSm, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                ),
                child: Text(
                  todo.category,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: AppSizes.fontXs,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingMd),
          Text(
            todo.title,
            style: const TextStyle(fontSize: AppSizes.fontXl, fontWeight: FontWeight.bold),
          ),
          if (todo.description.isNotEmpty) ...[
            const SizedBox(height: AppSizes.paddingSm),
            Text(
              todo.description,
              style: const TextStyle(fontSize: AppSizes.fontMd, color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: AppSizes.paddingLg),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today_outlined, color: AppColors.primary),
            title: const Text(AppStrings.dueDate),
            subtitle: Text(DateTimeHelper.formatDate(todo.scheduledDate)),
          ),
          if (todo.scheduledTime != null)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.access_time_rounded, color: AppColors.primary),
              title: const Text(AppStrings.dueTime),
              subtitle: Text(DateTimeHelper.formatTime(todo.scheduledTime!)),
            ),
          if (todo.hasAlarm)
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.alarm_rounded, color: AppColors.warning),
              title: Text(AppStrings.setAlarm),
              subtitle: Text('Alarm is set for this task'),
            ),
          if (todo.isRecurring)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.repeat_rounded, color: AppColors.primary),
              title: const Text(AppStrings.recurring),
              subtitle: Text(todo.recurrenceType.label),
            ),
        ],
      ),
    );
  }
}