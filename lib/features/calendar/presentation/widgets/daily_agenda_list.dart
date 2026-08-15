import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../todo/domain/todo_model.dart';
import '../../../todo/presentation/widgets/todo_tile.dart';

class DailyAgendaList extends StatelessWidget {
  final List<TodoModel> todos;
  final ValueChanged<TodoModel> onTapTodo;
  final void Function(TodoModel todo, bool? value) onToggleTodo;

  const DailyAgendaList({
    super.key,
    required this.todos,
    required this.onTapTodo,
    required this.onToggleTodo,
  });

  @override
  Widget build(BuildContext context) {
    if (todos.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSizes.paddingXl),
        child: Column(
          children: [
            const Icon(Icons.event_available_outlined, size: 48, color: AppColors.divider),
            const SizedBox(height: AppSizes.paddingSm),
            const Text(
              AppStrings.noTasksToday,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMd),
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        return TodoTile(
          todo: todo,
          onTap: () => onTapTodo(todo),
          onToggle: (value) => onToggleTodo(todo, value),
        );
      },
    );
  }
}