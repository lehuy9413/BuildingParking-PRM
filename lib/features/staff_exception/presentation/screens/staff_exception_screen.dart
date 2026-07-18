import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/models/incident_model.dart';
import '../../../auth_profile/presentation/screens/auth_profile_screen.dart';
import '../../domain/models/exception_models.dart';
import 'process_mismatch_screen.dart';
import 'exception_handling_screen.dart';
import 'mismatch_screen.dart';
import 'parking_map_screen.dart';
import 'process_lost_ticket_screen.dart';


/// Màn hình chính của Staff Exception – dashboard điều hướng 4 chức năng.
class StaffExceptionScreen extends StatefulWidget {
  const StaffExceptionScreen({super.key});

  @override
  State<StaffExceptionScreen> createState() => _StaffExceptionScreenState();
}

class _StaffExceptionScreenState extends State<StaffExceptionScreen> {
  Key _activityListKey = UniqueKey();

  void _reloadActivityList() {
    setState(() {
      _activityListKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header banner ───────────────────────────────────────────────
            _buildHeaderBanner(),
            const SizedBox(height: 24),

            // ─── Section title ───────────────────────────────────────────────
            _sectionTitle('MANAGEMENT FUNCTIONS'),
            const SizedBox(height: 14),

            // ─── Feature cards – 2 columns ───────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _FeatureCard(
                    icon: Icons.confirmation_number_outlined,
                    iconColor: const Color(0xFFEA580C),
                    iconBg: const Color(0xFFFFF7ED),
                    title: 'Lost\nTicket',
                    subtitle: 'Lost card & wrong vehicle info',
                    badge: null,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ExceptionHandlingScreen()),
                      );
                      _reloadActivityList();
                    },
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _FeatureCard(
                    icon: Icons.warning_amber_rounded,
                    iconColor: const Color(0xFFF59E0B),
                    iconBg: const Color(0xFFFEF3C7),
                    title: 'Mismatch',
                    subtitle: 'Overdue & wrong area',
                    badge: '5',
                    badgeColor: const Color(0xFFEF4444),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const MismatchScreen()),
                      );
                      if (result == true) {
                        _reloadActivityList();
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _FeatureCard(
                    icon: Icons.map_rounded,
                    iconColor: const Color(0xFF2563EB),
                    iconBg: const Color(0xFFEFF6FF),
                    title: 'Parking\nMap',
                    subtitle: 'Visual slot management',
                    badge: null,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ParkingMapScreen()),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _FeatureCard(
                    icon: Icons.tune_rounded,
                    iconColor: const Color(0xFF7C3AED),
                    iconBg: const Color(0xFFF5F3FF),
                    title: 'Status\nUpdate',
                    subtitle: 'Available, maintenance, locked',
                    badge: null,
                    onTap: () => _showQuickSlotUpdate(context),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ─── Quick Stats ─────────────────────────────────────────────────
            _sectionTitle('QUICK STATS'),
            const SizedBox(height: 14),
            _buildQuickStats(),

            const SizedBox(height: 28),

            // ─── Recent activity ─────────────────────────────────────────────
            _sectionTitle('ACTIVE EXCEPTION LOG'),
            const SizedBox(height: 14),
            _RecentActivityList(key: _activityListKey),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF0F172A), size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Row(
        children: [
          Icon(Icons.manage_accounts_rounded,
              color: Color(0xFF2563EB), size: 26),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Staff Exception',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A)),
              ),
              Text(
                'Exception & Monitoring',
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
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AuthProfileScreen()),
          ),
          tooltip: 'Logout',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeaderBanner() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1D4ED8), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield_rounded,
                        color: Colors.white, size: 14),
                    SizedBox(width: 5),
                    Text(
                      'STAFF EXCEPTION MODULE',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Parking Exception\nManagement',
            style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                height: 1.2),
          ),
          const SizedBox(height: 8),
          Text(
            'Active Shift · $h:$m',
            style: TextStyle(
                color: Colors.white.withOpacity(0.75),
                fontSize: 13,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        _QuickStatCard(
          value: '88',
          label: 'Total slots',
          icon: Icons.grid_view_rounded,
          color: const Color(0xFF2563EB),
          bg: const Color(0xFFEFF6FF),
        ),
        const SizedBox(width: 10),
        _QuickStatCard(
          value: '61',
          label: 'Occupied',
          icon: Icons.directions_car_rounded,
          color: const Color(0xFF16A34A),
          bg: const Color(0xFFECFDF5),
        ),
        const SizedBox(width: 10),
        _QuickStatCard(
          value: '5',
          label: 'Alerts',
          icon: Icons.warning_amber_rounded,
          color: const Color(0xFFEF4444),
          bg: const Color(0xFFFFF1F2),
        ),
      ],
    );
  }

  // _buildRecentActivity has been extracted into _RecentActivityList

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Color(0xFF475569),
          letterSpacing: 1.5),
    );
  }

  void _showQuickSlotUpdate(BuildContext context) {
    // Demo: mở bottom sheet với slot demo
    final demoSlot = ParkingSlot(
      id: 'demo-A01',
      label: 'A01',
      zone: 'Floor 1',
      floor: 1,
      status: SlotStatus.available,
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      backgroundColor: Colors.white,
      builder: (_) => SlotStatusUpdateSheet(
        slot: demoSlot,
        onStatusChanged: (status) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                '✅ Slot A01 updated: ${_statusLabel(status)}'),
            backgroundColor: const Color(0xFF2563EB),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ));
        },
      ),
    );
  }

  String _statusLabel(SlotStatus s) => switch (s) {
        SlotStatus.available => 'Available',
        SlotStatus.occupied => 'Occupied',
        SlotStatus.maintenance => 'Maintenance',
        SlotStatus.locked => 'Locked',
      };
}


