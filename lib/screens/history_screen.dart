import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kalima_fix/core/utils/app_constants.dart';
import 'package:kalima_fix/core/utils/app_strings.dart';
import 'package:kalima_fix/cubit/keyboard_fix_cubit.dart';
import 'package:kalima_fix/cubit/keyboard_fix_states.dart';
import 'package:kalima_fix/core/reusable_widgets/global_circular_indicator.dart';
import 'package:kalima_fix/core/reusable_widgets/global_snack_bar.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_ios, size: 23),
            ),

            Text(
              AppConstants.conversionHistoryTitle,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 60),
          ],
        ),

        actions: [
          BlocBuilder<KeyboardFixCubit, KeyboardFixState>(
            builder: (context, state) {
              if (state is KeyboardFixLoaded && state.history.isNotEmpty) {
                return IconButton(
                  onHover: (isHovered) {
                    if (isHovered) {
                      // Show a tooltip or change the icon color
                    }
                  },
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text(AppConstants.confirm),
                            content: const Text(AppConstants.clearHistoryConfirmation),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text(AppConstants.cancel),
                              ),
                              TextButton(
                                onPressed: () {
                                  KeyboardFixCubit.get(context).clearHistory();
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    displaySnackBar(message: AppConstants.historyCleared),
                                  );
                                },
                                child:  Text(AppConstants.clearHistory),
                              ),
                            ],
                          ),
                    );
                  },
                  icon: const Icon(
                    Icons.delete_rounded,
                    size: 26,
                    color: Colors.redAccent,
                  ),
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
            return const GlobalCircularIndicator();
          }

          if (state.history.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 250,
                      width: 250,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        
                        image: DecorationImage(
                          image: AssetImage(AppStrings.notFoundImage),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),

                    SizedBox(height: 16),
                    Text(
                      AppConstants.noConversionsFound,
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      AppConstants.startMakingConversions,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.history.length,
            itemBuilder: (context, index) {
              final conversion = state.history[index];
              final parts = conversion.split(' → ');

              return Dismissible(
                key: ValueKey(conversion), // unique key
                direction:
                    DismissDirection.endToStart, // swipe from right to left
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) {
                  // here i want only delete the specific item
                 KeyboardFixCubit.get(context).clearHistory();

                  ScaffoldMessenger.of(context).showSnackBar(
                    displaySnackBar(
                      message: AppConstants.itemDeleted,
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(
                      parts.isNotEmpty ? parts[0] : conversion,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: parts.length > 1 ? Text(parts[1]) : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            KeyboardFixCubit.get(
                              context,
                            ).loadFromHistory(
                              conversion,
                            );
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                             displaySnackBar(
                                message: AppConstants.conversionLoaded,
                              ),
                            );
                          },
                          icon: const Icon(Icons.download_done),
                          tooltip: AppConstants.loadToolTipTitle,
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                    onTap: () {
                       KeyboardFixCubit.get(context).loadFromHistory(
                        conversion,
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        displaySnackBar(message: AppConstants.conversionLoaded)
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
