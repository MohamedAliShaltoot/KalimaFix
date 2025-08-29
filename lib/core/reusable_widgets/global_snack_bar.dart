import 'package:flutter/material.dart';

SnackBar displaySnackBar({required String message}) {
  return SnackBar(
    content: Text(message),
    duration: Duration(seconds: 1),
    elevation: 5,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(8),
        topRight: Radius.circular(8),
      ),
    ),
  );
}
