import 'package:flutter/material.dart';
import '../../domain/models/exception_models.dart';

/// Màn hình danh sách cảnh báo xe:
/// - Xe quá hạn gửi (Long-term parking)
/// - Xe đỗ sai khu vực
class AlertVehiclesScreen extends StatefulWidget {
  const AlertVehiclesScreen({super.key});

  @override
  State<AlertVehiclesScreen> createState() => _AlertVehiclesScreenState();
}

class _AlertVehiclesScreenState extends State<AlertVehiclesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ─── Mock data ──────────────────────────────────────────────────────────
  final _allAlerts = [
    VehicleAlert(
      id: 'AL-001',
      plateNumber: '51A-12345',
      vehicleType: 'Car',
      zone: 'Floor 2 - Zone C',
      slotLabel: 'C07',
      alertType: VehicleAlertType.overdue,
      checkInTime: DateTime.now().subtract(const Duration(hours: 26)),
      overdueHours: 2,
    ),
    VehicleAlert(
      id: 'AL-002',
      plateNumber: '30G-55678',
      vehicleType: 'Motorbike',
      zone: 'B1 - Zone M',
      slotLabel: 'M15',
      alertType: VehicleAlertType.overdue,
      checkInTime: DateTime.now().subtract(const Duration(hours: 72)),
      overdueHours: 48,
    ),
    VehicleAlert(
      id: 'AL-003',
      plateNumber: '29A-78901',
      vehicleType: 'Car',
      zone: 'B1 - Zone M',
      slotLabel: 'M03',
      alertType: VehicleAlertType.wrongZone,
      checkInTime: DateTime.now().subtract(const Duration(hours: 3)),
      expectedZone: 'Floor 2 - Zone C',
    ),
    VehicleAlert(
      id: 'AL-004',
      plateNumber: '59B-11222',
      vehicleType: 'EV',
      zone: 'Floor 2 - Zone C',
      slotLabel: 'C12',
      alertType: VehicleAlertType.wrongZone,
      checkInTime: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
      expectedZone: 'Floor 1 - EV Zone',
    ),
    VehicleAlert(
      id: 'AL-005',
      plateNumber: '51K-33445',
      vehicleType: 'Motorbike',
      zone: 'B1 - Zone M',
      slotLabel: 'M31',
      alertType: VehicleAlertType.overdue,
      checkInTime: DateTime.now().subtract(const Duration(hours: 49)),
      overdueHours: 25,
    ),
  ];

  final Set<String> _resolvedIds = {};

  List<VehicleAlert> get _overdueAlerts =>
      _allAlerts.where((a) => a.alertType == VehicleAlertType.overdue).toList();

  List<VehicleAlert> get _wrongZoneAlerts =>
      _allAlerts.where((a) => a.alertType == VehicleAlertType.wrongZone).toList();

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

  void _markResolved(String id) {
    setState(() => _resolvedIds.add(id));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('✅ Đã đánh dấu xử lý xong'),
      backgroundColor: const Color(0xFF16A34A),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
    ));
  }

  void _showActionSheet(VehicleAlert alert) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      backgroundColor: Colors.white,
      builder: (_) => _ActionSheet(
        alert: alert,
        isResolved: _resolvedIds.contains(alert.id),
        onResolve: () {
          Navigator.pop(context);
          _markResolved(alert.id);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Summary row
          _buildSummaryBar(),

          // Tab bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF2563EB),
              unselectedLabelColor: const Color(0xFF94A3B8),
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 0.5),
              unselectedLabelStyle:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              indicatorColor: const Color(0xFF2563EB),
              indicatorWeight: 3,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.timer_off_rounded, size: 16),
                      const SizedBox(width: 6),
                      Text('QUÁ HẠN (${_overdueAlerts.length})'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wrong_location_rounded, size: 16),
                      const SizedBox(width: 6),
                      Text('SAI KHU VỰC (${_wrongZoneAlerts.length})'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAlertList(_overdueAlerts),
                _buildAlertList(_wrongZoneAlerts),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final unresolvedCount =
        _allAlerts.where((a) => !_resolvedIds.contains(a.id)).length;
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF0F172A), size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B), size: 24),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cảnh Báo Xe',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A)),
              ),
              Text(
                'Alert Vehicles List',
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
        if (unresolvedCount > 0)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0xFFF59E0B).withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: Color(0xFFD97706), size: 15),
                  const SizedBox(width: 5),
                  Text(
                    '$unresolvedCount chưa xử lý',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFD97706)),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSummaryBar() {
    final overdueUnresolved = _overdueAlerts
        .where((a) => !_resolvedIds.contains(a.id))
        .length;
    final wrongZoneUnresolved = _wrongZoneAlerts
        .where((a) => !_resolvedIds.contains(a.id))
        .length;
    final resolved = _resolvedIds.length;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: [
          _SummaryChip(
            icon: Icons.timer_off_rounded,
            iconColor: const Color(0xFFEF4444),
            bg: const Color(0xFFFFF1F2),
            value: overdueUnresolved.toString(),
            label: 'Quá hạn',
          ),
          const SizedBox(width: 10),
          _SummaryChip(
            icon: Icons.wrong_location_rounded,
            iconColor: const Color(0xFFF59E0B),
            bg: const Color(0xFFFEF3C7),
            value: wrongZoneUnresolved.toString(),
            label: 'Sai khu vực',
          ),
          const SizedBox(width: 10),
          _SummaryChip(
            icon: Icons.check_circle_rounded,
            iconColor: const Color(0xFF16A34A),
            bg: const Color(0xFFECFDF5),
            value: resolved.toString(),
            label: 'Đã xử lý',
          ),
        ],
      ),
    );
  }

  Widget _buildAlertList(List<VehicleAlert> alerts) {
    if (alerts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline_rounded,
                size: 56, color: Color(0xFF94A3B8)),
            SizedBox(height: 12),
            Text('Không có cảnh báo nào',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF475569))),
            SizedBox(height: 4),
            Text('Tất cả xe đang đỗ đúng quy định.',
                style: TextStyle(color: Color(0xFF94A3B8))),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: alerts.length,
      itemBuilder: (_, i) {
        final alert = alerts[i];
        final resolved = _resolvedIds.contains(alert.id);
        return _AlertCard(
          alert: alert,
          isResolved: resolved,
          onTap: () => _showActionSheet(alert),
        );
      },
    );
  }
}

