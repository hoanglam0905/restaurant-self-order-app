import 'package:dio/dio.dart';
import '../../../../../core/network/api_client.dart';

class ChatbotService {
  final ApiClient _apiClient;

  ChatbotService() : _apiClient = ApiClient();

  Future<String?> sendMessage(String message, List<Map<String, dynamic>> history) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/chatbot/ask',
        data: {
          'message': message,
          'history': history,
        },
      );

      if (response.data != null && response.data['reply'] != null) {
        return response.data['reply'];
      }
      return null;
    } on DioException catch (e) {
      throw Exception('Lỗi kết nối AI: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi hệ thống: $e');
    }
  }
}
