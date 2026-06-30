import 'package:flutter/material.dart';
import '../../domain/models/parking_session.dart';
import '../controllers/staff_core_controller.dart';
import '../widgets/staff_dashboard_summary.dart';
import '../widgets/vehicle_check_in_form.dart';
import '../widgets/parking_session_ticket_component.dart';
import '../widgets/vehicle_check_out_invoice_screen.dart';
import '../../../auth_profile/presentation/screens/auth_profile_screen.dart';

import '../../../staff_exception/presentation/screens/staff_exception_screen.dart';
import '../../../../app/app.dart' as import_app;


/// Màn hình chính của Staff Core – quản lý luồng xe vào/ra tiêu chuẩn.
class StaffCoreScreen extends StatefulWidget {
  const StaffCoreScreen({super.key});

  @override
  State<StaffCoreScreen> createState() => _StaffCoreScreenState();
}

class _StaffCoreScreenState extends State<StaffCoreScreen>
    with SingleTickerProviderStateMixin {
  late final StaffCoreController _ctrl;
  late final TabController _tabController;

  // Session vừa tạo – để hiển thị ticket
  ParkingSession? _justCreatedSession;

  @override
  void initState() {
    super.initState();
    _ctrl = StaffCoreController();
    _tabController = TabController(length: 2, vsync: this);
    _ctrl.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    _ctrl.removeListener(_rebuild);
    _ctrl.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onSessionCreated(ParkingSession session) {
    setState(() => _justCreatedSession = session);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '✅ Session tạo thành công! ${session.plateNumber} – ${session.suggestedArea}'),
        backgroundColor: const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _dismissTicket() {
    setState(() => _justCreatedSession = null);
  }

  void _onPaymentCompleted() {
    if (_justCreatedSession != null &&
        !_ctrl.activeSessions.any((s) => s.id == _justCreatedSession!.id)) {
      _justCreatedSession = null;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF7F9FB),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // ─── Tab bar ────────────────────────────────────────────────
          Container(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: TabBar(
              controller: _tabController,
              labelColor: isDark ? Colors.blue[300] : const Color(0xFF2563EB),
              unselectedLabelColor: isDark ? Colors.grey[500] : const Color(0xFF94A3B8),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              indicatorColor: const Color(0xFF2563EB),
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'CHECK-IN'),
                Tab(text: 'CHECK-OUT'),
              ],
            ),
          ),

          // ─── Tab content ─────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCheckInTab(),
                _buildCheckOutTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      elevation: 0,
      leading: null,
      automaticallyImplyLeading: true,
      title: Row(
        children: [
          const Icon(Icons.local_parking_rounded,
              color: Color(0xFF2563EB), size: 26),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Staff Core',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              Text(
                'Parking Gate Operations',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: isDark ? Colors.amber : const Color(0xFF0F172A)),
          onPressed: () {
            import_app.SmartParkingApp.of(context).toggleTheme(isDark);
          },
          tooltip: 'Toggle Theme',
        ),
        IconButton(
          icon: const Icon(Icons.history_rounded, color: Color(0xFF64748B)),
          onPressed: () => _showSessionHistory(context),
          tooltip: 'Lịch sử session',
        ),
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AuthProfileScreen()),
            );
          },
          tooltip: 'Đăng xuất',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // ─── Check-in tab ─────────────────────────────────────────────────────────

  Widget _buildCheckInTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dashboard
          StaffDashboardSummary(controller: _ctrl),
          const SizedBox(height: 24),

          // Section title
          _sectionTitle('CHECK-IN XE'),
          const SizedBox(height: 12),

          // Form check-in
          if (_justCreatedSession == null)
            VehicleCheckInForm(
              controller: _ctrl,
              onSessionCreated: _onSessionCreated,
            )
          else
            ParkingSessionTicketComponent(
              session: _justCreatedSession!,
              onDismiss: _dismissTicket,
            ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ─── Check-out tab ────────────────────────────────────────────────────────

  Widget _buildCheckOutTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dashboard nhỏ (re-sử dụng)
          StaffDashboardSummary(controller: _ctrl),
          const SizedBox(height: 24),

          // Section title
          _sectionTitle('CHECK-OUT & THANH TOÁN'),
          const SizedBox(height: 12),

          VehicleCheckOutInvoiceScreen(
            controller: _ctrl,
            onPaymentCompleted: _onPaymentCompleted,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: Color(0xFF475569),
        letterSpacing: 1.5,
      ),
    );
  }

  void _showSessionHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _SessionHistorySheet(sessions: _ctrl.sessions),
    );
  }
}

// ─── Session History Bottom Sheet ─────────────────────────────────────────────

class _SessionHistorySheet extends StatelessWidget {
  const _SessionHistorySheet({required this.sessions});
  final List<ParkingSession> sessions;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (_, scrollCtrl) => Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'LỊCH SỬ SESSION',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          Expanded(
            child: sessions.isEmpty
                ? const Center(
                    child: Text(
                      'Chưa có session nào trong ca.',
                      style: TextStyle(color: Color(0xFF94A3B8)),
                    ),
                  )
                : ListView.separated(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.all(16),
                    itemCount: sessions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final s = sessions[sessions.length - 1 - i];
                      return _SessionTile(session: s);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session});
  final ParkingSession session;

  @override
  Widget build(BuildContext context) {
    final isActive = session.isActive;
    final statusColor =
        isActive ? const Color(0xFF16A34A) : const Color(0xFF64748B);
    final statusLabel = isActive ? 'Active' : 'Paid';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFFECFDF5)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              session.vehicleType == 'Car'
                  ? Icons.directions_car_rounded
                  : session.vehicleType == 'EV'
                      ? Icons.electric_car_rounded
                      : Icons.two_wheeler_rounded,
              color: isActive
                  ? const Color(0xFF16A34A)
                  : const Color(0xFF64748B),
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.plateNumber,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${session.vehicleType} · ${session.entryGate} · ${session.id}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}