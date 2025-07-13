import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme_state.dart';
import 'package:flutter/material.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(const ThemeState(ThemeMode.dark));
  void toggleTheme(bool isDarkMode) {
    emit(ThemeState(isDarkMode ? ThemeMode.dark : ThemeMode.light));
  }
}
