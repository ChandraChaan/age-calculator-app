import 'package:agely/core/constants/app_spacing.dart';
import 'package:agely/features/age_calculator/services/reminder.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReminderDialog extends StatefulWidget {
  const ReminderDialog({
    required this.targetDate,
    this.initialReminder,
    super.key,
  });

  final DateTime targetDate;
  final Reminder? initialReminder;

  @override
  State<ReminderDialog> createState() => _ReminderDialogState();
}

class _ReminderDialogState extends State<ReminderDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _categoryController;
  late ReminderRepeat _repeat;
  late ReminderStyle _style;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool get _isEditing => widget.initialReminder != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.initialReminder?.title ?? '',
    );
    _categoryController = TextEditingController(
      text: widget.initialReminder?.category ?? 'Personal',
    );
    _repeat = widget.initialReminder?.repeat ?? ReminderRepeat.none;
    _style = widget.initialReminder?.style ?? ReminderStyle.onDay;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit Reminder' : 'Save Reminder'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Want to save this date?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                DateFormat('d MMMM y').format(widget.targetDate),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _titleController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Birthday reminder',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter a reminder title.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _categoryController,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  hintText: 'Personal',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter a reminder category.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<ReminderRepeat>(
                initialValue: _repeat,
                decoration: const InputDecoration(labelText: 'Repeat'),
                items: ReminderRepeat.values
                    .map(
                      (repeat) => DropdownMenuItem<ReminderRepeat>(
                        value: repeat,
                        child: Text(repeat.label),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    _repeat = value;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<ReminderStyle>(
                initialValue: _style,
                decoration: const InputDecoration(labelText: 'Reminder Style'),
                items: ReminderStyle.values
                    .map(
                      (style) => DropdownMenuItem<ReminderStyle>(
                        value: style,
                        child: Text(style.label),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    _style = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(_isEditing ? 'Save Changes' : 'Save Reminder'),
        ),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop(
      ReminderDraft(
        title: _titleController.text.trim(),
        category: _categoryController.text.trim(),
        repeat: _repeat,
        style: _style,
      ),
    );
  }
}

class ReminderDraft {
  const ReminderDraft({
    required this.title,
    required this.category,
    required this.repeat,
    required this.style,
  });

  final String title;
  final String category;
  final ReminderRepeat repeat;
  final ReminderStyle style;
}
