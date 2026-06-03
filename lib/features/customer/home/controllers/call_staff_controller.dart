import 'package:get/get.dart';

import '../../../../../core/storage/auth_session_storage.dart';
import '../../../../../core/storage/table_session_storage.dart';
import '../data/models/call_staff_request_model.dart';
import '../data/services/home_notification_service.dart';

class CallStaffController extends GetxController {
  CallStaffController({
    required HomeNotificationService notificationService,
    AuthSessionStorage? authSessionStorage,
    TableSessionStorage? tableSessionStorage,
  }) : _notificationService = notificationService,
       _authSessionStorage = authSessionStorage ?? AuthSessionStorage(),
       _tableSessionStorage = tableSessionStorage ?? TableSessionStorage();

  final HomeNotificationService _notificationService;
  final AuthSessionStorage _authSessionStorage;
  final TableSessionStorage _tableSessionStorage;

  final RxBool isSending = false.obs;
  final RxString errorMessage = ''.obs;

  Future<bool> callStaff(String requirement) async {
    final customerSession = await _authSessionStorage.readCustomerSession();
    if (customerSession == null) {
      errorMessage.value = 'Vui lòng đăng nhập để gọi nhân viên.';
      return false;
    }

    final tableId = await _tableSessionStorage.readTableId();
    if (tableId == null || tableId <= 0) {
      errorMessage.value = 'Vui lòng quét QR bàn trước khi gọi nhân viên.';
      return false;
    }

    final normalizedRequirement = requirement.trim();
    final message = normalizedRequirement.isEmpty
        ? 'Khách cần nhân viên hỗ trợ tại bàn.'
        : normalizedRequirement;

    isSending.value = true;
    errorMessage.value = '';

    try {
      await _notificationService.callStaff(
        CallStaffRequestModel(
          tableNumber: tableId,
          customerId: customerSession.customerId,
          additionalMessage: message,
        ),
      );
      return true;
    } on HomeNotificationException catch (error) {
      errorMessage.value = error.message;
      return false;
    } catch (_) {
      errorMessage.value = 'Không thể gửi yêu cầu gọi nhân viên.';
      return false;
    } finally {
      isSending.value = false;
    }
  }
}
