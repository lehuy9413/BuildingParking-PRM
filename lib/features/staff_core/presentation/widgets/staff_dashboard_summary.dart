import 'package:flutter/material.dart';
import '../controllers/staff_core_controller.dart';

/// Widget hiển thị dashboard tổng quan ca trực.
class StaffDashboardSummary extends StatelessWidget {
  const StaffDashboardSummary({super.key, required this.controller});
  final StaffCoreController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── Header ca trực ──────────────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1D4ED8), Color(0xFF2563EB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2563EB).withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ACTIVE SHIFT',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16A34A),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.circle, size: 8, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          'ACTIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Staff Parking Gate',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _shiftTimeLabel(),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // ─── Stat cards ──────────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Vehicles In',
                value: controller.vehiclesIn.toString(),
                icon: Icons.login_rounded,
                iconColor: const Color(0xFF2563EB),
                iconBg: const Color(0xFFEFF6FF),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'Vehicles Out',
                value: controller.vehiclesOut.toString(),
                icon: Icons.logout_rounded,
                iconColor: const Color(0xFF059669),
                iconBg: const Color(0xFFECFDF5),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'Currently Parked',
                value: controller.activeVehicleCount.toString(),
                icon: Icons.local_parking_rounded,
                iconColor: const Color(0xFFEA580C),
                iconBg: const Color(0xFFFFF7ED),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _shiftTimeLabel() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    return 'Started at $h:$m · ${_weekdayEN(now.weekday)}, ${now.year}/${now.month}/${now.day}';
  }

  String _weekdayEN(int wd) {
    const names = [
      '', 'Monday', 'Tuesday', 'Wednesday',
      'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    return names[wd];
  }
}

// ─── Stat Card ─────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
