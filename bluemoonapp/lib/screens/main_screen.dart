import 'package:flutter/material.dart';
import 'apartment_screen.dart';
import 'bill_screen.dart';
import 'user_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  static const routeName = '/main';

  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  final List<Widget> _pages = const [
    ApartmentScreen(),
    BillScreen(),
    UserScreen(),
    ProfileScreen(),
  ];

  void _onTap(int i) {
    setState(() {
      _index = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index], // 👈 đổi màn theo tab

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: _onTap,
        type: BottomNavigationBarType.fixed, // 👈 tránh lỗi 4 tab
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.apartment),
            label: 'Apartments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Bills',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}