import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

/// Mobile stub for RealCameraScreen.
/// Uses ImagePicker instead of web camera APIs.
class RealCameraScreen extends StatelessWidget {
  final bool isScanningQR;
  final String title;

  const RealCameraScreen({
    super.key,
    this.isScanningQR = false,
    this.title = 'Scan License Plate',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt, color: Colors.white54, size: 80),
            const SizedBox(height: 24),
            const Text(
              'Chọn ảnh để nhận diện biển số',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Chụp ảnh'),
              onPressed: () => _pickImage(context, ImageSource.camera),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.photo_library, color: Colors.white70),
              label: const Text('Chọn từ thư viện',
                  style: TextStyle(color: Colors.white70)),
              onPressed: () => _pickImage(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source, imageQuality: 90);
    if (file != null && context.mounted) {
      final bytes = await file.readAsBytes();
      final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      Navigator.pop(context, base64Image);
    }
  }
}
