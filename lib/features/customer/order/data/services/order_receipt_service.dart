import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../../../core/network/api_client.dart';
import '../../../../../core/utils/pdf_file_saver.dart';

class OrderReceiptService {
  const OrderReceiptService(this._apiClient);

  final ApiClient _apiClient;

  Future<String> exportReceiptPdf(int orderId) async {
    try {
      final response = await _apiClient.dio.get<List<int>>(
        '/receipts/generate/$orderId',
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = response.data;
      if (bytes == null || bytes.isEmpty) {
        throw const OrderReceiptException('File hóa đơn đang trống.');
      }

      final fileName = 'receipt-order-$orderId.pdf';
      final savedPath = await saveAndOpenPdfBytes(
        bytes: Uint8List.fromList(bytes),
        fileName: fileName,
      );
      if (savedPath == null || savedPath.isEmpty) {
        throw const OrderReceiptException('Không thể lưu file hóa đơn PDF.');
      }

      return savedPath;
    } on OrderReceiptException {
      rethrow;
    } on DioException catch (error) {
      throw OrderReceiptException(_messageFromDio(error));
    } catch (_) {
      throw const OrderReceiptException('Không thể xuất hóa đơn PDF.');
    }
  }

  String _messageFromDio(DioException error) {
    final statusCode = error.response?.statusCode;
    return switch (statusCode) {
      400 => 'Thông tin hóa đơn chưa hợp lệ.',
      401 => 'Vui lòng đăng nhập lại để in hóa đơn.',
      403 => 'Bạn không có quyền in hóa đơn này.',
      404 => 'Không tìm thấy hóa đơn.',
      500 => 'Máy chủ chưa thể tạo file hóa đơn PDF.',
      _ => 'Không thể kết nối đến máy chủ nhà hàng.',
    };
  }
}

class OrderReceiptException implements Exception {
  const OrderReceiptException(this.message);

  final String message;

  @override
  String toString() => message;
}
