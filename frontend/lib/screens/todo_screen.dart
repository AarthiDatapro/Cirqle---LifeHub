import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Priority { low, medium, high }

class Task {
  final String id;
  final String title;
  final bool completed;
  final DateTime dueDate;
  final Priority priority;

  Task({
    required this.id,
    required this.title,
    this.completed = false,
    required this.dueDate,
    this.priority = Priority.medium,
  });

  Task copyWith({
    String? title,
    bool? completed,
    DateTime? dueDate,
    Priority? priority,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
    );
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] ?? json['_id'],
      title: json['title'],
      completed: json['completed'] ?? false,
      dueDate: DateTime.parse(json['dueDate']),
      priority: Priority.values.firstWhere(
        (p) => p.name == (json['priority'] ?? 'medium'),
        orElse: () => Priority.medium,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "completed": completed,
      "dueDate": dueDate.toIso8601String(),
      "priority": priority.name,
    };
  }
}

class TodoScreen extends StatefulWidget {
  final DateTime? selectedDate;
  const TodoScreen({super.key, this.selectedDate});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final _newCtrl = TextEditingController();
  final _uuid = const Uuid();
  late DateTime _currentDate;
  List<Task> _tasks = [];
  bool _loading = false;
  String? token;

  // Use a more flexible base URL that works for both web and mobile
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:4000/api/tasks',
  );

  Priority _selectedPriority = Priority.medium;
  DateTime _selectedDueDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _currentDate = widget.selectedDate ?? DateTime.now();
    _loadTokenAndTasks();
  }

  Future<void> _loadTokenAndTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('jwt_token');

    if (storedToken == null) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
      return;
    }

    setState(() {
      token = storedToken;
    });

    _loadTasks();
  }

  Future<void> _loadTasks() async {
    if (token == null) return;

    setState(() => _loading = true);
    try {
      final res = await http.get(
        Uri.parse(baseUrl),
        headers: {"Authorization": "Bearer $token"},
      );

      if (res.statusCode == 200) {
        final List data = json.decode(res.body);
        setState(() {
          _tasks = data
              .map((t) => Task.fromJson(t))
              .where((task) =>
                  task.dueDate.year == _currentDate.year &&
                  task.dueDate.month == _currentDate.month &&
                  task.dueDate.day == _currentDate.day)
              .toList();
        });
      } else {
        debugPrint("Failed to load tasks: ${res.body}");
      }
    } catch (e) {
      debugPrint("Error loading tasks: $e");
    }
    setState(() => _loading = false);
  }

  Future<void> _addTask() async {
    if (_newCtrl.text.trim().isEmpty || token == null) return;

    final t = Task(
      id: _uuid.v4(),
      title: _newCtrl.text.trim(),
      dueDate: _selectedDueDate,
      priority: _selectedPriority,
      completed: false,
    );

    try {
      final res = await http.post(
        Uri.parse(baseUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode(t.toJson()),
      );

      if (res.statusCode == 201) {
        _newCtrl.clear();
        _selectedPriority = Priority.medium;
        _selectedDueDate = DateTime.now();
        _loadTasks();
      } else {
        debugPrint("Add task failed: ${res.body}");
      }
    } catch (e) {
      debugPrint("Error adding task: $e");
    }
  }

  Future<void> _updateTask(Task updatedTask) async {
    if (token == null) return;
    try {
      final res = await http.put(
        Uri.parse("$baseUrl/${updatedTask.id}"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode(updatedTask.toJson()),
      );
      if (res.statusCode == 200) {
        _loadTasks();
      } else {
        debugPrint("Update task failed: ${res.body}");
      }
    } catch (e) {
      debugPrint("Error updating task: $e");
    }
  }

  Future<void> _deleteTask(String id) async {
    if (token == null) return;
    try {
      final res = await http.delete(
        Uri.parse("$baseUrl/$id"),
        headers: {"Authorization": "Bearer $token"},
      );
      if (res.statusCode == 200) {
        _loadTasks();
      } else {
        debugPrint("Delete task failed: ${res.body}");
      }
    } catch (e) {
      debugPrint("Error deleting task: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        Icons.task_alt,
                        color: Theme.of(context).colorScheme.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'My Tasks',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          Text(
                            '${_currentDate.day} ${_getMonthName(_currentDate.month)} ${_currentDate.year}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.calendar_today,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _currentDate,
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                          );
                          if (picked != null) {
                            setState(() {
                              _currentDate = picked;
                            });
                            _loadTasks();
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Add Task Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _newCtrl,
                              decoration: InputDecoration(
                                hintText: 'What needs to be done?',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 15,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: IconButton(
                              onPressed: _addTask,
                              icon: const Icon(
                                Icons.add,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          // Priority Dropdown
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<Priority>(
                                  value: _selectedPriority,
                                  isExpanded: true,
                                  items: Priority.values.map((p) {
                                    return DropdownMenuItem(
                                      value: p,
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 12,
                                            height: 12,
                                            decoration: BoxDecoration(
                                              color: _getPriorityColor(p),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            p.name.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: _getPriorityColor(p),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    setState(() {
                                      _selectedPriority = val ?? Priority.medium;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Date Picker
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.calendar_today,
                                color: Theme.of(context).colorScheme.primary,
                                size: 20,
                              ),
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedDueDate,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                                );
                                if (picked != null) {
                                  setState(() {
                                    _selectedDueDate = picked;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Tasks List
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _tasks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(30),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.task_outlined,
                                size: 60,
                                color: Colors.grey[400],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'No tasks for today',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add a task to get started',
                              style: TextStyle(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _tasks.length,
                        itemBuilder: (context, index) {
                          final task = _tasks[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              leading: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: task.completed
                                        ? Colors.grey[400]!
                                        : _getPriorityColor(task.priority),
                                    width: 2,
                                  ),
                                  color: task.completed
                                      ? _getPriorityColor(task.priority)
                                      : Colors.transparent,
                                ),
                                child: task.completed
                                    ? const Icon(
                                        Icons.check,
                                        size: 16,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                              title: Text(
                                task.title,
                                style: TextStyle(
                                  decoration: task.completed
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: task.completed
                                      ? Colors.grey[600]
                                      : Colors.black87,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getPriorityColor(task.priority).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          task.priority.name.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: _getPriorityColor(task.priority),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.calendar_today,
                                        size: 12,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${task.dueDate.day} ${_getMonthName(task.dueDate.month)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () => _editTaskDialog(task),
                                    icon: Icon(
                                      Icons.edit_outlined,
                                      color: Colors.grey[600],
                                      size: 20,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _deleteTask(task.id),
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: Colors.red[400],
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () => _updateTask(task.copyWith(completed: !task.completed)),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return Colors.red;
      case Priority.medium:
        return Colors.orange;
      case Priority.low:
        return Colors.green;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  Future<void> _editTaskDialog(Task task) async {
    final titleCtrl = TextEditingController(text: task.title);
    Priority tempPriority = task.priority;
    DateTime tempDueDate = task.dueDate;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Task"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(hintText: "Task title"),
            ),
            const SizedBox(height: 8),
            DropdownButton<Priority>(
              value: tempPriority,
              items: Priority.values.map((p) {
                return DropdownMenuItem(
                  value: p,
                  child: Text(p.name),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  tempPriority = val ?? Priority.medium;
                });
              },
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: tempDueDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                );
                if (picked != null) {
                  setState(() {
                    tempDueDate = picked;
                  });
                }
              },
              icon: const Icon(Icons.date_range),
              label: Text(
                  "Due Date: ${tempDueDate.toLocal().toIso8601String().split("T")[0]}"),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
              onPressed: () {
                _updateTask(task.copyWith(
                  title: titleCtrl.text.trim(),
                  priority: tempPriority,
                  dueDate: tempDueDate,
                ));
                Navigator.pop(context);
              },
              child: const Text("Save")),
        ],
      ),
    );
  }
}

