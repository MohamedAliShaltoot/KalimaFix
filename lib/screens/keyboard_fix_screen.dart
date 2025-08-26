import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kalima_fix/cubit/keyboard_fix.dart';
import 'package:kalima_fix/screens/history_screen.dart';


class KeyboardFixScreen extends StatefulWidget {
  const KeyboardFixScreen({super.key});

  @override
  State<KeyboardFixScreen> createState() => _KeyboardFixScreenState();
}

class _KeyboardFixScreenState extends State<KeyboardFixScreen> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<KeyboardFixCubit, KeyboardFixState>(
      listener: (context, state) {
        if (state is KeyboardFixLoaded) {
          if (_inputController.text != state.inputText) {
            _inputController.text = state.inputText;
          }
          _outputController.text = state.convertedText;
        }
      },
      builder: (context, state) {
        if (state is! KeyboardFixLoaded) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text("Keyboard Fix"),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () => context.read<KeyboardFixCubit>().toggleTheme(),
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
                onSelected: (value) {
                  switch (value) {
                    case 'clear_all':
                      context.read<KeyboardFixCubit>().clearText();
                      break;
                    case 'clear_history':
                      context.read<KeyboardFixCubit>().clearHistory();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم مسح السجل')),
                      );
                      break;
                  }
                },
                itemBuilder:
                    (context) => [
                      const PopupMenuItem(
                        value: 'clear_all',
                        child: Row(
                          children: [
                            Icon(Icons.clear_all),
                            SizedBox(width: 8),
                            Text('مسح النصوص'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'clear_history',
                        child: Row(
                          children: [
                            Icon(Icons.history_toggle_off),
                            SizedBox(width: 8),
                            Text('مسح السجل'),
                          ],
                        ),
                      ),
                    ],
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // إعدادات التحويل
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "اتجاه التحويل:",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                Text(
                                  state.direction == ConversionDirection.enToAr
                                      ? "إنجليزي → عربي"
                                      : "عربي → إنجليزي",
                                ),
                                IconButton(
                                  onPressed:
                                      () =>
                                          context
                                              .read<KeyboardFixCubit>()
                                              .toggleDirection(),
                                  icon: const Icon(Icons.swap_horiz),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "التحويل التلقائي:",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Switch(
                              value: state.autoConvert,
                              onChanged:
                                  (value) =>
                                      context
                                          .read<KeyboardFixCubit>()
                                          .toggleAutoConvert(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // حقل النص المدخل
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "النص الأصلي:",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () async {
                                      final data = await Clipboard.getData(
                                        'text/plain',
                                      );
                                      if (data?.text != null) {
                                        context
                                            .read<KeyboardFixCubit>()
                                            .updateInputText(data!.text!);
                                      }
                                    },
                                    icon: const Icon(Icons.content_paste),
                                    tooltip: "لصق",
                                  ),
                                  IconButton(
                                    onPressed:
                                        () =>
                                            context
                                                .read<KeyboardFixCubit>()
                                                .clearText(),
                                    icon: const Icon(Icons.clear),
                                    tooltip: "مسح",
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: TextField(
                              controller: _inputController,
                              maxLines: null,
                              expands: true,
                              textAlignVertical: TextAlignVertical.top,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: "ادخل النص هنا...",
                              ),
                              onChanged:
                                  (text) => context
                                      .read<KeyboardFixCubit>()
                                      .updateInputText(text),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // أزرار التحكم
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed:
                          () => context.read<KeyboardFixCubit>().convertText(),
                      icon: const Icon(Icons.transform),
                      label: const Text("تحويل"),
                    ),
                    ElevatedButton.icon(
                      onPressed:
                          () => context.read<KeyboardFixCubit>().swapTexts(),
                      icon: const Icon(Icons.swap_vert),
                      label: const Text("تبديل"),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // حقل النتيجة
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "النتيجة:",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              IconButton(
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
                                            const SnackBar(
                                              content: Text('تم النسخ!'),
                                            ),
                                          );
                                        }
                                        : null,
                                icon: const Icon(Icons.copy),
                                tooltip: "نسخ",
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
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: SingleChildScrollView(
                                child: SelectableText(
                                  state.convertedText.isEmpty
                                      ? "النتيجة ستظهر هنا..."
                                      : state.convertedText,
                                  style: TextStyle(
                                    fontSize: 16,
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
          floatingActionButton:
              state.inputText.isNotEmpty
                  ? FloatingActionButton(
                    onPressed:
                        () => context.read<KeyboardFixCubit>().convertText(),
                    child: const Icon(Icons.play_arrow),
                  )
                  : null,
        );
      },
    );
  }
}
