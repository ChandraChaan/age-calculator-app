import 'package:agely/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders Agely home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const AgelyApp());

    expect(find.text('Agely'), findsOneWidget);
    expect(find.text('Age Calculator'), findsOneWidget);
    expect(find.text('Calculate Age'), findsOneWidget);
  });
}
