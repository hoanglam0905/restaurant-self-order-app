import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../staff_navigation_shell.dart';
import '../controllers/staff_face_scan_controller.dart';

class StaffFaceScanView extends StatefulWidget {
  const StaffFaceScanView({super.key});

  @override
  State<StaffFaceScanView> createState() => _StaffFaceScanViewState();
}

class _StaffFaceScanViewState extends State<StaffFaceScanView>
    with SingleTickerProviderStateMixin {
  late final StaffFaceScanController controller;

  // Animation cho việc quét mặt (nếu vẫn muốn giữ lại hiệu ứng quét)
  late final AnimationController _scanAnimationController;
  late final Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    controller = Get.put(StaffFaceScanController());

    _scanAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _scanAnimation = CurvedAnimation(
      parent: _scanAnimationController,
      curve: Curves.easeInOutCubic,
    );

    // Lắng nghe trạng thái quét để chạy animation
    ever(controller.isScanning, (isScanning) {
      if (isScanning) {
        _scanAnimationController.repeat(reverse: true);
      } else {
        _scanAnimationController.stop();
      }
    });
  }

  @override
  void dispose() {
    _scanAnimationController.dispose();
    Get.delete<StaffFaceScanController>();
    super.dispose();
  }

  void _enterStaffWorkspace() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const StaffNavigationShell()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F1EC),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: const [
                          Color(0xFFFFEFE7),
                          Color(0xFFF6F8FC),
                          Color(0xFFEAF1F8),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: -90,
                  right: -80,
                  child: const _GlowOrb(
                    size: 220,
                    color: Color(0x8CFFC2A8), // 0.55 opacity
                  ),
                ),
                Positioned(
                  bottom: 80,
                  left: -100,
                  child: const _GlowOrb(
                    size: 220,
                    color: Color(0x73B8D8FF), // 0.45 opacity
                  ),
                ),
                Positioned(
                  top: 118,
                  left: 28,
                  right: 28,
                  child: Container(
                    height: 138,
                    decoration: BoxDecoration(
                      color: const Color(0x0F18212E), // 0.06 opacity
                      borderRadius: BorderRadius.circular(38),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
                  child: Obx(() {
                    return Column(
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 18),
                        _buildStatusCard(),
                        const SizedBox(height: 18),
                        Expanded(child: Center(child: _buildFaceScanner())),
                        if (controller.errorMessage.value.isNotEmpty)
                          Flexible(
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  controller.errorMessage.value,
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 18),
                        _buildChecklist(),
                        const SizedBox(height: 16),
                        _buildPrimaryButton(),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: controller.toggleAction,
                          child: Text(
                            controller.isCheckOut.value
                                ? 'Đang ở chế độ Check-Out. Nhấn để đổi sang Check-In'
                                : 'Đang ở chế độ Check-In. Nhấn để đổi sang Check-Out',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xD9718096), // 0.85 opacity
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E293B), Color(0xFFB63A1B)],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0x3DB63A1B), // 0.24 opacity
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.admin_panel_settings_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.isCheckOut.value ? 'Xác thực Tan Ca' : 'Xác thực Vào Ca',
                style: const TextStyle(
                  color: Color(0xFF1F2937),
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                controller.isCheckOut.value
                    ? 'Quét khuôn mặt trước khi về'
                    : 'Quét khuôn mặt trước khi vào ca',
                style: const TextStyle(
                  color: Color(0xFF718096),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xD1FFFFFF), // 0.82 opacity
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: Colors.white),
          ),
          child: const Text(
            'STAFF',
            style: TextStyle(
              color: Color(0xFFB63A1B),
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    final title = controller.isVerified.value
        ? 'Đã xác thực'
        : controller.isScanning.value
            ? 'Đang nhận diện'
            : 'Sẵn sàng xác thực';

    final subtitle = controller.isVerified.value
        ? controller.scanResult?.message ?? 'Xác thực thành công.'
        : controller.isScanning.value
            ? 'Đang gửi ảnh lên server kiểm tra...'
            : 'Nhấn bắt đầu và nhìn thẳng vào camera.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xC2FFFFFF), // 0.76 opacity
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 1.4),
        boxShadow: [
          BoxShadow(
            color: const Color(0x12253248), // 0.07 opacity
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: controller.isVerified.value
                    ? const [Color(0xFFDAFBE6), Color(0xFF6BD18A)]
                    : const [Color(0xFFFFE4D8), Color(0xFFFFB088)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              controller.isVerified.value
                  ? Icons.check_rounded
                  : Icons.face_retouching_natural,
              color: controller.isVerified.value
                  ? const Color(0xFF116B32)
                  : const Color(0xFFB63A1B),
              size: 24,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF718096),
                    fontSize: 11,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: controller.isVerified.value
                        ? 1
                        : controller.isScanning.value
                            ? null
                            : 0.18,
                    minHeight: 5,
                    backgroundColor: const Color(0xFFE6EBF2),
                    color: controller.isVerified.value
                        ? const Color(0xFF31A354)
                        : const Color(0xFFB63A1B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaceScanner() {
    final statusLabel = controller.isVerified.value
        ? 'VERIFIED'
        : controller.isScanning.value
            ? 'SCANNING'
            : 'READY';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      width: 322,
      height: 384,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xB8FFFFFF), // 0.72 opacity
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: Colors.white, width: 1.6),
        boxShadow: [
          BoxShadow(
            color: const Color(0x241E293B), // 0.14 opacity
            blurRadius: 34,
            offset: const Offset(0, 22),
          ),
        ],
      ),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF101827), Color(0xFF253041), Color(0xFF161B25)],
          ),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _FaceScanFramePainter(
                  isScanning: controller.isScanning.value,
                  isVerified: controller.isVerified.value,
                ),
              ),
            ),
            Positioned(
              top: 14,
              left: 14,
              right: 14,
              child: Row(
                children: [
                  _ScannerBadge(
                    label: 'LIVE PREVIEW',
                    color: controller.isScanning.value
                        ? const Color(0xFFFF8A5B)
                        : const Color(0xFF94A3B8),
                  ),
                  const Spacer(),
                  _ScannerBadge(
                    label: statusLabel,
                    color: controller.isVerified.value
                        ? const Color(0xFF4ADE80)
                        : const Color(0xFFFFC1A6),
                  ),
                ],
              ),
            ),
            Container(
              width: 214,
              height: 254,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: const Color(0x0DFFFFFF), // 0.05 opacity
                borderRadius: BorderRadius.circular(92),
                border: Border.all(
                  color: controller.isVerified.value
                      ? const Color(0xFF4ADE80)
                      : const Color(0xADFFC1A6), // 0.68 opacity
                  width: 1.6,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (controller.isVerified.value
                            ? const Color(0xFF4ADE80)
                            : const Color(0xFFFF7A45))
                        .withValues(alpha: 0.18),
                    blurRadius: 34,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                fit: StackFit.expand,
                children: [
                  if (controller.isCameraInitialized.value &&
                      controller.cameraController != null)
                    FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: controller.cameraController!.value.previewSize?.height ?? 1,
                        height: controller.cameraController!.value.previewSize?.width ?? 1,
                        child: CameraPreview(controller.cameraController!),
                      ),
                    )
                  else
                    const Center(
                      child: Icon(
                        Icons.face_retouching_natural,
                        size: 80,
                        color: Color(0xFFFFE1D5),
                      ),
                    ),
                  if (controller.isVerified.value)
                    Positioned(
                      right: 16,
                      bottom: 24,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFF31A354),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (controller.isScanning.value)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _scanAnimation,
                  builder: (context, child) {
                    return Align(
                      alignment: Alignment(
                        0,
                        -0.76 + _scanAnimation.value * 1.52,
                      ),
                      child: child,
                    );
                  },
                  child: Container(
                    height: 5,
                    margin: const EdgeInsets.symmetric(horizontal: 30),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Colors.transparent,
                          Color(0xFFFF8A5B),
                          Colors.white,
                          Color(0xFFFF8A5B),
                          Colors.transparent,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(99),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xADFF7A45), // 0.68 opacity
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Row(
                children: [
                  Expanded(
                    child: _buildScannerMetric(
                      label: 'API Status',
                      value: controller.isVerified.value
                          ? 'OK'
                          : controller.isScanning.value
                              ? 'WAIT'
                              : '--',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildScannerMetric(
                      label: 'Camera',
                      value: controller.isCameraInitialized.value ? 'ON' : 'OFF',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerMetric({required String label, required String value}) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0x14FFFFFF), // 0.08 opacity
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x1EFFFFFF)), // 0.12 opacity
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFAAB6C6),
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklist() {
    return Row(
      children: [
        Expanded(
          child: _CheckItem(
            icon: Icons.light_mode_outlined,
            label: 'Đủ sáng',
            active: controller.isScanning.value || controller.isVerified.value,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _CheckItem(
            icon: Icons.center_focus_strong,
            label: 'Camera Sẵn Sàng',
            active: controller.isCameraInitialized.value,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _CheckItem(
            icon: Icons.badge_outlined,
            label: 'Thành công',
            active: controller.isVerified.value,
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton() {
    final label = controller.isVerified.value
        ? 'Vào màn nhân viên'
        : controller.isScanning.value
            ? 'Đang xử lý...'
            : 'Bắt đầu quét mặt';

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: controller.isVerified.value
                ? const [Color(0xFF138A3D), Color(0xFF31A354)]
                : const [Color(0xFF9F2F12), Color(0xFFD9542D)],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0x47B63A1B), // 0.28 opacity
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: controller.isScanning.value
                ? null
                : controller.isVerified.value
                    ? _enterStaffWorkspace
                    : controller.startScan,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  controller.isVerified.value
                      ? Icons.login
                      : Icons.face_retouching_natural,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 9),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScannerBadge extends StatelessWidget {
  const _ScannerBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0x14FFFFFF), // 0.08 opacity
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: const Color(0x21FFFFFF)), // 0.13 opacity
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.55),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckItem extends StatelessWidget {
  const _CheckItem({
    required this.icon,
    required this.label,
    required this.active,
  });

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: Color(0xFFFFFFFF).withValues(alpha: active ? 0.9 : 0.68),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: active ? const Color(0xFFFFB391) : Colors.white,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E293B).withValues(alpha: active ? 0.08 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: active ? const Color(0xFFFFE3D7) : const Color(0xFFE8EEF5),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              active ? Icons.check_rounded : icon,
              color: active ? const Color(0xFFB63A1B) : const Color(0xFF94A3B8),
              size: 16,
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: active ? const Color(0xFF1F2937) : const Color(0xFF718096),
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 80,
            spreadRadius: 24,
          ),
        ],
      ),
    );
  }
}

class _FaceScanFramePainter extends CustomPainter {
  const _FaceScanFramePainter({
    required this.isScanning,
    required this.isVerified,
  });

  final bool isScanning;
  final bool isVerified;

  @override
  void paint(Canvas canvas, Size size) {
    final frameColor = isVerified
        ? const Color(0xFF31A354)
        : isScanning
            ? const Color(0xFFB63A1B)
            : const Color(0xFFCBD5E1);
    final cornerPaint = Paint()
      ..color = frameColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final subtlePaint = Paint()
      ..color = frameColor.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final rect = Rect.fromLTWH(18, 18, size.width - 36, size.height - 36);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(28)),
      subtlePaint,
    );

    const length = 42.0;
    final left = rect.left;
    final right = rect.right;
    final top = rect.top;
    final bottom = rect.bottom;

    canvas.drawLine(Offset(left, top + length), Offset(left, top), cornerPaint);
    canvas.drawLine(Offset(left, top), Offset(left + length, top), cornerPaint);

    canvas.drawLine(Offset(right - length, top), Offset(right, top), cornerPaint);
    canvas.drawLine(Offset(right, top), Offset(right, top + length), cornerPaint);

    canvas.drawLine(
      Offset(left, bottom - length),
      Offset(left, bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left, bottom),
      Offset(left + length, bottom),
      cornerPaint,
    );

    canvas.drawLine(
      Offset(right - length, bottom),
      Offset(right, bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(right, bottom),
      Offset(right, bottom - length),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _FaceScanFramePainter oldDelegate) {
    return oldDelegate.isScanning != isScanning ||
        oldDelegate.isVerified != isVerified;
  }
}
