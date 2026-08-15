import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../domain/todo_model.dart';
import 'alarm_tile.dart';

class AlarmListView extends StatelessWidget {
  final List<TodoModel> todos;
  final void Function(TodoModel todo, bool value) onToggleAlarm;
  final ValueChanged<TodoModel> onTapTodo;

  const AlarmListView({
    super.key,
    required this.todos,
    required this.onToggleAlarm,
    required this.onTapTodo,
  });

  @override
  Widget build(BuildContext context) {
    if (todos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.alarm_off_rounded, size: 64, color: AppColors.divider),
            const SizedBox(height: AppSizes.paddingMd),
            const Text(
              'No alarms set',
              style: TextStyle(color: AppColors.textSecondary, fontSize: AppSizes.fontMd),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingMd),
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        return AlarmTile(
          todo: todo,
          onToggleAlarm: (value) => onToggleAlarm(todo, value),
          onTap: () => onTapTodo(todo),
        );
      },
    );
  }
}