// ─── Alert Card ──────────────────────────────────────────────────────────────

class _AlertCard extends StatelessWidget {
  const _AlertCard({
    required this.alert,
    required this.isResolved,
    required this.onTap,
  });

  final VehicleAlert alert;
  final bool isResolved;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isOverdue = alert.alertType == VehicleAlertType.overdue;
    final alertColor = isOverdue
        ? const Color(0xFFEF4444)
        : const Color(0xFFF59E0B);
    final alertBg = isOverdue
        ? const Color(0xFFFFF1F2)
        : const Color(0xFFFEF3C7);

    // Duration string
    final duration = DateTime.now().difference(alert.checkInTime);
    final dH = duration.inHours;
    final dM = duration.inMinutes % 60;
    final durationStr = '${dH}h ${dM}m';

    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isResolved ? 0.5 : 1.0,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isResolved
                  ? const Color(0xFFE2E8F0)
                  : alertColor.withOpacity(0.3),
              width: isResolved ? 1 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isResolved
                      ? const Color(0xFFF8FAFC)
                      : alertBg.withOpacity(0.5),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(18)),
                ),
                child: Row(
                  children: [
                    Icon(
                      isOverdue
                          ? Icons.timer_off_rounded
                          : Icons.wrong_location_rounded,
                      color: isResolved ? const Color(0xFF94A3B8) : alertColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      alert.alertLabel,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: isResolved
                              ? const Color(0xFF94A3B8)
                              : alertColor,
                          letterSpacing: 0.5),
                    ),
                    const Spacer(),
                    if (isResolved)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(8)),
                        child: const Text('ĐÃ XỬ LÝ',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF16A34A))),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                            color: alertBg,
                            borderRadius: BorderRadius.circular(8)),
                        child: Text('CẦN XỬ LÝ',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: alertColor)),
                      ),
                  ],
                ),
              ),

              // Body
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Vehicle icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        alert.vehicleType == 'Motorbike'
                            ? Icons.two_wheeler_rounded
                            : alert.vehicleType == 'EV'
                                ? Icons.electric_car_rounded
                                : Icons.directions_car_rounded,
                        color: const Color(0xFF475569),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alert.plateNumber,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                                color: Color(0xFF0F172A)),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.place_rounded,
                                  size: 14, color: Color(0xFF94A3B8)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${alert.zone} · Slot ${alert.slotLabel}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B),
                                      fontWeight: FontWeight.w500),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Alert-specific detail
                          if (alert.alertType == VehicleAlertType.overdue)
                            _detailChip(
                              Icons.access_time_filled_rounded,
                              'Gửi: $durationStr (quá ${alert.overdueHours}h)',
                              const Color(0xFFEF4444),
                              const Color(0xFFFFF1F2),
                            )
                          else
                            _detailChip(
                              Icons.swap_horiz_rounded,
                              'Nên ở: ${alert.expectedZone}',
                              const Color(0xFFF59E0B),
                              const Color(0xFFFEF3C7),
                            ),
                        ],
                      ),
                    ),

                    // Chevron
                    const Icon(Icons.chevron_right_rounded,
                        color: Color(0xFFCBD5E1), size: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailChip(
      IconData icon, String label, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700, color: color),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Summary Chip ─────────────────────────────────────────────────────────────

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.icon,
    required this.iconColor,
    required this.bg,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final Color bg;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
            color: bg, borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 18),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: iconColor,
                        height: 1)),
                Text(label,
                    style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Action Bottom Sheet ──────────────────────────────────────────────────────

class _ActionSheet extends StatelessWidget {
  const _ActionSheet({
    required this.alert,
    required this.isResolved,
    required this.onResolve,
  });

  final VehicleAlert alert;
  final bool isResolved;
  final VoidCallback onResolve;

  @override
  Widget build(BuildContext context) {
    final isOverdue = alert.alertType == VehicleAlertType.overdue;
    final duration = DateTime.now().difference(alert.checkInTime);
    final dH = duration.inHours;
    final dM = duration.inMinutes % 60;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2)),
          ),

          // Plate
          Text(
            alert.plateNumber,
            style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
                color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 4),
          Text(
            '${alert.vehicleType} · ${alert.zone} · Slot ${alert.slotLabel}',
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
          ),
          const SizedBox(height: 16),

          // Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9FB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                _sheetRow('Loại cảnh báo', alert.alertLabel),
                const Divider(height: 16, thickness: 0.5),
                _sheetRow('Thời gian gửi', '${dH}h ${dM}m'),
                if (isOverdue) ...[
                  const Divider(height: 16, thickness: 0.5),
                  _sheetRow('Quá hạn', '${alert.overdueHours} giờ',
                      valueColor: const Color(0xFFEF4444)),
                ] else ...[
                  const Divider(height: 16, thickness: 0.5),
                  _sheetRow('Khu vực đúng', alert.expectedZone ?? '—',
                      valueColor: const Color(0xFF2563EB)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Actions
          if (!isResolved) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onResolve,
                icon: const Icon(Icons.check_circle_rounded,
                    color: Colors.white, size: 20),
                label: const Text('ĐÁNH DẤU ĐÃ XỬ LÝ',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded,
                    size: 18, color: Color(0xFF64748B)),
                label: const Text('Đóng',
                    style: TextStyle(
                        color: Color(0xFF64748B), fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ] else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Đóng',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sheetRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
                fontSize: 13)),
        Text(value,
            style: TextStyle(
                color: valueColor ?? const Color(0xFF0F172A),
                fontWeight: FontWeight.w700,
                fontSize: 13)),
      ],
    );
  }
}
