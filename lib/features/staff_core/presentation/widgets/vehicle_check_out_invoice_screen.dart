import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/staff_core_controller.dart';
import '../../domain/models/parking_session.dart';
import 'payment_confirmation_dialog.dart';
import '../screens/simulated_camera_screen.dart';

/// Màn hình / component Check-out + Invoice.
class VehicleCheckOutInvoiceScreen extends StatefulWidget {
  const VehicleCheckOutInvoiceScreen({
    super.key,
    required this.controller,
    required this.onPaymentCompleted,
  });

  final StaffCoreController controller;
  final VoidCallback onPaymentCompleted;

  @override
  State<VehicleCheckOutInvoiceScreen> createState() =>
      _VehicleCheckOutInvoiceScreenState();
}

class _VehicleCheckOutInvoiceScreenState
    extends State<VehicleCheckOutInvoiceScreen> {
  final _searchController = TextEditingController();

  StaffCoreController get ctrl => widget.controller;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _findSession() {
    final session = ctrl.findActiveSession(_searchController.text);
    if (session == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No parking session found for "${_searchController.text.trim()}"',
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      ctrl.clearCheckoutSelection();
    } else {
      ctrl.selectForCheckout(session);
    }
    setState(() {});
  }

  Future<void> _scanQRCard() async {
    final session = ctrl.latestActiveSession;
    if (session == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No active parking session found.'),
          backgroundColor: Color(0xFFF59E0B),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Hiện màn hình camera mô phỏng
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const SimulatedCameraScreen(
          title: 'Scan Session QR',
          subtitle: 'Detecting QR/Card...',
        ),
      ),
    );

    // Nếu trả về true (quét thành công)
    if (result == true && mounted) {
      _searchController.text = session.plateNumber;
      ctrl.selectForCheckout(session);
      setState(() {});
    }
  }

  Future<void> _confirmPayment() async {
    if (ctrl.selectedCheckoutSession == null) return;
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PaymentConfirmationDialog(
        session: ctrl.selectedCheckoutSession!,
        totalFee: ctrl.totalFee,
      ),
    );
    if (result == true) {
      ctrl.confirmPayment();
      setState(() {});
      widget.onPaymentCompleted();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Payment successful! Session closed.'),
            backgroundColor: Color(0xFF16A34A),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Tiêu đề ──────────────────────────────────────────────────
          const Row(
            children: [
              Icon(Icons.logout_rounded, color: Color(0xFF059669), size: 22),
              SizedBox(width: 10),
              Text(
                'VEHICLE CHECK-OUT',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF059669),
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ─── Tìm kiếm session ─────────────────────────────────────────
          const Text(
            'Search session (License Plate / Session ID)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                  onSubmitted: (_) => _findSession(),
                  decoration: InputDecoration(
                    hintText: 'Ex: 51A-12345 or PS-xxx',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade400,
                    ),
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: Color(0xFF059669)),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          BorderSide(color: Colors.grey.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                          color: Color(0xFF059669), width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _findSession,
                  icon: const Icon(Icons.search_rounded,
                      size: 18, color: Colors.white),
                  label: const Text(
                    'FIND SESSION',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _scanQRCard,
                  icon: const Icon(Icons.qr_code_scanner_rounded,
                      size: 18, color: Color(0xFF059669)),
                  label: const Text(
                    'SCAN QR',
                    style: TextStyle(
                      color: Color(0xFF059669),
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF059669)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            '* Tap SCAN QR to scan parking session code',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF94A3B8),
              fontStyle: FontStyle.italic,
            ),
          ),

          // ─── Empty state ──────────────────────────────────────────────
          if (ctrl.activeVehicleCount == 0) ...[
            const SizedBox(height: 40),
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 40,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No currently parked vehicles',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'All parking sessions have been processed',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
          ]
          // ─── Invoice ──────────────────────────────────────────────────
          else if (ctrl.selectedCheckoutSession != null) ...[
            const SizedBox(height: 24),
            _InvoiceCard(
              session: ctrl.selectedCheckoutSession!,
              fee: ctrl.totalFee,
              onConfirmPayment: _confirmPayment,
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Invoice Card ─────────────────────────────────────────────────────────────

class _InvoiceCard extends StatelessWidget {
  const _InvoiceCard({
    required this.session,
    required this.fee,
    required this.onConfirmPayment,
  });

  final ParkingSession session;
  final double fee;
  final VoidCallback onConfirmPayment;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final durationMin = now.difference(session.checkInTime).inMinutes;
    final hoursRaw = (durationMin / 60).ceil();
    final hours = hoursRaw < 1 ? 1 : hoursRaw;
    final rate = switch (session.vehicleType) {
      'Car' => '15.000 VND/giờ',
      'EV' => '20.000 VND/giờ',
      _ => '5.000 VND/giờ',
    };
    final fmtFee =
        '${_formatMoney(fee)} VND';

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Header invoice
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.receipt_long_rounded,
                        size: 18, color: Color(0xFF475569)),
                    SizedBox(width: 8),
                    Text(
                      'PAYMENT INVOICE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF475569),
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    session.id,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFEA580C),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                _InvoiceRow(
                    label: 'License Plate', value: session.plateNumber),
                const SizedBox(height: 10),
                _InvoiceRow(
                    label: 'Vehicle Type', value: session.vehicleType),
                const SizedBox(height: 10),
                _InvoiceRow(
                  label: 'Time In',
                  value: DateFormat('HH:mm dd/MM/yy')
                      .format(session.checkInTime),
                ),
                const SizedBox(height: 10),
                _InvoiceRow(
                  label: 'Time Out',
                  value: DateFormat('HH:mm dd/MM/yy').format(now),
                ),
                const SizedBox(height: 10),
                _InvoiceRow(
                  label: 'Duration',
                  value: '$durationMin mins (~$hours hours)',
                ),
                const SizedBox(height: 10),
                _InvoiceRow(label: 'Unit Price', value: rate),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: Color(0xFFE2E8F0)),
                ),
                // Total fee nổi bật
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TOTAL AMOUNT',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      fmtFee,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Nút Confirm Payment
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onConfirmPayment,
                icon: const Icon(Icons.payments_rounded,
                    color: Colors.white),
                label: const Text(
                  'CONFIRM PAYMENT',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    letterSpacing: 0.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatMoney(double amount) {
    final str = amount.toInt().toString();
    final buf = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buf.write('.');
      buf.write(str[i]);
      count++;
    }
    return buf.toString().split('').reversed.join();
  }
}

class _InvoiceRow extends StatelessWidget {
  const _InvoiceRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
