import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../controllers/booking_controller.dart';

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
                      ? const Color(0xFF0F4C5C).withValues(alpha: 0.3)
                      : const Color(0xFF0F4C5C).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.directions_car_rounded, color: Color(0xFF0F4C5C), size: 20),
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
              IconData icon = Icons.directions_car_rounded;
              Color color = const Color(0xFF3B82F6);
              if (typeLower.contains('motor')) {
                icon = Icons.two_wheeler_rounded;
                color = const Color(0xFFA855F7);
              } else if (typeLower.contains('ev') || typeLower.contains('electric')) {
                icon = Icons.electric_car_rounded;
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

          // (Removed Manual License Plate Input as it's selected from list)
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
              ? [const Color(0xFF065F46), const Color(0xFF047857)]
              : [const Color(0xFF10B981), const Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF059669).withValues(alpha: 0.3),
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
                '\$${price.toStringAsFixed(2)}',
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
