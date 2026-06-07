import 'dart:math';
import '../../domain/entities/parking_slot.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/ai_suggestion.dart';

class MockBookingDataSource {
  final _random = Random();
  final List<Booking> _bookings = [];

  Future<List<ParkingSlot>> getAvailableSlots({
    required VehicleType vehicleType,
    required ParkingZone zone,
    required DateTime dateTime,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final slots = <ParkingSlot>[];
    final prefix = _getZonePrefix(zone);
    final total = vehicleType == VehicleType.motorbike ? 30 : 15;

    for (int i = 1; i <= total; i++) {
      final isAvailable = _random.nextDouble() > 0.4;
      slots.add(ParkingSlot(
        id: '${prefix}_${vehicleType.name}_$i',
        slotNumber: '$prefix-${i.toString().padLeft(3, '0')}',
        zone: zone,
        vehicleType: vehicleType,
        status: isAvailable ? SlotStatus.available : SlotStatus.occupied,
        floor: _getFloorForZone(zone),
        pricePerHour: vehicleType == VehicleType.car
            ? 3.0
            : vehicleType == VehicleType.ev
                ? 4.0
                : 1.0,
      ));
    }
    return slots;
  }

  Future<Booking> createBooking({
    required String slotId,
    required VehicleType vehicleType,
    required String? licensePlate,
    required DateTime checkInTime,
    required DateTime checkOutTime,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    final duration = checkOutTime.difference(checkInTime);
    final pricePerHour = vehicleType == VehicleType.car
        ? 3.0
        : vehicleType == VehicleType.ev
            ? 4.0
            : 1.0;
    final totalPrice = pricePerHour * (duration.inMinutes / 60.0);
    final zone = _getZoneFromSlotId(slotId);
    final slotNumber = _getSlotNumberFromId(slotId);

    final booking = Booking(
      id: 'BK${DateTime.now().millisecondsSinceEpoch}',
      slotId: slotId,
      slotNumber: slotNumber,
      zone: zone,
      vehicleType: vehicleType,
      licensePlate: licensePlate,
      checkInTime: checkInTime,
      checkOutTime: checkOutTime,
      totalPrice: totalPrice,
      status: BookingStatus.confirmed,
      qrCode: 'QR_BK${DateTime.now().millisecondsSinceEpoch}_$slotId',
      createdAt: DateTime.now(),
    );
    _bookings.add(booking);
    return booking;
  }

  Future<Booking> getBookingById(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _bookings.firstWhere((b) => b.id == bookingId);
  }

  Future<List<Booking>> getUserBookings() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return List.from(_bookings.reversed);
  }

  Future<void> cancelBooking(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _bookings.removeWhere((b) => b.id == bookingId);
  }

  Future<List<AiSuggestion>> getAiSuggestions({
    required VehicleType vehicleType,
    required DateTime dateTime,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    final suggestions = <AiSuggestion>[];
    final zones = ParkingZone.values;

    for (int i = 0; i < 3; i++) {
      final zone = zones[i];
      final prefix = _getZonePrefix(zone);
      final slotNum = _random.nextInt(20) + 1;

      suggestions.add(AiSuggestion(
        id: 'ai_${i + 1}',
        recommendedSlot: ParkingSlot(
          id: '${prefix}_${vehicleType.name}_$slotNum',
          slotNumber: '$prefix-${slotNum.toString().padLeft(3, '0')}',
          zone: zone,
          vehicleType: vehicleType,
          status: SlotStatus.available,
          floor: _getFloorForZone(zone),
          pricePerHour: vehicleType == VehicleType.car ? 3.0 : 1.0,
        ),
        confidenceScore: 0.95 - (i * 0.1) + (_random.nextDouble() * 0.05),
        reason: _getAiReason(i),
        estimatedWalkTimeMinutes: 2 + (i * 2) + _random.nextInt(3),
        occupancyRate: 0.3 + (i * 0.15) + (_random.nextDouble() * 0.1),
        advantages: _getAdvantages(i),
      ));
    }
    return suggestions;
  }

  String _getZonePrefix(ParkingZone zone) {
    switch (zone) {
      case ParkingZone.zoneA: return 'A';
      case ParkingZone.zoneB: return 'B';
      case ParkingZone.zoneC: return 'C';
      case ParkingZone.zoneD: return 'D';
    }
  }

  String _getFloorForZone(ParkingZone zone) {
    switch (zone) {
      case ParkingZone.zoneA: return 'Ground Floor';
      case ParkingZone.zoneB: return 'Level 1';
      case ParkingZone.zoneC: return 'Level 2';
      case ParkingZone.zoneD: return 'Rooftop';
    }
  }

  ParkingZone _getZoneFromSlotId(String slotId) {
    if (slotId.startsWith('A')) return ParkingZone.zoneA;
    if (slotId.startsWith('B')) return ParkingZone.zoneB;
    if (slotId.startsWith('C')) return ParkingZone.zoneC;
    return ParkingZone.zoneD;
  }

  String _getSlotNumberFromId(String slotId) {
    final parts = slotId.split('_');
    return '${parts.first}-${parts.last.padLeft(3, '0')}';
  }

  String _getAiReason(int index) {
    const reasons = [
      'Lowest occupancy rate near entrance, minimizing your walking distance and time to find a spot.',
      'Predicted low traffic area based on historical patterns. This zone typically has 40% fewer vehicles at this hour.',
      'Near elevator access with good security camera coverage. Optimal balance of convenience and safety.',
    ];
    return reasons[index % reasons.length];
  }

  List<String> _getAdvantages(int index) {
    const allAdvantages = [
      ['Closest to entrance', 'Well-lit area', 'Near elevator', 'Low occupancy'],
      ['Near exit gate', 'Covered parking', 'Security cameras', 'Wide lanes'],
      ['Near elevator', 'EV charging nearby', 'Shaded area', 'Easy maneuver'],
    ];
    return allAdvantages[index % allAdvantages.length];
  }
}
