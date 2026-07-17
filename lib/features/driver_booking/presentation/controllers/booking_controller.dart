import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/parking_slot.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/ai_suggestion.dart';
import '../../domain/entities/parking_lot.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/entities/vehicle_type.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../data/datasources/api_booking_datasource.dart';
import '../../data/repositories/booking_repository_impl.dart';

// ─── State ───────────────────────────────────────────────────────────────────

class BookingState extends Equatable {
  final int currentStep;
  final DateTime? selectedDate;
  final TimeOfDay? checkInTime;
  final TimeOfDay? checkOutTime;
  
  final List<ParkingLot> parkingLots;
  final ParkingLot? selectedParkingLot;
  
  final List<Vehicle> myVehicles;
  final Vehicle? selectedVehicle;

  final List<VehicleType> vehicleTypes;
  final VehicleType? selectedVehicleType;

  final String licensePlate;
  final ParkingSlot? selectedSlot;
  final List<ParkingSlot> availableSlots;
  final List<AiSuggestion> aiSuggestions;
  final Booking? confirmedBooking;
  final bool isLoading;
  final bool isBookingConfirming;
  final String? errorMessage;

  const BookingState({
    this.currentStep = 0,
    this.selectedDate,
    this.checkInTime,
    this.checkOutTime,
    this.parkingLots = const [],
    this.selectedParkingLot,
    this.myVehicles = const [],
    this.selectedVehicle,
    this.vehicleTypes = const [],
    this.selectedVehicleType,
    this.licensePlate = '',
    this.selectedSlot,
    this.availableSlots = const [],
    this.aiSuggestions = const [],
    this.confirmedBooking,
    this.isLoading = false,
    this.isBookingConfirming = false,
    this.errorMessage,
  });

