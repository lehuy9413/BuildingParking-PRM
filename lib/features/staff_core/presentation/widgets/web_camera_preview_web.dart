// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

class WebCameraPreview extends StatefulWidget {
  const WebCameraPreview({super.key});

  @override
  State<WebCameraPreview> createState() => _WebCameraPreviewState();
}

class _WebCameraPreviewState extends State<WebCameraPreview> {
  late html.VideoElement _videoElement;
  bool _isInitialized = false;
  String? _errorMessage;
  late final String _viewType;

  @override
  void initState() {
    super.initState();
    _viewType = 'web-camera-preview-${DateTime.now().millisecondsSinceEpoch}';
    _initPureWebCamera();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (!_isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return HtmlElementView(viewType: _viewType);
  }
}
