import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../controllers/driver_tracking_controller.dart';
import '../../../staff_core/data/models/parking_session_api_model.dart';
import '../../../driver_booking/data/datasources/api_booking_datasource.dart';
import '../../../driver_booking/domain/entities/booking.dart';
import '../../data/driver_tracking_datasource.dart';
import '../../../../core/utils/vehicle_icon_helper.dart';

/// Màn hình Lịch sử gửi xe & Giao dịch thanh toán – lấy từ API.
class ParkingHistoryScreen extends ConsumerWidget {
  const ParkingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            'History & Receipts',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.refresh_rounded,
                  color: isDark ? Colors.white : const Color(0xFF0F172A)),
              onPressed: () =>
                  ref.read(parkingHistoryProvider.notifier).refresh(),
            ),
          ],
        ),
        body: const _BookingsTab(),
      );
  }
}

// ─── Bookings Tab ────────────────────────────────────────────────────────────

class _BookingsTab extends StatefulWidget {
  const _BookingsTab();

  @override
  State<_BookingsTab> createState() => _BookingsTabState();
}

class _BookingsTabState extends State<_BookingsTab> {
  final _ds = ApiBookingDataSource();
  final _sessionDs = DriverTrackingDatasource();
  List<Booking> _bookings = [];
  List<ParkingSessionApiModel> _walkinSessions = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final results = await Future.wait([
        _ds.getMyBookings(),
        _sessionDs.getMySessionHistory(),
      ]);
      final bookings = results[0] as List<Booking>;
      final sessions = results[1] as List<ParkingSessionApiModel>;
      // Walk-in = sessions not linked to any booking
      final walkins = sessions.where((s) => s.bookingId == null || s.bookingId!.isEmpty).toList();
      bookings.sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));
      walkins.sort((a, b) => b.entryTime.compareTo(a.entryTime));
      if (mounted) setState(() {
        _bookings = bookings;
        _walkinSessions = walkins;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString().replaceAll('Exception: ', ''); _isLoading = false; });
    }
  }

  // A booking is "done" if: completed, or approved past its actual end datetime
  bool _isDone(Booking b) {
    if (b.status == BookingStatus.completed) return true;
    if (b.status == BookingStatus.approved) {
      try {
        final sParts = b.startTime.split(':');
        final eParts = b.endTime.split(':');
        final startMin = int.parse(sParts[0]) * 60 + int.parse(sParts[1]);
        final endMin   = int.parse(eParts[0]) * 60 + int.parse(eParts[1]);
        var endDt = DateTime(
          b.scheduledDate.year, b.scheduledDate.month, b.scheduledDate.day,
          int.parse(eParts[0]), int.parse(eParts[1]),
        );
        // Overnight booking: endTime < startTime means it ends the next day
        if (endMin < startMin) endDt = endDt.add(const Duration(days: 1));
        return DateTime.now().isAfter(endDt);
      } catch (_) {
        return b.scheduledDate.isBefore(DateTime.now());
      }
    }
    return false;
  }

  int get _totalBookings => _bookings.where(_isDone).length + _walkinSessions.length;

  double get _totalSpent {
    final bookingTotal = _bookings
        .where(_isDone)
        .fold(0.0, (sum, b) => sum + (b.actualFee ?? b.estimatedFee));
    final sessionTotal = _walkinSessions.fold(0.0, (sum, s) => sum + s.totalFee);
    return bookingTotal + sessionTotal;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF0B7A59)));
    }
    
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      color: const Color(0xFF0B7A59),
      onRefresh: _load,
      child: CustomScrollView(
        slivers: [
          // ── Bookings Section ──────────────────────────────────────────
          if (_bookings.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.qr_code_rounded, color: Color(0xFF3B82F6), size: 16),
                    ),
                    const SizedBox(width: 10),
                    Text('Reservations',
                        style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1,
                          color: isDark ? Colors.grey.shade400 : const Color(0xFF475569),
                        )),
                  ],
                ),
              ),
            ),

          if (_bookings.isEmpty && _walkinSessions.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.receipt_long_rounded, size: 48,
                          color: isDark ? Colors.grey.shade500 : Colors.grey.shade400),
                    ),
                    const SizedBox(height: 20),
                    Text('No History Yet',
                        style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        )),
                    const SizedBox(height: 8),
                    Text('Your parking history will appear here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                        )),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _BookingCard(booking: _bookings[i], isDark: isDark),
                childCount: _bookings.length,
              ),
            ),

          // ── Walk-in Sessions Section ───────────────────────────────────
          if (_walkinSessions.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.directions_car_rounded, color: Color(0xFF10B981), size: 16),
                    ),
                    const SizedBox(width: 10),
                    Text('Walk-in Sessions',
                        style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1,
                          color: isDark ? Colors.grey.shade400 : const Color(0xFF475569),
                        )),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _WalkinSessionCard(session: _walkinSessions[i], isDark: isDark),
                childCount: _walkinSessions.length,
              ),
            ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: isDark ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(height: 14),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking, required this.isDark});
  final Booking booking;
  final bool isDark;

  Color get _statusColor {
    switch (booking.status) {
      case BookingStatus.completed: return const Color(0xFF10B981); // green
      case BookingStatus.approved:  return const Color(0xFF3B82F6); // blue
      case BookingStatus.pending:   return const Color(0xFFF59E0B); // amber
      case BookingStatus.cancelled: return Colors.grey;
      case BookingStatus.rejected:  return const Color(0xFFEF4444); // red
      case BookingStatus.noShow:    return const Color(0xFFEF4444); // red
    }
  }

  String get _statusLabel {
    switch (booking.status) {
      case BookingStatus.completed: return 'Used';
      case BookingStatus.approved:  return 'Approved';
      case BookingStatus.pending:   return 'Pending';
      case BookingStatus.cancelled: return 'Cancelled';
      case BookingStatus.rejected:  return 'Rejected';
      case BookingStatus.noShow:    return 'Expired';
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,###', 'vi_VN');
    final dateStr = DateFormat('dd MMM yyyy').format(booking.scheduledDate);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: InkWell(
        onTap: () => _showDetail(context),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                blurRadius: 16, offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    booking.status == BookingStatus.completed
                        ? Icons.check_circle_rounded
                        : booking.status == BookingStatus.approved
                            ? Icons.qr_code_rounded
                            : Icons.receipt_long_rounded,
                    color: _statusColor, size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(booking.parkingLotName.isNotEmpty ? booking.parkingLotName : 'Parking Lot',
                          style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text('$dateStr · ${booking.startTime}–${booking.endTime}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w500,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                          )),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _statusColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(_statusLabel,
                                style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w700,
                                  color: _statusColor,
                                )),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(booking.licensePlate,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                                )),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${fmt.format((booking.actualFee ?? booking.estimatedFee).toInt())} đ',
                        style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        )),
                    const SizedBox(height: 4),
                    Icon(Icons.chevron_right_rounded,
                        color: isDark ? Colors.grey.shade600 : Colors.grey.shade400, size: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BookingDetailSheet(booking: booking, isDark: isDark),
    );
  }
}

