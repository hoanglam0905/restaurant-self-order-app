import 'package:get/get.dart';

import '../../../../../core/storage/auth_session_storage.dart';
import '../../../../../core/storage/table_session_storage.dart';
import '../../../../../core/storage/token_storage.dart';
import '../data/models/customer_settings_profile.dart';
import '../data/services/customer_settings_service.dart';

class CustomerSettingsController extends GetxController {
  CustomerSettingsController({
    required CustomerSettingsService settingsService,
    AuthSessionStorage? authSessionStorage,
    TableSessionStorage? tableSessionStorage,
    TokenStorage? tokenStorage,
  }) : _settingsService = settingsService,
       _authSessionStorage = authSessionStorage ?? AuthSessionStorage(),
       _tableSessionStorage = tableSessionStorage ?? TableSessionStorage(),
       _tokenStorage = tokenStorage ?? TokenStorage();

  final CustomerSettingsService _settingsService;
  final AuthSessionStorage _authSessionStorage;
  final TableSessionStorage _tableSessionStorage;
  final TokenStorage _tokenStorage;

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isLoggingOut = false.obs;
  final RxString errorMessage = ''.obs;
  final Rxn<CustomerSettingsProfile> profile = Rxn<CustomerSettingsProfile>();
  final Rxn<CustomerSession> customerSession = Rxn<CustomerSession>();
  final RxnInt tableId = RxnInt();
  final RxnString tableLabel = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  Future<void> loadSettings() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final session = await _authSessionStorage.readCustomerSession();
      customerSession.value = session;
      tableId.value = await _tableSessionStorage.readTableId();
      tableLabel.value = await _tableSessionStorage.readTableLabel();

      if (session == null) {
        profile.value = null;
        return;
      }

      profile.value = await _settingsService.getProfile(session.customerId);
    } on CustomerSettingsException catch (error) {
      errorMessage.value = error.message;
    } catch (_) {
      errorMessage.value = 'Không thể tải trang cài đặt.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateFullName(String value) async {
    final normalizedName = value.trim();
    if (normalizedName.length < 2) {
      errorMessage.value = 'Tên hiển thị cần có ít nhất 2 ký tự.';
      return false;
    }

    final currentProfile = profile.value;
    final session = customerSession.value;
    if (currentProfile == null || session == null) {
      errorMessage.value = 'Vui lòng đăng nhập để cập nhật tài khoản.';
      return false;
    }

    isSaving.value = true;
    errorMessage.value = '';
    try {
      final updatedProfile = await _settingsService.updateProfileName(
        profile: currentProfile,
        fullName: normalizedName,
      );
      profile.value = updatedProfile;
      await _authSessionStorage.saveAuthProfile(
        userType: 'CUSTOMER',
        customerId: updatedProfile.customerId,
        customerName: updatedProfile.fullName,
      );
      customerSession.value = CustomerSession(
        customerId: updatedProfile.customerId,
        customerName: updatedProfile.fullName,
      );
      return true;
    } on CustomerSettingsException catch (error) {
      errorMessage.value = error.message;
      return false;
    } catch (_) {
      errorMessage.value = 'Không thể cập nhật tài khoản.';
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> saveTableSession({
    required int tableId,
    required String tableLabel,
  }) async {
    await _tableSessionStorage.saveTableSession(
      tableId: tableId,
      tableLabel: tableLabel,
    );
    this.tableId.value = tableId;
    this.tableLabel.value = tableLabel;
  }

  Future<void> clearTableSession() async {
    await _tableSessionStorage.clear();
    tableId.value = null;
    tableLabel.value = null;
  }

  Future<bool> logout() async {
    isLoggingOut.value = true;
    errorMessage.value = '';
    try {
      await _settingsService.logout();
      await _clearLocalSession();
      return true;
    } on CustomerSettingsException catch (error) {
      errorMessage.value = error.message;
      await _clearLocalSession();
      return true;
    } catch (_) {
      errorMessage.value = 'Không thể đăng xuất khỏi máy chủ.';
      await _clearLocalSession();
      return true;
    } finally {
      isLoggingOut.value = false;
    }
  }

  Future<void> _clearLocalSession() async {
    await _tokenStorage.clear();
    await _authSessionStorage.clear();
    await _tableSessionStorage.clear();
    profile.value = null;
    customerSession.value = null;
    tableId.value = null;
    tableLabel.value = null;
  }
}
