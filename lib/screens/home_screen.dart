import 'package:flutter/material.dart';
import 'browse_screen.dart';
import 'my_listings_screen.dart';
import 'chats_screen.dart';
import 'settings_screen.dart';
import '../widgets/bottom_nav.dart';
import 'swaps_request_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const BrowseScreen(),
    const MyListingsScreen(),
    const ChatsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      floatingActionButton: FloatingActionButton(
        tooltip: 'Swap Requests',
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const SwapRequestsPage()));
        },
        child: const Icon(Icons.swap_horiz),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
