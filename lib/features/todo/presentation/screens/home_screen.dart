import 'package:chronos/core/services/notification_service.dart';
import 'package:chronos/features/todo/presentation/screens/bottom_nav.dart';
import 'package:chronos/features/todo/presentation/widgets/alarm_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

import '../../../auth/data/auth_provider.dart';
import '../../../calendar/presentation/screens/calendar_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

import '../../data/todo_provider.dart';
import '../widgets/task_status_sheet.dart';
import '../widgets/todo_list_view.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  void _openStatusSheet(dynamic todo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => TaskStatusSheet(todo: todo),
    );
  }

  Widget _buildTodosTab() {
    final user = ref.watch(authStateChangesProvider).value;
    final todosAsync = ref.watch(todosStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.todos),
      ),
      body: todosAsync.when(
        data: (todos) => TodoListView(
          todos: todos,
          onTapTodo: (todo) => _openStatusSheet(todo),
          onToggleTodo: (todo, value) {
            if (user == null) return;

            ref
                .read(todoControllerProvider.notifier)
                .toggleComplete(
                  user.uid,
                  todo.id,
                  value ?? false,
                );
          },
          onViewDetail: (todo) => context.push('/todo-detail', extra: todo),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (e, _) => Center(
          child: Text(
            'Error: $e',
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/add-edit-todo');
        },
        backgroundColor: AppColors.primary,
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildAlarmsTab() {
    final alarms = ref.watch(alarmTodosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.alarms),
      ),
      body: AlarmListView(
        todos: alarms,
        onTapTodo: (todo) => context.push('/todo-detail', extra: todo),
        onToggleAlarm: (todo, value) async {
          final updated = todo.copyWith(hasAlarm: value);
          await ref.read(todoControllerProvider.notifier).updateTodo(updated);
          if (value && todo.scheduledTime != null) {
            await NotificationService().requestExactAlarmPermission();
            await NotificationService().scheduleNotification(
              id: todo.id.hashCode,
              title: todo.title,
              body: todo.description.isEmpty ? 'Task reminder' : todo.description,
              scheduledDateTime: todo.scheduledTime!,
            );
          } else {
            await NotificationService().cancelNotification(todo.id.hashCode);
          }
        },
      ),
    );
  }

  Widget _buildCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        return _buildTodosTab();

      case 1:
        return const CalendarScreen();

      case 2:
        return _buildAlarmsTab();

      case 3:
        return const ProfileScreen();

      default:
        return _buildTodosTab();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildCurrentPage(),

      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}