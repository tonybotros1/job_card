// Basic sanity test: the project's screens need Firebase, so this only checks
// that the test harness and the app's constants load.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_card/const.dart';

void main() {
  testWidgets('brand colours render', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: Container(color: mainColor, child: const Text('ok'))),
    ));
    expect(find.text('ok'), findsOneWidget);
  });
}
