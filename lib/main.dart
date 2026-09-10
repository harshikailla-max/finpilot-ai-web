import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/finance_provider.dart';
import 'providers/budget_provider.dart';
import 'providers/goal_provider.dart';

import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => FinanceProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => BudgetProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => GoalProvider(),
        ),
      ],
      child: const FinPilotApp(),
    ),
  );
}

class FinPilotApp extends StatelessWidget {
  const FinPilotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FinPilot AI',
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}