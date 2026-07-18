import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/models/incident_model.dart';

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
        
        String sinceStr = 'N/A';
        if (data['checkInTime'] != null) {
          final dt = DateTime.tryParse(data['checkInTime'])?.toLocal();
          if (dt != null) {
            sinceStr = DateFormat('hh:mm a').format(dt);
          }
        }

        _foundSystemRecord = {
          'type': typeStr,
          'zone': zoneStr,
          'slot': slotStr,
          'since': sinceStr,
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

  void _confirmPaymentAndRelease() {
    setState(() => _isSubmitting = true);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ticket processed and released successfully!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true); // return true to indicate success
    });
  }

  Widget _sectionTitle(String title, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF475569),
                letterSpacing: 1.0),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
          ]
        ],
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('2. SYSTEM MATCH INFORMATION'),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _foundSystemRecord != null ? const Color(0xFFF0FDF4) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _foundSystemRecord != null ? const Color(0xFFBBF7D0) : const Color(0xFFE2E8F0)),
          ),
          child: _foundSystemRecord == null
              ? const Center(
                  child: Text(
                    'Search a plate to load system record',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 18),
                        SizedBox(width: 8),
                        Text('Match Found', style: TextStyle(color: Color(0xFF16A34A), fontWeight: FontWeight.w700, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMatchItem('Vehicle Type', _foundSystemRecord!['type']!),
                        _buildMatchItem('Zone', _foundSystemRecord!['zone']!),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMatchItem('Slot', _foundSystemRecord!['slot']!),
                        _buildMatchItem('Parked Since', _foundSystemRecord!['since']!),
                      ],
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildMatchItem(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A), fontWeight: FontWeight.w600)),
        ],
      ),
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
                onPressed: () {},
                icon: const Icon(Icons.camera_alt_rounded, size: 18, color: Color(0xFF64748B)),
                label: const Text('Take Photo', style: TextStyle(color: Color(0xFF475569))),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.upload_file_rounded, size: 18, color: Color(0xFF64748B)),
                label: const Text('Upload Document', style: TextStyle(color: Color(0xFF475569))),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('4. PAYMENT INFORMATION'),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Parking Fee:', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                  Text('Automated on checkout', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(child: Text('Lost Ticket Fine (VND):', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500))),
                  SizedBox(
                    width: 120,
                    child: _buildTextField('e.g. 50000', _fineCtrl, keyboardType: TextInputType.number),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Payment Method:', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
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
                          color: _paymentMethod == 'CASH' ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'CASH',
                          style: TextStyle(
                            color: _paymentMethod == 'CASH' ? Colors.white : const Color(0xFF64748B),
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
                          color: _paymentMethod == 'QR TRANSFER' ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'QR TRANSFER',
                          style: TextStyle(
                            color: _paymentMethod == 'QR TRANSFER' ? Colors.white : const Color(0xFF64748B),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            const Text(
              'Process Lost Ticket',
              style: TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.w800),
            ),
            Text(
              'Ref: ${widget.incident.incidentCode ?? 'N/A'}',
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w500),
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
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('CANCEL', style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w800)),
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
