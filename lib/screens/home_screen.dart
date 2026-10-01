import 'package:flutter/material.dart';
import '../providers/discipline_state.dart';
import '../theme/app_theme.dart';
import 'books_and_souls_screen.dart';
import 'export_pdf_screen.dart';
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 768;

        if (isDesktop) {
          // ---- VUE DESKTOP PREMIUM AVEC SIDEBAR FLORALE ÉLÉGANTE ----
          return Scaffold(
            body: Row(
              children: [
                // Sidebar latérale gauche
                Container(
                  width: 260,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: const Border(
                      right: BorderSide(color: AppTheme.dividerColor, width: 1.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryRose.withOpacity(0.04),
                        blurRadius: 20,
                        offset: const Offset(4, 0),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header Sidebar avec Logo et Titre "Aline"
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryRoseLight.withOpacity(0.7),
                              Colors.white,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: AppTheme.rosePetalGradient,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: AppTheme.roseGlowShadow,
                              ),
                              child: const Icon(Icons.spa_rounded, color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Aline 🌸',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryRoseDark,
                                    ),
                                  ),
                                  const Text(
                                    'Disciplines CMCI',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: AppTheme.dividerColor),
                      const SizedBox(height: 16),

                      // Liste des onglets de navigation
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          children: [
                            _buildSidebarItem(
                              index: 0,
                              icon: Icons.spa_outlined,
                              activeIcon: Icons.spa_rounded,
                              label: 'Aujourd’hui',
                              subtitle: 'Saisie quotidienne',
                            ),
                            const SizedBox(height: 6),
                            _buildSidebarItem(
                              index: 1,
                              icon: Icons.table_chart_outlined,
                              activeIcon: Icons.table_chart_rounded,
                              label: 'Fiche Mensuelle',
                              subtitle: 'Grille 1 à 31 jours',
                            ),
                            const SizedBox(height: 6),
                            _buildSidebarItem(
                              index: 2,
                              icon: Icons.menu_book_outlined,
                              activeIcon: Icons.menu_book_rounded,
                              label: 'Bilan & Livres',
                              subtitle: 'Lectures et Âmes',
                            ),
                            const SizedBox(height: 6),
                            _buildSidebarItem(
                              index: 3,
                              icon: Icons.person_outline_rounded,
                              activeIcon: Icons.person_rounded,
                              label: 'Mon Profil',
                              subtitle: 'Infos & Sauvegardes',
                            ),
                          ],
                        ),
                      ),

                      // Bas de sidebar : Raccourci Export PDF rapide
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ExportPdfScreen(state: widget.state),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              gradient: AppTheme.rosePetalGradient,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: AppTheme.roseGlowShadow,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.picture_as_pdf_rounded, color: Colors.white, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Aperçu & Export PDF',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Contenu principal à droite
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: screens[_currentIndex],
                  ),
                ),
              ],
            ),
          );
        }

        // ---- VUE MOBILE STANDARD (Barre en bas) ----
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
      },
    );
  }

  Widget _buildSidebarItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required String subtitle,
  }) {
    final isSelected = _currentIndex == index;

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryRoseLight : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppTheme.primaryRose.withOpacity(0.3) : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppTheme.primaryRose : AppTheme.textMuted,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? AppTheme.primaryRoseDark : AppTheme.textMain,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10.5,
                      color: isSelected
                          ? AppTheme.primaryRose.withOpacity(0.8)
                          : AppTheme.textMuted.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryRose,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
