import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kalima_fix/cubit/keyboard_fix.dart';

import 'screens/keyboard_fix_screen.dart';

void main() {
  runApp(const KeyboardFixApp());
}

class KeyboardFixApp extends StatelessWidget {
  const KeyboardFixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => KeyboardFixCubit()..initialize(),
      child: BlocBuilder<KeyboardFixCubit, KeyboardFixState>(
        builder: (context, state) {
          bool isDarkMode = false;

          if (state is KeyboardFixLoaded) {
            isDarkMode = state.isDarkMode;
          }

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Keyboard Fix',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const KeyboardFixScreen(),
          );
        },
      ),
    );
  }
}
