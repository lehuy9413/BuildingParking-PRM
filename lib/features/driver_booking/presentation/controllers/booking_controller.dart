import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/parking_slot.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/ai_suggestion.dart';
import '../../data/datasources/mock_booking_datasource.dart';
import '../../data/repositories/booking_repository_impl.dart';

// ─── State ───────────────────────────────────────────────────────────────────

class BookingState extends Equatable {
  final int currentStep;
  final DateTime? selectedDate;
  final TimeOfDay? checkInTime;
  final TimeOfDay? checkOutTime;
  final VehicleType? vehicleType;
  final String licensePlate;
  final ParkingZone? selectedZone;
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
    this.vehicleType,
    this.licensePlate = '',
    this.selectedZone,
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
    VehicleType? vehicleType,
    String? licensePlate,
    ParkingZone? selectedZone,
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
      vehicleType: vehicleType ?? this.vehicleType,
      licensePlate: licensePlate ?? this.licensePlate,
      selectedZone: selectedZone ?? this.selectedZone,
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
      selectedDate != null && checkInTime != null && checkOutTime != null;

  bool get canProceedStep2 => vehicleType != null;

  bool get canProceedStep3 => selectedSlot != null;

  double get estimatedPrice {
    if (vehicleType == null || checkInTime == null || checkOutTime == null) {
      return 0.0;
    }
    final pricePerHour = vehicleType == VehicleType.car
        ? 3.0
        : vehicleType == VehicleType.ev
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
        vehicleType, licensePlate, selectedZone, selectedSlot,
        availableSlots, aiSuggestions, confirmedBooking,
        isLoading, isBookingConfirming, errorMessage,
      ];
}

// ─── Controller ──────────────────────────────────────────────────────────────

class BookingController extends Notifier<BookingState> {
  late final BookingRepositoryImpl _repository;

  @override
  BookingState build() {
    _repository = ref.watch(bookingRepositoryProvider);
    return const BookingState();
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

  void selectVehicleType(VehicleType type) {
    state = state.copyWith(vehicleType: type, clearError: true);
  }

  void setLicensePlate(String plate) {
    state = state.copyWith(licensePlate: plate);
  }

  // ── Step 3: Zone & Slot Selection ──

  void selectZone(ParkingZone zone) {
    state = state.copyWith(
      selectedZone: zone,
      clearSlot: true,
      clearError: true,
    );
    _loadAvailableSlots(zone);
  }

  Future<void> _loadAvailableSlots(ParkingZone zone) async {
    if (state.vehicleType == null || state.selectedDate == null) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final slots = await _repository.getAvailableSlots(
        vehicleType: state.vehicleType!,
        zone: zone,
        dateTime: state.selectedDate!,
      );
      state = state.copyWith(availableSlots: slots, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load slots: $e',
      );
    }
  }

  void selectSlot(ParkingSlot slot) {
    if (slot.status == SlotStatus.available) {
      state = state.copyWith(selectedSlot: slot, clearError: true);
    }
  }

  // ── AI Suggestions ──

  Future<void> loadAiSuggestions() async {
    if (state.vehicleType == null || state.selectedDate == null) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final suggestions = await _repository.getAiSuggestions(
        vehicleType: state.vehicleType!,
        dateTime: state.selectedDate!,
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
    state = state.copyWith(
      selectedZone: suggestion.recommendedSlot.zone,
      selectedSlot: suggestion.recommendedSlot,
      clearError: true,
    );
  }

  // ── Booking Confirmation ──

  Future<void> confirmBooking() async {
    if (state.selectedSlot == null ||
        state.vehicleType == null ||
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
      final checkOut = DateTime(
        state.selectedDate!.year,
        state.selectedDate!.month,
        state.selectedDate!.day,
        state.checkOutTime!.hour,
        state.checkOutTime!.minute,
      );

      final booking = await _repository.createBooking(
        slotId: state.selectedSlot!.id,
        vehicleType: state.vehicleType!,
        licensePlate: state.licensePlate.isEmpty ? null : state.licensePlate,
        checkInTime: checkIn,
        checkOutTime: checkOut,
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

final bookingRepositoryProvider = Provider<BookingRepositoryImpl>((ref) {
  return BookingRepositoryImpl(dataSource: MockBookingDataSource());
});

final bookingControllerProvider =
    NotifierProvider<BookingController, BookingState>(BookingController.new);
