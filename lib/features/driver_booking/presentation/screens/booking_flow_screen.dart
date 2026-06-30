import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/booking_controller.dart';
import '../widgets/booking_step_time.dart';
import '../widgets/booking_step_vehicle.dart';
import '../widgets/booking_step_slot.dart';
import 'digital_ticket_screen.dart';

class BookingFlowScreen extends ConsumerStatefulWidget {
  const BookingFlowScreen({super.key, this.isEmbedded = false});

  /// When true, the screen is embedded inside a tab (no back navigation at step 0).
  final bool isEmbedded;

  @override
  ConsumerState<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends ConsumerState<BookingFlowScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _animateToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(bookingControllerProvider);
    final controller = ref.read(bookingControllerProvider.notifier);

    // Listen for step changes to animate PageView
    ref.listen<BookingState>(bookingControllerProvider, (prev, next) {
      if (prev?.currentStep != next.currentStep) {
        _animateToPage(next.currentStep);
      }
      // Navigate to ticket screen when booking is confirmed
      if (prev?.confirmedBooking == null && next.confirmedBooking != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DigitalTicketScreen(booking: next.confirmedBooking!),
          ),
        ).then((_) {
          // Reset booking state when returning from ticket screen
          ref.read(bookingControllerProvider.notifier).resetBooking();
        });
      }
    });

    // Determine whether to show back button
    final showBackButton = state.currentStep > 0 || !widget.isEmbedded;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: showBackButton
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
                onPressed: () {
                  if (state.currentStep > 0) {
                    controller.previousStep();
                  } else if (!widget.isEmbedded) {
                    controller.resetBooking();
                    Navigator.of(context).pop();
                  }
                },
              )
            : null,
        title: Text(
          'Book a Slot',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ── Stepper Indicator ──
          _StepIndicator(currentStep: state.currentStep, isDark: isDark),
          const SizedBox(height: 8),

          // ── PageView Content ──
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                BookingStepTime(),
                BookingStepVehicle(),
                BookingStepSlot(),
              ],
            ),
          ),

          // ── Bottom Navigation Buttons ──
          _BottomButtons(
            currentStep: state.currentStep,
            canProceed: _canProceedCurrentStep(state),
            isConfirming: state.isBookingConfirming,
            isDark: isDark,
            onBack: () => controller.previousStep(),
            onNext: () {
              if (state.currentStep == 2) {
                controller.confirmBooking();
              } else {
                controller.nextStep();
              }
            },
          ),
        ],
      ),
    );
  }

  bool _canProceedCurrentStep(BookingState state) {
    switch (state.currentStep) {
      case 0:
        return state.canProceedStep1;
      case 1:
        return state.canProceedStep2;
      case 2:
        return state.canProceedStep3;
      default:
        return false;
    }
  }
}

// ─── Step Indicator ──────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.currentStep, required this.isDark});

  final int currentStep;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    const steps = [
      ('Time', Icons.schedule_rounded),
      ('Vehicle', Icons.directions_car_filled_rounded),
      ('Slot', Icons.space_dashboard_rounded),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2332) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2A3A4A) : const Color(0xFFE8EDF2),
        ),
      ),
      child: Row(
        children: [
          _buildStep(0, steps[0].$1, steps[0].$2),
          _buildConnector(0),
          _buildStep(1, steps[1].$1, steps[1].$2),
          _buildConnector(1),
          _buildStep(2, steps[2].$1, steps[2].$2),
        ],
      ),
    );
  }

  Widget _buildStep(int step, String label, IconData icon) {
    final isCompleted = currentStep > step;
    final isCurrent = currentStep == step;

    return Expanded(
      flex: 2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            width: isCurrent ? 36 : 28,
            height: isCurrent ? 36 : 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted
                  ? const Color(0xFF1B998B)
                  : isCurrent
                      ? const Color(0xFF0F4C5C)
                      : (isDark ? const Color(0xFF2A3A4A) : const Color(0xFFE2E8F0)),
              boxShadow: isCurrent
                  ? [
                      BoxShadow(
                        color: const Color(0xFF0F4C5C).withOpacity(0.35),
                        blurRadius: 12,
                        spreadRadius: 1,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : isCompleted
                      ? [
                          BoxShadow(
                            color: const Color(0xFF1B998B).withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: isCompleted
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 16, key: ValueKey('check'))
                    : Icon(
                        icon,
                        color: isCurrent
                            ? Colors.white
                            : (isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                        size: isCurrent ? 18 : 14,
                        key: const ValueKey('icon'),
                      ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isCurrent ? 13 : 12,
                fontWeight: isCurrent
                    ? FontWeight.w800
                    : isCompleted
                        ? FontWeight.w700
                        : FontWeight.w500,
                color: isCurrent
                    ? (isDark ? Colors.white : const Color(0xFF0F4C5C))
                    : isCompleted
                        ? const Color(0xFF1B998B)
                        : (isDark ? Colors.grey.shade600 : Colors.grey.shade400),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnector(int afterStep) {
    final isActive = currentStep > afterStep;
    return Expanded(
      flex: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 2,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A3A4A) : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                return AnimatedAlign(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.centerLeft,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                    height: 2,
                    width: isActive ? constraints.maxWidth : 0,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1B998B), Color(0xFF0F4C5C)],
                      ),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Bottom Buttons ──────────────────────────────────────────────────────────

class _BottomButtons extends StatelessWidget {
  const _BottomButtons({
    required this.currentStep,
    required this.canProceed,
    required this.isConfirming,
    required this.isDark,
    required this.onBack,
    required this.onNext,
  });

  final int currentStep;
  final bool canProceed;
  final bool isConfirming;
  final bool isDark;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A202C) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Row(
        children: [
          if (currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: onBack,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                    color: isDark ? Colors.grey.shade600 : const Color(0xFFCBD5E1),
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Back',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: isDark ? Colors.grey.shade300 : const Color(0xFF475569),
                  ),
                ),
              ),
            ),
          if (currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: currentStep > 0 ? 2 : 1,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: ElevatedButton(
                onPressed: canProceed && !isConfirming ? onNext : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF0F4C5C),
                  disabledBackgroundColor:
                      isDark ? const Color(0xFF2D3748) : const Color(0xFFE2E8F0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: canProceed ? 4 : 0,
                  shadowColor: const Color(0xFF0F4C5C).withOpacity(0.4),
                ),
                child: isConfirming
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        currentStep == 2 ? 'Confirm Booking' : 'Continue',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: canProceed
                              ? Colors.white
                              : (isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
