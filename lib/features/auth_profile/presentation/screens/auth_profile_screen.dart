import 'package:flutter/material.dart';

import '../../../../core/components/placeholders/feature_placeholder_screen.dart';

class AuthProfileScreen extends StatelessWidget {
  const AuthProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderScreen(
      title: 'Auth & Profile',
      description:
          'Onboarding, đăng nhập, đăng ký, đổi mật khẩu và quản lý xe cá nhân.',
    );
  }
}