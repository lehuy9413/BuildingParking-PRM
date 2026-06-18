import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Màn hình Thanh toán Online – giả lập cổng thanh toán (Momo, ZaloPay, QR Bank).
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({
    super.key,
    required this.amount,
    required this.sessionId,
    required this.plateNumber,
  });

  final double amount;
  final String sessionId;
  final String plateNumber;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with TickerProviderStateMixin {
  int _selectedMethodIndex = -1;
  bool _showQr = false;
  bool _isProcessing = false;
  bool _paymentSuccess = false;

  late final AnimationController _successAnimController;
  late final Animation<double> _successScale;

  final List<_PaymentMethod> _methods = const [
    _PaymentMethod(
      name: 'MoMo',
      subtitle: 'MoMo E-Wallet',
      icon: Icons.account_balance_wallet_rounded,
      color: Color(0xFFAE2070),
      gradientColors: [Color(0xFFAE2070), Color(0xFFD63384)],
    ),
    _PaymentMethod(
      name: 'Cash',
      subtitle: 'Pay at the counter',
      icon: Icons.payments_rounded,
      color: Color(0xFFF59E0B),
      gradientColors: [Color(0xFFF59E0B), Color(0xFFFCD34D)],
    ),
    _PaymentMethod(
      name: 'Bank QR',
      subtitle: 'Bank Transfer',
      icon: Icons.qr_code_rounded,
      color: Color(0xFF059669),
      gradientColors: [Color(0xFF059669), Color(0xFF34D399)],
    ),
    _PaymentMethod(
      name: 'Visa / Master',
      subtitle: 'International Card',
      icon: Icons.credit_card_rounded,
      color: Color(0xFF6366F1),
      gradientColors: [Color(0xFF6366F1), Color(0xFFA78BFA)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _successAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _successScale = CurvedAnimation(
      parent: _successAnimController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _successAnimController.dispose();
    super.dispose();
  }

  String _formatVnd(double amount) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount)}đ';
  }

  void _onPaymentMethodSelected(int index) {
    setState(() {
      _selectedMethodIndex = index;
      _showQr = false;
      _paymentSuccess = false;
    });
  }

  Future<void> _processPayment() async {
    if (_selectedMethodIndex < 0 || _isProcessing) return;

    final method = _methods[_selectedMethodIndex];

    if (method.name == 'Cash') {
      setState(() {
        _isProcessing = true;
      });
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _paymentSuccess = true;
      });
      _successAnimController.forward();
      return;
    }

    setState(() {
      _showQr = true;
    });

    // Simulate QR display time
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() {
      _isProcessing = true;
    });

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() {
      _isProcessing = false;
      _paymentSuccess = true;
    });
    _successAnimController.forward();
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
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: isDark ? Colors.white : const Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Payment',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        centerTitle: true,
      ),
      body: _paymentSuccess
          ? _buildSuccessView(isDark)
          : _showQr
              ? _buildQrPaymentView(isDark)
              : _buildMethodSelectionView(isDark),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // METHOD SELECTION VIEW
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildMethodSelectionView(bool isDark) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Amount Card ──
                _buildAmountCard(isDark),
                const SizedBox(height: 28),

                // ── Section Title ──
                Text(
                  'SELECT PAYMENT METHOD',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? Colors.grey.shade400
                        : const Color(0xFF475569),
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),

                // ── Payment Methods ──
                ..._methods.asMap().entries.map((entry) {
                  final i = entry.key;
                  final method = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildMethodCard(method, i, isDark),
                  );
                }),

                const SizedBox(height: 20),

                // ── Security Note ──
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E3A5F).withOpacity(0.3)
                        : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF1E3A8A).withOpacity(0.3)
                          : const Color(0xFFBFDBFE),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.shield_rounded,
                        color: isDark
                            ? const Color(0xFF60A5FA)
                            : const Color(0xFF2563EB),
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your payment is secured with 256-bit encryption. We never store your card details.',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? Colors.grey.shade300
                                : const Color(0xFF475569),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Bottom Button ──
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A202C) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                blurRadius: 20,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_selectedMethodIndex >= 0 && !_isProcessing) ? _processPayment : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                backgroundColor: _selectedMethodIndex >= 0
                    ? _methods[_selectedMethodIndex].color
                    : const Color(0xFFE2E8F0),
                disabledBackgroundColor:
                    isDark ? const Color(0xFF2D3748) : const Color(0xFFE2E8F0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                elevation: _selectedMethodIndex >= 0 ? 6 : 0,
                shadowColor: _selectedMethodIndex >= 0
                    ? _methods[_selectedMethodIndex].color.withOpacity(0.4)
                    : Colors.transparent,
              ),
              child: _isProcessing
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white),
                    )
                  : Text(
                      _selectedMethodIndex >= 0
                          ? 'Pay with ${_methods[_selectedMethodIndex].name}'
                          : 'Select a payment method',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: _selectedMethodIndex >= 0
                            ? Colors.white
                            : (isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF0F4C5C), const Color(0xFF1B998B)]
              : [const Color(0xFF0F4C5C), const Color(0xFF1B998B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F4C5C).withOpacity(isDark ? 0.5 : 0.3),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'TOTAL AMOUNT',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _formatVnd(widget.amount),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.receipt_long_rounded,
                    color: Colors.white70, size: 16),
                const SizedBox(width: 8),
                Text(
                  '${widget.sessionId} • ${widget.plateNumber}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodCard(_PaymentMethod method, int index, bool isDark) {
    final isSelected = _selectedMethodIndex == index;

    return GestureDetector(
      onTap: () => _onPaymentMethodSelected(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected
              ? method.color.withOpacity(isDark ? 0.15 : 0.06)
              : (isDark ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? method.color
                : (isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0)),
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: method.color.withOpacity(isDark ? 0.25 : 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isSelected
                      ? method.gradientColors
                      : [
                          method.color.withOpacity(isDark ? 0.2 : 0.1),
                          method.color.withOpacity(isDark ? 0.1 : 0.05),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                method.icon,
                color: isSelected
                    ? Colors.white
                    : method.color,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    method.subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? method.color : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? method.color
                      : (isDark ? Colors.grey.shade600 : Colors.grey.shade300),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 16)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // QR PAYMENT VIEW
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildQrPaymentView(bool isDark) {
    final method = _methods[_selectedMethodIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // ── Method Header ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: method.gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: method.color.withOpacity(0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(method.icon, color: Colors.white, size: 40),
                const SizedBox(height: 12),
                Text(
                  'Pay with ${method.name}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatVnd(widget.amount),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // ── QR Code ──
          Container(
            padding: const EdgeInsets.all(28),
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
                Text(
                  'Scan QR Code to Pay',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: method.color.withOpacity(0.3),
                      width: 3,
                    ),
                  ),
                  child: QrImageView(
                    data:
                        '${method.name}|${widget.sessionId}|${widget.amount}|${DateTime.now().millisecondsSinceEpoch}',
                    version: QrVersions.auto,
                    size: 200,
                    backgroundColor: Colors.white,
                    eyeStyle: QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: method.color,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_isProcessing) ...[
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: method.color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Processing payment...',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                    ),
                  ),
                ] else ...[
                  Text(
                    'Open your ${method.name} app and scan this QR code',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                // Info
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? method.color.withOpacity(0.1)
                        : method.color.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.timer_rounded,
                          color: method.color, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'QR code expires in 5 minutes. Do not close this screen.',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.grey.shade300
                                : const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Change Method ──
          TextButton.icon(
            onPressed: () {
              setState(() {
                _showQr = false;
                _isProcessing = false;
              });
            },
            icon: Icon(Icons.swap_horiz_rounded,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
            label: Text(
              'Change payment method',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SUCCESS VIEW
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildSuccessView(bool isDark) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _successScale,
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
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
                      color: const Color(0xFF059669)
                          .withOpacity(isDark ? 0.5 : 0.3),
                      blurRadius: 32,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: Colors.white, size: 72),
                    const SizedBox(height: 20),
                    const Text(
                      'PAYMENT SUCCESSFUL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatVnd(widget.amount),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'via ${_methods[_selectedMethodIndex].name}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // ── Receipt ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'RECEIPT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? Colors.grey.shade400
                          : const Color(0xFF475569),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildReceiptRow(isDark, 'Transaction ID',
                      'TXN-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}'),
                  _buildReceiptRow(isDark, 'Session', widget.sessionId),
                  _buildReceiptRow(isDark, 'Plate', widget.plateNumber),
                  _buildReceiptRow(isDark, 'Method',
                      _methods[_selectedMethodIndex].name),
                  _buildReceiptRow(isDark, 'Amount',
                      _formatVnd(widget.amount)),
                  _buildReceiptRow(isDark, 'Date',
                      DateFormat('HH:mm – dd/MM/yyyy').format(DateTime.now())),
                  _buildReceiptRow(isDark, 'Status', 'Paid ✓'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Buttons ──
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                icon: const Icon(Icons.home_rounded),
                label: const Text('Back to Home'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: const Color(0xFF0F4C5C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  elevation: 4,
                  shadowColor: const Color(0xFF0F4C5C).withOpacity(0.4),
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(bool isDark, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
            ),
          ),
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
      ),
    );
  }
}

class _PaymentMethod {
  final String name;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<Color> gradientColors;

  const _PaymentMethod({
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.gradientColors,
  });
}
