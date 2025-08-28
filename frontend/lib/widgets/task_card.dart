import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final void Function(bool?)? onChanged;
  final DismissDirectionCallback? onDismissed;

  const TaskCard({super.key, required this.task, this.onTap, this.onChanged, this.onDismissed});

  Color _priorityColor(Priority p) {
    switch (p) {
      case Priority.high:
        return Colors.redAccent;
      case Priority.medium:
        return Colors.orangeAccent;
      case Priority.low:
      default:
        return Colors.greenAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(task.id),
      onDismissed: onDismissed ?? (_) {},
      background: Container(color: Colors.redAccent, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          onTap: onTap,
          leading: Checkbox(value: task.completed, onChanged: onChanged),
          title: Text(task.title, style: TextStyle(decoration: task.completed ? TextDecoration.lineThrough : null)),
          subtitle: task.notes != null ? Text(task.notes!) : null,
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: _priorityColor(task.priority).withOpacity(0.14), borderRadius: BorderRadius.circular(8)),
            child: Text(task.priority.name.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }
}
