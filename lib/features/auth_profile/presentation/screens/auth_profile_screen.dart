import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class AuthProfileScreen extends StatefulWidget {
  const AuthProfileScreen({super.key});

  @override
  State<AuthProfileScreen> createState() => _AuthProfileScreenState();
}

class _AuthProfileScreenState extends State<AuthProfileScreen> {
  int _selectedPage = 0; // 0: Login, 1: Register, 2: Forgot

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              children: [
                if (_selectedPage != 2)
                  _Header(
                    selectedPage: _selectedPage,
                    onPageChanged: (value) => setState(() => _selectedPage = value),
                  ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: switch (_selectedPage) {
                      0 => _LoginCard(
                          key: const ValueKey('login'),
                          onNavigateToRegister: () => setState(() => _selectedPage = 1),
                          onNavigateToForgot: () => setState(() => _selectedPage = 2),
                        ),
                      1 => _RegisterCard(
                          key: const ValueKey('register'),
                          onNavigateToLogin: () => setState(() => _selectedPage = 0),
                        ),
                      _ => _ForgotPasswordCard(
                          key: const ValueKey('forgot'),
                          onNavigateToLogin: () => setState(() => _selectedPage = 0),
                        ),
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.selectedPage, required this.onPageChanged});
  final int selectedPage;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _TabButton(
            title: 'Login',
            isSelected: selectedPage == 0,
            onTap: () => onPageChanged(0),
          ),
          const SizedBox(width: 32),
          _TabButton(
            title: 'Sign Up',
            isSelected: selectedPage == 1,
            onTap: () => onPageChanged(1),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({required this.title, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? AppColors.primary : Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 3,
              width: isSelected ? 24 : 0,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom TextField
class _InputField extends StatelessWidget {
  const _InputField({
    required this.hintText,
    required this.icon,
    this.trailingIcon,
    this.obscureText = false,
  });

  final String hintText;
  final IconData icon;
  final IconData? trailingIcon;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
        prefixIcon: Icon(icon, color: Colors.grey.shade500),
        suffixIcon: trailingIcon != null ? Icon(trailingIcon, color: Colors.grey.shade500) : null,
        filled: true,
        fillColor: const Color(0xFFF7F9FB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onPressed, this.color});

  final String label;
  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? AppColors.primary,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _ToggleChoice extends StatelessWidget {
  const _ToggleChoice({required this.label, required this.isSelected, required this.onTap, this.icon});

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withOpacity(0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: isSelected ? AppColors.primary : Colors.grey.shade600),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.primary : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  final VoidCallback onNavigateToRegister;
  final VoidCallback onNavigateToForgot;

  const _LoginCard({super.key, required this.onNavigateToRegister, required this.onNavigateToForgot});
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          const CircleAvatar(
            radius: 42,
            backgroundColor: Color(0xFFDFF3EA),
            child: Text(
              'P',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 42,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Welcome Back',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Smart Parking, Seamless Living',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 32),
          const _InputField(hintText: 'Email or Phone', icon: Icons.alternate_email),
          const SizedBox(height: 16),
          const _InputField(
            hintText: 'Password',
            icon: Icons.lock_outline,
            trailingIcon: Icons.visibility_outlined,
            obscureText: true,
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onNavigateToForgot,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Forgot Password?',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _PrimaryButton(
            label: 'LOG IN',
            onPressed: () {
              // TODO: Handle Login
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _RegisterCard extends StatefulWidget {
  final VoidCallback onNavigateToLogin;

  const _RegisterCard({super.key, required this.onNavigateToLogin});

  @override
  State<_RegisterCard> createState() => _RegisterCardState();
}

class _RegisterCardState extends State<_RegisterCard> {
  bool isCarSelected = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Create Account',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Join our eco-friendly community and find parking effortlessly.',
            style: TextStyle(
              fontSize: 15,
              height: 1.4,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _ToggleChoice(
                label: 'Car',
                isSelected: isCarSelected,
                icon: Icons.directions_car_outlined,
                onTap: () => setState(() => isCarSelected = true),
              ),
              const SizedBox(width: 12),
              _ToggleChoice(
                label: 'Motorcycle',
                isSelected: !isCarSelected,
                icon: Icons.pedal_bike_outlined,
                onTap: () => setState(() => isCarSelected = false),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const _InputField(hintText: 'Full Name', icon: Icons.person_outline),
          const SizedBox(height: 16),
          const _InputField(hintText: 'Email Address', icon: Icons.mail_outline),
          const SizedBox(height: 16),
          const _InputField(hintText: 'Phone Number', icon: Icons.phone_outlined),
          const SizedBox(height: 16),
          const _InputField(hintText: 'Password', icon: Icons.lock_outline, obscureText: true),
          const SizedBox(height: 32),
          _PrimaryButton(
            label: 'SIGN UP',
            onPressed: () {
              // TODO: Handle Register
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ForgotPasswordCard extends StatelessWidget {
  final VoidCallback onNavigateToLogin;

  const _ForgotPasswordCard({super.key, required this.onNavigateToLogin});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          const CircleAvatar(
            radius: 46,
            backgroundColor: Color(0xFFDFF3EA),
            child: Icon(Icons.lock_reset_rounded, size: 46, color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          const Text(
            'Forgot Password',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter your email or phone number to receive a verification code.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.4,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 32),
          const _InputField(hintText: 'e.g. name@email.com', icon: Icons.contact_mail_outlined),
          const SizedBox(height: 32),
          _PrimaryButton(
            label: 'SEND CODE',
            onPressed: () {
              // TODO: Send code
            },
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: onNavigateToLogin,
            icon: const Icon(Icons.arrow_back, color: AppColors.primary),
            label: const Text(
              'Back to Login',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}