import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../controllers/driver_tracking_controller.dart';
import '../../../staff_core/data/models/parking_session_api_model.dart';

/// Màn hình Lịch sử gửi xe & Giao dịch thanh toán – lấy từ API.
class ParkingHistoryScreen extends ConsumerWidget {
  const ParkingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final asyncHistory = ref.watch(parkingHistoryProvider);

    return DefaultTabController(
      length: 1,
      child: Scaffold(
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
        body: asyncHistory.when(
          loading: () =>
              const Center(child: CircularProgressIndicator()),
          error: (e, _) => _buildError(context, isDark, e.toString(), ref),
          data: (historyState) {
            if (historyState.error != null) {
              return _buildError(
                  context, isDark, historyState.error!, ref);
            }
            return _buildBody(context, isDark, historyState, ref);
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, bool isDark,
      ParkingHistoryState historyState, WidgetRef ref) {
    final sessions = historyState.sessions;

    return Column(
      children: [
        // ── Summary Cards ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              _buildSummaryCard(
                isDark: isDark,
                icon: Icons.local_parking_rounded,
                iconColor: const Color(0xFF3B82F6),
                label: 'Total Sessions',
                value: '${sessions.length}',
              ),
              const SizedBox(width: 12),
              _buildSummaryCard(
                isDark: isDark,
                icon: Icons.payments_rounded,
                iconColor: const Color(0xFF059669),
                label: 'Total Spent',
                value: _formatCurrency(historyState.totalSpent),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // ── Content ──
        Expanded(
          child: sessions.isEmpty
              ? _buildEmpty(isDark, ref)
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 8),
                  itemCount: sessions.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 12),
                  itemBuilder: (_, i) =>
                      _buildSessionCard(sessions[i], isDark),
                ),
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context, bool isDark, String message,
      WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded,
                size: 64,
                color: isDark
                    ? Colors.grey.shade600
                    : Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('Failed to load history',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? Colors.white
                        : const Color(0xFF0F172A))),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? Colors.grey.shade400
                        : Colors.grey.shade600)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () =>
                  ref.read(parkingHistoryProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(bool isDark, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.history_rounded,
                  size: 64,
                  color: isDark
                      ? Colors.grey.shade600
                      : Colors.grey.shade400),
            ),
            const SizedBox(height: 24),
            Text(
              'No History Yet',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? Colors.white
                      : const Color(0xFF0F172A)),
            ),
            const SizedBox(height: 8),
            Text(
              'Your completed parking sessions will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? Colors.grey.shade400
                      : Colors.grey.shade600,
                  height: 1.5),
            ),
          ],
        ),
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
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
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
                color: iconColor.withOpacity(isDark ? 0.15 : 0.08),
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
                color: isDark
                    ? Colors.grey.shade400
                    : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCard(ParkingSessionApiModel session, bool isDark) {
    final duration = session.exitTime != null
        ? session.exitTime!.difference(session.entryTime)
        : DateTime.now().difference(session.entryTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final durationText =
        hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';

    final statusColor = switch (session.status) {
      'completed' => const Color(0xFF16A34A),
      'active' => const Color(0xFF3B82F6),
      _ => const Color(0xFFEF4444),
    };

    final isMotorbike =
        session.vehicleTypeName.toLowerCase().contains('motor');

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF064E3B).withOpacity(0.4)
                      : const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isMotorbike
                      ? Icons.two_wheeler_rounded
                      : Icons.directions_car_filled_rounded,
                  color: isDark
                      ? const Color(0xFF34D399)
                      : const Color(0xFF059669),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              // Left: plate + status + location
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            session.licensePlate.isNotEmpty
                                ? session.licensePlate
                                : session.vehicleTypeName,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                              letterSpacing: 0.3,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            session.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: statusColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Floor/zone on one line
                    Text(
                      '${session.floorName}${session.zoneName != null ? ' – ${session.zoneName}' : ''}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 3),
                    // Slot as compact chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.07)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        session.slotCode,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? Colors.grey.shade300
                              : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Right: fee + duration
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatCurrency(session.totalFee),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: isDark
                          ? const Color(0xFF34D399)
                          : const Color(0xFF059669),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    durationText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(
            color:
                isDark ? Colors.grey.shade700 : Colors.grey.shade100,
            height: 1,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.login_rounded,
                  size: 14,
                  color: isDark
                      ? Colors.grey.shade500
                      : Colors.grey.shade400),
              const SizedBox(width: 6),
              Text(
                DateFormat('HH:mm dd/MM').format(session.entryTime),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? Colors.grey.shade400
                      : Colors.grey.shade500,
                ),
              ),
              if (session.exitTime != null) ...[
                const SizedBox(width: 12),
                Icon(Icons.arrow_forward_rounded,
                    size: 14,
                    color: isDark
                        ? Colors.grey.shade600
                        : Colors.grey.shade300),
                const SizedBox(width: 12),
                Icon(Icons.logout_rounded,
                    size: 14,
                    color: isDark
                        ? Colors.grey.shade500
                        : Colors.grey.shade400),
                const SizedBox(width: 6),
                Text(
                  DateFormat('HH:mm dd/MM')
                      .format(session.exitTime!),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? Colors.grey.shade400
                        : Colors.grey.shade500,
                  ),
                ),
              ],
              const Spacer(),
              // Payment status badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: session.isPaid
                      ? const Color(0xFF059669).withOpacity(0.1)
                      : const Color(0xFFEF4444).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: session.isPaid
                            ? const Color(0xFF059669)
                            : const Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      session.isPaid ? 'PAID' : 'UNPAID',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: session.isPaid
                            ? const Color(0xFF059669)
                            : const Color(0xFFEF4444),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
            locale: 'vi_VN', symbol: '₫', decimalDigits: 0)
        .format(amount);
  }
}
