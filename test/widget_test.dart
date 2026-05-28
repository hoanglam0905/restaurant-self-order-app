import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:self_ordering_restaurant/app/app.dart';

void main() {
  testWidgets('Welcome screen renders app entry actions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RestaurantApp());

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('CHÀO MỪNG ĐẾN VỚI'), findsOneWidget);
    expect(find.text('Quét mã QR ngay!'), findsOneWidget);
    expect(find.text('Đăng ký'), findsOneWidget);
    expect(find.text('Google'), findsOneWidget);
    expect(find.text('Facebook'), findsOneWidget);
    expect(find.text('Đăng nhập'), findsOneWidget);

    await tester.ensureVisible(find.text('Đăng nhập'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Đăng nhập'));
    await tester.pumpAndSettle();

    expect(find.text('Chào mừng trở lại'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Mật khẩu'), findsOneWidget);

    await tester.tap(find.text('Quên mật khẩu?'));
    await tester.pumpAndSettle();

    expect(find.text('Quên mật khẩu'), findsOneWidget);
    expect(find.text('Gửi mã xác nhận'), findsOneWidget);
  });

  testWidgets('Welcome screen opens register screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RestaurantApp());

    await tester.tap(find.text('Đăng ký'));
    await tester.pumpAndSettle();

    expect(find.text('Tạo tài khoản'), findsOneWidget);
    expect(find.text('HỌ VÀ TÊN'), findsOneWidget);
    expect(find.text('XÁC NHẬN MẬT KHẨU'), findsOneWidget);
  });
}
