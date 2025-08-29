import 'package:flutter/material.dart';

class GlobalCircularIndicator extends StatelessWidget {
  const GlobalCircularIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        strokeWidth: 2.0,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        
      ),
    );
  }
}