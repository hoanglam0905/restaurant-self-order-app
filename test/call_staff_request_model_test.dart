import 'package:flutter_test/flutter_test.dart';
import 'package:self_ordering_restaurant/features/customer/home/data/models/call_staff_request_model.dart';

void main() {
  group('CallStaffRequestModel', () {
    test('serializes backend notification request', () {
      final request = CallStaffRequestModel(
        tableNumber: 6,
        customerId: 12,
        additionalMessage: 'Cần thêm nước lọc.',
      );

      expect(request.toJson(), {
        'tableNumber': 6,
        'customerId': 12,
        'orderId': null,
        'type': 'CALL_STAFF',
        'additionalMessage': 'Cần thêm nước lọc.',
      });
    });
  });
}
