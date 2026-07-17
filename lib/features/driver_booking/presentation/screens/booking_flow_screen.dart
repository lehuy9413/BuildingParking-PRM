import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../data/datasources/api_booking_datasource.dart';
import '../controllers/booking_controller.dart';
import '../widgets/booking_step_time.dart';
import '../widgets/booking_step_vehicle.dart';
import '../widgets/booking_step_slot.dart';
import 'digital_ticket_screen.dart';

class BookingFlowScreen extends ConsumerStatefulWidget {
  const BookingFlowScreen({super.key, this.isEmbedded = false});

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

    ref.listen<BookingState>(bookingControllerProvider, (prev, next) {
      if (prev?.currentStep != next.currentStep) {
        _animateToPage(next.currentStep);
      }
      if (prev?.errorMessage != next.errorMessage && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    });

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
          _StepIndicator(currentStep: state.currentStep, isDark: isDark),
          const SizedBox(height: 8),
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
          _BottomButtons(
            currentStep: state.currentStep,
            canProceed: _canProceedCurrentStep(state),
            isConfirming: state.isBookingConfirming,
            isDark: isDark,
            onBack: () => controller.previousStep(),
            onNext: () async {
              if (state.currentStep == 2) {
                await controller.confirmBooking();
                final confirmed = ref.read(bookingControllerProvider).confirmedBooking;
                if (confirmed != null && mounted) {
                  if (state.paymentMethod == 'qr') {
                    _showQrPaymentSheet(context, confirmed.id, isDark);
                  } else {
                    // Cash: đặt chỗ xong, trả tiền lúc lấy xe
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => DigitalTicketScreen(booking: confirmed),
                    )).then((_) {
                      ref.read(bookingControllerProvider.notifier).resetBooking();
                    });
                  }
                }
              } else {
                controller.nextStep();
              }
            },
          ),
        ],
      ),
    );
  }

  void _showQrPaymentSheet(BuildContext context, String bookingId, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _BookingQrSheet(
        bookingId: bookingId,
        isDark: isDark,
        onPaid: () {
          Navigator.pop(ctx);
          final confirmed = ref.read(bookingControllerProvider).confirmedBooking;
          if (confirmed != null) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => DigitalTicketScreen(booking: confirmed),
            )).then((_) {
              ref.read(bookingControllerProvider.notifier).resetBooking();
            });
          }
        },
      ),
    );
  }

  bool _canProceedCurrentStep(BookingState state) {
    switch (state.currentStep) {
      case 0: return state.canProceedStep1;
      case 1: return state.canProceedStep2;
      case 2: return state.canProceedStep3;
      default: return false;
    }
  }
}

// ─── QR Payment Bottom Sheet ─────────────────────────────────────────────────

class _BookingQrSheet extends StatefulWidget {
  const _BookingQrSheet({
    required this.bookingId,
    required this.isDark,
    required this.onPaid,
  });

  final String bookingId;
  final bool isDark;
  final VoidCallback onPaid;

  @override
  State<_BookingQrSheet> createState() => _BookingQrSheetState();
}

