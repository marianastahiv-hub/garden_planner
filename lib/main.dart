import 'package:flutter/material.dart';
import 'screens/zones_screen.dart'; 
import 'screens/plants_screen.dart';
import 'screens/gallery_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/profile_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'data/auth_repository.dart';


Future<void> main() async {
  // Точка входу: створюємо кореневий віджет застосунку.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const GardenPlannerApp());
}

// Тут задаються тема програми й головний навігаційний контейнер.
class GardenPlannerApp extends StatelessWidget {
  const GardenPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SproutPlan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // Світлий фоновий колір 
        scaffoldBackgroundColor: const Color(0xFFF9F9F7),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D5A43), // Темно-зелений акцентний колір
          primary: const Color(0xFF2D5A43),
          secondary: const Color(0xFFE89A6C), // Оранжевий акцент
          surface: const Color(0xFFF9F9F7),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF9F9F7),
          elevation: 0
        ),
      ),
      home: const MainNavigationWrapper(),
    );
  }
}

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  // Індекс активної нижньої вкладки та тимчасові дані демо-профілю.
  int _currentIndex = 0;
  final _authRepository = AuthRepository();
  late final Stream<User?> _authChanges = _authRepository.authStateChanges;

  // Список усіх 6 екранів застосунку
  String? _selectedGalleryPlant;

// Повертає екран для кожної вкладки нижнього меню.
Widget _screenForIndex(int index, User user) {
  switch (index) {
    case 0:
      return DashboardScreen(
        userName: user.displayName ?? user.email?.split('@').first ?? 'Garden Keeper',
        onOpenZones: () => setState(() => _currentIndex = 1),
        onOpenPlants: () => setState(() => _currentIndex = 2),
        onOpenTasks: () => setState(() => _currentIndex = 3),
      );
    case 1:
      return const ZonesScreen();
    case 2:
      return PlantsScreen(
        onViewGallery: (plantName) {
          setState(() {
            _selectedGalleryPlant = plantName;
            _currentIndex = 4;
          });
        },
      );
    case 3:
      return const TasksScreen();
    case 4:
      return GalleryScreen(
        key: ValueKey(_selectedGalleryPlant),
        initialPlantName: _selectedGalleryPlant,
      );
    case 5:
      return ProfileScreen(
        name: user.displayName ?? user.email?.split('@').first ?? 'Garden Keeper',
        email: user.email ?? '',
        photoUrl: user.photoURL,
        onNameChanged: _authRepository.updateDisplayName,
        onPhotoChanged: _authRepository.updatePhotoUrl,
        onPasswordChanged: (currentPassword, newPassword) =>
            _authRepository.changePassword(
          currentPassword: currentPassword,
          newPassword: newPassword,
        ),
        onLogout: () => _authRepository.signOut(),
      );
    default: 
      return const SizedBox.shrink();
  }
}

  @override
  Widget build(BuildContext context) {
    // Firebase відновлює збережену сесію й повідомляє про вхід/вихід.
    return StreamBuilder<User?>(
      stream: _authChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final user = snapshot.data;
        if (user == null) return const AuthScreen();

        return Scaffold(
      body: IndexedStack(
        // IndexedStack зберігає стан вкладок, коли користувач переходить між ними.
        index: _currentIndex,
        children: List.generate(6, (index) => _screenForIndex(index, user)),
      ),
      
      bottomNavigationBar: NavigationBar(
        // Єдина нижня панель навігації для всіх основних екранів.
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFF2D5A43).withOpacity(0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Color(0xFF2D5A43)),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view, color: Color(0xFF2D5A43)),
            label: 'Zones',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_florist_outlined),
            selectedIcon: Icon(Icons.local_florist, color: Color(0xFF2D5A43)),
            label: 'Plants',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today, color: Color(0xFF2D5A43)),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.photo_library_outlined),
            selectedIcon: Icon(Icons.photo_library, color: Color(0xFF2D5A43)),
            label: 'Gallery',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: Color(0xFF2D5A43)),
            label: 'Profile',
          ),
        ],
      ),
        );
      },
    );
  }

}


