import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/parking_slot.dart';
import '../controllers/booking_controller.dart';

class BookingStepSlot extends ConsumerStatefulWidget {
  const BookingStepSlot({super.key});

  @override
  ConsumerState<BookingStepSlot> createState() => _BookingStepSlotState();
}

class _BookingStepSlotState extends ConsumerState<BookingStepSlot> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bookingControllerProvider.notifier).loadAvailableSlots();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(bookingControllerProvider);
    final controller = ref.read(bookingControllerProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Visual Parking Map ──
          _SectionHeader(
            icon: Icons.map_rounded,
            title: 'Parking Map',
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          if (state.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(color: Color(0xFF2563eb)),
              ),
            )
          else ...[
            if (state.selectedSlot != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2563eb).withValues(alpha: 0.1) : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF2563eb).withValues(alpha: 0.3) : const Color(0xFFBFDBFE),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome, color: const Color(0xFF2563eb), size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Auto-assigned by System',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1D4ED8),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Optimal Location: ${state.selectedSlot!.slotCode}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : const Color(0xFF1E3A8A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            _ParkingVisualMap(
              slots: state.availableSlots,
              selectedSlot: state.selectedSlot,
              onSlotSelected: controller.lockAndSelectSlot,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _SlotLegend(isDark: isDark),
          ],

          // ── Selected Slot Summary ──
          if (state.selectedSlot != null) ...[
            const SizedBox(height: 24),
            _SelectedSlotSummary(
              slot: state.selectedSlot!,
              estimatedPrice: state.estimatedPrice,
              isDark: isDark,
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ─── Section Header ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.isDark,
  });

  final IconData icon;
  final String title;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF2563eb).withValues(alpha: 0.3)
                : const Color(0xFF2563eb).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF2563eb), size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}


// ─── Visual Parking Map ──────────────────────────────────────────────────────

class _ParkingVisualMap extends StatelessWidget {
  const _ParkingVisualMap({
    required this.slots,
    required this.selectedSlot,
    required this.onSlotSelected,
    required this.isDark,
  });

