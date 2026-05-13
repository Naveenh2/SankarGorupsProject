import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/task_model.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _taskCollection(String uid) {
    return _firestore.collection('users').doc(uid).collection('tasks');
  }

  Stream<List<TaskModel>> tasksStream(String uid) {
    return _taskCollection(uid)
        .orderBy('date')
        .snapshots()
        .map(
          (QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
              .map(TaskModel.fromFirestore)
              .toList(growable: false),
        );
  }

  Future<List<TaskModel>> fetchTasks(String uid) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _taskCollection(uid).orderBy('date').get();
    return snapshot.docs.map(TaskModel.fromFirestore).toList(growable: false);
  }

  Future<void> addTask(String uid, TaskModel task) async {
    await _taskCollection(uid).add(task.toMap());
  }

  Future<void> updateTask(String uid, TaskModel task) async {
    await _taskCollection(uid).doc(task.id).update(task.toMap());
  }

  Future<void> deleteTask(String uid, String taskId) async {
    await _taskCollection(uid).doc(taskId).delete();
  }

  Future<void> updateTaskCompletion({
    required String uid,
    required String taskId,
    required bool isCompleted,
  }) async {
    await _taskCollection(uid).doc(taskId).update(
      <String, dynamic>{'isCompleted': isCompleted},
    );
  }
}
