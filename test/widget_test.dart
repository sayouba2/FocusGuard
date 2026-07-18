import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:focusguard/main.dart';

void main() {
  testWidgets('renders the FocusGuard home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const FocusGuardApp());

    expect(find.text('FocusGuard'), findsWidgets);
    expect(find.text('Focus session'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Roadmap issues'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Roadmap issues'), findsOneWidget);
  });
}
