import 'package:agely/core/theme/app_theme.dart';
import 'package:agely/features/age_calculator/presentation/age_calculator_controller.dart';
import 'package:agely/features/age_calculator/presentation/home_page.dart';
import 'package:agely/features/age_calculator/services/reminder.dart';
import 'package:agely/features/age_calculator/services/reminder_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('renders the reminder section on the single page', (
    WidgetTester tester,
  ) async {
    final controller = AgeCalculatorController(
      reminderStorageService: _FakeReminderStorageService(),
      now: () => DateTime(2026, 7, 5),
    );

    await controller.initialize();

    await tester.pumpWidget(_buildTestApp(controller));

    expect(find.text('Agely'), findsOneWidget);
    expect(find.text('Upcoming Reminders'), findsOneWidget);
    expect(find.text('No reminders saved yet.'), findsOneWidget);
  });

  testWidgets('opens the save reminder dialog after a calculation', (
    WidgetTester tester,
  ) async {
    final controller = AgeCalculatorController(
      reminderStorageService: _FakeReminderStorageService(),
      now: () => DateTime(2026, 7, 5),
    );

    await controller.initialize();
    controller.updateStartDate(DateTime(1997, 11, 15));
    controller.calculate();

    await tester.pumpWidget(_buildTestApp(controller));

    final saveReminderButton = find.widgetWithText(
      FilledButton,
      'Save Reminder',
    );
    await tester.ensureVisible(saveReminderButton);
    await tester.tap(saveReminderButton);
    await tester.pumpAndSettle();

    final dialogFinder = find.byType(AlertDialog);

    expect(dialogFinder, findsOneWidget);
    expect(
      find.descendant(
        of: dialogFinder,
        matching: find.text('Want to save this date?'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: dialogFinder, matching: find.text('Title')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: dialogFinder, matching: find.text('Category')),
      findsOneWidget,
    );
  });
}

Widget _buildTestApp(AgeCalculatorController controller) {
  return ChangeNotifierProvider<AgeCalculatorController>.value(
    value: controller,
    child: MaterialApp(theme: AppTheme.light(), home: const HomePage()),
  );
}

class _FakeReminderStorageService extends ReminderStorageService {
  @override
  Future<List<Reminder>> loadReminders() async {
    return <Reminder>[];
  }
}
