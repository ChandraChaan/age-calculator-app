import 'package:agely/features/age_calculator/services/reminder.dart';
import 'package:agely/features/age_calculator/services/reminder_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const storageService = ReminderStorageService();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('saves and loads reminders from local storage', () async {
    final reminders = <Reminder>[
      Reminder(
        id: 'birthday',
        notificationId: 101,
        title: 'Birthday Reminder',
        category: 'Personal',
        targetDate: DateTime(2026, 11, 15),
        repeat: ReminderRepeat.yearly,
        style: ReminderStyle.oneWeekBefore,
        createdAt: DateTime(2026, 1, 1),
      ),
    ];

    await storageService.saveReminders(reminders);
    final loadedReminders = await storageService.loadReminders();

    expect(loadedReminders, hasLength(1));
    expect(loadedReminders.first.title, 'Birthday Reminder');
    expect(loadedReminders.first.repeat, ReminderRepeat.yearly);
    expect(loadedReminders.first.style, ReminderStyle.oneWeekBefore);
  });

  test('persists theme mode values', () async {
    await storageService.saveThemeMode(ThemeMode.dark);

    final themeMode = await storageService.loadThemeMode();

    expect(themeMode, ThemeMode.dark);
  });
}
