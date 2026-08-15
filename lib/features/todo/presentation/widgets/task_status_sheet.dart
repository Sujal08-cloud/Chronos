import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/services/notification_service.dart';
import '../../../auth/data/auth_provider.dart';
import '../../data/todo_provider.dart';
import '../../domain/todo_model.dart';

class TaskStatusSheet extends ConsumerStatefulWidget {
  final TodoModel todo;

  const TaskStatusSheet({super.key, required this.todo});

  @override
  ConsumerState<TaskStatusSheet> createState() => _TaskStatusSheetState();
}

class _TaskStatusSheetState extends ConsumerState<TaskStatusSheet> {
  bool _showReasonField = false;
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _markComplete() async {
    final updated = widget.todo.copyWith(isCompleted: true, incompleteReason: '');
    await ref.read(todoControllerProvider.notifier).updateTodo(updated);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _saveIncomplete() async {
    final updated = widget.todo.copyWith(
      isCompleted: false,
      incompleteReason: _reasonController.text.trim(),
    );
    await ref.read(todoControllerProvider.notifier).updateTodo(updated);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSizes.paddingLg,
        right: AppSizes.paddingLg,
        top: AppSizes.paddingLg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSizes.paddingLg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.paddingLg),
          Text(
            widget.todo.title,
            style: const TextStyle(fontSize: AppSizes.fontLg, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSizes.paddingSm),
          const Text(
            'Did you complete this task?',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSizes.paddingLg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _markComplete,
                  icon: const Icon(Icons.check_circle_outline, color: AppColors.success),
                  label: const Text('Completed'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.success),
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingMd),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.paddingMd),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _showReasonField = true),
                  icon: const Icon(Icons.cancel_outlined, color: AppColors.error),
                  label: const Text('Not Completed'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingMd),
                  ),
                ),
              ),
            ],
          ),
          if (_showReasonField) ...[
            const SizedBox(height: AppSizes.paddingLg),
            TextField(
              controller: _reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Why not completed? (optional)',
              ),
            ),
            const SizedBox(height: AppSizes.paddingMd),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveIncomplete,
                child: const Text('Save'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}