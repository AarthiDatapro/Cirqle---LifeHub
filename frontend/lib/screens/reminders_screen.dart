import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'todo_screen.dart'; // Import your todo screen

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  List<dynamic> reminders = [];
  bool loading = true;
  String? token;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('jwt_token');
    if (token == null) {
      setState(() {
        loading = false;
        reminders = [];
      });
      return;
    }

    final res = await http.get(
      Uri.parse('http://192.168.2.63:4000/api/reminders'),
      headers: {"Authorization": "Bearer $token"},
    );

    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      setState(() {
        reminders = data['suggestions'] ?? [];
        loading = false;
      });
    }
  }

  String _friendlyDue(String? dateStr) {
    if (dateStr == null) return "No due date";
    final date = DateTime.parse(dateStr);
    final now = DateTime.now();
    final diff = date.difference(now).inDays;
    if (diff == 0) return "Today ${DateFormat.jm().format(date)}";
    if (diff == 1) return "Tomorrow ${DateFormat.jm().format(date)}";
    if (diff < 0) return "Overdue by ${-diff} days";
    return DateFormat('MMM d, h:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Reminders'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : reminders.isEmpty
              ? const Center(child: Text('No smart reminders right now'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: reminders.length,
                  itemBuilder: (ctx, i) {
                    final r = reminders[i];
                    return Card(
                      child: ListTile(
                        title: Text(r['title'] ?? ''),
                        subtitle: Text(_friendlyDue(r['dueDate'])),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TodoScreen(),
                              ),
                            );
                          },
                          child: const Text('Track Task'),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
