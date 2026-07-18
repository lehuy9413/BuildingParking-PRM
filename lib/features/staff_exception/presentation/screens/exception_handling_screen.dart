import 'package:flutter/material.dart';
import '../../domain/models/exception_models.dart';

/// Màn hình xử lý ngoại lệ:
/// - Mất thẻ xe (tìm kiếm theo biển số)
/// - Sai thông tin xe
class ExceptionHandlingScreen extends StatefulWidget {
  const ExceptionHandlingScreen({super.key});

  @override
  State<ExceptionHandlingScreen> createState() =>
      _ExceptionHandlingScreenState();
}

class _ExceptionHandlingScreenState extends State<ExceptionHandlingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Danh sách các yêu cầu đã xử lý trong ca
  final List<ExceptionRequest> _requests = [];

  // ─────────────────────────────────────────────────────────────────────────
  // Lost Card form state
  // ─────────────────────────────────────────────────────────────────────────
  final _plateSearchCtrl = TextEditingController();
  bool _isSearching = false;
  Map<String, String>? _foundVehicle; // mock result

  // ─────────────────────────────────────────────────────────────────────────
  // Wrong Info form state
  // ─────────────────────────────────────────────────────────────────────────
  final _wrongPlateCtrl = TextEditingController();
  String _selectedWrongType = 'Sai biển số';
  final _correctInfoCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  static const _wrongInfoTypes = [
    'Sai biển số',
    'Sai loại xe',
    'Sai khu vực',
    'Khác',
  ];

  // Mock dữ liệu bãi xe để tìm kiếm
  static const _mockDb = {
    '51A-12345': {
      'type': 'Car',
      'zone': 'Floor 2 - Zone C',
      'slot': 'C07',
      'since': '08:30',
    },
    '59B-67890': {
      'type': 'Motorbike',
      'zone': 'B1 - Zone M',
      'slot': 'M22',
      'since': '09:15',
    },
    '30E-99999': {
      'type': 'EV',
      'zone': 'Floor 1 - EV Zone',
      'slot': 'EV03',
      'since': '07:45',
    },
  };

  // ─────────────────────────────────────────────────────────────────────────
  // New UI state
  // ─────────────────────────────────────────────────────────────────────────
  String _selectedExceptionType2 = 'Lost Ticket';
  final _titleCtrl2 = TextEditingController(text: 'Lost Ticket');
  final _detailsCtrl2 = TextEditingController();

  static const _exceptionTypes2 = [
    'Lost Ticket',
    'LPR Mismatch',
    'Theft',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _plateSearchCtrl.dispose();
    _notesCtrl.dispose();
    _titleCtrl2.dispose();
    _detailsCtrl2.dispose();
    super.dispose();
  }

  void _searchVehicle() {
    final plate = _plateSearchCtrl.text.trim().toUpperCase();
    if (plate.isEmpty) return;
    setState(() {
      _isSearching = true;
      _foundVehicle = null;
    });

    // Simulate network delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        _isSearching = false;
        _foundVehicle = _mockDb[plate] ??
            {
              'type': '—',
              'zone': '—',
              'slot': '—',
              'since': '—',
              'notFound': 'true',
            };
      });
    });
  }

  void _submitLostCard() {
    if (_foundVehicle == null || _foundVehicle!['notFound'] != null) return;
    final plate = _plateSearchCtrl.text.trim().toUpperCase();
    final req = ExceptionRequest(
      id: 'EX-${DateTime.now().millisecondsSinceEpoch}',
      type: ExceptionType.lostCard,
      plateNumber: plate,
      createdAt: DateTime.now(),
    );
    setState(() {
      _requests.insert(0, req);
      _plateSearchCtrl.clear();
      _foundVehicle = null;
    });
    _showSuccessSnack('Lost card request recorded for $plate');
  }

  void _submitWrongInfo() {
    final plate = _wrongPlateCtrl.text.trim().toUpperCase();
    if (plate.isEmpty || _correctInfoCtrl.text.trim().isEmpty) {
      _showErrorSnack('Please fill in license plate and correct info.');
      return;
    }
    final req = ExceptionRequest(
      id: 'EX-${DateTime.now().millisecondsSinceEpoch}',
      type: ExceptionType.wrongVehicleInfo,
      plateNumber: plate,
      notes: '$_selectedWrongType: ${_correctInfoCtrl.text.trim()}',
      createdAt: DateTime.now(),
    );
    setState(() {
      _requests.insert(0, req);
      _wrongPlateCtrl.clear();
      _correctInfoCtrl.clear();
      _notesCtrl.clear();
    });
    _showSuccessSnack('Wrong info recorded for $plate');
  }

  void _showSuccessSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: const Color(0xFF16A34A),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  void _showErrorSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: const Color(0xFFEF4444),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('REPORT NEW EXCEPTION'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLostTicketForm(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLostTicketForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Exception Type'),
        const SizedBox(height: 8),
        _buildExceptionTypeDropdown2(),
        const SizedBox(height: 16),
        _fieldLabel('Title'),
        const SizedBox(height: 8),
        _styledTextField(controller: _titleCtrl2, hint: 'Lost Ticket', icon: null),
        const SizedBox(height: 16),
        _fieldLabel('Details / Plate Info'),
        const SizedBox(height: 8),
        _styledTextField(
            controller: _detailsCtrl2, hint: 'Provide details...', icon: null, maxLines: 4),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child: const Text('SUBMIT MANUAL OVERRIDE',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          ),
        ),
      ],
    );
  }

  Widget _buildExceptionTypeDropdown2() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedExceptionType2,
          isExpanded: true,
          dropdownColor: Colors.white,
          icon: const Icon(Icons.expand_more_rounded, color: Color(0xFF94A3B8)),
          style: const TextStyle(
              color: Color(0xFF0F172A), fontWeight: FontWeight.w600, fontSize: 14),
          items: _exceptionTypes2
              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
              .toList(),
          onChanged: (v) {
            setState(() {
              _selectedExceptionType2 = v!;
              _titleCtrl2.text = v;
            });
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF0F172A), size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Row(
        children: [
          Icon(Icons.report_problem_rounded, color: Color(0xFFEA580C), size: 24),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Exception Handling',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A)),
              ),
              Text(
                'Exception Handling',
                style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Badge hiện số yêu cầu đã xử lý trong ca
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFEA580C).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.history_rounded,
                        color: Color(0xFFEA580C), size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${_requests.length} this shift',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFEA580C)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Tab: Mất thẻ xe
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildLostCardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card
          _buildInfoBanner(
            icon: Icons.credit_card_off_rounded,
            iconColor: const Color(0xFFEA580C),
            iconBg: const Color(0xFFFFF7ED),
            title: 'Process Lost Card',
            subtitle: 'Search vehicle by plate, confirm & grant exit.',
          ),
          const SizedBox(height: 20),

          _sectionTitle('SEARCH BY LICENSE PLATE'),
          const SizedBox(height: 10),

          // Search bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _plateSearchCtrl,
                    textCapitalization: TextCapitalization.characters,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        letterSpacing: 1,
                        color: Color(0xFF0F172A)),
                    decoration: const InputDecoration(
                      hintText: 'Enter license plate... (Ex: 51A-12345)',
                      hintStyle:
                          TextStyle(color: Color(0xFFCBD5E1), fontSize: 14),
                      prefixIcon: Icon(Icons.search_rounded,
                          color: Color(0xFF94A3B8), size: 22),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    ),
                    onSubmitted: (_) => _searchVehicle(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ElevatedButton(
                    onPressed: _isSearching ? null : _searchVehicle,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 14),
                      elevation: 0,
                    ),
                    child: _isSearching
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('SEARCH',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 13)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
          const Text(
            'Try: 51A-12345 · 59B-67890 · 30E-99999',
            style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
          ),

          // Search result
          if (_foundVehicle != null) ...[
            const SizedBox(height: 20),
            _buildSearchResult(),
          ],

          // Lịch sử yêu cầu ca này
          if (_requests.where((r) => r.type == ExceptionType.lostCard).isNotEmpty) ...[
            const SizedBox(height: 28),
            _sectionTitle('RESOLVED IN SHIFT'),
            const SizedBox(height: 12),
            ..._requests
                .where((r) => r.type == ExceptionType.lostCard)
                .map((r) => _buildRequestTile(r)),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchResult() {
    final notFound = _foundVehicle!['notFound'] == 'true';
    if (notFound) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1F2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFECACA)),
        ),
        child: const Row(
          children: [
            Icon(Icons.search_off_rounded, color: Color(0xFFEF4444), size: 28),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'License plate not found',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFEF4444),
                        fontSize: 15),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'This plate is not currently parked.',
                    style:
                        TextStyle(color: Color(0xFF64748B), fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final plate = _plateSearchCtrl.text.trim().toUpperCase();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF2563EB).withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        children: [
          // Header xanh
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFF2563EB),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_rounded,
                    color: Colors.white, size: 20),
                const SizedBox(width: 10),
                const Text(
                  'Vehicle found in system',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('PARKED',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                // Biển số lớn
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      plate,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Thông tin chi tiết
                _infoRow(Icons.directions_car_rounded, 'Vehicle Type',
                    _foundVehicle!['type']!),
                const Divider(height: 18, thickness: 0.5),
                _infoRow(Icons.place_rounded, 'Zone', _foundVehicle!['zone']!),
                const Divider(height: 18, thickness: 0.5),
                _infoRow(Icons.grid_view_rounded, 'Slot', _foundVehicle!['slot']!),
                const Divider(height: 18, thickness: 0.5),
                _infoRow(Icons.access_time_rounded, 'Time In',
                    'Today ${_foundVehicle!['since']!}'),
                const SizedBox(height: 20),

                // Nút hành động
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() => _foundVehicle = null);
                          _plateSearchCtrl.clear();
                        },
                        icon: const Icon(Icons.close_rounded, size: 18),
                        label: const Text('Cancel'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF64748B),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _submitLostCard,
                        icon: const Icon(Icons.check_circle_rounded,
                            size: 18, color: Colors.white),
                        label: const Text(
                          'Grant Exit',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 14),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16A34A),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Tab: Sai thông tin xe
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildWrongInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoBanner(
            icon: Icons.edit_note_rounded,
            iconColor: const Color(0xFF7C3AED),
            iconBg: const Color(0xFFF5F3FF),
            title: 'Correct Vehicle Info',
            subtitle:
                'Adjust when vehicle info is recorded incorrectly.',
          ),
          const SizedBox(height: 20),

          _sectionTitle('EXCEPTION INFO'),
          const SizedBox(height: 12),

          // Form card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Biển số
                _fieldLabel('License Plate *'),
                const SizedBox(height: 8),
                _styledTextField(
                  controller: _wrongPlateCtrl,
                  hint: 'Ex: 51A-12345',
                  icon: Icons.confirmation_number_rounded,
                  textCap: TextCapitalization.characters,
                ),
                const SizedBox(height: 16),

                // Loại lỗi
                _fieldLabel('Error Type *'),
                const SizedBox(height: 8),
                _buildDropdown(),
                const SizedBox(height: 16),

                // Thông tin đúng
                _fieldLabel('Correct Info *'),
                const SizedBox(height: 8),
                _styledTextField(
                  controller: _correctInfoCtrl,
                  hint: 'Enter correct information...',
                  icon: Icons.check_circle_outline_rounded,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // Ghi chú
                _fieldLabel('Additional Notes (optional)'),
                const SizedBox(height: 8),
                _styledTextField(
                  controller: _notesCtrl,
                  hint: 'Describe the situation...',
                  icon: Icons.notes_rounded,
                  maxLines: 3,
                ),
                const SizedBox(height: 24),

                // Submit
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _submitWrongInfo,
                    icon: const Icon(Icons.send_rounded,
                        color: Colors.white, size: 18),
                    label: const Text(
                      'SUBMIT REPORT',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          letterSpacing: 0.5),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Lịch sử
          if (_requests
              .where((r) => r.type == ExceptionType.wrongVehicleInfo)
              .isNotEmpty) ...[
            const SizedBox(height: 28),
            _sectionTitle('RESOLVED IN SHIFT'),
            const SizedBox(height: 12),
            ..._requests
                .where((r) => r.type == ExceptionType.wrongVehicleInfo)
                .map((r) => _buildRequestTile(r)),
          ],
        ],
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedWrongType,
          isExpanded: true,
          icon: const Icon(Icons.expand_more_rounded, color: Color(0xFF64748B)),
          style: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w600,
              fontSize: 14),
          items: _wrongInfoTypes
              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
              .toList(),
          onChanged: (v) => setState(() => _selectedWrongType = v!),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Shared widgets
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildInfoBanner({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: iconBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconColor.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                    color: iconColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3))
              ],
            ),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: iconColor)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestTile(ExceptionRequest req) {
    final isLost = req.type == ExceptionType.lostCard;
    final color = isLost ? const Color(0xFFEA580C) : const Color(0xFF7C3AED);
    final bg = isLost ? const Color(0xFFFFF7ED) : const Color(0xFFF5F3FF);
    final icon = isLost
        ? Icons.credit_card_off_rounded
        : Icons.edit_note_rounded;

    final h = req.createdAt.hour.toString().padLeft(2, '0');
    final m = req.createdAt.minute.toString().padLeft(2, '0');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(req.plateNumber,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        letterSpacing: 1,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text(
                  '${req.typeLabel}${req.notes != null ? ' · ${req.notes}' : ''}',
                  style:
                      const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$h:$m',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF94A3B8))),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('DONE',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF16A34A))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Color(0xFF475569),
            letterSpacing: 1.5));
  }

  Widget _fieldLabel(String label) {
    return Text(label,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF334155)));
  }

  Widget _styledTextField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    int maxLines = 1,
    TextCapitalization textCap = TextCapitalization.none,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      textCapitalization: textCap,
      style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF0F172A)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(color: Color(0xFFCBD5E1), fontSize: 14),
        prefixIcon: (maxLines == 1 && icon != null)
            ? Icon(icon, color: const Color(0xFF94A3B8), size: 20)
            : null,
        filled: true,
        fillColor: const Color(0xFFF7F9FB),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: Color(0xFF2563EB), width: 1.5)),
        contentPadding:
            EdgeInsets.symmetric(horizontal: 16, vertical: maxLines > 1 ? 14 : 0),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 10),
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500)),
        const Spacer(),
        Text(value,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A))),
      ],
    );
  }
}