class _BookingQrSheetState extends State<_BookingQrSheet> {
  bool _loading = true;
  String? _error;
  String? _qrUrl;
  String? _transferContent;
  String? _bankInfo;
  double? _amount;
  String? _paymentId;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _initQr();
  }

  @override
  void dispose() {
    _isChecking = false;
    super.dispose();
  }

  Future<void> _initQr() async {
    try {
      final ds = ApiBookingDataSource();
      final data = await ds.initiateBookingQrPayment(widget.bookingId);
      if (mounted) {
        setState(() {
          _loading = false;
          _qrUrl = data['qrUrl'] as String?;
          _transferContent = data['transferContent'] as String?;
          final bi = data['bankInfo'];
          if (bi is Map) {
            _bankInfo = '${bi['bankName']} – ${bi['accountNumber']} (${bi['accountName']})';
          }
          _amount = (data['amount'] as num?)?.toDouble();
          
          final paymentObj = data['payment'];
          if (paymentObj is Map && paymentObj['_id'] != null) {
            _paymentId = paymentObj['_id'].toString();
            _startPolling();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  void _startPolling() async {
    _isChecking = true;
    final ds = ApiBookingDataSource(); // Reusing the DIO instance
    while (_isChecking && mounted && _paymentId != null) {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted || !_isChecking) break;
      
      try {
        final res = await ds.dio.get(ApiEndpoints.bankTransferStatus(_paymentId!));
        if (res.statusCode == 200) {
          final isPaid = res.data['data']['isPaid'] == true;
          if (isPaid && mounted) {
            _isChecking = false;
            widget.onPaid();
          }
        }
      } catch (e) {
        debugPrint('Polling error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (ctx, scroll) {
        return Container(
          decoration: BoxDecoration(
            color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              // Header
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF059669), Color(0xFF34D399)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.qr_code_2_rounded, color: Colors.white, size: 36),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Payment via QR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                          if (_amount != null)
                            Text(
                              '${_amount!.toInt().toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.')} ₫',
                              style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  controller: scroll,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _loading
                      ? const Center(child: Padding(
                          padding: EdgeInsets.all(48),
                          child: CircularProgressIndicator(color: Color(0xFF059669)),
                        ))
                      : _error != null
                          ? _buildError()
                          : _buildQrContent(),
                ),
              ),
              if (!_loading && _error == null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        _isChecking = false;
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: widget.isDark ? Colors.grey.shade300 : Colors.grey.shade700)),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildError() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 32),
        Icon(Icons.error_outline_rounded, size: 56, color: Colors.red.shade400),
        const SizedBox(height: 16),
        Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: Colors.red.shade400, fontWeight: FontWeight.w600)),
        const SizedBox(height: 24),
        TextButton(
          onPressed: () { setState(() { _loading = true; _error = null; }); _initQr(); },
          child: const Text('Try Again'),
        ),
      ],
    );
  }

  Widget _buildQrContent() {
    return Column(
      children: [
        // QR Image
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8)),
            ],
          ),
          child: _qrUrl != null
              ? Image.network(
                  _qrUrl!,
                  width: 220, height: 220,
                  fit: BoxFit.contain,
                  loadingBuilder: (_, child, prog) => prog == null
                      ? child
                      : const SizedBox(width: 220, height: 220, child: Center(child: CircularProgressIndicator(color: Color(0xFF059669)))),
                  errorBuilder: (_, __, ___) => const SizedBox(
                    width: 220, height: 220,
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.qr_code_2_rounded, size: 80, color: Color(0xFF059669)),
                      SizedBox(height: 8),
                      Text('Use the transfer content below', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ]),
                  ),
                )
              : const SizedBox(width: 220, height: 220, child: Center(child: Icon(Icons.qr_code_2_rounded, size: 80, color: Color(0xFF059669)))),
        ),
        const SizedBox(height: 24),
        // Loading Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF059669))),
            const SizedBox(width: 12),
            Text('Awaiting payment...', style: TextStyle(fontWeight: FontWeight.w600, color: widget.isDark ? Colors.grey.shade300 : Colors.grey.shade700)),
          ],
        ),
        const SizedBox(height: 24),
        // Transfer content
        if (_transferContent != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF059669).withOpacity(widget.isDark ? 0.15 : 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF059669).withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(Icons.info_outline_rounded, color: const Color(0xFF059669), size: 15),
                  const SizedBox(width: 6),
                  const Text('Transfer Message (Required)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF059669))),
                ]),
                const SizedBox(height: 8),
                SelectableText(
                  _transferContent!,
                  style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w900,
                    color: widget.isDark ? Colors.white : const Color(0xFF0F172A),
                    letterSpacing: 2,
                  ),
                ),
                if (_bankInfo != null) ...[
                  const SizedBox(height: 6),
                  Text(_bankInfo!, style: TextStyle(fontSize: 12, color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
                ],
              ],
            ),
          ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF059669).withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_rounded, color: Color(0xFF059669), size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Enter the parking lot immediately after payment is successful.\nIf you overstay, extra fees will be applied upon exit.',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF059669), height: 1.5),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
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
        border: Border.all(color: isDark ? const Color(0xFF2A3A4A) : const Color(0xFFE8EDF2)),
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
                  ? const Color(0xFF2563eb)
                  : isCurrent
                      ? const Color(0xFF1e293b)
                      : (isDark ? const Color(0xFF2A3A4A) : const Color(0xFFE2E8F0)),
              boxShadow: isCurrent
                  ? [BoxShadow(color: const Color(0xFF1e293b).withOpacity(0.35), blurRadius: 12, spreadRadius: 1, offset: const Offset(0, 3))]
                  : isCompleted
                      ? [BoxShadow(color: const Color(0xFF2563eb).withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 2))]
                      : [],
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: isCompleted
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 16, key: ValueKey('check'))
                    : Icon(icon, color: isCurrent ? Colors.white : (isDark ? Colors.grey.shade600 : Colors.grey.shade400), size: isCurrent ? 18 : 14, key: const ValueKey('icon')),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isCurrent ? 13 : 12,
                fontWeight: isCurrent ? FontWeight.w800 : isCompleted ? FontWeight.w700 : FontWeight.w500,
                color: isCurrent
                    ? (isDark ? Colors.white : const Color(0xFF1e293b))
                    : isCompleted
                        ? const Color(0xFF2563eb)
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
        child: Stack(alignment: Alignment.center, children: [
          Container(height: 2, decoration: BoxDecoration(color: isDark ? const Color(0xFF2A3A4A) : const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(1))),
          LayoutBuilder(builder: (context, constraints) {
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
                  gradient: const LinearGradient(colors: [Color(0xFF2563eb), Color(0xFF1e293b)]),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            );
          }),
        ]),
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
                  side: BorderSide(color: isDark ? Colors.grey.shade600 : const Color(0xFFCBD5E1), width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Back', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: isDark ? Colors.grey.shade300 : const Color(0xFF475569))),
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
                  backgroundColor: const Color(0xFF1e293b),
                  disabledBackgroundColor: isDark ? const Color(0xFF2D3748) : const Color(0xFFE2E8F0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: canProceed ? 4 : 0,
                  shadowColor: const Color(0xFF1e293b).withOpacity(0.4),
                ),
                child: isConfirming
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                    : Text(
                        currentStep == 2 ? 'Confirm Booking' : 'Continue',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: canProceed ? Colors.white : (isDark ? Colors.grey.shade600 : Colors.grey.shade400),
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
