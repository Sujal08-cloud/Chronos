import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize in main.dart before use');
});

class ThemeController extends StateNotifier<bool> {
  final SharedPreferences _prefs;
  static const _key = 'isDarkMode';

  ThemeController(this._prefs) : super(_prefs.getBool(_key) ?? false);

  Future<void> toggleTheme(bool isDark) async {
    state = isDark;
    await _prefs.setBool(_key, isDark);
  }
}

final themeControllerProvider = StateNotifierProvider<ThemeController, bool>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return ThemeController(prefs);
});