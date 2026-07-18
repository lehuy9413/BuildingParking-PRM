import 'package:flutter/material.dart';

class WebCameraPreview extends StatelessWidget {
  const WebCameraPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Live camera feed not supported on this platform.'),
    );
  }
}
