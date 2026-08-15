import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/todo/presentation/screens/home_screen.dart';
import '../../features/todo/presentation/screens/add_edit_todo_screen.dart';
import '../../features/todo/presentation/screens/todo_detail_screen.dart';
import '../../features/todo/domain/todo_model.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/add-edit-todo',
        builder: (context, state) {
          final todo = state.extra as TodoModel?;
          return AddEditTodoScreen(todo: todo);
        },
      ),
      GoRoute(
        path: '/todo-detail',
        builder: (context, state) {
          final todo = state.extra as TodoModel;
          return TodoDetailScreen(todo: todo);
        },
      ),
    ],
  );
});