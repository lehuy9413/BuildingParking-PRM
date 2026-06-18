import 'package:flutter/material.dart';
import '../../domain/models/exception_models.dart';

/// Màn hình sơ đồ bãi xe tương tác:
/// - Lưới GridView hiển thị slot theo zone và tầng
/// - InteractiveViewer cho phép pinch-zoom và pan
/// - Tap vào slot để cập nhật trạng thái
class ParkingMapScreen extends StatefulWidget {
  const ParkingMapScreen({super.key});

  @override
  State<ParkingMapScreen> createState() => _ParkingMapScreenState();
}

class _ParkingMapScreenState extends State<ParkingMapScreen> {
  final _transformCtrl = TransformationController();
  String _selectedZone = 'B1';


  // ─── Mock data: các khu vực ─────────────────────────────────────────────
  static const _zones = ['B1', 'Floor 1', 'Floor 2'];

  late List<ParkingSlot> _slots;

  @override
  void initState() {
    super.initState();
    _slots = _generateMockSlots();
  }

  @override
  void dispose() {
    _transformCtrl.dispose();
    super.dispose();
  }

  List<ParkingSlot> _generateMockSlots() {
    final slots = <ParkingSlot>[];
    final rng = [
      SlotStatus.available,
      SlotStatus.occupied,
      SlotStatus.occupied,
      SlotStatus.occupied,
      SlotStatus.available,
      SlotStatus.maintenance,
      SlotStatus.occupied,
      SlotStatus.available,
    ];
    int idx = 0;

    // B1: Zone M (moto) – 32 slots
    for (var i = 1; i <= 32; i++) {
      slots.add(ParkingSlot(
        id: 'B1-M${i.toString().padLeft(2, '0')}',
        label: 'M${i.toString().padLeft(2, '0')}',
        zone: 'B1',
        floor: -1,
        status: rng[idx % rng.length],
        occupiedBy: rng[idx % rng.length] == SlotStatus.occupied
            ? '51A-${10000 + i}'
            : null,
      ));
      idx++;
    }

    // Floor 1: EV zone – 12 slots
    for (var i = 1; i <= 12; i++) {
      slots.add(ParkingSlot(
        id: 'F1-EV${i.toString().padLeft(2, '0')}',
        label: 'EV${i.toString().padLeft(2, '0')}',
        zone: 'Floor 1',
        floor: 1,
        status: rng[(idx + 3) % rng.length],
        occupiedBy: rng[(idx + 3) % rng.length] == SlotStatus.occupied
            ? '30E-${20000 + i}'
            : null,
      ));
      idx++;
    }

    // Floor 1: Car zone – 20 slots
    for (var i = 1; i <= 20; i++) {
      slots.add(ParkingSlot(
        id: 'F1-A${i.toString().padLeft(2, '0')}',
        label: 'A${i.toString().padLeft(2, '0')}',
        zone: 'Floor 1',
        floor: 1,
        status: rng[(idx + 1) % rng.length],
        occupiedBy: rng[(idx + 1) % rng.length] == SlotStatus.occupied
            ? '59B-${30000 + i}'
            : null,
      ));
      idx++;
    }

    // Floor 2: Car zone – 24 slots
    for (var i = 1; i <= 24; i++) {
      slots.add(ParkingSlot(
        id: 'F2-C${i.toString().padLeft(2, '0')}',
        label: 'C${i.toString().padLeft(2, '0')}',
        zone: 'Floor 2',
        floor: 2,
        status: rng[(idx + 2) % rng.length],
        occupiedBy: rng[(idx + 2) % rng.length] == SlotStatus.occupied
            ? '29A-${40000 + i}'
            : null,
      ));
      idx++;
    }

    return slots;
  }

  List<ParkingSlot> get _filteredSlots =>
      _slots.where((s) => s.zone == _selectedZone).toList();

  void _onSlotTap(ParkingSlot slot) {
    _showSlotUpdateSheet(slot);
  }

  void _updateSlotStatus(String slotId, SlotStatus newStatus) {
    setState(() {
      final idx = _slots.indexWhere((s) => s.id == slotId);
      if (idx != -1) {
        _slots[idx] = _slots[idx].copyWith(
          status: newStatus,
          occupiedBy: newStatus == SlotStatus.occupied ? null : null,
        );
      }
    });
  }

