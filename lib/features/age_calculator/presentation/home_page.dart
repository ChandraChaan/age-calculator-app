import 'package:agely/core/constants/app_spacing.dart';
import 'package:agely/features/age_calculator/presentation/age_calculator_controller.dart';
import 'package:agely/features/age_calculator/presentation/widgets/date_input_field.dart';
import 'package:agely/features/age_calculator/presentation/widgets/primary_button.dart';
import 'package:agely/features/age_calculator/presentation/widgets/reminder_dialog.dart';
import 'package:agely/features/age_calculator/presentation/widgets/reminder_list_tile.dart';
import 'package:agely/features/age_calculator/presentation/widgets/result_card.dart';
import 'package:agely/features/age_calculator/presentation/widgets/statistic_tile.dart';
import 'package:agely/features/age_calculator/services/age_calculation_result.dart';
import 'package:agely/features/age_calculator/services/notification_service.dart';
import 'package:agely/features/age_calculator/services/reminder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static final DateFormat _fieldDateFormat = DateFormat('d MMM y');
  static final DateFormat _birthdayDateFormat = DateFormat('d MMMM y');
  static final NumberFormat _numberFormat = NumberFormat.decimalPattern();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AgeCalculatorController>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 88,
        titleSpacing: AppSpacing.md,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Agely', style: textTheme.headlineSmall),
            const SizedBox(height: 2),
            Text(
              'Age Calculator',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: controller.themeMode == ThemeMode.dark
                ? 'Switch to light theme'
                : 'Switch to dark theme',
            onPressed: () => _toggleTheme(context, controller),
            icon: Icon(
              controller.themeMode == ThemeMode.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
          ),
          PopupMenuButton<_AppBarAction>(
            tooltip: 'App actions',
            onSelected: (action) => _handleAppBarAction(context, action),
            itemBuilder: (context) => const [
              PopupMenuItem(value: _AppBarAction.about, child: Text('About')),
              PopupMenuItem(
                value: _AppBarAction.share,
                child: Text('Share App'),
              ),
              PopupMenuItem(value: _AppBarAction.rate, child: Text('Rate App')),
              PopupMenuItem(
                value: _AppBarAction.privacy,
                child: Text('Privacy Policy'),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 980;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1080),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.md,
                    AppSpacing.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ResultCard(
                        title: 'Date Range',
                        subtitle:
                            'Pick any two dates to compare. End date defaults to today.',
                        icon: Icons.event_outlined,
                        children: [
                          _DateFieldGroup(
                            startDate: controller.startDate,
                            endDate: controller.endDate,
                            showMissingStartDateError:
                                controller.hasMissingStartDateError,
                            onSelectStartDate: () =>
                                _selectStartDate(context, controller),
                            onSelectEndDate: () =>
                                _selectEndDate(context, controller),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          if (controller.errorMessage != null &&
                              !controller.hasMissingStartDateError) ...[
                            _ValidationMessage(
                              message: controller.errorMessage!,
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],
                          PrimaryButton(
                            label: 'Calculate',
                            onPressed: () => _calculate(context, controller),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      if (isWide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: _ResultsColumn(controller: controller),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              flex: 2,
                              child: _RemindersColumn(
                                controller: controller,
                                onCreateReminder:
                                    controller.canSaveReminder &&
                                        controller.suggestedReminderDate != null
                                    ? () => _openCreateReminderDialog(
                                        context,
                                        controller,
                                      )
                                    : null,
                                onEnableNotifications: () =>
                                    _enableNotifications(context, controller),
                                onEditReminder: (reminder) =>
                                    _openEditReminderDialog(
                                      context,
                                      controller,
                                      reminder,
                                    ),
                                onDeleteReminder: (reminder) => _deleteReminder(
                                  context,
                                  controller,
                                  reminder,
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _ResultsColumn(controller: controller),
                            const SizedBox(height: AppSpacing.xl),
                            _RemindersColumn(
                              controller: controller,
                              onCreateReminder:
                                  controller.canSaveReminder &&
                                      controller.suggestedReminderDate != null
                                  ? () => _openCreateReminderDialog(
                                      context,
                                      controller,
                                    )
                                  : null,
                              onEnableNotifications: () =>
                                  _enableNotifications(context, controller),
                              onEditReminder: (reminder) =>
                                  _openEditReminderDialog(
                                    context,
                                    controller,
                                    reminder,
                                  ),
                              onDeleteReminder: (reminder) => _deleteReminder(
                                context,
                                controller,
                                reminder,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        'Version 1.0',
                        textAlign: TextAlign.center,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _selectStartDate(
    BuildContext context,
    AgeCalculatorController controller,
  ) async {
    final today = DateUtils.dateOnly(DateTime.now());
    final initialDate = controller.startDate ?? controller.endDate;
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: today,
      initialDatePickerMode: DatePickerMode.year,
      helpText: 'Select start date',
    );

    if (!context.mounted || selectedDate == null) {
      return;
    }

    controller.updateStartDate(selectedDate);
  }

  Future<void> _selectEndDate(
    BuildContext context,
    AgeCalculatorController controller,
  ) async {
    final today = DateUtils.dateOnly(DateTime.now());
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: controller.endDate,
      firstDate: DateTime(1900),
      lastDate: today,
      initialDatePickerMode: DatePickerMode.year,
      helpText: 'Select end date',
    );

    if (!context.mounted || selectedDate == null) {
      return;
    }

    controller.updateEndDate(selectedDate);
  }

  Future<void> _calculate(
    BuildContext context,
    AgeCalculatorController controller,
  ) async {
    await HapticFeedback.mediumImpact();
    controller.calculate();
  }

  Future<void> _openCreateReminderDialog(
    BuildContext context,
    AgeCalculatorController controller,
  ) async {
    final targetDate = controller.suggestedReminderDate;
    if (targetDate == null) {
      return;
    }

    final draft = await showDialog<ReminderDraft>(
      context: context,
      builder: (context) => ReminderDialog(targetDate: targetDate),
    );

    if (!context.mounted || draft == null) {
      return;
    }

    await HapticFeedback.selectionClick();

    try {
      await controller.createReminder(
        title: draft.title,
        category: draft.category,
        repeat: draft.repeat,
        style: draft.style,
        targetDate: targetDate,
      );

      if (!context.mounted) {
        return;
      }

      _showMessage(context, 'Reminder saved.');
    } on ArgumentError catch (error) {
      if (!context.mounted) {
        return;
      }

      _showMessage(context, error.message.toString());
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      _showMessage(context, 'Could not save this reminder.');
    }
  }

  Future<void> _openEditReminderDialog(
    BuildContext context,
    AgeCalculatorController controller,
    Reminder reminder,
  ) async {
    final draft = await showDialog<ReminderDraft>(
      context: context,
      builder: (context) => ReminderDialog(
        targetDate: reminder.targetDate,
        initialReminder: reminder,
      ),
    );

    if (!context.mounted || draft == null) {
      return;
    }

    await HapticFeedback.selectionClick();

    try {
      await controller.updateReminder(
        reminder: reminder,
        title: draft.title,
        category: draft.category,
        repeat: draft.repeat,
        style: draft.style,
      );

      if (!context.mounted) {
        return;
      }

      _showMessage(context, 'Reminder updated.');
    } on ArgumentError catch (error) {
      if (!context.mounted) {
        return;
      }

      _showMessage(context, error.message.toString());
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      _showMessage(context, 'Could not update this reminder.');
    }
  }

  Future<void> _deleteReminder(
    BuildContext context,
    AgeCalculatorController controller,
    Reminder reminder,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: Text('Remove "${reminder.title}" from upcoming reminders?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (!context.mounted || shouldDelete != true) {
      return;
    }

    await HapticFeedback.selectionClick();

    try {
      await controller.deleteReminder(reminder);

      if (!context.mounted) {
        return;
      }

      _showMessage(context, 'Reminder deleted.');
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      _showMessage(context, 'Could not delete this reminder.');
    }
  }

  Future<void> _enableNotifications(
    BuildContext context,
    AgeCalculatorController controller,
  ) async {
    try {
      await controller.enableNotifications();
      if (!context.mounted) {
        return;
      }

      _showMessage(context, 'Notifications enabled.');
    } on NotificationPermissionDeniedException {
      if (!context.mounted) {
        return;
      }

      _showMessage(
        context,
        AgeCalculatorController.notificationPermissionMessage,
      );
    }
  }

  Future<void> _toggleTheme(
    BuildContext context,
    AgeCalculatorController controller,
  ) async {
    await HapticFeedback.selectionClick();
    await controller.toggleThemeMode();
  }

  Future<void> _handleAppBarAction(
    BuildContext context,
    _AppBarAction action,
  ) async {
    switch (action) {
      case _AppBarAction.about:
        showAboutDialog(
          context: context,
          applicationName: 'Agely',
          applicationVersion: '1.0.0',
          applicationLegalese: 'A minimal age calculator built with Flutter.',
        );
        return;
      case _AppBarAction.share:
        await SharePlus.instance.share(
          ShareParams(
            text:
                'Try Agely, a simple age calculator built for fast date comparisons.',
          ),
        );
        return;
      case _AppBarAction.rate:
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Rate App'),
            content: const Text(
              'Google Play rating will be connected when the store listing goes live.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
        return;
      case _AppBarAction.privacy:
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Privacy Policy'),
            content: const Text(
              'Agely stores reminders locally on your device. A full privacy policy will be published with the Google Play listing.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
        return;
    }
  }

  void _showMessage(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

enum _AppBarAction { about, share, rate, privacy }

class _ResultsColumn extends StatelessWidget {
  const _ResultsColumn({required this.controller});

  final AgeCalculatorController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.result == null) {
      return const ResultCard(
        title: 'Results',
        icon: Icons.analytics_outlined,
        children: [_EmptyStateMessage()],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AgeSummaryCard(result: controller.result!),
        const SizedBox(height: AppSpacing.md),
        _TotalsCard(result: controller.result!),
        if (controller.result!.showsBirthdaySection) ...[
          const SizedBox(height: AppSpacing.md),
          _NextBirthdayCard(result: controller.result!),
        ],
      ],
    );
  }
}

class _RemindersColumn extends StatelessWidget {
  const _RemindersColumn({
    required this.controller,
    required this.onCreateReminder,
    required this.onEnableNotifications,
    required this.onEditReminder,
    required this.onDeleteReminder,
  });

  final AgeCalculatorController controller;
  final VoidCallback? onCreateReminder;
  final VoidCallback onEnableNotifications;
  final ValueChanged<Reminder> onEditReminder;
  final ValueChanged<Reminder> onDeleteReminder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (controller.canSaveReminder &&
            controller.suggestedReminderDate != null)
          _ReminderSuggestionCard(
            targetDate: controller.suggestedReminderDate!,
            isBusy: controller.isSavingReminder,
            onPressed: onCreateReminder,
          ),
        if (controller.canSaveReminder &&
            controller.suggestedReminderDate != null)
          const SizedBox(height: AppSpacing.md),
        _UpcomingRemindersSection(
          controller: controller,
          onCreateReminder: onCreateReminder,
          onEnableNotifications: onEnableNotifications,
          onEditReminder: onEditReminder,
          onDeleteReminder: onDeleteReminder,
        ),
      ],
    );
  }
}

class _DateFieldGroup extends StatelessWidget {
  const _DateFieldGroup({
    required this.startDate,
    required this.endDate,
    required this.showMissingStartDateError,
    required this.onSelectStartDate,
    required this.onSelectEndDate,
  });

  final DateTime? startDate;
  final DateTime endDate;
  final bool showMissingStartDateError;
  final VoidCallback onSelectStartDate;
  final VoidCallback onSelectEndDate;

  @override
  Widget build(BuildContext context) {
    final startDateLabel = startDate == null
        ? null
        : HomePage._fieldDateFormat.format(startDate!);
    final endDateLabel = HomePage._fieldDateFormat.format(endDate);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 560;
        final fieldWidth = isWide
            ? (constraints.maxWidth - AppSpacing.md) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            SizedBox(
              width: fieldWidth,
              child: DateInputField(
                label: 'Start Date',
                value: startDateLabel,
                placeholder: 'Select start date',
                errorText: showMissingStartDateError
                    ? AgeCalculatorController.missingStartDateMessage
                    : null,
                onTap: onSelectStartDate,
              ),
            ),
            SizedBox(
              width: fieldWidth,
              child: DateInputField(
                label: 'End Date',
                value: endDateLabel,
                placeholder: 'Select end date',
                helperText: 'Defaults to today',
                onTap: onSelectEndDate,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ValidationMessage extends StatelessWidget {
  const _ValidationMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: colorScheme.onErrorContainer),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyStateMessage extends StatelessWidget {
  const _EmptyStateMessage();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.insights_outlined, size: 32, color: colorScheme.primary),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Nothing to show yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Choose a start date and an end date, then tap Calculate to view the full age breakdown.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _AgeSummaryCard extends StatelessWidget {
  const _AgeSummaryCard({required this.result});

  final AgeCalculationResult result;

  @override
  Widget build(BuildContext context) {
    return ResultCard(
      title: 'Age Summary',
      icon: Icons.cake_outlined,
      children: [
        _StatisticGrid(
          items: [
            _StatisticItem(
              label: 'Years',
              value: HomePage._numberFormat.format(result.years),
            ),
            _StatisticItem(
              label: 'Months',
              value: HomePage._numberFormat.format(result.months),
            ),
            _StatisticItem(
              label: 'Days',
              value: HomePage._numberFormat.format(result.days),
            ),
            _StatisticItem(
              label: 'Weeks',
              value: HomePage._numberFormat.format(result.weeks),
            ),
          ],
        ),
      ],
    );
  }
}

class _TotalsCard extends StatelessWidget {
  const _TotalsCard({required this.result});

  final AgeCalculationResult result;

  @override
  Widget build(BuildContext context) {
    return ResultCard(
      title: 'Totals',
      icon: Icons.calculate_outlined,
      children: [
        _StatisticGrid(
          items: [
            _StatisticItem(
              label: 'Total Days',
              value: HomePage._numberFormat.format(result.totalDays),
            ),
            _StatisticItem(
              label: 'Total Months',
              value: HomePage._numberFormat.format(result.totalMonths),
            ),
            _StatisticItem(
              label: 'Hours',
              value: HomePage._numberFormat.format(result.hours),
            ),
            _StatisticItem(
              label: 'Minutes',
              value: HomePage._numberFormat.format(result.minutes),
            ),
          ],
        ),
      ],
    );
  }
}

class _NextBirthdayCard extends StatelessWidget {
  const _NextBirthdayCard({required this.result});

  final AgeCalculationResult result;

  @override
  Widget build(BuildContext context) {
    return ResultCard(
      title: 'Next Birthday',
      icon: Icons.celebration_outlined,
      children: [
        _StatisticGrid(
          items: [
            _StatisticItem(
              label: 'Next Birthday',
              value: HomePage._birthdayDateFormat.format(result.nextBirthday!),
            ),
            _StatisticItem(
              label: 'Days Remaining',
              value: HomePage._numberFormat.format(result.daysUntilBirthday!),
            ),
          ],
        ),
      ],
    );
  }
}

class _ReminderSuggestionCard extends StatelessWidget {
  const _ReminderSuggestionCard({
    required this.targetDate,
    required this.isBusy,
    required this.onPressed,
  });

  final DateTime targetDate;
  final bool isBusy;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ResultCard(
      title: 'Want to save this date?',
      subtitle: DateFormat('d MMMM y').format(targetDate),
      icon: Icons.notifications_active_outlined,
      children: [
        PrimaryButton(
          label: isBusy ? 'Saving...' : 'Save Reminder',
          onPressed: isBusy ? null : onPressed,
        ),
      ],
    );
  }
}

class _UpcomingRemindersSection extends StatelessWidget {
  const _UpcomingRemindersSection({
    required this.controller,
    required this.onCreateReminder,
    required this.onEnableNotifications,
    required this.onEditReminder,
    required this.onDeleteReminder,
  });

  final AgeCalculatorController controller;
  final VoidCallback? onCreateReminder;
  final VoidCallback onEnableNotifications;
  final ValueChanged<Reminder> onEditReminder;
  final ValueChanged<Reminder> onDeleteReminder;

  @override
  Widget build(BuildContext context) {
    final today = DateUtils.dateOnly(DateTime.now());

    return ResultCard(
      title: 'Upcoming Reminders',
      icon: Icons.notifications_outlined,
      subtitle: controller.upcomingReminders.isEmpty
          ? 'Save an important date to see it here.'
          : null,
      children: [
        if (controller.isLoadingReminders)
          const Center(child: CircularProgressIndicator())
        else ...[
          if (!controller.notificationsEnabled &&
              controller.upcomingReminders.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Notifications are off for saved reminders.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: onEnableNotifications,
                    child: const Text('Enable'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          if (controller.reminderErrorMessage != null &&
              controller.reminderErrorMessage !=
                  AgeCalculatorController.notificationPermissionMessage) ...[
            _ValidationMessage(message: controller.reminderErrorMessage!),
            const SizedBox(height: AppSpacing.md),
          ],
          if (controller.upcomingReminders.isEmpty)
            const _ReminderEmptyState()
          else
            Column(
              children: [
                for (
                  var index = 0;
                  index < controller.upcomingReminders.length;
                  index += 1
                ) ...[
                  ReminderListTile(
                    reminder: controller.upcomingReminders[index],
                    referenceDate: today,
                    onEdit: () =>
                        onEditReminder(controller.upcomingReminders[index]),
                    onDelete: () =>
                        onDeleteReminder(controller.upcomingReminders[index]),
                  ),
                  if (index != controller.upcomingReminders.length - 1)
                    const SizedBox(height: AppSpacing.md),
                ],
              ],
            ),
          if (onCreateReminder != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: controller.isSavingReminder
                    ? null
                    : onCreateReminder,
                icon: const Icon(Icons.add_alert_outlined),
                label: const Text('Save Another Reminder'),
              ),
            ),
          ],
        ],
      ],
    );
  }
}

class _ReminderEmptyState extends StatelessWidget {
  const _ReminderEmptyState();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.event_available_outlined, color: colorScheme.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'No reminders saved yet. After a calculation, you can save birthdays or comparison dates and get local notifications on this device.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatisticGrid extends StatelessWidget {
  const _StatisticGrid({required this.items});

  final List<_StatisticItem> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 520;
        final tileWidth = isWide
            ? (constraints.maxWidth - AppSpacing.md) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            for (final item in items)
              SizedBox(
                width: tileWidth,
                child: StatisticTile(label: item.label, value: item.value),
              ),
          ],
        );
      },
    );
  }
}

class _StatisticItem {
  const _StatisticItem({required this.label, required this.value});

  final String label;
  final String value;
}
