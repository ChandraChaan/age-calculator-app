import 'package:flutter/material.dart';

class DobPicker extends StatelessWidget {
  const DobPicker({required this.placeholder, required this.onTap, super.key});

  final String placeholder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: IgnorePointer(
        child: TextFormField(
          decoration: InputDecoration(
            hintText: placeholder,
            suffixIcon: const Icon(Icons.calendar_today_outlined),
          ),
        ),
      ),
    );
  }
}
