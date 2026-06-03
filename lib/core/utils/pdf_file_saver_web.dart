import 'dart:typed_data';

import 'download_file.dart';

Future<String?> saveAndOpenPdfBytes({
  required Uint8List bytes,
  required String fileName,
}) async {
  final downloaded = await downloadBytes(
    bytes: bytes,
    fileName: fileName,
    mimeType: 'application/pdf',
  );
  return downloaded ? fileName : null;
}
