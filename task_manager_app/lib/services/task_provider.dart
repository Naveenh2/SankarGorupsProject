import 'dart:async';

import 'package:flutter/material.dart';

import '../models/task_model.dart';
import 'firestore_service.dart';

enum TaskFilter { all, completed, pending }

class TaskProvider extends ChangeNotifier {
  TaskProvider(this._firestoreService);

  final FirestoreService _firestoreService;

  StreamSubscription<List<TaskModel>>? _taskSubscription;
  List<TaskModel> _tasks = <TaskModel>[];
  bool _isLoading = false;
  String? _errorMessage;
  TaskFilter _currentFilter = TaskFilter.all;
  String? _listeningUserId;

  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  TaskFilter get currentFilter => _currentFilter;

  List<TaskModel> get filteredTasks {
    switch (_currentFilter) {
      case TaskFilter.completed:
        return _tasks.where((TaskModel task) => task.isCompleted).toList();
      case TaskFilter.pending:
        return _tasks.where((TaskModel task) => !task.isCompleted).toList();
      case TaskFilter.all:
        return _tasks;
    }
  }

  void listenToTasks(String userId) {
    if (_listeningUserId == userId && _taskSubscription != null) {
      return;
    }

    _listeningUserId = userId;
    _taskSubscription?.cancel();
    _setLoading(true);
    _errorMessage = null;

    _taskSubscription = _firestoreService.tasksStream(userId).listen(
      (List<TaskModel> tasks) {
        _tasks = tasks;
        _setLoading(false);
      },
      onError: (_) {
        _errorMessage = 'Failed to load tasks.';
        _setLoading(false);
      },
    );
  }

  Future<void> refreshTasks(String userId) async {
    try {
      final List<TaskModel> latest = await _firestoreService.fetchTasks(userId);
      _tasks = latest;
      _errorMessage = null;
      notifyListeners();
    } catch (_) {
      _errorMessage = 'Unable to refresh tasks.';
      notifyListeners();
    }
  }

  Future<bool> addTask({
    required String userId,
    required String title,
    required String description,
    required DateTime date,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _firestoreService.addTask(
        userId,
        TaskModel(
          id: '',
          title: title.trim(),
          description: description.trim(),
          date: date,
          isCompleted: false,
        ),
      );
      return true;
    } catch (_) {
      _errorMessage = 'Failed to add task.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateTask({
    required String userId,
    required TaskModel task,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _firestoreService.updateTask(userId, task);
      return true;
    } catch (_) {
      _errorMessage = 'Failed to update task.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleTaskCompletion({
    required String userId,
    required TaskModel task,
    required bool value,
  }) async {
    try {
      await _firestoreService.updateTaskCompletion(
        uid: userId,
        taskId: task.id,
        isCompleted: value,
      );
    } catch (_) {
      _errorMessage = 'Could not update task status.';
      notifyListeners();
    }
  }

  Future<void> deleteTask({
    required String userId,
    required String taskId,
  }) async {
    try {
      await _firestoreService.deleteTask(userId, taskId);
    } catch (_) {
      _errorMessage = 'Failed to delete task.';
      notifyListeners();
    }
  }

  void setFilter(TaskFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  void clear() {
    _tasks = <TaskModel>[];
    _errorMessage = null;
    _listeningUserId = null;
    _taskSubscription?.cancel();
    _taskSubscription = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _taskSubscription?.cancel();
    super.dispose();
  }
}
