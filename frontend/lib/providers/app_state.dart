import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../models/event.dart';
import '../models/grocery_item.dart';

class AppState extends ChangeNotifier {
  List<Task> _tasks = [];
  List<Event> _events = [];
  List<GroceryItem> _groceryItems = [];
  bool _isLoading = false;

  // Use a more flexible base URL that works for both web and mobile
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:4000',
  );

  List<Task> get tasks => _tasks;
  List<Event> get events => _events;
  List<GroceryItem> get groceryItems => _groceryItems;
  bool get isLoading => _isLoading;

  void initializeDemoData() {
    // Initialize with demo data
    _tasks = [
      Task(
        id: '1',
        title: 'Complete project proposal',
        completed: false,
        dueDate: DateTime.now().add(const Duration(days: 2)),
        priority: Priority.high,
      ),
      Task(
        id: '2',
        title: 'Review code changes',
        completed: true,
        dueDate: DateTime.now(),
        priority: Priority.medium,
      ),
    ];

    _events = [
      Event(
        id: '1',
        title: 'Team Meeting',
        start: DateTime.now(),
        end: DateTime.now().add(const Duration(hours: 1)),
        description: 'Weekly team sync',
      ),
      Event(
        id: '2',
        title: 'Client Call',
        start: DateTime.now().add(const Duration(days: 1, hours: 14)),
        end: DateTime.now().add(const Duration(days: 1, hours: 15)),
        description: 'Project discussion',
      ),
    ];

    _groceryItems = [
      GroceryItem(
        id: '1',
        name: 'Milk',
        qty: 2,
        checked: false,
      ),
      GroceryItem(
        id: '2',
        name: 'Bread',
        qty: 1,
        checked: true,
      ),
    ];

    notifyListeners();
  }

  Future<void> fetchTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse("$apiBaseUrl/api/tasks"),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> tasksJson = json.decode(response.body);
        _tasks = tasksJson.map((json) => Task.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error fetching tasks: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    try {
      final response = await http.post(
        Uri.parse("$apiBaseUrl/api/tasks"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(task.toJson()),
      );

      if (response.statusCode == 201) {
        final newTask = Task.fromJson(json.decode(response.body));
        _tasks.add(newTask);
        notifyListeners();
      }
    } catch (e) {
      print('Error adding task: $e');
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      final response = await http.put(
        Uri.parse("$apiBaseUrl/api/tasks/${task.id}"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(task.toJson()),
      );

      if (response.statusCode == 200) {
        final index = _tasks.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          _tasks[index] = task;
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error updating task: $e');
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      final response = await http.delete(
        Uri.parse("$apiBaseUrl/api/tasks/$id"),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        _tasks.removeWhere((task) => task.id == id);
        notifyListeners();
      }
    } catch (e) {
      print('Error deleting task: $e');
    }
  }

  // Event methods
  void addEvent(Event event) {
    _events.add(event);
    notifyListeners();
  }

  void updateEvent(Event event) {
    final index = _events.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      _events[index] = event;
      notifyListeners();
    }
  }

  void deleteEvent(String id) {
    _events.removeWhere((event) => event.id == id);
    notifyListeners();
  }

  // Grocery methods
  void addGroceryItem(GroceryItem item) {
    _groceryItems.add(item);
    notifyListeners();
  }

  void updateGroceryItem(GroceryItem item) {
    final index = _groceryItems.indexWhere((g) => g.id == item.id);
    if (index != -1) {
      _groceryItems[index] = item;
      notifyListeners();
    }
  }

  void deleteGroceryItem(String id) {
    _groceryItems.removeWhere((item) => item.id == id);
    notifyListeners();
  }
}
