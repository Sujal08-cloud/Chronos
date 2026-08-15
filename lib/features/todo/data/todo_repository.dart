import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/todo_model.dart';

class TodoRepository {
  final FirebaseFirestore _firestore;

  TodoRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _todosRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('todos');
  }

  Stream<List<TodoModel>> watchTodos(String userId) {
    return _todosRef(userId)
        .orderBy('scheduledDate', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TodoModel.fromMap(doc.id, doc.data())).toList());
  }

  Future<String> addTodo(TodoModel todo) async {
    final docRef = await _todosRef(todo.userId).add(todo.toMap());
    return docRef.id;
  }

  Future<void> updateTodo(TodoModel todo) async {
    await _todosRef(todo.userId).doc(todo.id).update(todo.toMap());
  }

  Future<void> deleteTodo(String userId, String todoId) async {
    await _todosRef(userId).doc(todoId).delete();
  }

  Future<void> toggleComplete(String userId, String todoId, bool isCompleted) async {
    await _todosRef(userId).doc(todoId).update({'isCompleted': isCompleted});
  }

  Future<TodoModel?> getTodoById(String userId, String todoId) async {
    final doc = await _todosRef(userId).doc(todoId).get();
    if (!doc.exists) return null;
    return TodoModel.fromMap(doc.id, doc.data()!);
  }
}