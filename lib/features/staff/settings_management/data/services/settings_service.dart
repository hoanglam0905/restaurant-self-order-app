import 'package:dio/dio.dart';

import '../../../../../core/network/api_client.dart';
import '../../../../../core/storage/auth_session_storage.dart';
import '../models/staff_settings_profile_model.dart';

class SettingsService {
  SettingsService({
    required ApiClient apiClient,
    AuthSessionStorage? authSessionStorage,
  }) : _apiClient = apiClient,
       _authSessionStorage = authSessionStorage ?? AuthSessionStorage();

  final ApiClient _apiClient;
  final AuthSessionStorage _authSessionStorage;

  Future<StaffSettingsProfileModel> getProfile() async {
    final staffSession = await _authSessionStorage.readStaffSession();

    if (staffSession == null || staffSession.staffId <= 0) {
      throw const SettingsException(
        'Không tìm thấy staffId. Vui lòng đăng xuất rồi đăng nhập lại.',
      );
    }

    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      '/staff/${staffSession.staffId}',
    );

    final data = response.data ?? {};

    StaffShiftScheduleModel? currentShift;
    try {
      final scheduleDays = await getMySchedule();
      currentShift = _findCurrentOrNextShift(scheduleDays);
    } catch (_) {
      currentShift = null;
    }

    final staffId = _readInt(data, ['staffId', 'staff_id']);

    return StaffSettingsProfileModel(
      staffId: staffId,
      fullName: _readString(
        data,
        ['fullname', 'fullName'],
        fallback: staffSession.staffName ?? 'Nhân viên',
      ),
      staffCode: 'NV#${staffId.toString().padLeft(4, '0')}',
      roleName: _readString(data, ['position', 'role'], fallback: 'Nhân viên'),
      email: _readString(
        data,
        ['email'],
        fallback: staffSession.email ?? 'Chưa cập nhật',
      ),
      phoneNumber: _readString(data, ['phone', 'phoneNumber'], fallback: 'Chưa cập nhật'),
      address: 'BE hiện chưa có dữ liệu địa chỉ',
      salaryDisplay: _formatMoney(_readNum(data, ['salary'])),
      currentShiftName: currentShift?.shiftName ?? 'Chưa có ca',
      currentShiftTime: currentShift?.timeRange ?? 'Chưa có lịch làm',
      appVersion: 'PHIÊN BẢN 2.4.0 · GOURMET DIRECT',
      avatarAssetPath: 'assets/images/auth/login_logo.png',
    );
  }

  Future<List<StaffScheduleDayModel>> getMySchedule() async {
    final response = await _apiClient.dio.get('/staff/shifts/my-schedule');
    return _parseScheduleMap(response.data);
  }

  Future<List<StaffScheduleDayModel>> getAvailableShiftsForWeek(
    DateTime weekStart,
  ) async {
    final response = await _apiClient.dio.get(
      '/staff/shifts/available-week',
      queryParameters: {
        'weekStart': _apiDate(weekStart),
      },
    );

    return _parseScheduleMap(response.data);
  }

  Future<void> registerShift({
    required int shiftId,
    required DateTime date,
  }) async {
    await _apiClient.dio.post(
      '/staff/shifts/register',
      data: {
        'shiftId': shiftId,
        'date': _apiDate(date),
      },
    );
  }

  Future<void> cancelShift(int staffShiftId) async {
    await _apiClient.dio.delete('/staff/shifts/$staffShiftId');
  }

  Future<void> updateProfile({
    required String fullname,
    required String email,
    required String phone,
    required String address,
  }) async {
    throw const SettingsException(
      'BE hiện tại chưa có API cập nhật hồ sơ. Chức năng này chỉ có thể làm UI demo.',
    );
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    throw const SettingsException(
      'BE hiện tại chưa có API đổi mật khẩu khi đang đăng nhập.',
    );
  }

  StaffShiftScheduleModel? _findCurrentOrNextShift(
    List<StaffScheduleDayModel> days,
  ) {
    final now = DateTime.now();
    final allShifts = <StaffShiftScheduleModel>[];

    for (final day in days) {
      allShifts.addAll(day.shifts);
    }

    if (allShifts.isEmpty) {
      return null;
    }

    allShifts.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));

    for (final shift in allShifts) {
      if (!shift.endDateTime.isBefore(now)) {
        return shift;
      }
    }

    return allShifts.last;
  }

  List<StaffScheduleDayModel> _parseScheduleMap(Object? rawData) {
    if (rawData is! Map) {
      return const [];
    }

    final days = <StaffScheduleDayModel>[];

    for (final entry in rawData.entries) {
      final date = DateTime.tryParse(entry.key.toString());
      if (date == null) {
        continue;
      }

      final shifts = <StaffShiftScheduleModel>[];
      final rawShifts = entry.value;

      if (rawShifts is List) {
        for (final item in rawShifts) {
          if (item is Map) {
            shifts.add(
              StaffShiftScheduleModel.fromJson(
                Map<String, dynamic>.from(item),
                date,
              ),
            );
          }
        }
      }

      days.add(StaffScheduleDayModel(date: date, shifts: shifts));
    }

    days.sort((a, b) => a.date.compareTo(b.date));
    return days;
  }

  int _readInt(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];

      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
      }
    }

    return 0;
  }

  num _readNum(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];

      if (value is num) return value;
      if (value is String) {
        final parsed = num.tryParse(value);
        if (parsed != null) return parsed;
      }
    }

    return 0;
  }

  String _readString(
    Map<String, dynamic> data,
    List<String> keys, {
    String fallback = '',
  }) {
    for (final key in keys) {
      final value = data[key];

      if (value == null) continue;

      final text = value.toString().trim();
      if (text.isNotEmpty) {
        return text;
      }
    }

    return fallback;
  }

  String _formatMoney(num value) {
    final rounded = value.round().toString();
    final buffer = StringBuffer();

    for (var i = 0; i < rounded.length; i++) {
      final reverseIndex = rounded.length - i;
      buffer.write(rounded[i]);

      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write(',');
      }
    }

    return '${buffer.toString()} đ';
  }

  static String errorMessage(Object error) {
    if (error is SettingsException) {
      return error.message;
    }

    if (error is DioException) {
      final data = error.response?.data;

      if (data is Map<String, dynamic>) {
        final message = data['message']?.toString();
        if (message != null && message.isNotEmpty) {
          return message;
        }
      }

      if (data is String && data.trim().isNotEmpty) {
        return data;
      }

      final statusCode = error.response?.statusCode;
      return switch (statusCode) {
        400 => 'Dữ liệu không hợp lệ.',
        401 => 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
        403 => 'Bạn không có quyền thực hiện thao tác này.',
        404 => 'Không tìm thấy dữ liệu.',
        500 => 'Máy chủ đang gặp lỗi. Vui lòng thử lại sau.',
        _ => 'Không thể kết nối máy chủ.',
      };
    }

    return 'Đã có lỗi xảy ra. Vui lòng thử lại.';
  }
}

