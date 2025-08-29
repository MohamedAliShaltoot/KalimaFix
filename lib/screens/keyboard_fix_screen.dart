// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kalima_fix/core/utils/app_constants.dart';
import 'package:kalima_fix/cubit/keyboard_fix_cubit.dart';
import 'package:kalima_fix/cubit/keyboard_fix_states.dart';
import 'package:kalima_fix/screens/history_screen.dart';
import 'package:kalima_fix/core/utils/conversion_enum.dart';
import 'package:kalima_fix/core/reusable_widgets/custom_elevated_btn.dart';
import 'package:kalima_fix/core/reusable_widgets/global_circular_indicator.dart';
import 'package:kalima_fix/core/reusable_widgets/global_snack_bar.dart';

class KeyboardFixScreen extends StatelessWidget {
  const KeyboardFixScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<KeyboardFixCubit, KeyboardFixState>(
      listener: (context, state) {
        if (state is KeyboardFixLoaded) {
          if (KeyboardFixCubit.get(context).inputController.text !=
              state.inputText) {
            KeyboardFixCubit.get(context).inputController.text =
                state.inputText;
          }
          KeyboardFixCubit.get(context).outputController.text =
              state.convertedText;
        }
      },
      builder: (context, state) {
        if (state is! KeyboardFixLoaded) {
          return const Scaffold(body: GlobalCircularIndicator());
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              AppConstants.appName,
              style: TextStyle(fontWeight: FontWeight.w700),
            ),

            actions: [
              IconButton(
                onPressed: () => KeyboardFixCubit.get(context).toggleTheme(),
                icon: Icon(
                  state.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
              ),
              IconButton(
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HistoryScreen(),
                      ),
                    ),
                icon: const Icon(Icons.history),
              ),
              PopupMenuButton<String>(
                tooltip: AppConstants.moreOptionsTitle,
                icon: const Icon(Icons.more_vert_rounded),
                onSelected: (value) {
                  switch (value) {
                    case 'clear_all':
                      KeyboardFixCubit.get(context).clearText();
                      break;
                    case 'clear_history':
                      KeyboardFixCubit.get(context).clearHistory();
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(displaySnackBar(message: AppConstants.historyCleared));
                      break;
                  }
                },
                itemBuilder:
                    (context) => [
                       PopupMenuItem(
                        value: 'clear_all',
                        child: Row(
                          children: [
                            Icon(Icons.clear_all),
                            SizedBox(width: 8),
                            Text(AppConstants.clearInputs),
                          ],
                        ),
                      ),
                       PopupMenuItem(
                        value: 'clear_history',
                        child: Row(
                          children: [
                            Icon(Icons.history_toggle_off),
                            SizedBox(width: 8),
                            Text(AppConstants.clearHistory),
                          ],
                        ),
                      ),
                    ],
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              height:
                  MediaQuery.of(context).size.height -
                  AppBar().preferredSize.height -
                  MediaQuery.of(context).padding.top -
                  24,
              child: Column(
                children: [
                  // إعدادات التحويل - أكثر إيجازاً
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                               Text(
                                AppConstants.conversionDirection,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    state.direction ==
                                            ConversionDirection.enToAr
                                        ? AppConstants.conversionEnToAr
                                        : AppConstants.conversionArToEn,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  IconButton(
                                    constraints: const BoxConstraints(
                                      minWidth: 32,
                                      minHeight: 32,
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    onPressed:
                                        () =>
                                            KeyboardFixCubit.get(
                                              context,
                                            ).toggleDirection(),
                                    icon: const Icon(
                                      Icons.swap_horiz,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppConstants.autoConversion,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Switch(
                                value: state.autoConvert,
                                onChanged:
                                    (value) =>
                                        KeyboardFixCubit.get(
                                          context,
                                        ).toggleAutoConvert(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // حقل النص المدخل - حجم أكبر
                  Expanded(
                    flex: 4,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppConstants.originalText,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      constraints: const BoxConstraints(
                                        minWidth: 32,
                                        minHeight: 32,
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      onPressed: () async {
                                        final data = await Clipboard.getData(
                                          'text/plain',
                                        );
                                        if (data?.text != null) {
                                          KeyboardFixCubit.get(
                                            context,
                                          ).updateInputText(data!.text!);
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.content_paste,
                                        size: 18,
                                      ),
                                      tooltip: AppConstants.paste,
                                    ),
                                    IconButton(
                                      constraints: const BoxConstraints(
                                        minWidth: 32,
                                        minHeight: 32,
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      onPressed:
                                          () =>
                                              KeyboardFixCubit.get(
                                                context,
                                              ).clearText(),
                                      icon: const Icon(Icons.clear, size: 18),
                                      tooltip: AppConstants.clear,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: TextField(
                                controller:
                                    KeyboardFixCubit.get(
                                      context,
                                    ).inputController,
                                maxLines: null,
                                expands: true,
                                textAlignVertical: TextAlignVertical.top,
                                style: const TextStyle(fontSize: 16),
                                decoration:  InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: AppConstants.enterOriginalTextHere,
                                  contentPadding: EdgeInsets.all(12),
                                ),
                                onChanged:
                                    (text) => KeyboardFixCubit.get(
                                      context,
                                    ).updateInputText(text),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // أزرار التحكم - أصغر
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CustomElevatedButton(
                        btnName: AppConstants.convert,
                        icon: Icons.transform,
                        onPressed:
                            () => KeyboardFixCubit.get(context).convertText(),
                      ),
                      CustomElevatedButton(
                        btnName: AppConstants.swap,
                        icon: Icons.swap_vert,
                        onPressed:
                            () => KeyboardFixCubit.get(context).swapTexts(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // حقل النتيجة - حجم أكبر
                  Expanded(
                    flex: 4,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppConstants.theResult,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                IconButton(
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  onPressed:
                                      state.convertedText.isNotEmpty
                                          ? () {
                                            Clipboard.setData(
                                              ClipboardData(
                                                text: state.convertedText,
                                              ),
                                            );
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              displaySnackBar(
                                                message: AppConstants.copyComplete,
                                              ),
                                            );
                                          }
                                          : null,
                                  icon: const Icon(Icons.copy, size: 18),
                                  tooltip: AppConstants.copy,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: SingleChildScrollView(
                                  child: SelectableText(
                                    state.convertedText.isEmpty
                                        ? AppConstants.theResultWillShowHere
                                        : state.convertedText,
                                    style: TextStyle(
                                      fontSize: 16,
                                      height: 1.4,
                                      color:
                                          state.convertedText.isEmpty
                                              ? Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant
                                              : null,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton:
              state.inputText.isNotEmpty
                  ? FloatingActionButton(
                    onPressed:
                        () => KeyboardFixCubit.get(context).convertText(),
                    child: const Icon(Icons.play_arrow),
                  )
                  : null,
        );
      },
    );
  }
}
