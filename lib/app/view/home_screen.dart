import 'package:flutter/material.dart';

import '../../features/auth_profile/presentation/screens/profile_screen.dart';
import '../../features/driver_booking/presentation/screens/driver_home_screen.dart';
import '../../features/driver_booking/presentation/screens/booking_flow_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  /// Switch to a specific tab from anywhere below this widget.
  static void switchTab(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<_HomeScreenState>();
    state?._onItemTapped(index);
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    DriverHomeScreen(),
    BookingFlowScreen(isEmbedded: true),
    Center(child: Text('Pay Page')),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'HOME',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: 'BOOKINGS',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.payment_outlined),
              activeIcon: Icon(Icons.payment),
              label: 'PAY',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'PROFILE',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFF0B7A59),
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 10),
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}