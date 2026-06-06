import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_back_icon_button.dart';
import '../../../../core/widgets/app_cta_button.dart';
import '../../../../core/widgets/app_state_panel.dart';
import '../controllers/customer_feedback_controller.dart';
import '../data/models/customer_feedback_model.dart';
import '../data/services/customer_feedback_service.dart';

class CustomerFeedbackView extends StatefulWidget {
  const CustomerFeedbackView({
    required this.orderId,
    required this.earnedPoints,
    super.key,
  });

  final int orderId;
  final int earnedPoints;

  @override
  State<CustomerFeedbackView> createState() => _CustomerFeedbackViewState();
}

class _CustomerFeedbackViewState extends State<CustomerFeedbackView> {
  static const List<String> _positiveTags = [
    'Nhân viên nhiệt tình',
    'Món ăn ngon',
    'Sạch sẽ',
    'Không gian thoáng',
  ];
  static const List<String> _negativeTags = [
    'Nhân viên chưa thân thiện',
    'Khác',
    'Chưa hợp vệ sinh',
    'Món ăn chưa ngon',
  ];

  late final String _controllerTag;
  late final CustomerFeedbackController _controller;
  late final TextEditingController _commentController;
  final Set<String> _selectedTags = <String>{};
  int _rating = 5;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _controllerTag = 'customer-feedback-${widget.orderId}-${UniqueKey()}';
    _controller = Get.put(
      CustomerFeedbackController(
        feedbackService: CustomerFeedbackService(ApiClient()),
      ),
      tag: _controllerTag,
    );
    _commentController = TextEditingController();
    unawaited(_controller.loadExistingFeedback(widget.orderId));
  }

  @override
  void dispose() {
    _commentController.dispose();
    Get.delete<CustomerFeedbackController>(tag: _controllerTag);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      body: SafeArea(
        child: Obx(() {
          if (_controller.isLoadingExistingFeedback.value) {
            return const AppStatePanel(message: 'Dang kiem tra danh gia...');
          }

          final existingFeedback = _controller.existingFeedback.value;
          if (!_submitted && existingFeedback != null) {
            return _buildExistingFeedback(existingFeedback);
          }

          return _submitted ? _buildThanksPage() : _buildFeedbackForm();
        }),
      ),
    );
  }

  Widget _buildExistingFeedback(CustomerFeedbackModel feedback) {
    final satisfied = feedback.rating >= 4;
    final tags = feedback.selectedTags;
    final comment = feedback.displayComment;

    return Column(
      children: [
        _FeedbackTopBar(onBack: () => Navigator.pop(context, false)),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 24, 18, 24),
            children: [
              const Text(
                'Ban da danh gia don hang nay',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF161C23),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                satisfied ? 'Rat hai long' : 'Chua hai long',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              _StarRating(rating: feedback.rating, onChanged: null),
              if (tags.isNotEmpty) ...[
                const SizedBox(height: 18),
                _FeedbackTagWrap(
                  tags: tags,
                  selectedTags: tags.toSet(),
                  onToggle: (_) {},
                  enabled: false,
                ),
              ],
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 120),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF1F1F22)),
                ),
                child: Text(
                  comment.isEmpty
                      ? 'Khach hang khong de lai nhan xet.'
                      : comment,
                  style: const TextStyle(
                    color: Color(0xFF686267),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                  ),
                ),
              ),
              const SizedBox(height: 54),
              Center(
                child: SizedBox(
                  width: 120,
                  child: AppCtaButton(
                    label: 'XONG',
                    onPressed: () => Navigator.pop(context, false),
                    backgroundColor: Colors.black,
                    borderRadius: 6,
                    height: 44,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackForm() {
    final satisfied = _rating >= 4;
    final tags = satisfied ? _positiveTags : _negativeTags;

    return Column(
      children: [
        _FeedbackTopBar(onBack: () => Navigator.pop(context, false)),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 24, 18, 24),
            children: [
              Text(
                satisfied ? 'Rất hài lòng' : 'Chưa hài lòng',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF161C23),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 18),
              _StarRating(
                rating: _rating,
                onChanged: (rating) {
                  setState(() {
                    _rating = rating;
                    _selectedTags.clear();
                  });
                },
              ),
              const SizedBox(height: 18),
              Text(
                satisfied
                    ? 'Bạn thích điều gì ở dịch vụ?'
                    : 'Bạn chưa hài lòng điều gì?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF161C23),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 16),
              _FeedbackTagWrap(
                tags: tags,
                selectedTags: _selectedTags,
                onToggle: _toggleTag,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _commentController,
                minLines: 5,
                maxLines: 5,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: 'Giúp chúng tôi hiểu thêm',
                  hintStyle: const TextStyle(
                    color: Color(0xFFB5B0B3),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF1F1F22)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppColors.orderAccent,
                      width: 1.3,
                    ),
                  ),
                ),
              ),
              Obx(() {
                if (_controller.errorMessage.value.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: AppStatePanel(message: _controller.errorMessage.value),
                );
              }),
              const SizedBox(height: 54),
              Center(
                child: SizedBox(
                  width: 120,
                  child: Obx(
                    () => AppCtaButton(
                      label: _controller.isSubmitting.value
                          ? 'Đang gửi...'
                          : 'GỬI',
                      onPressed: _submit,
                      enabled: !_controller.isSubmitting.value,
                      backgroundColor: Colors.black,
                      borderRadius: 6,
                      height: 44,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThanksPage() {
    return Column(
      children: [
        const _FeedbackTopBar(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 42, 22, 24),
            children: [
              const Icon(
                Icons.restaurant_menu_rounded,
                color: Colors.black,
                size: 54,
              ),
              const SizedBox(height: 8),
              const Text(
                'Bon Appétit',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 34),
              const Text(
                'Cảm ơn bạn đã đánh giá!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF161C23),
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                widget.earnedPoints > 0
                    ? 'Bạn vừa được tích ${widget.earnedPoints} điểm cho đơn hàng này.'
                    : 'Điểm tích lũy của bạn đã được cập nhật sau thanh toán.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF8D888C),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 52),
              Icon(
                Icons.room_service_rounded,
                color: AppColors.orderAccent.withValues(alpha: 0.92),
                size: 92,
              ),
              const SizedBox(height: 54),
              Center(
                child: SizedBox(
                  width: 120,
                  child: AppCtaButton(
                    label: 'XONG',
                    onPressed: () => Navigator.pop(context, true),
                    backgroundColor: Colors.black,
                    borderRadius: 6,
                    height: 44,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  Future<void> _submit() async {
    final submitted = await _controller.submitFeedback(
      orderId: widget.orderId,
      rating: _rating,
      comment: _commentController.text,
      selectedTags: _selectedTags.toList(),
    );
    if (!mounted || !submitted) {
      return;
    }

    setState(() => _submitted = true);
  }
}

class _FeedbackTopBar extends StatelessWidget {
  const _FeedbackTopBar({this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEDE8E8))),
      ),
      child: Row(
        children: [
          if (onBack == null)
            const SizedBox(width: 50)
          else
            AppBackIconButton(onTap: onBack!),
          const Expanded(
            child: Text(
              'Đánh giá chất lượng dịch vụ',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 50),
        ],
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  const _StarRating({required this.rating, required this.onChanged});

  final int rating;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final value = index + 1;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: onChanged == null ? null : () => onChanged!(value),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Icon(
                Icons.star_rounded,
                color: value <= rating
                    ? const Color(0xFFFFC43B)
                    : const Color(0xFFC4C0C3),
                size: 30,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _FeedbackTagWrap extends StatelessWidget {
  const _FeedbackTagWrap({
    required this.tags,
    required this.selectedTags,
    required this.onToggle,
    this.enabled = true,
  });

  final List<String> tags;
  final Set<String> selectedTags;
  final ValueChanged<String> onToggle;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 9,
      runSpacing: 9,
      children: tags.map((tag) {
        final selected = selectedTags.contains(tag);
        return ChoiceChip(
          label: Text(tag),
          selected: selected,
          onSelected: enabled ? (_) => onToggle(tag) : null,
          showCheckmark: false,
          backgroundColor: const Color(0xFFE4E1E3),
          selectedColor: AppColors.orderAccent.withValues(alpha: 0.14),
          side: BorderSide(
            color: selected
                ? AppColors.orderAccent.withValues(alpha: 0.42)
                : Colors.transparent,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          labelStyle: TextStyle(
            color: selected ? AppColors.orderAccent : Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        );
      }).toList(),
    );
  }
}
