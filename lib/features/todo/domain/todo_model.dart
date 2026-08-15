import 'package:chronos/features/todo/domain/reccurrence_type.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class TodoModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String category;
  final TaskPriority priority;
  final DateTime scheduledDate;
  final DateTime? scheduledTime;
  final bool isRecurring;
  final RecurrenceType recurrenceType;
  final bool hasAlarm;
  final bool isCompleted;
  final DateTime createdAt;

  TodoModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.scheduledDate,
    this.scheduledTime,
    required this.isRecurring,
    required this.recurrenceType,
    required this.hasAlarm,
    required this.isCompleted,
    required this.createdAt,
  });

  factory TodoModel.fromMap(String id, Map<String, dynamic> map) {
    return TodoModel(
      id: id,
      userId: map['userId'] as String,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? 'General',
      priority: TaskPriority.fromString(map['priority'] as String? ?? 'medium'),
      scheduledDate: (map['scheduledDate'] as Timestamp).toDate(),
      scheduledTime: map['scheduledTime'] != null
          ? (map['scheduledTime'] as Timestamp).toDate()
          : null,
      isRecurring: map['isRecurring'] as bool? ?? false,
      recurrenceType: RecurrenceType.fromString(map['recurrenceType'] as String? ?? 'none'),
      hasAlarm: map['hasAlarm'] as bool? ?? false,
      isCompleted: map['isCompleted'] as bool? ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority.name,
      'scheduledDate': Timestamp.fromDate(scheduledDate),
      'scheduledTime': scheduledTime != null ? Timestamp.fromDate(scheduledTime!) : null,
      'isRecurring': isRecurring,
      'recurrenceType': recurrenceType.name,
      'hasAlarm': hasAlarm,
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  TodoModel copyWith({
    String? title,
    String? description,
    String? category,
    TaskPriority? priority,
    DateTime? scheduledDate,
    DateTime? scheduledTime,
    bool? isRecurring,
    RecurrenceType? recurrenceType,
    bool? hasAlarm,
    bool? isCompleted,
  }) {
    return TodoModel(
      id: id,
      userId: userId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      hasAlarm: hasAlarm ?? this.hasAlarm,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
    );
  }
}