  final List<ParkingSlot> slots;
  final ParkingSlot? selectedSlot;
  final ValueChanged<ParkingSlot> onSlotSelected;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Entrance indicator ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF3b82f6).withValues(alpha: 0.15) : const Color(0xFFE0F7FA),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? const Color(0xFF3b82f6).withValues(alpha: 0.3) : const Color(0xFFB2DFDB),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.arrow_downward_rounded, color: const Color(0xFF3b82f6), size: 16),
                const SizedBox(width: 6),
                Text(
                  'ENTRANCE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF3b82f6),
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.arrow_downward_rounded, color: const Color(0xFF3b82f6), size: 16),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Road + Slots Layout ──
          _buildParkingRows(context),

          const SizedBox(height: 16),
          // ── Exit indicator ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFFEA580C).withValues(alpha: 0.15) : const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? const Color(0xFFEA580C).withValues(alpha: 0.3) : const Color(0xFFFED7AA),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.arrow_downward_rounded, color: const Color(0xFFEA580C), size: 16),
                const SizedBox(width: 6),
                Text(
                  'EXIT',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFEA580C),
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.arrow_downward_rounded, color: const Color(0xFFEA580C), size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParkingRows(BuildContext context) {
    // Split slots into rows of pairs (left side + right side, separated by road)
    final rowCount = (slots.length / 2).ceil();

    return Column(
      children: List.generate(rowCount, (rowIndex) {
        final leftIndex = rowIndex * 2;
        final rightIndex = rowIndex * 2 + 1;

        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              // Left slot
              Expanded(
                child: leftIndex < slots.length
                    ? _buildSlotCell(context, slots[leftIndex], isLeft: true)
                    : const SizedBox(),
              ),
              // Road
              Container(
                width: 40,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF374151).withValues(alpha: 0.3) : const Color(0xFFF1F5F9),
                  border: Border.symmetric(
                    vertical: BorderSide(
                      color: isDark ? const Color(0xFFFBBF24).withValues(alpha: 0.3) : const Color(0xFFFDE68A),
                      width: 1.5,
                      style: BorderStyle.solid,
                    ),
                  ),
                ),
              ),
              // Right slot
              Expanded(
                child: rightIndex < slots.length
                    ? _buildSlotCell(context, slots[rightIndex], isLeft: false)
                    : const SizedBox(),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSlotCell(BuildContext context, ParkingSlot slot, {required bool isLeft}) {
    final isAvailable = slot.status == SlotStatus.available;
    final isSelected = selectedSlot?.id == slot.id;

    Color bgColor;
    Color borderColor;
    Color textColor;

    if (isSelected) {
      bgColor = const Color(0xFFF2C14E).withValues(alpha: 0.25);
      borderColor = const Color(0xFFF2C14E);
      textColor = isDark ? const Color(0xFFF2C14E) : const Color(0xFFB45309);
    } else if (isAvailable) {
      bgColor = isDark ? const Color(0xFF3b82f6).withValues(alpha: 0.1) : const Color(0xFFECFDF5);
      borderColor = isDark ? const Color(0xFF3b82f6).withValues(alpha: 0.3) : const Color(0xFFBBF7D0);
      textColor = isDark ? const Color(0xFF34D399) : const Color(0xFF059669);
    } else {
      bgColor = isDark ? const Color(0xFFEF4444).withValues(alpha: 0.08) : const Color(0xFFFEF2F2);
      borderColor = isDark ? const Color(0xFFEF4444).withValues(alpha: 0.2) : const Color(0xFFFECACA);
      textColor = isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626);
    }

    return GestureDetector(
      onTap: isAvailable ? () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hệ thống đã tự động sắp xếp vị trí tối ưu nhất cho bạn.'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 44,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.horizontal(
            left: isLeft ? const Radius.circular(8) : Radius.zero,
            right: isLeft ? Radius.zero : const Radius.circular(8),
          ),
          border: Border.all(color: borderColor, width: isSelected ? 2.5 : 1),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(Icons.check_circle, color: textColor, size: 14),
                ),
              Icon(
                isAvailable ? Icons.directions_car_outlined : Icons.block_rounded,
                color: textColor,
                size: 14,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  slot.slotCode,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                    color: textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Slot Legend ─────────────────────────────────────────────────────────────

class _SlotLegend extends StatelessWidget {
  const _SlotLegend({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem('Available', isDark ? const Color(0xFF34D399) : const Color(0xFF059669)),
        const SizedBox(width: 20),
        _legendItem('Occupied', isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626)),
        const SizedBox(width: 20),
        _legendItem('Selected', const Color(0xFFF2C14E)),
      ],
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: color, width: 1.5),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}



// ─── Selected Slot Summary ───────────────────────────────────────────────────

class _SelectedSlotSummary extends StatelessWidget {
  const _SelectedSlotSummary({
    required this.slot,
    required this.estimatedPrice,
    required this.isDark,
  });

  final ParkingSlot slot;
  final double estimatedPrice;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF2563eb).withValues(alpha: 0.4), const Color(0xFF3b82f6).withValues(alpha: 0.3)]
              : [const Color(0xFFE0F7FA), const Color(0xFFE8F5E9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF3b82f6).withValues(alpha: 0.4) : const Color(0xFFB2DFDB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF3b82f6), size: 22),
              const SizedBox(width: 10),
              Text(
                'Selected Slot',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isDark ? const Color(0xFF3b82f6) : const Color(0xFF2563eb),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _infoChip(Icons.local_parking_rounded, slot.slotCode),
              const SizedBox(width: 10),
              _infoChip(Icons.layers_rounded, slot.floorName ?? ''),
              const SizedBox(width: 10),
              _infoChip(Icons.payments_rounded, '${estimatedPrice.toInt()} VND'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF2563eb)),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2563eb),
            ),
          ),
        ],
      ),
    );
  }
}
