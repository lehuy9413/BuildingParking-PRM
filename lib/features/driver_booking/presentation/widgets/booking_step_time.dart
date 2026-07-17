import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../controllers/booking_controller.dart';


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
          if (state.errorMessage != null && state.parkingLots.isEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      state.errorMessage!,
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ] else if (state.parkingLots.isEmpty && !state.isLoading) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No parking lots available in the database. Please contact admin.',
                      style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ] else if (state.parkingLots.isNotEmpty) ...[
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
            subtitle: state.selectedDate == null
                ? 'Please select a date first'
                : 'Select arrival time to find the best spots',
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _NativeTimePicker(
            label: 'ENTRY TIME',
            selectedTime: state.checkInTime,
            onTimeSelected: controller.selectCheckInTime,
            isDark: isDark,
            selectedDate: state.selectedDate,
            enabled: state.selectedDate != null,
          ),
          const SizedBox(height: 28),

          // ── Check-out Time ──
          _SectionHeader(
            icon: Icons.logout_rounded,
            title: 'Check-out Time',
            subtitle: state.selectedDate == null
                ? 'Please select a date first'
                : 'Estimated departure time',
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _NativeTimePicker(
            label: 'EXIT TIME',
            selectedTime: state.checkOutTime,
            onTimeSelected: controller.selectCheckOutTime,
            isDark: isDark,
            selectedDate: state.selectedDate,
            enabled: state.selectedDate != null,
            isCheckout: true,
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
                    ? const Color(0xFF2563eb).withValues(alpha: 0.25)
                    : const Color(0xFF2563eb).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: const Color(0xFF2563eb), size: 18),
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
                        colors: [Color(0xFF2563eb), Color(0xFF3b82f6)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )
                    : null,
                color: isSelected
                    ? null
                    : isToday
                        ? (isDark ? const Color(0xFF3b82f6).withValues(alpha: 0.1) : const Color(0xFFE0F7FA))
                        : (isDark ? const Color(0xFF1E293B) : Colors.white),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : isToday
                          ? const Color(0xFF3b82f6).withValues(alpha: 0.4)
                          : (isDark ? const Color(0xFF2A3A4A) : const Color(0xFFEDF0F4)),
                  width: isToday && !isSelected ? 1.5 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF2563eb).withValues(alpha: 0.3),
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
                              ? const Color(0xFF3b82f6)
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
                        color: isSelected ? Colors.white : const Color(0xFF3b82f6),
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
              ? [const Color(0xFF3b82f6).withValues(alpha: 0.15), const Color(0xFF2563eb).withValues(alpha: 0.15)]
              : [const Color(0xFFE0F7FA), const Color(0xFFE8F5E9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF3b82f6).withValues(alpha: 0.25) : const Color(0xFFB2DFDB),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF3b82f6).withValues(alpha: isDark ? 0.2 : 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.timer_outlined, color: Color(0xFF3b82f6), size: 20),
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
                  color: isDark ? const Color(0xFF3b82f6) : const Color(0xFF2563eb),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Native Time Picker ─────────────────────────────────────────────────────

class _NativeTimePicker extends StatelessWidget {
  final TimeOfDay? selectedTime;
  final ValueChanged<TimeOfDay> onTimeSelected;
  final bool isDark;
  final String label;
  final DateTime? selectedDate;
  final bool enabled;
  final bool isCheckout;

  const _NativeTimePicker({
    required this.selectedTime,
    required this.onTimeSelected,
    required this.isDark,
    required this.label,
    this.selectedDate,
    this.enabled = true,
    this.isCheckout = false,
  });

  bool _isToday(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  bool _isPastTime(TimeOfDay time) {
    if (isCheckout) return false; // Checkout can be earlier hour (wraps to next day)
    if (!_isToday(selectedDate)) return false;
    final now = TimeOfDay.now();
    return time.hour < now.hour || (time.hour == now.hour && time.minute < now.minute);
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = !enabled;

    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: InkWell(
        onTap: isDisabled ? null : () async {
          // If today, ensure initial time is not in the past
          TimeOfDay initialTime = selectedTime ?? TimeOfDay.now();
          if (_isToday(selectedDate)) {
            final now = TimeOfDay.now();
            // Round up to next hour if current time is in the past
            if (initialTime.hour < now.hour || 
                (initialTime.hour == now.hour && initialTime.minute <= now.minute)) {
              initialTime = TimeOfDay(hour: (now.hour + 1) % 24, minute: 0);
            }
          }

          final time = await showTimePicker(
            context: context,
            initialTime: initialTime,
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: const Color(0xFF2563eb),
                    onPrimary: Colors.white,
                    surface: isDark ? const Color(0xFF1e293b) : Colors.white,
                    onSurface: isDark ? Colors.white : const Color(0xFF1e293b),
                  ),
                ),
                child: child!,
              );
            },
          );
          if (time != null) {
            // Validate: if today, don't allow past times
            if (_isPastTime(time)) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Cannot select a time in the past'),
                    backgroundColor: Colors.red.shade600,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
              return;
            }
            onTimeSelected(time);
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1e293b) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFe2e8f0),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 15,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFF94a3b8) : const Color(0xFF64748b),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    selectedTime != null
                        ? '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                        : isDisabled ? 'Select date first' : '--:--',
                    style: TextStyle(
                      fontSize: selectedTime != null ? 28 : (isDisabled ? 16 : 28),
                      fontWeight: FontWeight.w900,
                      color: selectedTime != null
                          ? (isDark ? Colors.white : const Color(0xFF1e293b))
                          : (isDark ? const Color(0xFF475569) : const Color(0xFFcbd5e1)),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563eb).withValues(alpha: isDisabled ? 0.05 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.access_time_filled_rounded, 
                  color: Color(isDisabled ? 0xFF94A3B8 : 0xFF2563EB), 
                  size: 28,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
