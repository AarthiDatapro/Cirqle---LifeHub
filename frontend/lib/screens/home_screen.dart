import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';
import 'calendar_screen.dart';
import 'todo_screen.dart';
import 'grocery_screen.dart';
import 'reminders_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int idx = 1;

  final pages = const [
    CalendarScreen(),
    TodoScreen(),
    GroceryScreen(),
    RemindersScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(duration: const Duration(milliseconds: 450), child: pages[idx], transitionBuilder: (child, anim) {
        return SlideTransition(position: Tween(begin: const Offset(0.15, 0), end: Offset.zero).animate(anim), child: FadeTransition(opacity: anim, child: child));
      }),
      bottomNavigationBar: LifeHubBottomNav(currentIndex: idx, onTap: (i) => setState(() => idx = i)),
    );
  }
}
