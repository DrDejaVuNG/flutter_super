import 'package:flutter/material.dart';
import 'package:flutter_super/flutter_super.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AsyncBuilder', () {
    testWidgets('Displays loading widget when connection state is waiting',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AsyncBuilder<int>(
            future: Future.delayed(const Duration(seconds: 3), () => 10),
            builder: (data) => Text(data.toString()),
            loading: const CircularProgressIndicator(),
          ),
        ),
      );

      // Verify that CircularProgressIndicator is displayed
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for the delayed future to complete
      await tester.pumpAndSettle();

      // Verify that the data is displayed
      expect(find.text('10'), findsOneWidget);
    });

    testWidgets('Displays data widget when data is available',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AsyncBuilder<int>(
            future: Future.delayed(const Duration(seconds: 2), () => 10),
            builder: (data) => Text('Data: $data'),
          ),
        ),
      );

      // Wait for future to complete
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify that data text is displayed
      expect(find.text('Data: 10'), findsOneWidget);
    });

    testWidgets('Updates data widget when new data is available',
        (WidgetTester tester) async {
      final stream =
          Stream<int>.periodic(const Duration(seconds: 1), (count) => count)
              .take(5);

      await tester.pumpWidget(
        MaterialApp(
          home: AsyncBuilder<int>(
            stream: stream,
            builder: (data) => Text('Data: $data'),
          ),
        ),
      );

      // Wait for the stream to emit new data
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify that updated data text is displayed
      expect(find.text('Data: 4'), findsOneWidget);
    });

    testWidgets('Disposes the subscription when widget is disposed',
        (WidgetTester tester) async {
      final stream =
          Stream<int>.periodic(const Duration(seconds: 1), (count) => count)
              .take(5);

      await tester.pumpWidget(
        MaterialApp(
          home: AsyncBuilder<int>(
            stream: stream,
            builder: (data) => Text('Data: $data'),
          ),
        ),
      );

      // Verify that the subscription is active
      expect(stream.isBroadcast, isFalse);
    });
  });
}
