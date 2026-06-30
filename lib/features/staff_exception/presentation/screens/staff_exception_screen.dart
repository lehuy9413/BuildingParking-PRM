import 'package:flutter/material.dart';
import '../../../auth_profile/presentation/screens/auth_profile_screen.dart';
import '../../domain/models/exception_models.dart';
import 'exception_handling_screen.dart';
import 'alert_vehicles_screen.dart';
import 'parking_map_screen.dart';


/// Màn hình chính của Staff Exception – dashboard điều hướng 4 chức năng.
class StaffExceptionScreen extends StatelessWidget {
  const StaffExceptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header banner ───────────────────────────────────────────────
            _buildHeaderBanner(),
            const SizedBox(height: 24),

            // ─── Section title ───────────────────────────────────────────────
            _sectionTitle('MANAGEMENT FUNCTIONS'),
            const SizedBox(height: 14),

            // ─── Feature cards – 2 columns ───────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _FeatureCard(
                    icon: Icons.report_problem_rounded,
                    iconColor: const Color(0xFFEA580C),
                    iconBg: const Color(0xFFFFF7ED),
                    title: 'Exception\nHandling',
                    subtitle: 'Lost card & wrong vehicle info',
                    badge: null,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ExceptionHandlingScreen()),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _FeatureCard(
                    icon: Icons.warning_amber_rounded,
                    iconColor: const Color(0xFFF59E0B),
                    iconBg: const Color(0xFFFEF3C7),
                    title: 'Vehicle\nAlerts',
                    subtitle: 'Overdue & wrong area',
                    badge: '5',
                    badgeColor: const Color(0xFFEF4444),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AlertVehiclesScreen()),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _FeatureCard(
                    icon: Icons.map_rounded,
                    iconColor: const Color(0xFF2563EB),
                    iconBg: const Color(0xFFEFF6FF),
                    title: 'Parking\nMap',
                    subtitle: 'Visual slot management',
                    badge: null,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ParkingMapScreen()),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _FeatureCard(
                    icon: Icons.tune_rounded,
                    iconColor: const Color(0xFF7C3AED),
                    iconBg: const Color(0xFFF5F3FF),
                    title: 'Status\nUpdate',
                    subtitle: 'Available, maintenance, locked',
                    badge: null,
                    onTap: () => _showQuickSlotUpdate(context),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ─── Quick Stats ─────────────────────────────────────────────────
            _sectionTitle('QUICK STATS'),
            const SizedBox(height: 14),
            _buildQuickStats(),

            const SizedBox(height: 28),

            // ─── Recent activity ─────────────────────────────────────────────
            _sectionTitle('RECENT ACTIVITY'),
            const SizedBox(height: 14),
            _buildRecentActivity(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF0F172A), size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Row(
        children: [
          Icon(Icons.manage_accounts_rounded,
              color: Color(0xFF2563EB), size: 26),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Staff Exception',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A)),
              ),
              Text(
                'Exception & Monitoring',
                style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AuthProfileScreen()),
          ),
          tooltip: 'Logout',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeaderBanner() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1D4ED8), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield_rounded,
                        color: Colors.white, size: 14),
                    SizedBox(width: 5),
                    Text(
                      'STAFF EXCEPTION MODULE',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Parking Exception\nManagement',
            style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                height: 1.2),
          ),
          const SizedBox(height: 8),
          Text(
            'Active Shift · $h:$m',
            style: TextStyle(
                color: Colors.white.withOpacity(0.75),
                fontSize: 13,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        _QuickStatCard(
          value: '88',
          label: 'Total slots',
          icon: Icons.grid_view_rounded,
          color: const Color(0xFF2563EB),
          bg: const Color(0xFFEFF6FF),
        ),
        const SizedBox(width: 10),
        _QuickStatCard(
          value: '61',
          label: 'Occupied',
          icon: Icons.directions_car_rounded,
          color: const Color(0xFF16A34A),
          bg: const Color(0xFFECFDF5),
        ),
        const SizedBox(width: 10),
        _QuickStatCard(
          value: '5',
          label: 'Alerts',
          icon: Icons.warning_amber_rounded,
          color: const Color(0xFFEF4444),
          bg: const Color(0xFFFFF1F2),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    final items = [
      _ActivityItem(
          icon: Icons.credit_card_off_rounded,
          color: const Color(0xFFEA580C),
          bg: const Color(0xFFFFF7ED),
          title: 'Lost card: 51A-12345',
          subtitle: 'Granted exit permission',
          time: '10 mins ago'),
      _ActivityItem(
          icon: Icons.timer_off_rounded,
          color: const Color(0xFFEF4444),
          bg: const Color(0xFFFFF1F2),
          title: 'Overdue: 30G-55678',
          subtitle: '72 hours parked – pending',
          time: '25 mins ago'),
      _ActivityItem(
          icon: Icons.build_rounded,
          color: const Color(0xFFF59E0B),
          bg: const Color(0xFFFEF3C7),
          title: 'Maintenance: Slot M15',
          subtitle: 'Status updated',
          time: '1 hour ago'),
    ];

    return Column(
      children: items.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: item.bg,
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(item.icon, color: item.color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Color(0xFF0F172A))),
                    const SizedBox(height: 2),
                    Text(item.subtitle,
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF94A3B8))),
                  ],
                ),
              ),
              Text(item.time,
                  style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Color(0xFF475569),
          letterSpacing: 1.5),
    );
  }

  void _showQuickSlotUpdate(BuildContext context) {
    // Demo: mở bottom sheet với slot demo
    final demoSlot = ParkingSlot(
      id: 'demo-A01',
      label: 'A01',
      zone: 'Floor 1',
      floor: 1,
      status: SlotStatus.available,
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      backgroundColor: Colors.white,
      builder: (_) => SlotStatusUpdateSheet(
        slot: demoSlot,
        onStatusChanged: (status) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                '✅ Slot A01 updated: ${_statusLabel(status)}'),
            backgroundColor: const Color(0xFF2563EB),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ));
        },
      ),
    );
  }

  String _statusLabel(SlotStatus s) => switch (s) {
        SlotStatus.available => 'Available',
        SlotStatus.occupied => 'Occupied',
        SlotStatus.maintenance => 'Maintenance',
        SlotStatus.locked => 'Locked',
      };
}


// ─── Feature Card ─────────────────────────────────────────────────────────────

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    this.badge,
    this.badgeColor,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final String? badge;
  final Color? badgeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(14)),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const Spacer(),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (badgeColor ?? iconColor).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badge!,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: badgeColor ?? iconColor),
                    ),
                  ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: Colors.grey.shade400),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  height: 1.3),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF94A3B8),
                  height: 1.3),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Quick Stat Card ──────────────────────────────────────────────────────────

class _QuickStatCard extends StatelessWidget {
  const _QuickStatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    required this.bg,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
            color: bg, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: color,
                    height: 1)),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ─── Activity Item data class ─────────────────────────────────────────────────

class _ActivityItem {
  final IconData icon;
  final Color color;
  final Color bg;
  final String title;
  final String subtitle;
  final String time;

  const _ActivityItem({
    required this.icon,
    required this.color,
    required this.bg,
    required this.title,
    required this.subtitle,
    required this.time,
  });
}