  void _showSlotUpdateSheet(ParkingSlot slot) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      backgroundColor: Colors.white,
      builder: (_) => SlotStatusUpdateSheet(
        slot: slot,
        onStatusChanged: (newStatus) {
          Navigator.pop(context);
          _updateSlotStatus(slot.id, newStatus);
          _showStatusUpdatedSnack(slot.label, newStatus);
        },
      ),
    );
  }

  void _showStatusUpdatedSnack(String label, SlotStatus status) {
    final msg = switch (status) {
      SlotStatus.available => '✅ Slot $label → Trống',
      SlotStatus.maintenance => '🔧 Slot $label → Bảo trì',
      SlotStatus.locked => '🔒 Slot $label → Khóa',
      SlotStatus.occupied => '🚗 Slot $label → Có xe',
    };
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: const Color(0xFF2563EB),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredSlots;
    final total = filtered.length;
    final occupied =
        filtered.where((s) => s.status == SlotStatus.occupied).length;
    final available =
        filtered.where((s) => s.status == SlotStatus.available).length;
    final maintenance =
        filtered.where((s) => s.status == SlotStatus.maintenance).length;
    final locked =
        filtered.where((s) => s.status == SlotStatus.locked).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Zone selector tabs
          _buildZoneSelector(),

          // Stats bar
          _buildStatsBar(
              total, available, occupied, maintenance, locked),

          // Legend
          _buildLegend(),

          // Map grid (interactive)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4)),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: InteractiveViewer(
                    transformationController: _transformCtrl,
                    minScale: 0.6,
                    maxScale: 3.0,
                    boundaryMargin: const EdgeInsets.all(40),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: _buildGrid(filtered),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () {
          _transformCtrl.value = Matrix4.identity();
        },
        backgroundColor: const Color(0xFF2563EB),
        child: const Icon(Icons.center_focus_strong_rounded,
            color: Colors.white, size: 20),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
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
          Icon(Icons.map_rounded, color: Color(0xFF2563EB), size: 24),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sơ Đồ Bãi Xe',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A)),
              ),
              Text(
                'Interactive Parking Map',
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
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.pinch_rounded,
                    color: Color(0xFF2563EB), size: 15),
                SizedBox(width: 4),
                Text(
                  'Pinch to zoom',
                  style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildZoneSelector() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Row(
        children: _zones.map((zone) {
          final selected = zone == _selectedZone;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedZone = zone),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF2563EB)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  zone,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: selected ? Colors.white : const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatsBar(
      int total, int available, int occupied, int maintenance, int locked) {
    final occupancyPct = total > 0 ? (occupied / total * 100).toInt() : 0;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        children: [
          Row(
            children: [
              _mini('${total}', 'Tổng', const Color(0xFF475569),
                  const Color(0xFFF1F5F9)),
              const SizedBox(width: 8),
              _mini('${available}', 'Trống', const Color(0xFF16A34A),
                  const Color(0xFFECFDF5)),
              const SizedBox(width: 8),
              _mini('${occupied}', 'Có xe', const Color(0xFF2563EB),
                  const Color(0xFFEFF6FF)),
              const SizedBox(width: 8),
              _mini('${maintenance + locked}', 'Khóa/BT',
                  const Color(0xFFF59E0B), const Color(0xFFFEF3C7)),
            ],
          ),
          const SizedBox(height: 10),
          // Occupancy progress
          Row(
            children: [
              Text(
                'Tỷ lệ lấp đầy: $occupancyPct%',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF475569)),
              ),
              const Spacer(),
              Text(
                '$occupied/$total slots',
                style: const TextStyle(
                    fontSize: 11, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: total > 0 ? occupied / total : 0,
              minHeight: 8,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mini(
      String value, String label, Color color, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
            color: bg, borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: color,
                    height: 1)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      color: const Color(0xFFF7F9FB),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _legendItem(SlotStatus.available, 'Trống'),
          const SizedBox(width: 14),
          _legendItem(SlotStatus.occupied, 'Có xe'),
          const SizedBox(width: 14),
          _legendItem(SlotStatus.maintenance, 'Bảo trì'),
          const SizedBox(width: 14),
          _legendItem(SlotStatus.locked, 'Khóa'),
        ],
      ),
    );
  }

  Widget _legendItem(SlotStatus status, String label) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
              color: _slotColor(status),
              borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 5),
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildGrid(List<ParkingSlot> slots) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: 0.75,
      ),
      itemCount: slots.length,
      itemBuilder: (_, i) {
        final slot = slots[i];
        return _SlotCell(
          slot: slot,
          onTap: () => _onSlotTap(slot),
        );
      },
    );
  }

  Color _slotColor(SlotStatus status) => switch (status) {
        SlotStatus.available => const Color(0xFF22C55E),
        SlotStatus.occupied => const Color(0xFF3B82F6),
        SlotStatus.maintenance => const Color(0xFFF59E0B),
        SlotStatus.locked => const Color(0xFFEF4444),
      };
}

// ─── Slot Cell ────────────────────────────────────────────────────────────────

class _SlotCell extends StatelessWidget {
  const _SlotCell({required this.slot, required this.onTap});

  final ParkingSlot slot;
  final VoidCallback onTap;

  Color get _bgColor => switch (slot.status) {
        SlotStatus.available => const Color(0xFFECFDF5),
        SlotStatus.occupied => const Color(0xFFEFF6FF),
        SlotStatus.maintenance => const Color(0xFFFEF3C7),
        SlotStatus.locked => const Color(0xFFFFF1F2),
      };

  Color get _borderColor => switch (slot.status) {
        SlotStatus.available => const Color(0xFF86EFAC),
        SlotStatus.occupied => const Color(0xFF93C5FD),
        SlotStatus.maintenance => const Color(0xFFFCD34D),
        SlotStatus.locked => const Color(0xFFFCA5A5),
      };

