import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/services/chatbot_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});

  Map<String, dynamic> toJson() => {
        'text': text,
        'user': isUser,
      };
}

class ChatbotController extends GetxController {
  late final ChatbotService _chatbotService;
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final RxList<ChatMessage> messages = <ChatMessage>[
    ChatMessage(
      text: 'Dạ nhà hàng Bon Appetit xin chào anh/chị ạ! Em là trợ lý ảo, anh/chị cần tư vấn món hay hỗ trợ gì không ạ?',
      isUser: false,
    ),
  ].obs;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    try {
      _chatbotService = ChatbotService();
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }

  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  Future<void> sendMessage() async {
    if (errorMessage.isNotEmpty) return;

    final text = textController.text.trim();
    if (text.isEmpty) return;

    textController.clear();
    
    final history = messages.map((m) => m.toJson()).toList();
    
    messages.add(ChatMessage(text: text, isUser: true));
    _scrollToBottom();

    isLoading.value = true;
    try {
      final response = await _chatbotService.sendMessage(text, history);
      if (response != null && response.isNotEmpty) {
        messages.add(ChatMessage(text: response.trim(), isUser: false));
      }
    } catch (e) {
      messages.add(
        ChatMessage(
          text: 'Dạ xin lỗi anh/chị, hiện tại em đang gặp chút sự cố mạng. Anh/chị vui lòng thử lại sau nhé!',
          isUser: false,
        ),
      );
    } finally {
      isLoading.value = false;
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}

