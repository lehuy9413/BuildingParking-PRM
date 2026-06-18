import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QuickCheckInScreen extends StatefulWidget {
  const QuickCheckInScreen({super.key});

  @override
  State<QuickCheckInScreen> createState() => _QuickCheckInScreenState();
}

class _QuickCheckInScreenState extends State<QuickCheckInScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  // Mock a user ID or dynamic check-in token
  final String _checkInToken = 'WALKIN-USR-${DateTime.now().millisecondsSinceEpoch}';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
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

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Quick Check-In',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Header Text ──
            FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                children: [
                  Text(
                    'No Reservation?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Scan the QR code below at the entrance gate to start a parking session at standard rates.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey.shade400 : const Color(0xFF64748B),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // ── QR Code Card ──
            ScaleTransition(
              scale: _scaleAnim,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withOpacity(isDark ? 0.2 : 0.08),
                      blurRadius: 32,
                      offset: const Offset(0, 16),
                    ),
                  ],
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: QrImageView(
                        data: _checkInToken,
                        version: QrVersions.auto,
                        size: 220,
                        backgroundColor: Colors.white,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: Color(0xFF2563EB),
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2563EB).withOpacity(0.15) : const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.auto_awesome_rounded,
                            color: Color(0xFF2563EB),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Auto-updating token',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            // ── Information Cards ──
            FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                children: [
                  _buildInfoRow(
                    icon: Icons.payments_rounded,
                    title: 'Standard Rates Apply',
                    subtitle: 'Parking fees will be calculated based on standard facility rates.',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 20),
                  _buildInfoRow(
                    icon: Icons.account_balance_wallet_rounded,
                    title: 'Auto Payment',
                    subtitle: 'Fees will be automatically deducted from your linked wallet upon exit.',
                    isDark: isDark,
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

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF3B82F6), size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey.shade400 : const Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
