import 'package:flutter/material.dart';
import '../../../../app/app.dart' as import_app;

class DriverHomeScreen extends StatelessWidget {
  const DriverHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, isDark),
              const SizedBox(height: 28),
              _buildLiveAvailabilityCard(isDark),
              const SizedBox(height: 32),
              _buildSectionTitle('FACILITY INFORMATION', isDark),
              const SizedBox(height: 16),
              _buildFacilityInformationCard(isDark),
              const SizedBox(height: 32),
              _buildSectionTitle('QUICK ACTIONS', isDark),
              const SizedBox(height: 16),
              _buildQuickActions(isDark),
              const SizedBox(height: 32),
              _buildStandardRatesCard(isDark),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: isDark ? Colors.grey.shade400 : const Color(0xFF475569),
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, Driver!',
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.grey.shade400 : const Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(8),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Color(0xFF0EA5E9), size: 22),
                  const SizedBox(width: 6),
                  Text(
                    'Ho Chi Minh City',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down, color: isDark ? Colors.white : const Color(0xFF0F172A), size: 22),
                ],
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: isDark ? Colors.amber : const Color(0xFF0F172A)),
              onPressed: () {
                import_app.SmartParkingApp.of(context).toggleTheme(isDark);
              },
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                Icon(Icons.notifications_none_rounded, color: isDark ? Colors.white : const Color(0xFF0F172A), size: 26),
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
          ],
        ),
      ],
    );
  }

  Widget _buildLiveAvailabilityCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark 
            ? [const Color(0xFF0F4C5C), const Color(0xFF1B998B)]
            : [const Color(0xFFE0F7FA), const Color(0xFFFFFFFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: isDark ? const Color(0xFF1B998B) : const Color(0xFFB2EBF2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00ACC1).withOpacity(isDark ? 0.4 : 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.15) : const Color(0xFF00ACC1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'LIVE AVAILABILITY',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF00838F),
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '342',
            style: TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF006064),
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Slots Available Now',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white.withOpacity(0.9) : const Color(0xFF00838F),
            ),
          ),
          const SizedBox(height: 24),
          Divider(color: (isDark ? Colors.white : const Color(0xFF00ACC1)).withOpacity(0.2), thickness: 1.5),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildVehicleAvailability(
                isDark: isDark,
                icon: Icons.directions_car,
                iconColor: isDark ? const Color(0xFF60A5FA) : const Color(0xFF3B82F6),
                iconBgColor: isDark ? const Color(0xFF1E3A8A).withOpacity(0.5) : const Color(0xFFDBEAFE),
                label: 'Cars',
                count: '120',
                status: 'vacant',
              ),
              Container(
                width: 1.5,
                height: 48,
                color: (isDark ? Colors.white : const Color(0xFF00ACC1)).withOpacity(0.2),
              ),
              _buildVehicleAvailability(
                isDark: isDark,
                icon: Icons.two_wheeler_rounded,
                iconColor: isDark ? const Color(0xFFC084FC) : const Color(0xFFA855F7),
                iconBgColor: isDark ? const Color(0xFF581C87).withOpacity(0.5) : const Color(0xFFF3E8FF),
                label: 'Motorbikes',
                count: '222',
                status: 'vacant',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleAvailability({
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String label,
    required String count,
    required String status,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: iconColor, size: 28),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 13, color: isDark ? Colors.grey.shade300 : Colors.grey.shade700, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Text(
                  count,
                  style: TextStyle(fontSize: 22, color: iconColor, fontWeight: FontWeight.w900),
                ),
                const SizedBox(width: 6),
                Text(
                  status,
                  style: TextStyle(fontSize: 15, color: isDark ? Colors.white : const Color(0xFF0F172A), fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFacilityInformationCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 24,
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E3A8A).withOpacity(0.4) : const Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.access_time_filled, color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB), size: 24),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Operating Hours', style: TextStyle(fontSize: 13, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text('24/7 Open', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: isDark ? Colors.white : const Color(0xFF0F172A))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF064E3B).withOpacity(0.4) : const Color(0xFFECFDF5),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.electric_bolt_rounded, color: isDark ? const Color(0xFF34D399) : const Color(0xFF059669), size: 24),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Allowed Vehicles', style: TextStyle(fontSize: 13, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildTag('Cars', isDark ? const Color(0xFF1E3A8A).withOpacity(0.4) : const Color(0xFFEFF6FF), isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB)),
                      const SizedBox(width: 8),
                      _buildTag('Motorbikes', isDark ? const Color(0xFF581C87).withOpacity(0.4) : const Color(0xFFFAF5FF), isDark ? const Color(0xFFC084FC) : const Color(0xFF9333EA)),
                      const SizedBox(width: 8),
                      _buildTag('EVs', isDark ? const Color(0xFF064E3B).withOpacity(0.4) : const Color(0xFFECFDF5), isDark ? const Color(0xFF34D399) : const Color(0xFF059669)),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Divider(color: isDark ? Colors.grey.shade700 : Colors.grey.shade200, thickness: 1.5),
          const SizedBox(height: 12),
          InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'View Full Pricing & Tariff Rules',
                    style: TextStyle(
                      color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.arrow_forward_ios_rounded, color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB), size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildQuickActions(bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                isDark: isDark,
                icon: Icons.qr_code_scanner_rounded,
                iconColor: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
                iconBgColor: isDark ? const Color(0xFF1E3A8A).withOpacity(0.4) : const Color(0xFFEFF6FF),
                title: 'Quick Check-In',
                subtitle: 'View active ticket/QR code',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                isDark: isDark,
                icon: Icons.edit_calendar_rounded,
                iconColor: isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
                iconBgColor: isDark ? const Color(0xFF064E3B).withOpacity(0.4) : const Color(0xFFECFDF5),
                title: 'Pre-book Slot',
                subtitle: 'Reserve your spot in advance',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                isDark: isDark,
                icon: Icons.timer_rounded,
                iconColor: isDark ? const Color(0xFFFB923C) : const Color(0xFFEA580C),
                iconBgColor: isDark ? const Color(0xFF7C2D12).withOpacity(0.4) : const Color(0xFFFFF7ED),
                title: 'Track Session',
                subtitle: 'Check live duration & fee',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                isDark: isDark,
                icon: Icons.support_agent_rounded,
                iconColor: isDark ? const Color(0xFFC084FC) : const Color(0xFF9333EA),
                iconBgColor: isDark ? const Color(0xFF581C87).withOpacity(0.4) : const Color(0xFFFAF5FF),
                title: 'Support',
                subtitle: 'Report lost card or issues',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: iconColor, size: 28),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey.shade400 : const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStandardRatesCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
            ? [const Color(0xFF065F46), const Color(0xFF047857)]
            : [const Color(0xFF10B981), const Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF059669).withOpacity(isDark ? 0.6 : 0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.payments_rounded, color: Colors.white, size: 24),
              const SizedBox(width: 10),
              const Text(
                'STANDARD RATES',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildRateRow(Icons.two_wheeler_rounded, 'Motorbikes', '\$1.00', '/hour'),
          const SizedBox(height: 16),
          Divider(color: Colors.white.withOpacity(0.25), thickness: 1.5),
          const SizedBox(height: 16),
          _buildRateRow(Icons.directions_car_rounded, 'Cars', '\$3.00', '/hour'),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, color: Colors.white, size: 14),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Additional fees may apply for extended parking',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRateRow(IconData icon, String type, String rate, String suffix) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        Text(
          type,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              rate,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              suffix,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
