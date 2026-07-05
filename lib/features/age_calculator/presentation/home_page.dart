import 'package:agely/core/constants/app_spacing.dart';
import 'package:agely/features/age_calculator/presentation/widgets/dob_picker.dart';
import 'package:agely/features/age_calculator/presentation/widgets/primary_button.dart';
import 'package:agely/features/age_calculator/presentation/widgets/result_card.dart';
import 'package:agely/features/age_calculator/presentation/widgets/statistic_tile.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
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
                    title: 'Date of Birth',
                    children: [
                      DobPicker(
                        placeholder: 'Select your date of birth',
                        onTap: () {},
                      ),
                      const SizedBox(height: AppSpacing.md),
                      PrimaryButton(label: 'Calculate Age', onPressed: () {}),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const ResultCard(
                    title: 'Your Age',
                    children: [
                      _StatisticGrid(
                        items: [
                          _StatisticItem(label: 'Years', value: '28'),
                          _StatisticItem(label: 'Months', value: '7'),
                          _StatisticItem(label: 'Days', value: '20'),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const ResultCard(
                    title: 'Totals',
                    children: [
                      _StatisticGrid(
                        items: [
                          _StatisticItem(label: 'Total Days', value: '10,462'),
                          _StatisticItem(label: 'Total Months', value: '343'),
                          _StatisticItem(label: 'Total Weeks', value: '1,494'),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const ResultCard(
                    title: 'Next Birthday',
                    children: [
                      _StatisticGrid(
                        items: [
                          _StatisticItem(
                            label: 'Next Birthday Date',
                            value: '15 November 2026',
                          ),
                          _StatisticItem(label: 'Days Remaining', value: '132'),
                        ],
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
        ),
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
