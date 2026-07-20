import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/models/parking_session.dart';
import '../controllers/staff_core_controller.dart';

/// Dialog xác nhận thanh toán với 2 phương thức: Cash và QR (VietQR/SEPay).
class PaymentConfirmationDialog extends StatefulWidget {
  const PaymentConfirmationDialog({
    super.key,
    required this.session,
    required this.totalFee,
    required this.sessionId,
    required this.controller,
  });

  final ParkingSession session;
  final double totalFee;
  final String sessionId;
  final StaffCoreController controller;

  @override
  State<PaymentConfirmationDialog> createState() =>
      _PaymentConfirmationDialogState();
}

class _PaymentConfirmationDialogState
    extends State<PaymentConfirmationDialog> {
  String _method = ''; // '' | 'cash' | 'qr'
  bool _processing = false;

  // QR payment state
  String? _qrUrl;
  String? _qrPaymentId;
  String? _transferContent;
  Map<String, dynamic>? _bankInfo;
  String _qrStatus = 'pending'; // pending | completed
  bool _qrLoading = false;

  String _formatMoney(double amount) {
    final str = amount.toInt().toString();
    final buf = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buf.write('.');
      buf.write(str[i]);
      count++;
    }
    return '${buf.toString().split('').reversed.join()} VND';
  }

  Future<void> _handleCashConfirm() async {
    setState(() => _processing = true);
    try {
      if (widget.controller.checkoutApiSession?.id != widget.sessionId) {
        await widget.controller.checkOutApi(widget.sessionId);
      }
      await widget.controller.confirmCashPaymentApi(
        sessionId: widget.sessionId,
        cashReceived: widget.controller.totalFee, // exact amount
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() => _processing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  Future<void> _generateQr() async {
    setState(() => _qrLoading = true);
    try {
      if (widget.controller.checkoutApiSession?.id != widget.sessionId) {
        await widget.controller.checkOutApi(widget.sessionId);
      }
      final data = await widget.controller.initiateQrPaymentApi(widget.sessionId);
      setState(() {
        _qrUrl = data['qrUrl']?.toString();
        _qrPaymentId = data['payment']?['_id']?.toString() ??
            data['payment']?.toString();
        _transferContent = data['transferContent']?.toString();
        _bankInfo = data['bankInfo'] as Map<String, dynamic>?;
        _qrLoading = false;
      });
      // Bắt đầu polling status
      _pollQrStatus();
    } catch (e) {
      setState(() => _qrLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('QR error: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  Future<void> _pollQrStatus() async {
    if (_qrPaymentId == null) return;
    // Poll mỗi 3 giây tối đa 10 lần
    for (int i = 0; i < 10; i++) {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;
      final status = await widget.controller.checkQrStatus(_qrPaymentId!);
      if (status == 'completed') {
        setState(() => _qrStatus = 'completed');
        await widget.controller.checkOutApi(widget.sessionId);
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) Navigator.of(context).pop(true);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ─── Header ────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1D4ED8), Color(0xFF2563EB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
              children: [
                const Icon(Icons.payments_rounded,
                    color: Colors.white, size: 36),
                const SizedBox(height: 10),
                const Text(
                  'CONFIRM PAYMENT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.session.plateNumber,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
            Positioned(
              top: -10,
              right: -10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ),
          ],
        ),
      ),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ─── Tổng tiền (Đã ẩn theo yêu cầu) ─────────────────────
                  const Text(
                    'Select Payment Method',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ─── Phương thức ──────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _MethodCard(
                          label: 'Cash',
                          icon: Icons.payments_outlined,
                          color: const Color(0xFF16A34A),
                          isSelected: _method == 'cash',
                          onTap: () => setState(() {
                            _method = 'cash';
                            _qrUrl = null;
                          }),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MethodCard(
                          label: 'QR Payment',
                          icon: Icons.qr_code_2_rounded,
                          color: const Color(0xFF2563EB),
                          isSelected: _method == 'qr',
                          onTap: () {
                            setState(() => _method = 'qr');
                            if (_qrUrl == null && !_qrLoading) _generateQr();
                          },
                        ),
                      ),
                    ],
                  ),

                  // ─── Cash section ─────────────────────────────────────
                  if (_method == 'cash') ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              color: Color(0xFF16A34A), size: 20),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Collect cash from customer then click Confirm.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF166534),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // ─── QR section ───────────────────────────────────────
                  if (_method == 'qr') ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          if (_qrLoading)
                            const CircularProgressIndicator()
                          else if (_qrStatus == 'completed')
                            ...[
                              const Icon(Icons.check_circle_rounded,
                                  color: Color(0xFF16A34A), size: 64),
                              const SizedBox(height: 8),
                              const Text('Payment successful!',
                                  style: TextStyle(
                                      color: Color(0xFF16A34A),
                                      fontWeight: FontWeight.w700)),
                            ]
                          else if (_qrUrl != null) ...[
                            // QR từ VietQR thực
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: _qrUrl!,
                                width: 200,
                                height: 200,
                                placeholder: (_, __) => const SizedBox(
                                  width: 200,
                                  height: 200,
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                ),
                                errorWidget: (_, __, ___) => Container(
                                  width: 200,
                                  height: 200,
                                  color: const Color(0xFFF1F5F9),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.qr_code_2_rounded,
                                          size: 80,
                                          color: Color(0xFF1D4ED8)),
                                      SizedBox(height: 8),
                                      Text('Scan QR to pay',
                                          style: TextStyle(
                                              color: Color(0xFF64748B))),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (_bankInfo != null) ...[
                              Text(
                                '${_bankInfo!['bankName']} • ${_bankInfo!['accountNumber']}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF374151),
                                ),
                              ),
                              const SizedBox(height: 4),
                            ],
                            if (_transferContent != null)
                              Text(
                                'Transfer code: $_transferContent',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            const SizedBox(height: 8),
                            const Text(
                              'Waiting for payment...',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF94A3B8),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ] else ...[
                            const Icon(Icons.qr_code_2_rounded,
                                size: 80, color: Color(0xFF1D4ED8)),
                            const SizedBox(height: 8),
                            const Text('Generating QR code...',
                                style:
                                    TextStyle(color: Color(0xFF94A3B8))),
                          ],
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // ─── Confirm button ───────────────────────────────────
                  if (_method == 'cash')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _processing ? null : _handleCashConfirm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16A34A),
                          disabledBackgroundColor: Colors.grey.shade200,
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: _processing
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white),
                              )
                            : const Text(
                                'CONFIRM CASH PAYMENT',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  letterSpacing: 0.3,
                                ),
                              ),
                      ),
                    )
                  else if (_method.isEmpty)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: null,
                        style: ElevatedButton.styleFrom(
                          disabledBackgroundColor: Colors.grey.shade200,
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: Text(
                          'SELECT PAYMENT METHOD',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),


                ],
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}

// ─── Method Card ─────────────────────────────────────────────────────────────

class _MethodCard extends StatelessWidget {
  const _MethodCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: isSelected ? color : Colors.grey.shade500, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isSelected ? color : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
