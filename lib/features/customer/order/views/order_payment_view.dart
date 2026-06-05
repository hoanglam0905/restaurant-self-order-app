import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_price_formatter.dart';
import '../../../../core/utils/download_file.dart';
import '../../../../core/widgets/app_back_icon_button.dart';
import '../../../../core/widgets/app_cta_button.dart';
import '../../../../core/widgets/app_labeled_auth_text_field.dart';
import '../../../../core/widgets/app_surface_command_button.dart';
import '../../feedback/views/customer_feedback_view.dart';
import '../controllers/order_detail_controller.dart';
import '../data/models/order_detail_model.dart';
import '../data/models/order_item_model.dart';

class OrderPaymentView extends StatelessWidget {
  const OrderPaymentView({
    required this.order,
    required this.controller,
    super.key,
  });

  final OrderDetailModel order;
  final OrderDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAFA),
      body: SafeArea(
        child: Column(
          children: [
            _PaymentTopBar(onBack: () => Navigator.pop(context)),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 20, 12, 28),
                children: [
                  _PaymentTitle(status: order.paymentStatus),
                  const SizedBox(height: 16),
                  _InvoiceCard(order: order, controller: controller),
                  const SizedBox(height: 18),
                  Obx(() {
                    final paymentUrl = controller.vnpayPaymentUrl.value;
                    if (paymentUrl.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _VNPayQrCard(
                        paymentUrl: paymentUrl,
                        orderId: order.orderId,
                        onOpen: () => _openVNPay(context, paymentUrl),
                        onDownload: () => _downloadQr(context, paymentUrl),
                      ),
                    );
                  }),
                  Obx(
                    () => AppCtaButton(
                      label: controller.isProcessingPayment.value
                          ? 'Đang xử lý...'
                          : _primaryButtonLabel,
                      onPressed: () => _pay(context),
                      backgroundColor: AppColors.orderAccent,
                      borderRadius: 8,
                      height: 52,
                      fontSize: 14,
                      enabled: !controller.isProcessingPayment.value,
                      trailing: controller.isProcessingPayment.value
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.qr_code_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  AppSurfaceCommandButton(
                    label: 'KIỂM TRA THANH TOÁN',
                    onTap: () => _refreshPaymentStatus(context),
                    height: 52,
                    backgroundColor: const Color(0xFFE3E6EE),
                    labelColor: const Color(0xFF161C23),
                    fontSize: 13,
                    borderRadius: 8,
                    trailingIcon: Icons.refresh_rounded,
                    trailingRight: 64,
                  ),
                  const SizedBox(height: 10),
                  AppSurfaceCommandButton(
                    label: 'ĐẶT LẠI MÓN',
                    onTap: () => Navigator.pop(context),
                    height: 52,
                    backgroundColor: const Color(0xFFF0F2F7),
                    labelColor: const Color(0xFF161C23),
                    fontSize: 14,
                    borderRadius: 8,
                    trailingIcon: Icons.restaurant_menu_rounded,
                    trailingRight: 86,
                  ),
                  Obx(() {
                    if (controller.paymentMessage.value.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        controller.paymentMessage.value,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: controller.isPaid
                              ? const Color(0xFF3F8E3D)
                              : const Color(0xFFB3261E),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _primaryButtonLabel {
    if (controller.selectedPaymentMethod.value ==
            CustomerPaymentMethod.online &&
        controller.vnpayPaymentUrl.value.isNotEmpty) {
      return 'TẠO LẠI QR VNPAY';
    }
    return 'THANH TOÁN NGAY';
  }

  Future<void> _pay(BuildContext context) async {
    final method = controller.selectedPaymentMethod.value;
    if (method == CustomerPaymentMethod.online) {
      await _createVNPayQr(context);
      return;
    }

    final success = await controller.requestStaffPayment(method);
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          controller.paymentMessage.value.isNotEmpty
              ? controller.paymentMessage.value
              : success
              ? 'Đã gửi yêu cầu thanh toán cho nhân viên.'
              : 'Không thể gửi yêu cầu thanh toán.',
        ),
      ),
    );

    if (success) {
      Navigator.pop(context, false);
    }
  }

  Future<void> _createVNPayQr(BuildContext context) async {
    final paymentUrl = await controller.createVNPayPayment();
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          paymentUrl == null || paymentUrl.trim().isEmpty
              ? controller.paymentMessage.value.isNotEmpty
                    ? controller.paymentMessage.value
                    : 'Không thể tạo QR VNPay.'
              : 'Đã tạo QR VNPay. Khách hàng có thể tải QR hoặc mở VNPay.',
        ),
      ),
    );
  }

  Future<void> _openVNPay(BuildContext context, String paymentUrl) async {
    final uri = Uri.tryParse(paymentUrl);
    if (uri == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Link VNPay không hợp lệ.')));
      return;
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          opened
              ? 'Đã mở VNPay. Sau khi thanh toán, quay lại app và bấm kiểm tra.'
              : 'Không thể mở VNPay trên thiết bị này.',
        ),
      ),
    );
  }

  Future<void> _downloadQr(BuildContext context, String paymentUrl) async {
    final bytes = await _buildQrPng(paymentUrl);
    if (!context.mounted) {
      return;
    }

    if (bytes == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Không thể tạo ảnh QR.')));
      return;
    }

    final downloaded = await downloadBytes(
      bytes: bytes,
      fileName: 'vnpay_order_${order.orderId}.png',
      mimeType: 'image/png',
    );
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          downloaded
              ? 'Đã tải QR VNPay.'
              : 'Nền tảng này chưa hỗ trợ tải QR trực tiếp.',
        ),
      ),
    );
  }

  Future<Uint8List?> _buildQrPng(String paymentUrl) async {
    final painter = QrPainter(
      data: paymentUrl,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.M,
      gapless: true,
      eyeStyle: const QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: Colors.black,
      ),
      dataModuleStyle: const QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: Colors.black,
      ),
    );
    final imageData = await painter.toImageData(
      768,
      format: ui.ImageByteFormat.png,
    );
    return imageData?.buffer.asUint8List();
  }

  Future<void> _refreshPaymentStatus(BuildContext context) async {
    await controller.loadOrder();
    if (!context.mounted) {
      return;
    }

    if (controller.isPaid) {
      final earnedPoints = await controller.handlePaymentConfirmed();
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thanh toán đã được xác nhận.')),
      );
      await _openFeedback(context, earnedPoints);
      if (!context.mounted) {
        return;
      }
      Navigator.pop(context, true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đơn hàng vẫn chưa được xác nhận thanh toán.'),
      ),
    );
  }

  Future<void> _openFeedback(BuildContext context, int earnedPoints) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CustomerFeedbackView(
          orderId: order.orderId,
          earnedPoints: earnedPoints,
        ),
      ),
    );
  }
}

