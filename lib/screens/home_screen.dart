import 'package:flutter/material.dart';

import '../controllers/todo_controller.dart';
import '../models/todo.dart';
import '../theme/app_theme.dart';
import '../widgets/todo_editor.dart';
import '../widgets/todo_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.controller});

  final TodoController controller;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _search = TextEditingController();

  TodoController get _c => widget.controller;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _addTodo() async {
    final draft = await showTodoEditor(context);
    if (draft == null) return;
    _c.add(title: draft.title, notes: draft.notes, dueDate: draft.dueDate);
  }

  Future<void> _editTodo(Todo todo) async {
    final draft = await showTodoEditor(context, existing: todo);
    if (draft == null) return;
    _c.update(
      todo.id,
      title: draft.title,
      notes: draft.notes,
      dueDate: draft.dueDate,
    );
  }

  void _deleteTodo(Todo todo) {
    final index = _c.remove(todo.id);
    if (index == null) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.delete_sweep_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text('Deleted "${todo.title}"')),
            ],
          ),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => _c.restore(todo, index),
          ),
        ),
      );
  }

  Future<void> _confirmClearCompleted() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final scheme = Theme.of(ctx).colorScheme;
        return AlertDialog(
          backgroundColor: scheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          icon: Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: AppGradients.button,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_delete_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          title: const Text('Clear completed?'),
          content: Text(
            'This removes ${_c.completedCount} completed '
            '${_c.completedCount == 1 ? 'task' : 'tasks'}.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
    if (ok == true) _c.clearCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _c,
      builder: (context, _) {
        final items = _c.visible;
        final total = _c.all.length;
        final completed = _c.completedCount;
        final progress = total == 0 ? 0.0 : completed / total;
        final hasAny = _c.all.isNotEmpty;
        final hasQuery = _c.query.trim().isNotEmpty;

        return Scaffold(
          body: Stack(
            children: [
              const Positioned.fill(child: _AuroraBackground()),
              SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: _Header(
                        activeCount: _c.activeCount,
                        completedCount: completed,
                        total: total,
                        progress: progress,
                        canClear: completed > 0,
                        onClearCompleted: _confirmClearCompleted,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _SearchField(
                        controller: _search,
                        query: _c.query,
                        onChanged: _c.setQuery,
                        onClear: () {
                          _search.clear();
                          _c.setQuery('');
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _FilterBar(
                        selected: _c.filter,
                        onChanged: _c.setFilter,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, animation) {
                          final offset = Tween<Offset>(
                            begin: const Offset(0, 0.03),
                            end: Offset.zero,
                          ).animate(animation);
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: offset,
                              child: child,
                            ),
                          );
                        },
                        child: items.isEmpty
                            ? _EmptyState(
                                key: ValueKey(
                                  'empty-$hasAny-$hasQuery-${_c.filter.name}',
                                ),
                                hasAny: hasAny,
                                filter: _c.filter,
                                query: _c.query,
                              )
                            : ListView.separated(
                                key: ValueKey('list-${_c.filter.name}'),
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  8,
                                  16,
                                  120,
                                ),
                                itemCount: items.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final todo = items[index];
                                  return TodoTile(
                                    key: ValueKey(todo.id),
                                    todo: todo,
                                    index: index,
                                    onToggle: () => _c.toggle(todo.id),
                                    onTap: () => _editTodo(todo),
                                    onDelete: () => _deleteTodo(todo),
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: _GradientFab(onPressed: _addTodo),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.activeCount,
    required this.completedCount,
    required this.total,
    required this.progress,
    required this.canClear,
    required this.onClearCompleted,
  });

  final int activeCount;
  final int completedCount;
  final int total;
  final double progress;
  final bool canClear;
  final VoidCallback onClearCompleted;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final percent = (progress * 100).round();

    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.header,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppPalette.primary.withValues(alpha: 0.35),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          children: [
            Positioned(
              top: -60,
              right: -40,
              child: _GlowOrb(
                size: 160,
                color: Colors.white.withValues(alpha: 0.16),
              ),
            ),
            Positioned(
              bottom: -70,
              left: -30,
              child: _GlowOrb(
                size: 150,
                color: AppPalette.mint.withValues(alpha: 0.25),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 14, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.22),
                          ),
                        ),
                        child: const Icon(
                          Icons.done_all_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'My Tasks',
                              style: textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.6,
                              ),
                            ),
                            Text(
                              "Let's make today count",
                              style: textTheme.bodySmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.75),
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        tooltip: 'More options',
                        icon: Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Icon(
                            Icons.more_horiz_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        onSelected: (value) {
                          if (value == 'clear') onClearCompleted();
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: 'clear',
                            enabled: canClear,
                            child: const Row(
                              children: [
                                Icon(Icons.cleaning_services_rounded, size: 18),
                                SizedBox(width: 10),
                                Text('Clear completed'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$activeCount',
                            style: textTheme.displaySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              height: 0.9,
                            ),
                          ),
                          Text(
                            activeCount == 1 ? 'task left' : 'tasks left',
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$percent%',
                            style: textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '$completedCount of $total done',
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _AnimatedProgress(value: progress),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedProgress extends StatelessWidget {
  const _AnimatedProgress({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.clamp(0.0, 1.0).toDouble()),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, animated, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              height: 10,
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Container(
                width: constraints.maxWidth * animated,
                height: 10,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, AppPalette.mint],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(99)),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _SearchField extends StatefulWidget {
  const _SearchField({
    required this.controller,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  final _focus = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    setState(() => _focused = _focus.hasFocus);
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocusChanged);
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _focused
              ? AppPalette.primary
              : scheme.outlineVariant.withValues(alpha: 0.5),
          width: _focused ? 1.6 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (_focused ? AppPalette.primary : Colors.black).withValues(
              alpha: _focused ? 0.16 : 0.05,
            ),
            blurRadius: _focused ? 26 : 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focus,
        onChanged: widget.onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search tasks...',
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: _focused ? AppPalette.primary : scheme.onSurfaceVariant,
          ),
          suffixIcon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: widget.query.isEmpty
                ? const SizedBox.shrink(key: ValueKey('empty'))
                : IconButton(
                    key: const ValueKey('clear'),
                    icon: const Icon(Icons.close_rounded),
                    onPressed: widget.onClear,
                    tooltip: 'Clear search',
                  ),
          ),
        ),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selected, required this.onChanged});

  final TodoFilter selected;
  final ValueChanged<TodoFilter> onChanged;

  String _label(TodoFilter filter) => switch (filter) {
    TodoFilter.all => 'All',
    TodoFilter.active => 'Active',
    TodoFilter.completed => 'Done',
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          for (final filter in TodoFilter.values)
            Expanded(
              child: _FilterPill(
                label: _label(filter),
                selected: filter == selected,
                onTap: () => onChanged(filter),
              ),
            ),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            gradient: selected ? AppGradients.button : null,
            borderRadius: BorderRadius.circular(15),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppPalette.primary.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              style: (textTheme.labelLarge ?? const TextStyle()).copyWith(
                color: selected ? Colors.white : scheme.onSurfaceVariant,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
              child: Text(label),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    super.key,
    required this.hasAny,
    required this.filter,
    required this.query,
  });

  final bool hasAny;
  final TodoFilter filter;
  final String query;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasQuery = query.trim().isNotEmpty;

    final message = !hasAny
        ? 'No tasks yet'
        : hasQuery
        ? 'No tasks match your search'
        : switch (filter) {
            TodoFilter.active => 'Nothing left to do',
            TodoFilter.completed => 'No completed tasks yet',
            TodoFilter.all => 'No tasks match your search',
          };

    final hint = !hasAny
        ? 'Tap "New task" and give your day a direction.'
        : hasQuery
        ? 'Try a different keyword.'
        : switch (filter) {
            TodoFilter.active => 'Everything is checked off. Enjoy the win!',
            TodoFilter.completed => 'Finish a task to see it here.',
            TodoFilter.all => 'Add a new task to fill this space.',
          };

    final icon = !hasAny
        ? Icons.rocket_launch_rounded
        : hasQuery
        ? Icons.search_off_rounded
        : filter == TodoFilter.completed
        ? Icons.task_alt_rounded
        : Icons.celebration_rounded;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 650),
                curve: Curves.easeOutBack,
                builder: (context, value, child) {
                  final clamped = value.clamp(0.0, 1.0).toDouble();
                  return Opacity(
                    opacity: clamped,
                    child: Transform.translate(
                      offset: Offset(0, 24 * (1 - clamped)),
                      child: Transform.scale(
                        scale: 0.86 + 0.14 * clamped,
                        child: child,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(32, 24, 32, 120),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 92,
                        height: 92,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: AppGradients.button,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppPalette.primary.withValues(alpha: 0.35),
                              blurRadius: 28,
                              offset: const Offset(0, 14),
                            ),
                          ],
                        ),
                        child: Icon(icon, size: 44, color: Colors.white),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        hint,
                        textAlign: TextAlign.center,
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GradientFab extends StatelessWidget {
  const _GradientFab({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppGradients.button,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppPalette.primary.withValues(alpha: 0.45),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_rounded, color: Colors.white, size: 24),
                const SizedBox(width: 8),
                Text(
                  'New task',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AuroraBackground extends StatelessWidget {
  const _AuroraBackground();

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -140,
            right: -100,
            child: _Blob(
              size: 320,
              colors: [
                AppPalette.primary.withValues(alpha: dark ? 0.32 : 0.18),
                Colors.transparent,
              ],
            ),
          ),
          Positioned(
            bottom: 40,
            left: -140,
            child: _Blob(
              size: 340,
              colors: [
                AppPalette.secondary.withValues(alpha: dark ? 0.22 : 0.13),
                Colors.transparent,
              ],
            ),
          ),
          Positioned(
            top: 360,
            right: -120,
            child: _Blob(
              size: 280,
              colors: [
                AppPalette.tertiary.withValues(alpha: dark ? 0.16 : 0.1),
                Colors.transparent,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.colors});

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: colors),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}
