// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:discipline_cmci/main.dart';
import 'package:discipline_cmci/providers/discipline_state.dart';

void main() {
  testWidgets('Discipline app smoke test', (WidgetTester tester) async {
    final state = DisciplineState();
    await tester.pumpWidget(DisciplineCmciApp(state: state));
    expect(find.byType(DisciplineCmciApp), findsOneWidget);
  });
}
