import 'package:flutter_test/flutter_test.dart';
import 'package:self_ordering_restaurant/features/customer/home/data/models/call_staff_request_model.dart';

void main() {
  group('CallStaffRequestModel', () {
    test('serializes backend notification request', () {
      final request = CallStaffRequestModel(
        tableNumber: 6,
        customerId: 12,
        additionalMessage: 'Need more water.',
      );

      expect(request.toJson(), {
        'tableNumber': 6,
        'customerId': 12,
        'orderId': null,
        'type': 'CALL_STAFF',
        'additionalMessage': 'Need more water.',
      });
    });

    test('includes resolved customerId for guest notification request', () {
      final request = CallStaffRequestModel(
        tableNumber: 4,
        customerId: 31,
        orderId: null,
        additionalMessage: 'Need assistance.',
      );

      expect(request.toJson(), {
        'tableNumber': 4,
        'customerId': 31,
        'orderId': null,
        'type': 'CALL_STAFF',
        'additionalMessage': 'Need assistance.',
      });
    });
  });
}
