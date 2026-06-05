import 'package:flutter/material.dart';

import '../../../../core/components/placeholders/feature_placeholder_screen.dart';

class DriverBookingScreen extends StatelessWidget {
  const DriverBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderScreen(
      title: 'Driver Booking',
      description:
          'Dashboard bãi xe, booking flow, vé QR và gợi ý AI phân bổ slot.',
    );
  }
}