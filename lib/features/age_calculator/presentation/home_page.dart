import 'package:agely/features/age_calculator/presentation/widgets/result_section_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static final DateFormat _birthdayFormat = DateFormat('d MMMM y');

  @override
  Widget build(BuildContext context) {
    const dateOfBirth = '15 Nov 1997';

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 84,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Agely',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              'Age Calculator',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Date of Birth',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _DatePickerField(value: dateOfBirth, onTap: () {}),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {},
                  child: const Text('Calculate Age'),
                ),
                const SizedBox(height: 24),
                const ResultSectionCard(
                  icon: Icons.cake_outlined,
                  title: 'Your Age',
                  children: [
                    ResultValue(label: 'Years', value: '28 Years'),
                    ResultValue(label: 'Months', value: '7 Months'),
                    ResultValue(label: 'Days', value: '20 Days'),
                  ],
                ),
                const SizedBox(height: 16),
                const ResultSectionCard(
                  icon: Icons.calendar_today_outlined,
                  title: 'Total',
                  children: [
                    ResultValue(label: 'Days', value: '10,462 Days'),
                    ResultValue(label: 'Months', value: '343 Months'),
                    ResultValue(label: 'Weeks', value: '1,494 Weeks'),
                  ],
                ),
                const SizedBox(height: 16),
                ResultSectionCard(
                  icon: Icons.celebration_outlined,
                  title: 'Next Birthday',
                  children: [
                    const ResultValue(
                      label: 'Remaining',
                      value: '132 Days Remaining',
                    ),
                    ResultValue(
                      label: 'Date',
                      value: _birthdayFormat.format(DateTime(2026, 11, 15)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    'Version 1.0',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
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

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({required this.value, required this.onTap});

  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: IgnorePointer(
        child: TextFormField(
          initialValue: value,
          decoration: const InputDecoration(
            suffixIcon: Icon(Icons.calendar_today_outlined),
          ),
        ),
      ),
    );
  }
}
