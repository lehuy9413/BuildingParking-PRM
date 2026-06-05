import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/components/placeholders/feature_placeholder_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.appName,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Khởi tạo kiến trúc Feature-First cho 2 role: Staff và Driver.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              const Expanded(
                child: FeaturePlaceholderScreen(
                  title: 'Smart Parking Ready',
                  description:
                      'Mỗi feature đã được tách riêng để team làm việc song song và hạn chế conflict khi merge Git.',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}