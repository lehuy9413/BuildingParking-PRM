import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class AuthProfileScreen extends StatefulWidget {
  const AuthProfileScreen({super.key});

  @override
  State<AuthProfileScreen> createState() => _AuthProfileScreenState();
}

class _AuthProfileScreenState extends State<AuthProfileScreen> {
  int _selectedPage = 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isWide = size.width >= 900;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.3,
            colors: [Color(0xFF20232A), Color(0xFF121418)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              const _BackgroundPattern(),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        _Header(
                          selectedPage: _selectedPage,
                          onPageChanged: (value) {
                            setState(() => _selectedPage = value);
                          },
                        ),
                        const SizedBox(height: 24),
                        Expanded(
                          child: isWide
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: _LoginCard()),
                                    SizedBox(width: 28),
                                    Expanded(child: _RegisterCard()),
                                    SizedBox(width: 28),
                                    Expanded(child: _ForgotPasswordCard()),
                                  ],
                                )
                              : AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  child: switch (_selectedPage) {
                                    0 => const _LoginCard(key: ValueKey('login')),
                                    1 => const _RegisterCard(key: ValueKey('register')),
                                    _ => const _ForgotPasswordCard(key: ValueKey('forgot')),
                                  },
                                ),
                        ),
                        if (!isWide) ...[
                          const SizedBox(height: 16),
                          _PagerDots(
                            selectedIndex: _selectedPage,
                            onTap: (index) {
                              setState(() => _selectedPage = index);
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    return Row(
      children: [
        Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFE7F6F0),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Center(
            child: Text(
              'P',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'ParkSmart',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
        const Spacer(),
        if (isWide)
          _PagePills(selectedPage: selectedPage, onPageChanged: onPageChanged),
      ],
    );
  }
}

class _PagePills extends StatelessWidget {
  const _PagePills({required this.selectedPage, required this.onPageChanged});

  final int selectedPage;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _NavPill(
          label: 'Login',
          isSelected: selectedPage == 0,
          onTap: () => onPageChanged(0),
        ),
        const SizedBox(width: 10),
        _NavPill(
          label: 'Register',
          isSelected: selectedPage == 1,
          onTap: () => onPageChanged(1),
        ),
        const SizedBox(width: 10),
        _NavPill(
          label: 'Forgot',
          isSelected: selectedPage == 2,
          onTap: () => onPageChanged(2),
        ),
      ],
    );
  }
}

class _NavPill extends StatelessWidget {
  const _NavPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.12),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primary : Colors.white70,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _PagerDots extends StatelessWidget {
  const _PagerDots({required this.selectedIndex, required this.onTap});

  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isSelected = index == selectedIndex;
        return GestureDetector(
          onTap: () => onTap(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.symmetric(horizontal: 6),
            width: isSelected ? 22 : 10,
            height: 10,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.secondary : Colors.white30,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        );
      }),
    );
  }
}

class _BackgroundPattern extends StatelessWidget {
  const _BackgroundPattern();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _DotPatternPainter(),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.06);
    const spacing = 16.0;
    const dotSize = 1.2;

    for (var y = 0.0; y < size.height; y += spacing) {
      for (var x = 0.0; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), dotSize, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child, this.highlight = false});

  final Widget child;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlight ? const Color(0xFF7F7CFF) : Colors.white,
          width: highlight ? 2.4 : 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55000000),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: child,
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.hintText,
    required this.icon,
    this.trailingIcon,
  });

  final String hintText;
  final IconData icon;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE6EAF0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 19, color: const Color(0xFF5B6777)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              hintText,
              style: const TextStyle(
                color: Color(0xFF90A0B2),
                fontSize: 13.5,
              ),
            ),
          ),
          if (trailingIcon != null)
            Icon(trailingIcon, size: 19, color: const Color(0xFF5B6777)),
        ],
      ),
    );
  }
}

class _ToggleChoice extends StatelessWidget {
  const _ToggleChoice({required this.label, required this.isSelected, this.icon});

  final String label;
  final bool isSelected;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 34,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x11000000),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 15, color: const Color(0xFF0B6E4F)),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  color: isSelected ? const Color(0xFF0B6E4F) : const Color(0xFF5F6B7A),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(9),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

