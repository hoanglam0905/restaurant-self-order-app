import 'package:flutter_test/flutter_test.dart';
import 'package:self_ordering_restaurant/features/staff/table_management/data/models/table_order_model.dart';

void main() {
  group('TableOrderModel table release rule', () {
    test(
      'allows release only when paid and all items are completed or cancelled',
      () {
        final order = TableOrderModel.fromJson({
          'orderId': 12,
          'customerName': 'Guest',
          'tableNumber': 3,
          'status': 'PROCESSING',
          'paymentStatus': 'PAID',
          'totalAmount': 250000,
          'items': [
            {
              'dishId': 1,
              'dishName': 'Soup',
              'quantity': 1,
              'status': 'COMPLETED',
            },
            {
              'dishId': 2,
              'dishName': 'Salad',
              'quantity': 1,
              'status': 'CANCELLED',
            },
          ],
        });

        expect(order.areAllItemsCompletedOrCancelled, isTrue);
        expect(order.canReleaseTable, isTrue);
      },
    );

    test(
      'keeps table occupied when payment is unpaid even if all items are done',
      () {
        final order = TableOrderModel.fromJson({
          'orderId': 13,
          'customerName': 'Guest',
          'tableNumber': 4,
          'status': 'COMPLETED',
          'paymentStatus': 'UNPAID',
          'totalAmount': 150000,
          'items': [
            {
              'dishId': 1,
              'dishName': 'Soup',
              'quantity': 1,
              'status': 'COMPLETED',
            },
          ],
        });

        expect(order.areAllItemsCompletedOrCancelled, isTrue);
        expect(order.canReleaseTable, isFalse);
      },
    );

    test(
      'keeps table occupied when payment is paid but any item is pending',
      () {
        final order = TableOrderModel.fromJson({
          'orderId': 14,
          'customerName': 'Guest',
          'tableNumber': 5,
          'status': 'PROCESSING',
          'paymentStatus': 'PAID',
          'totalAmount': 150000,
          'items': [
            {
              'dishId': 1,
              'dishName': 'Soup',
              'quantity': 1,
              'status': 'PENDING',
            },
          ],
        });

        expect(order.areAllItemsCompletedOrCancelled, isFalse);
        expect(order.canReleaseTable, isFalse);
      },
    );
  });
}
