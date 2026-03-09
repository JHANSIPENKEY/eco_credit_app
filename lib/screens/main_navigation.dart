import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'wallet_screen.dart';
import 'rewards_screen.dart';
import 'leaderboard_screen.dart';
import 'profile_screen.dart';

class MainNavigation extends StatefulWidget {
  final int selectedIndex;
  final String role;

  const MainNavigation({super.key, required this.role, this.selectedIndex = 0});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _selectedIndex;
  late final List<Widget> screens;

  @override
  void initState() {
    super.initState();

    // Start from selected tab
    _selectedIndex = widget.selectedIndex;

    // Screens list
    screens = [
      HomeScreen(),
      WalletScreen(),
      RewardsScreen(),
      LeaderboardScreen(),
      ProfileScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: "Wallet",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            label: "Rewards",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: "Leaderboard",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
