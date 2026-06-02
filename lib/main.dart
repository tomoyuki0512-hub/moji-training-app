import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'services/addition_service.dart';
import 'theme.dart';

void main() {
  runApp(const TashizanApp());
}

/// 4さい から はじめる、かわいい たしざん アプリ。
class TashizanApp extends StatelessWidget {
  const TashizanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'たしざん',
      theme: AppTheme.light,
      home: HomeScreen(service: AdditionService()),
      debugShowCheckedModeBanner: false,
    );
  }
}
