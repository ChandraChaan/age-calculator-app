import 'dart:convert';

import 'package:agely/features/age_calculator/services/reminder.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReminderStorageService {
  static const String _remindersKey = 'agely.reminders';
  static const String _themeModeKey = 'agely.theme_mode';

  const ReminderStorageService();

  Future<List<Reminder>> loadReminders() async {
    final preferences = await SharedPreferences.getInstance();
    final encodedReminders =
        preferences.getStringList(_remindersKey) ?? <String>[];

    return encodedReminders.map((encodedReminder) {
        final json = jsonDecode(encodedReminder) as Map<String, dynamic>;
        return Reminder.fromJson(json);
      }).toList()
      ..sort((left, right) => left.createdAt.compareTo(right.createdAt));
  }

  Future<void> saveReminders(List<Reminder> reminders) async {
    final preferences = await SharedPreferences.getInstance();
    final encodedReminders = reminders
        .map((reminder) => jsonEncode(reminder.toJson()))
        .toList(growable: false);

    await preferences.setStringList(_remindersKey, encodedReminders);
  }

  Future<ThemeMode> loadThemeMode() async {
    final preferences = await SharedPreferences.getInstance();
    final storedValue = preferences.getString(_themeModeKey);

    if (storedValue == null) {
      return ThemeMode.system;
    }

    return ThemeMode.values.firstWhere(
      (mode) => mode.name == storedValue,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> saveThemeMode(ThemeMode themeMode) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_themeModeKey, themeMode.name);
  }
}
