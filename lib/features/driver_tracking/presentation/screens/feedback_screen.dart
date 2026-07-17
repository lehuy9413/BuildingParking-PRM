import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/driver_tracking_controller.dart';

/// Màn hình Gửi Phản hồi/Khiếu nại – Báo mất thẻ, sai phí, slot bị chiếm.
class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({super.key});

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  int _selectedIssueIndex = -1;
  final _descController = TextEditingController();
  final _plateController = TextEditingController(text: '51A-123.45');
  final _titleController = TextEditingController();
  final List<String> _attachedImages = [];
  bool _isSubmitting = false;
  bool _submitted = false;
  String? _feedbackId;

  static const _issues = [
    _IssueType('Lost parking card', 'The parking card is lost or damaged',
        Icons.credit_card_off_rounded, Color(0xFFEF4444), 'issue_report'),
    _IssueType('Incorrect parking fee', 'The calculated fee is incorrect',
        Icons.money_off_rounded, Color(0xFFF59E0B), 'complaint'),
    _IssueType('Slot occupied',
        'The reserved slot is occupied by another vehicle',
        Icons.block_rounded, Color(0xFFEA580C), 'complaint'),
    _IssueType('Vehicle damaged',
        'Found scratches/damage on vehicle in the parking lot',
        Icons.car_crash_rounded, Color(0xFF8B5CF6), 'issue_report'),
    _IssueType('Other issues', 'Other issues that need support',
        Icons.help_outline_rounded, Color(0xFF0EA5E9), 'general'),
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _plateController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedIssueIndex < 0 || _descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Please select an issue type and provide a description'),
            backgroundColor: Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating),
      );
      return;
    }
    setState(() => _isSubmitting = true);

    final issue = _issues[_selectedIssueIndex];
    final title = _titleController.text.trim().isNotEmpty
        ? _titleController.text.trim()
        : issue.title;

    await ref.read(feedbackProvider.notifier).submit(
      title: title,
      content: _descController.text.trim(),
      rating: 3, // neutral default
      type: issue.apiType,
    );

    if (!mounted) return;
    final feedbackState = ref.read(feedbackProvider);

    setState(() => _isSubmitting = false);

    if (feedbackState.status == FeedbackSubmitStatus.success) {
      setState(() {
        _submitted = true;
        _feedbackId = feedbackState.feedbackId;
      });
    } else if (feedbackState.status == FeedbackSubmitStatus.failed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(feedbackState.error ?? 'Submit failed'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating),
      );
    }
  }

  void _simulateAttachImage() {
    if (_attachedImages.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 3 attached images allowed'), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    setState(() => _attachedImages.add('photo_${_attachedImages.length + 1}.jpg'));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : const Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Feedback & Report', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: isDark ? Colors.white : const Color(0xFF0F172A))),
        centerTitle: true,
      ),
      body: _submitted ? _buildSuccessView(isDark) : _buildFormView(isDark),
    );
  }

  Widget _buildFormView(bool isDark) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  width: double.infinity, padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark ? [const Color(0xFF7C2D12), const Color(0xFFEA580C)] : [const Color(0xFFFFF7ED), const Color(0xFFFED7AA)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isDark ? const Color(0xFFEA580C).withOpacity(0.4) : const Color(0xFFFB923C).withOpacity(0.3)),
                  ),
                  child: Row(children: [
                    Icon(Icons.feedback_rounded, color: isDark ? Colors.white : const Color(0xFFEA580C), size: 32),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Having an issue?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: isDark ? Colors.white : const Color(0xFF9A3412))),
                      const SizedBox(height: 4),
                      Text('Describe the issue so we can assist you as quickly as possible.', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isDark ? Colors.white70 : const Color(0xFF9A3412).withOpacity(0.7), height: 1.4)),
                    ])),
                  ]),
                ),
                const SizedBox(height: 24),

                // Issue Type
                _sectionTitle('ISSUE TYPE', isDark),
                const SizedBox(height: 12),
                ..._issues.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildIssueCard(e.value, e.key, isDark),
                )),
                const SizedBox(height: 20),

                // Title (optional)
                _sectionTitle('TITLE (optional)', isDark),
                const SizedBox(height: 12),
                _buildTextField(_titleController, 'Short title for your report',
                    Icons.title_rounded, isDark),
                const SizedBox(height: 20),

                // Plate
                _sectionTitle('LICENSE PLATE', isDark),
                const SizedBox(height: 12),
                _buildTextField(_plateController, 'Enter license plate', Icons.badge_rounded, isDark),
                const SizedBox(height: 20),

                // Description
                _sectionTitle('DETAILED DESCRIPTION', isDark),
                const SizedBox(height: 12),
                _buildDescField(isDark),
                const SizedBox(height: 20),

                // Attachments
                _sectionTitle('ATTACH IMAGES (optional)', isDark),
                const SizedBox(height: 12),
                _buildAttachmentSection(isDark),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        // Submit button
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A202C) : Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.06), blurRadius: 20, offset: const Offset(0, -8))],
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submit,
              icon: _isSubmitting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)) : const Icon(Icons.send_rounded),
              label: Text(_isSubmitting ? 'Submitting...' : 'Submit Feedback'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                backgroundColor: const Color(0xFFEA580C),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFEA580C).withOpacity(0.6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 6, shadowColor: const Color(0xFFEA580C).withOpacity(0.4),
                textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title, bool isDark) {
    return Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: isDark ? Colors.grey.shade400 : const Color(0xFF475569), letterSpacing: 1.5));
  }

  Widget _buildIssueCard(_IssueType issue, int index, bool isDark) {
    final isSelected = _selectedIssueIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIssueIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? issue.color.withOpacity(isDark ? 0.15 : 0.06) : (isDark ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isSelected ? issue.color : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)), width: isSelected ? 2 : 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.03), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: issue.color.withOpacity(isDark ? 0.2 : 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(issue.icon, color: issue.color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(issue.title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: isDark ? Colors.white : const Color(0xFF0F172A))),
            const SizedBox(height: 2),
            Text(issue.subtitle, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? Colors.grey.shade400 : Colors.grey.shade500)),
          ])),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 22, height: 22,
            decoration: BoxDecoration(shape: BoxShape.circle, color: isSelected ? issue.color : Colors.transparent,
              border: Border.all(color: isSelected ? issue.color : (isDark ? Colors.grey.shade600 : Colors.grey.shade300), width: 2)),
            child: isSelected ? const Icon(Icons.check_rounded, color: Colors.white, size: 14) : null,
          ),
        ]),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint, IconData icon, bool isDark) {
    return TextFormField(
      controller: ctrl,
      style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hint, hintStyle: TextStyle(color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
        prefixIcon: Icon(icon, color: isDark ? Colors.grey.shade500 : Colors.grey.shade500),
        filled: true, fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF7F9FB),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFEA580C), width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Widget _buildDescField(bool isDark) {
    return TextFormField(
      controller: _descController, maxLines: 5, maxLength: 500,
      style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A)),
      decoration: InputDecoration(
        hintText: 'Describe the issue in detail...', hintStyle: TextStyle(color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
        filled: true, fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF7F9FB),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFEA580C), width: 1.5)),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildAttachmentSection(bool isDark) {
    return Column(
      children: [
        if (_attachedImages.isNotEmpty)
          Wrap(
            spacing: 10, runSpacing: 10,
            children: _attachedImages.asMap().entries.map((e) => Stack(
              children: [
                Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.image_rounded, color: isDark ? Colors.grey.shade500 : Colors.grey.shade400, size: 28),
                    const SizedBox(height: 4),
                    Text(e.value, style: TextStyle(fontSize: 10, color: isDark ? Colors.grey.shade500 : Colors.grey.shade400, fontWeight: FontWeight.w600)),
                  ]),
                ),
                Positioned(top: -4, right: -4, child: GestureDetector(
                  onTap: () => setState(() => _attachedImages.removeAt(e.key)),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                    child: const Icon(Icons.close, color: Colors.white, size: 14),
                  ),
                )),
              ],
            )).toList(),
          ),
        if (_attachedImages.isNotEmpty) const SizedBox(height: 12),
        Row(children: [
          Expanded(child: OutlinedButton.icon(
            onPressed: _simulateAttachImage,
            icon: const Icon(Icons.camera_alt_rounded),
            label: const Text('Camera'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: isDark ? Colors.grey.shade600 : const Color(0xFFCBD5E1), width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              foregroundColor: isDark ? Colors.grey.shade300 : const Color(0xFF475569),
              textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
          )),
          const SizedBox(width: 12),
          Expanded(child: OutlinedButton.icon(
            onPressed: _simulateAttachImage,
            icon: const Icon(Icons.photo_library_rounded),
            label: const Text('Gallery'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: isDark ? Colors.grey.shade600 : const Color(0xFFCBD5E1), width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              foregroundColor: isDark ? Colors.grey.shade300 : const Color(0xFF475569),
              textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
          )),
        ]),
      ],
    );
  }

  Widget _buildSuccessView(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: isDark ? [const Color(0xFF065F46), const Color(0xFF047857)] : [const Color(0xFF10B981), const Color(0xFF059669)]),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [BoxShadow(color: const Color(0xFF059669).withOpacity(0.3), blurRadius: 32, offset: const Offset(0, 14))],
            ),
            child: const Column(children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 72),
              SizedBox(height: 20),
              Text('SUBMITTED SUCCESSFULLY', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 2)),
              SizedBox(height: 8),
              Text('We will respond within 24 hours.\nThank you for your feedback!', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500, height: 1.5)),
            ]),
          ),
          const SizedBox(height: 32),
          // Ticket info
          Container(
            width: double.infinity, padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.06), blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: Column(children: [
              _receiptRow(isDark, 'Report ID',
                  _feedbackId != null
                      ? '#${_feedbackId!.substring(_feedbackId!.length > 6 ? _feedbackId!.length - 6 : 0)}'
                      : 'FB-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}'),
              _receiptRow(isDark, 'Issue Type', _issues[_selectedIssueIndex].title),
              _receiptRow(isDark, 'License Plate', _plateController.text),
              _receiptRow(isDark, 'Attachments', '${_attachedImages.length} images'),
              _receiptRow(isDark, 'Status', 'Processing'),
            ]),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.home_rounded),
              label: const Text('Back to Home'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                backgroundColor: const Color(0xFF0F4C5C), foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _receiptRow(bool isDark, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.grey.shade400 : Colors.grey.shade500)),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF0F172A))),
      ]),
    );
  }
}

class _IssueType {
  final String title, subtitle;
  final IconData icon;
  final Color color;
  final String apiType;
  const _IssueType(this.title, this.subtitle, this.icon, this.color, this.apiType);
}
