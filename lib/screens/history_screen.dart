import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kalima_fix/cubit/keyboard_fix.dart';


class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("سجل التحويلات"),
        centerTitle: true,
        actions: [
          BlocBuilder<KeyboardFixCubit, KeyboardFixState>(
            builder: (context, state) {
              if (state is KeyboardFixLoaded && state.history.isNotEmpty) {
                return IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text("تأكيد"),
                            content: const Text("هل تريد مسح جميع التحويلات؟"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("إلغاء"),
                              ),
                              TextButton(
                                onPressed: () {
                                  context
                                      .read<KeyboardFixCubit>()
                                      .clearHistory();
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('تم مسح السجل'),
                                    ),
                                  );
                                },
                                child: const Text("مسح"),
                              ),
                            ],
                          ),
                    );
                  },
                  icon: const Icon(Icons.delete_sweep),
                  tooltip: "مسح السجل",
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<KeyboardFixCubit, KeyboardFixState>(
        builder: (context, state) {
          if (state is! KeyboardFixLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.history.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "لا يوجد تحويلات محفوظة",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "ابدأ بإجراء بعض التحويلات لتظهر هنا",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.history.length,
            itemBuilder: (context, index) {
              final conversion = state.history[index];
              final parts = conversion.split(' → ');

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(
                    parts.length > 0 ? parts[0] : conversion,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: parts.length > 1 ? Text(parts[1]) : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          context.read<KeyboardFixCubit>().loadFromHistory(
                            conversion,
                          );
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تم تحميل التحويل')),
                          );
                        },
                        icon: const Icon(Icons.refresh),
                        tooltip: "تحميل",
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                  onTap: () {
                    context.read<KeyboardFixCubit>().loadFromHistory(
                      conversion,
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم تحميل التحويل')),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
