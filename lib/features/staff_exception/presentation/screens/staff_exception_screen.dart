import 'package:flutter/material.dart';

import '../../../../core/components/placeholders/feature_placeholder_screen.dart';

class StaffExceptionScreen extends StatelessWidget {
  const StaffExceptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderScreen(
      title: 'Staff Exception',
      description:
          'Xử lý mất thẻ, xe cảnh báo/quá hạn, grid slot và đổi trạng thái bãi xe.',
    );
  }
}