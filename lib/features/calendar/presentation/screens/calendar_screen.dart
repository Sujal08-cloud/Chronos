import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/date_time_helper.dart';
import '../../../auth/data/auth_provider.dart';
import '../../../todo/data/todo_provider.dart';
import '../../../todo/presentation/widgets/task_status_sheet.dart';
import '../../data/calendar_provider.dart';
import '../widgets/daily_agenda_list.dart';
import '../widgets/month_calendar_widget.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  void _openStatusSheet(BuildContext context, dynamic todo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => TaskStatusSheet(todo: todo),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focusedDay = ref.watch(focusedDayProvider);
    final selectedDay = ref.watch(selectedDayProvider);
    final allTodos = ref.watch(todosStreamProvider).value ?? [];
    final user = ref.watch(authStateChangesProvider).value;

    final dayTodos = allTodos
        .where((t) => DateTimeHelper.isSameDay(t.scheduledDate, selectedDay))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.calendar)),
      body: ListView(
        children: [
          MonthCalendarWidget(
            focusedDay: focusedDay,
            selectedDay: selectedDay,
            allTodos: allTodos,
            onDaySelected: (day) => ref.read(selectedDayProvider.notifier).state = day,
            onPageChanged: (day) => ref.read(focusedDayProvider.notifier).state = day,
          ),
          DailyAgendaList(
            todos: dayTodos,
            onTapTodo: (todo) => _openStatusSheet(context, todo),
            onToggleTodo: (todo, value) {
              if (user == null) return;
              ref.read(todoControllerProvider.notifier).toggleComplete(
                    user.uid,
                    todo.id,
                    value ?? false,
                  );
            },
            onViewDetail: (todo) => context.push('/todo-detail', extra: todo),
          ),
        ],
      ),
    );
  }
}