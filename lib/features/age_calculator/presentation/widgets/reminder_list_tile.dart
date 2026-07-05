import 'package:agely/core/constants/app_spacing.dart';
import 'package:agely/features/age_calculator/services/reminder.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReminderListTile extends StatelessWidget {
  const ReminderListTile({
    required this.reminder,
    required this.referenceDate,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final Reminder reminder;
  final DateTime referenceDate;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final nextTriggerDate = reminder.nextTriggerDate(referenceDate);
    final nextEventDate = reminder.nextEventDate(referenceDate);
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      container: true,
      label: 'Reminder ${reminder.title}',
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        reminder.category,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Edit reminder',
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: 'Delete reminder',
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _ReminderMetaChip(
                  label: 'Next alert',
                  value: nextTriggerDate == null
                      ? 'Expired'
                      : DateFormat('d MMM y').format(nextTriggerDate),
                ),
                _ReminderMetaChip(
                  label: 'Event date',
                  value: DateFormat('d MMM y').format(nextEventDate),
                ),
                _ReminderMetaChip(
                  label: 'Repeat',
                  value: reminder.repeat.label,
                ),
                _ReminderMetaChip(label: 'Style', value: reminder.style.label),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReminderMetaChip extends StatelessWidget {
  const _ReminderMetaChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label: $value',
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
      ),
    );
  }
}
