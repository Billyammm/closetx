import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:closetx/main.dart';

void main() {
  testWidgets('renders the ClosetX splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ClosetXApp());

    expect(find.text('ClosetX'), findsOneWidget);
    expect(find.text('Your Virtual Fashion Studio'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
