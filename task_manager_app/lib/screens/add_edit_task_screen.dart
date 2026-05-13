import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task_model.dart';
import '../services/auth_provider.dart';
import '../services/task_provider.dart';
import '../utils/date_formatter.dart';
import '../utils/snackbar_util.dart';
import '../utils/validators.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class AddEditTaskScreen extends StatefulWidget {
  const AddEditTaskScreen({super.key, this.task});

  final TaskModel? task;

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late bool _isCompleted;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    final TaskModel? task = widget.task;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(text: task?.description ?? '');
    _selectedDate = task?.date ?? DateTime.now();
    _isCompleted = task?.isCompleted ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 10),
    );
    if (pickedDate == null) return;
    setState(() {
      _selectedDate = pickedDate;
    });
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    final String userId = context.read<AuthProvider>().user?.uid ?? '';
    if (userId.isEmpty) {
      SnackBarUtil.showError(context, 'User session expired. Please login again.');
      return;
    }

    final TaskProvider taskProvider = context.read<TaskProvider>();
    bool success;

    if (_isEditing) {
      final TaskModel updatedTask = widget.task!.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        date: _selectedDate,
        isCompleted: _isCompleted,
      );
      success = await taskProvider.updateTask(userId: userId, task: updatedTask);
    } else {
      success = await taskProvider.addTask(
        userId: userId,
        title: _titleController.text,
        description: _descriptionController.text,
        date: _selectedDate,
      );
    }

    if (!mounted) return;
    if (!success) {
      SnackBarUtil.showError(
        context,
        taskProvider.errorMessage ?? 'Could not save task',
      );
      return;
    }
    SnackBarUtil.showMessage(
      context,
      _isEditing ? 'Task updated' : 'Task added',
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Task' : 'Add Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              CustomTextField(
                controller: _titleController,
                label: 'Title',
                validator: (String? value) =>
                    Validators.requiredField(value, fieldName: 'Title'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descriptionController,
                label: 'Description',
                maxLines: 4,
                validator: (String? value) =>
                    Validators.requiredField(value, fieldName: 'Description'),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Task Date'),
                subtitle: Text(DateFormatter.format(_selectedDate)),
                trailing: IconButton(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.date_range_rounded),
                ),
              ),
              if (_isEditing)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Mark as Completed'),
                  value: _isCompleted,
                  onChanged: (bool value) {
                    setState(() {
                      _isCompleted = value;
                    });
                  },
                ),
              const SizedBox(height: 20),
              Consumer<TaskProvider>(
                builder: (_, TaskProvider provider, __) {
                  return CustomButton(
                    text: _isEditing ? 'Update Task' : 'Create Task',
                    isLoading: provider.isLoading,
                    onPressed: _saveTask,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
