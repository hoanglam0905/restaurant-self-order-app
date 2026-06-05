import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:self_ordering_restaurant/core/config/api_config.dart';
import '../models/attendance_response.dart';

class AttendanceService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: '${ApiConfig.baseUrl}/attendance',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 120),
  ));
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<AttendanceResponse> checkIn(XFile imageFile) async {
    return _callFaceApi('/check-in-camera', imageFile);
  }

  Future<AttendanceResponse> checkOut(XFile imageFile) async {
    return _callFaceApi('/check-out-camera', imageFile);
  }

  Future<AttendanceResponse> _callFaceApi(String path, XFile imageFile) async {
    try {
      final token = await _storage.read(key: 'accessToken');
      if (token == null) {
        throw Exception('Vui lòng đăng nhập lại.');
      }

      final bytes = await imageFile.readAsBytes();

      final formData = FormData.fromMap({
        'image': MultipartFile.fromBytes(
          bytes,
          filename: imageFile.name.isEmpty ? 'face_scan.jpg' : imageFile.name,
        ),
      });

      final response = await _dio.post(
        path,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      return AttendanceResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          throw Exception(data['message']);
        }
      }
      throw Exception('Lỗi kết nối máy chủ: ${e.message}');
    } catch (e) {
      throw Exception('Đã xảy ra lỗi: $e');
    }
  }
}
