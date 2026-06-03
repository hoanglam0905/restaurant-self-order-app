import 'package:flutter_test/flutter_test.dart';
import 'package:self_ordering_restaurant/features/customer/settings/data/models/customer_settings_profile.dart';

void main() {
  group('CustomerSettingsProfile', () {
    test('parses customer response payload', () {
      final profile = CustomerSettingsProfile.fromJson({
        'customerId': 7,
        'fullname': 'Nguyen Van A',
        'points': 120,
        'joinDate': '2026-06-03T10:15:30.000Z',
      });

      expect(profile.customerId, 7);
      expect(profile.fullName, 'Nguyen Van A');
      expect(profile.points, 120);
      expect(profile.joinDate, isNotNull);
    });

    test('keeps backend update payload keys', () {
      final profile = CustomerSettingsProfile(
        customerId: 7,
        fullName: 'Nguyen Van A',
        points: 120,
        joinDate: DateTime.utc(2026, 6, 3),
      );

      expect(profile.toUpdateJson(fullName: 'Tran Van B'), {
        'fullname': 'Tran Van B',
        'joinDate': '2026-06-03T00:00:00.000Z',
        'points': 120,
      });
    });
  });
}
