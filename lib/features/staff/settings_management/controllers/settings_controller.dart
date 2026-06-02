import 'package:get/get.dart';

import '../data/models/settings_menu_item_model.dart';
import '../data/models/staff_settings_profile_model.dart';
import '../data/services/settings_service.dart';

class SettingsController extends GetxController {
  SettingsController({required SettingsService settingsService})
      : _settingsService = settingsService;

  final SettingsService _settingsService;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rxn<StaffSettingsProfileModel> profile = Rxn<StaffSettingsProfileModel>();
  final RxString selectedLanguage = 'VN'.obs;

  final List<SettingsMenuItemModel> menuItems = const [
    SettingsMenuItemModel(
      id: 'edit-profile',
      title: 'Chỉnh sửa hồ sơ',
      iconCodePoint: 0xe163, // Icons.edit_note_rounded
    ),
    SettingsMenuItemModel(
      id: 'language',
      title: 'Ngôn ngữ hiển thị',
      iconCodePoint: 0xe2d0, // Icons.language_rounded
      showChevron: false,
    ),
    SettingsMenuItemModel(
      id: 'work-schedule',
      title: 'Lịch làm việc',
      iconCodePoint: 0xe935, // Icons.calendar_month_rounded
    ),
    SettingsMenuItemModel(
      id: 'register-shift',
      title: 'Đăng ký lịch làm việc',
      iconCodePoint: 0xebcc, // Icons.fact_check_rounded
    ),
    SettingsMenuItemModel(
      id: 'security',
      title: 'Bảo mật & Mật khẩu',
      iconCodePoint: 0xe73d, // Icons.vpn_key_rounded
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      profile.value = await _settingsService.getProfile();
    } catch (_) {
      errorMessage.value = 'Không thể tải thông tin cài đặt.';
    } finally {
      isLoading.value = false;
    }
  }

  void changeLanguage(String value) {
    selectedLanguage.value = value;
  }
}
