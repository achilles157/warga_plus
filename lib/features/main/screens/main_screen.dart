import 'package:flutter/material.dart';
import '../../home/presentation/home_page.dart';
import '../../profile/screens/profile_screen.dart';
import '../../profile/services/profile_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final ProfileService _profileService = ProfileService();

  final List<Widget> _pages = const [
    HomePage(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Daily Check-in Logic
    _profileService.checkIn();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          false, // Prevents keyboard from shrinking the view on mobile web
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_rounded),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.badge_rounded),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
