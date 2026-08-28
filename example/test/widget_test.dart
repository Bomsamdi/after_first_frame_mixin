import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the dialog after the first frame', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Hello World'), findsOneWidget);

    await tester.tap(find.text('DISMISS'));
    await tester.pumpAndSettle();
    expect(find.text('Hello World'), findsNothing);
  });

  testWidgets('measures the box after the next frame', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('DISMISS'));
    await tester.pumpAndSettle();

    expect(find.text('not measured yet'), findsOneWidget);

    await tester.tap(find.text('Grow, then measure after next frame'));
    await tester.pumpAndSettle();

    expect(find.text('measured after next frame: 160 x 48'), findsOneWidget);
  });
}
