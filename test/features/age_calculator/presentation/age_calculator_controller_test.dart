import 'package:agely/features/age_calculator/presentation/age_calculator_controller.dart';
import 'package:agely/features/age_calculator/services/reminder.dart';
import 'package:agely/features/age_calculator/services/reminder_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AgeCalculatorController reminders', () {
    test('creates, updates, and deletes reminders', () async {
      final storageService = _FakeReminderStorageService();
      final controller = AgeCalculatorController(
        reminderStorageService: storageService,
        now: () => DateTime(2026, 7, 5),
      );

      await controller.initialize();
      controller.updateStartDate(DateTime(1997, 11, 15));
      controller.calculate();

      await controller.createReminder(
        title: 'Birthday Reminder',
        category: 'Personal',
        repeat: ReminderRepeat.yearly,
        style: ReminderStyle.oneWeekBefore,
        targetDate: controller.suggestedReminderDate!,
      );

      expect(controller.reminders, hasLength(1));
      expect(controller.upcomingReminders, hasLength(1));

      final reminder = controller.reminders.first;

      await controller.updateReminder(
        reminder: reminder,
        title: 'Family Birthday',
        category: 'Family',
        repeat: ReminderRepeat.yearly,
        style: ReminderStyle.oneDayBefore,
      );

      expect(controller.reminders.first.title, 'Family Birthday');
      expect(controller.reminders.first.category, 'Family');
      expect(controller.reminders.first.style, ReminderStyle.oneDayBefore);

      await controller.deleteReminder(controller.reminders.first);

      expect(controller.reminders, isEmpty);
      expect(storageService.savedReminders, isEmpty);
    });
  });
}

class _FakeReminderStorageService extends ReminderStorageService {
  List<Reminder> savedReminders = <Reminder>[];

  @override
  Future<List<Reminder>> loadReminders() async {
    return List<Reminder>.from(savedReminders);
  }

  @override
  Future<void> saveReminders(List<Reminder> reminders) async {
    savedReminders = List<Reminder>.from(reminders);
  }
}
