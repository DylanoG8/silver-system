import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todo_app/controllers/todo_controller.dart';
import 'package:flutter_todo_app/models/todo.dart';
import 'package:flutter_todo_app/services/todo_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<TodoController> makeController() async {
    final c = TodoController(TodoStorage());
    await c.load();
    return c;
  }

  test('adds todos newest-first and trims the title', () async {
    final c = await makeController();
    c.add(title: '  First ');
    await Future<void>.delayed(const Duration(milliseconds: 2));
    c.add(title: 'Second');
    expect(c.all.map((t) => t.title), ['Second', 'First']);
  });

  test('toggle updates counts', () async {
    final c = await makeController();
    c.add(title: 'A');
    c.toggle(c.all.first.id);
    expect(c.completedCount, 1);
    expect(c.activeCount, 0);
  });

  test('filter and search narrow the visible list', () async {
    final c = await makeController();
    c.add(title: 'Buy milk');
    await Future<void>.delayed(const Duration(milliseconds: 2));
    c.add(title: 'Write report', notes: 'quarterly numbers');
    c.toggle(c.all.first.id); // completes "Write report"

    c.setFilter(TodoFilter.active);
    expect(c.visible.map((t) => t.title), ['Buy milk']);

    c.setFilter(TodoFilter.all);
    c.setQuery('quarterly');
    expect(c.visible.map((t) => t.title), ['Write report']);
  });

  test('update can set and clear the due date', () async {
    final c = await makeController();
    c.add(title: 'A');
    final id = c.all.first.id;
    final due = DateTime(2030, 1, 1);
    c.update(id, title: 'A2', notes: 'n', dueDate: due);
    expect(c.all.first.dueDate, due);
    c.update(id, title: 'A2', notes: 'n');
    expect(c.all.first.dueDate, isNull);
  });

  test('remove and restore put the item back in place', () async {
    final c = await makeController();
    c.add(title: 'A');
    await Future<void>.delayed(const Duration(milliseconds: 2));
    c.add(title: 'B');
    final todo = c.all.last; // "A"
    final index = c.remove(todo.id)!;
    expect(c.all.length, 1);
    c.restore(todo, index);
    expect(c.all.map((t) => t.title), ['B', 'A']);
  });

  test('clearCompleted removes only finished tasks', () async {
    final c = await makeController();
    c.add(title: 'A');
    await Future<void>.delayed(const Duration(milliseconds: 2));
    c.add(title: 'B');
    c.toggle(c.all.first.id);
    c.clearCompleted();
    expect(c.all.map((t) => t.title), ['A']);
  });

  test('data persists across controller instances', () async {
    final c1 = await makeController();
    c1.add(title: 'Persist me', notes: 'please');
    await c1.idle;

    final c2 = await makeController();
    expect(c2.all.single.title, 'Persist me');
    expect(c2.all.single.notes, 'please');
  });

  test('Todo JSON round-trip and overdue detection', () {
    final todo = Todo(
      id: '1',
      title: 'T',
      dueDate: DateTime.now().subtract(const Duration(days: 3)),
    );
    final copy = Todo.fromJson(todo.toJson());
    expect(copy.title, 'T');
    expect(copy.isOverdue, isTrue);
    expect(copy.copyWith(isDone: true).isOverdue, isFalse);
  });
}
