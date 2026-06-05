import 'package:flutter/material.dart';

import '../../../../core/components/placeholders/feature_placeholder_screen.dart';

class StaffCoreScreen extends StatelessWidget {
  const StaffCoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderScreen(
      title: 'Staff Core',
      description:
          'Check-in biển số, tạo parking session, check-out tính phí và thanh toán tại cổng.',
    );
  }
}