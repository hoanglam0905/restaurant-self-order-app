import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_back_icon_button.dart';
import '../../../../core/widgets/app_cta_button.dart';
import '../data/models/table_qr_payload.dart';

class TableQrScanView extends StatefulWidget {
  const TableQrScanView({super.key});

  @override
  State<TableQrScanView> createState() => _TableQrScanViewState();
}

class _TableQrScanViewState extends State<TableQrScanView> {
  late final MobileScannerController _scannerController;
  bool _handledScan = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      formats: const [BarcodeFormat.qrCode],
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            MobileScanner(
              controller: _scannerController,
              onDetect: _handleBarcodeCapture,
            ),
            const _ScanFrameOverlay(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppBackIconButton(onTap: () => Navigator.pop(context)),
                  const Spacer(),
                  if (_errorMessage != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.66),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  AppCtaButton(
                    label: 'Demo ban A9',
                    onPressed: () => _completeScan(
                      const TableQrPayload(tableId: 9, tableLabel: 'A9'),
                    ),
                    backgroundColor: AppColors.welcomeAccent,
                    height: 48,
                    borderRadius: 8,
                    fontSize: 15,
                    trailing: const Icon(
                      Icons.table_restaurant_rounded,
                      color: Colors.white,
                      size: 20,
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

  void _handleBarcodeCapture(BarcodeCapture capture) {
    if (_handledScan) {
      return;
    }

    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue;
      if (value == null) {
        continue;
      }

      final payload = TableQrPayload.tryParse(value);
      if (payload == null) {
        setState(() {
          _errorMessage = 'Ma QR ban khong hop le.';
        });
        continue;
      }

      _completeScan(payload);
      return;
    }
  }

  void _completeScan(TableQrPayload payload) {
    if (_handledScan) {
      return;
    }

    _handledScan = true;
    Navigator.pop(context, payload);
  }
}

class _ScanFrameOverlay extends StatelessWidget {
  const _ScanFrameOverlay();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 248,
        height: 248,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.38),
              blurRadius: 18,
              spreadRadius: 8,
            ),
          ],
        ),
      ),
    );
  }
}
