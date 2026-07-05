import 'package:agely/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the Agely single-page experience', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AgelyApp());

    expect(find.text('Agely'), findsOneWidget);
    expect(find.text('Age Calculator'), findsOneWidget);
    expect(find.text('Start Date'), findsOneWidget);
    expect(find.text('End Date'), findsOneWidget);
    expect(find.text('Calculate'), findsOneWidget);
    expect(find.text('Results'), findsOneWidget);
  });

  testWidgets('shows a validation error when start date is missing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AgelyApp());

    await tester.tap(find.text('Calculate'));
    await tester.pumpAndSettle();

    expect(find.text('Select a start date to continue.'), findsOneWidget);
  });
}
