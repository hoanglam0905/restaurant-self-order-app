import 'package:camera/camera.dart';
import 'package:get/get.dart';

import '../data/models/attendance_response.dart';
import '../data/services/attendance_service.dart';

class StaffFaceScanController extends GetxController {
  final AttendanceService _attendanceService = AttendanceService();

  CameraController? cameraController;
  List<CameraDescription> _cameras = [];

  // State
  final isCameraInitialized = false.obs;
  final isScanning = false.obs;
  final isVerified = false.obs;
  final isCheckOut = false.obs; // Toggle Check-In / Check-Out
  final errorMessage = ''.obs;

  AttendanceResponse? scanResult;

  @override
  void onInit() {
    super.onInit();
    _initCamera();
  }

  @override
  void onClose() {
    cameraController?.dispose();
    super.onClose();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        errorMessage.value = 'Không tìm thấy camera trên thiết bị.';
        return;
      }

      // Ưu tiên camera trước
      CameraDescription? frontCamera;
      try {
        frontCamera = _cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
        );
      } catch (_) {
        frontCamera = _cameras.first;
      }

      cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await cameraController!.initialize();
      isCameraInitialized.value = true;
    } catch (e) {
      errorMessage.value = 'Lỗi khởi tạo camera: $e';
    }
  }

  void toggleAction() {
    if (isScanning.value) return;
    isCheckOut.value = !isCheckOut.value;
    // Reset state
    isVerified.value = false;
    errorMessage.value = '';
    scanResult = null;
  }

  Future<void> startScan() async {
    if (isScanning.value ||
        !isCameraInitialized.value ||
        cameraController == null) {
      return;
    }

    try {
      isScanning.value = true;
      errorMessage.value = '';
      isVerified.value = false;
      scanResult = null;

      // Chụp ảnh
      final XFile picture = await cameraController!.takePicture();

      // Gọi API Check-In / Check-Out
      if (isCheckOut.value) {
        scanResult = await _attendanceService.checkOut(picture);
      } else {
        scanResult = await _attendanceService.checkIn(picture);
      }

      isVerified.value = true;
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      isVerified.value = false;
    } finally {
      isScanning.value = false;
    }
  }
}
