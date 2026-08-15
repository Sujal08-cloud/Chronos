import 'package:chronos/core/utils/date_time_helper.dart';
import 'package:chronos/features/profile/presentation/widgets/task_stats_charts.dart';
import 'package:chronos/features/todo/data/todo_provider.dart';
import 'package:chronos/shared/provider/shared_prefs_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../auth/data/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentAppUserProvider);
    final isDark = ref.watch(themeControllerProvider);
    final allTodos = ref.watch(todosStreamProvider).value ?? [];

    final todayTodos = allTodos
        .where((t) => DateTimeHelper.isSameDay(t.scheduledDate, DateTime.now()))
        .toList();
    final completedCount = todayTodos.where((t) => t.isCompleted).length;
    final notCompletedCount = todayTodos
    .where((t) => !t.isCompleted && (t.incompleteReason?.isNotEmpty ?? false))
    .length;

    final pendingCount = todayTodos.where((t) => !t.isCompleted).length;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.profile)),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.paddingLg),
        children: [
          Center(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.person_rounded, size: 40, color: Colors.white),
                ),
                const SizedBox(height: AppSizes.paddingMd),
                userAsync.when(
                  data: (user) => Column(
                    children: [
                      Text(
                        user?.name ?? '',
                        style: const TextStyle(
                            fontSize: AppSizes.fontLg, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (e, _) => const Text('Error loading profile'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.paddingXl),
          TaskStatsChart(completedCount: completedCount, pendingCount: pendingCount, notCompletedCount: notCompletedCount,),
          const SizedBox(height: AppSizes.paddingLg),
          const Divider(),
          SwitchListTile(
            value: isDark,
            onChanged: (v) => ref.read(themeControllerProvider.notifier).toggleTheme(v),
            title: const Text(AppStrings.darkMode),
            secondary: const Icon(Icons.dark_mode_outlined, color: AppColors.primary),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: AppColors.error),
            title: const Text(AppStrings.logout, style: TextStyle(color: AppColors.error)),
            onTap: () async {
              await ref.read(authControllerProvider.notifier).signOut();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}