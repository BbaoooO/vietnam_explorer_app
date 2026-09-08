import 'package:flutter/material.dart';
import 'features/planner/planner_screen.dart';
import 'features/passport/passport_screen.dart';
import 'features/passport/data/sample_passport_data.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const VietNamExplorerApp());
}

class VietNamExplorerApp extends StatelessWidget {
  const VietNamExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vietnam Explorer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  // Danh sách các màn hình con
  final List<Widget> _screens = [
    const Center(child: Text('Home & Discover Screen')),
    const Center(child: Text('Interactive Map Screen')),
    const PlannerScreen(),
    PassportScreen(profile: sampleProfile),
    const Center(child: Text('Profile Screen')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF0F4C3A),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Trip Planner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.badge),
            label: 'Passport',
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