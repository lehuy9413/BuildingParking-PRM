import 'package:flutter/material.dart';
import '../../../../app/app.dart' as import_app;

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0B7A59)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Change Password',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: isDark ? Colors.amber : const Color(0xFF0F172A)),
            onPressed: () {
              import_app.SmartParkingApp.of(context).toggleTheme(isDark);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF0B7A59)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Secure your account',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your new password should be strong and unique to protect your smart parking profile.',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey.shade400 : const Color(0xFF64748B),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            _buildLabel('Current Password', isDark),
            _buildPasswordField(Icons.lock_outline, isDark),
            const SizedBox(height: 20),
            _buildLabel('New Password', isDark),
            _buildPasswordField(Icons.vpn_key_outlined, isDark),
            const SizedBox(height: 20),
            _buildLabel('Confirm New Password', isDark),
            _buildPasswordField(Icons.verified_user_outlined, isDark),
            const SizedBox(height: 24),
            _buildRequirementsBox(isDark),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B7A59),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'UPDATE PASSWORD',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: Icon(
                Icons.shield_outlined,
                size: 100,
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.grey.shade400 : const Color(0xFF475569),
        ),
      ),
    );
  }

  Widget _buildPasswordField(IconData icon, bool isDark) {
    return TextFormField(
      obscureText: true,
      obscuringCharacter: '•',
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        hintText: '••••••••',
        hintStyle: TextStyle(color: isDark ? Colors.grey.shade600 : Colors.grey.shade400, fontSize: 18),
        prefixIcon: Icon(icon, color: isDark ? Colors.grey.shade400 : Colors.grey.shade500),
        suffixIcon: Icon(Icons.visibility_outlined, color: isDark ? Colors.grey.shade400 : Colors.grey.shade500),
        filled: true,
        fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF0B7A59), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
      ),
    );
  }

  Widget _buildRequirementsBox(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF064E3B) : const Color(0xFFE8F5EE), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: Color(0xFF0B7A59), size: 18),
              const SizedBox(width: 8),
              Text(
                'Password Requirements',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildRequirementRow('Minimum 8 characters', isDark),
          const SizedBox(height: 6),
          _buildRequirementRow('At least one number', isDark),
          const SizedBox(height: 6),
          _buildRequirementRow('At least one uppercase letter', isDark),
        ],
      ),
    );
  }

  Widget _buildRequirementRow(String text, bool isDark) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: isDark ? Colors.grey.shade500 : Colors.grey.shade400, width: 1.5),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