// ─── Feature Card ─────────────────────────────────────────────────────────────

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    this.badge,
    this.badgeColor,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final String? badge;
  final Color? badgeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(14)),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const Spacer(),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (badgeColor ?? iconColor).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badge!,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: badgeColor ?? iconColor),
                    ),
                  ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: Colors.grey.shade400),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  height: 1.3),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF94A3B8),
                  height: 1.3),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Quick Stat Card ──────────────────────────────────────────────────────────

class _QuickStatCard extends StatelessWidget {
  const _QuickStatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    required this.bg,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
            color: bg, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: color,
                    height: 1)),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ─── Activity Item data class ─────────────────────────────────────────────────

class _ActivityItem {
  final IconData icon;
  final Color color;
  final Color bg;
  final String title;
  final String subtitle;
  final String time;

  const _ActivityItem({
    required this.icon,
    required this.color,
    required this.bg,
    required this.title,
    required this.subtitle,
    required this.time,
  });
}

// ─── Recent Activity List (API fetching) ──────────────────────────────────────

class _RecentActivityList extends StatefulWidget {
  const _RecentActivityList({Key? key}) : super(key: key);

  @override
  _RecentActivityListState createState() => _RecentActivityListState();
}

class _RecentActivityListState extends State<_RecentActivityList> {
  late Future<List<IncidentModel>> _incidentsFuture;

  @override
  void initState() {
    super.initState();
    _incidentsFuture = _fetchIncidents();
  }

