import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'app/providers.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String mode = ref.watch(themeModeProvider);
    final ThemeData light = buildTheme();
    final ThemeData dark = buildDarkTheme();
    return MaterialApp(
      title: 'MeshChat',
      theme: light,
      darkTheme: dark,
      themeMode: mode == 'dark' ? ThemeMode.dark : mode == 'light' ? ThemeMode.light : ThemeMode.system,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}

// Screens will be wired later.
