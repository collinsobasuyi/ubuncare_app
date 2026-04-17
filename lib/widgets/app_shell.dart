import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../app/theme.dart';
import '../features/home/home_screen.dart';
import '../features/mood/mood_history_screen.dart';
import '../features/wellness/wellness_hub_screen.dart';
import '../features/settings/settings_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with SingleTickerProviderStateMixin {
  int _index = 0;
  late final PageController _pageCtrl;
  late final AnimationController _fabAnim;

  static const _tabs = [
    _TabItem(icon: Icons.home_rounded, label: 'Home'),
    _TabItem(icon: Icons.book_rounded, label: 'Journal'),
    _TabItem(icon: Icons.grid_view_rounded, label: 'Explore'),
    _TabItem(icon: Icons.person_rounded, label: 'You'),
  ];

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
    _fabAnim  = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _fabAnim.dispose();
    super.dispose();
  }

  void _onTabTap(int i) {
    if (_index == i) return;
    HapticFeedback.selectionClick();
    setState(() => _index = i);
    _pageCtrl.animateToPage(
      i,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      body: PageView(
        controller: _pageCtrl,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          HomeScreen(),
          MoodHistoryScreen(),
          WellnessHubScreen(),
          SettingsScreen(),
        ],
      ),
      // ── Floating check-in button ──────────────────────────────────────────
      floatingActionButton: _index == 0
          ? ScaleTransition(
              scale: CurvedAnimation(parent: _fabAnim, curve: Curves.elasticOut),
              child: FloatingActionButton.extended(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  context.push('/chatmood');
                },
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                elevation: 6,
                extendedPadding: const EdgeInsets.symmetric(horizontal: 24),
                icon: const Icon(Icons.add_rounded, size: 22),
                label: const Text(
                  'Check In',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // ── Bottom navigation ─────────────────────────────────────────────────
      bottomNavigationBar: _BottomNav(
        selectedIndex: _index,
        onTap: _onTabTap,
        tabs: _tabs,
        showFab: _index == 0,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom navigation bar
// ─────────────────────────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final List<_TabItem> tabs;
  final bool showFab;

  const _BottomNav({
    required this.selectedIndex,
    required this.onTap,
    required this.tabs,
    required this.showFab,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        border: const Border(
          top: BorderSide(color: AppTheme.bgBorder, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A2420).withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60 + (showFab ? 8.0 : 0),
          child: Row(
            children: [
              // Left two tabs
              ...[0, 1].map((i) => _NavItem(
                    tab: tabs[i],
                    selected: selectedIndex == i,
                    onTap: () => onTap(i),
                  )),
              // Center gap for FAB
              if (showFab) const SizedBox(width: 72),
              // Right two tabs
              ...[2, 3].map((i) => _NavItem(
                    tab: tabs[i],
                    selected: selectedIndex == i,
                    onTap: () => onTap(i),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final _TabItem tab;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: tab.label,
        child: InkWell(
          onTap: onTap,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                decoration: BoxDecoration(
                  color: selected
                      ? AppTheme.primarySurface
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  tab.icon,
                  size: 22,
                  color: selected ? AppTheme.primary : AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  color: selected ? AppTheme.primary : AppTheme.textMuted,
                ),
                child: Text(tab.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final String label;
  const _TabItem({required this.icon, required this.label});
}
