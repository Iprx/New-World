import 'package:flutter/material.dart';

import 'discover_screen.dart';
import 'matches_screen.dart';
import 'profile_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  final _discoverKey = GlobalKey<DiscoverScreenState>();
  final _matchesKey = GlobalKey<MatchesScreenState>();

  late final _screens = [
    DiscoverScreen(key: _discoverKey),
    MatchesScreen(key: _matchesKey),
    const ProfileScreen(),
  ];

  void _onDestinationSelected(int value) {
    setState(() => _index = value);
    // The tabs stay alive in the IndexedStack (so scroll position and any
    // in-progress state survive switching), which means they'd otherwise
    // only ever load once. Re-fetch whenever a tab is re-selected so a new
    // discover candidate or a match made elsewhere shows up.
    switch (value) {
      case 0:
        _discoverKey.currentState?.reload();
      case 1:
        _matchesKey.currentState?.reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.style_outlined), selectedIcon: Icon(Icons.style), label: 'Discover'),
          NavigationDestination(icon: Icon(Icons.favorite_border), selectedIcon: Icon(Icons.favorite), label: 'Matches'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
