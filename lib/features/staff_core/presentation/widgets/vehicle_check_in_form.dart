import 'package:flutter/material.dart';
import '../controllers/staff_core_controller.dart';
import '../screens/real_camera_screen.dart';
import '../../domain/models/parking_session.dart';

/// Form check-in xe: nhập biển số, chọn gate, chọn loại xe.
class VehicleCheckInForm extends StatefulWidget {
  const VehicleCheckInForm({
    super.key,
    required this.controller,
    required this.onSessionCreated,
  });

  final StaffCoreController controller;

  /// Callback khi tạo session thành công.
  final ValueChanged<ParkingSession> onSessionCreated;

  @override
  State<VehicleCheckInForm> createState() => _VehicleCheckInFormState();
}

class _VehicleCheckInFormState extends State<VehicleCheckInForm> {
  final _plateController = TextEditingController();
  String _selectedGate = 'Gate A';
  String _selectedVehicleType = 'Motorbike';
  bool _isSubmitting = false;
  String? _scannedImageBase64;

  static const List<String> _gates = ['Gate A', 'Gate B', 'Gate C'];
  static const List<String> _vehicleTypes = ['Motorbike', 'Car', 'EV'];

  // Icon + màu theo loại xe
  IconData _vehicleIcon(String name) {
    final n = name.toLowerCase();
    if (n.contains('car') || n.contains('ô tô')) return Icons.directions_car_rounded;
    if (n.contains('ev') || n.contains('electric')) return Icons.electric_car_rounded;
    return Icons.two_wheeler_rounded;
  }

  Color _vehicleColor(String name) {
    final n = name.toLowerCase();
    if (n.contains('car') || n.contains('ô tô')) return const Color(0xFF2563EB);
    if (n.contains('ev') || n.contains('electric')) return const Color(0xFF16A34A);
    return const Color(0xFF9333EA);
  }

  @override
  void dispose() {
    _plateController.dispose();
    super.dispose();
  }

  Future<void> _scanPlate() async {
    final base64Image = await Navigator.push<String?>(
      context,
      MaterialPageRoute(
        builder: (_) => const RealCameraScreen(),
      ),
    );
    
    if (base64Image != null && mounted) {
      _scannedImageBase64 = base64Image;
      // Hiện loading khi đang gọi LPR API
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recognizing license plate...')),
      );
      
      final plate = await widget.controller.recognizeLicensePlate(base64Image);
      
      if (mounted) {
        if (plate.isNotEmpty) {
          setState(() {
            _plateController.text = plate;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Recognized: $plate'), backgroundColor: Colors.green),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not recognize license plate. Please try again or type manually.'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _createSession() async {
    final plate = _plateController.text.trim();
    if (plate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter or scan the license plate!'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Lấy vehicle type được chọn
    final ctrl = widget.controller;
    final types = ctrl.vehicleTypes;

    // Nếu chưa load được types từ API, fallback sang check theo tên
    String vehicleTypeId = '';
    String vehicleTypeName = _selectedVehicleType;

    if (types.isNotEmpty) {
      // Tìm type khớp với lựa chọn hiện tại (theo tên gần đúng)
      final matched = types.firstWhere(
        (t) => t.name.toLowerCase().contains(_selectedVehicleType.toLowerCase()) ||
               _selectedVehicleType.toLowerCase().contains(t.code.toLowerCase()),
        orElse: () => types.first,
      );
      vehicleTypeId = matched.id;
      vehicleTypeName = matched.name;
    }

    if (vehicleTypeId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot determine vehicle type. Please try again.'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final session = await ctrl.createSessionApi(
        plateNumber: plate,
        vehicleTypeId: vehicleTypeId,
        vehicleTypeName: vehicleTypeName,
      );
      if (mounted) {
        if (_scannedImageBase64 != null) {
          await ctrl.uploadEvidence(session.id, _scannedImageBase64!);
          _scannedImageBase64 = null;
        }

        _plateController.clear();
        widget.onSessionCreated(session);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.controller;
    final vehicleTypes = ctrl.vehicleTypes;
    // Nếu API chưa trả về thì dùng list mặc định
    final displayTypes = vehicleTypes.isNotEmpty
        ? vehicleTypes.map((t) => t.name).toList()
        : _vehicleTypes;

    // Sync selected nếu chưa init
    if (vehicleTypes.isNotEmpty &&
        !displayTypes.contains(_selectedVehicleType)) {
      _selectedVehicleType = displayTypes.first;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Tiêu đề ─────────────────────────────────────────────────
          const Row(
            children: [
              Icon(Icons.login_rounded, color: Color(0xFF2563EB), size: 22),
              SizedBox(width: 10),
              Text(
                'VEHICLE CHECK-IN',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2563EB),
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ─── Ô nhập biển số ───────────────────────────────────────────
          const Text(
            'License Plate',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _plateController,
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    color: Color(0xFF0F172A),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ex: 51A-12345',
                    hintStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade400,
                      letterSpacing: 0.5,
                    ),
                    prefixIcon: const Icon(
                      Icons.credit_card_rounded,
                      color: Color(0xFF2563EB),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          BorderSide(color: Colors.grey.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                          color: Color(0xFF2563EB), width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Nút OCR Scan biển số
              GestureDetector(
                onTap: _scanPlate,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.document_scanner_rounded,
                          color: Color(0xFF2563EB), size: 24),
                      SizedBox(height: 4),
                      Text(
                        'SCAN',
                        style: TextStyle(
                          color: Color(0xFF2563EB),
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            '* Tap SCAN to scan license plate',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF94A3B8),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 20),

          // ─── Dropdown Gate ────────────────────────────────────────────
          const Text(
            'Entry Gate',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          _buildDropdown<String>(
            value: _selectedGate,
            items: _gates,
            icon: Icons.door_sliding_rounded,
            onChanged: (v) => setState(() => _selectedGate = v!),
            labelBuilder: (v) => v,
          ),
          const SizedBox(height: 20),

          // ─── Loại xe ─────────────────────────────────────────────────
          const Text(
            'Vehicle Type',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          ctrl.vehicleTypesLoading
              ? const Center(child: CircularProgressIndicator())
              : Row(
                  children: displayTypes.map((type) {
                    final selected = _selectedVehicleType == type;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _selectedVehicleType = type),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: EdgeInsets.only(
                              right: type != displayTypes.last ? 8 : 0),
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: selected
                                ? _vehicleColor(type).withOpacity(0.1)
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: selected
                                  ? _vehicleColor(type)
                                  : Colors.grey.shade200,
                              width: selected ? 1.5 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                _vehicleIcon(type),
                                color: selected
                                    ? _vehicleColor(type)
                                    : Colors.grey.shade500,
                                size: 24,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                type,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: selected
                                      ? _vehicleColor(type)
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
          const SizedBox(height: 24),

          // ─── Nút tạo session ──────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _createSession,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.add_circle_outline_rounded,
                      color: Colors.white),
              label: Text(
                _isSubmitting ? 'CREATING...' : 'CREATE PARKING SESSION',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    required IconData icon,
    required ValueChanged<T?> onChanged,
    required String Function(T) labelBuilder,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF2563EB)),
          items: items
              .map((item) => DropdownMenuItem<T>(
                    value: item,
                    child: Row(
                      children: [
                        Icon(icon,
                            size: 18, color: const Color(0xFF2563EB)),
                        const SizedBox(width: 10),
                        Text(
                          labelBuilder(item),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