  BookingState copyWith({
    int? currentStep,
    DateTime? selectedDate,
    TimeOfDay? checkInTime,
    TimeOfDay? checkOutTime,
    List<ParkingLot>? parkingLots,
    ParkingLot? selectedParkingLot,
    List<Vehicle>? myVehicles,
    Vehicle? selectedVehicle,
    List<VehicleType>? vehicleTypes,
    VehicleType? selectedVehicleType,
    String? licensePlate,
    ParkingSlot? selectedSlot,
    List<ParkingSlot>? availableSlots,
    List<AiSuggestion>? aiSuggestions,
    Booking? confirmedBooking,
    bool? isLoading,
    bool? isBookingConfirming,
    String? errorMessage,
    bool clearSlot = false,
    bool clearBooking = false,
    bool clearError = false,
    bool clearTime = false,
  }) {
    return BookingState(
      currentStep: currentStep ?? this.currentStep,
      selectedDate: selectedDate ?? this.selectedDate,
      checkInTime: clearTime ? checkInTime : (checkInTime ?? this.checkInTime),
      checkOutTime: clearTime ? checkOutTime : (checkOutTime ?? this.checkOutTime),
      parkingLots: parkingLots ?? this.parkingLots,
      selectedParkingLot: selectedParkingLot ?? this.selectedParkingLot,
      myVehicles: myVehicles ?? this.myVehicles,
      selectedVehicle: selectedVehicle ?? this.selectedVehicle,
      vehicleTypes: vehicleTypes ?? this.vehicleTypes,
      selectedVehicleType: selectedVehicleType ?? this.selectedVehicleType,
      licensePlate: licensePlate ?? this.licensePlate,
      selectedSlot: clearSlot ? null : (selectedSlot ?? this.selectedSlot),
      availableSlots: availableSlots ?? this.availableSlots,
      aiSuggestions: aiSuggestions ?? this.aiSuggestions,
      confirmedBooking: clearBooking ? null : (confirmedBooking ?? this.confirmedBooking),
      isLoading: isLoading ?? this.isLoading,
      isBookingConfirming: isBookingConfirming ?? this.isBookingConfirming,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  bool get canProceedStep1 =>
      selectedDate != null && checkInTime != null && checkOutTime != null && selectedParkingLot != null;

  bool get canProceedStep2 {
    if (selectedVehicle != null) return true;
    if (licensePlate.trim().isNotEmpty && selectedVehicleType != null) return true;
    return false;
  }

  bool get canProceedStep3 => selectedSlot != null;

  double get estimatedPrice {
    final hasValidVehicle = selectedVehicle != null || selectedVehicleType != null;
    if (!hasValidVehicle || checkInTime == null || checkOutTime == null) {
      return 0.0;
    }

    // Use pricing from backend (vehicle or vehicleType), fallback to logic below if 0
    final dRate = selectedVehicle?.dayBlockRate ?? selectedVehicleType?.dayBlockRate ?? 0.0;
    final nRate = selectedVehicle?.nightBlockRate ?? selectedVehicleType?.nightBlockRate ?? 0.0;

    // Determine vehicle type for fallback
    final vTypeName = (selectedVehicleType?.name ?? selectedVehicle?.vehicleTypeName ?? '').toLowerCase();
    final isCar = vTypeName.contains('ô tô') || vTypeName.contains('oto') || vTypeName.contains('car');

    // Default fallbacks: Motorbike (2k/3k), Car (4k/5k)
    final defaultDayRate = isCar ? 4000.0 : 2000.0;
    final defaultNightRate = isCar ? 5000.0 : 3000.0;

    // Day is 6:00 to 18:00, Night is 18:00 to 6:00
    final dayRate = dRate > 0 ? dRate : defaultDayRate;
    final nightRate = nRate > 0 ? nRate : defaultNightRate;

    // Calculate duration in blocks of 4 hours
    final baseDate = selectedDate ?? DateTime.now();
    var tempStart = DateTime(baseDate.year, baseDate.month, baseDate.day,
        checkInTime!.hour, checkInTime!.minute);
    final exitDateTime = DateTime(baseDate.year, baseDate.month, baseDate.day,
        checkOutTime!.hour, checkOutTime!.minute);
    // Handle overnight
    final tempExit = exitDateTime.isBefore(tempStart) 
        ? exitDateTime.add(const Duration(days: 1)) 
        : exitDateTime;

    double totalCost = 0;
    while (tempStart.isBefore(tempExit)) {
      final startHour = tempStart.hour;
      final isNightBlock = startHour >= 18 || startHour < 6;
      totalCost += isNightBlock ? nightRate : dayRate;
      tempStart = tempStart.add(const Duration(hours: 4));
    }

    return totalCost;
  }

  String get durationText {
    if (checkInTime == null || checkOutTime == null) return '—';
    final checkIn = DateTime(2024, 1, 1, checkInTime!.hour, checkInTime!.minute);
    var checkOut = DateTime(2024, 1, 1, checkOutTime!.hour, checkOutTime!.minute);
    
    // Handle overnight
    if (checkOut.isBefore(checkIn)) {
      checkOut = checkOut.add(const Duration(days: 1));
    }
    
    final dur = checkOut.difference(checkIn);
    final hours = dur.inHours;
    final minutes = dur.inMinutes % 60;
    if (hours == 0) return '${minutes}m';
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}m';
  }

  @override
  List<Object?> get props => [
        currentStep, selectedDate, checkInTime, checkOutTime,
        parkingLots, selectedParkingLot, myVehicles, selectedVehicle,
        vehicleTypes, selectedVehicleType,
        licensePlate, selectedSlot, availableSlots, aiSuggestions, confirmedBooking,
        isLoading, isBookingConfirming, errorMessage,
      ];
}

// ─── Controller ──────────────────────────────────────────────────────────────

class BookingController extends Notifier<BookingState> {
  late final BookingRepository _repository;

  @override
  BookingState build() {
    _repository = ref.watch(bookingRepositoryProvider);
    Future.microtask(_initializeData);
    return const BookingState(isLoading: true);
  }

  Future<void> _initializeData() async {
    try {
      final lots = await _repository.getParkingLots();
      final vehicles = await _repository.getMyVehicles();
      final vTypes = await _repository.getVehicleTypes();
      state = state.copyWith(
        parkingLots: lots,
        selectedParkingLot: lots.isNotEmpty ? lots.first : null,
        myVehicles: vehicles,
        vehicleTypes: vTypes,
        selectedVehicleType: vTypes.isNotEmpty ? vTypes.first : null,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load initial data: $e',
      );
    }
  }

  // ── Step Navigation ──

  void goToStep(int step) {
    if (step >= 0 && step <= 2) {
      state = state.copyWith(currentStep: step, clearError: true);
    }
  }

  void nextStep() {
    if (state.currentStep < 2) {
      state = state.copyWith(currentStep: state.currentStep + 1, clearError: true);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1, clearError: true);
    }
  }

