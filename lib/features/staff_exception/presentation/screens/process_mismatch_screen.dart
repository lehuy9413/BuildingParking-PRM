import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/models/incident_model.dart';
import 'package:dio/dio.dart';
import '../../../staff_core/presentation/widgets/web_camera_preview.dart';

class ProcessMismatchScreen extends StatefulWidget {
  final IncidentModel incident;

  const ProcessMismatchScreen({super.key, required this.incident});

  @override
  State<ProcessMismatchScreen> createState() => _ProcessMismatchScreenState();
}

class _ProcessMismatchScreenState extends State<ProcessMismatchScreen> {
  final _searchController = TextEditingController();
  final _actualPlateController = TextEditingController();
  String _selectedReason = 'AI misread license plate';

  bool _isSearching = false;
  bool _isResolving = false;
  Map<String, dynamic>? _foundSystemRecord;

  final List<String> _reasons = [
    'AI misread license plate',
    'Blurred or unreadable plate',
    'Customer swapped vehicle',
    'Other'
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _actualPlateController.dispose();
    super.dispose();
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false, bool isRed = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: isRed ? const Color(0xFFEF4444) : const Color(0xFF0F172A),
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Future<void> _searchRecord() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    
    setState(() {
      _isSearching = true;
      _foundSystemRecord = null;
    });

    try {
      final isSessionCode = query.toUpperCase().startsWith('PS-') || query.length > 10;
      final queryParams = isSessionCode ? {'sessionCode': query} : {'licensePlate': query};

      final res = await ApiClient.instance.dio.get(
        ApiEndpoints.findActiveSession,
        queryParameters: queryParams,
      );
      
      final data = res.data['data'];
      
      if (!mounted) return;
      setState(() {
        _isSearching = false;
        
        String entryTimeStr = 'N/A';
        final timeStr = data['entryTime'] ?? data['checkInTime'];
        if (timeStr != null) {
          final dt = DateTime.tryParse(timeStr.toString())?.toLocal();
          if (dt != null) {
            entryTimeStr = DateFormat('M/d/yyyy, hh:mm:ss a').format(dt);
          }
        }

        String? imageUrl;
        if (data['evidenceImages'] != null && (data['evidenceImages'] as List).isNotEmpty) {
           imageUrl = data['evidenceImages'][0]['url'];
        }

        final vehicleInfo = data['vehicleInfo'] as Map<String, dynamic>?;
        final plateStr = vehicleInfo?['licensePlate'] ?? data['licensePlate'] ?? 'N/A';

        _foundSystemRecord = {
          'id': data['_id'] ?? data['id'],
          'ticketId': data['sessionCode'] ?? 'N/A',
          'plate': plateStr,
          'entryTime': entryTimeStr,
          'imageUrl': imageUrl,
        };
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSearching = false;
        _foundSystemRecord = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not find record for: $query'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            const Text(
              'Process Mismatch',
              style: TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(
              'Ref: ${widget.incident.incidentCode ?? 'N/A'}',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('1. LOOKUP INFORMATION'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Color(0xFF0F172A)),
                    decoration: InputDecoration(
                      hintText: 'Enter Ticket ID or Plate',
                      hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _isSearching ? null : _searchRecord,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      elevation: 0,
                    ),
                    icon: _isSearching
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.search_rounded, size: 18),
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(_isSearching ? 'Searching' : 'Search', style: const TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            _buildSectionTitle('2. CURRENT INFO (INCORRECT)'),
            const SizedBox(height: 12),
            if (_foundSystemRecord == null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Center(
                  child: Text(
                    'Search to load system record',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  children: [
                    _buildInfoRow('Ticket ID:', _foundSystemRecord!['ticketId'] ?? 'N/A', isBold: true),
                    const Divider(height: 16, color: Color(0xFFF1F5F9)),
                    _buildInfoRow('AI Recognized Plate:', _foundSystemRecord!['plate'] ?? 'N/A', isBold: true, isRed: true),
                    const Divider(height: 16, color: Color(0xFFF1F5F9)),
                    _buildInfoRow('Entry Time:', _foundSystemRecord!['entryTime'] ?? 'N/A', isBold: true),
                  ],
                ),
              ),

            const SizedBox(height: 24),
            _buildSectionTitle('VISUAL COMPARISON'),
            const SizedBox(height: 12),
            const Text('Entry Camera Image (Overview)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF475569))),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(4),
              ),
              child: _foundSystemRecord != null && _foundSystemRecord!['imageUrl'] != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        _foundSystemRecord!['imageUrl'].toString().startsWith('http')
                            ? _foundSystemRecord!['imageUrl']
                            : ApiEndpoints.baseUrl.replaceAll('/api/v1', '') + _foundSystemRecord!['imageUrl'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Center(
                          child: Icon(Icons.broken_image, color: Color(0xFF94A3B8), size: 32),
                        ),
                      ),
                    )
                  : const Center(
                      child: Text('No Image', style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w700)),
                    ),
            ),

            const SizedBox(height: 16),
            const Text('Current Exit Camera Image', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF475569))),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: const WebCameraPreview(),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, color: Colors.white, size: 8),
                          SizedBox(width: 4),
                          Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 24),
            _buildSectionTitle('3. ADJUSTMENT INFO'),
            const SizedBox(height: 12),
            const Text('Actual Plate', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF475569))),
            const SizedBox(height: 8),
            TextField(
              controller: _actualPlateController,
              style: const TextStyle(color: Color(0xFF0F172A)),
              decoration: InputDecoration(
                hintText: 'e.g. 51F-123.45',
                hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
            ),

            const SizedBox(height: 16),
            const Text('Reason for edit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF475569))),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedReason,
                  isExpanded: true,
                  dropdownColor: Colors.white,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF94A3B8)),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w700,
                  ),
                  items: _reasons.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedReason = val);
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _isResolving ? null : _processMismatch,
                  icon: _isResolving
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.check_circle_outline_rounded, size: 18),
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _isResolving ? 'Processing...' : 'UPDATE & CALCULATE FEE',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    disabledBackgroundColor: const Color(0xFF2563EB).withOpacity(0.6),
                    disabledForegroundColor: Colors.white,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w900,
        color: Color(0xFF94A3B8),
        letterSpacing: 0.5,
      ),
    );
  }

  Future<void> _processMismatch() async {
    if (_foundSystemRecord == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please search for a parking session first.'), backgroundColor: Colors.red),
      );
      return;
    }

    final actualPlate = _actualPlateController.text.trim();
    if (actualPlate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the actual license plate.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isResolving = true);

    try {
      final sessionId = _foundSystemRecord!['id'];
      final dio = ApiClient.instance.dio;
      final newPlate = actualPlate.toUpperCase();

      // 1. Cập nhật biển số xe mới
      await dio.patch(
        '/parking-sessions/$sessionId/license-plate',
        data: { 'licensePlate': newPlate },
      );

      // 2. Thực hiện Check-out
      await dio.patch(
        ApiEndpoints.checkOut(sessionId),
      );

      // 3. Đóng sự cố
      final description = "LPR Mismatch Resolved.\nActual Plate: $newPlate\nReason: $_selectedReason";
      final formData = FormData.fromMap({
        'description': description,
        'extraCharge': 0,
      });
      
      await dio.patch(
        ApiEndpoints.incidentResolve(widget.incident.id),
        data: formData,
      );

      if (!mounted) return;
      
      // Reset form & state
      _searchController.clear();
      _actualPlateController.clear();
      _selectedReason = _reasons[0];
      
      setState(() {
        _foundSystemRecord = null;
        _isResolving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehicle information updated and released.'), backgroundColor: Colors.green),
      );
      
      Navigator.pop(context, true);

    } catch (e) {
      if (!mounted) return;
      setState(() => _isResolving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing mismatch: $e'), backgroundColor: Colors.red),
      );
    }
  }
}
