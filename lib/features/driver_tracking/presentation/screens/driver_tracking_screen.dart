import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/driver_tracking_controller.dart';
import '../../../staff_core/data/models/parking_session_api_model.dart';
import 'live_session_screen.dart';
import 'parking_history_screen.dart';
import 'payment_screen.dart';

/// Hub screen for Driver Tracking – links to all tracking/payment/feedback features.
class DriverTrackingScreen extends ConsumerWidget {
  const DriverTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sessionState = ref.watch(liveSessionProvider);
    final sessions = sessionState.value?.sessions ?? [];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        title: Text('Tracking & Services', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: isDark ? Colors.white : const Color(0xFF0F172A))),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: isDark ? Colors.white : const Color(0xFF0F172A)),
            tooltip: 'Refresh sessions',
            onPressed: () => ref.read(liveSessionProvider.notifier).refresh(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Active Session Banners (one per parked vehicle)
            ...sessions.expand((s) => [
              _buildActiveSessionBanner(context, isDark, s),
              const SizedBox(height: 12),
            ]),
            if (sessions.isNotEmpty) const SizedBox(height: 8),

            _sectionTitle('SERVICES', isDark),
            const SizedBox(height: 16),
            _buildServiceCard(
              context: context, isDark: isDark,
              icon: Icons.history_rounded, title: 'History & Receipts',
              subtitle: 'View parking history and payment transactions',
              color: const Color(0xFF3B82F6),
              gradientColors: [const Color(0xFF3B82F6), const Color(0xFF60A5FA)],
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ParkingHistoryScreen())),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, bool isDark) {
    return Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: isDark ? Colors.grey.shade400 : const Color(0xFF475569), letterSpacing: 1.5));
  }

  Widget _buildActiveSessionBanner(BuildContext ctx, bool isDark, ParkingSessionApiModel session) {
    return GestureDetector(
      onTap: () => Navigator.push(ctx, MaterialPageRoute(
        builder: (_) => LiveSessionScreen(sessionId: session.id),
      )),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF0F4C5C), Color(0xFF1B998B)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: const Color(0xFF0F4C5C).withOpacity(isDark ? 0.5 : 0.3), blurRadius: 24, offset: const Offset(0, 10))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.directions_car_filled_rounded, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFF16A34A).withOpacity(0.3), borderRadius: BorderRadius.circular(6)),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.circle, color: Color(0xFF4ADE80), size: 6),
                    SizedBox(width: 4),
                    Text('ACTIVE', style: TextStyle(color: Color(0xFF4ADE80), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  ]),
                ),
              ]),
              const SizedBox(height: 8),
              Text('${session.licensePlate} • ${session.floorName} • ${session.slotCode}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text('Tap to view live session', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w500)),
            ])),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required BuildContext context, required bool isDark,
    required IconData icon, required String title, required String subtitle,
    required Color color, required List<Color> gradientColors, required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.04), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: isDark ? Colors.white : const Color(0xFF0F172A))),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isDark ? Colors.grey.shade400 : Colors.grey.shade500, height: 1.3)),
            ])),
            Icon(Icons.arrow_forward_ios_rounded, color: isDark ? Colors.grey.shade600 : Colors.grey.shade300, size: 16),
          ],
        ),
      ),
    );
  }
}