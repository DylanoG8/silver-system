import 'package:flutter/material.dart';

import 'controllers/todo_controller.dart';
import 'screens/home_screen.dart';
import 'services/todo_storage.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = TodoController(TodoStorage());
  await controller.load();
  runApp(TodoApp(controller: controller));
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key, required this.controller});

  final TodoController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeAnimationDuration: const Duration(milliseconds: 350),
      themeAnimationCurve: Curves.easeOutCubic,
      home: HomeScreen(controller: controller),
    );
  }
}
