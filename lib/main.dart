import 'package:agely/core/theme/app_theme.dart';
import 'package:agely/features/age_calculator/presentation/home_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const AgelyApp());
}

class AgelyApp extends StatelessWidget {
  const AgelyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agely',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const HomePage(),
    );
  }
}
