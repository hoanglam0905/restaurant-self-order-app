import 'package:flutter_test/flutter_test.dart';
import 'package:self_ordering_restaurant/features/customer/home/data/models/table_qr_payload.dart';

void main() {
  group('TableQrPayload', () {
    test('parses table deep link payload', () {
      final payload = TableQrPayload.tryParse(
        'selfordering://table?tableId=6&tableLabel=A6',
      );

      expect(payload, isNotNull);
      expect(payload!.tableId, 6);
      expect(payload.tableLabel, 'A6');
    });

    test('uses table id as fallback label', () {
      final payload = TableQrPayload.tryParse(
        'selfordering://table?tableId=12',
      );

      expect(payload, isNotNull);
      expect(payload!.tableId, 12);
      expect(payload.tableLabel, '12');
    });

    test('rejects invalid qr payloads', () {
      expect(TableQrPayload.tryParse('https://example.com/table/6'), isNull);
      expect(TableQrPayload.tryParse('selfordering://table?tableId=0'), isNull);
      expect(TableQrPayload.tryParse('selfordering://dish?tableId=6'), isNull);
    });
  });
}