  // ── Step 1: Time Selection ──

  void selectParkingLot(ParkingLot lot) {
    state = state.copyWith(selectedParkingLot: lot, clearError: true);
  }

  void selectDate(DateTime date) {
    // Reset times when date changes to prevent stale past times
    final now = DateTime.now();
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
    
    // If switching to today and existing times are in the past, clear them
    if (isToday && state.checkInTime != null) {
      final currentHour = now.hour;
      final currentMinute = now.minute;
      if (state.checkInTime!.hour < currentHour || 
          (state.checkInTime!.hour == currentHour && state.checkInTime!.minute < currentMinute)) {
        state = state.copyWith(
          selectedDate: date,
          clearTime: true,
          clearError: true,
        );
        return;
      }
    }
    state = state.copyWith(selectedDate: date, clearError: true);
  }

  void selectCheckInTime(TimeOfDay time) {
    final suggestedCheckout = TimeOfDay(
      hour: (time.hour + 4) % 24,
      minute: time.minute,
    );
    state = state.copyWith(
      checkInTime: time, 
      checkOutTime: suggestedCheckout,
      clearError: true
    );
  }

  void selectCheckOutTime(TimeOfDay time) {
    state = state.copyWith(checkOutTime: time, clearError: true);
  }

  // ── Step 2: Vehicle Selection ──

  void selectVehicle(Vehicle vehicle) {
    state = state.copyWith(
      selectedVehicle: vehicle, 
      licensePlate: vehicle.licensePlate, // Auto-fill license plate
      clearError: true
    );
  }

  void selectVehicleType(VehicleType type) {
    state = state.copyWith(selectedVehicleType: type, clearError: true);
  }

  void setLicensePlate(String licensePlate) {
    state = state.copyWith(licensePlate: licensePlate, clearError: true);
  }

  // ── Step 3: Slot Selection ──

