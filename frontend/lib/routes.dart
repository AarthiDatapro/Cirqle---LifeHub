import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/todo_screen.dart';
import 'screens/grocery_screen.dart';
import 'screens/reminders_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';     // <-- create placeholder if missing
import 'screens/register_screen.dart'; // <-- create placeholder if missing

class Routes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String register = '/register';
  static const String calendar = '/calendar';
  static const String todo = '/todo';
  static const String grocery = '/grocery';
  static const String reminders = '/reminders';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    home: (context) => const HomeScreen(),
    register: (context) => const RegisterScreen(),
    calendar: (context) => const CalendarScreen(),

    // When navigating without a date, defaults to today's tasks
    todo: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is DateTime) {
        return TodoScreen(selectedDate: args);
      }
      return const TodoScreen();
    },

    grocery: (context) => const GroceryScreen(),
    reminders: (context) => const RemindersScreen(),
  };
}