class StaffScheduleDayModel {
  const StaffScheduleDayModel({
    required this.date,
    required this.shifts,
  });

  final DateTime date;
  final List<StaffShiftScheduleModel> shifts;

  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String get weekdayLabel {
    return switch (date.weekday) {
      DateTime.monday => 'Thứ 2',
      DateTime.tuesday => 'Thứ 3',
      DateTime.wednesday => 'Thứ 4',
      DateTime.thursday => 'Thứ 5',
      DateTime.friday => 'Thứ 6',
      DateTime.saturday => 'Thứ 7',
      DateTime.sunday => 'Chủ nhật',
      _ => '',
    };
  }

  String get dateLabel {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }
}

class StaffShiftScheduleModel {
  const StaffShiftScheduleModel({
    required this.date,
    required this.shiftId,
    required this.shiftName,
    required this.startTime,
    required this.endTime,
    this.status,
    this.staffShiftId,
  });

  factory StaffShiftScheduleModel.fromJson(
    Map<String, dynamic> json,
    DateTime date,
  ) {
    return StaffShiftScheduleModel(
      date: date,
      staffShiftId: _toInt(json['staffShiftId']),
      shiftId: _toInt(json['shiftId']) ?? 0,
      shiftName:
          json['shiftName']?.toString() ?? json['name']?.toString() ?? 'Ca làm',
      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString() ?? '',
      status: json['status']?.toString(),
    );
  }

  final DateTime date;
  final int? staffShiftId;
  final int shiftId;
  final String shiftName;
  final String startTime;
  final String endTime;
  final String? status;

  String get timeRange => '${_normalizeTime(startTime)} - ${_normalizeTime(endTime)}';

  DateTime get startDateTime => _dateTimeFromTime(startTime);

  DateTime get endDateTime => _dateTimeFromTime(endTime);

  DateTime _dateTimeFromTime(String value) {
    final parts = value.split(':');
    final hour = int.tryParse(parts.isNotEmpty ? parts[0] : '') ?? 0;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '') ?? 0;

    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  static int? _toInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static String _normalizeTime(String value) {
    if (value.isEmpty) {
      return '--:--';
    }

    final parts = value.split(':');
    if (parts.length >= 2) {
      return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
    }

    return value;
  }
}

class SettingsException implements Exception {
  const SettingsException(this.message);

  final String message;

  @override
  String toString() => message;
}

String _apiDate(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');

  return '$year-$month-$day';
}