  Future<void> loadAvailableSlots() async {
    final vId = state.selectedVehicle?.vehicleTypeId ?? state.selectedVehicleType?.id;
    if (vId == null || state.selectedParkingLot == null) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      // ignore: avoid_print
      print('[BookingController] Loading slots for lot=${state.selectedParkingLot!.id}, vehicleType=$vId');
      // Format times
      final startTimeStr = state.checkInTime != null 
          ? '${state.checkInTime!.hour.toString().padLeft(2, '0')}:${state.checkInTime!.minute.toString().padLeft(2, '0')}'
          : null;
      final endTimeStr = state.checkOutTime != null
          ? '${state.checkOutTime!.hour.toString().padLeft(2, '0')}:${state.checkOutTime!.minute.toString().padLeft(2, '0')}'
          : null;

      final slots = await _repository.getAvailableSlots(
        parkingLotId: state.selectedParkingLot!.id,
        vehicleTypeId: vId,
        scheduledDate: state.selectedDate,
        startTime: startTimeStr,
        endTime: endTimeStr,
      );
      // ignore: avoid_print
      print('[BookingController] Loaded ${slots.length} slots');
      state = state.copyWith(availableSlots: slots);
      
      // Auto load AI suggestions and pick the best slot
      await loadAiSuggestions();
    } catch (e) {
      // ignore: avoid_print
      print('[BookingController] Error loading slots: $e');
      state = state.copyWith(
        isLoading: false,
        availableSlots: [],
        errorMessage: 'Failed to load slots: $e',
      );
    }
  }

  Future<void> lockAndSelectSlot(ParkingSlot slot) async {
    if (slot.status != SlotStatus.available) return;
    
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final success = await _repository.lockSlot(slot.id);
      if (success) {
        state = state.copyWith(
          selectedSlot: slot, 
          isLoading: false
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Slot already locked by someone else.'
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error locking slot: $e'
      );
    }
  }

  Future<void> unlockSlot() async {
    if (state.selectedSlot != null) {
      try {
        await _repository.unlockSlot(state.selectedSlot!.id);
        state = state.copyWith(clearSlot: true);
      } catch (_) {}
    }
  }

  // ── AI Suggestions ──

  Future<void> loadAiSuggestions() async {
    final vId = state.selectedVehicle?.vehicleTypeId ?? state.selectedVehicleType?.id;
    if (vId == null || state.selectedParkingLot == null) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final suggestions = await _repository.getAiSuggestions(
        parkingLotId: state.selectedParkingLot!.id,
        vehicleTypeId: vId,
      );
      state = state.copyWith(
        aiSuggestions: suggestions, 
        isLoading: false,
        selectedSlot: suggestions.isNotEmpty ? suggestions.first.recommendedSlot : null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load AI suggestions: $e',
      );
    }
  }

  void selectAiSuggestion(AiSuggestion suggestion) {
    state = state.copyWith(selectedSlot: suggestion.recommendedSlot);
  }

  // ── Booking Confirmation ──

  Future<void> confirmBooking() async {
    final hasValidVehicle = state.selectedVehicle != null || 
        (state.licensePlate.trim().isNotEmpty && state.selectedVehicleType != null);

    if (state.selectedSlot == null ||
        !hasValidVehicle ||
        state.selectedDate == null ||
        state.checkInTime == null ||
        state.checkOutTime == null) {
      state = state.copyWith(errorMessage: 'Please complete all steps');
      return;
    }

    state = state.copyWith(isBookingConfirming: true, clearError: true);

    try {
      final checkIn = DateTime(
        state.selectedDate!.year,
        state.selectedDate!.month,
        state.selectedDate!.day,
        state.checkInTime!.hour,
        state.checkInTime!.minute,
      );

      var booking = await _repository.createBooking(
        parkingLotId: state.selectedParkingLot!.id,
        vehicleTypeId: state.selectedVehicle?.vehicleTypeId ?? state.selectedVehicleType!.id,
        scheduledDate: checkIn,
        startTime: '${state.checkInTime!.hour.toString().padLeft(2, '0')}:${state.checkInTime!.minute.toString().padLeft(2, '0')}',
        endTime: '${state.checkOutTime!.hour.toString().padLeft(2, '0')}:${state.checkOutTime!.minute.toString().padLeft(2, '0')}',
        licensePlate: state.licensePlate,
        floorId: state.selectedSlot?.floorId,
        zoneId: state.selectedSlot?.zoneId,
        assignedSlot: state.selectedSlot?.id,
      );

      // Enrich booking with local slot info when API doesn't return populated zone/floor
      if (state.selectedSlot != null) {
        final slot = state.selectedSlot!;
        booking = Booking(
          id: booking.id,
          bookingCode: booking.bookingCode,
          parkingLotId: booking.parkingLotId,
          parkingLotName: booking.parkingLotName.isNotEmpty 
              ? booking.parkingLotName 
              : (state.selectedParkingLot?.name ?? ''),
          slotId: booking.slotId ?? slot.id,
          slotCode: booking.slotCode ?? slot.slotCode,
          floorName: booking.floorName ?? slot.floorName,
          zoneName: booking.zoneName ?? slot.zoneName,
          vehicleTypeName: booking.vehicleTypeName.isNotEmpty 
              ? booking.vehicleTypeName 
              : (state.selectedVehicle?.vehicleTypeName ?? state.selectedVehicleType?.name ?? ''),
          licensePlate: booking.licensePlate.isNotEmpty 
              ? booking.licensePlate 
              : state.licensePlate,
          scheduledDate: booking.scheduledDate,
          startTime: booking.startTime,
          endTime: booking.endTime,
          estimatedFee: booking.estimatedFee > 0 ? booking.estimatedFee : state.estimatedPrice,
          status: booking.status,
          qrCode: booking.qrCode,
        );
      }

      state = state.copyWith(
        confirmedBooking: booking,
        isBookingConfirming: false,
      );
    } catch (e) {
      // Clean up error message for user display
      String errorMsg = e.toString();
      if (errorMsg.startsWith('Exception: ')) {
        errorMsg = errorMsg.substring('Exception: '.length);
      }
      state = state.copyWith(
        isBookingConfirming: false,
        errorMessage: errorMsg,
      );
    }
  }

  // ── Reset ──

  void resetBooking() {
    state = BookingState(
      parkingLots: state.parkingLots,
      myVehicles: state.myVehicles,
      vehicleTypes: state.vehicleTypes,
      // all other fields revert to default
    );
  }
}

// ─── Providers ───────────────────────────────────────────────────────────────

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepositoryImpl(dataSource: ApiBookingDataSource());
});

final bookingControllerProvider =
    NotifierProvider<BookingController, BookingState>(BookingController.new);
