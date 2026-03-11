import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const HistoryScreen(),
    const ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF0079C1),
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: Colors.white,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home'),
              _buildNavItem(1, Icons.history_outlined, Icons.history, 'History'),
              const SizedBox(width: 40), // Space for floating button
              _buildNavItem(2, Icons.notifications_none, Icons.notifications, 'Inbox'),
              _buildNavItem(3, Icons.person_outline, Icons.person, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData outlineIcon, IconData filledIcon, String label) {
    int? mappedPageIndex;
    if (index == 0) {
      mappedPageIndex = 0;
    } else if (index == 1) {
      mappedPageIndex = 1;
    } else if (index == 3) {
      mappedPageIndex = 2;
    }

    bool isActive = mappedPageIndex != null && _currentIndex == mappedPageIndex;

    return InkWell(
      onTap: () {
        if (mappedPageIndex != null) {
          _onTabTapped(mappedPageIndex);
        } else if (index == 2) {
          // Dummy for Inbox
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fitur Inbox akan segera hadir!')),
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? filledIcon : outlineIcon,
            color: isActive ? const Color(0xFF0079C1) : Colors.grey,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isActive ? const Color(0xFF0079C1) : Colors.grey,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
