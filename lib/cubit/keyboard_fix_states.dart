import 'package:kalima_fix/core/utils/conversion_enum.dart';

abstract class KeyboardFixState {}

class KeyboardFixInitial extends KeyboardFixState {}

class KeyboardFixLoaded extends KeyboardFixState {
  final String inputText;
  final String convertedText;
  final ConversionDirection direction;
  final bool isDarkMode;
  final List<String> history;
  final bool autoConvert;

  KeyboardFixLoaded({
    required this.inputText,
    required this.convertedText,
    required this.direction,
    required this.isDarkMode,
    required this.history,
    required this.autoConvert,
  });

  KeyboardFixLoaded copyWith({
    String? inputText,
    String? convertedText,
    ConversionDirection? direction,
    bool? isDarkMode,
    List<String>? history,
    bool? autoConvert,
  }) {
    return KeyboardFixLoaded(
      inputText: inputText ?? this.inputText,
      convertedText: convertedText ?? this.convertedText,
      direction: direction ?? this.direction,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      history: history ?? this.history,
      autoConvert: autoConvert ?? this.autoConvert,
    );
  }
}
