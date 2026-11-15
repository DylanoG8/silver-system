import 'package:flutter/foundation.dart';

import '../models/todo.dart';
import '../services/todo_storage.dart';

enum TodoFilter { all, active, completed }

/// Holds app state and persists every change.
class TodoController extends ChangeNotifier {
  TodoController(this._storage);

  final TodoStorage _storage;

  List<Todo> _todos = [];
  TodoFilter _filter = TodoFilter.all;
  String _query = '';
  Future<void> _pending = Future.value();

  TodoFilter get filter => _filter;
  String get query => _query;

  /// Completes when all queued saves have finished (useful in tests).
  Future<void> get idle => _pending;

  List<Todo> get all => List.unmodifiable(_todos);

  int get activeCount => _todos.where((t) => !t.isDone).length;
  int get completedCount => _todos.where((t) => t.isDone).length;

  /// Todos after applying the current filter and search query.
  List<Todo> get visible {
    final q = _query.trim().toLowerCase();
    return _todos.where((t) {
      final matchesFilter = switch (_filter) {
        TodoFilter.all => true,
        TodoFilter.active => !t.isDone,
        TodoFilter.completed => t.isDone,
      };
      if (!matchesFilter) return false;
      if (q.isEmpty) return true;
      return t.title.toLowerCase().contains(q) ||
          t.notes.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> load() async {
    _todos = await _storage.load();
    notifyListeners();
  }

  void setFilter(TodoFilter value) {
    if (value == _filter) return;
    _filter = value;
    notifyListeners();
  }

  void setQuery(String value) {
    if (value == _query) return;
    _query = value;
    notifyListeners();
  }

  void add({required String title, String notes = '', DateTime? dueDate}) {
    final todo = Todo(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title.trim(),
      notes: notes.trim(),
      dueDate: dueDate,
    );
    _todos.insert(0, todo);
    _commit();
  }

  void update(
    String id, {
    required String title,
    required String notes,
    DateTime? dueDate,
  }) {
    final i = _todos.indexWhere((t) => t.id == id);
    if (i == -1) return;
    _todos[i] = _todos[i].copyWith(
      title: title.trim(),
      notes: notes.trim(),
      dueDate: dueDate,
      clearDueDate: dueDate == null,
    );
    _commit();
  }

  void toggle(String id) {
    final i = _todos.indexWhere((t) => t.id == id);
    if (i == -1) return;
    _todos[i] = _todos[i].copyWith(isDone: !_todos[i].isDone);
    _commit();
  }

  /// Removes a todo and returns its index so it can be restored (undo).
  int? remove(String id) {
    final i = _todos.indexWhere((t) => t.id == id);
    if (i == -1) return null;
    _todos.removeAt(i);
    _commit();
    return i;
  }

  void restore(Todo todo, int index) {
    _todos.insert(index.clamp(0, _todos.length), todo);
    _commit();
  }

  void clearCompleted() {
    _todos.removeWhere((t) => t.isDone);
    _commit();
  }

  void _commit() {
    notifyListeners();
    final snapshot = List<Todo>.of(_todos);
    // Chain saves so writes happen in order.
    _pending = _pending.then((_) => _storage.save(snapshot));
  }
}
