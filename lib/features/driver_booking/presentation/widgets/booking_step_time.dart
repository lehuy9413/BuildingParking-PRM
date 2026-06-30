import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../controllers/booking_controller.dart';

/// Time slot classification for color coding
enum _TimeSlotType { available, peak, promo, reserved }

class BookingStepTime extends ConsumerWidget {
  const BookingStepTime({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(bookingControllerProvider);
    final controller = ref.read(bookingControllerProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Parking Lot Section ──
          if (state.parkingLots.isNotEmpty) ...[
            _SectionHeader(
              icon: Icons.local_parking_rounded,
              title: 'Select Parking Lot',
              subtitle: 'Choose where you want to park',
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: state.selectedParkingLot?.id,
                  isExpanded: true,
                  dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                  icon: Icon(Icons.arrow_drop_down_rounded, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                  items: state.parkingLots.map((lot) {
                    return DropdownMenuItem<String>(
                      value: lot.id,
                      child: Text(
                        lot.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      final lot = state.parkingLots.firstWhere((l) => l.id == val);
                      controller.selectParkingLot(lot);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 28),
          ],

          // ── Date Section ──
          _SectionHeader(
            icon: Icons.calendar_month_rounded,
            title: 'Select Date',
            subtitle: 'Pick a date to check slot availability',
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _CompactDateStrip(
            selectedDate: state.selectedDate,
            onDateSelected: controller.selectDate,
            isDark: isDark,
          ),
          const SizedBox(height: 28),

          // ── Check-in Time ──
          _SectionHeader(
            icon: Icons.login_rounded,
            title: 'Check-in Time',
            subtitle: 'Select arrival time to find the best spots',
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _TimeSlotLegend(isDark: isDark),
          const SizedBox(height: 10),
          _SmartTimeGrid(
            selectedTime: state.checkInTime,
            onTimeSelected: controller.selectCheckInTime,
            startHour: 6,
            endHour: 22,
            isDark: isDark,
          ),
          const SizedBox(height: 28),

          // ── Check-out Time ──
          _SectionHeader(
            icon: Icons.logout_rounded,
            title: 'Check-out Time',
            subtitle: 'Estimated departure for accurate pricing',
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _SmartTimeGrid(
            selectedTime: state.checkOutTime,
            onTimeSelected: controller.selectCheckOutTime,
            startHour: 6,
            endHour: 23,
            isDark: isDark,
          ),
          const SizedBox(height: 24),

          // ── Duration Summary ──
          if (state.checkInTime != null && state.checkOutTime != null)
            _DurationSummary(
              duration: state.durationText,
              isDark: isDark,
            ),
          const SizedBox(height: 16),
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
    required this.subtitle,
    required this.isDark,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0F4C5C).withValues(alpha: 0.25)
                    : const Color(0xFF0F4C5C).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: const Color(0xFF0F4C5C), size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 43, top: 3),
          child: Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Compact Date Strip ──────────────────────────────────────────────────────

class _CompactDateStrip extends StatelessWidget {
  const _CompactDateStrip({
    required this.selectedDate,
    required this.onDateSelected,
    required this.isDark,
  });

  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final dates = List.generate(
      7,
      (i) => DateTime(today.year, today.month, today.day + i),
    );

    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = selectedDate != null &&
              date.year == selectedDate!.year &&
              date.month == selectedDate!.month &&
              date.day == selectedDate!.day;
          final isToday = index == 0;

          return GestureDetector(
            onTap: () => onDateSelected(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 56,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF0F4C5C), Color(0xFF1B998B)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )
                    : null,
                color: isSelected
                    ? null
                    : isToday
                        ? (isDark ? const Color(0xFF1B998B).withValues(alpha: 0.1) : const Color(0xFFE0F7FA))
                        : (isDark ? const Color(0xFF1E293B) : Colors.white),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : isToday
                          ? const Color(0xFF1B998B).withValues(alpha: 0.4)
                          : (isDark ? const Color(0xFF2A3A4A) : const Color(0xFFEDF0F4)),
                  width: isToday && !isSelected ? 1.5 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF0F4C5C).withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(date).toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.7)
                          : (isDark ? Colors.grey.shade500 : Colors.grey.shade500),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: isSelected
                          ? Colors.white
                          : isToday
                              ? const Color(0xFF1B998B)
                              : (isDark ? Colors.white : const Color(0xFF0F172A)),
                    ),
                  ),
                  if (isToday) ...[
                    const SizedBox(height: 3),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? Colors.white : const Color(0xFF1B998B),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Time Slot Legend ─────────────────────────────────────────────────────────

class _TimeSlotLegend extends StatelessWidget {
  const _TimeSlotLegend({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _legendDot(const Color(0xFF1B998B), 'Available', isDark),
        const SizedBox(width: 14),
        _legendDot(const Color(0xFFF59E0B), 'Peak', isDark),
        const SizedBox(width: 14),
        _legendDot(const Color(0xFF38BDF8), 'Promo', isDark),
        const SizedBox(width: 14),
        _legendDot(isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1), 'Reserved', isDark),
      ],
    );
  }

  Widget _legendDot(Color color, String label, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2.5),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}

// ─── Smart Time Grid ─────────────────────────────────────────────────────────

class _SmartTimeGrid extends StatelessWidget {
  const _SmartTimeGrid({
    required this.selectedTime,
    required this.onTimeSelected,
    required this.startHour,
    required this.endHour,
    required this.isDark,
  });

  final TimeOfDay? selectedTime;
  final ValueChanged<TimeOfDay> onTimeSelected;
  final int startHour;
  final int endHour;
  final bool isDark;

  _TimeSlotType _getSlotType(int hour) {
    // Reserved slots (simulated)
    if (hour == 8 || hour == 17) return _TimeSlotType.reserved;
    // Peak hours
    if ((hour >= 7 && hour <= 9) || (hour >= 16 && hour <= 18)) {
      return _TimeSlotType.peak;
    }
    // Promo / off-peak
    if (hour >= 10 && hour <= 14) return _TimeSlotType.promo;
    return _TimeSlotType.available;
  }

  @override
  Widget build(BuildContext context) {
    final times = <TimeOfDay>[];
    for (int h = startHour; h <= endHour; h++) {
      times.add(TimeOfDay(hour: h, minute: 0));
      if (h < endHour) {
        times.add(TimeOfDay(hour: h, minute: 30));
      }
    }

    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: times.map((time) {
        final isSelected = selectedTime != null &&
            time.hour == selectedTime!.hour &&
            time.minute == selectedTime!.minute;
        final label =
            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
        final type = _getSlotType(time.hour);
        final isReserved = type == _TimeSlotType.reserved;

        // Color logic
        Color chipBg;
        Color chipBorder;
        Color chipText;

        if (isSelected) {
          chipBg = const Color(0xFF0F4C5C);
          chipBorder = const Color(0xFF1B998B);
          chipText = Colors.white;
        } else if (isReserved) {
          chipBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
          chipBorder = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
          chipText = isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1);
        } else {
          switch (type) {
            case _TimeSlotType.peak:
              chipBg = isDark ? const Color(0xFFF59E0B).withValues(alpha: 0.08) : const Color(0xFFFFFBEB);
              chipBorder = isDark ? const Color(0xFFF59E0B).withValues(alpha: 0.25) : const Color(0xFFFDE68A);
              chipText = isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706);
              break;
            case _TimeSlotType.promo:
              chipBg = isDark ? const Color(0xFF38BDF8).withValues(alpha: 0.08) : const Color(0xFFF0F9FF);
              chipBorder = isDark ? const Color(0xFF38BDF8).withValues(alpha: 0.25) : const Color(0xFFBAE6FD);
              chipText = isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7);
              break;
            default:
              chipBg = isDark ? const Color(0xFF1E293B) : Colors.white;
              chipBorder = isDark ? const Color(0xFF334155) : const Color(0xFFE8EDF2);
              chipText = isDark ? Colors.grey.shade300 : const Color(0xFF475569);
          }
        }

        return GestureDetector(
          onTap: isReserved ? null : () => onTimeSelected(time),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: chipBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: chipBorder,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF0F4C5C).withValues(alpha: 0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isReserved)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(Icons.block_rounded, size: 11, color: chipText),
                  ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: chipText,
                    decoration: isReserved ? TextDecoration.lineThrough : null,
                    decorationColor: chipText,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Duration Summary ────────────────────────────────────────────────────────

class _DurationSummary extends StatelessWidget {
  const _DurationSummary({required this.duration, required this.isDark});

  final String duration;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1B998B).withValues(alpha: 0.15), const Color(0xFF0F4C5C).withValues(alpha: 0.15)]
              : [const Color(0xFFE0F7FA), const Color(0xFFE8F5E9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF1B998B).withValues(alpha: 0.25) : const Color(0xFFB2DFDB),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1B998B).withValues(alpha: isDark ? 0.2 : 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.timer_outlined, color: Color(0xFF1B998B), size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Estimated Duration',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                duration,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: isDark ? const Color(0xFF1B998B) : const Color(0xFF0F4C5C),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
