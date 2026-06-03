import '../models/staff_settings_profile_model.dart';

class SettingsService {
  const SettingsService();

  Future<StaffSettingsProfileModel> getProfile() async {
    await Future<void>.delayed(const Duration(milliseconds: 220));

    return const StaffSettingsProfileModel(
      fullName: 'Trần Thị Mỹ Dung',
      staffCode: 'NV#0001',
      roleName: 'Nhân viên phục vụ',
      email: 'MXD1234@gmail.com',
      phoneNumber: '+84 987654321',
      address: '448 Lê Văn Việt, Quận 9, TP.HCM',
      salaryDisplay: r'$390,08',
      currentShiftName: 'Ca 01',
      currentShiftTime: '7:00am - 1:00pm',
      appVersion: 'PHIÊN BẢN 2.4.0 · GOURMET DIRECT',
      avatarAssetPath: 'assets/images/auth/login_logo.png',
    );
  }
}
