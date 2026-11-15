import 'package:flutter/material.dart';

import '../models/todo.dart';
import '../theme/app_theme.dart';
import '../utils/date_format.dart';

typedef TodoDraft = ({String title, String notes, DateTime? dueDate});

/// Bottom sheet for creating or editing a todo.
/// Returns null if dismissed.
Future<TodoDraft?> showTodoEditor(BuildContext context, {Todo? existing}) {
  return showModalBottomSheet<TodoDraft>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    builder: (_) => _TodoEditor(existing: existing),
  );
}

class _TodoEditor extends StatefulWidget {
  const _TodoEditor({this.existing});

  final Todo? existing;

  @override
  State<_TodoEditor> createState() => _TodoEditorState();
}

class _TodoEditorState extends State<_TodoEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _notes;
  DateTime? _due;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.existing?.title ?? '');
    _notes = TextEditingController(text: widget.existing?.notes ?? '');
    _due = widget.existing?.dueDate;
  }

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final defaultFirstDate = DateTime(now.year - 1);
    final defaultLastDate = DateTime(now.year + 10);
    final firstDate = _due != null && _due!.isBefore(defaultFirstDate)
        ? _due!
        : defaultFirstDate;
    final lastDate = _due != null && _due!.isAfter(defaultLastDate)
        ? _due!
        : defaultLastDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: _due ?? now,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked != null) setState(() => _due = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop<TodoDraft>(context, (
      title: _title.text.trim(),
      notes: _notes.text.trim(),
      dueDate: _due,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 40,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 22),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 46,
                      height: 5,
                      decoration: BoxDecoration(
                        color: scheme.outlineVariant.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: AppGradients.button,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppPalette.primary.withValues(alpha: 0.32),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(
                          isEditing
                              ? Icons.edit_rounded
                              : Icons.add_task_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEditing ? 'Edit task' : 'New task',
                              style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isEditing
                                  ? 'Polish the details'
                                  : 'What do you want to get done?',
                              style: textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                        tooltip: 'Close',
                        style: IconButton.styleFrom(
                          backgroundColor: scheme.surfaceContainerHighest
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _EditorField(
                    controller: _title,
                    label: 'Title',
                    hint: 'e.g. Plan the weekend',
                    icon: Icons.title_rounded,
                    autofocus: true,
                    textInputAction: TextInputAction.next,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Please enter a title'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  _EditorField(
                    controller: _notes,
                    label: 'Notes (optional)',
                    hint: 'Add a little more detail...',
                    icon: Icons.notes_rounded,
                    minLines: 2,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 14),
                  _DueDateField(
                    due: _due,
                    onPick: _pickDate,
                    onClear: () => setState(() => _due = null),
                  ),
                  const SizedBox(height: 24),
                  _GradientButton(
                    label: isEditing ? 'Save changes' : 'Add task',
                    icon: isEditing ? Icons.check_rounded : Icons.add_rounded,
                    onTap: _save,
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EditorField extends StatelessWidget {
  const _EditorField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.autofocus = false,
    this.minLines = 1,
    this.maxLines = 1,
    this.textInputAction,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool autofocus;
  final int minLines;
  final int maxLines;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      autofocus: autofocus,
      minLines: minLines,
      maxLines: maxLines,
      textInputAction: textInputAction,
      textCapitalization: TextCapitalization.sentences,
      validator: validator,
      style: Theme.of(
        context,
      ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppPalette.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.error, width: 1.6),
        ),
      ),
    );
  }
}

class _DueDateField extends StatelessWidget {
  const _DueDateField({
    required this.due,
    required this.onPick,
    required this.onClear,
  });

  final DateTime? due;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasDue = due != null;
    return Row(
      children: [
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPick,
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  color: hasDue
                      ? AppPalette.tertiary.withValues(alpha: 0.1)
                      : scheme.surfaceContainerHighest.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: hasDue
                        ? AppPalette.tertiary.withValues(alpha: 0.5)
                        : scheme.outlineVariant.withValues(alpha: 0.45),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.event_rounded,
                      size: 20,
                      color: hasDue
                          ? AppPalette.tertiary
                          : scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          hasDue ? formatDate(due!) : 'Add a due date',
                          key: ValueKey(hasDue),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: hasDue
                                    ? AppPalette.tertiary
                                    : scheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: hasDue ? AppPalette.tertiary : scheme.outline,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: hasDue
              ? Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: IconButton.filledTonal(
                    onPressed: onClear,
                    icon: const Icon(Icons.close_rounded, size: 20),
                    tooltip: 'Clear due date',
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppGradients.button,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppPalette.primary.withValues(alpha: 0.38),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
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
