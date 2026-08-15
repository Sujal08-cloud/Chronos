import 'package:chronos/core/widgets/cutom_textfield.dart';
import 'package:chronos/features/todo/domain/reccurrence_type.dart';
import 'package:chronos/features/todo/presentation/widgets/category_chips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/utils/date_time_helper.dart';
import '../../../../core/widgets/custom_button.dart';

import '../../../auth/data/auth_provider.dart';
import '../../data/todo_provider.dart';
import '../../domain/todo_model.dart';
import '../widgets/priority_selector.dart';

class AddEditTodoScreen extends ConsumerStatefulWidget {
  final TodoModel? todo;

  const AddEditTodoScreen({
    super.key,
    this.todo,
  });

  @override
  ConsumerState<AddEditTodoScreen> createState() =>
      _AddEditTodoScreenState();
}

class _AddEditTodoScreenState
    extends ConsumerState<AddEditTodoScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descController;

  final List<String> _categories = [
    'General',
    'Work',
    'Personal',
    'Study',
    'Health',
  ];

  late String _selectedCategory;
  late TaskPriority _priority;
  late DateTime _selectedDate;

  DateTime? _selectedTime;

  late bool _isRecurring;
  late RecurrenceType _recurrenceType;
  late bool _hasAlarm;

  bool get _isEditing => widget.todo != null;

  @override
  void initState() {
    super.initState();

    final todo = widget.todo;

    _titleController = TextEditingController(
      text: todo?.title ?? '',
    );

    _descController = TextEditingController(
      text: todo?.description ?? '',
    );

    _selectedCategory =
        todo?.category ?? _categories.first;

    _priority =
        todo?.priority ?? TaskPriority.medium;

    _selectedDate =
        todo?.scheduledDate ?? DateTime.now();

    _selectedTime =
        todo?.scheduledTime;

    _isRecurring =
        todo?.isRecurring ?? false;

    _recurrenceType =
        todo?.recurrenceType ?? RecurrenceType.none;

    _hasAlarm =
        todo?.hasAlarm ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------
  // Check whether selected date is today
  // ----------------------------------------------------------

  bool _isToday(DateTime date) {
    final now = DateTime.now();

    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // ----------------------------------------------------------
  // Check complete scheduled date + time
  // ----------------------------------------------------------

  DateTime? get _scheduledDateTime {
    if (_selectedTime == null) {
      return null;
    }

    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
  }

  // ----------------------------------------------------------
  // Check if selected date/time is in the past
  // ----------------------------------------------------------

  bool get _isPastDateTime {
    final scheduled = _scheduledDateTime;

    if (scheduled == null) {
      return false;
    }

    return !scheduled.isAfter(DateTime.now());
  }

  // ----------------------------------------------------------
  // Date Picker
  // ----------------------------------------------------------

  Future<void> _pickDate() async {
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    // If editing an old Todo, allow its existing date
    // to remain visible, but new selections start from today.
    final initialDate = _selectedDate.isBefore(today)
        ? today
        : _selectedDate;

    final picked = await showDatePicker(
      context: context,

      initialDate: initialDate,

      // IMPORTANT:
      // User cannot select any date before today.
      firstDate: today,

      lastDate: DateTime(
        now.year + 2,
        now.month,
        now.day,
      ),
    );

    if (picked == null) return;

    setState(() {
      _selectedDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
      );

      // If selected date is today and the selected time
      // has already passed, clear the time.
      if (_selectedTime != null &&
          _isToday(_selectedDate) &&
          _isPastDateTime) {
        _selectedTime = null;
      }
    });
  }

  // ----------------------------------------------------------
  // Time Picker
  // ----------------------------------------------------------

  Future<void> _pickTime() async {
    final now = DateTime.now();

    // If selected date is today, don't allow a past time.
    final isSelectedDateToday = _isToday(_selectedDate);

    final currentTime = TimeOfDay(
      hour: now.hour,
      minute: now.minute,
    );

    final initialTime = _selectedTime != null
        ? TimeOfDay.fromDateTime(_selectedTime!)
        : currentTime;

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked == null) return;

    // --------------------------------------------------------
    // Build selected DateTime
    // --------------------------------------------------------

    final selectedDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      picked.hour,
      picked.minute,
    );

    // --------------------------------------------------------
    // Prevent past/current time
    // --------------------------------------------------------

    if (isSelectedDateToday &&
        !selectedDateTime.isAfter(now)) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Please select a future time.',
            ),
          ),
        );

      return;
    }

    setState(() {
      _selectedTime = selectedDateTime;
    });
  }

  // ----------------------------------------------------------
  // Save Todo
  // ----------------------------------------------------------

  Future<void> _handleSave() async {
    // Validate text fields
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user =
        ref.read(authStateChangesProvider).value;

    if (user == null) {
      return;
    }

    // --------------------------------------------------------
    // Date validation
    // --------------------------------------------------------

    final now = DateTime.now();

    final selectedDateOnly = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );

    final todayOnly = DateTime(
      now.year,
      now.month,
      now.day,
    );

    if (selectedDateOnly.isBefore(todayOnly)) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'You cannot create a task for a past date.',
            ),
          ),
        );

      return;
    }

    // --------------------------------------------------------
    // Time validation
    // --------------------------------------------------------

    if (_selectedTime != null) {
      final scheduledDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      if (!scheduledDateTime.isAfter(now)) {
        if (!mounted) return;

        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            const SnackBar(
              content: Text(
                'Please select a future date and time.',
              ),
            ),
          );

        return;
      }
    }

    // --------------------------------------------------------
    // Create Todo
    // --------------------------------------------------------

    final id =
        widget.todo?.id ?? const Uuid().v4();

    final todo = TodoModel(
      id: id,
      userId: user.uid,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      category: _selectedCategory,
      priority: _priority,
      scheduledDate: _selectedDate,
      scheduledTime: _selectedTime,
      isRecurring: _isRecurring,
      recurrenceType: _isRecurring
          ? _recurrenceType
          : RecurrenceType.none,
      hasAlarm: _hasAlarm,
      isCompleted:
          widget.todo?.isCompleted ?? false,
      createdAt:
          widget.todo?.createdAt ?? DateTime.now(),
    );

    // --------------------------------------------------------
    // Save to Firebase
    // --------------------------------------------------------

    if (_isEditing) {
      await ref
          .read(todoControllerProvider.notifier)
          .updateTodo(todo);
    } else {
      await ref
          .read(todoControllerProvider.notifier)
          .addTodo(todo);
    }

    // --------------------------------------------------------
    // Notifications
    // --------------------------------------------------------

    if (_hasAlarm && _selectedTime != null) {
      await NotificationService()
          .requestExactAlarmPermission();

      await NotificationService().scheduleNotification(
        id: id.hashCode,
        title: todo.title,
        body: todo.description.isEmpty
            ? 'Task reminder'
            : todo.description,
        scheduledDateTime: _selectedTime!,
      );
    } else {
      await NotificationService()
          .cancelNotification(id.hashCode);
    }

    if (!mounted) return;

    context.pop();
  }

  // ----------------------------------------------------------
  // UI
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final controllerState =
        ref.watch(todoControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing
              ? AppStrings.editTask
              : AppStrings.addTask,
        ),
      ),

      body: Form(
        key: _formKey,

        child: ListView(
          padding: const EdgeInsets.all(
            AppSizes.paddingLg,
          ),

          children: [
            // --------------------------------------------------
            // Title
            // --------------------------------------------------

            CustomTextField(
              controller: _titleController,
              label: AppStrings.taskTitle,
              hint: 'e.g. Team meeting',
              validator: (v) {
                if (v == null ||
                    v.trim().isEmpty) {
                  return 'Title is required';
                }

                return null;
              },
            ),

            const SizedBox(
              height: AppSizes.paddingMd,
            ),

            // --------------------------------------------------
            // Description
            // --------------------------------------------------

            CustomTextField(
              controller: _descController,
              label: AppStrings.taskDescription,
              hint: 'Add notes...',
              maxLines: 3,
            ),

            const SizedBox(
              height: AppSizes.paddingLg,
            ),

            // --------------------------------------------------
            // Category
            // --------------------------------------------------

            const Text(
              AppStrings.category,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: AppSizes.fontSm,
              ),
            ),

            const SizedBox(
              height: AppSizes.paddingSm,
            ),

            Wrap(
              spacing: AppSizes.paddingSm,
              runSpacing: AppSizes.paddingSm,
              children: _categories.map((cat) {
                return CategoryChip(
                  label: cat,
                  isSelected:
                      _selectedCategory == cat,
                  onTap: () {
                    setState(() {
                      _selectedCategory = cat;
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(
              height: AppSizes.paddingLg,
            ),

            // --------------------------------------------------
            // Priority
            // --------------------------------------------------

            const Text(
              AppStrings.priority,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: AppSizes.fontSm,
              ),
            ),

            const SizedBox(
              height: AppSizes.paddingSm,
            ),

            PrioritySelector(
              selected: _priority,
              onChanged: (p) {
                setState(() {
                  _priority = p;
                });
              },
            ),

            const SizedBox(
              height: AppSizes.paddingLg,
            ),

            // --------------------------------------------------
            // Date & Time
            // --------------------------------------------------

            Row(
              children: [
                Expanded(
                  child: ListTile(
                    contentPadding:
                        EdgeInsets.zero,

                    leading: const Icon(
                      Icons.calendar_today_outlined,
                    ),

                    title: Text(
                      DateTimeHelper.formatDate(
                        _selectedDate,
                      ),
                    ),

                    subtitle: const Text(
                      AppStrings.dueDate,
                    ),

                    onTap: _pickDate,
                  ),
                ),

                Expanded(
                  child: ListTile(
                    contentPadding:
                        EdgeInsets.zero,

                    leading: const Icon(
                      Icons.access_time_rounded,
                    ),

                    title: Text(
                      _selectedTime != null
                          ? DateTimeHelper.formatTime(
                              _selectedTime!,
                            )
                          : '--:--',
                    ),

                    subtitle: const Text(
                      AppStrings.dueTime,
                    ),

                    onTap: _pickTime,
                  ),
                ),
              ],
            ),

            const Divider(),

            // --------------------------------------------------
            // Alarm
            // --------------------------------------------------

            SwitchListTile(
              contentPadding: EdgeInsets.zero,

              value: _hasAlarm,

              onChanged: (v) {
                setState(() {
                  _hasAlarm = v;
                });
              },

              title: const Text(
                AppStrings.setAlarm,
              ),

              secondary: const Icon(
                Icons.alarm_rounded,
                color: AppColors.warning,
              ),
            ),

            // --------------------------------------------------
            // Recurring
            // --------------------------------------------------

            SwitchListTile(
              contentPadding: EdgeInsets.zero,

              value: _isRecurring,

              onChanged: (v) {
                setState(() {
                  _isRecurring = v;
                });
              },

              title: const Text(
                AppStrings.recurring,
              ),

              secondary: const Icon(
                Icons.repeat_rounded,
                color: AppColors.primary,
              ),
            ),

            // --------------------------------------------------
            // Recurrence Options
            // --------------------------------------------------

            if (_isRecurring)
              Padding(
                padding: const EdgeInsets.only(
                  top: AppSizes.paddingSm,
                ),

                child: Wrap(
                  spacing: AppSizes.paddingSm,

                  children: RecurrenceType.values
                      .where(
                        (r) =>
                            r != RecurrenceType.none,
                      )
                      .map((r) {
                    return CategoryChip(
                      label: r.label,

                      isSelected:
                          _recurrenceType == r,

                      onTap: () {
                        setState(() {
                          _recurrenceType = r;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),

            const SizedBox(
              height: AppSizes.paddingXl,
            ),

            // --------------------------------------------------
            // Save Button
            // --------------------------------------------------

            CustomButton(
              label: AppStrings.save,

              isLoading:
                  controllerState.isLoading,

              onPressed: _handleSave,
            ),
          ],
        ),
      ),
    );
  }
}