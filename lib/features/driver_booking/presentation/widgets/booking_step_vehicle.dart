import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/booking_controller.dart';
import '../../../../core/utils/vehicle_icon_helper.dart';

class BookingStepVehicle extends ConsumerWidget {
  const BookingStepVehicle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(bookingControllerProvider);
    final controller = ref.read(bookingControllerProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section Title ──
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF2563eb).withValues(alpha: 0.2)
                      : const Color(0xFF2563eb).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.directions_car_rounded, color: Color(0xFF2563eb), size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Select Vehicle',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Loading state ──
          if (state.isLoading && state.myVehicles.isEmpty)
            const Center(child: CircularProgressIndicator()),

          // ── My Vehicles List ──
          if (!state.isLoading && state.myVehicles.isEmpty)
            Center(
              child: Text(
                'No vehicles found. Please add a vehicle first.',
                style: TextStyle(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
            ),
          
          if (state.myVehicles.isNotEmpty)
            ...state.myVehicles.map((vehicle) {
              final isSelected = state.selectedVehicle?.id == vehicle.id;
              final typeLower = vehicle.vehicleTypeName.toLowerCase();
              IconData icon = VehicleIconHelper.getIconForVehicleType(vehicle.vehicleTypeName);
              Color color = const Color(0xFF2563eb);
              if (typeLower.contains('motor') || typeLower.contains('xe máy')) {
                color = const Color(0xFFA855F7);
              } else if (typeLower.contains('ev') || typeLower.contains('điện') || typeLower.contains('electric')) {
                color = const Color(0xFF059669);
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _VehicleCard(
                  icon: icon,
                  title: vehicle.licensePlate,
                  subtitle: vehicle.vehicleTypeName,
                  price: '', // Removed fixed price here
                  color: color,
                  bgColor: isSelected 
                    ? color.withValues(alpha: 0.2) 
                    : (isDark ? color.withValues(alpha: 0.1) : color.withValues(alpha: 0.05)),
                  isSelected: isSelected,
                  isDark: isDark,
                  onTap: () => controller.selectVehicle(vehicle),
                ),
              );
            }),
          const SizedBox(height: 32),

          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Or Enter Manually',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Optional',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: state.licensePlate,
            onChanged: controller.setLicensePlate,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              letterSpacing: 2,
            ),
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'e.g. 59A-123.45',
              hintStyle: TextStyle(
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                fontWeight: FontWeight.w500,
                letterSpacing: 1,
              ),
              prefixIcon: Icon(
                Icons.badge_outlined,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
              ),
              filled: true,
              fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF0F4C5C), width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
          const SizedBox(height: 16),
          
          if (state.vehicleTypes.isNotEmpty)
            DropdownButtonFormField<String>(
              initialValue: state.selectedVehicleType?.id,
              decoration: InputDecoration(
                hintText: 'Select Vehicle Type',
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: Icon(
                  Icons.commute_outlined,
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              items: state.vehicleTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type.id,
                  child: Text(
                    type.name,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  final vt = state.vehicleTypes.firstWhere((t) => t.id == val);
                  controller.selectVehicleType(vt);
                }
              },
            ),
          
          const SizedBox(height: 32),

          // ── Estimated Price ──
          if (state.selectedVehicle != null && state.checkInTime != null && state.checkOutTime != null)
            _EstimatedPriceCard(
              price: state.estimatedPrice,
              duration: state.durationText,
              isDark: isDark,
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ─── Vehicle Card ────────────────────────────────────────────────────────────

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.color,
    required this.bgColor,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String price;
  final Color color;
  final Color bgColor;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? color.withValues(alpha: 0.15) : color.withValues(alpha: 0.08))
              : (isDark ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (price.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  price,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: color,
                  ),
                ),
              ),
            if (isSelected) ...[
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Estimated Price Card ────────────────────────────────────────────────────

class _EstimatedPriceCard extends StatelessWidget {
  const _EstimatedPriceCard({
    required this.price,
    required this.duration,
    required this.isDark,
  });

  final double price;
  final String duration;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1e293b), const Color(0xFF0f172a)]
              : [const Color(0xFF2563eb), const Color(0xFF1d4ed8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : const Color(0xFF2563eb)).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.payments_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Estimated Total',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${price.toInt()} VND',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              duration,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
