import 'package:flutter/material.dart';

class DateInputField extends StatelessWidget {
  const DateInputField({
    required this.label,
    required this.placeholder,
    required this.onTap,
    this.value,
    this.errorText,
    this.helperText,
    super.key,
  });

  final String label;
  final String placeholder;
  final String? value;
  final String? errorText;
  final String? helperText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          helperText: helperText,
          errorText: errorText,
          suffixIcon: const Icon(Icons.calendar_today_outlined),
        ),
        child: Text(
          value ?? placeholder,
          style: textTheme.bodyLarge?.copyWith(
            color: value == null
                ? colorScheme.onSurfaceVariant
                : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
