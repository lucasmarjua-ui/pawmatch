import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/dog_provider.dart';
import 'providers/match_provider.dart';
import 'services/auth_service.dart';
import 'services/dog_repository.dart';
import 'services/match_repository.dart';
import 'screens/onboarding_screen.dart';
import 'screens/create_profile_screen.dart';
import 'screens/discover_screen.dart';
import 'screens/matches_screen.dart';
import 'screens/dog_profile_screen.dart';
import 'screens/my_profile_screen.dart';
import 'theme/paw_colors.dart';
import 'widgets/nav_item.dart';
import 'widgets/paw_loading_indicator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(MockAuthService())),
        ChangeNotifierProvider(create: (_) => DogProvider(MockDogRepository())),
        ChangeNotifierProvider(create: (_) => MatchProvider(MockMatchRepository())),
      ],
      child: MaterialApp(
        title: 'PawMatch',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: PawColors.cream,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: PawColors.pine,
            primary: PawColors.pine,
          ),
        ),
        home: const AuthGate(),
      ),
    );
  }
}

// ── Puerta de autenticación ─────────────────────────────────────────
// Decide entre Onboarding y la app principal según AuthProvider. El día
// que conectemos Firebase Auth de verdad, solo cambia lo que hay dentro
// de MockAuthService — esta puerta no se entera del cambio.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user == null) return const OnboardingScreen();
    if (!user.hasCompletedProfile) return const CreateProfileScreen();
    return const MainShell();
  }
}

// ── Contenedor principal con navegación inferior ────────────────────
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int currentTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<DogProvider>().loadInitialData();
      context.read<MatchProvider>().loadConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final myDog = context.watch<DogProvider>().myDog;
    final location = context.watch<AuthProvider>().user?.location ?? '';

    final screens = [
      const DiscoverScreen(),
      MatchesScreen(onStartSwiping: () => setState(() => currentTab = 0)),
      if (myDog != null) DogProfileScreen(dog: myDog) else const _LoadingTab(),
      if (myDog != null)
        MyProfileScreen(
          dog: myDog,
          location: location,
          onSignOut: () {
            context.read<AuthProvider>().signOut();
            context.read<DogProvider>().reset();
            context.read<MatchProvider>().reset();
          },
        )
      else
        const _LoadingTab(),
    ];

    return Scaffold(
      body: IndexedStack(index: currentTab, children: screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: PawColors.cream,
          boxShadow: [BoxShadow(color: PawColors.charcoal.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, -4))],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 56,
            child: Row(
              children: [
                NavItem(icon: Icons.explore_outlined, label: 'Discover', selected: currentTab == 0, onTap: () => setState(() => currentTab = 0)),
                NavItem(icon: Icons.favorite_border, label: 'Matches', selected: currentTab == 1, onTap: () => setState(() => currentTab = 1)),
                NavItem(icon: Icons.pets_outlined, label: 'My dog', selected: currentTab == 2, onTap: () => setState(() => currentTab = 2)),
                NavItem(icon: Icons.person_outline, label: 'My profile', selected: currentTab == 3, onTap: () => setState(() => currentTab = 3)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingTab extends StatelessWidget {
  const _LoadingTab();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: PawColors.cream,
      body: Center(child: PawLoadingIndicator()),
    );
  }
}
