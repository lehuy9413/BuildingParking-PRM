import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Màn hình Lịch sử gửi xe & Giao dịch thanh toán.
class ParkingHistoryScreen extends StatefulWidget {
  const ParkingHistoryScreen({super.key});

  @override
  State<ParkingHistoryScreen> createState() => _ParkingHistoryScreenState();
}

class _ParkingHistoryScreenState extends State<ParkingHistoryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Mock Data ──
  static final List<_ParkingRecord> _parkingHistory = [
    _ParkingRecord(
      id: 'PS-84721',
      plateNumber: '51A-123.45',
      vehicleType: 'Car',
      slotNumber: 'C-14',
      floor: 'Floor 2',
      zone: 'Zone C',
      checkIn: DateTime.now().subtract(const Duration(hours: 3, minutes: 15)),
      checkOut: DateTime.now().subtract(const Duration(minutes: 38)),
      fee: 10.00,
      status: 'completed',
    ),
    _ParkingRecord(
      id: 'PS-84690',
      plateNumber: '51A-123.45',
      vehicleType: 'Car',
      slotNumber: 'A-07',
      floor: 'Tầng 1',
      zone: 'Zone A',
      checkIn: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
      checkOut: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      fee: 9.00,
      status: 'completed',
    ),
    _ParkingRecord(
      id: 'PS-84655',
      plateNumber: '51A-123.45',
      vehicleType: 'Car',
      slotNumber: 'B-22',
      floor: 'B1',
      zone: 'Zone B',
      checkIn: DateTime.now().subtract(const Duration(days: 2, hours: 8)),
      checkOut: DateTime.now().subtract(const Duration(days: 2, hours: 6)),
      fee: 6.00,
      status: 'completed',
    ),
    _ParkingRecord(
      id: 'PS-84510',
      plateNumber: '51A-123.45',
      vehicleType: 'Car',
      slotNumber: 'C-03',
      floor: 'Floor 2',
      zone: 'Zone C',
      checkIn: DateTime.now().subtract(const Duration(days: 4, hours: 10)),
      checkOut: DateTime.now().subtract(const Duration(days: 4, hours: 5)),
      fee: 15.00,
      status: 'completed',
    ),
    _ParkingRecord(
      id: 'PS-84401',
      plateNumber: '51A-123.45',
      vehicleType: 'Car',
      slotNumber: 'D-11',
      floor: 'Rooftop',
      zone: 'Zone D',
      checkIn: DateTime.now().subtract(const Duration(days: 7, hours: 3)),
      checkOut: DateTime.now().subtract(const Duration(days: 7, hours: 1)),
      fee: 6.00,
      status: 'completed',
    ),
  ];

  static final List<_PaymentRecord> _paymentHistory = [
    _PaymentRecord(
      id: 'TXN-20241201',
      sessionId: 'PS-84721',
      method: 'MoMo',
      amount: 10.00,
      date: DateTime.now().subtract(const Duration(minutes: 38)),
      status: 'success',
    ),
    _PaymentRecord(
      id: 'TXN-20241130',
      sessionId: 'PS-84690',
      method: 'ZaloPay',
      amount: 9.00,
      date: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      status: 'success',
    ),
    _PaymentRecord(
      id: 'TXN-20241129',
      sessionId: 'PS-84655',
      method: 'Bank QR',
      amount: 6.00,
      date: DateTime.now().subtract(const Duration(days: 2, hours: 6)),
      status: 'success',
    ),
    _PaymentRecord(
      id: 'TXN-20241125',
      sessionId: 'PS-84510',
      method: 'MoMo',
      amount: 15.00,
      date: DateTime.now().subtract(const Duration(days: 4, hours: 5)),
      status: 'success',
    ),
    _PaymentRecord(
      id: 'TXN-20241118',
      sessionId: 'PS-84401',
      method: 'Cash',
      amount: 6.00,
      date: DateTime.now().subtract(const Duration(days: 7, hours: 1)),
      status: 'success',
    ),
  ];

  String _formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
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
          'History & Receipts',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
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
                  value: '${_parkingHistory.length}',
                ),
                const SizedBox(width: 12),
                _buildSummaryCard(
                  isDark: isDark,
                  icon: Icons.payments_rounded,
                  iconColor: const Color(0xFF059669),
                  label: 'Total Spent',
                  value: _formatCurrency(
                    _paymentHistory.fold(0.0, (sum, p) => sum + p.amount),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── Tab Bar ──
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(4),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: isDark ? const Color(0xFF0F4C5C) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: isDark ? Colors.white : const Color(0xFF0F172A),
              unselectedLabelColor:
                  isDark ? Colors.grey.shade500 : Colors.grey.shade500,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Parking History'),
                Tab(text: 'Payments'),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Tab Content ──
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildParkingHistoryTab(isDark),
                _buildPaymentHistoryTab(isDark),
              ],
            ),
          ),
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
                fontSize: 22,
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

  // ── Parking History Tab ──

  Widget _buildParkingHistoryTab(bool isDark) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: _parkingHistory.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final record = _parkingHistory[i];
        return _buildParkingCard(record, isDark);
      },
    );
  }

  Widget _buildParkingCard(_ParkingRecord record, bool isDark) {
    final duration = record.checkOut.difference(record.checkIn);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final durationText = hours > 0
        ? '${hours}h ${minutes}m'
        : '${minutes}m';

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
                  Icons.directions_car_filled_rounded,
                  color: isDark
                      ? const Color(0xFF34D399)
                      : const Color(0xFF059669),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          record.plateNumber,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF16A34A).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'COMPLETED',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF16A34A),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${record.floor} • ${record.zone} • ${record.slotNumber}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatCurrency(record.fee),
                    style: TextStyle(
                      fontSize: 16,
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
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
            height: 1,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.login_rounded,
                  size: 14,
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade400),
              const SizedBox(width: 6),
              Text(
                DateFormat('HH:mm dd/MM').format(record.checkIn),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.arrow_forward_rounded,
                  size: 14,
                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade300),
              const SizedBox(width: 12),
              Icon(Icons.logout_rounded,
                  size: 14,
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade400),
              const SizedBox(width: 6),
              Text(
                DateFormat('HH:mm dd/MM').format(record.checkOut),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                ),
              ),
              const Spacer(),
              Text(
                record.id,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Payments Tab ──

  Widget _buildPaymentHistoryTab(bool isDark) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: _paymentHistory.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final record = _paymentHistory[i];
        return _buildPaymentCard(record, isDark);
      },
    );
  }

  Widget _buildPaymentCard(_PaymentRecord record, bool isDark) {
    final methodIcon = switch (record.method) {
      'MoMo' => Icons.account_balance_wallet_rounded,
      'ZaloPay' => Icons.wallet_rounded,
      'Bank QR' => Icons.qr_code_rounded,
      _ => Icons.payments_rounded,
    };
    final methodColor = switch (record.method) {
      'MoMo' => const Color(0xFFAE2070),
      'ZaloPay' => const Color(0xFF0068FF),
      'Bank QR' => const Color(0xFF059669),
      _ => const Color(0xFF6366F1),
    };

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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: methodColor.withOpacity(isDark ? 0.2 : 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(methodIcon, color: methodColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.method,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${record.id} • ${record.sessionId}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('HH:mm – dd/MM/yyyy').format(record.date),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '-${_formatCurrency(record.amount)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF16A34A),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'SUCCESS',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF16A34A),
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
}

// ── Data Models ──

class _ParkingRecord {
  final String id;
  final String plateNumber;
  final String vehicleType;
  final String slotNumber;
  final String floor;
  final String zone;
  final DateTime checkIn;
  final DateTime checkOut;
  final double fee;
  final String status;

  const _ParkingRecord({
    required this.id,
    required this.plateNumber,
    required this.vehicleType,
    required this.slotNumber,
    required this.floor,
    required this.zone,
    required this.checkIn,
    required this.checkOut,
    required this.fee,
    required this.status,
  });
}

class _PaymentRecord {
  final String id;
  final String sessionId;
  final String method;
  final double amount;
  final DateTime date;
  final String status;

  const _PaymentRecord({
    required this.id,
    required this.sessionId,
    required this.method,
    required this.amount,
    required this.date,
    required this.status,
  });
}
