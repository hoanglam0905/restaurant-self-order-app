import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:self_ordering_restaurant/app/app.dart';

void main() {
  testWidgets('Home screen renders core sections', (WidgetTester tester) async {
    await tester.pumpWidget(const RestaurantApp());

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Up to 40% OFF'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.text("Today's Special"), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
  });
}
