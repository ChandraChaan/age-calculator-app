import 'package:agely/core/theme/app_theme.dart';
import 'package:agely/features/age_calculator/presentation/widgets/reminder_dialog.dart';
import 'package:agely/features/age_calculator/presentation/widgets/reminder_list_tile.dart';
import 'package:agely/features/age_calculator/services/reminder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the save reminder dialog fields', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildTestApp(child: ReminderDialog(targetDate: DateTime(2026, 11, 15))),
    );

    expect(find.text('Save Reminder'), findsNWidgets(2));
    expect(find.text('Want to save this date?'), findsOneWidget);
    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Category'), findsOneWidget);
    expect(find.text('Repeat'), findsOneWidget);
    expect(find.text('Reminder Style'), findsOneWidget);
  });

  testWidgets('renders a reminder list tile with metadata and actions', (
    WidgetTester tester,
  ) async {
    final reminder = Reminder(
      id: 'birthday',
      notificationId: 10,
      title: 'Birthday Reminder',
      category: 'Personal',
      targetDate: DateTime(2026, 11, 15),
      repeat: ReminderRepeat.yearly,
      style: ReminderStyle.oneWeekBefore,
      createdAt: DateTime(2026, 7, 5),
    );

    await tester.pumpWidget(
      _buildTestApp(
        child: ReminderListTile(
          reminder: reminder,
          referenceDate: DateTime(2026, 7, 5),
          onEdit: () {},
          onDelete: () {},
        ),
      ),
    );

    expect(find.text('Birthday Reminder'), findsOneWidget);
    expect(find.text('Personal'), findsOneWidget);
    expect(find.textContaining('Next alert:'), findsOneWidget);
    expect(find.textContaining('Event date:'), findsOneWidget);
    expect(find.byTooltip('Edit reminder'), findsOneWidget);
    expect(find.byTooltip('Delete reminder'), findsOneWidget);
  });
}

Widget _buildTestApp({required Widget child}) {
  return MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(body: Center(child: child)),
  );
}