class _BookingDetailSheet extends StatelessWidget {
  const _BookingDetailSheet({required this.booking, required this.isDark});
  final Booking booking;
  final bool isDark;

  String _formatDuration(String start, String end) {
    try {
      final s = start.split(':');
      final e = end.split(':');
      var diff = (int.parse(e[0]) * 60 + int.parse(e[1])) - (int.parse(s[0]) * 60 + int.parse(s[1]));
      if (diff < 0) diff += 1440;
      final h = diff ~/ 60, m = diff % 60;
      if (h == 0) return '$m min';
      if (m == 0) return '$h h';
      return '$h h $m min';
    } catch (_) { return 'N/A'; }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,###', 'vi_VN');
    final hasOvertime = booking.overtimeFee != null && booking.overtimeFee! > 0;
    final hasActual = booking.actualFee != null;
    final dateStr = DateFormat('dd MMM yyyy').format(booking.scheduledDate);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, ctrl) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF7F9FB),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Text('Booking Detail',
                      style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      )),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close_rounded,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: ctrl,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // QR Code
                  _buildQrSection(context),
                  const SizedBox(height: 20),

                  // Booking Info
                  _buildCard(isDark, children: [
                    _row(Icons.location_on_rounded, const Color(0xFF3B82F6), 'Parking', booking.parkingLotName.isNotEmpty ? booking.parkingLotName : '—'),
                    _divider(),
                    _row(Icons.local_parking_rounded, const Color(0xFF0B7A59), 'Slot', booking.slotCode ?? 'Auto-assigned'),
                    _divider(),
                    _row(Icons.layers_rounded, const Color(0xFF8B5CF6), 'Floor / Zone',
                        [booking.floorName, booking.zoneName].where((e) => e != null).join(' / ').isNotEmpty
                            ? [booking.floorName, booking.zoneName].where((e) => e != null).join(' / ')
                            : 'Auto-assigned'),
                    _divider(),
                    _row(VehicleIconHelper.getIconForVehicleType(booking.vehicleTypeName), const Color(0xFFF59E0B), 'Vehicle', '${booking.vehicleTypeName} · ${booking.licensePlate}'),
                    _divider(),
                    _row(Icons.login_rounded, const Color(0xFF10B981), 'Check-in', '${booking.startTime} — $dateStr'),
                    _divider(),
                    _row(Icons.logout_rounded, const Color(0xFFEF4444), 'Check-out', '${booking.endTime} — $dateStr'),
                    _divider(),
                    _row(Icons.timer_rounded, const Color(0xFFF59E0B), 'Duration', _formatDuration(booking.startTime, booking.endTime)),
                  ]),
                  const SizedBox(height: 16),

                  // Fee Breakdown
                  _buildCard(isDark, children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text('Fee Breakdown',
                          style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                          )),
                    ),
                    _feeRow('Booking Deposit', fmt.format(booking.estimatedFee.toInt()), isDark, isDeposit: true),
                    if (hasOvertime) ...[
                      _divider(),
                      _feeRow('Overtime Fee', fmt.format(booking.overtimeFee!.toInt()), isDark, isOvertime: true),
                    ],
                    _divider(),
                    _totalRow(
                      hasActual ? fmt.format(booking.actualFee!.toInt()) : fmt.format(booking.estimatedFee.toInt()),
                      isDark,
                    ),
                    if (hasOvertime || hasActual)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFFF59E0B)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  hasOvertime
                                      ? 'Overtime fee was charged for exceeding the reserved period.'
                                      : 'Actual fee may differ from estimate due to real checkout time.',
                                  style: const TextStyle(fontSize: 11, color: Color(0xFFF59E0B), fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ]),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrSection(BuildContext context) {
    // Dùng bookingCode (giống digital_ticket_screen.dart), fallback về id nếu rỗng
    final qrData = booking.bookingCode.isNotEmpty ? booking.bookingCode : booking.id;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 16, offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text('# ${booking.bookingCode.isNotEmpty ? booking.bookingCode : booking.id}',
              style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1.5,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
              )),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 160,
              backgroundColor: Colors.white,
              eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Color(0xFF0F4C5C)),
              dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Color(0xFF0F172A)),
            ),
          ),
          const SizedBox(height: 12),
          Text('Scan at parking gate',
              style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
              )),
        ],
      ),
    );
  }

  Widget _buildCard(bool isDark, {required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 12, offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _row(IconData icon, Color color, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 90,
            child: Text(label,
                style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                )),
          ),
          Expanded(
            child: Text(value,
                style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
                textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }

  Widget _feeRow(String label, String amount, bool isDark, {bool isDeposit = false, bool isOvertime = false}) {
    final color = isOvertime ? const Color(0xFFEF4444) : (isDark ? Colors.grey.shade300 : const Color(0xFF475569));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(
            isOvertime ? Icons.timer_off_rounded : Icons.receipt_rounded,
            size: 16,
            color: isOvertime ? const Color(0xFFEF4444) : (isDark ? Colors.grey.shade400 : Colors.grey.shade500),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color))),
          Text('$amount đ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }

  Widget _totalRow(String amount, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Total Paid',
              style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              )),
          Text('$amount đ',
              style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.w900,
                color: Color(0xFF0B7A59),
              )),
        ],
      ),
    );
  }

  Widget _divider() => Divider(
    color: isDark ? Colors.grey.shade700.withValues(alpha: 0.5) : Colors.grey.shade100,
    height: 1,
  );
}

