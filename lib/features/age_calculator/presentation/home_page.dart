import 'package:agely/core/constants/app_spacing.dart';
import 'package:agely/features/age_calculator/presentation/age_calculator_controller.dart';
import 'package:agely/features/age_calculator/presentation/widgets/date_input_field.dart';
import 'package:agely/features/age_calculator/presentation/widgets/primary_button.dart';
import 'package:agely/features/age_calculator/presentation/widgets/result_card.dart';
import 'package:agely/features/age_calculator/presentation/widgets/statistic_tile.dart';
import 'package:agely/features/age_calculator/services/age_calculation_result.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static final DateFormat _fieldDateFormat = DateFormat('d MMM y');
  static final DateFormat _birthdayDateFormat = DateFormat('d MMMM y');
  static final NumberFormat _numberFormat = NumberFormat.decimalPattern();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AgeCalculatorController>();
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 84,
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
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
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
                    subtitle: 'End date defaults to today.',
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
                        _ValidationMessage(message: controller.errorMessage!),
                        const SizedBox(height: AppSpacing.md),
                      ],
                      PrimaryButton(
                        label: 'Calculate',
                        onPressed: controller.calculate,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  if (controller.result == null)
                    const ResultCard(
                      title: 'Results',
                      children: [_EmptyStateMessage()],
                    )
                  else ...[
                    _AgeSummaryCard(result: controller.result!),
                    const SizedBox(height: AppSpacing.md),
                    _TotalsCard(result: controller.result!),
                    if (controller.result!.showsBirthdaySection) ...[
                      const SizedBox(height: AppSpacing.md),
                      _NextBirthdayCard(result: controller.result!),
                    ],
                  ],
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
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        message,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: colorScheme.onErrorContainer),
      ),
    );
  }
}

class _EmptyStateMessage extends StatelessWidget {
  const _EmptyStateMessage();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.hourglass_empty_rounded, color: colorScheme.primary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            'Choose a start date and an end date, then tap Calculate to view the full age breakdown.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
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
