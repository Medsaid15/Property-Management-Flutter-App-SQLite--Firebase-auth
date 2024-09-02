import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:property_management/screens/payment_screen.dart';
import 'package:property_management/screens/profile_screen.dart';
import 'package:property_management/screens/property_screen.dart';
import 'package:property_management/screens/tenant_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  static final List<Widget> _screens = [
    const PropertyScreen(),
    const TenantScreen(),
     PaymentScreen(),
    const ProfileScreen(),
  ];

  onTap(int index) {
     setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF00796B),
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(10.0),
            topLeft: Radius.circular(10.0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
          child: GNav(
              backgroundColor: const Color(0xFF00796B),
              color: Colors.white,
              activeColor: Colors.white,
              tabBackgroundColor: const Color(0xFF00897B),
              gap: 10,
              padding: const EdgeInsets.all(16),
              tabs: const [
                GButton(
                  icon: Icons.real_estate_agent_outlined,
                  text: 'Properties',
                ),
                GButton(
                  icon: Icons.people_outline_outlined,
                  text: 'Tenants',
                ),
                GButton(
                  icon: Icons.payment,
                  text: 'Payment',
                ),
                GButton(
                  icon: Icons.account_circle_outlined,
                  text: 'Profile',
                ),
              ],
              selectedIndex: _currentIndex,
              onTabChange: (index) {
                setState(() {
                  _currentIndex = index;
                });
              }),
        ),
      ),
    );
  }
}
