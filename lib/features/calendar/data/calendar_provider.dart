import 'package:flutter_riverpod/legacy.dart';

final focusedDayProvider = StateProvider<DateTime>((ref) => DateTime.now());
final selectedDayProvider = StateProvider<DateTime>((ref) => DateTime.now());