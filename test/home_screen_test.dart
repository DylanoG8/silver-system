import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todo_app/controllers/todo_controller.dart';
import 'package:flutter_todo_app/screens/home_screen.dart';
import 'package:flutter_todo_app/services/todo_storage.dart';
import 'package:flutter_todo_app/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('home screen renders and adds a task', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final controller = TodoController(TodoStorage());
    await controller.load();

    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: HomeScreen(controller: controller),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('My Tasks'), findsOneWidget);
    expect(find.text('No tasks yet'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);

    await tester.tap(find.text('New task'));
    await tester.pumpAndSettle();

    expect(find.byType(TextFormField), findsNWidgets(2));

    await tester.enterText(find.byType(TextFormField).first, 'Buy flowers');
    await tester.tap(find.text('Add task'));
    await tester.pumpAndSettle();
    await controller.idle;

    expect(controller.all.single.title, 'Buy flowers');
    expect(find.text('Buy flowers'), findsOneWidget);
    expect(find.text('No tasks yet'), findsNothing);
  });
}
