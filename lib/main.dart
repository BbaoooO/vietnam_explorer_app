import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/app_nav.dart';
import 'core/providers/travel_data.dart';
import 'core/repositories/travel_repository.dart';
import 'features/auth/login_screen.dart';
import 'features/home/home_discover_screen.dart';
import 'features/map/interactive_map_screen.dart';
import 'features/passport/passport_screen.dart';
import 'features/planner/planner_screen.dart';
import 'features/profile/profile_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(VietNamExplorerApp(repository: TravelRepository()));
}

class VietNamExplorerApp extends StatelessWidget {
  const VietNamExplorerApp({super.key, required this.repository});

  final TravelRepository repository;

  @override
  Widget build(BuildContext context) => MaterialApp(
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
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = snapshot.data;
        if (user == null) return const LoginScreen();
        return TravelSession(
          key: ValueKey(user.uid),
          repository: repository,
          uid: user.uid,
        );
      },
    ),
  );
}

class TravelSession extends StatefulWidget {
  const TravelSession({super.key, required this.repository, required this.uid});

  final TravelRepository repository;
  final String uid;

  @override
  State<TravelSession> createState() => _TravelSessionState();
}

class _TravelSessionState extends State<TravelSession> {
  late final _data = TravelData(widget.repository, widget.uid);
  final _navigation = AppNav();
  late Future<void> _loading = _data.load();

  @override
  void dispose() {
    _data.dispose();
    _navigation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<void>(
    future: _loading,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (snapshot.hasError) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Không mở được dữ liệu du lịch trên thiết bị.'),
                TextButton(
                  onPressed: () => setState(() => _loading = _data.load()),
                  child: const Text('Thử lại'),
                ),
                TextButton(
                  onPressed: () async => FirebaseAuth.instance.signOut(),
                  child: const Text('Đăng xuất'),
                ),
              ],
            ),
          ),
        );
      }
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<TravelData>.value(value: _data),
          Provider<AppNav>.value(value: _navigation),
        ],
        child: const MainNavigationScreen(),
      );
    },
  );
}

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  static const _screens = <Widget>[
    HomeDiscoverScreen(),
    InteractiveMapScreen(),
    PlannerScreen(),
    PassportScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final navigation = context.read<AppNav>();
    return ValueListenableBuilder<int>(
      valueListenable: navigation.tab,
      builder: (context, index, _) => Scaffold(
        body: IndexedStack(index: index, children: _screens),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: index,
          onTap: (i) => navigation.tab.value = i,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF0F4C3A),
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Discover'),
            BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month),
              label: 'Trip Planner',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.badge), label: 'Passport'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
