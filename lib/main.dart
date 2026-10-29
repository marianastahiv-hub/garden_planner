import 'package:flutter/material.dart';
import 'screens/zones_screen.dart'; 
import 'screens/plants_screen.dart';
import 'screens/gallery_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/profile_screen.dart';


void main() {
  // Точка входу: створюємо кореневий віджет застосунку.
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
  bool _isAuthenticated = false;
  String _profileName = 'Sarah Jenkins';
  String _profileEmail = 'sarah.j@gardenlover.com';
  String _profilePassword = '';

  // Список усіх 6 екранів застосунку
  String? _selectedGalleryPlant;

// Повертає екран для кожної вкладки нижнього меню.
Widget _screenForIndex(int index) {
  switch (index) {
    case 0:
      return DashboardScreen(
        userName: _profileName,
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
        name: _profileName,
        email: _profileEmail,
        password: _profilePassword,
        onNameChanged: (name) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted || _profileName == name) return;
            setState(() => _profileName = name);
          });
        },
        onPasswordChanged: (password) => setState(() => _profilePassword = password),
        onLogout: () => setState(() {
          _isAuthenticated = false;
          _currentIndex = 0;
        }),
      );
    default: 
      return const SizedBox.shrink();
  }
}

  @override
  Widget build(BuildContext context) {
    // До входу показуємо авторизацію; після входу — вкладки застосунку.
    if (!_isAuthenticated) {
      return AuthScreen(
        onAuthenticated: (account) => setState(() {
          _profileName = account.name;
          _profileEmail = account.email;
          _profilePassword = account.password;
          _isAuthenticated = true;
          _currentIndex = 0;
        }),
      );
    }
    return Scaffold(
      body: IndexedStack(
        // IndexedStack зберігає стан вкладок, коли користувач переходить між ними.
        index: _currentIndex,
        children: List.generate(6, _screenForIndex),
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
  }
}


