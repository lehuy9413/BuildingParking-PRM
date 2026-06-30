import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/booking_controller.dart';
import '../screens/ai_suggestion_screen.dart';

class AiSuggestionBanner extends ConsumerWidget {
  const AiSuggestionBanner({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        final state = ref.read(bookingControllerProvider);
        if (state.selectedVehicle != null && state.selectedDate != null && state.selectedParkingLot != null) {
          ref.read(bookingControllerProvider.notifier).loadAiSuggestions();
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AiSuggestionScreen()),
          );
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF1E1B4B), const Color(0xFF312E81)]
                : [const Color(0xFFEEF2FF), const Color(0xFFE0E7FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? const Color(0xFF6366F1).withValues(alpha: 0.4) : const Color(0xFFC7D2FE),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withValues(alpha: isDark ? 0.3 : 0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF6366F1).withValues(alpha: 0.25)
                    : const Color(0xFF6366F1).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Color(0xFF6366F1),
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Smart Suggestion',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF312E81),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Find your optimal parking spot with AI analysis',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.grey.shade400 : const Color(0xFF6366F1),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: isDark ? const Color(0xFF6366F1) : const Color(0xFF818CF8),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