  Future<List<IncidentModel>> _fetchIncidents() async {
    try {
      final res = await ApiClient.instance.dio.get(ApiEndpoints.incidents);
      debugPrint('GET /incidents RESPONSE: ${res.data}');
      final dynamic rawData = res.data['data'] ?? res.data ?? [];
      
      List items = [];
      if (rawData is List) {
        items = rawData;
      } else if (rawData is Map && rawData['docs'] is List) {
        items = rawData['docs'];
      } else if (rawData is Map && rawData['incidents'] is List) {
        items = rawData['incidents'];
      }
      
      return items.map((e) => IncidentModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error fetching incidents: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<IncidentModel>>(
      future: _incidentsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Failed to load incidents'));
        }
        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return const Center(child: Text('No active incidents'));
        }

        return Column(
          children: items.map((item) {
            IconData icon = Icons.warning_amber_rounded;
            Color color = const Color(0xFFEA580C);
            Color bg = const Color(0xFFFFF7ED);

            if (item.type == 'lost_ticket') {
              icon = Icons.credit_card_off_rounded;
              color = const Color(0xFFEA580C);
              bg = const Color(0xFFFFF7ED);
            } else if (item.type == 'wrong_license_plate') {
              icon = Icons.camera_alt_rounded;
              color = const Color(0xFFF59E0B);
              bg = const Color(0xFFFEF3C7);
            } else {
              icon = Icons.info_outline_rounded;
              color = const Color(0xFF3B82F6);
              bg = const Color(0xFFEFF6FF);
            }

            String timeStr = '';
            if (item.createdAt != null) {
              timeStr = DateFormat('hh:mm:ss a').format(item.createdAt!.toLocal());
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Timestamp & Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 6),
                          Text(timeStr, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (item.status?.toLowerCase() == 'open' ? const Color(0xFFFEF3C7) : const Color(0xFFECFDF5)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          (item.status ?? 'OPEN').toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: (item.status?.toLowerCase() == 'open' ? const Color(0xFFD97706) : const Color(0xFF059669)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24, color: Color(0xFFF1F5F9)),
                  
                  // Row 2: Reference ID & Exception Type
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('REFERENCE ID', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text(item.incidentCode ?? 'N/A', style: const TextStyle(fontSize: 12, color: Color(0xFF0F172A), fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('EXCEPTION TYPE', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(icon, color: color, size: 14),
                                const SizedBox(width: 6),
                                Expanded(child: Text(item.type == 'lost_ticket' ? 'Lost Ticket' : (item.type == 'wrong_license_plate' ? 'Wrong License Plate' : (item.type ?? 'Other')), style: const TextStyle(fontSize: 12, color: Color(0xFF0F172A), fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Row 3: Title / Details
                  const Text('TITLE / DETAILS', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(item.title, style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A), fontWeight: FontWeight.w800)),
                  if (item.description != null && item.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(item.description!, style: const TextStyle(fontSize: 12, color: Color(0xFF475569))),
                  ],
                  
                  const SizedBox(height: 16),
                  
                  // Row 4: Action Button
                  SizedBox(
                    width: double.infinity,
                    child: Builder(
                      builder: (context) {
                        final isResolved = item.status?.toLowerCase() != 'open';
                        
                        return OutlinedButton(
                          onPressed: () async {
                            if (isResolved) {
                              _showIncidentDetailsPopup(context, item);
                              return;
                            }
                            
                            if (item.type == 'lost_ticket') {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProcessLostTicketScreen(incident: item),
                                ),
                              );
                              if (result == true) {
                                final state = context.findAncestorStateOfType<_StaffExceptionScreenState>();
                                state?._reloadActivityList();
                              }
                            } else if (item.type == 'wrong_license_plate') {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProcessMismatchScreen(incident: item),
                                ),
                              );
                              if (result == true) {
                                final state = context.findAncestorStateOfType<_StaffExceptionScreenState>();
                                state?._reloadActivityList();
                              }
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isResolved ? const Color(0xFF64748B) : const Color(0xFF2563EB),
                            side: BorderSide(color: isResolved ? const Color(0xFFCBD5E1) : const Color(0xFF2563EB)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: isResolved 
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.visibility, size: 16),
                                  SizedBox(width: 8),
                                  Text('VIEW DETAILS', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                                ],
                              )
                            : Text('PROCESS ${item.type == 'lost_ticket' ? 'LOST TICKET' : (item.type == 'wrong_license_plate' ? 'MISMATCH' : 'EXCEPTION')}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                        );
                      }
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _showIncidentDetailsPopup(BuildContext context, IncidentModel incident) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Container(
            width: 700,
            padding: const EdgeInsets.all(0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Incident Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                      IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                // Body
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('GENERAL INFO', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 1.0)),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFF1F5F9)),
                                color: Colors.white,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildPopupDetailItem('REFERENCE ID', incident.incidentCode ?? incident.id),
                                  const SizedBox(height: 16),
                                  _buildPopupDetailItem('TYPE', _formatIncidentType(incident.type ?? 'Unknown')),
                                  const SizedBox(height: 16),
                                  _buildPopupDetailItem('REPORTED AT', incident.createdAt != null ? DateFormat('M/d/yyyy, hh:mm:ss a').format(incident.createdAt!) : 'N/A'),
                                  const SizedBox(height: 16),
                                  _buildPopupDetailItem('TITLE', incident.title),
                                  const SizedBox(height: 16),
                                  const Text('DESCRIPTION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
                                  const SizedBox(height: 4),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(4)),
                                    child: Text(incident.description ?? 'No description', style: const TextStyle(fontSize: 13, color: Color(0xFF334155))),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Right Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('RESOLUTION DETAILS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF10B981), letterSpacing: 1.0)),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFD1FAE5)),
                                color: const Color(0xFFECFDF5).withOpacity(0.5),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('RESOLVED AT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                                  const SizedBox(height: 4),
                                  Text(incident.resolvedAt != null ? DateFormat('M/d/yyyy, hh:mm:ss a').format(incident.resolvedAt!) : 'N/A', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF065F46))),
                                  const SizedBox(height: 16),
                                  const Divider(color: Color(0xFFD1FAE5), height: 1),
                                  const SizedBox(height: 16),
                                  const Text('RESOLUTION NOTE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                                  const SizedBox(height: 8),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFFD1FAE5))),
                                    child: Text(incident.resolutionNote ?? 'No resolution note provided.', style: const TextStyle(fontSize: 13, color: Color(0xFF065F46), fontWeight: FontWeight.w500)),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                // Footer
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF334155),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('CLOSE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPopupDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
      ],
    );
  }

  String _formatIncidentType(String type) {
    switch (type) {
      case 'lost_ticket':
        return 'Lost Ticket';
      case 'wrong_license_plate':
        return 'Wrong License Plate';
      default:
        return type;
    }
  }
}