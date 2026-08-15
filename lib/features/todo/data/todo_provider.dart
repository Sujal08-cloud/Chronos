import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../auth/data/auth_provider.dart';
import '../domain/todo_model.dart';
import 'todo_repository.dart';

final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  return TodoRepository();
});

final todosStreamProvider = StreamProvider<List<TodoModel>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return const Stream.empty();
  return ref.watch(todoRepositoryProvider).watchTodos(user.uid);
});

final selectedCategoryFilterProvider = StateProvider<String?>((ref) => null);

final completedTodosProvider = Provider<List<TodoModel>>((ref) {
  final todos = ref.watch(todosStreamProvider).value ?? [];
  return todos.where((t) => t.isCompleted).toList();
});

final pendingTodosProvider = Provider<List<TodoModel>>((ref) {
  final todos = ref.watch(todosStreamProvider).value ?? [];
  return todos.where((t) => !t.isCompleted).toList();
});

final alarmTodosProvider = Provider<List<TodoModel>>((ref) {
  final todos = ref.watch(todosStreamProvider).value ?? [];
  return todos.where((t) => t.hasAlarm && !t.isCompleted).toList();
});

class TodoController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> addTodo(TodoModel todo) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(todoRepositoryProvider).addTodo(todo);
    });
  }

  Future<void> updateTodo(TodoModel todo) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(todoRepositoryProvider).updateTodo(todo);
    });
  }

  Future<void> deleteTodo(String userId, String todoId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(todoRepositoryProvider).deleteTodo(userId, todoId);
    });
  }

  Future<void> toggleComplete(String userId, String todoId, bool isCompleted) async {
    await ref.read(todoRepositoryProvider).toggleComplete(userId, todoId, isCompleted);
  }
}

final todoControllerProvider = AsyncNotifierProvider<TodoController, void>(() {
  return TodoController();
});