class _FormGroup extends StatelessWidget {
  const _FormGroup({required this.label, required this.field});

  final String label;
  final Widget field;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        field,
      ],
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      highlight: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'P',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'ParkSmart',
                  style: TextStyle(
                    color: Color(0xFF0F4C5C),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const CircleAvatar(
              radius: 28,
              backgroundColor: Color(0xFFDFF3EA),
              child: Text(
                'P',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'ParkSmart',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Smart Parking, Seamless Living',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color: Color(0xFF566170),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F3F5),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                children: [
                  _ToggleChoice(label: 'Car', isSelected: true, icon: Icons.directions_car_outlined),
                  SizedBox(width: 4),
                  _ToggleChoice(label: 'Motorcycle', isSelected: false, icon: Icons.pedal_bike_outlined),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const _InputField(hintText: 'Email or Phone', icon: Icons.alternate_email),
            const SizedBox(height: 12),
            const _InputField(hintText: 'Password', icon: Icons.lock_outline, trailingIcon: Icons.visibility_outlined),
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Forgot Password?',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
            ),
            const SizedBox(height: 14),
            const _PrimaryButton(label: 'LOG IN', color: Color(0xFF0B7A59)),
            const SizedBox(height: 16),
            const Text(
              "Don't have an account?  Sign Up",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF596579),
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegisterCard extends StatelessWidget {
  const _RegisterCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                  color: const Color(0xFF1F2937),
                ),
                const Text(
                  'P ParkSmart',
                  style: TextStyle(
                    color: Color(0xFF0F4C5C),
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Create Account',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Join our eco-friendly community and find parking effortlessly.',
              style: TextStyle(
                fontSize: 13.5,
                height: 1.4,
                color: Color(0xFF52606D),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F3F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  _ToggleChoice(label: 'Car', isSelected: true),
                  SizedBox(width: 4),
                  _ToggleChoice(label: 'Motorcycle', isSelected: false),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const _FormGroup(label: 'Full Name', field: _InputField(hintText: 'Enter your full name', icon: Icons.person_outline)),
            const SizedBox(height: 12),
            const _FormGroup(label: 'Email Address', field: _InputField(hintText: 'name@example.com', icon: Icons.mail_outline)),
            const SizedBox(height: 12),
            const _FormGroup(label: 'Phone Number', field: _InputField(hintText: '+1 (555) 000-0000', icon: Icons.phone_outlined)),
            const SizedBox(height: 12),
            const _FormGroup(label: 'Password', field: _InputField(hintText: '••••••••', icon: Icons.lock_outline, trailingIcon: Icons.visibility_off_outlined)),
            const SizedBox(height: 12),
            const _FormGroup(label: 'Confirm Password', field: _InputField(hintText: '••••••••', icon: Icons.lock_reset_outlined)),
            const SizedBox(height: 18),
            const _PrimaryButton(label: 'SIGN UP', color: Color(0xFF0B7A59)),
            const SizedBox(height: 16),
            const Text(
              'Already have an account?  Log In',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF596579),
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ForgotPasswordCard extends StatelessWidget {
  const _ForgotPasswordCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: Text(
                'P ParkSmart',
                style: TextStyle(
                  color: Color(0xFF0F4C5C),
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 14),
            const CircleAvatar(
              radius: 28,
              backgroundColor: Color(0xFFD9F1DF),
              child: Icon(
                Icons.lock_reset,
                size: 30,
                color: Color(0xFF4A5C53),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Forgot Password',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Enter your email or phone number to receive a verification code.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.4,
                color: Color(0xFF52606D),
              ),
            ),
            const SizedBox(height: 18),
            const _FormGroup(
              label: 'Email or Phone Number',
              field: _InputField(hintText: 'e.g. name@email.com', icon: Icons.contact_mail_outlined),
            ),
            const SizedBox(height: 18),
            const _PrimaryButton(label: 'SEND VERIFICATION CODE', color: Color(0xFF10B981)),
            const SizedBox(height: 18),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.arrow_back, size: 16, color: AppColors.primary),
                SizedBox(width: 6),
                Text(
                  'Back to Login',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}