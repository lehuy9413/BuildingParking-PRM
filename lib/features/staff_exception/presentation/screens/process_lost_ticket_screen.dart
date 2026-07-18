import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/models/incident_model.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import '../../../staff_core/presentation/screens/real_camera_screen.dart';
import 'package:image_picker/image_picker.dart';

class ProcessLostTicketScreen extends StatefulWidget {
  final IncidentModel incident;

  const ProcessLostTicketScreen({super.key, required this.incident});

  @override
  State<ProcessLostTicketScreen> createState() => _ProcessLostTicketScreenState();
}

class _ProcessLostTicketScreenState extends State<ProcessLostTicketScreen> {
  final _plateSearchCtrl = TextEditingController();
  final _nationalIdCtrl = TextEditingController();
  final _fullNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _fineCtrl = TextEditingController(text: '50000');

  bool _isSearching = false;
  Map<String, String>? _foundSystemRecord;
  String? _capturedImageBase64;
  String? _evidenceSource;
  String _paymentMethod = 'CASH';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _plateSearchCtrl.dispose();
    _nationalIdCtrl.dispose();
    _fullNameCtrl.dispose();
    _phoneCtrl.dispose();
    _fineCtrl.dispose();
    super.dispose();
  }

  Future<void> _searchPlate() async {
    final plate = _plateSearchCtrl.text.trim();
    if (plate.isEmpty) return;
    
    setState(() {
      _isSearching = true;
      _foundSystemRecord = null;
    });

    try {
      final res = await ApiClient.instance.dio.get(
        ApiEndpoints.findActiveSession,
        queryParameters: {'licensePlate': plate},
      );
      
      final data = res.data['data'];
      
      if (!mounted) return;
      setState(() {
        _isSearching = false;
        
        final typeObj = data['vehicleType'] ?? {};
        final lotObj = data['parkingLot'] ?? {};
        final typeStr = typeObj is Map ? typeObj['name']?.toString() ?? 'Unknown' : 'Unknown';
        final zoneStr = lotObj is Map ? lotObj['name']?.toString() ?? 'Unknown' : 'Unknown';
        final slotStr = data['slot']?.toString() ?? 'N/A';
        
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

        _foundSystemRecord = {
          'sessionId': data['_id']?.toString() ?? data['id']?.toString() ?? '',
          'ticketId': data['sessionCode'] ?? 'N/A',
          'type': typeStr,
          'zone': zoneStr,
          'slot': slotStr,
          'since': entryTimeStr,
          'imageUrl': imageUrl ?? '',
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
          content: Text('Could not find active session for plate: $plate'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _confirmPaymentAndRelease() async {
    if (_nationalIdCtrl.text.trim().isEmpty || 
        _fullNameCtrl.text.trim().isEmpty || 
        _phoneCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all mandatory fields in Exception Verification.'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_foundSystemRecord == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please search for a valid session first!'), backgroundColor: Colors.red),
      );
      return;
    }

    final sessionId = _foundSystemRecord!['sessionId']!;
    if (sessionId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid session ID'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    
    try {
      final dio = ApiClient.instance.dio;
      final fineAmount = double.tryParse(_fineCtrl.text.trim()) ?? 0;
      
      // 1. Resolve the incident
      dynamic requestData;
      if (_capturedImageBase64 != null) {
        final base64Str = _capturedImageBase64!.split(',').last;
        final bytes = base64Decode(base64Str);
        requestData = FormData.fromMap({
          'description': 'Lost ticket processed and fine paid.',
          'extraCharge': fineAmount,
          'image': MultipartFile.fromBytes(bytes, filename: 'evidence.jpg'),
        });
      } else {
        requestData = {
          'description': 'Lost ticket processed and fine paid.',
          'extraCharge': fineAmount,
        };
      }

      await dio.patch(
        ApiEndpoints.incidentResolve(widget.incident.id),
        data: requestData,
      );

      // 2. Check-out the session
      await dio.patch(
        ApiEndpoints.checkOut(sessionId),
      );

      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ticket processed and released successfully!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true); // return true to indicate success
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to process: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Widget _sectionTitle(String title, {String? subtitle}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.grey[400] : const Color(0xFF475569),
                letterSpacing: 1.0),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[500] : const Color(0xFF94A3B8))),
          ]
        ],
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, {TextInputType? keyboardType}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: isDark ? Colors.grey[600] : const Color(0xFF94A3B8), fontSize: 14),
        filled: true,
        fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        ),
      ),
    );
  }

  Widget _buildLookupSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('1. LOOKUP INFORMATION'),
        Row(
          children: [
            Expanded(
              child: _buildTextField('ENTER LICENSE PLATE', _plateSearchCtrl),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: _isSearching ? null : _searchPlate,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: _isSearching 
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.search_rounded, size: 18),
              label: const Text('Search', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMatchSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('2. SYSTEM MATCH INFORMATION'),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          ),
          child: _foundSystemRecord == null
              ? Center(
                  child: Text(
                    'Search a plate to load system record',
                    style: TextStyle(color: isDark ? Colors.grey[500] : const Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Entry Time:', _foundSystemRecord!['since'] ?? 'N/A', isBold: true),
                    Divider(height: 16, color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                    _buildInfoRow('Old Ticket ID:', _foundSystemRecord!['ticketId'] ?? 'N/A', isBold: true),
                    Divider(height: 16, color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                    _buildInfoRow('Vehicle Type:', _foundSystemRecord!['type'] ?? 'N/A', isBold: true),
                    const SizedBox(height: 16),
                    Text('Entry Images:', style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[400] : const Color(0xFF64748B), fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (_foundSystemRecord!['imageUrl'] != null && _foundSystemRecord!['imageUrl']!.isNotEmpty)
                          Container(
                            width: 80,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(
                                _foundSystemRecord!['imageUrl']!.toString().startsWith('http')
                                    ? _foundSystemRecord!['imageUrl']!
                                    : ApiEndpoints.baseUrl.replaceAll('/api/v1', '') + _foundSystemRecord!['imageUrl']!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Center(
                                  child: Icon(Icons.broken_image, color: Color(0xFF94A3B8), size: 24),
                                ),
                              ),
                            ),
                          )
                        else
                          Container(
                            width: 80,
                            height: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: const Center(
                              child: Text('No Image', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                            ),
                          ),
                        const SizedBox(width: 8),
                        Container(
                          width: 80,
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Center(
                            child: Text(
                              'LPR Close-up',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false, bool isRed = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[400] : const Color(0xFF64748B), fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: isRed ? const Color(0xFFEF4444) : (isDark ? Colors.white : const Color(0xFF0F172A)),
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }



  Widget _buildVerificationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('3. EXCEPTION VERIFICATION (MANDATORY)'),
        _buildTextField('Customer\'s National ID/Passport', _nationalIdCtrl),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildTextField('Full Name', _fullNameCtrl)),
            const SizedBox(width: 12),
            Expanded(child: _buildTextField('Phone Number', _phoneCtrl, keyboardType: TextInputType.phone)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RealCameraScreen()),
                  );
                  if (result != null && result is String) {
                    setState(() {
                      _capturedImageBase64 = result;
                      _evidenceSource = 'camera';
                    });
                  }
                },
                icon: Icon(
                  _evidenceSource == 'camera' ? Icons.check_circle_rounded : Icons.camera_alt_rounded,
                  size: 18,
                  color: _evidenceSource == 'camera' ? Colors.green : const Color(0xFF64748B),
                ),
                label: Text(
                  _evidenceSource == 'camera' ? 'Photo Taken' : 'Take Photo',
                  style: TextStyle(
                    color: _evidenceSource == 'camera' ? Colors.green : const Color(0xFF475569),
                    fontWeight: _evidenceSource == 'camera' ? FontWeight.w700 : FontWeight.normal,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: _evidenceSource == 'camera' ? Colors.green : const Color(0xFFE2E8F0)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final picker = ImagePicker();
                  final file = await picker.pickImage(source: ImageSource.gallery);
                  if (file != null && mounted) {
                    final bytes = await file.readAsBytes();
                    setState(() {
                      _capturedImageBase64 = 'data:image/jpeg;base64,${base64Encode(bytes)}';
                      _evidenceSource = 'gallery';
                    });
                  }
                },
                icon: Icon(
                  _evidenceSource == 'gallery' ? Icons.check_circle_rounded : Icons.upload_file_rounded,
                  size: 18,
                  color: _evidenceSource == 'gallery' ? Colors.green : const Color(0xFF64748B),
                ),
                label: Text(
                  _evidenceSource == 'gallery' ? 'Uploaded' : 'Upload Document',
                  style: TextStyle(
                    color: _evidenceSource == 'gallery' ? Colors.green : const Color(0xFF475569),
                    fontWeight: _evidenceSource == 'gallery' ? FontWeight.w700 : FontWeight.normal,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: _evidenceSource == 'gallery' ? Colors.green : const Color(0xFFE2E8F0)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('4. PAYMENT INFORMATION'),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Parking Fee:', style: TextStyle(color: isDark ? Colors.grey[400] : const Color(0xFF64748B), fontWeight: FontWeight.w500)),
                  Text('Automated on checkout', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: Text('Lost Ticket Fine (VND):', style: TextStyle(color: isDark ? Colors.grey[400] : const Color(0xFF64748B), fontWeight: FontWeight.w500))),
                  SizedBox(
                    width: 120,
                    child: _buildTextField('e.g. 50000', _fineCtrl, keyboardType: TextInputType.number),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Payment Method:', style: TextStyle(color: isDark ? Colors.grey[400] : const Color(0xFF64748B), fontWeight: FontWeight.w500)),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _paymentMethod = 'CASH'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _paymentMethod == 'CASH' ? (isDark ? const Color(0xFF334155) : const Color(0xFF1E293B)) : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'CASH',
                          style: TextStyle(
                            color: _paymentMethod == 'CASH' ? Colors.white : (isDark ? Colors.grey[400] : const Color(0xFF64748B)),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _paymentMethod = 'QR TRANSFER'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _paymentMethod == 'QR TRANSFER' ? (isDark ? const Color(0xFF334155) : const Color(0xFF1E293B)) : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'QR TRANSFER',
                          style: TextStyle(
                            color: _paymentMethod == 'QR TRANSFER' ? Colors.white : (isDark ? Colors.grey[400] : const Color(0xFF64748B)),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF7F9FB),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: isDark ? Colors.white : const Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              'Process Lost Ticket',
              style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.w800),
            ),
            Text(
              'Ref: ${widget.incident.incidentCode ?? 'N/A'}',
              style: TextStyle(color: isDark ? Colors.grey[400] : const Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildLookupSection(),
                    _buildMatchSection(),
                    _buildVerificationSection(),
                    _buildPaymentSection(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                border: Border(top: BorderSide(color: isDark ? const Color(0xFF334155) : Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text('CANCEL', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF475569), fontWeight: FontWeight.w800)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _confirmPaymentAndRelease,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _isSubmitting 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('CONFIRM PAYMENT & RELEASE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12), textAlign: TextAlign.center),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
