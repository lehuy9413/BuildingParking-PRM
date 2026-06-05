import 'package:flutter/material.dart';

import '../../../../core/components/placeholders/feature_placeholder_screen.dart';

class DriverTrackingScreen extends StatelessWidget {
  const DriverTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderScreen(
      title: 'Driver Tracking',
      description:
          'Live tracking realtime, lịch sử gửi xe, thanh toán online và phản hồi sự cố.',
    );
  }
}