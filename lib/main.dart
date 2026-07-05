import 'package:agely/core/theme/app_theme.dart';
import 'package:agely/features/age_calculator/presentation/age_calculator_controller.dart';
import 'package:agely/features/age_calculator/presentation/home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const AgelyApp());
}

class AgelyApp extends StatelessWidget {
  const AgelyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AgeCalculatorController()..initialize(),
      child: Consumer<AgeCalculatorController>(
        builder: (context, controller, child) {
          return MaterialApp(
            title: 'Agely',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: controller.themeMode,
            home: const HomePage(),
          );
        },
      ),
    );
  }
}
