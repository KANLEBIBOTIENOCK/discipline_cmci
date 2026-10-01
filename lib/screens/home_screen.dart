import 'package:flutter/material.dart';
import '../providers/discipline_state.dart';
import '../theme/app_theme.dart';
import 'books_and_souls_screen.dart';
import 'monthly_grid_screen.dart';
import 'profile_screen.dart';
import 'today_screen.dart';

class HomeScreen extends StatefulWidget {
  final DisciplineState state;

  const HomeScreen({super.key, required this.state});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      TodayScreen(state: widget.state),
      MonthlyGridScreen(state: widget.state),
      BooksAndSoulsScreen(state: widget.state),
      ProfileScreen(state: widget.state),
    ];

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: screens[_currentIndex],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryRose.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            child: NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() => _currentIndex = index);
              },
              backgroundColor: Colors.white,
              indicatorColor: AppTheme.primaryRoseLight,
              elevation: 0,
              height: 64,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.spa_outlined, color: AppTheme.textMuted),
                  selectedIcon:
                      Icon(Icons.spa_rounded, color: AppTheme.primaryRose),
                  label: 'Aujourd’hui',
                ),
                NavigationDestination(
                  icon: Icon(Icons.table_chart_outlined, color: AppTheme.textMuted),
                  selectedIcon:
                      Icon(Icons.table_chart_rounded, color: AppTheme.primaryRose),
                  label: 'Fiche',
                ),
                NavigationDestination(
                  icon: Icon(Icons.menu_book_outlined, color: AppTheme.textMuted),
                  selectedIcon:
                      Icon(Icons.menu_book_rounded, color: AppTheme.primaryRose),
                  label: 'Bilan',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded, color: AppTheme.textMuted),
                  selectedIcon:
                      Icon(Icons.person_rounded, color: AppTheme.primaryRose),
                  label: 'Profil',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
