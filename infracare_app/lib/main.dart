import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_routes.dart';

void main() {
  runApp(
    // ProviderScope is required by flutter_riverpod and must wrap the
    // entire widget tree. All providers are lazily initialised on first use.
    const ProviderScope(
      child: InfraCareApp(),
    ),
  );
}

class InfraCareApp extends StatelessWidget {
  const InfraCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InfraCare',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: AppRoutes.login,
      routes: AppRoutes.routes,
    );
  }
}
