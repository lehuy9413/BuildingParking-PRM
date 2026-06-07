import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../domain/entities/booking.dart';

class DigitalTicketScreen extends StatefulWidget {
  const DigitalTicketScreen({super.key, required this.booking});

  final Booking booking;

  @override
  State<DigitalTicketScreen> createState() => _DigitalTicketScreenState();
}

class _DigitalTicketScreenState extends State<DigitalTicketScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _scaleAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final booking = widget.booking;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close_rounded,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            size: 28,
          ),
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
        title: Text(
          'Digital Ticket',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          children: [
            // ── Success Header ──
            ScaleTransition(
              scale: _scaleAnim,
              child: _SuccessHeader(isDark: isDark),
            ),
            const SizedBox(height: 24),

            // ── Ticket Card ──
            FadeTransition(
              opacity: _fadeAnim,
              child: _TicketCard(booking: booking, isDark: isDark),
            ),
            const SizedBox(height: 28),

            // ── Action Buttons ──
            FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Ticket saved to gallery!'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: const Color(0xFF1B998B),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      },
                      icon: const Icon(Icons.download_rounded),
                      label: const Text('Save to Gallery'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFF0F4C5C),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        shadowColor: const Color(0xFF0F4C5C).withOpacity(0.4),
                        textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      icon: const Icon(Icons.home_rounded),
                      label: const Text('Back to Home'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: isDark ? Colors.grey.shade600 : const Color(0xFFCBD5E1),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        foregroundColor: isDark ? Colors.grey.shade300 : const Color(0xFF475569),
                        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ─── Success Header ──────────────────────────────────────────────────────────

class _SuccessHeader extends StatelessWidget {
  const _SuccessHeader({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF065F46), const Color(0xFF047857)]
              : [const Color(0xFF10B981), const Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF059669).withOpacity(isDark ? 0.5 : 0.3),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Column(
        children: [
          Icon(Icons.check_circle_rounded, color: Colors.white, size: 56),
          SizedBox(height: 12),
          Text(
            'BOOKING CONFIRMED',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Your parking spot is reserved!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Ticket Card ─────────────────────────────────────────────────────────────

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.booking, required this.isDark});

  final Booking booking;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── QR Code Section ──
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: booking.qrCode,
                    version: QrVersions.auto,
                    size: 180,
                    backgroundColor: Colors.white,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: Color(0xFF0F4C5C),
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Scan at entrance gate',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  booking.id,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // ── Dashed Divider ──
          _DashedDivider(isDark: isDark),

          // ── Booking Details ──
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
            child: Column(
              children: [
                _DetailRow(
                  icon: Icons.location_on_rounded,
                  iconColor: const Color(0xFF3B82F6),
                  label: 'Zone',
                  value: booking.zoneName,
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                _DetailRow(
                  icon: Icons.local_parking_rounded,
                  iconColor: const Color(0xFF0F4C5C),
                  label: 'Slot',
                  value: booking.slotNumber,
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                _DetailRow(
                  icon: Icons.directions_car_rounded,
                  iconColor: const Color(0xFFA855F7),
                  label: 'Vehicle',
                  value: booking.vehicleTypeName,
                  isDark: isDark,
                ),
                if (booking.licensePlate != null && booking.licensePlate!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _DetailRow(
                    icon: Icons.badge_rounded,
                    iconColor: const Color(0xFFEA580C),
                    label: 'Plate',
                    value: booking.licensePlate!,
                    isDark: isDark,
                  ),
                ],
                const SizedBox(height: 16),
                Divider(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                  thickness: 1,
                ),
                const SizedBox(height: 16),
                _DetailRow(
                  icon: Icons.login_rounded,
                  iconColor: const Color(0xFF1B998B),
                  label: 'Check-in',
                  value: DateFormat('HH:mm — dd MMM yyyy').format(booking.checkInTime),
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                _DetailRow(
                  icon: Icons.logout_rounded,
                  iconColor: const Color(0xFFDC2626),
                  label: 'Check-out',
                  value: DateFormat('HH:mm — dd MMM yyyy').format(booking.checkOutTime),
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                _DetailRow(
                  icon: Icons.timer_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  label: 'Duration',
                  value: _formatDuration(booking.duration),
                  isDark: isDark,
                ),
                const SizedBox(height: 20),
                Divider(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                  thickness: 1,
                ),
                const SizedBox(height: 20),
                // Total price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Amount',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.grey.shade300 : const Color(0xFF475569),
                      ),
                    ),
                    Text(
                      '\$${booking.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F4C5C),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Status
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1B998B).withOpacity(0.15)
                        : const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF1B998B),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'CONFIRMED',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1B998B),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours == 0) return '${minutes} minutes';
    if (minutes == 0) return '$hours hours';
    return '$hours hours $minutes min';
  }
}

// ─── Detail Row ──────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.isDark,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(isDark ? 0.15 : 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 14),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

// ─── Dashed Divider ──────────────────────────────────────────────────────────

class _DashedDivider extends StatelessWidget {
  const _DashedDivider({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: Row(
        children: [
          // Left notch
          Container(
            width: 16,
            height: 24,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0E1116) : const Color(0xFFF7F9FB),
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
            ),
          ),
          // Dashed line
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final dashWidth = 8.0;
                final dashCount = (constraints.maxWidth / (dashWidth * 2)).floor();
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(dashCount, (_) {
                    return SizedBox(
                      width: dashWidth,
                      height: 2,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
          // Right notch
          Container(
            width: 16,
            height: 24,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0E1116) : const Color(0xFFF7F9FB),
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}
