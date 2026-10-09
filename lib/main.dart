import 'package:android_project/features/home/home_discover_screen.dart';
import 'package:android_project/features/passport/passport_screen.dart';
import 'package:flutter/material.dart';
import 'features/planner/planner_screen.dart';
import 'features/passport/data/sample_passport_data.dart';
import 'features/map/interactive_map_screen.dart';
import 'package:provider/provider.dart';
import 'core/providers/planner_provider.dart';
import 'package:android_project/core/app_nav.dart';

void main() {
  runApp(
    // Bọc ứng dụng bằng MultiProvider để sau này dễ thêm các Provider khác (như PassportProvider)
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => PlannerProvider()),
      ],
      child: const VietNamExplorerApp(),
    ),
  );
}

class VietNamExplorerApp extends StatelessWidget {
  const VietNamExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vietnam Explorer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF0F4C3A),// màu xanh ngọc lục bảo
        scaffoldBackgroundColor: const Color(0xFFF7F8FA)
      ),
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
  final List<Widget> _screens = [
    const HomeDiscoverScreen(),
    const InteractiveMapScreen(),
    const PlannerScreen(),
    PassportScreen(profile: sampleProfile),
    const Center(child: Text('Profile Screen')),
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: AppNav.tab,
      builder: (context, index, _) {
        return Scaffold(
          body: IndexedStack(index: index, children: _screens),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: index,
            onTap: (i) => AppNav.tab.value = i,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFF0F4C3A),
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home), label: 'Discover'),
              BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_month), label: 'Trip Planner'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.badge), label: 'Passport'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        );
      },
    );
  }
}