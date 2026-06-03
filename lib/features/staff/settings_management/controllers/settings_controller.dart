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
  final Rxn<StaffSettingsProfileModel> profile =
      Rxn<StaffSettingsProfileModel>();
  final RxString selectedLanguage = 'VN'.obs;

  final RxBool isScheduleLoading = false.obs;
  final RxString scheduleErrorMessage = ''.obs;
  final RxList<StaffScheduleDayModel> scheduleDays =
      <StaffScheduleDayModel>[].obs;

  final RxBool isAvailableShiftLoading = false.obs;
  final RxString availableShiftErrorMessage = ''.obs;
  final RxList<StaffScheduleDayModel> availableShiftDays =
      <StaffScheduleDayModel>[].obs;

  final RxBool isSubmitting = false.obs;

  final List<SettingsMenuItemModel> menuItems = const [
    SettingsMenuItemModel(
      id: 'edit-profile',
      title: 'Chỉnh sửa hồ sơ',
      iconCodePoint: 0xe163,
    ),
    SettingsMenuItemModel(
      id: 'language',
      title: 'Ngôn ngữ hiển thị',
      iconCodePoint: 0xe2d0,
      showChevron: false,
    ),
    SettingsMenuItemModel(
      id: 'work-schedule',
      title: 'Lịch làm việc',
      iconCodePoint: 0xe935,
    ),
    SettingsMenuItemModel(
      id: 'register-shift',
      title: 'Đăng ký lịch làm việc',
      iconCodePoint: 0xebcc,
    ),
    SettingsMenuItemModel(
      id: 'security',
      title: 'Bảo mật & Mật khẩu',
      iconCodePoint: 0xe73d,
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
    } catch (error) {
      errorMessage.value = SettingsService.errorMessage(error);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMySchedule() async {
    isScheduleLoading.value = true;
    scheduleErrorMessage.value = '';

    try {
      final result = await _settingsService.getMySchedule();
      scheduleDays.assignAll(result);
    } catch (error) {
      scheduleErrorMessage.value = SettingsService.errorMessage(error);
    } finally {
      isScheduleLoading.value = false;
    }
  }

  Future<void> loadAvailableShiftsForWeek(DateTime weekStart) async {
    isAvailableShiftLoading.value = true;
    availableShiftErrorMessage.value = '';

    try {
      final result = await _settingsService.getAvailableShiftsForWeek(weekStart);
      availableShiftDays.assignAll(result);
    } catch (error) {
      availableShiftErrorMessage.value = SettingsService.errorMessage(error);
    } finally {
      isAvailableShiftLoading.value = false;
    }
  }

  Future<void> registerShift({
    required int shiftId,
    required DateTime date,
  }) async {
    await _settingsService.registerShift(shiftId: shiftId, date: date);
    await loadProfile();
    await loadMySchedule();
  }

  Future<void> cancelShift(int staffShiftId) async {
    await _settingsService.cancelShift(staffShiftId);
    await loadProfile();
    await loadMySchedule();
  }

  Future<void> updateProfile({
    required String fullname,
    required String email,
    required String phone,
    required String address,
  }) async {
    isSubmitting.value = true;
    try {
      await _settingsService.updateProfile(
        fullname: fullname,
        email: email,
        phone: phone,
        address: address,
      );
      await loadProfile();
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    isSubmitting.value = true;
    try {
      await _settingsService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  void changeLanguage(String value) {
    selectedLanguage.value = value;
  }
}