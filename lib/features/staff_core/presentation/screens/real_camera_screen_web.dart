// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Web-only implementation of RealCameraScreen.
/// Uses dart:html VideoElement + getUserMedia.
class RealCameraScreen extends StatefulWidget {
  final bool isScanningQR;
  final String title;
  const RealCameraScreen({
    super.key,
    this.isScanningQR = false,
    this.title = 'Scan License Plate',
  });

  @override
  State<RealCameraScreen> createState() => _RealCameraScreenState();
}

class _RealCameraScreenState extends State<RealCameraScreen> {
  late html.VideoElement _videoElement;
  bool _isInitialized = false;
  String? _errorMessage;
  late final String _viewType;
  final TextEditingController _qrController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewType = 'web-camera-view-${DateTime.now().millisecondsSinceEpoch}';
    _initPureWebCamera();
  }

  void _submitQR() {
    final value = _qrController.text.trim();
    if (value.isNotEmpty && mounted) {
      Navigator.pop(context, value);
    }
  }

  Future<void> _initPureWebCamera() async {
    try {
      _videoElement = html.VideoElement()
        ..autoplay = true
        ..muted = true
        ..setAttribute('playsinline', 'true')
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover';

      ui_web.platformViewRegistry.registerViewFactory(
        _viewType,
        (int viewId) => _videoElement,
      );

      final stream = await html.window.navigator.mediaDevices!.getUserMedia({
        'video': true,
        'audio': false,
      });
      _videoElement.srcObject = stream;
      await _videoElement.play();

      if (mounted) setState(() => _isInitialized = true);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = 'Lỗi camera:\n$e');
    }
  }

  @override
  void dispose() {
    final stream = _videoElement.srcObject as html.MediaStream?;
    stream?.getTracks().forEach((track) => track.stop());
    _videoElement.srcObject = null;
    _qrController.dispose();
    super.dispose();
  }

  Future<void> _captureImage() async {
    if (!_isInitialized) return;
    try {
      final canvas = html.CanvasElement(
          width: _videoElement.videoWidth, height: _videoElement.videoHeight);
      canvas.context2D.drawImage(_videoElement, 0, 0);
      final base64Image = canvas.toDataUrl('image/jpeg', 0.9);
      if (mounted) Navigator.pop(context, base64Image);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Lỗi chụp ảnh: $e')));
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null && mounted) {
      final bytes = await file.readAsBytes();
      Navigator.pop(
          context, 'data:image/jpeg;base64,${base64Encode(bytes)}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: _errorMessage != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(_errorMessage!,
                      style: const TextStyle(
                          color: Colors.redAccent, fontSize: 16),
                      textAlign: TextAlign.center),
                ),
              )
            : !_isInitialized
                ? const Center(child: CircularProgressIndicator())
                : Column(children: [
                    Expanded(
                      child: Stack(
                        children: [
                          Center(
                            child: AspectRatio(
                              aspectRatio: 4 / 3,
                              child: HtmlElementView(viewType: _viewType),
                            ),
                          ),
                          if (widget.isScanningQR)
                            Positioned(
                              bottom: 20,
                              left: 20,
                              right: 20,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.green),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.qr_code_scanner, color: Colors.green, size: 40),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Use physical scanner or type booking ID',
                                      style: TextStyle(color: Colors.white, fontSize: 13),
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: _qrController,
                                      autofocus: true,
                                      style: const TextStyle(color: Colors.white),
                                      decoration: InputDecoration(
                                        hintText: 'Type or scan QR code here...',
                                        hintStyle: const TextStyle(color: Colors.white54),
                                        filled: true,
                                        fillColor: Colors.grey.shade900,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                      onSubmitted: (_) => _submitQR(),
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: _submitQR,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text('Confirm'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (!widget.isScanningQR)
                      Container(
                        padding: const EdgeInsets.all(24),
                        color: Colors.black87,
                        child: Column(children: [
                          ElevatedButton.icon(
                            onPressed: _captureImage,
                            icon: const Icon(Icons.camera_alt, size: 28),
                            label: const Text('Capture',
                                style: TextStyle(fontSize: 18)),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.photo_library,
                                color: Colors.white70),
                            label: const Text('Tải ảnh từ máy để test',
                                style: TextStyle(color: Colors.white70)),
                          ),
                        ]),
                      ),
                  ]),
      ),
    );
  }
}
