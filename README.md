# Flutter Todo App

A clean, fast, offline-first todo app built with Flutter and Dart, using Material 3 design. Tasks are saved on the device automatically, so nothing is lost when you close the app. The UI uses vibrant aurora gradients, playful animations and smooth transitions to make everyday task management feel a little more delightful.

## Features

- Vibrant gradient header with an animated completion progress bar
- Animated filter pills, search focus glow, staggered task cards and animated checkboxes
- Add, edit and delete tasks through a simple bottom-sheet form (title required, notes optional)
- Check off tasks with a tap on the checkbox
- Due dates with a date picker; overdue tasks are highlighted in red
- Filter by All / Active / Done
- Search by title or notes
- Swipe to delete with an Undo option in the snackbar
- Clear completed tasks from the overflow menu (with confirmation)
- Persistent storage: data is stored locally with `shared_preferences`
- Light and dark themes, following the system setting
- Empty states that adapt to the current filter or search
- Unit tests covering the controller, filtering, persistence and the model

## Screens

| Area | Description |
| --- | --- |
| App bar | Shows the number of remaining tasks and a menu to clear completed ones |
| Search and filter | Live search field and a segmented All / Active / Done switch |
| Task list | Checkbox, title, notes preview and due date; tap to edit, swipe left to delete |
| New task button | Opens the editor sheet to add a task |

## Project structure

```text
lib/
├── main.dart                      # App entry point, theme setup
├── models/
│   └── todo.dart                  # Todo data class + JSON (de)serialization
├── services/
│   └── todo_storage.dart          # Local persistence via shared_preferences
├── controllers/
│   └── todo_controller.dart       # ChangeNotifier: state, filtering, CRUD
├── screens/
│   └── home_screen.dart           # Main UI
├── theme/
│   └── app_theme.dart             # Colors, gradients, light/dark themes
├── widgets/
│   ├── todo_tile.dart             # A single task row (swipe to delete)
│   └── todo_editor.dart           # Add/edit bottom sheet
└── utils/
    └── date_format.dart           # Small date formatting helper
test/
├── todo_controller_test.dart      # Controller and model unit tests
└── home_screen_test.dart          # UI smoke test
```

## Architecture

The app uses plain Flutter with no state-management package:

- `TodoController` extends `ChangeNotifier` and owns all state (the list, filter and search query).
- `HomeScreen` rebuilds through `ListenableBuilder` whenever the controller notifies.
- Every mutation calls `notifyListeners()` and queues a save through `TodoStorage`. Saves are chained so they always run in order.
- The controller is created and loaded in `main()`, so the first frame already shows saved data.

## Getting started

### Prerequisites

- Flutter SDK 3.32 or newer (Dart 3.8+)
- An emulator, simulator, or a connected device (or Chrome for web)

### Run it

The platform folders (`android/`, `ios/`, `web/` and so on) are included in this repository.

```bash
# Install dependencies
flutter pub get

# Run on a connected device or emulator
flutter run
```

### Run the tests

```bash
flutter test
```

### Build a release

```bash
flutter build apk   # Android
flutter build ios   # iOS (requires macOS + Xcode)
flutter build web   # Web
```

## Dependencies

| Package | Purpose |
| --- | --- |
| `shared_preferences` | Persist todos locally |
| `flutter_lints` (dev) | Recommended lint rules |

## Ideas for extending it

- Task priorities and categories or tags
- Drag-to-reorder
- Local notifications for due dates
- Cloud sync (Firebase, Supabase) and sign-in
- Migrating storage to SQLite/Drift for larger lists

## License

MIT. Use it however you like.
