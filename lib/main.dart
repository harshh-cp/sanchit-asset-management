import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_colors.dart';
import 'data/repositories/asset_repository.dart';
import 'presentation/bloc/asset/asset_bloc.dart';
import 'presentation/bloc/assignment/assignment_bloc.dart';
import 'presentation/bloc/dashboard/dashboard_bloc.dart';
import 'presentation/bloc/history/history_bloc.dart';
import 'presentation/screens/asset_list_screen.dart';
import 'presentation/screens/assignments_screen.dart';
import 'presentation/screens/dashboard_screen.dart';
import 'presentation/screens/asset_history_screen.dart';
import 'presentation/screens/employees_screen.dart';
import 'presentation/screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final assetRepository = AssetRepository();

    return RepositoryProvider<AssetRepository>.value(
      value: assetRepository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AssetBloc>(
            create: (_) => AssetBloc(repository: assetRepository),
          ),
          BlocProvider<AssignmentBloc>(
            create: (_) => AssignmentBloc(repository: assetRepository),
          ),
          BlocProvider<DashboardBloc>(
            create: (_) => DashboardBloc(repository: assetRepository),
          ),
          BlocProvider<HistoryBloc>(
            create: (_) => HistoryBloc(repository: assetRepository),
          ),
        ],
        child: MaterialApp(
          title: 'Sanchit',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: AppColors.primary,
            scaffoldBackgroundColor: AppColors.background,
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            '/home': (context) => const RootNav(),
          },
        ),
      ),
    );
  }
}

class RootNav extends StatefulWidget {
  const RootNav({super.key});

  @override
  State<RootNav> createState() => _RootNavState();
}

class _RootNavState extends State<RootNav> {
  int _index = 0;

  final _screens = const [
    DashboardScreen(),
    AssetListScreen(),
    AssignmentsScreen(),
    EmployeesScreen(),
    AssetHistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Assets',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Assignments',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Employees',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            selectedIcon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }
}