class _VNPayQrCard extends StatelessWidget {
  const _VNPayQrCard({
    required this.paymentUrl,
    required this.orderId,
    required this.onOpen,
    required this.onDownload,
  });

  final String paymentUrl;
  final int orderId;
  final VoidCallback onOpen;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFEDE3E1)),
      ),
      child: Column(
        children: [
          const Text(
            'QUÉT QR VNPAY',
            style: TextStyle(
              color: AppColors.orderAccent,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE3E6EE)),
            ),
            child: QrImageView(
              data: paymentUrl,
              version: QrVersions.auto,
              size: 210,
              backgroundColor: Colors.white,
              errorCorrectionLevel: QrErrorCorrectLevel.M,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Mã đơn #${orderId.toString().padLeft(3, '0')}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: AppSurfaceCommandButton(
                  label: 'TẢI QR',
                  onTap: onDownload,
                  height: 44,
                  backgroundColor: const Color(0xFFE3E6EE),
                  labelColor: AppColors.orderAccent,
                  fontSize: 12,
                  borderRadius: 8,
                  trailingIcon: Icons.download_rounded,
                  trailingRight: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppSurfaceCommandButton(
                  label: 'MỞ VNPAY',
                  onTap: onOpen,
                  height: 44,
                  backgroundColor: AppColors.orderAccent,
                  labelColor: Colors.white,
                  fontSize: 12,
                  borderRadius: 8,
                  trailingIcon: Icons.open_in_new_rounded,
                  trailingRight: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentTopBar extends StatelessWidget {
  const _PaymentTopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE0BFB7))),
      ),
      child: Row(
        children: [
          AppBackIconButton(onTap: onBack),
          const Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.payments_outlined,
                  color: AppColors.orderAccent,
                  size: 18,
                ),
                SizedBox(width: 7),
                Text(
                  'Thanh toán',
                  style: TextStyle(
                    color: AppColors.orderAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFFF1E8E5),
            child: Icon(
              Icons.person_rounded,
              color: AppColors.orderAccent,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentTitle extends StatelessWidget {
  const _PaymentTitle({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Thanh toán',
            style: TextStyle(
              color: Color(0xFF161C23),
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.orderAccent.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            status.toUpperCase() == 'PAID'
                ? 'ĐÃ THANH TOÁN'
                : 'CHƯA THANH TOÁN',
            style: const TextStyle(
              color: AppColors.orderAccent,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  const _InvoiceCard({required this.order, required this.controller});

  final OrderDetailModel order;
  final OrderDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFEDE3E1)),
      ),
      child: Column(
        children: [
          const Text(
            'HÓA ĐƠN ĐƠN HÀNG',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 18),
          _InvoiceRow(
            label: 'Mã đơn hàng',
            value: '#${order.orderId.toString().padLeft(3, '0')}',
            bold: true,
          ),
          _InvoiceRow(
            label: 'Số bàn',
            value: 'Bàn #${order.tableNumber}',
            bold: true,
          ),
          _InvoiceRow(
            label: 'Ngày đặt',
            value: _dateText(order.orderDate ?? order.reservationTime),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFECE5E3)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'DANH SÁCH MÓN ĂN',
                  style: TextStyle(
                    color: AppColors.orderAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '${order.items.length} món',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...order.items.map((item) => _PaymentItemRow(item: item)),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFECE5E3)),
          const SizedBox(height: 12),
          _PaymentMethodRow(controller: controller),
          const SizedBox(height: 14),
          _LoyaltyPointsPanel(controller: controller),
          const SizedBox(height: 14),
          Obx(
            () => Column(
              children: [
                if (controller.appliedDiscount.value > 0) ...[
                  _InvoiceRow(
                    label: 'Giá trị đơn',
                    value: formatAppPrice(
                      order.totalAmount,
                      withCurrency: true,
                    ),
                  ),
                  _InvoiceRow(
                    label: 'Giảm điểm',
                    value:
                        '-${formatAppPrice(controller.appliedDiscount.value, withCurrency: true)}',
                  ),
                ],
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Tổng cộng',
                        style: TextStyle(
                          color: Color(0xFF161C23),
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      formatAppPrice(
                        controller.payableAmountFor(order),
                        withCurrency: true,
                      ),
                      style: const TextStyle(
                        color: AppColors.orderAccent,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _dateText(DateTime? date) {
    if (date == null) {
      return '--/--/----';
    }
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

class _LoyaltyPointsPanel extends StatefulWidget {
  const _LoyaltyPointsPanel({required this.controller});

  final OrderDetailController controller;

  @override
  State<_LoyaltyPointsPanel> createState() => _LoyaltyPointsPanelState();
}

class _LoyaltyPointsPanelState extends State<_LoyaltyPointsPanel> {
  late final TextEditingController _pointsController;

  @override
  void initState() {
    super.initState();
    _pointsController = TextEditingController();
  }

  @override
  void dispose() {
    _pointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final availablePoints = widget.controller.availablePoints.value;
      final appliedPoints = widget.controller.appliedPointsToUse.value;
      final loading = widget.controller.isApplyingPoints.value;

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7F4),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFEDE3E1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.stars_rounded,
                  color: AppColors.orderAccent,
                  size: 18,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'Điểm hiện có: $availablePoints',
                    style: const TextStyle(
                      color: Color(0xFF161C23),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (appliedPoints > 0)
                  Text(
                    'Đã dùng $appliedPoints',
                    style: const TextStyle(
                      color: AppColors.orderAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            AppLabeledAuthTextField(
              label: 'Sử dụng điểm',
              controller: _pointsController,
              hintText: 'Nhập số điểm',
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              prefixIcon: const Icon(
                Icons.redeem_rounded,
                color: AppColors.orderAccent,
                size: 18,
              ),
              onSubmitted: (_) => _applyPoints(),
            ),
            const SizedBox(height: 10),
            AppCtaButton(
              label: loading ? 'Đang áp dụng...' : 'Áp dụng điểm',
              onPressed: _applyPoints,
              backgroundColor: AppColors.orderAccent,
              borderRadius: 8,
              height: 44,
              fontSize: 13,
              enabled: !loading,
              trailing: loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
            ),
            if (widget.controller.loyaltyMessage.value.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                widget.controller.loyaltyMessage.value,
                style: TextStyle(
                  color: widget.controller.appliedPointsToUse.value > 0
                      ? const Color(0xFF3F8E3D)
                      : const Color(0xFFB3261E),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  void _applyPoints() {
    final pointsToUse = int.tryParse(_pointsController.text.trim()) ?? 0;
    widget.controller.applyPoints(pointsToUse);
  }
}

class _InvoiceRow extends StatelessWidget {
  const _InvoiceRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: const Color(0xFF161C23),
              fontSize: 12,
              fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentItemRow extends StatelessWidget {
  const _PaymentItemRow({required this.item});

  final OrderItemModel item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFDDE3EC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.restaurant_rounded,
              color: AppColors.orderAccent,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.dishName ?? 'Món ăn #${item.dishId}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF161C23),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (item.notes != null && item.notes!.trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.notes!.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  'Số lượng: ${item.quantity}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatAppPrice(item.subtotal, withCurrency: true),
            style: const TextStyle(
              color: AppColors.orderAccent,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodRow extends StatelessWidget {
  const _PaymentMethodRow({required this.controller});

  final OrderDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Phương thức thanh toán',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Obx(
          () => Container(
            height: 30,
            padding: const EdgeInsets.only(left: 10, right: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE9ECF4),
              borderRadius: BorderRadius.circular(999),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<CustomerPaymentMethod>(
                value: controller.selectedPaymentMethod.value,
                icon: const Icon(Icons.expand_more_rounded, size: 16),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
                items: CustomerPaymentMethod.values.map((method) {
                  return DropdownMenuItem(
                    value: method,
                    child: Text(method.label),
                  );
                }).toList(),
                onChanged: (method) {
                  if (method != null) {
                    controller.selectPaymentMethod(method);
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
