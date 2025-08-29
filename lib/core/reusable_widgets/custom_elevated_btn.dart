import 'package:flutter/material.dart';


class CustomElevatedButton extends StatelessWidget {
  const CustomElevatedButton({
    super.key,
    required this.btnName,
    this.icon,
    this.onPressed,
  });
  final String btnName;
  final IconData? icon;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(btnName, style: TextStyle(fontSize: 14)),
    );
  }
}