  Color get _iconColor => switch (slot.status) {
        SlotStatus.available => const Color(0xFF16A34A),
        SlotStatus.occupied => const Color(0xFF2563EB),
        SlotStatus.maintenance => const Color(0xFFD97706),
        SlotStatus.locked => const Color(0xFFDC2626),
      };

  IconData get _icon => switch (slot.status) {
        SlotStatus.available => Icons.check_rounded,
        SlotStatus.occupied => Icons.directions_car_rounded,
        SlotStatus.maintenance => Icons.build_rounded,
        SlotStatus.locked => Icons.lock_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _borderColor, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_icon, color: _iconColor, size: 16),
            const SizedBox(height: 4),
            Text(
              slot.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: _iconColor,
                  letterSpacing: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Slot Status Update Bottom Sheet ─────────────────────────────────────────

/// Widget có thể sử dụng độc lập hoặc được gọi từ map.
class SlotStatusUpdateSheet extends StatefulWidget {
  const SlotStatusUpdateSheet({
    super.key,
    required this.slot,
    required this.onStatusChanged,
  });

  final ParkingSlot slot;
  final ValueChanged<SlotStatus> onStatusChanged;

  @override
  State<SlotStatusUpdateSheet> createState() => _SlotStatusUpdateSheetState();
}

class _SlotStatusUpdateSheetState extends State<SlotStatusUpdateSheet> {
  late SlotStatus _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.slot.status;
  }

  @override
  Widget build(BuildContext context) {
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

          // Slot label
          const Text(
            'CẬP NHẬT TRẠNG THÁI SLOT',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF475569),
                letterSpacing: 1.5),
          ),
          const SizedBox(height: 6),
          Text(
            widget.slot.label,
            style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
                letterSpacing: 2),
          ),
          Text(
            '${widget.slot.zone}',
            style: const TextStyle(
                color: Color(0xFF64748B), fontSize: 13),
          ),

          if (widget.slot.occupiedBy != null) ...[
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.directions_car_rounded,
                      size: 16, color: Color(0xFF2563EB)),
                  const SizedBox(width: 6),
                  Text(
                    widget.slot.occupiedBy!,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2563EB),
                        letterSpacing: 1,
                        fontSize: 14),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Status options
          ...SlotStatus.values.map((status) {
            final selected = _selected == status;
            return _StatusOption(
              status: status,
              isSelected: selected,
              onTap: () => setState(() => _selected = status),
            );
          }),

          const SizedBox(height: 20),

          // Confirm button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _selected == widget.slot.status
                  ? null
                  : () => widget.onStatusChanged(_selected),
              icon: const Icon(Icons.save_rounded,
                  color: Colors.white, size: 18),
              label: const Text(
                'XÁC NHẬN CẬP NHẬT',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                disabledBackgroundColor: const Color(0xFFCBD5E1),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusOption extends StatelessWidget {
  const _StatusOption({
    required this.status,
    required this.isSelected,
    required this.onTap,
  });

  final SlotStatus status;
  final bool isSelected;
  final VoidCallback onTap;

  String get _label => switch (status) {
        SlotStatus.available => 'Trống',
        SlotStatus.occupied => 'Có xe',
        SlotStatus.maintenance => 'Đang bảo trì',
        SlotStatus.locked => 'Khóa',
      };

  String get _desc => switch (status) {
        SlotStatus.available => 'Slot sẵn sàng tiếp nhận xe',
        SlotStatus.occupied => 'Slot hiện đang có xe đỗ',
        SlotStatus.maintenance => 'Slot đang được sửa chữa, không sử dụng',
        SlotStatus.locked => 'Slot bị khóa, không cho phép đỗ xe',
      };

  IconData get _icon => switch (status) {
        SlotStatus.available => Icons.check_circle_outline_rounded,
        SlotStatus.occupied => Icons.directions_car_rounded,
        SlotStatus.maintenance => Icons.build_circle_outlined,
        SlotStatus.locked => Icons.lock_outline_rounded,
      };

  Color get _color => switch (status) {
        SlotStatus.available => const Color(0xFF16A34A),
        SlotStatus.occupied => const Color(0xFF2563EB),
        SlotStatus.maintenance => const Color(0xFFD97706),
        SlotStatus.locked => const Color(0xFFDC2626),
      };

  Color get _bg => switch (status) {
        SlotStatus.available => const Color(0xFFECFDF5),
        SlotStatus.occupied => const Color(0xFFEFF6FF),
        SlotStatus.maintenance => const Color(0xFFFEF3C7),
        SlotStatus.locked => const Color(0xFFFFF1F2),
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? _bg : const Color(0xFFF7F9FB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? _color : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? _color.withOpacity(0.12) : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_icon,
                  color: isSelected ? _color : const Color(0xFF94A3B8),
                  size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _label,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? _color : const Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _desc,
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: isSelected ? _color : const Color(0xFFCBD5E1),
                    width: 2),
                color: isSelected ? _color : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
