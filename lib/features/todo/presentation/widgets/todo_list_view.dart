import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/todo_model.dart';
import 'todo_tile.dart';

class TodoListView extends StatelessWidget {
  final List<TodoModel> todos;
  final ValueChanged<TodoModel> onTapTodo;
  final void Function(TodoModel todo, bool? value) onToggleTodo;

  const TodoListView({
    super.key,
    required this.todos,
    required this.onTapTodo,
    required this.onToggleTodo,
  });

  @override
  Widget build(BuildContext context) {
    if (todos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.checklist_rounded, size: 64, color: AppColors.divider),
            const SizedBox(height: AppSizes.paddingMd),
            const Text(
              AppStrings.noTasks,
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
        return TodoTile(
          todo: todo,
          onTap: () => onTapTodo(todo),
          onToggle: (value) => onToggleTodo(todo, value),
        );
      },
    );
  }
}