import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/parking_slot.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/ai_suggestion.dart';
import '../../domain/entities/parking_lot.dart';
import '../../domain/entities/vehicle.dart';
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
  }) {
    return BookingState(
      currentStep: currentStep ?? this.currentStep,
      selectedDate: selectedDate ?? this.selectedDate,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      parkingLots: parkingLots ?? this.parkingLots,
      selectedParkingLot: selectedParkingLot ?? this.selectedParkingLot,
      myVehicles: myVehicles ?? this.myVehicles,
      selectedVehicle: selectedVehicle ?? this.selectedVehicle,
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

  bool get canProceedStep2 => selectedVehicle != null;

  bool get canProceedStep3 => selectedSlot != null;

  double get estimatedPrice {
    if (selectedVehicle == null || checkInTime == null || checkOutTime == null) {
      return 0.0;
    }
    final type = selectedVehicle!.vehicleTypeName.toLowerCase();
    final pricePerHour = type.contains('car')
        ? 3.0
        : type.contains('ev')
            ? 4.0
            : 1.0;
    final checkIn = DateTime(2024, 1, 1, checkInTime!.hour, checkInTime!.minute);
    final checkOut = DateTime(2024, 1, 1, checkOutTime!.hour, checkOutTime!.minute);
    final dur = checkOut.difference(checkIn);
    if (dur.isNegative) return 0.0;
    return pricePerHour * (dur.inMinutes / 60.0);
  }

  String get durationText {
    if (checkInTime == null || checkOutTime == null) return '—';
    final checkIn = DateTime(2024, 1, 1, checkInTime!.hour, checkInTime!.minute);
    final checkOut = DateTime(2024, 1, 1, checkOutTime!.hour, checkOutTime!.minute);
    final dur = checkOut.difference(checkIn);
    if (dur.isNegative) return 'Invalid';
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
    _initializeData();
    return const BookingState();
  }

  Future<void> _initializeData() async {
    state = state.copyWith(isLoading: true);
    try {
      final lots = await _repository.getParkingLots();
      final vehicles = await _repository.getMyVehicles();
      state = state.copyWith(
        parkingLots: lots,
        selectedParkingLot: lots.isNotEmpty ? lots.first : null,
        myVehicles: vehicles,
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
    state = state.copyWith(selectedDate: date, clearError: true);
  }

  void selectCheckInTime(TimeOfDay time) {
    state = state.copyWith(checkInTime: time, clearError: true);
    final suggestedCheckout = TimeOfDay(
      hour: (time.hour + 2) % 24,
      minute: time.minute,
    );
    if (state.checkOutTime == null) {
      state = state.copyWith(checkOutTime: suggestedCheckout);
    }
  }

  void selectCheckOutTime(TimeOfDay time) {
    state = state.copyWith(checkOutTime: time, clearError: true);
  }

  // ── Step 2: Vehicle Selection ──

  void selectVehicle(Vehicle vehicle) {
    state = state.copyWith(
      selectedVehicle: vehicle, 
      licensePlate: vehicle.licensePlate,
      clearError: true
    );
  }

  void setLicensePlate(String plate) {
    state = state.copyWith(licensePlate: plate);
  }

  // ── Step 3: Slot Selection ──

  Future<void> loadAvailableSlots() async {
    if (state.selectedVehicle == null || state.selectedParkingLot == null) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final slots = await _repository.getAvailableSlots(
        parkingLotId: state.selectedParkingLot!.id,
        vehicleTypeId: state.selectedVehicle!.vehicleTypeId,
      );
      state = state.copyWith(availableSlots: slots, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
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
    if (state.selectedVehicle == null || state.selectedParkingLot == null) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final suggestions = await _repository.getAiSuggestions(
        parkingLotId: state.selectedParkingLot!.id,
        vehicleTypeId: state.selectedVehicle!.vehicleTypeId,
      );
      state = state.copyWith(aiSuggestions: suggestions, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load AI suggestions: $e',
      );
    }
  }

  void selectAiSuggestion(AiSuggestion suggestion) {
    lockAndSelectSlot(suggestion.recommendedSlot);
  }

  // ── Booking Confirmation ──

  Future<void> confirmBooking() async {
    if (state.selectedSlot == null ||
        state.selectedVehicle == null ||
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

      final booking = await _repository.createBooking(
        parkingLotId: state.selectedParkingLot!.id,
        vehicleTypeId: state.selectedVehicle!.vehicleTypeId,
        scheduledDate: checkIn, // Sending the date
        startTime: '${state.checkInTime!.hour.toString().padLeft(2, '0')}:${state.checkInTime!.minute.toString().padLeft(2, '0')}',
        endTime: '${state.checkOutTime!.hour.toString().padLeft(2, '0')}:${state.checkOutTime!.minute.toString().padLeft(2, '0')}',
        vehicleId: state.selectedVehicle!.id,
        floorId: state.selectedSlot?.floorId,
        zoneId: state.selectedSlot?.zoneId,
      );

      state = state.copyWith(
        confirmedBooking: booking,
        isBookingConfirming: false,
      );
    } catch (e) {
      state = state.copyWith(
        isBookingConfirming: false,
        errorMessage: 'Booking failed: $e',
      );
    }
  }

  // ── Reset ──

  void resetBooking() {
    state = const BookingState();
  }
}

// ─── Providers ───────────────────────────────────────────────────────────────

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepositoryImpl(dataSource: ApiBookingDataSource());
});

final bookingControllerProvider =
    NotifierProvider<BookingController, BookingState>(BookingController.new);
