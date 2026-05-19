import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import '../screens/explore/explore_screen.dart';
import '../screens/history/history_screen.dart';
import '../theme/app_colors.dart';

class MainTabNavigator extends StatefulWidget {
  const MainTabNavigator({super.key});

  @override
  State<MainTabNavigator> createState() => _MainTabNavigatorState();
}

class _MainTabNavigatorState extends State<MainTabNavigator> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const HomeScreen(),
    const ExploreScreen(),
    const HistoryScreen(),
  ];

  @override
  Widget build(BuildContext buildContext) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore_rounded), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: 'History'),
        ],
      ),
    );
  }
}