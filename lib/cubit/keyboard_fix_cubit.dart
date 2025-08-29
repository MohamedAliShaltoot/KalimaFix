
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kalima_fix/cubit/keyboard_fix_states.dart';
import 'package:kalima_fix/utils/conversion_enum.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KeyboardFixCubit extends Cubit<KeyboardFixState> {
  KeyboardFixCubit() : super(KeyboardFixInitial());

  static KeyboardFixCubit get(context) => BlocProvider.of(context);
  final TextEditingController inputController = TextEditingController();
  final TextEditingController outputController = TextEditingController();

  // خرائط التحويل
  static const Map<String, String> _enToAr = {
    "a": "ش",
    "b": "لا",
    "c": "ؤ",
    "d": "ي",
    "e": "ث",
    "f": "ب",
    "g": "ل",
    "h": "ا",
    "i": "ه",
    "j": "ت",
    "k": "ن",
    "l": "م",
    "m": "ة",
    "n": "ى",
    "o": "خ",
    "p": "ح",
    "q": "ض",
    "r": "ق",
    "s": "س",
    "t": "ف",
    "u": "ع",
    "v": "ر",
    "w": "ص",
    "x": "ء",
    "y": "غ",
    "z": "ئ",
    "[": "ج",
    "]": "د",
    "?": "ظ",
    ".": "ز",
    ",": "و",
    "`": "ذ",
    ";": "ك",
    "'": "ط",
    "/": "ظ",
    "\\": "\\",
    " ": " ",
    "\n": "\n",
  };

  static final Map<String, String> _arToEn = {
    for (var e in _enToAr.entries) e.value: e.key,
  };

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? false;
    final direction =
        ConversionDirection.values[prefs.getInt('direction') ??
            ConversionDirection.enToAr.index];
    final history = prefs.getStringList('history') ?? [];
    final autoConvert = prefs.getBool('autoConvert') ?? false;

    emit(
      KeyboardFixLoaded(
        inputText: '',
        convertedText: '',
        direction: direction,
        isDarkMode: isDarkMode,
        history: history,
        autoConvert: autoConvert,
      ),
    );
  }

  void updateInputText(String text) {
    final currentState = state as KeyboardFixLoaded;
    String convertedText = currentState.convertedText;

    if (currentState.autoConvert) {
      convertedText = _convertText(text, currentState.direction);
    }

    emit(currentState.copyWith(inputText: text, convertedText: convertedText));
  }

  void convertText() {
    final currentState = state as KeyboardFixLoaded;
    final convertedText = _convertText(
      currentState.inputText,
      currentState.direction,
    );

    emit(currentState.copyWith(convertedText: convertedText));

    // حفظ في التاريخ
    if (currentState.inputText.isNotEmpty && convertedText.isNotEmpty) {
      _addToHistory("${currentState.inputText} → $convertedText");
    }
  }

  String _convertText(String input, ConversionDirection direction) {
    if (input.isEmpty) return '';

    String result = "";
    final map = direction == ConversionDirection.enToAr ? _enToAr : _arToEn;

    for (int i = 0; i < input.length; i++) {
      String char = input[i];
      result += map[char.toLowerCase()] ?? char;
    }

    return result;
  }

  void toggleDirection() async {
    final currentState = state as KeyboardFixLoaded;
    final newDirection =
        currentState.direction == ConversionDirection.enToAr
            ? ConversionDirection.arToEn
            : ConversionDirection.enToAr;

    emit(currentState.copyWith(direction: newDirection));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('direction', newDirection.index);
  }

  void toggleTheme() async {
    final currentState = state as KeyboardFixLoaded;
    final newTheme = !currentState.isDarkMode;

    emit(currentState.copyWith(isDarkMode: newTheme));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', newTheme);
  }

  void toggleAutoConvert() async {
    final currentState = state as KeyboardFixLoaded;
    final newAutoConvert = !currentState.autoConvert;

    emit(currentState.copyWith(autoConvert: newAutoConvert));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoConvert', newAutoConvert);
  }

  void clearText() {
    final currentState = state as KeyboardFixLoaded;
    emit(currentState.copyWith(inputText: '', convertedText: ''));
  }

  void swapTexts() {
    final currentState = state as KeyboardFixLoaded;
    emit(
      currentState.copyWith(
        inputText: currentState.convertedText,
        convertedText: currentState.inputText,
      ),
    );
    toggleDirection();
  }

  void _addToHistory(String conversion) async {
    final currentState = state as KeyboardFixLoaded;
    final newHistory = List<String>.from(currentState.history);

    if (!newHistory.contains(conversion)) {
      newHistory.insert(0, conversion);
      if (newHistory.length > 20) {
        newHistory.removeLast();
      }

      emit(currentState.copyWith(history: newHistory));

      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('history', newHistory);
    }
  }

  void clearHistory() async {
    final currentState = state as KeyboardFixLoaded;
    emit(currentState.copyWith(history: []));

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('history');
  }

  void loadFromHistory(String conversion) {
    final parts = conversion.split(' → ');
    if (parts.length == 2) {
      final currentState = state as KeyboardFixLoaded;
      emit(currentState.copyWith(inputText: parts[0], convertedText: parts[1]));
    }
  }
}
