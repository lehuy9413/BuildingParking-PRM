import 'package:flutter/material.dart';
import '../controllers/staff_core_controller.dart';
import '../screens/simulated_camera_screen.dart';
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

  static const List<String> _gates = ['Gate A', 'Gate B', 'Gate C'];
  static const List<String> _vehicleTypes = ['Motorbike', 'Car', 'EV'];

  // Icon + màu theo loại xe
  IconData _vehicleIcon(String type) {
    return switch (type) {
      'Car' => Icons.directions_car_rounded,
      'EV' => Icons.electric_car_rounded,
      _ => Icons.two_wheeler_rounded,
    };
  }

  Color _vehicleColor(String type) {
    return switch (type) {
      'Car' => const Color(0xFF2563EB),
      'EV' => const Color(0xFF16A34A),
      _ => const Color(0xFF9333EA),
    };
  }

  Future<void> _scanPlate() async {
    // Hiện màn hình camera mô phỏng
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const SimulatedCameraScreen(
          title: 'Scan License Plate',
          subtitle: 'Detecting license plate...',
        ),
      ),
    );

    // Nếu trả về true (quét thành công), điền dữ liệu
    if (result == true && mounted) {
      setState(() {
        _plateController.text = widget.controller.getSamplePlate();
      });
    }
  }

  void _createSession() {
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
    final session = widget.controller.createSession(
      plateNumber: plate,
      vehicleType: _selectedVehicleType,
      entryGate: _selectedGate,
    );
    _plateController.clear();
    widget.onSessionCreated(session);
  }

  @override
  void dispose() {
    _plateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  child: Column(
                    children: const [
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
          Row(
            children: _vehicleTypes.map((type) {
              final selected = _selectedVehicleType == type;
              return Expanded(
                child: GestureDetector(
                  onTap: () =>
                      setState(() => _selectedVehicleType = type),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(
                        right: type != _vehicleTypes.last ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 12),
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
                          style: TextStyle(
                            fontSize: 11,
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
              onPressed: _createSession,
              icon: const Icon(Icons.add_circle_outline_rounded,
                  color: Colors.white),
              label: const Text(
                'CREATE PARKING SESSION',
                style: TextStyle(
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
