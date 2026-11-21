import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'screens/zones_screen.dart';
import 'screens/plants_screen.dart';
import 'screens/gallery_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/profile_screen.dart';

import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'data/auth_repository.dart';
import 'data/firebase_auth_repository.dart';
import 'data/firebase_telemetry_repository.dart';
import 'data/garden_repository.dart';
import 'data/in_memory_auth_repository.dart';
import 'data/shared_preferences_garden_repository.dart';
import 'data/telemetry_repository.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/auth/bloc/auth_state.dart';
import 'features/garden/bloc/garden_bloc.dart';
import 'features/garden/bloc/garden_event.dart';

// Change this composition choice to run with in-memory auth/telemetry
// adapters while leaving screens and Blocs untouched.
const useFirebaseServices = true;

Future<void> main() async {
  // Точка входу: створюємо кореневий віджет застосунку.
  WidgetsFlutterBinding.ensureInitialized();
  if (useFirebaseServices) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  final telemetry = useFirebaseServices
      ? FirebaseTelemetryRepository()
      : const NoopTelemetryRepository();
  // Crashlytics підтримується мобільними платформами. Під'єднуємо
  // обробники для помилок Flutter та неперехоплених async-помилок.
  final supportsCrashlytics =
      useFirebaseServices &&
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);
  if (supportsCrashlytics) {
    FlutterError.onError = telemetry.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      telemetry.recordError(error, stack, fatal: true);
      return true;
    };
  }
  runApp(
    RepositoryProvider<TelemetryRepository>.value(
      value: telemetry,
      child: RepositoryProvider<AuthRepository>(
        create: (_) => useFirebaseServices
            ? FirebaseAuthRepository()
            : InMemoryAuthRepository(),
        child: RepositoryProvider<GardenRepository>(
          create: (_) => SharedPreferencesGardenRepository(),
          child: MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => AuthBloc(
                  context.read<AuthRepository>(),
                  context.read<TelemetryRepository>(),
                ),
              ),
              BlocProvider(
                create: (context) {
                  final bloc = GardenBloc(context.read<GardenRepository>());
                  final userId = context.read<AuthRepository>().currentUser?.id;
                  if (userId != null) {
                    bloc.add(GardenLoadRequested(userId));
                  }
                  return bloc;
                },
              ),
            ],
            child: const GardenPlannerApp(),
          ),
        ),
      ),
    ),
  );
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
          elevation: 0,
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

  // Список усіх 6 екранів застосунку
  String? _selectedGalleryPlant;

  // Повертає екран для кожної вкладки нижнього меню.
  Widget _screenForIndex(int index, AuthUser user, BuildContext context) {
    switch (index) {
      case 0:
        return DashboardScreen(
          userName: user.displayName ?? user.email.split('@').first,
          onOpenZones: () => _selectTab(1),
          onOpenPlants: () => _selectTab(2),
          onOpenTasks: () => _selectTab(3),
        );
      case 1:
        return const ZonesScreen();
      case 2:
        return PlantsScreen(
          onViewGallery: (plantName) {
            _selectedGalleryPlant = plantName;
            _selectTab(4);
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
          name: user.displayName ?? user.email.split('@').first,
          email: user.email,
          photoUrl: user.photoUrl,
          onNameChanged: (name) =>
              context.read<AuthBloc>().add(AuthDisplayNameChanged(name)),
          onPhotoChanged: (photoUrl) =>
              context.read<AuthBloc>().add(AuthPhotoChanged(photoUrl)),
          onPasswordChanged: (currentPassword, newPassword) =>
              context.read<AuthBloc>().add(
                AuthPasswordChanged(
                  currentPassword: currentPassword,
                  newPassword: newPassword,
                ),
              ),
          onLogout: () =>
              context.read<AuthBloc>().add(const AuthSignOutRequested()),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _selectTab(int index) {
    setState(() => _currentIndex = index);
    const screenNames = [
      'Home',
      'Zones',
      'Plants',
      'Tasks',
      'Gallery',
      'Profile',
    ];
    context
        .read<TelemetryRepository>()
        .logScreenView(
          screenName: screenNames[index],
          screenClass: 'MainNavigation',
        )
        .catchError((Object error) {
          debugPrint('Firebase Analytics screen event failed: $error');
        });
  }

  @override
  Widget build(BuildContext context) {
    // Firebase відновлює збережену сесію й повідомляє про вхід/вихід.
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          current.user != null && previous.user?.id != current.user?.id,
      listener: (context, state) {
        context.read<GardenBloc>().add(GardenLoadRequested(state.user!.id));
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState.status == AuthStatus.checking) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final user = authState.user;
          if (user == null) return const AuthScreen();

          return Scaffold(
            body: IndexedStack(
              // IndexedStack зберігає стан вкладок, коли користувач переходить між ними.
              index: _currentIndex,
              children: List.generate(
                6,
                (index) => _screenForIndex(index, user, context),
              ),
            ),

            bottomNavigationBar: NavigationBar(
              // Єдина нижня панель навігації для всіх основних екранів.
              selectedIndex: _currentIndex,
              onDestinationSelected: (int index) {
                _selectTab(index);
              },
              backgroundColor: Colors.white,
              indicatorColor: const Color(0xFF2D5A43).withValues(alpha: 0.15),
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
                  selectedIcon: Icon(
                    Icons.local_florist,
                    color: Color(0xFF2D5A43),
                  ),
                  label: 'Plants',
                ),
                NavigationDestination(
                  icon: Icon(Icons.calendar_today_outlined),
                  selectedIcon: Icon(
                    Icons.calendar_today,
                    color: Color(0xFF2D5A43),
                  ),
                  label: 'Tasks',
                ),
                NavigationDestination(
                  icon: Icon(Icons.photo_library_outlined),
                  selectedIcon: Icon(
                    Icons.photo_library,
                    color: Color(0xFF2D5A43),
                  ),
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
      ),
    );
  }
}
