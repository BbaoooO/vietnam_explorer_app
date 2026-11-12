import 'package:android_project/core/app_nav.dart';
import 'package:android_project/features/home/home_discover_screen.dart';
import 'package:android_project/features/passport/passport_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/providers/planner_provider.dart';
import 'features/map/interactive_map_screen.dart';
import 'features/passport/data/sample_passport_data.dart';
import 'features/planner/planner_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/auth/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
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
        primaryColor: const Color(0xFF0F4C3A),
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFF0F4C3A)),
              ),
            );
          }
          if (snapshot.hasData) {
            return const MainNavigationScreen();
          }
          return const LoginScreen();
        },
      ),
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
    const ProfileScreen(),
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
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Discover'),
              BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
              BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Trip Planner'),
              BottomNavigationBarItem(icon: Icon(Icons.badge), label: 'Passport'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        );
      },
    );
  }
}