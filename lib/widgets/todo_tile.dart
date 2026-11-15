import 'package:flutter/material.dart';

import '../models/todo.dart';
import '../theme/app_theme.dart';
import '../utils/date_format.dart';

class TodoTile extends StatefulWidget {
  const TodoTile({
    super.key,
    required this.todo,
    required this.index,
    required this.onToggle,
    required this.onTap,
    required this.onDelete,
  });

  final Todo todo;
  final int index;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  State<TodoTile> createState() => _TodoTileState();
}

class _TodoTileState extends State<TodoTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _fade = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0, 0.7, curve: Curves.easeOut),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic));

    final delay = Duration(milliseconds: 45 * widget.index.clamp(0, 8));
    Future<void>.delayed(delay, () {
      if (mounted) _entrance.forward();
    });
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todo = widget.todo;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final accentGradient = AppGradients.accentFor(todo.id);
    final accent = accentGradient.colors.first;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Dismissible(
          key: ValueKey(todo.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => widget.onDelete(),
          background: const _DeleteBackground(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: todo.isDone
                    ? scheme.outlineVariant.withValues(alpha: 0.5)
                    : accent.withValues(alpha: 0.22),
              ),
              boxShadow: [
                BoxShadow(
                  color: todo.isDone
                      ? Colors.black.withValues(alpha: 0.04)
                      : accent.withValues(alpha: 0.14),
                  blurRadius: 20,
                  offset: const Offset(0, 9),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 14,
                    bottom: 14,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 5,
                      decoration: BoxDecoration(
                        gradient: todo.isDone
                            ? LinearGradient(
                                colors: [
                                  scheme.outlineVariant,
                                  scheme.outlineVariant,
                                ],
                              )
                            : accentGradient,
                        borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(99),
                        ),
                      ),
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: widget.onTap,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _AnimatedCheck(
                              isDone: todo.isDone,
                              accent: accent,
                              onTap: widget.onToggle,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeOut,
                                    style:
                                        (textTheme.titleMedium ??
                                                const TextStyle())
                                            .copyWith(
                                              fontWeight: FontWeight.w700,
                                              height: 1.25,
                                              color: todo.isDone
                                                  ? scheme.outline
                                                  : scheme.onSurface,
                                              decoration: todo.isDone
                                                  ? TextDecoration.lineThrough
                                                  : TextDecoration.none,
                                              decorationColor: scheme.outline,
                                            ),
                                    child: Text(todo.title),
                                  ),
                                  if (todo.notes.isNotEmpty) ...[
                                    const SizedBox(height: 5),
                                    Text(
                                      todo.notes,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: textTheme.bodySmall?.copyWith(
                                        color: scheme.onSurfaceVariant
                                            .withValues(alpha: 0.85),
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
                                  if (todo.dueDate != null) ...[
                                    const SizedBox(height: 9),
                                    _DueChip(
                                      dueDate: todo.dueDate!,
                                      isOverdue: todo.isOverdue,
                                      accent: accent,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Icon(
                                Icons.edit_rounded,
                                size: 16,
                                color: scheme.outline.withValues(alpha: 0.55),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedCheck extends StatelessWidget {
  const _AnimatedCheck({
    required this.isDone,
    required this.accent,
    required this.onTap,
  });

  final bool isDone;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      checked: isDone,
      label: isDone ? 'Mark as not done' : 'Mark as done',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutBack,
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: isDone
                ? LinearGradient(
                    colors: [accent, accent.withValues(alpha: 0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isDone ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDone ? Colors.transparent : scheme.outlineVariant,
              width: 2,
            ),
            boxShadow: isDone
                ? [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: AnimatedScale(
            scale: isDone ? 1 : 0,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutBack,
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 19,
            ),
          ),
        ),
      ),
    );
  }
}

class _DueChip extends StatelessWidget {
  const _DueChip({
    required this.dueDate,
    required this.isOverdue,
    required this.accent,
  });

  final DateTime dueDate;
  final bool isOverdue;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = isOverdue ? scheme.error : accent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOverdue ? Icons.warning_amber_rounded : Icons.event_rounded,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            isOverdue
                ? 'Overdue - ${formatDate(dueDate)}'
                : formatDate(dueDate),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.error.withValues(alpha: 0.15),
            scheme.error.withValues(alpha: 0.85),
            scheme.error,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.delete_sweep_rounded, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            'Delete',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