// ─── Walk-in Session Card ─────────────────────────────────────────────────────

class _WalkinSessionCard extends StatelessWidget {
  const _WalkinSessionCard({required this.session, required this.isDark});
  final ParkingSessionApiModel session;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,###', 'vi_VN');
    final dateStr = DateFormat('dd MMM yyyy').format(session.entryTime);
    final timeIn = DateFormat('HH:mm').format(session.entryTime);
    final timeOut = session.exitTime != null ? DateFormat('HH:mm').format(session.exitTime!) : '--:--';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: InkWell(
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => _WalkinSessionDetailSheet(session: session, isDark: isDark),
        ),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                blurRadius: 16, offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(VehicleIconHelper.getIconForVehicleType(session.vehicleTypeName),
                      color: const Color(0xFF10B981), size: 26),
                ),
                const SizedBox(width: 14),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(session.licensePlate,
                          style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          )),
                      const SizedBox(height: 4),
                      Text('$dateStr · $timeIn – $timeOut',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w500,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                          )),
                      const SizedBox(height: 6),
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Completed',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                                  color: Color(0xFF10B981))),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text('${session.floorName} · ${session.slotCode}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade400)),
                        ),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${fmt.format(session.totalFee.toInt())} đ',
                        style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        )),
                    const SizedBox(height: 4),
                    Icon(Icons.chevron_right_rounded,
                        color: isDark ? Colors.grey.shade600 : Colors.grey.shade400, size: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Walk-in Session Detail Sheet ────────────────────────────────────────────

class _WalkinSessionDetailSheet extends StatelessWidget {
  const _WalkinSessionDetailSheet({required this.session, required this.isDark});
  final ParkingSessionApiModel session;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,###', 'vi_VN');
    final entryStr = DateFormat('HH:mm – dd/MM/yyyy').format(session.entryTime);
    final exitStr = session.exitTime != null
        ? DateFormat('HH:mm – dd/MM/yyyy').format(session.exitTime!)
        : 'In progress';

    Duration? dur;
    String durStr = 'N/A';
    if (session.exitTime != null) {
      dur = session.exitTime!.difference(session.entryTime);
      final h = dur.inHours;
      final m = dur.inMinutes % 60;
      durStr = h > 0 ? (m > 0 ? '$h h $m min' : '$h h') : '$m min';
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.92,
      minChildSize: 0.4,
      builder: (_, ctrl) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF7F9FB),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Text('Session Detail',
                      style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      )),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close_rounded,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: ctrl,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Session code banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06), blurRadius: 16, offset: const Offset(0, 6))],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(VehicleIconHelper.getIconForVehicleType(session.vehicleTypeName), color: const Color(0xFF10B981), size: 28),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(session.licensePlate,
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A), letterSpacing: 2)),
                            const SizedBox(height: 4),
                            Text(session.sessionCode,
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade400, letterSpacing: 1)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Details card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04), blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: Column(children: [
                      _sRow(Icons.local_parking_rounded, const Color(0xFF3B82F6), 'Slot', '${session.floorName} · ${session.slotCode}', isDark),
                      Divider(color: isDark ? Colors.grey.shade800 : Colors.grey.shade100, height: 1),
                      _sRow(Icons.login_rounded, const Color(0xFF10B981), 'Check-in', entryStr, isDark),
                      Divider(color: isDark ? Colors.grey.shade800 : Colors.grey.shade100, height: 1),
                      _sRow(Icons.logout_rounded, const Color(0xFFEF4444), 'Check-out', exitStr, isDark),
                      Divider(color: isDark ? Colors.grey.shade800 : Colors.grey.shade100, height: 1),
                      _sRow(Icons.timer_rounded, const Color(0xFFF59E0B), 'Duration', durStr, isDark),
                      Divider(color: isDark ? Colors.grey.shade800 : Colors.grey.shade100, height: 1),
                      _sRow(VehicleIconHelper.getIconForVehicleType(session.vehicleTypeName), const Color(0xFF8B5CF6), 'Vehicle Type', session.vehicleTypeName, isDark),
                    ]),
                  ),
                  const SizedBox(height: 16),

                  // Fee card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04), blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Paid',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : const Color(0xFF0F172A))),
                        Text('${fmt.format(session.totalFee.toInt())} đ',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900,
                                color: Color(0xFF0B7A59))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sRow(IconData icon, Color color, String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(9)),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        SizedBox(width: 90, child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.grey.shade400 : Colors.grey.shade500))),
        Expanded(child: Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF0F172A)), textAlign: TextAlign.end)),
      ]),
    );
  }
}
