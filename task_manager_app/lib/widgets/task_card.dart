import 'package:flutter/material.dart';

import '../models/task_model.dart';
import '../utils/date_formatter.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.onToggleComplete,
    required this.onEdit,
    required this.onDelete,
  });

  final TaskModel task;
  final ValueChanged<bool> onToggleComplete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final TextStyle? titleStyle = task.isCompleted
        ? Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(decoration: TextDecoration.lineThrough)
        : Theme.of(context).textTheme.titleMedium;

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (bool? value) => onToggleComplete(value ?? false),
        ),
        title: Text(task.title, style: titleStyle),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(task.description),
              const SizedBox(height: 4),
              Text(
                'Date: ${DateFormatter.format(task.date)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                task.isCompleted ? 'Status: Completed' : 'Status: Pending',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        trailing: Wrap(
          spacing: 2,
          children: [
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_rounded),
              tooltip: 'Edit task',
            ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: 'Delete task',
            ),
          ],
        ),
      ),
    );
  }
}
