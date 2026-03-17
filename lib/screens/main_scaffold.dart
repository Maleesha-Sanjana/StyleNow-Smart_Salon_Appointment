import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'home/landing_page.dart';
import 'feed/feed_page.dart';
import 'salons/salons_page.dart';
import 'marketplace/marketplace_page.dart';
import 'profile/profile_page.dart';

/// Global notifier — set to 4 to jump to Profile tab from anywhere
final ValueNotifier<int> mainNavIndex = ValueNotifier(0);

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _previousIndex = 0;

  final List<Widget> _pages = const [
    LandingPage(),
    FeedPage(),
    SalonsPage(),
    MarketplacePage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    mainNavIndex.addListener(_onNavChange);
  }

  @override
  void dispose() {
    mainNavIndex.removeListener(_onNavChange);
    super.dispose();
  }

  void _onNavChange() {
    setState(() {});
  }

  void _onTap(int index) {
    _previousIndex = mainNavIndex.value;
    mainNavIndex.value = index;
  }

  @override
  Widget build(BuildContext context) {
    final current = mainNavIndex.value;
    final goingRight = current > _previousIndex;

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        transitionBuilder: (child, animation) {
          // Slide direction depends on which tab we're going to
          final offsetTween = Tween<Offset>(
            begin: Offset(goingRight ? 0.08 : -0.08, 0),
            end: Offset.zero,
          );
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: offsetTween.animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            ),
          );
        },
        // Key forces AnimatedSwitcher to treat each tab as a new widget
        child: KeyedSubtree(
          key: ValueKey<int>(current),
          child: _pages[current],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: current,
        onTap: _onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.primary,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: Colors.white54,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dynamic_feed_outlined),
            activeIcon: Icon(Icons.dynamic_feed),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store_outlined),
            activeIcon: Icon(Icons.store),
            label: 'Salons',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            activeIcon: Icon(Icons.shopping_bag),
            label: 'Market',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
